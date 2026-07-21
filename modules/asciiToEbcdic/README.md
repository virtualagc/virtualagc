The `asciiToEbcdic` module just contains two items, both lists:

- `asciiToEbcdic` is a table for converting characters encoded in ASCII to those encoded in EBCDIC.  
- `ebcdicToAscii` is a table for the reverse translation from EBCDIC to ASCII.

These conversions are specific to the EBCDIC code table needed by Intermetrics HAL/S (which has '[' and ']' characters with unusual encoding), and to the character conversions for EBCDIC characters not contained in the ASCII character set that are needed by the Virtual AGC ports of the original HAL/S compiler (specifically, &not; and &cent;, as translated to ~ and ` respectively).

Because of these specializations, these conversions are not suitable translations outside this specific context, nor are general translation libraries fit for this specific context.
