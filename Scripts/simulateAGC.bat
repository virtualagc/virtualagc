@echo off
REM This batch file was generated from the BASH shell-script `simulateAGC`
REM using the "bash shell to bat converter" found at
REM https://github.com/daniel-sc/bash-shell-to-bat-converter.  In its current
REM state of development, the converter worked well except that:
REM  1. It was entirely unable to deal correctly with any pipes.
REM  2. It could not handle FOR-loops.
REM Of which I had plenty!  To eliminate most of the rework resulting from the
REM inability to handle FOR-loops, I've devised a workaround, fully described at
REM https://github.com/daniel-sc/bash-shell-to-bat-converter/issues/58.
REM Workarounds of a similar nature I developed for poor piping are found here:
REM https://github.com/daniel-sc/bash-shell-to-bat-converter/issues/72.

REM Script for digital simulation of an AGC CPU.  The command-line arguments,
REM all optional, appear in the following order:
REM       MODEL           The AGC model.  In principle, only 1003565, 1003700,
REM                       2003100, 2003200, or 2003993.  Presently, only
REM                       2003200 or 2003993.  Defaults to 2003993, if missing
REM                       or .
REM       SOFTWARE        AGC software to run on the simulated CPU.  Defaults
REM                       to Validation-hardware-simulation if missing or .
REM       VERILOGPARMS    Parameters for iverilog compilation.  Multiple 
REM                       parameters are separated by spaces and the entire
REM                       set of parameters should be quoted.  This script 
REM                       accepts these as-is, and performs no check of 
REM                       correctness.  The default is -DDUMP_ALL
REM                       if missing or .  The known optional useful parameters 
REM                       are:

REM                       -Pagc.RUNLENGTH
REM                               which overrides the total runtime of the 
REM                               simulation.  The default is 1/4 second.
REM                       -DSPOOF_SC, spoofs certain input signals from the 
REM                               spacecraft.
REM                       -DDUMP_ALL, which means that all signals are dumped to
REM                               the logged simulation datafile.
REM                       -DUMP_BACKPLANE, which means that all backplane signals
REM                               are dumped.
REM                       -DUMP_DECODER, which means to dump all of the variables
REM                               used by the instruction-decoder circuitry.
REM                       -DUMP_HELPFUL, which means to dump all helpful signals.
REM                       
REM                       These switches are all interpreted by the test-bench 
REM                       file tb_xxxx.v where xxxx represents the AGC model 
REM                       number.  At present, though, tb_xxxx.v requires that
REM                       exactly one of the DUMP_xxxx options be present.

SET "extension=kicad_sch"

SET "PYTHONPATH=%PATH%"

REM Parse command line and perform sanity checks.

IF "%~1" == "" (
  SET "model=2003993"
  SET "sameAs=2003993"
) ELSE (
  IF "%~1" == "2003993" (
    SET "model=%~1"
    SET "sameAs=2003993"
  ) ELSE (
    IF "%~1" == "2003200" (
      SET "model=%~1"
      SET "sameAs=2003200"
    ) ELSE (
      IF "%~1" == "2003100" (
        SET "model=%~1"
        SET "sameAs=2003100"
        echo Model not yet supported.
        EXIT /b 1
      ) ELSE (
        IF "%~1" == "1003700" (
          SET "model=%~1"
          SET "sameAs=1003700"
          echo Model not yet supported.
          EXIT /b 1
        ) ELSE (
          IF "%~1" == "1003565" (
            SET "model=%~1"
            SET "sameAs=1003700"
            echo Model not yet supported.
            EXIT /b 1
          ) ELSE (
            echo Unrecognized AGC model number.
            EXIT /b 1
          )
        )
      )
    )
  )
)
IF "%model%" == "%sameAs%" (
  echo AGC model: %model%
) ELSE (
  echo AGC model: %model% (same as %sameAs%)
)
IF "%sameAs%" == "2003993" (
  REM Schematic drawings for logic modules A1-A24.
  SET "modules="
  SET "modules=%modules% 2005259A"
  SET "modules=%modules% 2005260A"
  SET "modules=%modules% 2005251A"
  SET "modules=%modules% 2005262A"
  SET "modules=%modules% 2005261A"
  SET "modules=%modules% 2005263A"
  SET "modules=%modules% 2005252A"
  SET "modules=%modules% 2005255-"
  SET "modules=%modules% 2005256A"
  SET "modules=%modules% 2005257A"
  SET "modules=%modules% 2005258A"
  SET "modules=%modules% 2005253A"
  SET "modules=%modules% 2005269-"
  SET "modules=%modules% 2005264B"
  SET "modules=%modules% 2005265A"
  SET "modules=%modules% 2005266-"
  SET "modules=%modules% 2005267A"
  SET "modules=%modules% 2005268A"
  SET "modules=%modules% 2005270-"
  SET "modules=%modules% 2005254-"
  SET "modules=%modules% 2005250-"
  SET "modules=%modules% 2005271-"
  SET "modules=%modules% 2005272A"
  SET "modules=%modules% 2005273A"
)
IF "%sameAs%" == "2003200" (
  REM Schematic drawings for logic modules A1-A24, A52.
  SET "modules="
  SET "modules=%modules% 2005259A"
  SET "modules=%modules% 2005260A"
  SET "modules=%modules% 2005251A"
  SET "modules=%modules% 2005262A"
  SET "modules=%modules% 2005261A"
  SET "modules=%modules% 2005263A"
  SET "modules=%modules% 2005252A"
  SET "modules=%modules% 2005255-"
  SET "modules=%modules% 2005256A"
  SET "modules=%modules% 2005257A"
  SET "modules=%modules% 2005258A"
  SET "modules=%modules% 2005253A"
  SET "modules=%modules% 2005269-"
  SET "modules=%modules% 2005264A"
  SET "modules=%modules% 2005265A"
  SET "modules=%modules% 2005266-"
  SET "modules=%modules% 2005267A"
  SET "modules=%modules% 2005268A"
  SET "modules=%modules% 2005270-"
  SET "modules=%modules% 2005254-"
  SET "modules=%modules% 2005250-"
  SET "modules=%modules% 2005271-"
  SET "modules=%modules% 2005272A"
  SET "modules=%modules% 2005273A"
  SET "module52=2003305B"
)

REM Workflow Step #1:
echo Checking existence of all schematic diagrams needed ...
FOR %%d IN ( %modules% %module52% ) DO (
  IF NOT exist %%d/module.%extension% (
    echo Schematic %%d/module.%extension% does not exist
    EXIT /b 1
  )
)

IF "%~2" == "" (
  SET "software=Validation-hardware-simulation"
) ELSE (
  SET "software=%~1"
)
echo AGC software: %software%
IF NOT exist roms\%software%.v (
  echo Selected AGC software version has no Verilog source-code file.
  EXIT /b 1
)

REM Workflow Step #2:
SET "autonet=0"
IF "%extension%" == "kicad_sch" (
  SET "autonet=1"
)
IF "%autonet%" == "1" (
  echo Generating netlist files ...
  REM kicad-cli does exist.
  FOR %%d in ( %modules% %module52% fixed_erasable_memory ) DO (
    cd %%d > NUL 2>&1
    kicad-cli sch export netlist --output module.net --format orcadpcb2 module.kicad_sch
    cd .. > NUL 2>&1
  )
) ELSE (
  echo Checking existence of netlist files ...
  REM kicad-cli not found.  The netlist files must pre-exist.
  FOR %%d in ( %modules% %module52% fixed_erasable_memory ) DO (
    IF NOT exist %%d\module.net (
      echo Netlist %%d\module.net does not exist.
      EXIT /b 1
    )
  )
)

REM Workflow Step #3:
echo Generation of flip-flop initialization file ...

SET "n=0"
DEL  dummy.v > NUL 2>&1
FOR %%d IN ( %modules% %module52% fixed_erasable_memory ) DO (
  IF "%%d" == "fixed_erasable_memory" (
    SET "n=99"
  ) ELSE (
    IF "%n%" == "24" (
      SET "n=52"
    ) ELSE (
      SET /A "n=n+1"
    )
  )
  echo Initial Verilog creation for A%n% %%d ...
  cd %%d > NUL 2>&1
  DEL  empty.init > NUL 2>&1
  touch empty.init
  python -m dumbVerilog A%n% module.net pins.txt 20 empty.init module.%extension% >> %CD%\..\dummy.v
  cd .. > NUL 2>&1
)

echo Flip-flop initilizer creation ...
python -m dumbInitialization < dummy.v

SET "n=0"
FOR %%d in ( %modules% %module52% fixed_erasable_memory ) DO (
  IF %%d == fixed_erasable_memory (
    SET "n=99"
  ) ELSE (
    IF %n% == 24 (
      SET "n=52"
    ) ELSE (
      SET /A "n=n+1"
    )
  )
  echo Final Verilog creation for A%n% %%d ...
  cd %%d > NUL 2>&1
  COPY  ../A%n%.init module.init
  python -m dumbVerilog A%n% module.net pins.txt 20 module.init module.%extension% > module.v
  cd .. > NUL 2>&1
)

REM Workflow step #4
echo Generation of testbench object-definition file ...
COPY  tb-%model%.v tb.v
python -m dumbTestbench < dummy.v > %model%_tb.v

REM Workflow step #5
echo Setup of erasable/fixed memory Verilog source code ...
COPY  roms\%software%.v roms\rom.v

REM Workflow step #6
echo Compiling Verilog source code ...
IF "%~3" == "" (
  SET "verilogOptions=-DDUMP_ALL"
) ELSE (
  SET "verilogOptions=%~3"
)
SET "vsources="
FOR %%f in ( %modules% %module52% fixed_erasable_memory ) DO (
  SET "vsources=%vsources% %%f/module.v"
)
iverilog %verilogOptions% -o %model%.vvp %model%_tb.v %vsources% fixed_erasable_memory\RAM.v fixed_erasable_memory\ROM.v fixed_erasable_memory\BUFFER.v

REM Workflow step #7
echo Performing simulation ...
vvp %model%.vvp -fst
REM mv agc.fst %model%.fst

REM Workflow step #8
echo Simulation-results data visualization ...
REM gtkwave %model%.fst
gtkwave agc.gtkw