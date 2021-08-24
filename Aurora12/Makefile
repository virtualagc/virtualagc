# Copyright:	Public domain.
# Filename:	Makefile
# Purpose:	Makefile for Aurora (revision 12).
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	http://www.ibiblio.org/apollo
# Mod history:	2016-09-20 JL	Adapted from similar Luminary 099 Makefile.
#		2016-10-04 JL	Change to use Makefile.inc.
#		2016-10-05 JL	Pass --blk2 to yaYUL.
#		2016-10-05 JL	Pass --syntax to yaYUL for proofing.
#		2016-10-21 RSB	Changed to "production" settings.
#		2017-01-30 MAS	Removed cruft and changed EXTRA_YAYUL_ARGS to +=
#		2017-06-17 MAS	Added --early-sbank (which isn't actualyl needed,
#				but is more "accurate" to use).
#		2017-06-18 MAS	Removed --flip=7, since this is now handled by
#				--blk2.
#		2021-04-20 RSB	Added --honeywell.

BASENAME=Aurora12
EXTRA_YAYUL_ARGS+=--blk2 --early-sbank --honeywell

include ../Makefile.inc
