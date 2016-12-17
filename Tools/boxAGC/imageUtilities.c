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
 *  Filename:	imageUtilities.c
 *  Purpose:	For performing various simple image manipulations, typically
 *  		for use by boxAGC.c.
 *  Mode:	2016-12-12 RSB	Began.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "imageUtilities.h"

// Deallocates an image_t object previously allocated by allocImage().
void
freeImage (image_t *image)
{
  int i;
  if (image == NULL)
    return;
  for (i = 0; i < image->height; i++)
    if (image->data[i] != NULL)
      free (image->data[i]);
  free (image);
}

// Allocates an initializes an image object of a given size, with all "white"
// pixel values.  Returns either a pointer to the new object, or else NULL on error.
image_t *
allocImage (int width, int height)
{
  int i;
  image_t *image;
  image = calloc (sizeof(image_t) + height * sizeof(image->data[0]), 1);
  if (image == NULL)
    return (NULL);
  image->width = width;
  image->height = height;
  for (i = 0; i < height; i++)
    {
      image->data[i] = malloc (width * sizeof(uint8_t));
      if (image->data[i] == NULL)
	{
	  freeImage (image);
	  return (NULL);
	}
      memset (image->data[i], 0xFF, width);
    }
  return (image);
}

// Creates an image object of a given size, and populates it from a "raw" grayscale
// image file.  Returns a pointer to the new image_t, or else NULL on any error
// (out of memory, file doesn't exist, file is the wrong size, etc.).
image_t *
inputImageFromFile (int width, int height, char *filename)
{
  FILE *fp = NULL;
  image_t *image = NULL;
  int i;

  image = allocImage (width, height);
  if (image == NULL)
    goto error;
  fp = fopen (filename, "rb");
  if (fp == NULL)
    goto error;
  fseek (fp, 0L, SEEK_END);
  if (ftell (fp) != width * height)
    goto error;
  rewind (fp);

  for (i = 0; i < height; i++)
    if (width != fread (image->data[i], 1, width, fp))
      goto error;

  fclose (fp);
  return (image);
  error: ;
  if (fp != NULL)
    fclose (fp);
  freeImage (image);
  return (NULL);
}

// Writes a "raw" grayscale image_t to disk.  Returns 0
// on success or 1 on failure.
int
outputImageToFile (image_t *image, char *filename)
{
  FILE *fp = NULL;
  int i;

  fp = fopen (filename, "wb");
  if (fp == NULL)
    goto error;

  for (i = 0; i < image->height; i++)
    if (image->width != fwrite (image->data[i], 1, image->width, fp))
      goto error;

  fclose (fp);
  return (0);
  error: ;
  if (fp != NULL)
    fclose (fp);
  return (1);
}

// Allocates and populates a new image_t identical to a given image_t.
// The data is copied, not merely referenced.  On error, NULL is returned.
image_t *
cloneImage (image_t *originalImage)
{
  image_t *image = NULL;
  int i;

  image = allocImage (originalImage->width, originalImage->height);
  if (image == NULL)
    goto error;

  for (i = 0; i < image->height; i++)
    memcpy (image->data[i], originalImage->data[i], image->width);

  return (image);
  error: ;
  freeImage (image);
  return (NULL);
}

// Creates a new image_t based on an existing one, in which the new
// image has pixel values that are averages of the original pixel
// values in rectangles centered at the original pixels.  These 
// rectangles include the orginal pixels, and the xRadius columns to
// the left and right, plus the yRadius rows above and below.  So
// the new pixel values are averages of (2*xRadius+1)*(2*yRadius+1)
// old pixel values.  The averaging can't approach the edges closer 
// than xRadius or yRadius columns or rows, so the pixels in those
// margins are unchanged.  Also, for our purpose, if only the averaging
// at the very top is needed, the coverage parameter can be used to 
// specify that only the top coverage pixel rows are of interest; the
// pixel-rows below that are unchanged.  This lets the computation 
// proceed much faster in some cases.  Returns a pointer to the new
// image_t, or NULL on error.  Averaging with very big xRadius is good
// for detecting rows (or gaps between rows), while averaging with
// a very bit yRadius is better for detecting columns.  However, since 
// the gaps between columns are typically very small compared to those
// between rows, even a very small tilt is enough to make column-detection
// very difficult.
image_t *
densifyImage (image_t *oldImage, int xRadius, int yRadius, int coverage)
{
  unsigned *sums = NULL;
  image_t *image = NULL;
  int i, j, ii, pixels;

  image = cloneImage (oldImage);
  if (image == NULL)
    goto error;
  sums = calloc (image->width, sizeof(unsigned));
  if (sums == NULL)
    goto error;

  // Fill in the initial value of the sums[] array (and first row of image).
  pixels = (2 * xRadius + 1) * (2 * yRadius + 1);
  for (i = 0; i <= 2 * xRadius; i++)
    for (j = 0; j <= 2 * yRadius; j++)
      sums[xRadius] += oldImage->data[j][i];
  image->data[yRadius][xRadius] = (sums[xRadius] + pixels / 2) / pixels;
  for (i = xRadius + 1; i < image->width - xRadius; i++)
    {
      sums[i] = sums[i - 1];
      for (j = 0; j <= 2 * yRadius; j++)
	sums[i] += oldImage->data[j][i + xRadius]
	    - oldImage->data[j][i - xRadius - 1];
      image->data[yRadius][i] = (sums[i] + pixels / 2) / pixels;
    }

  // Loop on the rows.
  for (j = yRadius + 1; j < coverage && j < image->height - yRadius; j++)
    for (i = xRadius; i < image->width - xRadius; i++)
      {
	for (ii = i - xRadius; ii <= i + xRadius; ii++)
	  sums[i] += oldImage->data[j + yRadius][ii]
	      - oldImage->data[j - yRadius - 1][ii];
	image->data[j][i] = (sums[i] + pixels / 2) / pixels;
      }

  free (sums);
  return (image);
  error: ;
  if (sums != NULL)
    free (sums);
  freeImage (image);
  return (NULL);
}

// Applies a threshold to the image, in-place, in which all pixels < the given
// threshold are set to 0x00 (black), and all those over it are set to 0xFF (white).
void
thresholdImage (image_t *image, uint8_t threshold)
{
  int i, j;
  for (i = 0; i < image->width; i++)
    for (j = 0; j < image->height; j++)
      image->data[j][i] = (image->data[j][i] >= threshold) ? 0xFF : 0;
}

// Determines the tilt of the image.  As implemented, it uses knowledge about the 
// characteristics of the top line of an AGC printout.  The idea is that you first
// use densifyImage() with very big xRadius and very small yRadius, and relatively
// small coverage (since only the top line is of interest), and then use topAngle()
// to find the angle of the now horizontally-smeared-out top line.  The returned
// angle is in degrees counterclockwise, so rotating the image by that angle 
// clockwise should theoretically square it up, if the vertical and horizontal are
// orthogonal.  (In theory, a similar operation should sometimes be possible for 
// determining the vertical tilt, however, there is no vertical equivalent to the 
// horizontal top line of the printout, so there is no equivalent feature which is
// guaranteed to be present in the image.)
double
topAngle (image_t *image, int xRadius)
{
#define DIVISIONS 10
  int leftX, leftY, rightX, rightY, i, j, sumX = 0, sumY = 0, sumXX = 0, sumYY =
      0, sumXY = 0;
  double angle;

  // Find the y coordinate of the top of the line at several x.
  for (i = 0; i < DIVISIONS; i++)
    {
      int x;
      x = (xRadius * (DIVISIONS - 1 - i) + (image->width - xRadius - 1) * i)
	  / (DIVISIONS - 1);
      sumX += x;
      sumXX += x * x;
      for (j = 0; j < image->height; j++)
	if (image->data[j][x] > 128)
	  break;
      for (; j < image->height; j++)
	if (image->data[j][x] <= 128)
	  break;
      sumY += j;
      sumYY += j * j;
      sumXY += x * j;
      if (j >= image->height)
	return (1000.0); // Nothing found, return an illegal (or at least distinctive) value.
    }

  // Do a least-squares fit to find the slope of the line.
  angle = -atan2 (DIVISIONS * sumXY - sumX * sumY,
		  DIVISIONS * sumXX - sumX * sumX) * 180.0 / M_PI;
  return (angle);
#undef DIVISIONS  
}

// Given an image_t, creates a new image that's rotated counter-clockwise by angle (degrees).
// Returns a pointer to the new image, or else NULL on error.  The technique is that for each
// point in the output image, we back-rotate it to find the four points in the input image of
// the surrounding rectangle, and then find the value of the point by a 2D linear interpolation
// within that rectangle.
image_t *
rotateImage (image_t *inputImage, double angle)
{
  int i, j, width, height;
  double midX, midY;
  double cosAngle, sinAngle;
  image_t *outputImage = NULL;

  outputImage = cloneImage (inputImage);
  if (angle == 0.0)
    return (outputImage);

  // Convert angle to radians.
  angle *= M_PI / 180.0;
  cosAngle = cos (angle);
  sinAngle = sin (angle);

  // Rotate.
  width = inputImage->width;
  height = inputImage->height;
  midX = (width - 1) / 2.0;
  midY = (height - 1) / 2.0;
  for (i = 0; i < inputImage->width; i++)
    for (j = 0; j < inputImage->height; j++)
      {
	double x, y;
	int left, right, top, bottom;
	// Back-rotate (i,j) -> (x,y)
	x = cosAngle * (i - midX) - sinAngle * (j - midY) + midX;
	y = sinAngle * (i - midX) + cosAngle * (j - midY) + midY;
	if (x < 0 || x > width - 1 || y < 0 || y > height - 1)
	  outputImage->data[j][i] = 0xFF;
	else
	  {
	    left = x;
	    right = x + 1;
	    top = y;
	    bottom = y + 1;
	    outputImage->data[j][i] = fmax (
		0,
		fmin (
		    255,
		    0.5
			+ inputImage->data[bottom][left] * (y - top)
			    * (right - x)
			+ inputImage->data[bottom][right] * (y - top)
			    * (x - left)
			+ inputImage->data[top][left] * (bottom - y)
			    * (right - x)
			+ inputImage->data[top][right] * (bottom - y)
			    * (x - left)));
	  }
      }

  return (outputImage);
  error: ;
  freeImage (outputImage);
  return (NULL);
}

// Examine each pixel line of an image, and if it has more than threshold black pixels,
// blacken the entire line.  Otherwise, whiten it.  Do this in place.  The threshold
// is for the number of pixels, not the black level, since it is assumed that all pixels
// are either 0x00 or 0xFF.
void
blackenLines(image_t *image, int xRadius, int yRadius, int threshold)
{
  int i, j, count;
  uint8_t value;
  for (j = 0; j < image->height; j++)
    {
      count = 0;
      if (j >= yRadius && j < image->height - yRadius)
	for (i = xRadius; i < image->width - xRadius; i++)
	  if (image->data[j][i] < 128)
	    count++;
      value = (count > threshold) ? 0x00 : 0xff;
      for (i = 0; i < image->width; i++)
	image->data[j][i] = value;
    }
}

// Do the same for columns.
void
blackenColumns(image_t *image, int xRadius, int yRadius, int threshold)
{
  int i, j, count;
  uint8_t value;
  for (i = 0; i < image->width; i++)
    {
      count = 0;
      if (i >= xRadius && i < image->width - xRadius)
	for (j = yRadius; j < image->height - yRadius; j++)
	  if (image->data[j][i] < 128)
	    count++;
      value = (count > threshold) ? 0x00 : 0xff;
      for (j = 0; j < image->height; j++)
	image->data[j][i] = value;
    }
}

// Lighten the first image in place, by applying the 2nd image.  The two
// images must be the same dimension.  The operation is a bitwise OR, so
// if the pixels aren't confined to the values 0x00 and 0xFF, the result
// isn't entirely straightforward.
void
maskImage(image_t *imageBase, image_t *imageModifier)
{
  int i, j;
  for (j = 0; j < imageBase->height; j++)
    for (i = 0; i < imageBase->width; i++)
      imageBase->data[j][i] |= imageModifier->data[j][i];
}
