#!/usr/bin/python3
# Copyright 2017 Ronald S. Burkey <info@sandroid.org>
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
# 
# Filename: 	piSplash.py
# Purpose:	Simply displays a 270x480 splash screen for 3 seconds, then
#		clears the screen and exits.
# Reference:	http://www.ibiblio.org/apollo/developer.html
# Mod history:	2017-11-22 RSB	Began adapting from piDSKY2.py.

import time
import sys
import threading
from tkinter import Tk, Label, PhotoImage
import argparse

# Parse command-line arguments.
cli = argparse.ArgumentParser()
cli.add_argument("--window", help="Use window rather than full screen for LCD.")
args = cli.parse_args()

# Set up root viewport for tkinter graphics
root = Tk()
if args.window:
	root.geometry('272x480+0+0')
	root.title("piSplash")
else:
	root.attributes('-fullscreen', True)
	root.config(cursor="none")
root.configure(background='black')
# Preload images to make it go faster later.
imageSplash = PhotoImage(file="piDSKY2-images/splash.gif")
imageBlank = PhotoImage(file="piDSKY2-images/blank.gif")
# Initial placement of all graphical objects on LCD panel.
def displayGraphic(x, y, img):
	dummy = Label(root, image=img, borderwidth=0, highlightthickness=0)
	dummy.place(x=x, y=y)
displayGraphic(0, 0, imageSplash)
def blankScreen():
	displayGraphic(0, 0, imageBlank)
	root.update_idletasks()
	root.quit()
	sys.exit()

timerA = threading.Timer(3.0, blankScreen)
timerA.start()

root.mainloop()

