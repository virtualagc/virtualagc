/* File longBitstringDemo.xpl */
/* $E Intersperse 360 code in printout */

DECLARE S1 CHARACTER INITIAL('HELLO');
DECLARE B1 BIT(56) INITIAL("FFFFFFF");
DECLARE B2 BIT(56) INITIAL("FFFFFF0");
DECLARE B3 BIT(56) INITIAL("FFFFF00");
DECLARE B4 BIT(56) INITIAL("FFFF000");
DECLARE B5 BIT(56) INITIAL("FFF0000");
DECLARE B6 BIT(56) INITIAL("FF00000");
DECLARE B7 BIT(56) INITIAL("F000000");
DECLARE B8 BIT(56) INITIAL("0000000");
DECLARE B10 BIT(57) INITIAL("(1) 
1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1
");
DECLARE B11 BIT(58) INITIAL("(1) 
1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 11
");
DECLARE B12 BIT(59) INITIAL("(1) 
1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 111
");
DECLARE B13 BIT(60) INITIAL("(1) 
1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111
");
DECLARE B14 BIT(60) INITIAL("(1) 
0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
");
DECLARE B15 BIT(86) INITIAL("(1)
1111 1111 1111 1111 1111 1111 1111 1111 1111 1111
1111 1111 1111 1111 1111 1111 1111 1111 1111 1111
1111 11
");
DECLARE S2 CHARACTER INITIAL('GOODBYE');

DECLARE BIT2048 BIT(2048) INITIAL("
        00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
        10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F
        20 21 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F
        30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F
        40 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F
        50 51 52 53 54 55 56 57 58 59 5A 5B 5C 5D 5E 5F
        60 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F
        70 71 72 73 74 75 76 77 78 79 7A 7B 7C 7D 7E 7F
        80 81 82 83 84 85 86 87 88 89 8A 8B 8C 8D 8E 8F
        90 91 92 93 94 95 96 97 98 99 9A 9B 9C 9D 9E 9F
        A0 A1 A2 A3 A4 A5 A6 A7 A8 A9 AA AB AC AD AE AF
        B0 B1 B2 B3 B4 B5 B6 B7 B8 B9 BA BB BC BD BE BF
        C0 C1 C2 C3 C4 C5 C6 C7 C8 C9 CA CB CC CD CE CF
        D0 D1 D2 D3 D4 D5 D6 D7 D8 D9 DA DB DC DD DE DF
        E0 E1 E2 E3 E4 E5 E6 E7 E8 E9 EA EB EC ED EE EF
        F0 F1 F2 F3 F4 F5 F6 F7 F8 F9 FA FB FC FD FE FF
");
DECLARE BIT392 BIT(392) INITIAL("(2)
    0000 0001 0002 0003 0010 0011 0012 0013
    0020 0021 0022 0023 0030 0031 0032 0033
    0100 0101 0102 0103 0110 0111 0112 0113
    0120 0121 0122 0123 0130 0131 0132 0133
    0200 0201 0202 0203 0210 0211 0212 0213
    0220 0221 0222 0223 0230 0231 0232 0233
    0300 
");
DECLARE I FIXED;

OUTPUT = 'BIT2048';
DO I = 0 TO 255;
    OUTPUT = I || ': ' || BYTE(BIT2048, I);
END;

OUTPUT = '';
OUTPUT = 'BIT392';
DO I = 0 TO 48;
    OUTPUT = I || ': ' || BYTE(BIT392, I);
END;

OUTPUT = "(2)11111111 11111111 1";

EOF EOF EOF