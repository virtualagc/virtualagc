#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   asciiToEbcdic.py
Purpose:    A table for converting ASCII characters to EBCDIC.  Only
            printable characters are converted
Requires:   Python 3.6 or later.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-04-27 RSB  Began
            2024-05-02 RSB  Added standalone mode for interconverting *.xpl, 
                            *.bal, and *.hal files among the encodings 
                            ASCII, UTF-8, and EBCDIC. 

I had perfectly satisfactorily (I thought!) been using the string method
`encode` for this conversion, a la
    ebcdicBytearray = asciiString.encode("cp1140");
However, there are boundary cases that don't work -- the ASCII character '~'
is one I know about -- that get translated wrong, at least for my purposes.
(I want it to be translated to 0x5F, "logical NOT", but it gets translated to
0xA1.)  Rather than trapping these individual cases as I discover them, it 
seems easier to me to just use the `asciiToEbcdic` conversion table from my
runtimeC.c file.  At least, I'm guaranteed that the compiler is doing the same
thing as the runtime.
'''

# Make sure these tables remains identical to the tables of the same names in 
# runtimeC.c!

asciiToEbcdic = [
  0x00, 0x01, 0x02, 0x03, 0x37, 0x2d, 0x2e, 0x2f,
  0x16, 0x05, 0x25, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
  0x10, 0x11, 0x12, 0x13, 0x3c, 0x3d, 0x32, 0x26, #              */
  0x18, 0x19, 0x3f, 0x27, 0x1c, 0x1d, 0x1e, 0x1f, #              */
  0x40, 0x5A, 0x7F, 0x7B, 0x5B, 0x6C, 0x50, 0x7D, #  !"#$%&'     */
  0x4D, 0x5D, 0x5C, 0x4E, 0x6B, 0x60, 0x4B, 0x61, # ()*+,-./     */
  0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, # 01234567     */
  0xF8, 0xF9, 0x7A, 0x5E, 0x4C, 0x7E, 0x6E, 0x6F, # 89:;<=>?     */
  0x7C, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, # @ABCDEFG     */
  0xC8, 0xC9, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, # HIJKLMNO     */
  0xD7, 0xD8, 0xD9, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, # PQRSTUVW     */
  0xE7, 0xE8, 0xE9, 0xBA, 0xFE, 0xBB, 0x5F, 0x6D, # XYZ[\]^_     */
  0x4A, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, # `abcdefg     */
  0x88, 0x89, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, # hijklmno     */
  0x97, 0x98, 0x99, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, # pqrstuvw     */
  0xA7, 0xA8, 0xA9, 0xC0, 0x4F, 0xD0, 0x5F, 0x07  # xyz{|}~      */
]

ebcdicToAscii = [
  '\x00', '\x01', '\x02', '\x03', ' '   , '\x09', ' '   , '\x7F',
  ' '   , ' '   , ' '   , '\x0B', '\x0C', '\x0D', '\x0E', '\x0F',
  '\x10', '\x11', '\x12', '\x13', ' '   , ' '   , '\x08', ' '   ,
  '\x18', '\x19', ' '   , ' '   , '\x1C', '\x1D', '\x1E', '\x1F',
  ' '   , ' '   , ' '   , ' '   , ' '   , '\x0A', '\x17', '\x1B',
  ' '   , ' '   , ' '   , ' '   , ' '   , '\x05', '\x06', '\x07',
  ' '   , ' '   , '\x16', ' '   , ' '   , ' '   , ' '   , '\x04',
  ' '   , ' '   , ' '   , ' '   , '\x14', '\x15', ' '   , '\x1A',
  ' '   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , ' '   , '`'   , '.'   , '<'   , '('   , '+'   , '|'   ,
  '&'   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , ' '   , '!'   , '$'   , '*'   , ')'   , ';'   , '~'   ,
  '-'   , '/'   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , ' '   , ' '   , ','   , '%'   , '_'   , '>'   , '?'   ,
  ' '   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , ' '   , ':'   , '#'   , '@'   , '\''  , '='   , '"'   ,
  ' '   , 'a'   , 'b'   , 'c'   , 'd'   , 'e'   , 'f'   , 'g'   ,
  'h'   , 'i'   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , 'j'   , 'k'   , 'l'   , 'm'   , 'n'   , 'o'   , 'p'   ,
  'q'   , 'r'   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , ' '   , 's'   , 't'   , 'u'   , 'v'   , 'w'   , 'x'   ,
  'y'   , 'z'   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , ' '   , '['   , ']'   , ' '   , ' '   , ' '   , ' '   ,
  '{'   , 'A'   , 'B'   , 'C'   , 'D'   , 'E'   , 'F'   , 'G'   ,
  'H'   , 'I'   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  '}'   , 'J'   , 'K'   , 'L'   , 'M'   , 'N'   , 'O'   , 'P'   ,
  'Q'   , 'R'   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  ' '   , ' '   , 'S'   , 'T'   , 'U'   , 'V'   , 'W'   , 'X'   ,
  'Y'   , 'Z'   , ' '   , ' '   , ' '   , ' '   , ' '   , ' '   ,
  '0'   , '1'   , '2'   , '3'   , '4'   , '5'   , '6'   , '7'   ,
  '8'   , '9'   , ' '   , ' '   , ' '   , ' '   , '\\'  , ' '
]

#----------------------------------------------------------------------------
# The stuff below is executed only if this file is run as a program, and is
# not executed when the file is imported as a module. 

if __name__ == "__main__":
    
    import sys
    import os
    from glob import glob
        
    folder = "../EBCDIC" # The output folder
    remove = False       # Remove Virtual AGC comments?
    target = "EBCDIC"
    source = "ASCII"
    legal = ["EBCDIC", "ASCII", "UTF-8"]
    file = None
    columns = None
    
    # Convert a single file.
    aborted = []
    def convert(filename, to=None):
        global aborted
        print("Converting " + filename)
        try:
            inf = open(filename, "rb")
            ba = bytearray(inf.read())
            inf.close()
        except:
            print("Could not read the file")
            aborted.append(filename)
            return
        # Step 0:  Remove all carriage-return characters.
        i = 0
        while i < len(ba):
            if ba[i] == ord('\r'):
                del ba[i]
            else:
                i = i + 1
        # First, convert to internal representation: ASCII with logical NOT and
        # U.S. cent converted to ~ and ` respectively.
        errorCount = 0
        adjustment = 0
        if source == "ASCII":
            i = 0
            while i < len(ba):
                b = ba[i]
                if b == 0:
                    print("NUL byte at 0x%X replaced by a space" % (i + adjustment))
                    ba[i] = 0x20
                elif b == ord('^'):
                    ba[i] = ord('~')
                elif b > 127:
                    print("Byte %02X found at offset 0x%X is not legal ASCII" % \
                          (b, i + adjustment))
                    errorCount += 1
                i += 1
        elif source == "UTF-8":
            i = 0
            while i < len(ba):
                b = ba[i]
                ip1 = i + 1
                if b == 0:
                    print("NUL byte at 0x%X replaced by a space" % (i + adjustment))
                    ba[i] = 0x20
                elif b == ord('^'):
                    ba[i] = ord('~')
                if b > 127:
                    if b != 0xC2 or ip1 >= len(ba) or ba[ip1] not in [0xAC, 0xA2]:
                        print("Not a supported UTF-8 character at offset 0x%s" % \
                              i + adjustment)
                        print("Only logical-NOT (0xC2 0xAC) and U.S. cent (0xC2 0xA2)")
                        print("are supported.")
                        aborted.append(filename)
                        return
                    if ba[ip1] == 0xAC:
                        ba[i] = ord('~')
                    else: 
                        ba[i] = ord('`')
                    del ba[ip1]
                    adjustment += 1
                i += 1
        elif source == "EBCDIC":
            for i in range(len(ba)):
                ba[i] = ord(ebcdicToAscii[ba[i]])
        if errorCount > 1:
            print("%d error(s) were encountered.  Aborting %s." % \
                  (errorCount, filename))
            aborted.append(filename)
            return
        # Now remove "modern" comments if requested.  Headers for *.hal are
        # presently undetermined, and thus not yet supported.
        if remove:
            wasHeader = False
            if len(ba) >= 6 and ba[0] == ord(' ') and ba[1] == ord('/') and \
                    ba[2] == ord('*') and ba[3] == ord('@'):
                # This is the kind of header expected for *.xpl files.
                wasHeader = True
                found = False
                for i in range(5, len(ba)):
                    if found:
                        if ba[i] in [ord(' '), ord('\r')]:
                            continue
                        elif ba[i] == ord('\n'):
                            i += 1
                            break
                        break
                    elif ba[i] == ord('/') and ba[i-1] == ord('*'):
                        found = True
                # At this point, i points to the next character after the 
                # header.
                ba = ba[i:]
            elif len(ba) >= 2 and \
                    ba[0] == ord('*') and ba[1] == ord('/'):
                # This is the kind of header expected for *.bal files.
                wasHeader = True
                while len(ba) >= 2 and \
                        ba[0] == ord('*') and ba[1] == ord('/'):
                    for i in range(3, len(ba)):
                        if ba[i] == ord('\n'):
                            i += 1
                            break
                    ba = ba[i:]
            if wasHeader:
                # Check for blank line after header
                for i in range(len(ba)):
                    if ba[i] in [ord(' '), ord('\r')]:
                        continue
                    if ba[i] == ord('\n'):
                        ba = ba[i + 1:]
                        break
                    break

        # Now recode.
        if target == "ASCII":
            pass # Already correct, no changes needed.
        elif target == "UTF-8":
            i = 0
            while i < len(ba):
                b = ba[i]
                ip1 = i + 1
                if b in [ord('~'), ord('`')]:
                    ba[i] = 0xC2
                    if b == ord('~'):
                        ba.insert(ip1, 0xAC)
                    elif b == ord('`'):
                        ba.insert(ip1, 0xA2)
                    i = ip1
                i += 1
        elif target == "EBCDIC":
            for i in range(len(ba)):
                ba[i] = asciiToEbcdic[ba[i]]
        # Add newlines after every fixed number of columns.
        if columns != None and target == "ASCII":
            i = columns
            while (i < len(ba)):
                ba.insert(i, 0x0A)
                i += columns + 1
        # Save it:
        if to != None:
            if to == sys.stdout:
                to.buffer.write(ba)
            else:
                to.write(ba)
            to.close()
            return
        try:
            nfilename = folder + "/" + filename
            os.makedirs(os.path.dirname(nfilename), exist_ok=True)
            outf = open(nfilename, "wb")
            outf.write(ba)
            outf.close()
        except:
            print("Failed to write output file")
            aborted.append(filename)
            return
    
    for parm in sys.argv[1:]:
        if parm == "--":
            break
        elif parm.startswith("--folder="):
            folder = parm[9:]
            if not folder.startswith("/") and not folder.startswith("../"):
                print("Do not use a subfolder of the current working folder")
                sys.exit(1)
            
        elif parm == "--remove":
            remove = True
        elif parm.startswith("--target="):
            target = parm[9:]
            if target not in legal:
                print("Not an allowed target")
                sys.exit(1)
            folder = "../" + target
        elif parm.startswith("--source="):
            source = parm[9:]
            if source not in legal:
                print("Not an allowed source")
                sys.exit(1)
        elif parm.startswith("--file="):
            file = parm[7:]
        elif parm.startswith("--columns="):
            columns = int(parm[10:])
        elif parm == "--help":
            print("Recursively convert ASCII, UTF-8, or EBCDIC files with")
            print("names of the form *.xpl, *.hal, or *.bal in the current")
            print("folder to ASCII, UTF-8, or EBCDIC, storing them in a new")
            print("folder.  Optionally remove \"modern\" program comments")
            print("added by the Virtual AGC Project.")
            print()
            print("IMPORTANT: These conversions are specific to character")
            print("substitutions present in space-shuttle related software")
            print("presented by the Virtual AGC Project.  *Not* suitable for")
            print("general purposes!")
            print()
            print("Usage:")
            print("\tasciiToEbcdic [OPTIONS]")
            print()
            print("The allowed [OPTIONS] are:")
            print("    --source=T   (Default \"ASCII\".) Specify the encoding")
            print("                 of the input file.  The choices are")
            print("                 \"ASCII\", \"UTF-8\", or \"EBCDIC\".")
            print("    --target=T   (Default \"EBCDIC\".) Specify the encoding")
            print("                 of the otuput file.  The choices are")
            print("                 \"ASCII\", \"UTF-8\", or \"EBCDIC\".")
            print("    --folder=F   (Default is \"../\" plus the target output")
            print("                 type. See --target.)  F is the pathname")
            print("                 of the desired output folder.  Must start")
            print("                 with either \"/\" or \"../\".")
            print("                 NOTE: --target overrides this option, so")
            print("                 make sure it *follows* --target on the")
            print("                 command line.")
            print("    --remove     Removes file headers added by the Virtual")
            print("                 AGC Project.  By default, these kept.")
            print("    --file=F     The requests conversion of a single file")
            print("                 rather than an entire folder.  If the")
            print("                 target encoding is ASCII or UTF-8, then")
            print("                 output is to stdout.  Otherwise, the output")
            print("                 is to a file of the same name, but")
            print("                 suffixed by \".ebcdic\".")
            print("    --columns=N  Inserts a newline after every Nth column.")
            print("                 The default is to make no such insertions.")
            print("                 Only for --target=ASCII.")
            sys.exit(0)
        else:
            print("Unrecognized command-line parameter.  Use --help for help.")
            sys.exit(1)
            
    if file != None:
        if target == "EBCDIC":
            convert(file, to=open(file+".ebcdic", "wb"))
        else:
            convert(file, to=sys.stdout)
        sys.exit(0)
    try:
        outf = os.makedirs(folder)
    except:
        print("The output folder %s already exists. Remove it first." % folder)
        print("Aborting ...")
        sys.exit(1)
    
    for filename in glob('**/*.xpl', recursive=True):
        convert(filename)
    for filename in glob('**/*.hal', recursive=True):
        convert(filename)
    for filename in glob('**/*.bal', recursive=True):
        convert(filename)

    if len(aborted) == 0:
        print("Success!")
    else:
        print("The following files failed and were aborted:")
        for filename in aborted:
            print("\t" + filename)