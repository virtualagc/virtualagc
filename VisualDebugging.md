![http://virtualagc.googlecode.com/svn/trunk/Apollo32.png](http://virtualagc.googlecode.com/svn/trunk/Apollo32.png)
# Visual Debugging the AGC and AGS #

> | **NOTE:** This page does not yet provide fully for integration with the so-called **VirtualAGC** GUI front-end.  We'll have that info as soon as it's available!  For now, the non-integrated approach described below provides some guidance. |
|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

One of the goals of this project is to fully enable the emulator to exhibit the GDB/MI behavior. Initially the focus will be on making the AGC behave like a gdb in debug mode by supporting the basic command line interface of the gdb. This capability will enable running the AGC and AGS under Graphical front-ends that can interact with the gdb. So far three environments have been successfully used to visually debug the AGC:

  * [Code::Blocks](http://www.codeblocks.org/) (Open Source IDE running on Linux, Windows and Mac OS)
  * [KDbg](http://www.kdbg.org/) (A KDE Graphical debugger)
  * [Emacs](http://www.gnu.org/software/emacs/) (GUB based debugging)

Supporting documentation for each of these Front-ends will be provided on a separate distinct Wiki page for each supporting IDE explaining how to setup the environment to use the respective IDE with the Virtual AGC tools. Over time the tool set will be made compatible with the gcc and gdb tool-set where possible to allow for seamless integrations with these third party tools. The following additional documentation exist:

  * [Development with Code Blocks](http://code.google.com/p/virtualagc/wiki/DevelopmentWithCodeBlocks)

Of course you don't need a debug front-end you can also just launch yaAGC in in debug mode and interact with the AGC using gdb command line options. Type help all for all supported commands and for detailed documentation refer to the [GDB Documentation](http://www.gnu.org/software/gdb/documentation/).

To actually debug the Luminary131 or Colossus249 code you must get a working copy of the source tree and build your own core-ropes image to load into the emulator. To verify you have correctly compiled the original AGC code you run the following from the command line:

```
  yaAGC --fullname Colossus249.bin
```

If you downloaded a binary distribution and did not compile the AGC sources your self (e.g. Colossus249) then you can use the option --directory=DIR to specify the location of the respective AGC code.

Below is an example of Luminary131 being debugged in the IDE Code::Blocks. Notice that the interrupts are showing up as separate threads in the debugger (with symbolic reference to the source of the interrupt in this case TIMER4). This example also shows the AGC syntax highlighting.
> ![http://virtualagc.googlecode.com/svn/trunk/doc/images/CodeBlocks.png](http://virtualagc.googlecode.com/svn/trunk/doc/images/CodeBlocks.png)