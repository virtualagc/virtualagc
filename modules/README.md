I have found that within the Virtual AGC source tree, it is increasingly the case that there are Python modules that were originally intended for importation into one Python program, but which eventually turn out to be used by other Python programs being developed in other directories as well.  Unfortunately, Pythons is not well suited for using modules residing in other directories that aren't subdirectories. 

Up to now, I've handled this by the rather lame expedients of having multiple copies of the module, or else having the Python programs using them copy the modules into the directories in which it needs them before importing them.  Ick!  It's a confusing maintenance and debugging irritation.

A better solution is to have a single copy of each of these modules, and to use **pip** to install them locally so that they can be imported by the programs using them without any special nonsense.

This directory is the parent for those modules, each stored in it's own dedicated subdirectory:

- asciiToEbcdic.py, for conversions of string data between ASCII and EBCDIC encodings, using the particular EBCDIC tables and substitutions specific to Space Shuttle applications.
- TBD

To install one of these modules for use, do this: 
<pre>
pip install -e path/to/the/subdirectory/containing/the/module
</pre>

For example, if on your local filesystem the Virtual AGC source tree is at virtualagc/ in your current directory, then
<pre>
pip install -e ./virtualagc/modules/asciiToEbcdic
</pre>
The `-e` switch means that the module is "editable" and thus doesn't need to be reinstalled if upgraded later, but it could be omitted in order to freeze the module at its current version.

I won't try to enforce this just yet, for fear of breaking existing installations, so the multiple copies of the modules and/or the copying of the modules into additional directories at runtime will persist for a while.  It would break existing installations because the user won't have installed any of the modules whose files we'd be deleting, and we don't want to blindside them like that.

But I think there's a valid, rather painless strategy for dealing with it when the time is ripe for it.  Here's an example of that strategy, for the `asciiToEbcdic` module, as imported into the file virtualagc/XCOM-I/generateC.py.  It should do the trick if we replace the line
<pre>
from asciiToEbcdic import asciiToEbcdic
</pre>
in that file by something like this:
<pre>
for i in range(2):
    try:
        from asciiToEbcdic import asciiToEbcdic
    except ImportError as error:
        # &grave;_pathToVAGC&grave; must be set the relative path from the 
        # importing file to the top of the Virtual AGC source-code tree.
        _pathToVAGC = os.path.dirname(os.path.abspath(__file__)) + "/.."
        # Pull in the &grave;pipIt()&grave; function.
        with open(f"{_pathToVAGC}/modules/pipIt.py", "r") as f: 
            exec(f.read())
        # Try to use &grave;pipIt()&grave; to install the missing package.
        pipIt(i, _pathToVAGC, error.name)
</pre>
Or in brief, just
<pre>
for i in range(2):
    try:
        from asciiToEbcdic import asciiToEbcdic
    except ImportError as error:
        _pathToVAGC = os.path.dirname(os.path.abspath(__file__)) + "/.."
        with open(f"{_pathToVAGC}/modules/pipIt.py", "r") as f: exec(f.read())
        pipIt(i, _pathToVAGC, error.name)
</pre>
The only customizable things here are the `_pathToVAGC` and the `import`-line itself. Of course, the `import`-line could be anything, such as `import asciiToEbcdic` or `from asciiToEbcdic import *`, or whatever.

There's a bit of a trick to setting `_pathToVAGC`, in that when you use relative paths like "..", you have to ask yourself, Relative to <i>what</i>?  As shown above, the `os.path.etc.` construct is used to make sure the path is relative to the file doing the importing, versus the current working directory or the top-level program or whatever.  The prefixed underscore is to make sure that this symbol, which is likely to appear in lots of our files, isn't being imported.

In case it isn't obvious, the code tries to perform the `import`, and if it fails it tries to install the missing module via **pip**, and retries the `import`. But the beauty of it is that it's all completely transparent to the user.  Once this change has been made in generateC.py, it all continues to work even if the copy of asciiToEbcdic.py in XCOM-I/ is removed.  However, as long as the local version continues to exist, it is the one the importer will find and use.

In the case of something like `asciiToEbcdic`, which simply contains two lists, it doesn't really have to be a module at all: We could just have used the same technique for reading in pipIt.py to instead read in asciiToEbcdic.py.  However, for anything more complicated than that, we need `pipIt` in all its glory.
