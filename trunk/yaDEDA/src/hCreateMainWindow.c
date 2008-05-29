/*
  Copyright 2004-2005 Ronald S. Burkey <info@sandroid.org>
  
  This file is part of yaAGC.

  yaAGC is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  yaAGC is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with yaAGC; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  
  Filename:	hCreateMainWindow.c
  Mods:		08/11/04 RSB.	created.
  		05/28/05 RSB	Adapted from the yaDSKY version of this file.
				For some reason I can't figure out, glade has
				used gtk_widget_set_size_request to size the 
				widgets, rather than gtk_widget_set_usize
				as it did with yaDSKY, so I've compensated
				for that.
  
  This takes the yaDEDA file interface.c, created by the GLADE code-generator,
  and scales it down by two.  (The main program has to call hCreateMainWindow
  rather than create_MainWindow to get this effect.) 
  
  In order for this to work, the interface.c file has to be edited so that the
  #includes at the top of that file are enclosed in 
  	
	#ifndef create_MainWindow
	#includes ...
	#endif
*/

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>

#include <gdk/gdkkeysyms.h>
#include <gtk/gtk.h>

#include "callbacks.h"
#include "interface.h"
#include "support.h"

static GtkWidget *my_create_pixmap (GtkWidget *Window, const char *Name)
{
  return (create_pixmap (Window, Name));
}
#define create_pixmap(x,y) my_create_pixmap (x, "h" y)

static void my_gtk_fixed_put (GtkFixed *Fixed, GtkWidget *Widget, int x, int y)
{
  gtk_fixed_put (Fixed, Widget, (x + 1) / 2, (y + 1) / 2);
}
#define gtk_fixed_put(f,w,x,y) my_gtk_fixed_put (f, w, x, y)

static void my_gtk_widget_set_usize (GtkWidget *Widget, int x, int y)
{
  gtk_widget_set_usize (Widget, (x + 1) / 2, (y + 1) / 2);
}
#define gtk_widget_set_usize(w,x,y) my_gtk_widget_set_usize (w, x, y)
#define gtk_widget_set_size_request(w,x,y) my_gtk_widget_set_usize (w, x, y)

#define create_MainWindow hCreateMainWindow

#include "interface.c"

