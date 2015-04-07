![http://virtualagc.googlecode.com/svn/trunk/Apollo32.png](http://virtualagc.googlecode.com/svn/trunk/Apollo32.png)
# 1. DSKY Basics #
The DSKY is the "display/keyboard" used by the Apollo Guidance Computer (AGC).  The DSKY provided only a means to input keyboard data to the AGC, or to display visual information at command of the AGC, and therefore had little or no functionality of its own, when considered as a stand-alone device. The DSKY was used in both the Command Module and the Lunar Module.

> ![http://virtualagc.googlecode.com/svn/trunk/doc/images/DSKY.png](http://virtualagc.googlecode.com/svn/trunk/doc/images/DSKY.png)

## 1.1 Interacting with DSKY ##
The DSKY design used a pretty simple but smart interface to allow the user to interact with the AGC. A method of verbs and nouns were used to request an operation (i.e. the verb) and on what (i.e. noun) you wanted this operation to execute on. Each distinct verb was assigned a number and each noun was assigned a number. For example the verb "display" was assigned the number 16 and noun 36 was assigned to "ground elapsed time (GET)". So to display the current GET you would press "V" followed by the number 16 and then "N" followed by the numbers 36 thereafter executed when pressing Entr key. A shorthand notation in check lists was used to express the above sequence: V16N36E. In some cases just a simple verb was sufficient to execute a certain command.

Similarly if the AGC required the user to input certain values or ask to confirm (i.e the Pro(ceed) key ) it would display a flashing verb/noun combination to indicate that user input is requested.

To display output in response to a request or when punching input in the DSKY the registers [R1](https://code.google.com/p/virtualagc/source/detail?r=1) (top row), [R2](https://code.google.com/p/virtualagc/source/detail?r=2) (middle row) and [R3](https://code.google.com/p/virtualagc/source/detail?r=3) (bottom row) were used.

To show which program was running the right top 2 digits were used. Programs were applications that executed a specific task. For example program 64 (P64) was the high gate approach program where as P66 was the final landing phase program and P68 the post landing shutdown program to prevent inadvertent RCS firing. A program was typically started with the verb 37 followed by the program number. To start program 66 one would enter: V37E66E Notice that after V37E the DSKY starts flashing the Code 37 to ask the crew for the program input.

When entering numbers it was assumed that octal numbers where used unless the user would use the sign +/- symbol; in that case decimal numbers were assumed. Also when using decimal numbers leading zeros must be entered this is not the case for octal numbers. When input is requested in [R1](https://code.google.com/p/virtualagc/source/detail?r=1) the row for [R1](https://code.google.com/p/virtualagc/source/detail?r=1) would clear and the user can provide its input. To correct the input press the CLR key before pressing Entr.

## 1.2 Status Indicators ##
Also part of the DSKY are the status indicator lights. These are illuminated to indicate warnings or caution. The following is a list of the indicator lights with an explanation of when the light is illuminated.
  * UPLINK ACTY: Received a complete 16-bit digital uplink message
  * NO ATT: Inertial Subsystem is in coarse align
  * STBY: When AGC is in standby mode to preserve power
  * KEY REL: Crew pressing keys or Input requested (except PRO,RSET and ENTR)
  * OPR ERR: Incorrect sequence of keys pressed
  * TEMP: Inertial Subsystem temperature outside of nominal values
  * GIMBAL LOCK: Middle gimbal exceeds +/-70 degrees
  * PROG: Computational difficulty detected
  * RESTART: Temporary Hardware or Software failure detected (Reset)
  * TRACKER: Issue with the OCDU or rendezvous radar

## 1.3 Keyboard ##
The keyboard exist of a set of numerical buttons,sign buttons and command buttons. The numerical buttons aren't further explained since their purpose is just to enter digits. The sign buttons although straight forward immediately flag the AGC that a decimal number is being entered. The remaining set of Keys is enumerated below with a brief explanation.
  * VERB: Interpret the next 2 numerical as verb code
  * NOUN: Interpret the next 2 numerical as noun code
  * CLR: Clear the data display (1st the active, successive presses clears the other 2)
  * PRO: Proceed with entered data or go standby if power down program is started
  * KEY REL: Allow AGC to display data if you were entering data
  * ENTR: Requested Data Entered and start Execution
  * RSET: Extinguishes the illuminated caution indicators

Here is a short video demonstrating the lamp test followed by starting the idle program.

> <a href='http://www.youtube.com/watch?feature=player_embedded&v=PF-9SyWM1Mw' target='_blank'><img src='http://img.youtube.com/vi/PF-9SyWM1Mw/0.jpg' width='425' height=344 /></a>

In this demonstration you can see that VERB 35 is already displayed but the enter key has not been pressed yet. After the lamp test the idle program is started with V37E00E.

## 1.4 Some Basic Commands ##
The following is a list of some basic commands to demonstrate the interaction with the DSKY.

| **Verb Noun** | **Description**                                                     |
|:--------------|:--------------------------------------------------------------------|
| V35E        | Execute Lamp Test                                                 |
| V36E        | Fresh restart                                                     |
| V16N36E     | Display ground Elapsed Time (GET)                                 |
| V25N36E     | Set GET. [R1](https://code.google.com/p/virtualagc/source/detail?r=1) for hours, [R2](https://code.google.com/p/virtualagc/source/detail?r=2) for minutes and [R3](https://code.google.com/p/virtualagc/source/detail?r=3) for 1/100 of seconds |
| V01N02E     | Single shot peek at erasable memory address [R3](https://code.google.com/p/virtualagc/source/detail?r=3) in octal |
| V21N02E     | Poke value [R2](https://code.google.com/p/virtualagc/source/detail?r=2) into erasable memory address [R3](https://code.google.com/p/virtualagc/source/detail?r=3) in octal |
| V11N02E     | Continuous peek at erasable memory address [R3](https://code.google.com/p/virtualagc/source/detail?r=3) in octal |
| V05N09E     | Display Alarm Code |
| V05N08E     | Display Alarm Data |
| V37E00E     | Enter Idle program mode |
