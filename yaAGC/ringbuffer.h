/*
  ringbuffer - Implements a simple FIFO ringbuffer.
  Copyright 2020 Michael Karl Franzl <public.michael@franzl.name>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

  Filename:  ringbuffer.h
  Purpose:   Implements a simple FIFO ringbuffer.
  Contact:   Michael Karl Franzl <public.michael@franzl.name>
  Mods:      2020-06-07 MKF  Created.
*/

#define RINGBUFFER_ELEMENT_SIZE 4
#define RINGBUFFER_ELEMENTS 1024
#define RINGBUFFER_CAPACITY RINGBUFFER_ELEMENTS * RINGBUFFER_ELEMENT_SIZE

typedef struct {
  unsigned char data[RINGBUFFER_CAPACITY];
  int tail;
  int head;
} ringbuffer;

extern ringbuffer ringbuffer_in;
extern ringbuffer ringbuffer_out;

void ringbuffer_init (ringbuffer *buf);
int ringbuffer_put (ringbuffer* buf, unsigned char* Packet);
int ringbuffer_get (ringbuffer* buf, unsigned char* Packet);
