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
 *  Filename:	boxAGC.c
 *  Purpose:	For performing certain image manipulations on AGC program-scan
 *  		imagery, similar in nature to what octopus.py does, but in my
 *  		own unique idiom.
 *  Mode:	2016-12-12 RSB	Began.
 *
 * This program is my attempt to find bounding boxes on AGC scans, independently 
 * from Tesseract.  I work only with raw 8-bit grayscale images ... i.e., the files
 * are simply NUMROWxNUMCOLS unsigned 8-bit values.  The starting image would be
 * created using "octopus.py --no-crop" and then using ImageMagick 
 * "convert infile -depth=8 gray:outfile".  At that point, the grayscale values 
 * would all be 0xFF (white) or 0x00 (black).
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "imageUtilities.h"

int 
main (int argc, char *argv[])
{
  int i, j;
  int width = 0, height = 0;
  char *inputFilename = NULL;
  image_t *inputImage = NULL, *rotatedImage = NULL, *tempImage = NULL, *tempImage2 = NULL;
  double angle;
  
  
  // Parse command line.
  for (i = 1; i < argc; i++)
    {
      if (1 == sscanf(argv[i], "--width=%d", &j))
        width = j;
      else if (1 == sscanf(argv[i], "--height=%d", &j))
        height = j;
      else if (!strncmp(argv[i], "--input=", 8))
        inputFilename = &argv[i][8];
      else
        {
          printf ("Unknown parameter %s\n", argv[i]);
          return (1);
        }
    }
  if (inputFilename == NULL || width == 0 || height == 0)
    {
      printf ("Must give all of --input, --width, and --height.\n");
      return (1);
    }  
  
  // Get the input image.
  inputImage = inputImageFromFile(width, height, inputFilename);
  if (inputImage == NULL)
    {
      printf("Failed to read image from file.\n");
      return(1);
    }
  
  // If it's an image from an AGC printout, the following should allow determining
  // the angle of the top line.
  tempImage = densifyImage(inputImage, width / 5, 1, 200);
  thresholdImage(tempImage, 224);
  angle = topAngle(tempImage, width / 4);
  freeImage(tempImage);
  printf("Angle = %lf\n", angle);

  // Let's undo the rotation on the image.
  rotatedImage = rotateImage(inputImage, -angle);
  outputImageToFile(rotatedImage, "rotated.raw");

  if (0)
    {
      // If we now densify the rotated image, we should be able to easily find all of the line
      // locations, and the lines should be horizontal as opposed to tilted, or at least good
      // enough for our purposes.
      //tempImage = densifyImage(rotatedImage, width / 10, 0, height);
      //thresholdImage(tempImage, 240);
      //blackenLines(tempImage, width / 10, 0, 10);
      tempImage = cloneImage(rotatedImage);
      blackenLines(tempImage, 0, 0, 1);
      outputImageToFile(tempImage, "blackenedLines.raw");

      // Let's now do the same thing for columns, which should have some spaces between them,
      // since the image has been rotated.
      //tempImage2 = densifyImage(rotatedImage, 0, height / 20, height);
      //thresholdImage(tempImage2, 248);
      //blackenColumns(tempImage2, 0, height / 20, 10);
      tempImage2 = cloneImage(rotatedImage);
      blackenColumns(tempImage2, 0, 0, 2);
      outputImageToFile(tempImage2, "blackenedColumns.raw");

      // Combine the two to get the possible locations of bounding boxes.
      maskImage(tempImage, tempImage2);
      freeImage(tempImage2);
      outputImageToFile(tempImage, "possibleBoxes.raw");
    }

  return (0);
}

