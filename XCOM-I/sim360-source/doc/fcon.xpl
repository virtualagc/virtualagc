/*
     The University of Michigan created a text processing system for the
  Michigan Terminal System.  (Circa 1980)  The text processor had the
  uninspired name of FORMAT.  For the most part the FORMAT program was
  written in IBM/360 assembly language and so is effectivly lost to history.
     FCON.XPL will read documents written for FORMAT and translate them
  to HTML which can be read by any browser.

     Unless you have a document already written for FORMAT this program
  will be usless to you.

  Author: Daniel Weaver
  Written: 2021

*/

declare TRUE literally '1',
   FALSE literally '0';

declare (source_unit, output_unit) fixed; 
declare (text, buffer, string) character,
   (sp, cp, text_limit, number, token) fixed,
   line_number fixed,
   reading fixed,
   fixed_pitch_option fixed,
   count_option fixed,
   macro_option fixed,
   mix_option fixed;

declare hex_codes character initial('0123456789ABCDEF'),
   lc_letters character initial('abcdefghijklmnopqrstuvwxyz'),
   uc_letters character initial('ABCDEFGHIJKLMNOPQRSTUVWXYZ'),
   super_letters character initial('0123456789()+-'),
   x1 character initial(' '),
   x70 character initial(
   '                                                                      ');

declare map(255) character,
   map9A character,
   (uc, ctype, vcc)(255) bit(8),
   (vcc_ident, default_vcc_ident) fixed,
   VCC_COMMAND literally '1',
   VCC_ASIS literally '2',
   VCC_VBAR literally '4',
   VCC_VBAR_SPACE literally '8',
   VCC_SUPER literally '16',
   VCC_ALPHA literally '32',
   VCC_NUMERIC literally '64',
   VCC_EXTENDED literally '128',
   VCC_IDENTIFIER literally '(VCC_ALPHA | VCC_NUMERIC)',
   TAB literally '9',
   UNDERLINE literally '"9A"',
   CENT literally '"A2"',
   BOXUL literally '"F1"';

declare (i, j, k) fixed;

declare (tran, nart, und) (255) bit(8);

/* Translation modes */
declare (hold, line, split) character,
   COMMAND_MODE literally '0',
   TEXT_MODE literally '1',
   MACRO_MODE literally '2',
   BODY_COUNT_MODE literally '3',
   FIGURE_MODE literally '4',
   FOOTER_MODE literally '5',
   FOOTNOTE_MODE literally '6',
   LEFT_FOOTER_MODE literally '7',
   LEFT_TITLE_MODE literally '8',
   RIGHT_FOOTER_MODE literally '9',
   RIGHT_TITLE_MODE literally '10',
   SUBTITLE_MODE literally '11',
   TITLE_MODE literally '12',
   mode fixed,
   super_mode fixed,
   underline_mode fixed,
   ncc_columns fixed,
   (ncc, last_character) character,
   justify_mode fixed,
   text_align character,
   auto_break fixed,
   (first_mode, shift_next) fixed,
   as_is_mode fixed,
   uppercase_mode fixed,
   suppression_mode fixed,
   generate_mode fixed,
   page_width fixed;

declare MACRO_LIMIT literally '255',
   LAST_MACRO_BODY literally '1023',
   mac_top fixed,  /* Last macro name */
   mac_name(MACRO_LIMIT) character,
   mac_body_index(MACRO_LIMIT) fixed,
   mac_body_count fixed,
   mac_body_top fixed,
   mac_body(LAST_MACRO_BODY) character;

declare mac fixed,  /* Current macro nest level */
   MACRO_NEST_LIMIT literally '15',
   (mp, mend)(MACRO_NEST_LIMIT) fixed,  /* Macro body index (start, end) */
   resume_text(MACRO_NEST_LIMIT) character,  /* Text after the macro */
   null_hook fixed,
   MACRO_ARGUMENTS literally '159',
   par(MACRO_ARGUMENTS) character;

declare COUNT_LIMIT literally '99',
   counter fixed,
   cname(COUNT_LIMIT) character,  /* Counter name */
   cvalue(COUNT_LIMIT) fixed,  /* Current value */
   countv(COUNT_LIMIT) fixed,  /* Value for COUNTV */
   cin(COUNT_LIMIT) fixed;

declare TAB_LIMIT literally '20',
   TAB_STACK_LIMIT literally '200',
   tab(TAB_STACK_LIMIT) fixed,
   eat_blanks fixed,
   col fixed,
   columns fixed,
   drop character initial('.');

declare INDENT_LIMIT literally '20',
   INDENT_STACK_LIMIT literally '200',
   indent(INDENT_STACK_LIMIT) fixed,
   indent_level fixed,
   hanging_indent fixed,
   (left_indent, left_offset, right_offset) fixed,
   paragraph_indent fixed,
   paragraph_separation fixed;

/* Paragraph style options
   style=
      text-indent: 4ch;   or  text-indent: -8ch; <- hanging indent
      padding-left: 8ch;                         <- left indent
      padding: 1ch 2ch 3ch 4ch;
         1ch - top
         2ch - right
         3ch - bottom
         4ch - left
         initial | inherit
      margin: 1ch 2ch 3ch 4ch;
         1ch - top
         2ch - right
         3ch - bottom
         4ch - left
         auto | initial | inherit
   Examples:
      Paragraph with indent:
         <p style="text-indent:4ch; margin: 0 0ch 0 5ch;">
      Hanging indent:
         <p style="text-indent:-4ch; margin: 0 0ch 0 5ch;">
   Comments:
         <!-- Any text here -->
*/

/* Boxes and tables */
declare html_table fixed,
   HTML_TABLE_MODE literally '1',
   HTML_BOX_MODE literally '2',
   td fixed,
   tdmax fixed,
   class_number fixed,
   td_size(TAB_LIMIT) fixed,
   td_tag(TAB_LIMIT) character,
   table_tag character initial(
'<table cellspacing="0" cellpadding="0" style="border-collapse: collapse;">'),
   tbody_tag character initial('<tbody>'),
   end_table_tag character initial('</td></tr></tbody></table>');

declare box_map fixed,
   BOX_TAB_LIMIT literally '200',
   box(BOX_TAB_LIMIT) fixed,
   box_tag(BOX_TAB_LIMIT) character;

declare draw_box fixed,
   bs(15) character,
   DRAW_TOP literally '8',
   DRAW_RIGHT literally '4',
   DRAW_BOTTOM literally '2',
   DRAW_LEFT literally '1',
   DRAW_ALL literally '15',
   DRAW_NONE literally '0';

declare (count_div, count_tr, count_td, count_p, count_tbody) fixed,
   (count_start_div, count_start_p, count_start_td, count_start_tr) fixed,
   count_td_pairs fixed;

/*
   EBCDIC to ASCII translation table.
   This is used with the TRANSLATE command when the user has specified
   a hexadecimal value.  This table is specific to the FORMAT program
   and should not be used as a general translation table.  Characters
   that are blank are not translated.
*/
declare code_page(15) character initial(
/* 0 */ '                ',
/* 1 */ '                ',
/* 2 */ '                ',
/* 3 */ '                ',
/* 4 */ '           .<(+|',
/* 5 */ '&         !$*); ',
/* 6 */ '-/        |,%_>?',
/* 7 */ '         `:#@''="',
/* 8 */ ' abcdefghi {    ',
/* 9 */ ' jklmnopqr }    ',
/* A */ ' ~stuvwxyz   [  ',
/* B */ '^            ]  ',
/* C */ ' ABCDEFGHI      ',
/* D */ ' JKLMNOPQR      ',
/* E */ '  STUVWXYZ      ',
/* F */ '0123456789      ');

declare tnt(255) bit(8);

/*
**  output_string(s)
**
**  Output a string to the output_unit file.
*/
output_string:
   procedure(s);
      declare s character,
         i fixed;

      output(output_unit) = hold;
      hold = s;
      if count_option then
         do i = 0 to length(s) - 3;
            if substr(s, i, 5) = '<div>' then
               do;
                  if count_div = 0 then count_start_div = line_number;
                  count_div = count_div + 1;
               end;
            else
            if substr(s, i, 11) = '<div style=' then
               do;
                  if count_div = 0 then count_start_div = line_number;
                  count_div = count_div + 1;
               end;
            else
            if substr(s, i, 3) = '<p>' then
               do;
                  if count_p = 0 then count_start_p = line_number;
                  count_p = count_p + 1;
               end;
            else
            if substr(s, i, 9) = '<p style=' then
               do;
                  if count_p = 0 then count_start_p = line_number;
                  count_p = count_p + 1;
               end;
            else
            if substr(s, i, 4) = '<tr>' then
               do;
                  if count_tr = 0 then count_start_tr = line_number;
                  count_tr = count_tr + 1;
               end;
            else
            if substr(s, i, 3) = '<td' then
               do;
                  if count_td = 0 then count_start_td = line_number;
                  count_td = count_td + 1;
                  count_td_pairs = count_td_pairs + 1;
               end;
            else
            if substr(s, i, 7) = '<tbody>' then count_tbody = count_tbody + 1;
            else
            if substr(s, i, 8) = '</tbody>' then
               do;
                  count_tbody = count_tbody - 1;
                  if count_tbody < 0 then
                     output(1) = 'Too many </tbody>' || ' Line: ' || line_number;
               end;
            else
            if substr(s, i, 6) = '</div>' then
               do;
                  count_div = count_div - 1;
                  if count_div < 0 then
                     output(1) = 'Too many </div>' || ' Line: ' || line_number;
               end;
            else
            if substr(s, i, 5) = '</td>' then
               do;
                  count_td = count_td - 1;
                  if count_td < 0 then
                     output(1) = 'Too many </td>' || ' Line: ' || line_number;
               end;
            else
            if substr(s, i, 5) = '</tr>' then
               do;
                  count_tr = count_tr - 1;
                  if count_tr < 0 then
                     output(1) = 'Too many </tr>' || ' Line: ' || line_number;
                  if html_table = HTML_BOX_MODE then
                     do;
                        if count_td_pairs > tdmax then
                           output(1) = 'Too many <td></td> pairs' ||
                              ' Line: ' || line_number;
                        if count_td_pairs < tdmax then
                           output(1) = 'Missing <td></td> pairs' ||
                              ' Line: ' || line_number;
                     end;
                  count_td_pairs = 0;
               end;
            else
            if substr(s, i, 4) = '</p>' then
               do;
                  count_p = count_p - 1;
                  if count_p < 0 then
                     output(1) = 'Too many </p>' || ' Line: ' || line_number;
                  /* Multiple indents are allowed to nest.
                     The following is possible: <p> <p>  </p> </p> */
               end;
         end;
   end output_string;

/*
**  output_line
**
**  Output the line character string to the output_unit file.
*/
output_line:
   procedure;
      call output_string(line);
      line = '';
   end output_line;

/*
**  uppercase(string)
**
**  Convert a string to UPPERCASE.
*/
uppercase:
   procedure(s) character;
      declare s character, i fixed;

      if length(s) = 0 then return '';
      s = x1 || s;
         do i = 1 to length(s) - 1;
            byte(s, i) = uc(byte(s, i));
         end;
      return substr(s, 1);
   end uppercase;

/*
**  hex(number, size)
**
**  Return the number in hexadecimal.  Size is length in nibbles.
*/
hex:
   procedure(v, l) character;
      declare (n, l, v) fixed,
         s character;

      s = '';
         do n = 1 to l;
            s = substr(hex_codes, v & 15, 1) || s;
            v = shr(v, 4);
         end;
      return s;
   end hex;

/*
**  pad(string, width)
**
**  Pad the string with blanks.
*/
pad:
   procedure(string, width) character;
      declare string character, (width, l) fixed;

      l = length(string);
      if l >= width then return string;
         do while width - l > length(x70);
            string = string || x70;
            l = l + length(x70);
         end;
      return string || substr(x70, 0, width - l); 
   end pad;

/*
**  error(text)
**
**  Print an error message with line number.
*/
error:
   procedure(s);
      declare s character;

      output(1) = 'Line ' || line_number || ': ' || s;
   end error;

/*
**  trim(string)
**
**  Trim the blanks off the end of the string.
*/
trim:
   procedure(s) character;
      declare (c, i) fixed,
         s character;

         do i = length(s) - 1 to 0 by -1;
            c = byte(s, i);
            if c ^= byte(' ') then
               do;
                  return substr(s, 0, i + 1);
               end;
         end;
      return '';
   end trim;

/*
**  icon(value, length)
**
**  Integer Convert
*/
icon:
   procedure(v, w) character;
      declare (v, w) fixed,
         s character;

      s = v;
      if length(s) >= w then return s;
      return substr(x70, 0, w - length(s)) || s;
   end icon;

/*
**  next_byte(position)
**
**  Return the byte at some position on the right.
*/
next_byte:
   procedure(n) fixed;
      declare n fixed;

      if n > text_limit then return 0;
      return byte(text, n);
   end next_byte;

/*
**  scan
*/
scan:
   procedure;
      declare c fixed;

      string = '';
      token, number = 0;
         do while 1;
            if cp > text_limit then return;
            sp = cp;
            c = byte(text, cp);
               do case ctype(c);
                  /* Special characters */
                     do;
                        string = substr(text, cp, 1);
                        cp = cp + 1;
                        token = c;
                        return;
                     end;
                  /* White space */ cp = cp + 1;
                  /* Identifier */
                     do while 1;
                        if cp > text_limit then
                           do;
                              string = substr(text, sp);
                              token = byte('A');
                              return;
                           end;
                        c = byte(text, cp);
                        if (vcc(c) & vcc_ident) = 0 then
                           do;
                              string = substr(text, sp, cp - sp);
                              token = byte('A');
                              return;
                           end;
                        if c = byte('.') then default_vcc_ident =
                           default_vcc_ident | VCC_EXTENDED;
                        cp = cp + 1;
                     end;
                  /* Number */
                     do while 1;
                        if cp > text_limit then
                           do;
                              string = substr(text, sp);
                              token = byte('0');
                              return;
                           end;
                        c = byte(text, cp);
                        if ctype(c) ^= 3 then
                           do;
                              string = substr(text, sp, cp - sp);
                              token = byte('0');
                              return;
                           end;
                        number = number * 10 + c - byte('0');
                        cp = cp + 1;
                     end;
                  /* Quote */
                     do while 1;
                        cp = cp + 1;
                        if cp > text_limit then
                           do;
                              string = string || substr(text, sp + 1);
                              token = byte('S');
                              return;
                           end;
                        c = byte(text, cp);
                        if c = byte('''') then
                           do;
                              string = string || substr(text, sp + 1, cp - sp - 1);
                              token = byte('S');
                              if cp >= text_limit then return;
                              cp = cp + 1;
                              c = byte(text, cp);
                              if c ^= byte('''') then return;
                              string = string || '''';
                              sp = cp;
                           end;
                     end;
               end;
         end;
   end scan;

/*
**  sst(string)
**
**  Scan test code.  Process the string and print the results of one scan.
*/
sst:
   procedure(s);
      declare s character;

      cp = 0;
      text_limit = length(s) - 1;
      text = s;
      output = 'sst(' || s || ')';
      call scan;
      output = 'cp=' || cp || ' token=' || map(token) || ' string="'
         || string || '" ' || substr(text, cp);
   end sst;

/*
**  deblank
**
**  Scan past the blanks.
*/
deblank:
   procedure;
      declare c fixed;

         do while cp <= text_limit;
            c = byte(text, cp);
            if ctype(c) ^= 1 then return;
            cp = cp + 1;
         end;
   end;

/*
**  scan_trans
**
**  Scan text looking for either a string or a hex value.
**  This function is used by the TRANSLATE command.
*/
scan_trans:
   procedure fixed;
      declare (c, n, v) fixed;

      call deblank;
      if cp > text_limit then return 0;
      c = byte(text, cp);
      if c = byte('''') then
         do;
            call scan;
            if length(string) > 0 then return byte(string);
            return 0;
         end;
      v, n = 0;
         do while cp <= text_limit;
            c = byte(text, cp);
            if c >= byte('0') & c <= byte('9') then v = c - byte('0');
            else
            if c >= byte('A') & c <= byte('F') then v = c - byte('A') + 10;
            else
            if c >= byte('a') & c <= byte('f') then v = c - byte('a') + 10;
            else return n;
            n = shl(n, 4) + v;
            cp = cp + 1;
         end;
      return tnt(n & 255);
   end scan_trans;

/*
**  scan_number(default)
**
**  Scan the text looking for a number.
**  Discard all identifiers and punctuation.
*/
scan_number:
   procedure(def) fixed;
      declare def fixed;

         do while cp <= text_limit;
            call scan;
            if token = byte('0') then return number;
         end;
      return def;
   end scan_number;

/*
**  scan_parameters(macro_nest_level)
**
**  Scan Macro arguments of the form:
**     (<token> {,<token>}...)
**  The spec does not permit blanks in the parameter list.
**  The argument list may be empty.
*/
scan_parameters:
   procedure(n);
      declare (c, i, lp, n, pest) fixed;

      if n >= MACRO_NEST_LIMIT then n = MACRO_NEST_LIMIT;
      pest = n * 10;
         do i = pest to MACRO_ARGUMENTS;
            par(i) = '';
         end;
      null_hook = next_byte(cp + 1);
      if byte(text, cp) = byte('(') then
         do;
            lp, cp = cp + 1;
            i = 1;
            token = cp <= text_limit;
               do while token > 0;
                  if cp > text_limit then c = byte(')');
                  else c = byte(text, cp);
                  if c = byte('''') then
                     do;
                        call scan;
                        par(i + pest) = string;
                        i = i + 1;
                        c = next_byte(cp);
                        lp, cp = cp + 1;
                     end;
                  else
                  if c = byte(',') | c = byte(')') | c = byte(' ') then
                     do;
                        string = substr(text, lp, cp - lp);
                        par(i + pest) = string;
                        i = i + 1;
                        if c = byte(' ') then token = 0;
                        else cp = cp + 1;
                        lp = cp;
                     end;
                  else cp = cp + 1;
                  if c = byte(')') then token = 0;
                  if i > 9 then i = 0;
               end;
         end;
      if cp <= text_limit then
         do;
            c = byte(text, cp);
            if (vcc(c) & VCC_VBAR_SPACE) ^= 0 then cp = cp + 1;
         end;
   end scan_parameters;

/*
**  parameter_number
**
**  Return the parameter number if this is a macro parameter.
**  Return -1 if not a valid parameter.
**
**  Parameters have the form:  PAR.0 thru PAR.9
*/
parameter_number:
   procedure fixed;
      declare c fixed;

      if cp + 5 > text_limit then return -1;
      if (vcc(byte(text, cp)) & VCC_VBAR) = 0 then return -1;
      if uc(byte(text, cp + 1)) ^= byte('P') then return -1;
      if uc(byte(text, cp + 2)) ^= byte('A') then return -1;
      if uc(byte(text, cp + 3)) ^= byte('R') then return -1;
      if byte(text, cp + 4) ^= byte('.') then return -1;
      c = byte(text, cp + 5);
      if ctype(c) ^= 3 then return -1;
      return c - byte('0');
   end parameter_number;

/*
**  macro_expand
**
**  Do macro expansion
*/
macro_expand:
   procedure(m) character;
      declare (m, n, p, ncp, v) fixed,
         more character;

      p = m * 10;
      text = mac_body(mp(m));
      text_limit = length(text) - 1;
      cp = 0;
         do while cp <= text_limit;
            n = parameter_number;
            if n < 0 then cp = cp + 1;
            else
               do;
                  ncp = cp;
                  cp = cp + 6;
                  v = next_byte(cp);
                  if next_byte(cp + 1) ^= byte(')') | v ^= byte(' ') then
                     do;
                        if (vcc(v) & VCC_VBAR_SPACE) ^= 0 then cp = cp + 1;
                     end;
                  more = substr(text, cp);
                  text = substr(text, 0, ncp) || par(n + p);
                  cp = length(text);
                  text = text || more;
                  text_limit = length(text) - 1;
               end;
         end;
      return text;
   end macro_expand;

/*
**  find_macro_name(name)
**
**  Find the macro name and return the number.
**  Return -1 if not found.
*/
find_macro_name:
   procedure(name) fixed;
      declare name character,
         n fixed;

         do n = 0 to mac_top - 1;
            if mac_name(n) = name then return n;
         end;
      return -1;
   end find_macro_name;

/*
**  number_value(string)
**
**  Convert a character string to a number.
*/
number_value:
   procedure(s) fixed;
      declare s character,
         (n, c) fixed;

      n = 0;
         do while length(s) > 0;
            c = byte(s);
            if ctype(c) ^= 3 then return n;
            n = (n * 10) + c - byte('0');
            s = substr(s, 1);
         end;
      return n;
   end number_value;

/*
**  find_counter(name)
**
**  Find the counter by name.
**  If the counter does not exist then create it.
**  On overflow return COUNT_LIMIT.
*/
find_counter:
   procedure(name) fixed;
      declare name character,
         (i, first) fixed;

      first = COUNT_LIMIT;
         do i = 0 to COUNT_LIMIT;
            if name = cname(i) then return i;
            if length(cname(i)) = 0 then
               if first = COUNT_LIMIT then first = i;
         end;
      cname(first) = name;
      countv(first), cvalue(first) = 0;
      cin(first) = 1;  /* Increment */
      return first;
   end find_counter;

/*
**  format_functions(name, level)
**
**  Implement the built-in functions used by FORMAT
**  Return the string.
*/
format_functions:
   procedure(name, lvl) character;
      declare (name, value) character,
         (lvl, p, n, v, inc, ret) fixed;

      p = lvl * 10;
      if name = 'COUNT' then
         do;
            n = find_counter(par(p + 1));
            ret = 1;
            inc = cin(n);
            if length(par(p + 2)) > 0 then
               do;  /* New start value */
                  v = number_value(par(p + 2));
                  cvalue(n) = v;
                  ret, inc = 0;
               end;
            if length(par(p + 3)) > 0 then
               do;  /* New increment */
                  v = number_value(par(p + 3));
                  cin(n) = v;
                  ret, inc = 0;
               end;
            if length(par(p + 4)) > 0 then
               do;  /* New type */
                  ret, inc = 0;
               end;
            countv(n) = cvalue(n);
            value = cvalue(n);
            cvalue(n) = cvalue(n) + inc;
            if ret then return value;
            else return '';
         end;
      if name = 'COUNTV' then
         do;
            n = find_counter(par(p + 1));
            value = countv(n);
            return value;
         end;
      if name = 'STACK' then
         do;
            value = uppercase(par(p + 1));
            if value = 'PUSH' then
               do;
                  value = uppercase(par(p + 2));
                  if value = 'TABS' then
                     do;
                        /* TAB zero is not pushed */
                           do v = TAB_STACK_LIMIT to TAB_LIMIT by -1;
                              tab(v) = tab(v - TAB_LIMIT);
                           end;
                           do v = 0 to TAB_LIMIT;
                              tab(v) = 0;
                           end;
                     end;
                  else
                  if value = 'INDENTS' then
                     do;
                           do v = INDENT_STACK_LIMIT to INDENT_LIMIT by -1;
                              indent(v) = indent(v - INDENT_LIMIT);
                           end;
                           do v = 0 to INDENT_LIMIT;
                              indent(v) = 0;
                           end;
                     end;
                  return '';
               end;
            if value = 'POP' then
               do;
                  value = uppercase(par(p + 2));
                  if value = 'TABS' then
                     do;
                           do v = 1 to TAB_STACK_LIMIT - TAB_LIMIT;
                              tab(v) = tab(v + TAB_LIMIT);
                           end;
                           do v = v + 1 to TAB_STACK_LIMIT;
                              tab(v) = 0;
                           end;
                     end;
                  else
                  if value = 'INDENTS' then
                     do;
                           do v = 1 to INDENT_STACK_LIMIT - INDENT_LIMIT;
                              indent(v) = indent(v + INDENT_LIMIT);
                           end;
                           do v = v + 1 to INDENT_STACK_LIMIT;
                              indent(v) = 0;
                           end;
                     end;
                  return '';
               end;
            return '';
         end;
      if name = 'D' then
         do;
            return 'MM-DD-YY';
         end;
      if name = 'T' then
         do;
            return 'HH:MM:SS';
         end;
      if name = 'EXIST' then
         do;
            string = uppercase(par(p + 1));
            v = find_macro_name(string);
            if v >= 0 then return par(p + 2);
            else return par(p + 3);
         end;
      if name = 'NULL' then
         do;
            if ctype(null_hook) ^= 3 then string = par(p + 1);
            else /* A number */
            if p < 10 then string = '';
            else
               do;
                  n = null_hook - byte('0');
                  string = par(p + n - 9);
               end;

            if length(string) = 0 then return par(p + 2);
            else return par(p + 3);
         end;
      if name = 'LINE' then
         do;
            return line_number;
         end;
      if name = 'EXITTEXT' then
         do;
            return ' )V ';
         end;
      if name = 'SETUP' then
         do;
            return 'GO';
         end;
      return '';
   end format_functions;

/*
**  newline
**
**  Send a <br> tag to the output stream.
**  When center justify mode is enabled HTML operates differently with:
**      some text
**      <br> More text
**  and the following:
**      some text<br>
**      More text
**  My general impression is that the <br> tag should be at the end of the line.
*/
newline:
   procedure;
      hold = trim(hold);
      line = trim(line);
      if length(line) = 0 then hold = hold || '<br>';
      else line = line || '<br>';
   end newline;

/*
**  html_td_tag
**
**  Set the class name to draw the correct box.
**  Return the correct <td> tag for a box entry.
*/
html_td_tag:
   procedure character;
      declare db fixed;

      db = draw_box;
      if td = tdmax then draw_box = draw_box & (DRAW_LEFT | DRAW_RIGHT);
      if length(td_tag(td)) = 0 then return '<td>';
      if byte(td_tag(td), length(td_tag(td)) - 1) = byte('>') then
         return td_tag(td);
      return td_tag(td) || bs(db) || '">';
   end html_td_tag;

/*
**  html_set_column(column)
**
**  Emit the correct <td> </td> tags to position the
**  text to the correct column.
*/
html_set_column:
   procedure(c);
      declare c fixed;

         do while TRUE;
            if td >= tdmax then return;
            if c < td_size(td) then return;
            if td = 0 then line = line || '<tr>';
            else line = line || '</td>';
            col = td_size(td);
            td = td + 1;
            line = line || html_td_tag;
         end;
   end html_set_column;

/*
**  html_line_start(tag)
**
**  Emit the correct <td> </td> tags to position the
**  text to the correct td_tag().
*/
html_line_start:
   procedure(tag);
      declare (i, tag) fixed;

         do while td < tag;
            if td >= tdmax then return;
            if td = 0 then line = line || '<tr>';
            else line = line || '</td>';
            col = td_size(td);
            td = td + 1;
            line = line || html_td_tag;
         end;
   end html_line_start;

/*
**  html_finish_line(text)
**
**  Finish the current line so the boxes get printed properly.
*/
html_finish_line:
   procedure(tx);
      declare (s, tx) character;

         do while td < tdmax;
            if td = 0 then line = line || '<tr>';
            else line = line || '</td>';
            td = td + 1;
            s = html_td_tag;
            line = line || s;
         end;
      line = line || tx;
      call output_line;
   end html_finish_line;

/*
**  html_box_style_class(draw, width)
**
**  Create the <style> lines to define a box.
**  border-width: top right bottom left
*/
html_box_style_class:
   procedure(w, draw);
      declare (i, draw) fixed,
         (s, w) character;

      s = bs(draw);
      line = 'td.td' || class_number || 'x' || s ||
         ' {width: ' || w || 'ch;' ||
         ' border-style: solid; border-width: ' ||
         substr(s, 0, 1) || 'px ' ||
         substr(s, 1, 1) || 'px ' ||
         substr(s, 2, 1) || 'px ' ||
         substr(s, 3, 1) || 'px;' ||
         ' border-color: black;' ||
         ' padding: 0}';
      call output_line;
   end html_box_style_class;

/*
**  html_box_style(box_number)
**
**  Set up the style command for an HTML box
*/
html_box_style:
   procedure(b);
      declare (b, i, v) fixed,
         w character;

      call output_string('<style type="text/css">');
      v = 1;
         do i = 0 to TAB_LIMIT - 1;
            if box(b + i) <= 0 then
               do;
                  box_tag(b + i) = '<td>';
               end;
            else
            if i > 0 then
               do;
                  box_tag(b + i) = '<td valign="top" class="td'
                     || class_number || 'x';
                  w = box(b + i) - v;
                  call html_box_style_class(w, DRAW_NONE);
                  call html_box_style_class(w, DRAW_LEFT | DRAW_RIGHT);
                  call html_box_style_class(w, DRAW_LEFT | DRAW_TOP | DRAW_RIGHT);
                  call html_box_style_class(w, DRAW_LEFT | DRAW_BOTTOM | DRAW_RIGHT);
                  call html_box_style_class(w, DRAW_ALL);
                  class_number = class_number + 1;
                  v = box(b + i);
               end;
            else
            if box(b + i) = 1 then
               do;
                  box_tag(b + i) = '<td>';
                  v = box(b + i);
               end;
            else
               do;
                  box_tag(b + i) = '<td valign="top" class="td'
                     || class_number || '">';
                  w = box(b + i) - v;
                  line = 'td.td' || class_number ||
                     ' {width: ' || w || 'ch;' ||
                     ' padding: 0}';
                  call output_line;
                  class_number = class_number + 1;
                  v = box(b + i);
               end;
         end;
      line = '</style>';
      call output_line;
   end html_box_style;

/*
**  start_html_box(box_number, new)
**
**  Send the code to start an HTML box
*/
start_html_box:
   procedure(n, new_box);
      declare (b, i, n, new_box) fixed;

      if new_box then
         do;
            box_map = box_map | shl(1, n);  /* Mark this box as open */
            html_table = HTML_BOX_MODE;
            line = line || table_tag;
            call output_line;
            call output_string(tbody_tag);
            draw_box = DRAW_LEFT | DRAW_TOP | DRAW_RIGHT;
         end;
      if mix_option then call output_string('===> start_html_box(' ||
         n || ') td=' || td || ' box_map=' || hex(box_map, 4));
      tdmax = 1;
      td_tag(0) = '<td>';
      td_size(0) = 0;
      b = n * TAB_LIMIT;
         do i = 0 to TAB_LIMIT - 1;
            td_size(i + 1) = box(b + i);
            td_tag(i + 1) = box_tag(b + i);
            if td_size(i + 1) > 0 then tdmax = i + 1;
         end;
      td = 0;
      col = 1;
      call html_line_start(1);
      auto_break = 0;
   end start_html_box;

/*
**  end_html_box(n)
**
**  Send the HTML code to close a box.
*/
end_html_box:
   procedure(n);
      declare (n, m) fixed;

      /* Mark this box as closed */
      box_map = box_map & ~shl(1, n);
      if mix_option then call output_string('===> end_html_box(' || n ||
         ') td=' || td || ' box_map=' || hex(box_map, 4));
      if td ^= 1 then
         do;
            call html_finish_line('</td></tr>');
            td = 0;
            draw_box = draw_box & (DRAW_LEFT | DRAW_RIGHT | DRAW_BOTTOM);
         end;
      if (draw_box & DRAW_BOTTOM) = 0 then
         do;
            draw_box = draw_box | DRAW_BOTTOM;
            call html_finish_line('<br></td></tr>');
         end;
      line = line || '</tbody></table>';
      call output_line;
      n = -1;
      m = box_map;
         do while m ^= 0;
            /* Find the left most bit in box_map */
            m = shr(m, 1);
            n = n + 1;
         end;
      if n <= 0 then
         do;
            html_table = 0;
            draw_box = DRAW_NONE;
         end;
      else call start_html_box(n, FALSE);
   end end_html_box;

/*
**  start_html_table
**
**  Set up the beginning of the HTML table.
*/
start_html_table:
   procedure;
      declare v fixed;

      tdmax = 1;
      td_size(0) = 0;
         do while cp <= text_limit & tdmax < TAB_LIMIT;
            call scan;
            if token = byte('0') then
               do;
                  if tdmax = 1 then 
                     call output_string('<style type="text/css">');
                  td_size(tdmax) = number;
                  td_tag(tdmax) = '<td valign="top" class="td'
                     || class_number || '">';
                  if tdmax = 1 then v = td_size(tdmax) - 1;
                  else v = td_size(tdmax) - td_size(tdmax - 1);
                  line = 'td.td' || class_number ||
                     ' {width: ' || v || 'ch}';
                  call output_line;
                  class_number = class_number + 1;
                  tdmax = tdmax + 1;
               end;
         end;
      if tdmax > 1 then call output_string('</style>');
         do i = tdmax to TAB_LIMIT;
            td_tag(i) = '<td>';
            td_size(i) = 0;
         end;
      html_table = HTML_TABLE_MODE;
      call output_string(table_tag);
      call output_string(tbody_tag);
      td = 0;
      col = 1;
      call html_line_start(1);
      auto_break = 0;
   end start_html_table;

/*
**  control_phrase
*/
control_phrase:
   procedure;
      declare (i, v, x, enable) fixed,
         (phrase, s) character;

      call scan;
      string = uppercase(string);
      if string = 'NO' then
         do;
            call scan;
            string = uppercase(string);
            enable = 0;
         end;
      else enable = 1;
      phrase = string;
      /* Only the first three characters are used */
      if length(phrase) > 3 then phrase = substr(phrase, 0, 3);
      if phrase = 'BOX' then
         do;
            x = scan_number(0);
            v = x * TAB_LIMIT;
            if v <= 0 | v > BOX_TAB_LIMIT then
               do;
                  call error('Box ' || x ||
                     ' must be in the range of 1 thru 10');
                  return;
               end;
               do i = 0 to TAB_LIMIT - 1;
                  box(v + i) = scan_number(0);
               end;
            call html_box_style(v);
         end;
      else
      if phrase = 'CAL' then /* Macro CALL */
         do;
            call scan;
            if token = byte('A') then /* Identifier */
               do;
                  s = uppercase(string);
                  v = find_macro_name(s);
                  call scan_parameters(mac + 1);
                  if v >= 0 & mac < MACRO_NEST_LIMIT - 1 then
                     do;
                        mac = mac + 1;
                        mp(mac) = mac_body_index(v);
                        mend(mac) = mac_body_index(v + 1);
                        resume_text(mac) = substr(text, cp);
                        return;
                     end;
                  else call format_functions(s, mac + 1);
               end;
         end;
      else
      if phrase = 'CLE' then /* Clear all function and macro definitions */
         do;
            mac_top = 0;
            mac_body_top = 0;
         end;
      else
      if phrase = 'COL' then
         do;
            if length(line) > 0 then call output_line;
            v = scan_number(1);
            if v < 1 then v = 1;
            if v > 2 then v = 2;
            if v > columns then
               do;
                  call output_string('<div style="display:flex;">');
                  call output_string('<div style="flex:1;">');
               end;
            else
            if v < columns then
               do;
                  call output_string('</div></div>');
               end;
            columns = v;
         end;
      else
      if phrase = 'DEF' then /* Define macro */
         do;
            if mac_top >= MACRO_LIMIT then
               do;
                  call error('Macro name overflow');
                  reading = 0;
               end;
            else
               do;
                  vcc_ident = vcc_ident | VCC_EXTENDED;
                  call scan;
                  vcc_ident = default_vcc_ident;
                  mac_name(mac_top) = uppercase(string);
                  mac_body_count = scan_number(-1);
                  mac_top = mac_top + 1;
                  if mac_body_count < 0 then mode = MACRO_MODE;
                  else mode = BODY_COUNT_MODE;
               end;
         end;
      else
      if phrase = 'DRO' then /* TAB expansion character */
         do;
            call scan;
            if token = byte('S') then
               drop = substr(x1 || string, 1);
            else drop = '.';
         end;
      else
      if phrase = 'ERA' then /* Erase macro */
         do;
            call scan;
            if token = byte('A') then /* Identifier */
               do;
                  s = uppercase(string);
                  v = find_macro_name(s);
                  if v >= 0 then mac_name(v) = x1 || mac_name(v);
               end;
         end;
      else
      if phrase = 'FIG' then /* Figure */
         do;
            mode = FIGURE_MODE;
         end;
      else
      if substr(string, 0, 5) = 'FOOTE' then /* Footer */
         do;
            mode = FOOTER_MODE;
         end;
      else
      if phrase = 'FOO' then /* Footnote */
         do;
            mode = FOOTNOTE_MODE;
         end;
      else
      if phrase = 'GEN' then /* Generate /L/ after each line */
         do;
            generate_mode = enable;
         end;
      else
      if phrase = 'GO' then mode = TEXT_MODE;
      else
      if phrase = 'HTM' then  /* HTML TABLE/BOX extension */
         do;
            call scan;
            string = uppercase(string);
            if string = 'TABLE' then
               do;
                  if length(line) > 0 then call output_line;
                  if enable then call start_html_table;
                  else
                     do;
                        html_table = 0;
                        line = line || end_table_tag;
                        call output_line;
                        draw_box = DRAW_NONE;
                     end;
               end;
         end;
      else
      if phrase = 'IND' then /* Indent */
         do;
            indent(0), indent(1) = 0;
               do i = 2 to INDENT_LIMIT;
                  indent(i) = scan_number(0);
               end;
         end;
      else
      if phrase = 'KEY' | phrase = 'LOW' then /* Lowercase input */
         do;
               do i = 0 to 255;
                  tran(i) = i;
               end;
            tran(byte('_')) = UNDERLINE;
            if enable = 0 then
               do i = 0 to length(lc_letters) - 1;
                  v = byte(uc_letters, i);
                  tran(v) = byte(lc_letters, i);
               end;
         end;
      else
      if phrase = 'LEF' then /* Lefthand Page */;
      else
      if phrase = 'LFO' then /* Lefthand Footer */
         do;
            mode = LEFT_FOOTER_MODE;
         end;
      else
      if phrase = 'LTI' then /* Lefthand Title */
         do;
            mode = LEFT_TITLE_MODE;
         end;
      else
      if phrase = 'MTS' then reading = 0;
      else
      if phrase = 'PAR' then
         paragraph_indent = scan_number(paragraph_indent);
      else
      if phrase = 'RFO' then /* Righthand Footer */
         do;
            mode = RIGHT_FOOTER_MODE;
         end;
      else
      if phrase = 'RTI' then /* Righthand Title */
         do;
            mode = RIGHT_TITLE_MODE;
         end;
      else
      if phrase = 'SEP' then
         paragraph_separation = scan_number(paragraph_separation);
      else
      if phrase = 'SET' then /* Define a one line macro */
         do;
            if mac_top >= MACRO_LIMIT then
               do;
                  call error('Macro name overflow');
                  reading = 0;
               end;
            else
            if mac_body_top >= LAST_MACRO_BODY then
               do;
                  call error('Macro body overflow');
                  reading = 0;
               end;
            else
               do;
                  vcc_ident = vcc_ident | VCC_EXTENDED;
                  call scan;
                  vcc_ident = default_vcc_ident;
                  if token ^= byte('A') then
                     do;
                        call error('<identifier> expected');
                        return;
                     end;
                  mac_name(mac_top) = uppercase(string);
                  call scan;
                  if token ^= byte('=') then
                     do;
                        call error('= expected');
                        return;
                     end;
                  call scan;
                  if token ^= byte('S') then
                     do;
                        call error('''string'' expected');
                        return;
                     end;
                  mac_top = mac_top + 1;
                  mac_body(mac_body_top) = string;
                  mac_body_index(mac_top),
                  mac_body_top = mac_body_top + 1;
               end;
         end;
      else
      if string = 'SHOW' then /* Show debug info */
         do;
            call scan;
            if token ^= byte('A') then return;
            string = uppercase(string);
            if string = 'TD' then
               do;
                  output = 'TD=' || td || '  TDMAX=' || tdmax ||
                     ' draw_box=' || bs(draw_box);
                  v = td;
                  x = draw_box;
                     do i = 0 to TAB_LIMIT - 1;
                        td = i;
                        s = icon(i, 2) || icon(td_size(i), 4) || x1 || td_tag(i);
                        s = pad(s, 38) || html_td_tag;
                        output = s;
                     end;
                  td = v;
                  draw_box = x;
                  return;
               end;
            if string = 'BOX' then
               do;
                  number = scan_number(1);
                  output = 'BOX: ' || number;
                  v = number * TAB_LIMIT;
                  x = (TAB_LIMIT + 4) / 5;
                     do i = 0 to x - 1;
                        s = '';
                        k = 0;
                           do j = i to TAB_LIMIT - 1 by x;
                              s = pad(s, k) || j;
                              s = pad(s, k + 3) || box(v + j);
                              k = k + 15;
                           end;
                        output = s;
                     end;
                  return;
               end;
            if string = 'TAB' | string = 'TABS' then
               do;
                  s = '';
                     do i = 0 to TAB_LIMIT;
                        s = s || x1 || tab(i);
                     end;
                  output = 'TABS:' || s || '  col=' || col;
                  return;
               end;
            if string = 'INDENT' | string = 'INDENTS' then
               do;
                  output = 'indent_level=' || indent_level
                     || ' hanging_indent=' || hanging_indent;
                  s = '';
                     do i = 0 to INDENT_LIMIT;
                        if (i & 1) = 0 then s = s || ') (';
                        else s = s || ',';
                        s = s || indent(i);
                     end;
                  output = 'INDENTS:' || substr(s, 1);
                  return;
               end;
         end;
      else
      if phrase = 'SUB' then /* Subtitle */
         do;
            mode = SUBTITLE_MODE;
         end;
      else
      if phrase = 'SUP' then super_mode = enable;
      else
      if phrase = 'TAB' then
         do;
            tab(0) = 0;
               do i = 1 to TAB_LIMIT;
                  tab(i) = scan_number(tab(i - 1));
               end;
         end;
      else
      if phrase = 'TIT' then /* Title */
         do;
            mode = TITLE_MODE;
         end;
      else
      if phrase = 'TRA' then /* Translate */
         do;
            call scan;
            if token ^= byte('A') then return;
            string = uppercase(string);
            if length(string) > 3 then string = substr(string, 0, 3);
            if string = 'IN' | string = 'INP' then
               do;
                  i = scan_trans;
                  v = scan_trans;
                  tran(i) = v;
               end;
            else
            if string = 'OUT' then
               do;
                  i = scan_trans;
                  v = scan_trans;
                  nart(i) = v;
               end;
            else
            if string = 'UND' then
               do;
                  i = scan_trans;
                  v = scan_trans;
                  und(i) = v;
               end;
         end;
      else
      if phrase = 'WID' then page_width = scan_number(page_width);
      else
         do;
            ;
         end;
   end control_phrase;

/*
**  close_then_open_box(n)
**
**  Look for Box close followed by Box open.  /B1B1/
**  This tells the formatter to generate a horizontal line.
*/
close_then_open_box:
   procedure(n) fixed;
      declare (n, save, c) fixed;

      save = cp;
      c = next_byte(cp);
      if uc(c) = byte('B') then
         do;
            cp = cp + 1;
            call scan;
            if mix_option then call output_string('===> close_then_open_box(' || n ||
               ') number=' || number);
            if token = byte('0') & number = n then
               do;
                  if td < tdmax then
                     call html_finish_line('<br></td></tr>');
                  else line = line || '</td></tr>';
                  td = 0;
                  draw_box = draw_box | DRAW_TOP;
                  return 1;
               end;
         end;
      cp = save;
      if mix_option then call output_string('===> close_then_open_box(' || n ||
               ') cp=' || cp || x1 || substr(text, cp));
      return 0;
   end close_then_open_box;

/*
**  add_colspan(n)
**
**  Add colspan to the HTML tag <td>
**     <td colspan="3" valign="middle" class="td4">
*/
add_colspan:
   procedure(n);
      declare (i, n) fixed,
         tag character initial('<td valign='),
         s character;

      if n <= 1 then return;
         do i = length(line) - length(tag) to 0 by -1;
            if substr(line, i, length(tag)) = tag then
               do;
                  s = substr(line, i + 4);
                  line = substr(line, 0, i + 4) || 'colspan="' ||
                     n || '" ' || s;
                  td = td + n - 1;
                  if td = tdmax then
                     draw_box = draw_box & (DRAW_LEFT | DRAW_RIGHT);
                  return;
               end;
         end;
      /* If the code gets here I fail quietly. */
   end add_colspan;

/*
**  current_indent_level
**
**  Add the indent from 'I' and the indent from 'H' and
**  set left_offset and right_offset.
*/
current_indent_level:
   procedure;
      left_indent = indent(indent_level + indent_level);
      left_offset = left_indent + indent(hanging_indent + hanging_indent);
      right_offset = indent(indent_level + indent_level + 1) +
         indent(hanging_indent + hanging_indent + 1);
   end current_indent_level;

/*
**  set_margin_offsets
**
**  Set the values of left_offset and right_offset
*/
set_margin_offsets:
   procedure;
      declare l fixed;

      if html_table > 0 then
         do;
            l = indent(indent_level + indent_level) + 1;
            call html_set_column(l);
            left_offset = l - td_size(td - 1);
            right_offset = indent(indent_level + indent_level + 1);
         end;
      else call current_indent_level;
   end set_margin_offsets;

/*
**  create_margin_tag
**
**  Create the HTML tag to start a margin.
*/
create_margin_tag:
   procedure;
      declare (s, left_ch, right_ch) character;

      left_ch = left_offset;
      right_ch = right_offset;
      s = '<p style="margin: 0 ' || right_ch || 'ch 0 ' ||
         left_ch || 'ch;' || text_align || ' padding:0;">';
      line = line || s;
   end create_margin_tag;

/*
**  ready_column_one
**
**  Send the HTML tags needed to set up column one and
**  prepare to emit text.
*/
ready_column_one:
   procedure;
      if html_table = HTML_BOX_MODE & td = 1 then
         do;
            td = td + 1;
            line = line || '</td>' || html_td_tag;
         end;
   end ready_column_one;

/*
**  start_margin_control
**
**  Issue the HTML tag to start indentation if needed.
*/
start_margin_control:
   procedure;
      if length(text_align) + indent_level + hanging_indent > 0 then
         do;
            call ready_column_one;
            call set_margin_offsets;
            call create_margin_tag;
         end;
   end start_margin_control;

/*
**  end_margin_control
**
**  Issue the HTML tag to stop indentation if it was active.
*/
end_margin_control:
   procedure;
      if length(text_align) + indent_level + hanging_indent > 0 then
         do;
            line = line || '</p>';
            auto_break = 1;
            col = 1;
         end;
   end end_margin_control;

/*
**  split_line
**
**  Scan the output line backwards looking for an HTML tag that marks the
**  start of the line.
**
**  Return the character strings line and split.
*/
split_line:
   procedure;
      declare pp fixed,
         ok(8) character initial('<u>', '</u>', '<sup>', '</sup>', '');

   split_here:
      procedure fixed;
         declare (i, l) fixed;

         if byte(line, pp) ^= byte('>') then return FALSE;
         i = 0;
            do while length(ok(i)) > 0;
               l = length(ok(i));
               if pp + 1 >= l then
                  if substr(line, pp - l + 1, l) = ok(i) then return FALSE;
               i = i + 1;
            end;
         return TRUE;
      end split_here;

         do pp = length(line) - 1 to 1 by -1;
            if split_here then
               do;
                  split = substr(line, pp + 1);
                  line = substr(line, 0, pp + 1);
                  return;
               end;
         end;
      split = line;
      line = '';
   end split_line;

/*
**  test_split_line
**
**  Test wrapper for the split_line scanner.
*/
test_split_line:
   procedure(s);
      declare s character;

      line = s;
      split = '';
      call split_line;
      output = 'Split: "' || line || '"<==>"' || split || '"';
   end test_split_line;

/*
**  test_all_split_line
**
**  This is a list of test cases for the split_line function.
*/
test_all_split_line:
   procedure;
      call test_split_line('');
      call test_split_line('<br>');
      call test_split_line('txt');
      call test_split_line('txt</p>jj');
      call test_split_line('<br>(1) &nbsp;');
      call test_split_line('</p>txt input');
      call test_split_line('txt</p>1&nbsp;&nbsp;');
      call test_split_line('<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;G &nbsp;&nbsp;&nbsp;');
      call test_split_line('<br>txt;');
      call test_split_line('xxxx');
      call test_split_line('xx;x');
      call test_split_line('xx&x');
      call test_split_line('x&;x');
      call test_split_line('<u>xyz</u>');
      call test_split_line('<sup><u>xyz</u></sup>');
   end test_all_split_line;

/*
**  start_hanging_indent
**
**  Emit the code to start a hanging indent.
**  The following two input streams will generate the same output:
**     /LH1/Text/T/Normal...
**     /L/Text/TH1/Normal...
**
**  This will be output:
**     <p style="text-indent:-6ch; margin: 0 0ch 0 8ch;">Text&nbsp;&nbsp;Normal...
*/
start_hanging_indent:
   procedure(cols);
      declare cols fixed;

      text_align = ' text-indent:' || cols || 'ch;';
      call split_line;
      call create_margin_tag;
      line = line || split;
      text_align = '';
   end start_hanging_indent;

/*
**  backspace_one_character
**
**  Backup one character.
**  The character string "line" is shortened by one character.
*/
backspace_one_character:
   procedure;
      declare (i, c, gt, semi) fixed,
         s character;

      gt, semi = -1;
         do i = length(line) - 1 to 0 by -1;
            c = byte(line, i);
            if c = byte('>') then gt = i;
            else
            if gt >= 0 then
               do;
                  /* Skip over HTML tags: <xx> </xx> */
                  if c = byte('<') then gt = -1;
               end;
            else
            if c = byte(';') then semi = i;
            else
            if semi >= 0 then
               do;
                  if c = byte('&') then
                     do;
                        /* Delete a character of the form: &xxx; */
                        if semi = length(line) - 1 then
                           line = substr(line, 0, i);
                        else
                           do;
                              s = substr(line, semi + 1);
                              line = substr(line, 0, i) || s;
                           end;
                        return;
                     end;
               end;
            else
            if i = length(line) - 1 then
               do;  /* Delete the last character */
                  line = substr(line, 0, i);
                  return;
               end;
            else
               do;  /* Delete one character */
                  s = substr(line, i + 1);
                  line = substr(line, 0, i) || s;
                  return;
               end;
         end;
      if semi >= 0 then
         do;
            /* Delete the last character */
            if length(line) = 1 then line = '';
            else
               do;
                  s = substr(line, semi + 1);
                  line = substr(line, 0, semi) || s;
               end;
            return;
         end;
      /* Fail quietly */
   end backspace_one_character;

test_backspace:
   procedure(s);
      declare s character;
      line = s;
      call backspace_one_character;
      output = 'backspace: "' || line || '"';
      line = '';
   end test_backspace;
tbs:
   procedure;
      call test_backspace('');
      call test_backspace('x');
      call test_backspace(';');
      call test_backspace('x;');
      call test_backspace('&x;');
      call test_backspace('?&x;');
      call test_backspace(' <u>');
      call test_backspace('?&x;<u>');
      call test_backspace('&x;</u></sup>');
      call test_backspace('?&x;</u></sup>');
      call test_backspace('?&x;<&xyz;="a b c";>');
      call test_backspace('MTS ( <u>');
      call test_backspace('MTS ( <u>M</u> ');
   end tbs;
/*
**  underbar
**
**  Convert '<u>&nbsp;</u>' to a single underscore.
**  HTML does not display this properly.
*/
underbar:
   procedure;
      declare n fixed;

      n = length(line);
      if n >= 13 then
         if substr(line, n - 13) = '<u>&nbsp;</u>' then
            do;
               line = substr(line, 0, n - 13) || '_';
            end;
   end underbar;

/*
**  exit_underline_mode
**
**  Send the code to exit underline mode.
*/
exit_underline_mode:
   procedure;
      if underline_mode then line = line || '</u>';
      underline_mode = 0;
      call underbar;
   end exit_underline_mode;

/*
**  exit_justify_mode(new_mode)
**
**  Send the code to exit justify mode
**  The justify flag will be set to new_mode.
*/
exit_justify_mode:
   procedure(new_mode);
      declare new_mode fixed;

      if length(text_align) > 0 then
         do;
            text_align = '';
            line = line || '</p>';
            auto_break = 1;
            col = 1;
            if indent_level + hanging_indent > 0 then
               do;
                  call set_margin_offsets;
                  call create_margin_tag;
               end;
         end;
      justify_mode = new_mode;
   end exit_justify_mode;

/*
**  reset_all_modes
**
**  Reset justify_mode, hanging_indent and indent.
*/
reset_all_modes:
   procedure;
      call end_margin_control;
      text_align = '';
      justify_mode, indent_level, hanging_indent = 0;
   end reset_all_modes;

/*
**  exit_indent_level
**
**  Send the code to disable indentation
*/
exit_indent_level:
   procedure;
      if indent_level > 0 then
         do;
            line = line || '</p>';
            auto_break = 1;
            col = 1;
         end;
   end exit_indent_level;

/*
**  begin_indent
**
**  Send the code to begin indent mode by setting the margins
*/
begin_indent:
   procedure;
      declare s character;

      if indent_level > 0 then
         do;
            call set_margin_offsets;
            s = '<p style="margin: 0 ' ||
               right_offset || 'ch 0 ' ||
               left_offset || 'ch;">';
            line = line || s;
         end;
   end begin_indent;

/*
**  text_commands
**
**  Process embedded text commands.
*/
text_commands:
   procedure(term);
      declare (term, c, v, x, enable, why_not) fixed;
      declare (unknown, s, tab_char) character;

      why_not = FALSE;
      unknown = '';
      cp = cp + 1;
         do while cp <= text_limit;
            c = uc(byte(text, cp));
            cp = cp + 1;
            enable = 1;
            if c = byte('-') then
               do;
                  enable = 0;
                  if cp > text_limit then c = 0;
                  else c = uc(byte(text, cp));
                  cp = cp + 1;
               end;
            if c = byte('A') then /* AS-IS mode */
               do;
                  call exit_underline_mode;
                  call reset_all_modes;
                  if html_table > 0 & td < 2 then
                     do;
                        call html_line_start(2);
                     end;
                  /* Use this to make boxes close:
                     line = line || '<pre style="line-height:90%">';
                  */
                  if as_is_mode = FALSE then
                     line = line || '<pre style="margin:0;">';
                  as_is_mode = TRUE;
               end;
            else
            if c = byte('B') then /* Box */
               do;
                  c = next_byte(cp);
                  if ctype(c) = 3 then
                     do;
                        call scan;
                        v = number;
                        if (shl(1, v) & box_map) ^= 0 then enable = 0;
                     end;
                  else v = -1;

                  if mix_option then call output_string('===> /B' || v ||
                     '/ enable=' || enable || ' box_map=' || hex(box_map, 4));
                  if enable = 1 & v < 0 then
                     do;  /* Backspace */
                        call backspace_one_character;
                     end;
                  else
                     do;
                        call exit_underline_mode;
                        call exit_justify_mode(justify_mode);
                        if enable = 1 & v >= 0 then
                           call start_html_box(v, TRUE);
                        else
                        if close_then_open_box(v) = 0 then
                           call end_html_box(v);
                     end;
               end;
            else
            if c = byte('C') then /* Next Column */
               do;
                  call exit_underline_mode;
                  call exit_justify_mode(FALSE);
                  v = next_byte(cp);
                  if ctype(v) = 3 then call scan;
                  /* The number is discarded */

                  if enable then
                     do;
                       line = line || '</div><div style="flex:1;">';
                     end;
                  else
                     do;
                       line = line || '</div></div>';
                       columns = 1;
                     end;
               end;
            else
            if c = byte('F') then /* Capitalization */
               do;
                  shift_next, first_mode = enable & ~first_mode;
               end;
            else
            if c = byte('H') then /* Hanging Indent */
               do;
                  v = next_byte(cp);
                  if ctype(v) = 3 then call scan;
                  else number = 0;

                  if hanging_indent = 0 then
                     do;
                        if number = 0 then number = 1;
                     end;
                  else
                  if number = 0 | number = hanging_indent then enable = 0;

                  call end_margin_control;

                  if enable then
                     do;
                        call current_indent_level;
                        v = left_offset;
                        hanging_indent = number;
                        call current_indent_level;
                        call start_hanging_indent(v - left_offset);
                     end;
                  else
                     do;
                        hanging_indent = 0;
                        call start_margin_control;
                     end;
               end;
            else
            if c = byte('I') then /* Indent */
               do;
                  v = next_byte(cp);
                  x = next_byte(cp + 1);
                  if v = byte('+') & ctype(x) = 3 then
                     do;
                        cp = cp + 1;
                        call scan;
                        number = indent_level + number;
                     end;
                  else
                  if v = byte('-') & ctype(x) = 3 then
                     do;
                        cp = cp + 1;
                        call scan;
                        number = indent_level - number;
                        if number < 0 then number = 0;
                     end;
                  else
                     do;
                        if ctype(v) = 3 then call scan;
                        else number = 0;

                        if indent_level = 0 then
                           do;
                              if number = 0 then number = 1;
                           end;
                        else
                        if number = indent_level then enable = 0;
                     end;

                  call end_margin_control;

                  if enable then indent_level = number;
                  else indent_level = 0;

                  call start_margin_control;
               end;
            else
            if c = byte('K') then /* Kolumn Span */
               do;
                  v = next_byte(cp);
                  if ctype(v) = 3 then call scan;
                  else number = 0;

                  call ready_column_one;

                  if td + number > tdmax + 1 then
                     number = tdmax - td + 1;
                  if html_table > 0 then
                     do;
                        call add_colspan(number);
                     end;
               end;
            else
            if (c = byte('J')) | (c = byte('L')) | (c = byte('G')) then
               do; /* Line break */
                  c = next_byte(cp);
                  if ctype(c) = 3 then call scan;
                  else number = 1;
                  if html_table = HTML_BOX_MODE then
                     do;
                        call html_line_start(2);
                        if indent_level > 0 & td > -1 then
                           do;
                              number = number - auto_break;
                                 do while number > 0;
                                    number = number - 1;
                                    line = line || '<br>';
                                    auto_break = 1;
                                 end;
                           end;
                        else
                           do;
                              if td < tdmax then 
                                 do;
                                    call html_finish_line('<br></td></tr>');
                                    draw_box = DRAW_LEFT | DRAW_RIGHT;
                                 end;
                              else line = line || '</td></tr>';
                                 do v = 2 to number;
                                    td = 0;
                                    call html_finish_line('<br></td></tr>');
                                    draw_box = DRAW_LEFT | DRAW_RIGHT;
                                 end;
                              if length(line) > 0 then call output_line;
                              td = 0;
                              col = 1;
                              call html_line_start(1);
                              auto_break = 1;
                           end;
                     end;
                  else
                  if html_table > 0 then
                     do;
                        line = line || '</td></tr><tr>';
                        td = 1;
                           do v = 2 to number;
                              line = line || '<td><br></td></tr><tr>';
                           end;
                        call output_line;
                        line = html_td_tag;
                        draw_box = DRAW_NONE;
                        auto_break = 1;
                     end;
                  else
                     do;
                        number = number - auto_break;
                           do while number > 0;
                              number = number - 1;
                              call newline;
                              auto_break = 1;
                              col = -1;
                           end;
                     end;
                  if col < 0 then
                     do;
                        call current_indent_level;
                        col = left_offset + 1;
                     end;
                  else col = 1;
               end;
            else
            if c = byte('M') then /* Align Center */
               do;
                  enable = enable & ~justify_mode;
                  call end_margin_control;
                  if enable then
                     do;
                        text_align = ' text-align:center;';
                     end;
                  else
                     do;
                        text_align = '';
                     end;
                  call start_margin_control;
                  justify_mode = enable;
               end;
            else
            if c = byte('P') then /* Paragraph */
               do;
                  /* Disable F, M, U, X, @ and <cent> */
                  call exit_underline_mode;
                  call exit_justify_mode(justify_mode);
                     do v = auto_break + 1 to paragraph_separation;
                        line = line || '<br>';
                     end;
                     do v = 1 to paragraph_indent;
                        line = line || '&nbsp;';
                     end;
                  col = paragraph_indent + 1;
                  suppression_mode, uppercase_mode, auto_break = 0;
                  first_mode, shift_next = FALSE;
                  /* Swallow blanks to make the next two lines generate
                     the same display:
                        /P/Start of paragraph...
                        /P/ Start of paragraph...
                  */
                  eat_blanks = 1;
               end;
            else
            if c = byte('Q') then /* Right Justify */
               do;
                  /* This command is a one shot (Unlike the 'M' command) */
                  if enable then
                     do;
                        call split_line;
                        line = line || '<div style="text-align:right;">' ||
                           split || '</div>';
                        auto_break = 1;
                     end;
               end;
            else
            if c = byte('R') | c = byte('S') then /* Reset and Skip */
               do;
                  /* Disable: M, @, F, U, I and H */
                  call exit_underline_mode;
                  call reset_all_modes;
                  if auto_break = 0 then line = line || '<br>';
                  if c = byte('S') then line = line || '<br>';
                  col = 1;
                  auto_break = 1;
                  suppression_mode, uppercase_mode = 0;
                  first_mode, shift_next = FALSE;
               end;
            else
            if c = byte('T') | c = byte('D') then /* TAB */
               do;
                  if c = byte('D') then tab_char = drop;
                  else tab_char = '&nbsp;';
                  c = next_byte(cp);
                  if ctype(c) = 3 then call scan;
                  else
                     do;
                        number = 0;
                        if col < tab(TAB_LIMIT) then
                           do while col >= tab(number);
                              number = number + 1;
                           end;
                     end;
                  if html_table = HTML_BOX_MODE then
                     do;
                        if td > tdmax then td = 1;  /* This cant be right */
                        call html_set_column(tab(number));
                           do while col < tab(number);
                              line = line || tab_char;
                              col = col + 1;
                           end;
                     end;
                  else
                  if html_table > 0 then
                     do;
                        if td > tdmax then td = 1;
                        if td = 0 then line = line || '<tr>';
                        else line = line || '</td>';
                        v = 1;
                           do while v;
                              if td + 1 >= tdmax then v = 0;
                              else
                              if tab(number) <= td_size(td) then v = 0;
                              else
                                 do;
                                    line = line || '<td></td>';
                                    td = td + 1;
                                 end;
                           end;
                        td = td + 1;
                        line = line || html_td_tag;
                     end;
                  else
                     do while col < tab(number);
                        line = line || tab_char;
                        col = col + 1;
                     end;
                  eat_blanks = 1;
               end;
            else
            if c = byte('U') then
               do;
                  if underline_mode then enable = 0;
                  if enable ^= underline_mode then
                     do;
                        if enable then line = line || '<u>';
                        else
                        if length(line) = 0 then line = '</u>';
                        else
                        if byte(line, length(line) - 1) = byte(' ') then
                           do;
                              line = substr(line, 0, length(line) - 1) ||
                                 '</u> ';
                           end;
                        else line = line || '</u>';
                        underline_mode = enable;
                        call underbar;
                     end;
               end;
            else
            if c = byte('V') then /* Vacation mode */
               do;
                  /* Disable: /F/, /@/, /M/, and /U/ */
                  call exit_underline_mode;
                  call exit_justify_mode(FALSE);
                  suppression_mode, uppercase_mode = 0;
                  /* Enter control phrase mode */
                  mode = COMMAND_MODE;
               end;
            else
            if c = byte('W') then /* Keep together */
               do;
                  /* Not supported */
                  c = next_byte(cp);
                  if ctype(c) = 3 then
                     do;
                        call scan;
                     end;
               end;
            else
            if c = byte('X') then /* Blank Suppression mode */
               do;
                  suppression_mode = enable & ~suppression_mode;
               end;
            else
            if c = byte('Y') then /* Insert HTML code */
               do;
                  /* All text after this command to the <EOL> is
                  passed to the output stream.  e.g.
                     /Y/<Custom HTML commands>
                  */
                  why_not = TRUE;
               end;
            else
            if c = byte('Z') then /* Debug code */
               do;
                  s = 'Z: col=' || col || ', td=' || td;
                  output = s;
               end;
            else
            if c = byte('@') then /* Convert to upper case */
               do;
                  uppercase_mode = enable & ~uppercase_mode;
               end;
            else
            if c = CENT then /* Convert to upper case */
               do;
                  uppercase_mode = enable & ~uppercase_mode;
               end;
            else
            if (vcc(c) & VCC_VBAR) ^= 0 then
               do; /* Revision level */
                  /* Not supported */
                  c = next_byte(cp);
                  if ctype(c) = 3 then call scan;
               end;
            else
            if (vcc(c) & VCC_COMMAND) ^= 0 then
               do;
                  /* Unimplemented commands come here */
                  unknown = unknown || substr(text, cp - 1, 1);
               end;
            else
               do;
                  if c ^= term then cp = cp - 1;
                  if length(unknown) > 0 then
                     line = line || '&iquest;' || unknown || '&iquest;';
                  if why_not then
                     do;
                        if cp <= text_limit then
                           line = line || substr(text, cp);
                        cp = text_limit + 1;
                     end;
                  return;
               end;
         end;
   end text_commands;

/*
**  special_permit
**
**  Return TRUE if this is /@/, /u/ or /U/
*/
special_permit:
   procedure fixed;
      declare (i, c, term) fixed;

      if as_is_mode = FALSE then return FALSE;
      c = byte(text, cp);
      if c = byte('/') then
         do;
            if super_mode = FALSE then return FALSE;
            term = byte('/');
         end;
      else
      if c ^= byte(')') then return FALSE;
      else
         do;
            if cp > 0 then
               if byte(text, cp - 1) ^= byte(' ') then return FALSE;
            term = byte(' ');
         end;
         do i = cp + 1 to length(text) - 1;
            c = byte(text, i);
            if c = term then return TRUE;
            if (vcc(c) & VCC_ASIS) = 0 then return FALSE;
         end;
      return i > cp + 1;
   end special_permit;

/*
**  valid_text_command
**
**  Return TRUE if this is a valid text command
*/
valid_text_command:
   procedure fixed;
      declare (i, c) fixed;

      if super_mode = FALSE then return FALSE;
         do i = cp + 1 to length(text) - 1;
            c = byte(text, i);
            if c = byte('/') then return TRUE;
            if (vcc(c) & VCC_COMMAND) = 0 then return FALSE;
         end;
      return i > cp + 1;
   end valid_text_command;

/*
**  paren_mode
**
**  Return TRUE if this is <space>)<letter> or <eol>)<letter>
**  This function uses the fact that spaces are not consumed.
*/
paren_mode:
   procedure fixed;
      declare (i, c) fixed;

      if byte(text, cp) ^= byte(')') then return FALSE;
      if cp > 0 then
         if byte(text, cp - 1) ^= byte(' ') then return FALSE;
         do i = cp + 1 to text_limit;
            c = byte(text, i);
            if (vcc(c) & VCC_COMMAND) = 0 then return i > cp + 1;
         end;
      return i > cp + 1;
   end paren_mode;

/*
**  bump_column
**
**  Increment the column number by one.
**  Set all the flags that make a non-blank printing character.
*/
bump_column:
   procedure;
      auto_break = 0;
      eat_blanks = FALSE;
      shift_next = FALSE;
   end bump_column;

/*
**  special_character(c)
**
**  Convert special characters.
*/
special_character:
   procedure(c);
      declare c fixed;

      cp = cp + 1;
      if c < 10 | c > 56 then
         do;
            ncc = '|';
            return;
         end;
      cp = cp + 2;
         do case c - 10;
            ncc = '<sup>(</sup>'; /* 10 */
            ncc = '<sup>)</sup>';
            ncc = '<sup>+</sup>';
            ncc = '<sup>-</sup>';
            ncc = '{';
            ncc = '}';
            ncc = '[';
            ncc = ']';
            ncc = '&le;';
            ncc = '&ge;';
            ncc = '&plusmn;'; /* 20 */
            ncc = '&ne;';
            ncc = '&boxur;';
            ncc = '&boxul;';
            ncc = '&boxdr;';
            ncc = '&boxdl;';
            ncc = '&boxvh;';
            ncc = '&boxh;';
            ncc = '&squ;';
            ncc = '&squf;';
            ncc = '&bullet;'; /* 30 */
            ncc = '&deg;';
            ncc = '&amp;';
            ncc = '&boxv;';
            ncc = '&not;';
            ncc = '&lt;';
            ncc = '=';
            ncc = '&gt;';
            ncc = '+';
            ncc = '(';
            ncc = ')'; /* 40 */
            ncc = '&quot;';
            ncc = '&prime;';
            ncc = '&cent;';
            ncc = '#';
            ncc = '%';
            ncc = '@';
            ncc = '_';
            ncc = ';';
            ncc = ':';
            ncc = '?';  /* 50 */
            ncc = '!';
            ncc = '&boxvl;';
            ncc = '&boxvr;';
            ncc = '&boxhu;';
            ncc = '&boxhd;';  /* 55 */
            ncc = '/';  /* 56 - Not documented */
         end;
   end special_character;

/*
**  text_data
*/
text_data:
   procedure;
      declare (c, n, v) fixed,
         name character;

      if as_is_mode then
         do;
            c = byte(text, cp);
            if text_limit = 0 then v = byte(' ');
            else v = byte(text, cp + 1);
            if super_mode = FALSE then
               if c = byte('/') then v = 0;
            if ((c = byte(')')) | (c = byte('/'))) & (v = byte(' ')) then
               do;
                  as_is_mode = FALSE;
                  line = line || '</pre>';
                  cp = cp + 2;
               end;
            else
            if html_table = HTML_BOX_MODE then
               do;
                  c = next_byte(cp);
                  n = td_size(1) - 1;
                     do while c = byte(' ') & cp < n;
                        cp = cp + 1;
                        c = next_byte(cp);
                     end;
               end;
         end;
      else
      if generate_mode then
         do;
            text = text || ' )L';
            text_limit = length(text) - 1;
         end;
      last_character = '&nbsp;';
         do while cp <= text_limit;
            ncc = '';
            ncc_columns = 1;
            c = byte(text, cp);
            if (vcc(c) & VCC_VBAR) ^= 0 then
               do;
                  if ctype(next_byte(cp + 1)) = 3 &
                     ctype(next_byte(cp + 2)) = 3 then
                     do;
                        n = (next_byte(cp + 1) - byte('0')) * 10 +
                           (next_byte(cp + 2) - byte('0'));
                        call special_character(n);
                        call bump_column;
                     end;
                  else
                  if as_is_mode then
                     do;
                        ncc = map(nart(c));
                        cp = cp + 1;
                        call bump_column;
                     end;
                  else
                  if ctype(next_byte(cp + 1)) = 2 then /* Macro */
                     do;
                        cp = cp + 1;
                        call scan;
                        name = uppercase(string);
                        v = find_macro_name(name);
                        call scan_parameters(mac + 1);
                        if v >= 0 & mac < MACRO_NEST_LIMIT - 1 then
                           do;
                              mac = mac + 1;
                              mp(mac) = mac_body_index(v);
                              mend(mac) = mac_body_index(v + 1);
                              resume_text(mac) = substr(text, cp);
                              return;
                           end;
                        else
                           do;
                              string = format_functions(name, mac + 1);
                              text = string || substr(text, cp);
                              text_limit = length(text) - 1;
                              cp = 0;
                           end;
                     end;
                  else
                  if next_byte(cp + 1) = byte('@') &
                     ctype(next_byte(cp + 2)) = 3 &
                     ctype(next_byte(cp + 3)) = 3 then
                     do;  /* Repeat character x|@nn */
                        n = (next_byte(cp + 2) - byte('0')) * 10 +
                           (next_byte(cp + 3) - byte('0'));
                       if last_character = x1 then last_character = '&nbsp;';
                       last_character = unique(last_character);  /* HUH */
                           do v = 2 to n;
                              name = line || last_character;
                              line = name;
                              call bump_column;
                           end;
                        cp = cp + 4;
                     end;
                  else
                  if next_byte(cp + 1) = byte('-') then
                     do; /* Hyphenation */
                        cp = cp + 2;
                        line = line || '&shy;';
                     end;
                  else
                     do;
                        ncc = map(nart(c));
                        cp = cp + 1;
                        call bump_column;
                     end;
               end;
            else
            if c = byte('@') | c = CENT then
               do;
                  v = next_byte(cp + 1);
                  if ctype(v) = 2 then /* alphabetic */
                     do;
                        ncc = map(nart(uc(v)));
                        cp = cp + 2;
                        call bump_column;
                     end;
                  else
                  if (vcc(v) & VCC_SUPER) ^= 0 then /* Superscript */
                     do;
                        ncc = '<sup>' || map(nart(v)) || '</sup>';
                        cp = cp + 2;
                        call bump_column;
                     end;
                  else
                     do;
                        ncc = map(nart(c));
                        cp = cp + 1;
                        call bump_column;
                     end;
               end;
            else
            if c = byte('/') & as_is_mode = FALSE then
               do;
                  c = next_byte(cp + 1);
                  if c = byte('/') then /* double slash */
                     do;
                        ncc = map(nart(byte('/')));
                        cp = cp + 2;
                        call bump_column;
                     end;
                  else
                  if valid_text_command then
                     do;
                        call text_commands(byte('/'));
                     end;
                  else
                     do;
                        ncc = map(nart(byte('/')));
                        cp = cp + 1;
                        call bump_column;
                     end;
               end;
            else
            if special_permit then
               do;
                  /* Implement the limited number of commands
                     that are permitted in AS-IS mode */
                  if c = byte('/') then call text_commands(c);
                  else call text_commands(byte(' '));
               end;
            else
            if paren_mode then
               do;
                  call text_commands(byte(' '));
               end;
            else
            if c = "AC" then /* EBCDIC logical not */
               do;
                  if next_byte(cp + 1) = UNDERLINE then
                     do;
                        ncc = map(nart(byte('_')));
                        cp = cp + 2;
                     end;
                  else
                     do;
                        ncc = '&nbsp;';
                        cp = cp + 1;
                     end;
                  auto_break = 0;
                  shift_next = FALSE;
               end;
            else
            if c = byte(' ') | c = TAB then
               do;
                  if length(line) < 1 then eat_blanks = 0;
                  else
                     do;
                        v = byte(line, length(line) - 1);
                        if ctype(v) ^= 0 then eat_blanks = 0;
                     end;
                  if (eat_blanks | suppression_mode) ^= 0 then
                     do;
                        cp = cp + 1;
                        ncc_columns = 0;
                     end;
                  else
                     do;
                        ncc = map(nart(byte(' ')));
                        cp = cp + 1;
                     end;
                  if as_is_mode = FALSE then call deblank;
                  shift_next = first_mode;
               end;
            else
            if c = "C2" then /* Mystery Character */
               do;
                  /* The purpose of this character is unclear.  It might have
                  been inserted by the text editor as a prefix to UTF-8.
                  None of the Word Format files in the MTS release use
                  this character for anything.  In any case it is ignored.
                  */
                  cp = cp + 1;
               end;
            else
               do;
                  if uppercase_mode | shift_next then c = uc(c);
                  ncc = map(nart(c));
                  if und(c) = byte('/') then ncc = ncc || '&#824;';
                  cp = cp + 1;
                  call bump_column;
               end;

            if html_table > 0 & td < tdmax then
               do;
                  if as_is_mode then
                     do;
                        call html_set_column(col);
                     end;
                  else
                  if length(ncc) > 0 & td < 2 then
                     do;
                        call html_line_start(2);
                     end;
               end;

            /* Process look aheads */
            c = next_byte(cp);
            if c = UNDERLINE & length(ncc) > 0 then
               do;
                  if ncc = ' ' | ncc = '&nbsp;' then
                     do;
                        ncc = map(nart(byte('_')));
                        cp = cp + 1;
                     end;
                  else
                  if ncc ^= '_' & ncc ^= map9A & underline_mode = FALSE then
                     do;
                        ncc = '<u>' || ncc || '</u>';
                        cp = cp + 1;
                     end;
               end;
            /* Repeat is done after underline so that the underline can be repeated. */
            last_character = ncc;
            if length(ncc) > 0 then
               do;
                  col = col + ncc_columns;
                  line = line || ncc;
               end;
         end;

      if html_table = HTML_BOX_MODE then
         do;
            if as_is_mode then
               do;
                  if tdmax > 2 then
                     do;
                        if td < tdmax then 
                           do;
                              call html_finish_line('<br></td></tr>');
                           end;
                        else line = line || '</td></tr>';
                        td = 0;
                        col = 1;
                     end;
               end;
         end;
   end text_data;

/*
**  nested_text_data
**
**  This function is called to scan the text looking for /E/ commands
**  that will disable nested text.  AS-IS mode is not permitted.
*/
nested_text_data:
   procedure;
      declare (c, state, wcc) fixed;

      state = 0;
      wcc = byte(' ');
         do while cp <= text_limit;
            c = byte(text, cp);
            if c = byte('/') & super_mode = TRUE then
               do;
                  /* Flip the state */
                  state = (state + 1) & 1;
               end;
            else
            if wcc = byte(' ') & c = byte(')') then
               do;
                  /* Flip the state */
                  state = (state + 1) & 1;
               end;
            else
            if (vcc(c) & VCC_COMMAND) = 0 then state = 0;
            else
            if uc(c) = byte('E') & state = 1 then
               do;
                  /* End of nested text marker */
                  mode = COMMAND_MODE;
                  return;
               end;
            wcc = c;
            cp = cp + 1;
         end;
   end nested_text_data;

/*
**  test_nested_text
**
**  Test driver for the function nested_text_data.
*/
test_nested_text:
   procedure(m, s);
      declare m fixed,
         s character;

      mode = FIGURE_MODE;
      super_mode = m;
      text = s;
      text_limit = length(text) - 1;
      cp = 0;
      call nested_text_data;
      output = 'super_mode=' || super_mode || ' mode=' || mode || x1 || s;
   end test_nested_text;

/*
**  translate_input
**
**  Implement TRANSLATE INPUT, LOWERCASE and KEYPUNCH commands.
**
**  LOWERCASE and KEYPUNCH commands will translate alphabetics to lowercase.
**  The TRANSLATE INPUT command can remap individual letters to a
**  different character.
*/
translate_input:
   procedure;
      declare s character,
         c fixed;

      s = 'x';
         do cp = 0 to text_limit;
            c = byte(text, cp);
            s = s || x1;
            byte(s, cp) = tnt(c);
         end;
      text = substr(s, 0, text_limit + 1);
      cp = 0;
   end translate_input;

/*
**  convert_file
*/
convert_file:
   procedure;
      hold = '<!DOCTYPE html>';
      call output_string('<html>');
      call output_string('<body>');
      if fixed_pitch_option then call output_string('<tt>');
      counter, mac = -1;
      reading = 1;
         do while reading;
            pop_macro:
            if mac < 0 then
               do;
                  line_number = line_number + 1;
                  buffer = input(source_unit);
                  call translate_input;
                  if mode = TEXT_MODE then
                     do i = 0 to length(buffer) - 1;
                        byte(buffer, i) = tran(byte(buffer, i));
                     end;
               end;
            else
            if mp(mac) < mend(mac) then
               do;
                  buffer = macro_expand(mac);
                  mp(mac) = mp(mac) + 1;
               end;
            else
            if length(resume_text(mac)) > 0 then
               do;
                  buffer = resume_text(mac);
                  resume_text(mac) = '';
               end;
            else
               do;
                  mac = mac - 1;
                  goto pop_macro;
               end;

            if mix_option then call output_string('---> ' || buffer);

            text = buffer;
            text_limit = length(text) - 1;
            cp = 0;
            if text_limit < 0 then reading = 0;
            else
            if mode = COMMAND_MODE then /* Control Phrases */
               do;
                  call control_phrase;
               end;
            else
            if mode = TEXT_MODE then /* Text */
               do;
                  call text_data;
                  if as_is_mode then call output_line;
                  else
                  if length(line) > 0 & eat_blanks = 0 then
                     do;
                        call output_line;
                     end;
               end;
            else
            if mode = MACRO_MODE then /* Building a macro body */
               do;
                  if (vcc(byte(text)) & VCC_VBAR) ^= 0 then
                     do;
                        if mac_body_top >= LAST_MACRO_BODY then
                           do;
                              call error('Macro body overflow');
                              reading = 0;
                           end;
                        else
                           do;
                              mac_body(mac_body_top) = substr(text, 1);
                              mac_body_index(mac_top),
                              mac_body_top = mac_body_top + 1;
                           end;
                     end;
                  else
                     do;
                        mode = COMMAND_MODE;
                        call control_phrase;
                     end;
               end;
            else
            if mode = BODY_COUNT_MODE then /* Building a macro body */
               do;
                  if mac_body_count > 0 then
                     do;
                        mac_body_count = mac_body_count - 1;
                        if mac_body_top >= LAST_MACRO_BODY then
                           do;
                              call error('Macro body overflow');
                              reading = 0;
                           end;
                        else
                           do;
                              mac_body(mac_body_top) = text;
                              mac_body_index(mac_top),
                              mac_body_top = mac_body_top + 1;
                           end;
                     end;
                  else
                     do;
                        mode = COMMAND_MODE;
                        call control_phrase;
                     end;
               end;
            else
               do;
                  /* TITLE and FOOTER statements come here */
                  call nested_text_data;
               end;
         end;
      if length(line) > 0 then call output_line;
      call output_string('</body>');
      call output_string('</html>');
      call output_string('');  /* Flush out the last line */
      if macro_option then
         do i = 0 to mac_top - 1;
            output = mac_name(i);
               do j = mac_body_index(i) to mac_body_index(i + 1) - 1;
                  output = '   ''' || mac_body(j) || '''';
               end;
         end;
   end convert_file;

/*
**  initialization
**
**  Initialize internal data structures.
*/
initialization:
   procedure;
      declare s character,
         vcc_asis character initial('Uu-@'),
         extra_letters character initial('.'),
         c fixed;

      do i = 0 to 15;
         s = '';  /* 0 thru 15 binary character strings */
            do j = 0 to 3;
               if (shl(i, j) & 8) = 8 then s = s || '1';
               else s = s || '0';
            end;
         bs(i) = s;
      end;
      string = x1;
         do i = 0 to 255;
            string = substr(string || x1, 1);
            byte(string) = i;
            map(i) = string;
            uc(i) = i;
            tran(i), nart(i) = i;
         end;
      map9A = map("9A");
         do i = 0 to length(lc_letters) - 1;
            j = byte(lc_letters, i);
            k = byte(uc_letters, i);
            uc(j) = k;
            vcc(j), vcc(k) = VCC_COMMAND | VCC_ALPHA;
            ctype(j), ctype(k) = 2;
         end;
      ctype(byte(' ')), ctype(TAB) = 1;
         do i = 0 to 9;
            j = byte('0') + i;
            ctype(j) = 3;
            vcc(j) = VCC_COMMAND | VCC_NUMERIC;
         end;
      ctype(byte('''')) = 4;
      vcc(CENT), vcc(byte('@')), vcc(byte('-')) = VCC_COMMAND;
      /* Mark command letters permitted in AS-IS mode */
      do i = 0 to length(vcc_asis) - 1;
         j = byte(vcc_asis, i);
         vcc(j) = vcc(j) | VCC_ASIS;
      end;
      vcc(byte('|')), vcc(byte('!')) =
         VCC_COMMAND | VCC_VBAR | VCC_VBAR_SPACE;
      vcc(byte(' ')) = vcc(byte(' ')) | VCC_VBAR_SPACE;
      /* Extended <identifier> characters */
         do i = 0 to length(extra_letters) - 1;
            j = byte(extra_letters, i);
            vcc(j) = vcc(j) | VCC_EXTENDED;
         end;
      /* Characters that can be superscripted with @ */
         do i = 0 to length(super_letters) - 1;
            j = byte(super_letters, i);
            vcc(j) = vcc(j) | VCC_SUPER;
         end;

      /* Translate underbar to "9A" so that the following
         will disable underlining:
            TRAN IN '_' '_'
         Then this command will restore normal behaviour:
            TRAN IN '_' 9A
      */
      tran(byte('_')) = UNDERLINE;

      /* Output character translation map (Required by HTML) */
      map(byte('''')) = '&apos;';
      map(byte('"')) = '&quot;';
      map(byte('&')) = '&amp;';
      map(byte('<')) = '&lt;';
      map(byte('>')) = '&gt;';

      /* Tilde is alternate character for EBCDIC logical NOT */
      map(byte('~')) = '&nbsp;';

      /* EBCDIC characters that were not translated */
      map("14") = '&boxvl;';  /* Right Join */
      map("1E") = '&mp;';  /* Field Mark */
      map("8B") = '&boxvr;';  /* Left Join */
      map("8C") = '&boxhd;';  /* Top Join */
      map(UNDERLINE) = '_';  /* 9A - Underscore */
      map("9B") = '&boxhu;';  /* Bottom Join */
      map("A1") = '~';  /* Tilde - (might not be right) */
      map(CENT) = '&cent;';  /* A2 - Cent sign */
      map("A4") = '&squf;';  /* Filled box */
      map("A8") = ']';
      map("AA") = '`';
      map("AC") = '&not;';  /* Logical not */
      map("AE") = '&bullet;';  /* Filled circle */
      map("AF") = '&boxdl;';  /* Upper right corner */
      map("B1") = '&boxvh;';  /* Intersection */
      map("B4") = '&ne;'; /* Not equal */
      map("BA") = '}';
      map("BB") = '{';
      map("BF") = '&boxur;';  /* Lower left corner */
      map("C6") = '&plusmn;'; /* Plus or minus */
      map("D0") = '&boxdr;';  /* Upper left corner */
      map("D7") = '&boxh;';  /* hyphen (Box horizontal) */
      map("DD") = '[';
      map("DE") = '&ge;'; /* Greater than or equal to */
      map("E6") = '&squ;';  /* Open box */
      map("F0") = '&le;'; /* Less than or equal to */
      map(BOXUL) = '&boxul;';  /* Lower right corner */
  
      /* Translation map for when TRANSLATE is used with a hex value */
         do i = 0 to 15;
               do j = 0 to 15;
                  k = shl(i, 4) + j;
                  c = byte(code_page(i), j);
                  if c = byte(' ') then tnt(k) = k;
                  else tnt(k) = c;
               end;
         end;
      tnt("40") = byte(' ');
      tnt("8C") = "F0"; /* Less than or equal to */
      tnt("AE") = "DE"; /* Greater than or equal to */
      tnt("9E") = "C6"; /* Plus or minus */
      tnt("BE") = "B4"; /* Not equal */
      tnt("BF") = "D7"; /* hyphen (Box horizontal) */
      tnt("9C") = "E6"; /* Open box */
      tnt("9F") = "A4"; /* Filled box */
      tnt("AF") = "AE"; /* Filled circle */
      tnt("5F") = "AC"; /* Logical not */
      tnt("4A") = CENT; /* Cent sign */
      tnt("2B") = "8B"; /* Left join */
      tnt("2C") = "8C"; /* Top join */
      tnt("3B") = "9B"; /* Bottom join */
      tnt("3C") = "14"; /* Right join */
      tnt("8F") = "B1"; /* Intersection */
      tnt("AB") = "BF"; /* Lower left corner */
      tnt("AC") = "D0"; /* Upper left corner */
      tnt("BB") = BOXUL; /* Lower right corner */
      tnt("BC") = "AF"; /* Upper right corner */

      default_vcc_ident, vcc_ident = VCC_IDENTIFIER;
      super_mode = TRUE;
      paragraph_indent = 5;
      paragraph_separation = 2;
      indent_level, hanging_indent = 0;
      mode = COMMAND_MODE;
      page_width = 64;
      col = 1;
      columns = 1;
   end initialization;

/*
**   Print a brief description of how to use the program.
*/
usage:
   procedure;
      output(1) = 'Usage: ' || argv(0) || ' [-tx] [<source-file>] [-o <html-file>]';
      output(1) = '   <source-file>   -  Input FORMAT file (if missing, use STDIN)';
      output(1) = '   -o <html-file>  -  Output HTML file (if missing, use STDOUT)';
      output(1) = '   -t              -  Teletype mode.  Fixed pitch font';
      output(1) = '   -c              -  Count start/stop pairs(debug mode)';
      output(1) = '   -m              -  Display macro definitions(debug mode)';
      output(1) = '   -x              -  Mix source with output(debug mode)';
      output(1) = 'Convert MTS FORMAT text files to HTML';
   end usage;

call initialization;
source_unit = 0;
output_unit = 0;
do i = 1 to argc - 1;
   j = byte(argv(i));
   if j ^= byte('-') then
      do;
         source_unit = xfopen(argv(i), 'r');
         if source_unit < 0 then
            do;
               output(1) = 'Open file error: ' || argv(i);
               call usage;
               return 1;
            end;
      end;
   else
   if argv(i) = '-o' then
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
      do k = 1 to length(argv(i)) - 1;
         j = byte(argv(i), k);
         if j = byte('c') then count_option = 1;
         else
         if j = byte('m') then macro_option = 1;
         else
         if j = byte('t') then fixed_pitch_option = 1;
         else
         if j = byte('x') then mix_option = 1;
         else
            do;
               output(1) = 'Unknown option: ' || argv(i);
               call usage;
               return 1;
            end;
      end;
end;
call convert_file;
if count_tbody ^= 0 then output(1) = count_tbody || ' extra <tbody>';
if count_div ^= 0 then output(1) = count_div || ' extra <div> at line: '
   || count_start_div;
if count_td ^= 0 then output(1) = count_td || ' extra <td> at line: '
   || count_start_td;
if count_tr ^= 0 then output(1) = count_tr || ' extra <tr> at line: '
   || count_start_tr;
if count_p ^= 0 then output(1) = count_p || ' extra <p> at line: '
   || count_start_p;
eof eof
