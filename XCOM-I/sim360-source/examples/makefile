#
#	Pascal test programs
#

.SUFFIXES: .pas .out

.pas.out:
	../sim360 -i0 $< @pascal.rc
	cat code.obj org.obj data.obj > $@

# Use the following option to write the output to a file:  -o0 zzl
soma: soma.out
	../sim360 -o0 zzl soma.out @pmd.rc

all:  ancest ancestor count knuth palindro passproc powers primes qsort queens soma

ancest.out: ancest.pas
ancestor.out: ancestor.pas
count.out: count.pas
knuth.out: knuth.pas
palindro.out: palindro.pas
passproc.out: passproc.pas
powers.out: powers.pas
primes.out: primes.pas
qsort.out: qsort.pas
queens.out: queens.pas
soma.out: soma.pas

ancest: ancest.out
	../sim360 ancest.out @pmd.rc

ancestor: ancestor.out
	../sim360 ancestor.out @pmd.rc

count: count.out
	../sim360 -i0 count.pas count.out @pmd.rc

knuth: knuth.out
	../sim360 -i0 knuth.dat knuth.out @pmd.rc

palindro: palindro.out
	../sim360 palindro.out @pmd.rc

passproc: passproc.out
	../sim360 passproc.out @pmd.rc

powers: powers.out
	../sim360 powers.out @pmd.rc

primes: primes.out
	../sim360 primes.out @pmd.rc

qsort: qsort.out
	../sim360 qsort.out @pmd.rc

queens: queens.out
	../sim360 queens.out @pmd.rc

clean:
	rm -f *.out *.obj zzl
