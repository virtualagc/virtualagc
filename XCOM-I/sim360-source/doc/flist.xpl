/*
   Some of the documents used by the Michigan Terminal System (MTS) were
distributed as files that could be copied directly to the printer.  The
first letter of each line was interpreted as a Vertical Format Control
character.  The rest of the line contained the next to be printed.  The
interesting part is when the text was overprinted.
   This program will take the text to be printed and merge it with the
overprinted text sometimes creating a new letter or glyph.  This new
text is then converted to an HTML document.

*/

declare (source_unit, output_unit, reading) fixed; 
declare (text, line) character,
   (cp, text_limit, number, line_number) fixed,
   hex_display fixed,
   map_display fixed;

declare (i, j) fixed;

declare LINE_LIMIT literally '132',
   (c, u) (LINE_LIMIT) fixed,
   map(255) character;

declare x1 character initial(' '),
   hx(16) character initial('0123456789ABCDEF');

/*
** hex(c, l)
**
** Convert a character to a two digit hexadecimal character.
** Return the string.
*/
hex:
   procedure(n, l) character;
      declare (n, l) fixed,
         s character;

      s = '';
         do while l > 0;
            l = l - 4;
            s = s || substr(hx, shr(n, l) & 15, 1);
         end;
      return s;
   end hex;

/*
** print_line
*/
print_line:
   procedure;
      declare (i, ul, w, ll) fixed,
         s character;

      i = 0;
      ul = 0;
      s, line = '';
         do while c(i) > 0;
            if ul ^= byte('_') & u(i) = byte('_') then
               do;
                  line = line || '<u>';
                  ul = byte('_');
               end;
            w = shl(c(i), 8) + u(i);
            if hex_display then
               if c(i) >= 128 | u(i) >= 128 then
                  do;
                     s = s || x1 || hex(w, 16);
                     if length(s) > 80 then
                        do;
                           output(output_unit) = s;
                           s = '';
                        end;
                  end;
            ll = length(line) + 1;
            if w = "BF7C" then line = line || '&boxvr;';
            else
            if w = "AF7C" then line = line || '&boxvl;';
            else
            if w = "D0D7" then line = line || '&boxhd;';
            else
            if w = "5DD7" then line = line || '&boxhu;';
            else line = line || map(c(i));
            if u(i) = byte('/') then line = line || '&#824;';
            if map_display = 1 & length(line) = ll then
               if c(i) >= 128 | u(i) >= 128 then
                  do;
                     s = s || x1 || hex(w, 16);
                     if length(s) > 80 then
                        do;
                           output(output_unit) = s;
                           s = '';
                        end;
                  end;
            u(i) = 0;
            i = i + 1;
            if ul = byte('_') & u(i) ^= byte('_') then
               do;
                  line = line || '</u>';
                  ul = 0;
               end;
         end;
      if length(s) > 0 then output(output_unit) = s;
      u(i) = 0;
      output(output_unit) = line;
   end print_line;

/*
**  convert_file
*/
convert_file:
   procedure;
      output(output_unit) = '<!DOCTYPE html>';
      output(output_unit) = '<html>';
      output(output_unit) = '<body><pre>';
      reading = 1;
         do while reading;
            text = input(source_unit);
            if length(text) > LINE_LIMIT then
               text = substr(text, 0, LINE_LIMIT);
            text_limit = length(text) - 1;
            cp = 0;
            if text_limit < 0 then reading = 0;
            else
            if byte(text) = byte('+') then
               do;
                  text = substr(text, 1);
                     do i = 0 to length(text) - 1;
                        u(i) = byte(text, i);
                     end;
                     do i = i to LINE_LIMIT;
                        u(i) = 0;
                     end;
               end;
            else
               do;
                  call print_line;
                  if byte(text) = byte('0') then output(output_unit) = '';
                  if byte(text) = byte('-') then
                     do;
                        output(output_unit) = '';
                        output(output_unit) = '';
                     end;
                  text = substr(text, 1);
                     do i = 0 to length(text) - 1;
                        c(i) = byte(text, i);
                     end;
                     do i = i to LINE_LIMIT;
                        c(i) = 0;
                     end;
               end;
            line_number = line_number + 1;
         end;
      call print_line;
      output(output_unit) = '</pre></body>';
      output(output_unit) = '</html>';
   end convert_file;

/*
**  initialization
**
**  Initialize internal data structures.
*/
initialization:
   procedure;
      declare s character;

      s = x1;
         do i = 0 to 255;
            s = substr(s || x1, 1);
            byte(s) = i;
            map(i) = s;
         end;
      /* Output character translation map (Required by HTML) */
      map(byte('''')) = '&apos;';
      map(byte('"')) = '&quot;';
      map(byte('&')) = '&amp;';
      map(byte('<')) = '&lt;';
      map(byte('>')) = '&gt;';

      /* EBCDIC characters that were not translated */
      map(byte('^')) = '<sup>0</sup>';  /* superscript 0 */
      map(byte('~')) = '&deg;';  /* Degree */
      map(byte(']')) = '&boxul;';  /* Lower right corner */
      map("83") = '&squf;';  /* Filled box */
      map("A3") = '<sup>1</sup>';  /* superscript 1 */
      map("A4") = '&squf;';  /* Filled box */
      map("A5") = '<sup>2</sup>';  /* superscript 2 */
      map("A7") = '<sup>5</sup>';  /* superscript 5 */
      map("A8") = ']';
      map("A9") = '<sup>4</sup>';  /* superscript 4 */
      map("AA") = '`';
      map("AE") = '&bullet;';  /* Filled circle */
      map("AF") = '&boxdl;';  /* Upper right corner */
      map("B1") = '&boxvh;';  /* Intersection */
      map("B4") = '&ne;'; /* Not equal */
      map("B5") = '<sup>-</sup>';  /* superscript minus */
      map("B6") = '<sup>6</sup>';  /* superscript 6 */
      map("B7") = '<sup>3</sup>';  /* superscript 3 */
      map("B8") = '<sup>)</sup>';  /* superscript right paren */
      map("BA") = '}';
      map("BB") = '{';
      map("BC") = '<sup>7</sup>';  /* superscript 7 */
      map("BD") = '<sup>8</sup>';  /* superscript 8 */
      map("BE") = '<sup>9</sup>';  /* superscript 9 */
      map("BF") = '&boxur;';  /* Lower left corner */
      map("C6") = '&plusmn;'; /* Plus or minus */
      map("D0") = '&boxdr;';  /* Upper left corner */
      map("D7") = '&boxh;';  /* hyphen (Box horizontal) */
      map("DD") = '[';
      map("DE") = '&ge;'; /* Greater than or equal to */
      map("E6") = '&squ;';  /* Open box */
      map("F0") = '&le;'; /* Less than or equal to */
      map("FD") = '<sup>(</sup>';  /* superscript left paren */
      map("FE") = '<sup>+</sup>';  /* superscript plus */
   end initialization;

/*
**   Print a brief description of how to use the program.
*/
usage:
   procedure;
      output(1) = 'Usage: ' || argv(0) || ' [<source-file>] [-o <html-file>]';
      output(1) = '   <source-file>   -  Input print file (if missing, use STDIN)';
      output(1) = '   -o <html-file>  -  Output HTML file (if missing, use STDOUT)';
      output(1) = '   -xHH=string     -  Map HH character to ''string''';
      output(1) = '   -h              -  Display characters above 127';
      output(1) = '   -H              -  Display unmapped characters above 127';
      output(1) = 'Convert line printer text files to an HTML file';
   end usage;

call initialization;
source_unit = 0;
output_unit = 0;
do i = 1 to argc - 1;
   text = argv(i);
   if length(text) < 5 then j = 0;
   else j = byte(text, 1);
   if byte(text) ^= byte('-') then
      do;
         source_unit = xfopen(text, 'r');
         if source_unit < 0 then
            do;
               output(1) = 'Open file error: ' || text;
               call usage;
               return 1;
            end;
      end;
   else
   if text = '-o' then
      do;
         if i >= argc - 1 then
            do;
               output(1) = 'Missing output filename';
               call usage;
               return 1;
            end;
         i = i + 1;
         output_unit = xfopen(argv(i), 'w');
         if output_unit < 0 then
            do;
               output(1) = 'Open file error: ' || argv(i);
               return 1;
            end;
      end;
   else
   if text = '-h' then /* Display characters above 127 */
      do;
         hex_display = 1;
      end;
   else
   if text = '-H' then /* Display unmapped characters above 127 */
      do;
         map_display = 1;
      end;
   else
   if j = byte('x') then
      do;
         number = 0;
            do cp = 2 to length(text) - 1;
               j = byte(text, cp);
               if j >= byte('0') & j <= byte('9') then
                  number = shl(number, 4) + j - byte('0');
               else
               if j >= byte('a') & j <= byte('f') then
                  number = shl(number, 4) + j - byte('a') + 10;
               else
               if j >= byte('A') & j <= byte('F') then
                  number = shl(number, 4) + j - byte('A') + 10;
               else
               if j = byte('=') then
                  do;
                     map(number & 255) = substr(text, cp + 1);
                     cp = length(text);
                  end;
            end;
      end;
   else
      do;
         output(1) = 'Unknown option: ' || text;
         call usage;
         return 1;
      end;
end;
call convert_file;
eof eof
