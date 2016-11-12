# Copyright 2016 Mike Stewart <mastewar1@gmail.com>
#  
# This file is part of yaAGC. 
#
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# Filename:	Interrupts.agc
# Purpose:	This file holds interrupt handlers and tests of interrupts
#               for the validation suite.
# Mod history:	11/12/16 MAS.	Created as a start for interrupt checks.

            BLOCK   02
T3RUPT      CAF     O37774      # Schedule another TIME3 interrupt
            TS      TIME3       # ... and don't do anything else, yet...

RESUME      DXCH    ARUPT       # Restore A, L, and Q, and exit the interrupt
            EXTEND
            QXCH    QRUPT
            RESUME
