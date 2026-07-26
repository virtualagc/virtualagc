This directory contains a C-language port of `gpc` (only the mode `gpc run`) from the original Javascript implementation in repository nsts-sim-gpc. `yaGPC` is intended to be a 100% identical drop-in, using identical command-line arguments and input files, and producing 100% byte-for-byte identical outputs. It is not intended to be a replacement as such for `gpc run`, although there are some advantages in terms of resource savings in using it.

No bugs in `gpc` have been fixed in `yaGPC`, nor have any missing features been added. Rather, it's intended that a forthcoming program, `yaGPC2`, not in this repository, will handle issues of that nature. The purpose for `yaGPC` is to act as a stepping-stone towards implementation of `yaGPC2`. With that said, future fixes in nsts-sim-gpc may nevertheless be incorporated into `yaGPC` over time if it appears anyone would find it valuable to do so.

This port was created using Claude Sonnet 5, under direction.  The initial port worked the first time it was tried, without modification.  All code was written by Claude.

To build:
<pre>
# In Linux, Mac OS, or Windows under MSYS2:
make
</pre>
or
<pre>
# In Windows:
nmake /v NMakefile
</pre>
To use, get `yaGPC` or `yaGPC.exe` into your `PATH`, and simply replace the commands "`gpc run ...`" that you would otherwise use with "`yaGPC ...`".

Example: Consider the HAL/S program
<pre>
 HELLO: PROGRAM;
  DECLARE I INTEGER;
    DECLARE POOKIE CHARACTER(20);
    DECLARE MY_NAME CHARACTER(20) INITIAL('RON BURKEY');
    DECLARE INTEGER, J;
    REPLACE PRINTER BY "6";
    WRITE(PRINTER) 'THE BEGINNING';
    DO FOR I = 1 TO 5;
       WRITE(PRINTER) I, 'HELLO, WORLD!';
       DO FOR J = 2 TO 8 BY 2;
          WRITE(PRINTER) '     ', J, MY_NAME||' SAYS ISN''T THIS FUN?';
       END;
    END;
    WRITE(6) 'THE END';
 CLOSE HELLO;
</pre>
Compiling, linking, and then running with `gpc run` gives the following results:
<pre>
&gt; <span style="color: brown">HALSFC HELLO.hal -o HELLO.obj --test --force --clean --archive</span>
&gt; <span style="color: brown">lnk101 HELLO.obj -o HELLO.fcm --json-symbols HELLO-lnk101.json</span>
&gt; <span style="color: brown">gpc run --interactive --no-trace --no-verbose --symbols HELLO-lnk101.json HELLO.fcm</span>
THE BEGINNING
          1     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
          2     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
          3     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
          4     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
          5     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
THE END

*** HAL/S PROGRAM HALT (SVC 0)
</pre>
Whereas running it instead with `yaGPC` produces
<pre>
&gt; <span style="color: brown">yaGPC --interactive --no-trace --no-verbose --symbols HELLO-lnk101.json HELLO.fcm</span>
THE BEGINNING
          1     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
          2     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
          3     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
          4     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
          5     HELLO, WORLD!
                    2     RON BURKEY SAYS ISN'T THIS FUN?
                    4     RON BURKEY SAYS ISN'T THIS FUN?
                    6     RON BURKEY SAYS ISN'T THIS FUN?
                    8     RON BURKEY SAYS ISN'T THIS FUN?
THE END

*** HAL/S PROGRAM HALT (SVC 0)
</pre>

