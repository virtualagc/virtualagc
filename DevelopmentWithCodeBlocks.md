![http://virtualagc.googlecode.com/svn/trunk/Apollo32.png](http://virtualagc.googlecode.com/svn/trunk/Apollo32.png)


|**NOTICE**: Code::Blocks has a problem showing the program counter in the IDE editor during debugging when the extension of the source files is `*.agc`.To get around this problem for now rename all the .agc files to .s and update the new MAIN.s to include the .s sources. After the rename you must recompile to have the symtab include the new source references.|
|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

# 1. Development with Code::Blocks #

The intent of this section is to guide you through the setup steps for developing and debugging AGC/AEA applications like Colossus,Artemis,Luminary,FP6 or your own application with the integrated develpoment environment Code::Blocks. This IDE (based on wxWidgets) is a cross platform development environment with a graphical debugger.

## 1.1 Software Requirements ##
You need the following software and files to develop and debug AGC/AEA applications:
  * A binary install of Virtual AGC (May 2009 or later)
  * Code::Blocks 8.02
  * AGC/AEA lexer files for source highlighting (See SVN Contributed).

This tutorial assumes you have a properly working Virtual AGC setup (i.e. you can run yaAGC and interact with it using the virtual DSKY) and have Code::Blocks installed for your specific platform.

## 1.2 Configuring Code::Blocks ##

To work with the AGC/AEA sources and development tools in Code:;Blocks one must:
  * Setup AGC/AEA Syntax Highlighting
  * Configure the AGC Toolchain for AGC development
  * Configure the AEA Toolchain for AEA development
  * Configure the pheriperal devices (e.g. yaDSKY2, yaACA3)

### 1.2.1 Configure Syntax Highlighting ###
Code::Blocks uses Scintilla source editing and so uses the Scintilla methods for enabling syntax highlighting capabilities. To create a real AGC/AEA lexer would require patching the Code::Blocks lexer from Scintella to make it aware of the new lexer capabilities. Since this is not desireable the approach taken here is to reuse and existing lexer and only configure the lexer with a configuration file. The lexer configuration files provided as part of Virtual AGC for AGC/AEA are using the Makefile lexer. These files can be found in virtualagc/Contributed/SyntaxHighlight/CodeBlocks/lexer.

To install the lexer configuration files just copy the .xml and .sample files for both the AGC and AEA to the lexer folder of Code::Blocks (e.g. /usr/share/codeblocks/lexer).

Besides getting syntax highlighting this will enable Comment folding as well as enable source file filtering for AGC/AEA files in file selection dialogs.

To verify the proper installation start the Code::Blocks IDE and launch the Configure Editor dialog from the Settings menu (i.e. Option Editor...). In the diaglog select the Syntax highlighting section and subsequently select either AGC Assembly or AEA Assembly in the `Syntax highligthing for` field. A correct configuration will show sample code for either AEA or AGC with syntax highlighting. In addtition to verifying the installation you can also customize the colors to your liking.


### 1.2.2 Configure the AGC Toolchain ###
To work with the AGC tools one must setup and configure the AGC toolchain. From the Settings menu select the  "Compiler and debugger..." option. This will launch the Compiler and debugger settings dialog.

In the Global compiler section select the GNU GCC Compiler to be used as the basis for our new compiler definition. Use the Copy button to create the AGC yaYUL Assembler definition. One could try a different compiler definition as a basis but this tutorial assumes you used the GNU GCC. Ensure that no flags are enabled on the Compiler Flags tab before to specify the tools in the Toolchain executables tab.

For the Toolchain executables do the following:
  1. Specify the directory of the Virtual AGC binary distribution which contains the bin directory as your Compiler's installation directory. If you get the invalid compiler during a build then probably this directory doesn't point to the correct location.
  1. Set the Compiler and Linker fields (i.e. 4 fields) to yaYUL.exe or yaYUL based on your platform.
  1. Set the Debugger to yaAGC.exe or yaAGC depending on your platform.
  1. Leave the resource compiler set to its default value
  1. Set the specific Make program which you use for your makefiles. If your make tool is not in the search path then add the location of the make utility in the Additional Paths tab. Under MinGW you probably want to specify mingw32-make.exe instead of the default make.

To finalize the AGC Toolchain settings switch to the section Debugger settings and make sure that only the Do **not** run the debugee is checked (and optionally the box Display debugger's log).

### 1.2.3 Configure the AEA Toolchain ###
Not yet specified because yaAGS and yaLEMAP still need to be converted to handle gdb and gcc parameters.

### 1.2.4 Adding Apollo Peripherals ###
The Code::Blocks IDE allows you to integrate the launching of user defined tools. This is a convenient location to configure the launching of a Lunar Module DSKY or Lunar Module DEDA.

To add these tools select the Configure Tools option from the Tools menu:
  1. Press the Add button to create a new user tool
  1. Specify the name (e.g. Lunar Module DSKY)
  1. Specify the executable yaDSKY2.exe (use a fullpath to the executable)
  1. Specify the tool options (e.g. --half-size --port=19797)
  1. Set the Working directory to the Virtual AGC Resources directory
  1. Set the radio button launching option to tool visible detached

To launch the user tool make sure you start with a running AGC or AEA. Continue adding the DEDA as well as the ACA (The ACA you may want to launch from a console if you use ACA3).If you experience connection issue with the AGC or EAE try varying the base port.

## 1.3 Working on a Project ##
When you work on a AGC project you need to define in Code::Blocks the project space, which sources are part of the project and what tool chain is used. The steps below help you to accomplish these steps.

### 1.3.1 Setting up a Project ###
This section of the tutorial uses Luminary131 as an example. Obviously when you have your own application you can adjust and customize the values to your liking.

Select from the File menu the option New/Project and select the Empty project Wizard.
  1. Provide the Project Title (e.g. Luminary131)
  1. Specify the location of where the Luminary131 project should be created
  1. Leave the Project filename untouched
  1. Verify the Resulting filename field
  1. Press the Next button.

Specify the compiler tool and which configuration to enable for your project:
  1. Select the AGC yaYUL Assembler
  1. Enable the Debug configuration
  1. Clear both the Output dir as well as the Objects dir field.
  1. Press the Finish button.

### 1.3.2 Configure file categories and extensions ###
First configure the new assembly extension .agc and .aea before associating these extensions with the internal Code::Blocks editor.
Right-click on your project (e.g. Luminary131) and navigate to the _Project Tree_ option. On the sub-menu select the option _'Edit file types and categories...'_. This brings up a category window. Select the _'ASM Sources'_ category and add the '.agc' and '.aea' extensions.

Next configure which editor can open these new extensions: From the main menu select the _'Settings'_ menu and pick the _'Environment'_ option. In the dialog's left pane select the _'Files extension handling'_ section. Then add the '.agc' and '.aea' and specify that these extensions shall be opened with the Code::Blocks editor. Notice that you maybe required to add the star wildcard in front of the period of the extension.

### 1.3.3 Adding Sources to a Project ###
Add the Sources:
  1. In the Projects pane Right click on the Luminary131 project
  1. Select the Add Files option from the Popup Menu
  1. Specify for Files of type the AGC/AEA Assembly files
  1. Select all assembly files (i.e. .agc)
  1. Press the Open button.

Now the appropriate sources are part of your project and can be opened in the editor by just double clicking the respective assembly file. If you try you will notice the syntax highlighting as well as the comment folding in the editor pane.

### 1.3.4 Project Properties ###

To allow the IDE to compile and debug the code some of the Project Properties must be changed:
  1. In the Projects pane Right click on the Luminary131 project
  1. Select the Properties option from the Popup Menu
  1. In the Project settings tab specify your Makefile (e.g. Makefile.Luminary)
  1. Check the this is a custom Makefile checkbox.
  1. Leave the Object names generation unchecked.

The content of the Makefile (e.g. Makefile.Luminary) should look like the following:
```
Debug:
	yaYUL MAIN.agc > Luminary131.lst
	mv MAIN.agc.bin Luminary131.bin
	mv MAIN.agc.symtab Luminary131.symtab

cleanDebug:
	rm Luminary131.lst Luminary131.bin Luminary131.symtab
```

On the Build targets tab make sure the following are set for the Debug target:
  1. Set Platforms to All
  1. Set Type to GUI application (yes this matters for the IDE)
  1. Set Output filename to Luminary131.bin
  1. Uncheck both the Auto-generate prefix and extension check boxes.
  1. Set the execution dir to . (i.e. the directory of the sources)

Once these steps are completed you should be able to build and clean the target files. To try use the Ctrl-F9 or select from the Build menu the option Build. You should get two warnings when building Luminary131. Check the Build Messages to see these warnings and double click to jump to the specific location in the assembly source file where the warning occured.

Now you are in principal ready to start debugging. If you don't have any breakpoints set it is adviseable to just use the Step-into Debug option (or the equivalent button) on the Debug menu to start debugging. Step into at least twice to ensure that you see the current pointer point to the location in the assembly code of where the current inner stack frame is ready to execute next.

## 1.4 Debugging Exercises ##

This section is intended only to show some capabilites of the GDBM/MI console interpreter being used within Code::Blocks.

  * Start Code::Blocks and load the Luminary131 project if you have not already done so
  * Ensure the Luminary131 build is up to date
  * Start bebugging by twice executing the Step-into function of the Debugger (notice the change in pane layout)
  * From the Debug menu goto the Debug windows option and enable the CPU Registers,Call Stack and Running threads windows. You can either dock them all in the main window or leave them floating.
  * Now continue single stepping (i.e. press F7) for some time and examine the CPU registers and Call Stack as you go.
  * Open the File INTERRUPT\_LEAD\_INS.s and set a breakpoint at line 35 (i.e. T3RUPT)
  * Now select Continue (i.e. Ctrl-F7)
  * The system will halt execution when the TIMER3 interrupt occurs.
  * Examing the Running threads window
  * As you single step the T3RUPT handler watch the CPU register values.
  * In the Call Stack window double click the visible stack frames to jump to the line of code from where the jump was made to the next stack frame.
  * Continue single stepping.
  * Open the Watches window
  * Add some watches (either right click on a variable or use the Debug Edit Watches option).
  * Keep single stepping.
  * Open the Examine memory window
  * Specify an address (either hexadecimal,decimal, octal or a banked address ) to start dumping from (e.g. 0x6c or 0154 or E0,0154).
  * Send a console debug command to the debugger by selecting option Send user command to debugger (e.g. next 500)

After these steps you can start examining and learning the full AGC software and extend your capabilities in Code::Blocks. Also not that if the debugger Stop function is not working that you should just kill the yaAGC process. No need to bring down the complete debug environment.