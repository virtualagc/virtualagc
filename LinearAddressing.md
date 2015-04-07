![http://virtualagc.googlecode.com/svn/trunk/Apollo32.png](http://virtualagc.googlecode.com/svn/trunk/Apollo32.png)
# Linear Virtual Addressing #

Although the real AGC used banked memory for addressing its Erasable and Fixed memory most debug front-ends use linear addressing. To facilitate debugging in existing gdb front-ends a  virtual linear memory map was created based on the original Octal Pseudo Addressing devised by the people at MIT in the early sixties (see Hugh Blair-Smith AGC4 Memo #9 1965 page 5). The original linear memory map had a gap from 0x1800-0x2000 but to keep the linear memory continuous I chose to fill this gap and allow Fixed-fixed even in the linear memory space to be addressed in two ways (see next section about memory overlaps). Note numbers with leading zero in this page are in Octal.

## Memory Overlaps ##
Unswitched Eraseable memory with an S-Reg value of 0000-01377 overlaps with Unswitched Erasable memory bank 00,01 and 02 with an S-Reg value of 01400-01777. Fixed-fixed memory with S-Reg value of 04000-07777 overlaps with Fixed-fixed bank 02 and 03 with an S-Reg value of 02000-03777. This means that the same data can be accessed in two ways.

## Memory Map ##

The following memory map shows how the linear virtual address maps to the actual banked memory in the AGC. All numbers are Octal with the exception of the Pseudo Address. The Pseudo Address is given in Hex format. Sometimes a series of bank values is used. For example each Common fixed Bank size is 1K and so listing all banks explicitly would just create a long table. Don't care is marked with an "X".
| **Pseudo Address** | **Memory Type** | **Erase Bank Reg.** | **Fixed Bank Reg.** | **Ext. Bit** | **S-Reg.** |
|:-------------------|:----------------|:--------------------|:--------------------|:-------------|:-----------|
| 0x0000-0x02FF | Unswitched Eraseable | X  | XX     | X | 00000-01377 |
| 0x0000-0x00FF | Unswitched Eraseable | 00 | XX     | X | 01400-01777 |
| 0x0100-0x01FF | Unswitched Eraseable | 01 | XX     | X | 01400-01777 |
| 0x0200-0x02FF | Unswitched Eraseable | 02 | XX     | X | 01400-01777 |
| 0x0300-0x03FF | Switched Eraseable   | 03 | XX     | X | 01400-01777 |
| 0x0400-0x04FF | Switched Eraseable   | 04 | XX     | X | 01400-01777 |
| 0x0500-0x05FF | Switched Eraseable   | 05 | XX     | X | 01400-01777 |
| 0x0600-0x06FF | Switched Eraseable   | 06 | XX     | X | 01400-01777 |
| 0x0700-0x07FF | Switched Eraseable   | 07 | XX     | X | 01400-01777 |
| 0x0800-0x0FFF | Fixed-Fixed          | X  | XX     | X | 04000-07777 |
| 0x1000-0x17FF | Common Fixed         | X  | 00..01 | X | 02000-03777 |
| 0x1800-0x1FFF | Fixed-Fixed          | X  | 02..03 | X | 02000-03777 |
| 0x2000-0x6FFF | Common Fixed         | X  | 04..27 | X | 02000-03777 |
| 0x7000-0x8FFF | Super-bank 0         | X  | 30..37 | 0 | 02000-03777 |
| 0x9000-0x9FFF | Super-bank 1         | X  | 30..33 | 1 | 02000-03777 |