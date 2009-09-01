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
    - Set tab width and indent width both to 8 (Unix). 
      On Windows, it seems these need to be set to 7. I don't know why 
      this is necessary, but setting to 8 does not display the 
      source indentation correctly. 
    - Unselect "Soft (emulated with spaces) tabs"
    - Specify "File name glob" as "*.{agc}"
    - Repeat for "assembly-ags", and exit the options panel.


