// Copyright (C) 2009 Onno Hommes.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


/**
 * @fileoverview
 * Registers a language handler for the AGC Assembly Language.
 *
 * @author ohommes@cmu.edu
 */

PR.registerLangHandler(
    PR.createSimpleLexer(
        [
         // A line comment that starts with ;
         [PR.PR_COMMENT,     /^#[^\r\n]*/, null, '#'],
         // Whitespace
         [PR.PR_PLAIN,       /^[\t\n\r \xA0]+/, null, '\t\n\r \xA0'],
         // A double quoted, possibly multi-line, string.
         [PR.PR_STRING,      /^\"(?:[^\"\\]|\\[\s\S])*(?:\"|$)/, null, '"']
        ],
        [
	 [PR.PR_KEYWORD, /^(?:ADS|AD|AUG|BZF|BZMF|CAE|CAF|CA|CCS|COM|CS|DAS|DCA|DCOM|DCS|DDOUBL|DIM|DOUBLE|DTCB|DTCF|DV|DXCH|EDRUPT|EXTEND|INCR|INDEX|NDX|INHINT|LXCH|MASK|MSK|MP|MSU|NOOP|OVSK|QXCH|RAND|READ|RELINT|RESUME|RETURN|ROR|RXOR|SQUARE|SU|TCR|TCAA|OVSK|TCF|TC|TS|WAND|WOR|WRITE|XCH|XLQ|XXALQ|ZL|ZQ)\b/,null],
	 [PR.PR_TYPE, /^(?:1DNADR|2DEC|2BCADR|2CADR|2OCT|2DNADR|3DNADR|4DNADR|5DNADR|6DNADR|ADRES|BBCON|BANK|BLOCK|BNKSUM|CADR|COUNT|COUNT*|DEC|DEC*|DNCHAN|DNPTR|EBANK|ECADR|EQUALS|ERASE|MEMORY|OCT|REMADR|SETLOC|SUBRO)\b/,null],
         // A single quote possibly followed by a word that optionally ends with
         // = ! or ?.
         [PR.PR_LITERAL,
          /^\'(?:-*(?:\w|\\[\x21-\x7e])(?:[\w-]*|\\[\x21-\x7e])[=!?]?)?/],
         // Any word including labels that optionally ends with = ! or ?.
         [PR.PR_PLAIN,
          /^-*(?:[!-z_]|\\[\x21-\x7e])(?:[\w-]*|\\[\x21-\x7e])[=!?]?/i],
         // A printable non-space non-special character
         [PR.PR_PUNCTUATION, /^[^\w\t\n\r \xA0()\"\\\';]+/]
        ]),
    ['agc']);
