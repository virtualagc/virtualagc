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
 * Registers a language handler for the AEA Assembly Language.
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
	[PR.PR_KEYWORD, /^(?:ADD|ADZ|SUB|SUZ|MPY|MPR|MPZ|DVP|COM|ABS|CLA|CLZ|LDQ|STO|STQ|ALS|LLS|LRS|TRA|TSQ|TMI|TOV|AXT|TIX|DLY|INP|OUT)\b/,null],
	[PR.PR_TYPE, /^(?:ORG|BSS|BES|SYN|EQU|DEFINE|DEC|OCT|END)\b/,null],
         [PR.PR_LITERAL,
          /^[+\-]?(?:0x[0-9a-f]+|E[0-9]+|\d+\/\d+|(?:\.\d+|\d+(?:\.\d*)?)(?:[ed][+\-]?\d+)?)/i],
         // A single quote possibly followed by a word that optionally ends with
         // = ! or ?.
         [PR.PR_LITERAL,
          /^\'(?:-*(?:\w|\\[\x21-\x7e])(?:[\w-]*|\\[\x21-\x7e])[=!?]?)?/],
         // A word that optionally ends with = ! or ?.
         [PR.PR_PLAIN,
          /^-*(?:[a-z_]|\\[\x21-\x7e])(?:[\w-]*|\\[\x21-\x7e])[=!?]?/i],
         // A printable non-space non-special character
         [PR.PR_PUNCTUATION, /^[^\w\t\n\r \xA0()\"\\\';]+/]
        ]),
    ['aea']);
