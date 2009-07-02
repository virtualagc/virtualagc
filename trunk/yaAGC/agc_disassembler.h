/*
  Copyright 2003-2006 Ronald S. Burkey <info@sandroid.org>,
  				2008 Onno Hommes

  This file is part of yaAGC.

  yaAGC is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  yaAGC is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with yaAGC; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  In addition, as a special exception, permission is given to
  link the code of this program with the Orbiter SDK library (or with
  modified versions of the Orbiter SDK library that use the same license as
  the Orbiter SDK library), and distribute linked combinations including
  the two. You must obey the GNU General Public License in all respects for
  all of the code used other than the Orbiter SDK library. If you modify
  this file, you may extend this exception to your version of the file,
  but you are not obligated to do so. If you do not wish to do so, delete
  this exception statement from your version.

  Filename:	agc_disassemble.h
  Purpose:	Header file for AGC Disassembler
  Contact:	Onno Hommes
  Reference:	http://www.ibiblio.org/apollo
  Mods:		08/31/08 OH.	Began.
*/

#ifndef AGC_DISASSEMBLE_H_
#define AGC_DISASSEMBLE_H_

extern void Disassemble (agc_t * State);
extern void DasPrintInstructionAtAddr(unsigned short LinearAddress);

#endif /*AGC_DISASSEMBLE_H_*/
