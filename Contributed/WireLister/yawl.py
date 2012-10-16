#!/usr/bin/env python

# Program to process an AGC wirelist and generate a cross-referenced
# signal dictionary.
#
# (c) 2009 Jim Lawton <jim DOT lawton AT gmail DOT com>

import os
import sys
import time
import re
import ConfigParser
import optparse

# Default input file name. Can be overridden on the command line.
DEFAULT_INPUT_FILENAME = "agc_signals.txt"

# Output file names.
XREF_FILENAME = "agc_wirelist_xref.txt"
ERROR_FILENAME = "agc_wirelist_errors.txt"
PAGECOUNT_FILENAME = "agc_wirelist_pagecounts.txt"
DICTIONARY_FILENAME = "agc_wirelist_dictionary.txt"

class Signal:
    """Class to hold a signal."""
    
    def __init__(self, name, src=None, sink=None):
        self.name = name
        self.description = ''
        self.type = ''
        self.src_mods = []
        self.src_pages = []
        self.sink_mods = []
        self.sink_pages = []
        self.page_counts = {}
        if src and src not in self.src_pages:
            self.src_mods.append(getModuleName(src))
            self.src_pages.append(src)
        if sink and sink not in self.sink_pages:
            self.sink_mods.append(getModuleName(sink))
            self.sink_pages.append(sink)
        # Page counts
        if src or sink:
            if src and sink and src == sink:
                self.page_counts[src] = 2
            else:
                if src:
                    self.page_counts[src] = 1
                if sink:
                    self.page_counts[sink] = 1
            
    def addSource(self, page):
        module = getModuleName(page)
        if module not in self.src_mods:
            self.src_mods.append(module)
        if page not in self.src_pages:
            self.src_pages.append(page)
        if page in self.page_counts:
            self.page_counts[page] += 1
        else:
            self.page_counts[page] = 1

    def addSink(self, page):
        module = getModuleName(page)
        if module not in self.sink_mods:
            self.sink_mods.append(module)
        if page not in self.sink_pages:
            self.sink_pages.append(page)
        if page in self.page_counts:
            self.page_counts[page] += 1
        else:
            self.page_counts[page] = 1

    def getName(self):
        return self.name

    def getNumSourceModules(self):
        return len(self.src_mods)

    def getNumSourcePages(self):
        return len(self.src_pages)

    def getNumSinkModules(self):
        return len(self.sink_mods)

    def getNumSinkPages(self):
        return len(self.sink_pages)

    def getNumOnPage(self, page):
        return self.page_counts[page]

    def getSourceList(self):
        return ','.join(self.src_pages)

    def getSinkList(self):
        return ','.join(self.sink_pages)

    def __str__(self):
        if len(self.src_pages) == 0 or len(self.sink_pages) == 0:
            if len(self.src_pages) == 0:
                text = "%-12s%-64s" % (self.name, ','.join(self.sink_pages))
            if len(self.sink_pages) == 0:
                text = "%-12s%-32s" % (self.name, ','.join(self.src_pages))
        else:
            text = "%-12s%-32s%-64s" % (self.name, ','.join(self.src_pages), ','.join(self.sink_pages))
        return text

    def getPageCounts(self):
        pages = []
        for page in self.src_pages:
            pages.append(page)
        for page in self.sink_pages:
            if page not in pages:
                pages.append(page)
        pages.sort(pageSorter)
        #text = "%-12s" % self.name
        text = ""
        for page in pages:
            text += "%s:%d," % (page, self.page_counts[page])
        text = text[:-1]
        return text

    def setDescription(self, description):
        self.description = description

    def getDescription(self):
        return self.description

    def setType(self, type):
        self.type = type

    def getType(self):
        return self.type

def getOpts():
    parser = optparse.OptionParser("usage: %prog [options] filename")

    (options, args) = parser.parse_args()

    if len(args) < 1:
        if os.path.exists(DEFAULT_INPUT_FILENAME):
            options.filename = DEFAULT_INPUT_FILENAME
        else:
            parser.error("signal filename required, or default file (%s) must exist!" % DEFAULT_INPUT_FILENAME)
    else:
        options.filename = args[0]

    return options


def getModuleName(page):
    if '-' in page:
        return page[:page.find('-')]
    else:
        return page


def getModulePage(page):
    if '-' in page:
        return page[page.find('-'):]
    else:
        return None


def modSorter(x, y):
    newx = x
    newy = y
    startx = x[0]
    starty = y[0]
    if startx == starty:
        if x.startswith('A') or y.startswith('A') or x.startswith('B') or y.startswith('B'):
            if x.startswith('A') or x.startswith('B'):
                newx = int(x[1:])
            if y.startswith('A') or y.startswith('B'):
                newy = int(y[1:])
        return cmp(newx, newy)
    else:
        return cmp(x,y)

    
def pageSorter(x, y):
    if '-' in x or '-' in y:
        xmod = getModuleName(x)
        xpage = getModulePage(x)
        ymod = getModuleName(y)
        ypage = getModulePage(y)
        if xmod == ymod:
            return modSorter(xpage, ypage)
        else:
            return modSorter(xmod, ymod)
    else:
        return modSorter(x, y)


def clean(line):
    line = line.strip()
    if '\\n' in line:
        line = line.replace('\\n', ' ')
    if '#' in line:
        line = line[:line.find('#')]
    line = line.replace('  ', ' ')
    line = line.upper()
    return line

    
def processPage(config, page):
    inputs = outputs = inouts = []
    expected_in = expected_out = expected_io = 0
    print "Processing page", page, "..."
    signals = config.get(page, 'signals').split()
    expected_in = int(signals[0])
    expected_out = int(signals[1])
    if len(signals) > 2:
        expected_io = int(signals[2])
    else:
        expected_io = 0

    try:
        inline = config.get(page, 'in')
    except ConfigParser.NoOptionError:
        inline = None
    if inline:
        inputs = clean(inline).split()

    try:
        outline = config.get(page, 'out')
    except ConfigParser.NoOptionError:
        outline = None
    if outline:
        outputs = clean(outline).split()

    try:
        ioline = config.get(page, 'inout')
    except ConfigParser.NoOptionError:
        ioline = None
    if ioline:
        inouts = clean(ioline).split()

    num_in = 0
    if inputs:
        num_in = len(inputs)

    num_out = 0
    if outputs:
        num_out = len(outputs)

    num_io = 0
    if inouts:
        num_io = len(inouts)

    if num_in != expected_in:
        print "Error: mismatch on page %s, expected %d inputs, got %d" % (page, expected_in, num_in)
        sys.exit(1)

    if num_out != expected_out:
        print "Error: mismatch on page %s, expected %d outputs, got %d" % (page, expected_out, num_out)
        sys.exit(1)

    if num_io != expected_io:
        print "Error: mismatch on page %s, expected %d outputs, got %d" % (page, expected_out, num_out)
        sys.exit(1)

    if inputs:
        for wire in inputs:
            if wire not in wirelist:
                wirelist[wire] = Signal(wire, sink=page)
            else:
                wirelist[wire].addSink(page)
    if outputs:
        for wire in outputs:
            if wire not in wirelist:
                wirelist[wire] = Signal(wire, src=page)
            else:
                wirelist[wire].addSource(page)
    if inouts:
        for wire in inouts:
            if wire not in wirelist:
                wirelist[wire] = Signal(wire, src=page, sink=page)
            else:
                wirelist[wire].addSink(page)
                wirelist[wire].addSource(page)

    print "Page %s:" % (page), "%d inputs, %d outputs, %d inouts" % (num_in, num_out, num_io)
    return (num_in, num_out, num_io)


def main():
    modules = []
    pages = []
    config = ConfigParser.RawConfigParser()
    config.read(opts.filename)

    total_inputs = total_outputs = total_inouts = 0
    
    try:
        sections = config.sections()
        for section in sections:
            modname = section
            if "-" in section:
                modname = section[:section.find('-')]
            if modname not in modules:
                modules.append(modname)

        modules.sort(modSorter)
        pages = sections
        pages.sort(pageSorter)
        
        for page in pages:
            (nin, nout, nio) = processPage(config, page)
            total_inputs += nin
            total_outputs += nout
            total_inouts += nio

    except ConfigParser.MissingSectionHeaderError:
        print "Error: no sections in file %s!" % (opts.filename)
        sys.exit(1)
    except ConfigParser.NoSectionError:
        print "Error: missing section(s) in file %s!" % (opts.filename)
        sys.exit(1)
    except ConfigParser.ParsingError:
        print "Error parsing file %s!" % (self.filename)
        sys.exit(1)

    print "Wires processed: %d inputs, %d outputs, %d inouts" % (total_inputs, total_outputs, total_inouts)
    wires = wirelist.keys()
    wires.sort()
    
    print "Analysing %d signals..." % (len(wires))
    
    no_src_list = []
    no_sink_list = []
    mult_src_list = []
    
    num_sources = num_sinks = 0
    
    for wire in wires:
        num_sources = wirelist[wire].getNumSourcePages()
        if num_sources == 0:
            no_src_list.append(wire)
        if num_sources > 1:
            mult_src_list.append(wire)
        num_sinks = wirelist[wire].getNumSinkPages()
        if num_sinks == 0:
            no_sink_list.append(wire)

    print "Writing cross-reference..."
    wlistfile = open(XREF_FILENAME, 'w')
    print >>wlistfile, "%-12s%-32s%-64s" % ("Signal", "Source(s)", "Sink(s)")
    print >>wlistfile, "%-12s%-32s%-64s" % ("=" * 8, "=" * 28, "=" * 60)
    for wire in wires:
        print >>wlistfile, wirelist[wire]
    wlistfile.close()

    print "Writing signal error file..."
    errfile = open(ERROR_FILENAME, 'w')
    if len(no_src_list) > 0:
        print "%d signals with no source" % (len(no_src_list))
        print >>errfile, "Signals with no source:"
        print >>errfile, "======================="
        for wire in no_src_list:
            print >>errfile, wirelist[wire]
    if len(no_sink_list) > 0:
        print "%d signals with no sink" % (len(no_sink_list))
        print >>errfile, ""
        print >>errfile, ""
        print >>errfile, ""
        print >>errfile, "Signals with no sink:"
        print >>errfile, "====================="
        for wire in no_sink_list:
            print >>errfile, wirelist[wire]
    if len(mult_src_list) > 0:
        print "%d signals with multiple sources" % (len(mult_src_list))
        print >>errfile, ""
        print >>errfile, ""
        print >>errfile, ""
        print >>errfile, "Signals with multiple sources:"
        print >>errfile, "=============================="
        for wire in mult_src_list:
            print >>errfile, wirelist[wire]
    errfile.close()
    
    print "Writing signal page counts..."
    countfile = open(PAGECOUNT_FILENAME, 'w')
    print >>countfile, "%-12s%-64s" % ("Signal", "Page(Count)...")
    print >>countfile, "%-12s%-64s" % ("=" * 8, "=" * 60)
    for wire in wires:
        print >>countfile, "%-12s%s" % (wirelist[wire].getName(), wirelist[wire].getPageCounts())
    countfile.close()

    dictfilename = DICTIONARY_FILENAME
    if os.path.isfile(dictfilename):
        print "Reading signal dictionary..."
        config = ConfigParser.RawConfigParser()
        config.read(dictfilename)
        try:
            sections = config.sections()
        except ConfigParser.MissingSectionHeaderError:
            print "Error: no sections in file %s!" % (opts.filename)
            sys.exit(1)
        except ConfigParser.NoSectionError:
            print "Error: missing section(s) in file %s!" % (opts.filename)
            sys.exit(1)
        except ConfigParser.ParsingError:
            print "Error parsing file %s!" % (self.filename)
            sys.exit(1)
        for wire in wires:
            if wire in sections:
                try:
                    description = config.get(wire, 'description')
                except ConfigParser.NoOptionError:
                    description = None
                if description:
                    wirelist[wire].setDescription(description)
                try:
                    type = config.get(wire, 'type')
                except ConfigParser.NoOptionError:
                    type = None
                if type:
                    wirelist[wire].setType(type)

    print "Writing signal dictionary..."
    dictfile = open(dictfilename, 'w')
    for wire in wires:
        signal = wirelist[wire]
        name = signal.getName()
        print >>dictfile, "[%s]" % name
        description = signal.getDescription()
        if description:
            print >>dictfile, "description = %s" % description
        else:
            if name.endswith('/') and name[:-1] in wires:
                print >>dictfile, "description = Complement of %s." % name[:-1]
            else:
                print >>dictfile, "description = " 
        type = signal.getType()
        if type:
            print >>dictfile, "type = %s" % type
        else:
            print >>dictfile, "type = "
        print >>dictfile, "sources = %s" % signal.getSourceList()
        print >>dictfile, "sinks = %s" % signal.getSinkList()
        print >>dictfile, "pagecounts = %s" % signal.getPageCounts()
        print >>dictfile
    dictfile.close()

    print "Done."

if __name__ == '__main__':
    wirelist = {}
    opts = getOpts()
    sys.exit(main())
