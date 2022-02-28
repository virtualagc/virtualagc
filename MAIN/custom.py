"""
Goal of the script is to turn the ourput of the yaYUL assembler into
two mif files (one for RAM and one for ROM) with our updated memory map format

argument one: text file for the command line output of the mif file
argument two: the name for the RAM.mif file (probably RAM.mif)
argument three: the name for the ROM.mif file (probably ROM.mif)
"""
import sys
class Formatter:
    #initializes the data structure
    def __init__(self, args):
        #get tag and word arrays
        self.assemblerInput = args[0]
        self.RAM = args[1]
        self.ROM = args[2]
        return

    #format
    def format():
	#open the files
        
        #close the files






main():
    #initialize formatter
    myFormatter = Formatter(sys.args)


if __name__ == "__main__":
    main()
