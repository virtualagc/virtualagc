/*
 * Copyright 2016 Ronald S. Burkey <info@sandroid.org>
 *
 *  This file is part of yaAGC.
 *
 *  yaAGC is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  yaAGC is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with yaAGC; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *  Filename:	imageUtilities.h
 *  Purpose:	Header file corresponding to imageUtilities.c
 *  Mode:	2016-12-12 RSB	Began.
 */
 
#include <stdint.h>

// This is the object type used to store all images.  It's basically just a 2D array
// of gray-scale values.
typedef struct {
  int width;
  int height;
  // Array of pointers to row data.
  uint8_t *data[0];
} image_t;

// Function prototypes.

void
freeImage(image_t *image);
image_t *
allocImage(int width, int height);
image_t *
inputImageFromFile(int width, int height, char *filename);
int
outputImageToFile(image_t *image, char *filename);
image_t *
cloneImage(image_t *originalImage);
image_t *
densifyImage(image_t *oldImage, int xRadius, int yRadius, int coverage);
void
thresholdImage(image_t *image, uint8_t threshold);
double
topAngle(image_t *image, int xRadius);
image_t *
rotateImage(image_t *image, double angle);
void
blackenLines(image_t *image, int xRadius, int yRadius, int threshold);
void
blackenColumns(image_t *image, int xRadius, int yRadius, int threshold);
void
maskImage(image_t *imageBase, image_t *imageModifier);

