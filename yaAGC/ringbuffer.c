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

  Filename:  ringbuffer.c
  Purpose:   Implements a simple FIFO ringbuffer.
  Contact:   Michael Karl Franzl <public.michael@franzl.name>
  Mods:      2020-06-07 MKF  Created.
*/

#include "ringbuffer.h"

#include <string.h>

/*
 * Initialize the ringbuffer; make it empty.
 */
void ringbuffer_init (ringbuffer* buf)
{
  buf->tail = buf->head = 0;
}

/* Copies `element` into the ringbuffer. Returns the number of copied bytes.
 * If the ringbuffer is full, does nothing and returns 0.
 */
int ringbuffer_put (ringbuffer* buf,
                       unsigned char element[RINGBUFFER_ELEMENT_SIZE])
{
  int i = (buf->head + RINGBUFFER_ELEMENT_SIZE) & (RINGBUFFER_CAPACITY - 1);
  if (i == buf->tail)
    return 0; // full

  memcpy (buf->data + buf->head, element, RINGBUFFER_ELEMENT_SIZE);
  buf->head = i;

  return RINGBUFFER_ELEMENT_SIZE;
}


/* Copies the next entry from `buf` into `element` and returns the number
 * of copied bytes.
 * If the ringbuffer is empty, does nothing and returns 0.
 */
int ringbuffer_get(ringbuffer* buf,
                      unsigned char element[RINGBUFFER_ELEMENT_SIZE])
{
  if (buf->tail == buf->head)
    return 0; // empty

  memcpy (element, buf->data + buf->tail, RINGBUFFER_ELEMENT_SIZE);
  buf->tail = (buf->tail + RINGBUFFER_ELEMENT_SIZE) & (RINGBUFFER_CAPACITY - 1);

  return RINGBUFFER_ELEMENT_SIZE;
}
