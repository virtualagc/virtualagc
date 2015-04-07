![http://virtualagc.googlecode.com/svn/trunk/Apollo32.png](http://virtualagc.googlecode.com/svn/trunk/Apollo32.png)
# 1 Syntax Highlighting AGC/AEA Assembly #
In order to enhance the readability of the AGC and AEA assembler code several syntax highlighting options are available for a select set of tools. These syntax highlighting definition files will attempt to highlight comments, assembler instructions and YUL/LEMAP directives differently from normal text to allow easy recognition of the AGC/AEA specifics as well as the YUL/LEMAP assembler directives. If you are familiar with the list of supported editors below then most likely you do not need additional guidance on how to install the highlight definition files (located in the yaSyntax directory) for your preferred tool. However if you need additional help you can access the "EnableSyntaxAGC" document (Open Office format).

## 1.1 Supported Editors ##
The following list of editors is currently supported:
  * [Code::Blocks](http://www.codeblocks.org/)
  * [Eclipse](http://www.eclipse.org/)
  * [Kate](http://kate-editor.org/)
  * [Textpad](http://www.textpad.com/)
  * [Vim](http://www.vim.org/)
  * [Programmer's Notepad](http://www.pnotepad.org/)
  * [jEdit](http://www.jedit.org/)

The syntax files for each of these editors can be found in the SVN source tree in [Contributed/SyntaxHighlight](http://code.google.com/p/virtualagc/source/browse/#svn/trunk/Contributed/SyntaxHighlight) folder.

## 1.2 Syntax Colours ##
The syntax related colours vary from editor to editor and are in many cases based on user or default preferences. However as a general guideline to aid you in reading and to teach AGC or AEA assembler one can distinguish the following code categories that in most cases will have a different colour for each of the supported editors.

  * Comments (e.g. # Some Comment )
  * AGC Instruction Set (e.g. CAF, BZF )
  * YUL Pseudo Codes (BANK, BLOCK, COUNT)
  * AGC Interpreted Instruction Codes (e.g. STORE, STCALL, COS)
  * Symbols and Labels

Not only are the Interpreted instructions in a different colour they are also enclosed in a combination (assuming no jumps are made out of the code block) of TC INTERPRET and EXIT.

## 1.3 Beyond Editors ##
Besides the syntax highlighting in editors you can also see full browsable code listings on the VirtualAGC project site using the syntax colour scheme (e.g. [FRESH\_START\_AND\_RESTART.agc](http://www.ibiblio.org/apollo/listings/Luminary099/FRESH_START_AND_RESTART.agc.html)) as well as in the SVN source browser of GoogleCode using the google-code-prettify engine (e.g. [FRESH\_START\_AND\_RESTART.agc](http://code.google.com/p/virtualagc/source/browse/trunk/Luminary099/FRESH_START_AND_RESTART.agc)).