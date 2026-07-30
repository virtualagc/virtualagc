This directory contains `yaGPC2`, a C-language emulator for the AP-101S CPU (the Shuttle GPC). It began as a fork of `yaGPC` — itself a byte-for-byte-faithful C port of `gpc run`, a mode of the Javascript program `gpc` from the `nsts-sim-gpc` repository — but unlike `yaGPC`, `yaGPC2`'s explicit purpose is to **fix** the bugs and omissions it inherited from `gpc`/`yaGPC`, not to reproduce them. See `problems.md` for the full list of bugs found and their fix status.

`yaGPC2` also aims for output parity with a separate, independently-developed HALMAT bytecode interpreter, `yaHALMAT2` (`../yaHALMAT2/`) — specifically, byte-identical `WRITE`/`FILE` output for the same compiled HAL/S program. (An earlier goal of also matching `yaHALMAT2`'s command-line-option surface was considered and dropped as impractical; `yaGPC2` uses its own command-line conventions, inherited from `yaGPC`/`gpc run`.)

This port was created using Claude Sonnet 5, under direction. The initial `yaGPC` port worked the first time it was tried, without modification. All code was written by Claude.

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
To use, get `yaGPC2` or `yaGPC2.exe` into your `PATH`, and simply replace the commands "`gpc run ...`" that you would otherwise use with "`yaGPC2 ...`".

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
Running it instead with `yaGPC2` produces byte-identical output (this particular example doesn't happen to exercise any of the bugs `yaGPC2` fixes relative to `gpc`/`yaGPC` — see `problems.md` for programs that do):
<pre>
&gt; <span style="color: brown">yaGPC2 --interactive --no-trace --no-verbose --symbols HELLO-lnk101.json HELLO.fcm</span>
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

