#
#  Compile the PASCAL compiler using the ASCII version of the XPL compiler.
#
I0=-i0
XPLFLAGS=-Y
#XPLFLAGS=-YDL
#XCOM= -i2 xplib.xpl -f2w+ /tmp/data.tmp -f3w+ /tmp/string.tmp $(XPLFLAGS) ../backup.out
XCOM= -i2 xplib.xpl -f2w+ /tmp/data.tmp -f3w+ /tmp/string.tmp $(XPLFLAGS) ../xpl.out

all: xpl.out pass1.out pass2.out pass3.out pmd.out

pass1.out: pass1.xpl
	../sim360 $(I0) pass1.xpl -f1w+ pass1.out $(XCOM)

pass2.out: pass2.xpl
	../sim360 $(I0) pass2.xpl -f1w+ pass2.out $(XCOM)

pass3.out: pass3.xpl
	../sim360 $(I0) pass3.xpl -f1w+ pass3.out $(XCOM)

pmd.out: pmd.xpl
	../sim360 $(I0) pmd.xpl -f1w+ pmd.out $(XCOM)

xpl.out: xcom4.xpl
	../sim360 $(I0) xcom4.xpl -f1w+ xpl.out $(XCOM) && cp xpl.out ..
#	../sim360 $(I0) xcom4.xpl -f1w+ xpl.out $(XCOM)

new:	xcom4.xpl
	../sim360 -v $(I0) xcom4.xpl -f1w+ zz.out -i2 xplib.xpl -f2w+ /tmp/data.tmp\
		-f3w+ /tmp/string.tmp $(XPLFLAGS) xpl.out && mv zz.out xpl.out

xplxref.out: xplxref.xpl
	../sim360 $(I0) xplxref.xpl -f1w+ xplxref.out $(XCOM)

clean:
	rm -f *.obj *.out

