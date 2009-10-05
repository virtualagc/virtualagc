These files add syntax highlighting for AGC and AGS assembly languages to 
the jEdit programmers editor (http://www.jedit.org). 

To install:

 1. Copy the xml files to the modes directory of your jEdit installation, 
    e.g. on Unix: /usr/local/share/jedit/modes, or 
    on Windows: C:\Program Files\jEdit\modes
    
 2. Paste the following into the catalog file in the same modes 
    directory in the jEdit installation area as above:

-----------------------------CUT HERE-----------------------------------
<MODE NAME="assembly-agc"	FILE="assembly-agc.xml"
				FILE_NAME_GLOB="*.agc" />

<MODE NAME="assembly-ags"	FILE="assembly-ags.xml"
				FILE_NAME_GLOB="*.aea" />

-----------------------------CUT HERE-----------------------------------

 3. Reload jEdit modes if jEdit is already running:
      Utilities -> Troubleshooting -> Reload Edit Modes
 
 4. Change your jEdit settings for these modes: 
    - Utilities -> Global Options
    - Select "Editing" section
    - For "Change settings for mode:", select "assembly-agc" from the dropdown. 
    - Unselect "Use default settings"
    - Set tab width and indent width both to 8. 
    - Make sure that Fractional Font Metrics are disabled (this causes 
      incorrect display of hard tabs). To do this go to 
      Utilities -> Global Options -> Text Area, 
      unselect Fractional font metrics, and press OK.
    - Unselect "Soft (emulated with spaces) tabs"
    - Specify "File name glob" as "*.{agc}"
    - Repeat for "assembly-ags", and exit the options panel.


Other suggestions:
    - When transcribing AGC source from page scans, it can be useful to 
      have vertical line-guides at specific columns. This can be done by
      installing the jEdit LineGuides plugin. It doesn't have a fantastic 
      user interface (OK, it doesn't have any). You'll have to edit its
      settings manually. Within jEdit go to 
      Utilities -. Settings Directory -> More -> properties
      Add a line like the following anywhere in the file (if it already exists, 
      modify to suit):
	lineguides.default-set=\#c0c0ff|8,\#8080ff|16,\#c0c0ff|24,\#c0c0ff|32,\#8080ff|40
      This sets vertical rulers at columns 8 (end of label), 16 (start of opcode), 
      24 (start of operand), 32 and 40 (start of comment). 

      To turn on LineGuides, select Plugins -> H-O -> Line Guides
      
