import xml.etree.ElementTree as ET
import sys
import os
import re
import traceback
import argparse
from collections import namedtuple

try:
    from tkinter import *
except:
    from Tkinter import *

# Tuple that captures all of the possible net configurations
NetType = namedtuple('NetType', ['external', 'input_connected', 'output_connected', 'open_drain_connected', 'tristate_connected'])

# Simple class representing a pin on a component
class Pin(object):
    def __init__(self, ref, number, type=None, net=None):
        self.number = number
        self.type = type
        self.net = net
        self.ref = ref
    
    def __str__(self):
        # If this pin has a net connected, use the net name.
        # Otherwise, make a "not connected" name using the component ref and pin number
        return self.net if self.net is not None else ' '

# Class representing each component in a schematic
class Component(object):
    def __init__(self, comp, libparts):
        # Load the basics from this component's node
        self.ref = comp.attrib['ref']
        self.type = comp.find('libsource').attrib['part']
        self.initial_values = {}
        self.pins = []
        self.fpga_flags = []
        
        # Look for codegen flags that have been set for this component
        self.process_codegen_fields(comp)
        
        # Build up a list of pins and their types
        if not self.load_pin_types(libparts):
            raise RuntimeError('Unable to load pin types for %s' % self.ref)
    
    def process_codegen_fields(self, comp):
        for part in comp.iterfind('.//part'):
            part_unit = part.attrib['unit']
            # Unless otherwise specified, assume everything starts at 0
            self.initial_values[part_unit] = "1'b0"

            for f in part.iterfind('.//field'):
                if f.attrib['name'] == 'Initial':
                    # This part has an initial condition, capture it
                    self.initial_values[part_unit] = "1'b" + f.text
                    break
                elif f.attrib['name'].startswith('FPGA#'):
                    # Stash away all of the FPGA-related codegen flags
                    self.fpga_flags.append(f.attrib['name'] + ':' + f.text)
    
    def load_pin_types(self, libparts):
        # Look up this component's part in the netlist's part library. It might
        # either be the official name of the component or one of its aliases.
        for libpart in libparts.iter('libpart'):
            part_name = libpart.attrib['part']
            aliases = [a.text for a in libpart.iterfind('.//alias')]
            pin_num = 1
            if self.type == part_name or self.type in aliases:
                # Found a match! Fill out the pin list with I/O types. Nets will be attached later.
                for pin_def in libpart.iterfind('.//pin'):
                    if str(pin_num) != pin_def.attrib['num']:
                        raise RuntimeError('Pin definitions for %s are out of order' % part_name)
                    self.pins.append(Pin(self.ref, pin_num, pin_def.attrib['type']))
                    pin_num += 1
                
                return True
        return False
        
    def unconnected_pins(self):
        # Return a list of pins with no attached net
        return [pin for pin in self.pins if pin.net is None]

    def __str__(self):
        # Build up a verilog representation of this component
        pin_names = []
        open_drains = []

        # Build up a list of pin names and note any pins that are open-drain or tristate
        for pin in self.pins:
            if pin.type in ['openCol', '3state'] and pin.net is not None:
                open_drains.append(pin.number)

            pin_names.append(str(pin))

        type_name = self.type
        if self.ref[0] == 'R':
            # Resistors (currently) always manifest as pullups or pulldowns.
            if 'p4VDC' in pin_names or 'p4VSW' in pin_names:
                return 'pullup %s(%s);' % (self.ref, pin_names[0] if not pin_names[0].startswith('p4V') else pin_names[1])
            elif 'GND' in pin_names:
                return 'pulldown %s(%s);' % (self.ref, pin_names[0] if pin_names[0] != 'GND' else pin_names[1])
            else:
                raise RuntimeError("Error processing resistor %s, not connected to p4V" % self.ref)
        else:
            if type_name[0].isdigit():
                # Lots of parts (like 74xx chips) start with a number, so prepend a U
                # to make Verilog happy
                type_name = 'U' + type_name

            if any([iv == "1'b1" for _,iv in self.initial_values.items()]):
                # If any of the initial conditions for this component are 1, we need to print them out
                ivs = [self.initial_values[part] for part in sorted(self.initial_values.keys())]
                # Multipart components have a separate voltage pin that we need to filter out
                if len(ivs) > 1:
                    ivs = ivs[:-1]
                iv_string = ' #(' + ', '.join(ivs) + ') '
            else:
                # Otherwise we'll just let everything default to 0.
                iv_string = ' '

            # Any FPGA codegen flags we have will be emitted as comments for the backplane generator to deal with
            comment_list = self.fpga_flags

            # If we have any open-drain or tristate pins, we also need to leave an FPGA codegen flag for the
            # backplane generator about which ones those are
            if open_drains:
                comment_list.append('FPGA#OD:' + ','.join(str(p) for p in open_drains))

            if comment_list:
                # Build up the final comment containing all codegen flags, separated by semicolons
                comment = ' //' + ';'.join(comment_list)
            else:
                comment = ''

            return type_name + iv_string + self.ref + '(' + ', '.join(pin_names) + ', SIM_RST, SIM_CLK);' + comment

symbolFile = ""
class VerilogGenerator(object):

    def __init__(self, module, root, symbolFile):
        self.module = module
        self.root = root
        self.components = {}
        self.net_types = {}
	self.symbolFile = symbolFile

        # Find the module number for signal naming
        self.module_name = 'Z99'
        for sheet in root.find('design').iter('sheet'):
            sheet_name = re.match('/([AB]\d{2})', sheet.attrib['name'])
            if sheet_name is not None:
                self.module_name = sheet_name.group(1)
                break
        
        # Build a list of all of the components for this module
        self.load_components(root.find('components'))
        
        # Build a netlist and attach it to the components
        self.load_nets(root.find('nets'))


    def make_net_name(self, net):
        # Trailing slashes mean negated signals
        name = re.sub('/$', '_n', net.attrib['name'])
        # Otherwise, they're path seperators for a local symbol

        name = name.replace('/','__')
        self.symbolFile.write(name + " ")
        if name.startswith('Net-'):
            #name = '__' + self.module_name + '_NET_' + net.attrib['code']
            name = name.replace("Net-(","net_").replace("-","_").replace(")","")
	self.symbolFile.write('__' + self.module_name + '_NET_' + net.attrib['code'] + " ")
        self.symbolFile.write(name + "\n")

        if name[0].isdigit():
            name = 'n' + name

        # Replace + and - with p and m
        name = name.replace('+','p')
        name = name.replace('-','m')

        return name
    
    def load_components(self, components):
        # Build up the list of components
        libparts = self.root.find('libparts')
        for comp in components.iter('comp'):
            comp_ref = comp.attrib['ref']
            self.components[comp_ref] = Component(comp, libparts)
            
    def load_nets(self, nets):
        # Build the list of nets and attach them to components
        for net in nets.iter('net'):
            net_name = self.make_net_name(net)
            
            # Very, very basic Verilog wire type determination. "External signal"
            # means this net is connected to a connector, and "output connected" means
            # that at least one of the net's connections are to a pin of type "output"
            num_nodes = len(net)

            external_signal = False
            input_connected = False
            output_connected = False
            open_drain_connected = False
            tristate_connected = False
            not_connected = False
            for node in net.iter('node'):
                # Attach this net to all of its pins
                ref = node.attrib['ref']
                pin_num = int(node.attrib['pin'])

                pin_type = self.components[ref].pins[pin_num-1].type
                if pin_type == 'NotConnected':
                    if num_nodes != 1:
                        raise RuntimeError('Found an NC pin connected to something else')
                    not_connected = True
                    break
                elif pin_type == 'output':
                    output_connected = True
                elif pin_type == 'openCol':
                    open_drain_connected = True
                elif pin_type == '3state':
                    tristate_connected = True
                elif pin_type == 'input':
                    input_connected = True
                elif ref[0] == 'R':
                    for pin in self.components[ref].pins:
                        if str(pin) == 'GND':
                            output_connected = True
                            break
                
                # Determine the wire type
                if ref[0] == 'P':
                    external_signal = True


                self.components[ref].pins[pin_num-1].net = net_name
            
            if not not_connected:
                self.net_types[net_name] = NetType(external_signal, input_connected, output_connected, open_drain_connected, tristate_connected)

    def generate_file(self, filename):
        # Dump verilog to the given filename
        with open(filename, 'w') as f:
            # Settings
            f.write('`timescale 1ns/1ps\n')
            f.write('`default_nettype none\n\n')
            
            # Write the module name, along with the standard inputs
            f.write('module %s(SIM_RST, SIM_CLK' % self.module)

            if 'p4VDC' in self.net_types:
                f.write(', p4VDC')
            if 'p4VSW' in self.net_types:
                f.write(', p4VSW')

            f.write(', GND')
            
            # Assuming P1 is the 'backplane connector', write out its attached
            # pins in order as the module inputs
            for pin in self.components['P1'].pins:
                # Write out all 
                if pin.net in ['p4VDC', 'p4VSW', 'GND']:
                    continue
                f.write(', ' + pin.net)

            f.write(');\n')
            f.write('    input wire SIM_RST;\n')
            f.write('    input wire SIM_CLK;\n')
            if 'p4VDC' in self.net_types:
                f.write('    input wire p4VDC;\n')
            if 'p4VSW' in self.net_types:
                f.write('    input wire p4VSW;\n')
            f.write('    input wire GND;\n')

            # Write out all of the wire declarations
            for net, net_type in sorted(self.net_types.items()):
                if net in ['p4VDC', 'p4VSW', 'GND']:
                    continue
                f.write('    ')
                io_type = ''
                if net_type.external:
                    # For non-internal wires, write out the I/O type
                    if net_type.input_connected and (net_type.open_drain_connected or net_type.tristate_connected):
                        io_type = 'inout '
                    elif net_type.output_connected or net_type.open_drain_connected or net_type.tristate_connected:
                        io_type = 'output '
                    elif net_type.input_connected:
                        io_type = 'input '
                    else:
                        io_type = 'output '

                if net_type.tristate_connected:
                    # Tristates become wors on the FPGA
                    comment = ' //FPGA#wor'
                elif net_type.open_drain_connected:
                    # Open drains become wands on the FPGA
                    comment = ' //FPGA#wand'
                else:
                    comment = ''

                f.write('%swire %s;%s\n' % (io_type, net, comment))
                
            f.write('\n')

            # Finally, dump the list of components
            for ref, comp in sorted(self.components.items(), key=lambda des: des[0][0] + des[0][-2:]):
                if ref[0] == 'P':
                    continue

                f.write('    %s\n' % comp)
            
            # And close out the module
            f.write('endmodule');

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate AGC Verilog from KiCad XML netlist")
    parser.add_argument('input_file', help="Input netlist XML file")
    parser.add_argument('output_file', help="Output Verilog filename")
    parser.add_argument('-g', '--gui', help="Show GUI dialogs", action="store_true")
    args = parser.parse_args()

    # Determine the module name and output filename
    filename = args.output_file
    module_path, ext = os.path.splitext(filename)
    module = os.path.basename(module_path)
    if ext == '':
        filename += '.v'

    symbolFile = open(filename + ".symbols", "w")

    if args.gui:
        top = Tk()

    try:
        # Parse the netlist XML
        tree = ET.parse(args.input_file)
        root = tree.getroot()

        # Make a verilog generator and use it to generate some verilog!
        verilog_generator = VerilogGenerator(module, root, symbolFile)
        verilog_generator.generate_file(filename)

        if args.gui:
            top.wm_title("AGC Verilog Generation Complete")
            Message(top, text="Successfully generated code for module %s\n" % module, width=800).pack()
            Button(top, text="OK", command=top.destroy).pack()
            mainloop()

    except:
        if args.gui:
            top.wm_title("AGC Verilog Generation Error")
            Message(top, text="Error generating code for module %s:\n\n%s" % (module,traceback.format_exc()), width=800).pack()
            Button(top, text="OK", command=top.destroy).pack()
            mainloop()
        else:
            traceback.print_exc()
