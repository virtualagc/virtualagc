/*
  Copyright 2003 Ronald S. Burkey <info@sandroid.org>
  
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
  
  Filename:	callbacks.h
  Purpose:	Prototypes for yaDSKY's callbacks.c.
  Mods:		08/20/03 RSB.	First fully-working version.
*/

#include <gtk/gtk.h>

typedef struct {
  char *GraphicOn;		// Filename of graphic for "lit" condition.
  char *GraphicOff;		// Filename of graphic for "dark" condition.
  int Channel;			// CPU i/o channel.
  int Bitmask;			// Mask selecting bitflag within i/o channel.
  int Polarity;			// Mask for flipping the polarity. (Either 0 or Bitmask.)
  int State;			// Whether currently on or off.  (Either 0 or Bitmask.)
  GtkImage *Widget;		// The GTK widget corresponding to the lamp.
  // Stuff mainly for indicators controlled by channel 10.
  int Latched;			// Following stuff ignored if Latched==0.
  int RowMask;
  int Row;
} Ind_t;

gboolean
on_iNounButton_button_press_event      (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iNounButton_button_release_event    (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iSevenButton_button_press_event     (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iSevenButton_button_release_event   (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iEightButton_button_press_event     (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iEightButton_button_release_event   (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iNineButton_button_press_event      (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iNineButton_button_release_event    (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iClrButton_button_press_event       (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iClrButton_button_release_event     (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iKeyRelButton_button_press_event    (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iKeyRelButton_button_release_event  (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iLastButton_button_press_event      (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iLastButton_button_release_event    (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iEntrButton_button_press_event      (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iEntrButton_button_release_event    (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iRsetButton_button_press_event      (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iRsetButton_button_release_event    (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iSixButton_button_press_event       (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iSixButton_button_release_event     (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iFiveButton_button_press_event      (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iFiveButton_button_release_event    (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iFourButton_button_press_event      (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iFourButton_button_release_event    (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iMinusButton_button_press_event     (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iMinusButton_button_release_event   (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iZeroButton_button_press_event      (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iZeroButton_button_release_event    (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iOneButton_button_press_event       (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iOneButton_button_release_event     (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iTwoButton_button_press_event       (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iTwoButton_button_release_event     (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iThreeButton_button_press_event     (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iThreeButton_button_release_event   (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iPlusButton_button_press_event      (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iPlusButton_button_release_event    (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iVerbButton_button_press_event      (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_iVerbButton_button_release_event    (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_MainWindow_destroy_event            (GtkWidget       *widget,
                                        GdkEvent        *event,
                                        gpointer         user_data);

void
on_EntrButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_EntrButton_released                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_EntrButton_clicked                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_NounButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_NounButton_released                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_SevenButton_pressed                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_SevenButton_released                (GtkButton       *button,
                                        gpointer         user_data);

void
on_EightButton_pressed                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_EightButton_released                (GtkButton       *button,
                                        gpointer         user_data);

void
on_NineButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_NineButton_released                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_ClrButton_pressed                   (GtkButton       *button,
                                        gpointer         user_data);

void
on_ClrButton_released                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_KeyRelButton_pressed                (GtkButton       *button,
                                        gpointer         user_data);

void
on_KeyRelButton_released               (GtkButton       *button,
                                        gpointer         user_data);

void
on_ProButton_pressed                   (GtkButton       *button,
                                        gpointer         user_data);

void
on_ProButton_released                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_RsetButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_RsetButton_released                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_SixButton_pressed                   (GtkButton       *button,
                                        gpointer         user_data);

void
on_SixButton_released                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_FiveButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_FiveButton_released                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_FourButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_FourButton_released                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_MinusButton_pressed                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_MinusButton_released                (GtkButton       *button,
                                        gpointer         user_data);

void
on_ZeroButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_ZeroButton_released                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_OneButton_pressed                   (GtkButton       *button,
                                        gpointer         user_data);

void
on_OneButton_released                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_TwoButton_pressed                   (GtkButton       *button,
                                        gpointer         user_data);

void
on_TwoButton_released                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_ThreeButton_pressed                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_ThreeButton_released                (GtkButton       *button,
                                        gpointer         user_data);

void
on_PlusButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_PlusButton_released                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_VerbButton_pressed                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_VerbButton_released                 (GtkButton       *button,
                                        gpointer         user_data);

gboolean
on_MainWindow_destroy_event            (GtkWidget       *widget,
                                        GdkEvent        *event,
                                        gpointer         user_data);

gboolean
on_MainWindow_delete_event             (GtkWidget       *widget,
                                        GdkEvent        *event,
                                        gpointer         user_data);
