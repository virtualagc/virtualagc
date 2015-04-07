![http://www.ibiblio.org/apollo/ApolloPatch2.jpg](http://www.ibiblio.org/apollo/ApolloPatch2.jpg)
# Virtual AGC and AGS #

The purpose of this project is to provide an emulation of the on-board Apollo guidance computers, along with some ancillary items needed to make the emulation do something interesting. "AGC" stands for Apollo Guidance Computer.  The AGC was the principal on-board computer for NASA's Apollo missions, including all of the lunar landings.  Both the Command Module (CM) and the Lunar Module (LM) had AGCs, so two AGCs were used on most of the Apollo missions, but with differing software.   The computer and its software were developed at MIT's Instrumentation Laboratory, also known as Draper Labs.

"AGS" stands for Abort Guidance System, of which the computer portion was the Abort Electronics Assembly (AEA).  The AEA was a completely separate computer system from the AGC, with a different architecture, different instruction-set, and different runtime software.  It was in the LM as a kind of backup for the AGC, but was only supposed to be used (as the name implies) in case of an aborted landing.

Special thanks go to Ron Burkey for starting this magnificent project and for bringing the wonders of the Apollo era with regards to computing back to life. The purpose of this project is to continue the project by adding new capabilities like GDB/MI functions to allow debugging in gdb capable IDE's.
