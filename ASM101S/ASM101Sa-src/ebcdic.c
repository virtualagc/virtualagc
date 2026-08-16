/*
 * License:    This program is declared by its author, Ronald Burkey, to be the
 *             U.S. Public Domain, and may be freely used, modified, or
 *             distributed for any purpose whatever.
 * Filename:   ebcdic.c
 * Purpose:    ASCII/EBCDIC conversion tables.
 * Contact:    info@sandroid.org
 *
 * These are transcribed from asciiToEbcdic.py, which in turn keeps them
 * identical to the tables of the same names in runtimeC.c.  Only printable
 * characters are meaningfully converted.  Note that `~` deliberately becomes
 * 0x5F, "logical NOT", which is what the cp1140 codec gets wrong and why the
 * table exists at all; and that `[` and `]` are 0xAD and 0xBD.
 */

#include "ebcdic.h"

const unsigned char asciiToEbcdic[128] = {
  0x00, 0x01, 0x02, 0x03, 0x37, 0x2D, 0x2E, 0x2F,
  0x16, 0x05, 0x25, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
  0x10, 0x11, 0x12, 0x13, 0x3C, 0x3D, 0x32, 0x26,
  0x18, 0x19, 0x3F, 0x27, 0x1C, 0x1D, 0x1E, 0x1F,
  0x40, 0x5A, 0x7F, 0x7B, 0x5B, 0x6C, 0x50, 0x7D,
  0x4D, 0x5D, 0x5C, 0x4E, 0x6B, 0x60, 0x4B, 0x61,
  0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7,
  0xF8, 0xF9, 0x7A, 0x5E, 0x4C, 0x7E, 0x6E, 0x6F,
  0x7C, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7,
  0xC8, 0xC9, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6,
  0xD7, 0xD8, 0xD9, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6,
  0xE7, 0xE8, 0xE9, 0xAD, 0xFE, 0xBD, 0x5F, 0x6D,
  0x4A, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87,
  0x88, 0x89, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96,
  0x97, 0x98, 0x99, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6,
  0xA7, 0xA8, 0xA9, 0xC0, 0x4F, 0xD0, 0x5F, 0x07,
};

const char ebcdicToAscii[256] = {
  '\x00', '\x01', '\x02', '\x03', ' ', '\x09', ' ', '\x7F',
  ' ', ' ', ' ', '\x0B', '\x0C', '\x0D', '\x0E', '\x0F',
  '\x10', '\x11', '\x12', '\x13', ' ', ' ', '\x08', ' ',
  '\x18', '\x19', ' ', ' ', '\x1C', '\x1D', '\x1E', '\x1F',
  ' ', ' ', ' ', ' ', ' ', '\x0A', '\x17', '\x1B',
  ' ', ' ', ' ', ' ', ' ', '\x05', '\x06', '\x07',
  ' ', ' ', '\x16', ' ', ' ', ' ', ' ', '\x04',
  ' ', ' ', ' ', ' ', '\x14', '\x15', ' ', '\x1A',
  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
  ' ', ' ', '`', '.', '<', '(', '+', '|',
  '&', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
  ' ', ' ', '!', '$', '*', ')', ';', '~',
  '-', '/', ' ', ' ', ' ', ' ', ' ', ' ',
  ' ', ' ', ' ', ',', '%', '_', '>', '?',
  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
  ' ', ' ', ':', '#', '@', '\'', '=', '"',
  ' ', 'a', 'b', 'c', 'd', 'e', 'f', 'g',
  'h', 'i', ' ', ' ', ' ', ' ', ' ', ' ',
  ' ', 'j', 'k', 'l', 'm', 'n', 'o', 'p',
  'q', 'r', ' ', ' ', ' ', ' ', ' ', ' ',
  ' ', ' ', 's', 't', 'u', 'v', 'w', 'x',
  'y', 'z', ' ', ' ', ' ', '[', ' ', ' ',
  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
  ' ', ' ', ' ', ' ', ' ', ']', ' ', ' ',
  '{', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
  'H', 'I', ' ', ' ', ' ', ' ', ' ', ' ',
  '}', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
  'Q', 'R', ' ', ' ', ' ', ' ', ' ', ' ',
  ' ', ' ', 'S', 'T', 'U', 'V', 'W', 'X',
  'Y', 'Z', ' ', ' ', ' ', ' ', ' ', ' ',
  '0', '1', '2', '3', '4', '5', '6', '7',
  '8', '9', ' ', ' ', ' ', ' ', '\\', ' ',
};
