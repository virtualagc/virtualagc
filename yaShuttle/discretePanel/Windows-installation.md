# Running the Shuttle simulation on Windows

These are the steps for running `simulatePASS.py` and the programs it starts natively on Windows 10 or 11 (64-bit). It does not use WSL. They were worked out on Windows 11 with Python 3.13 and Visual Studio 2022 Build Tools.

You need five things:

1. The repository.
2. `yaGPC2.exe`, the GPC emulator, which you build once.
3. Python, with two extra packages: PyQt6 and numpy.
4. 7-Zip, because the flight-software tapes in the repository are encrypted `.7z` archives.
5. The password for those tapes, which comes from the repository's owner. There are three tapes at increasing levels of access, OPS0 < OPS2 < OPS1, and the password you are given opens the level you are approved for.

The commands below are typed into an ordinary Command Prompt or PowerShell window, unless a step says otherwise. Where a command installs something system-wide, Windows asks for permission first.

## 1. Get the repository

If you have Git:

```
git clone https://github.com/virtualagc/virtualagc.git
```

Otherwise, download it as a ZIP from GitHub and unpack it. The rest of this page assumes it is in `C:\Users\you\git\virtualagc`, so change that path to wherever yours is.

If you do use Git for Windows, keep its line-ending conversion off for this repository:

```
git config --global core.autocrlf false
```

Otherwise it rewrites the shell scripts with Windows line endings, which breaks them for anyone using the same checkout from Linux or WSL.

## 2. Build yaGPC2.exe

The emulator is C and is compiled with Microsoft's free compiler. You don't need all of Visual Studio, just its command-line Build Tools:

```
winget install --id Microsoft.VisualStudio.2022.BuildTools --override "--passive --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
```

That is a download of several gigabytes. Afterwards, open **Developer Command Prompt for VS 2022** from the Start menu and build:

```
cd C:\Users\you\git\virtualagc\yaShuttle\yaGPC2
nmake /f NMakefile
```

This produces `yaGPC2.exe` in that directory, where `simulatePASS.py` looks for it. The build has to be done in the Developer Command Prompt, because that is where the compiler is on the PATH. Running the simulation doesn't need it.

To build and run the emulator's unit tests as well, use `nmake /f NMakefile test` instead.

## 3. Install Python

Install Python 3.12 or later from [python.org](https://www.python.org/downloads/windows/), or with:

```
winget install Python.Python.3.13
```

The python.org installer includes Tk, which the panel, keyboards and CAM use. It also installs the `py` command, which starts whichever Python you installed most recently and is what the commands below use.

Python from the Microsoft Store is not recommended. Typing `python` on a fresh Windows machine may offer to install it, which is that version.

## 4. Install PyQt6 and numpy

The display program, `MEDS2.py`, needs these two packages, which Python does not come with. There are two ways to install them. Either works, and you only need one.

### Method A: the simple way

Install them once into your Python:

```
py -m pip install PyQt6 numpy
```

That's all. Every Python program you run afterwards can use them, and the simulation needs nothing more.

### Method B: a virtual environment

If you'd rather keep this project's packages apart from everything else in your Python, make a virtual environment for it:

```
cd C:\Users\you\git\virtualagc\yaShuttle\discretePanel
py -m venv venv-win
venv-win\Scripts\python.exe -m pip install PyQt6 numpy
```

Then run the simulation with that environment's Python, `venv-win\Scripts\python.exe`, wherever the commands below say `py`. Alternatively, run `venv-win\Scripts\activate` first; after that, `python` means the environment's Python for the rest of that window's session.

Some things to know about this method:

- **Choose a name other than `venv`.** That name is already used by the Linux virtual environment in the same directory, if the checkout is shared with Linux or WSL. The two cannot be mixed.
- **The environment belongs to this computer.** Git ignores it (Python writes a `.gitignore` into it for that purpose), so it is never committed and never downloaded. Each user makes their own.
- **One run, one environment.** `simulatePASS.py` starts every other program with the same Python it is running under, so the displays, panel and keyboards all use the environment automatically.

## 5. Install 7-Zip

The flight-software tapes in `discretePanel` (`OI340700-OPS0.7z`, `-OPS1.7z`, `-OPS2.7z`) are encrypted archives, and the emulator unpacks them with 7-Zip:

```
winget install 7zip.7zip
```

The emulator and `simulatePASS.py` both find 7-Zip in its usual place in Program Files, so it does not have to be on the PATH. The unpacked tape exists only in the emulator's memory and is never written to disk. A plain `.mmv` tape, if you have one, doesn't need 7-Zip.

## 6. Run the simulation

From the `discretePanel` directory:

```
cd C:\Users\you\git\virtualagc\yaShuttle\discretePanel
py simulatePASS.py --tape OI340700-OPS0.7z
```

That asks for the tape's password, then brings up one GPC with one display, keyboard and the crew panel. (`OI340700-OPS0.7z` is also the default, so `--tape` can be left off for that one.) `OI340700-OPS0.7z` holds only the system software (OPS 0). `OI340700-OPS2.7z` adds OPS 2, and `OI340700-OPS1.7z` holds everything, including OPS 1.

To see the switch and keyboard steps for a configuration, without starting anything, add `--instructions`:

```
py simulatePASS.py --gpcs 1,2 --instructions
```

A scripted demonstration, with windows placed from a saved layout, looks like this. It takes five GPCs to OPS 1, so it needs the full tape:

```
py simulatePASS.py --gpcs 1-5 --crts 3 --tape OI340700-OPS1.7z --script examples\5gpc-3crt-subtitled.script --layout examples\5gpc-3crt-subtitled.layout --size 384 --scale 0.8
```

A scripted run waits for a click in the Panel window before it starts. Add `--no-wait-user` to have it start by itself. `py simulatePASS.py --help` lists every option.

**Ending a run.** Press Enter in the window you started it from, press Ctrl-C there, or click End Simulation in the Manager window. Any of these stops the emulator first, so that it prints its end-of-run reports, and then closes every window.

**Logs.** Each program's output goes to a log in `simulatePASS-logs`. The previous run's logs are moved into a `prev-<time>` directory there.

**The password** is asked for once, in the window you started from, and checked before any window opens. Alternatively, set it in the `YAGPC_TAPE_PASSWORD` environment variable beforehand.

## Things that are different on Windows

- **Windows Firewall** may ask, the first time, whether `python.exe` or `yaGPC2.exe` may use the network. Either answer works. The programs talk to one another only within this computer, which the firewall does not block.
- **Display scaling.** The window sizes were chosen on a Linux desktop at scale 2. `simulatePASS.py` rounds Windows' own scaling to a whole number (150% becomes 2) and sizes every window to match. At 150% on a 4K monitor, the windows are therefore the same size in pixels as on that Linux desktop. If they come out too large or too small for your screen, use `--size`: 512 is the default, and 384 is smaller.
- **Window layouts** saved on Linux work unchanged, and layouts saved on Windows work on Linux. To save or restore one without `simulatePASS.py`: `py windowLayout.py save mylayout`, `py windowLayout.py restore mylayout`, or `py windowLayout.py show`. On Windows these need no extra programs.
- **Fonts.** Windows has no Helvetica and substitutes Arial, which has the same letter widths but taller lines. The panel, keyboards and CAM allow for this, so their text lands where it does on Linux.
- **CPU.** Windows cannot sleep for less than about half a millisecond, and the emulator needs shorter waits than that to keep the computers in step. It spends that time waiting on the processor instead, so expect `yaGPC2.exe` to keep two or three cores busy during a multi-GPC run.
- **Audio lines** in a crew script need Linux's audio players. Run with `--no-audio` if a script complains.

## If something goes wrong

- **"No module named PyQt6"** in a display's log means PyQt6 was installed into a different Python from the one running `simulatePASS.py`. `py -0p` lists the Pythons installed. Either install the packages with the same command you use to run the simulation, or run the simulation with the Python you installed them into.
- **"would not open -- wrong password?"** means just that, or that 7-Zip is not installed. Nothing has been started.
- **"no volume ..."** means the `--tape` file was not found. Without `--tape`, the default is `OI340700-OPS0.7z` in the `discretePanel` directory.
- **"no yaGPC2 at ..."** means step 2 has not been done, or was done somewhere else. The emulator must be `yaShuttle\yaGPC2\yaGPC2.exe`, or name it with `--yagpc`.
- **"a previous run is still up on port base 6900"** means some of an earlier run's programs are still running. Close their windows, or end them in Task Manager (`python.exe` and `yaGPC2.exe`), and try again.
- **The display never shows the GPCIPL menu.** Look in `simulatePASS-logs`: `meds1.log` should show the display filling, and `yaGPC2.log` the computer's mode changes. Any Python error in a log names the program that failed.
