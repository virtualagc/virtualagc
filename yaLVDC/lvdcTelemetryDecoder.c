/*
 * License:    The author (Ronald Burkey) declares this program to be in the
 *             Public Domain, usable or modifiable in any way desired.
 * Filename:   lvdcTelemetryDecoder.c
 * Purpose:    Parses a "virtual wire" datastream from the yaLVDC CPU
 *             emulator, and pulls out just a telemetry datastream.
 * History:    2023-08-10 RSB  Began porting from lvdcTelemetryDecoder.py.
 *
 * See lvdcTelemetryDecoder.h for documentation.
 *
 * If compiled with -DUSE_MAIN, then can be used as a stand-alone program that
 * reads the PIO log file created by yaLVDC --log-pio.  This test program seems
 * to produce an output identical to analyzeBoost.py (which uses the Python
 * port lvdcTelemetryDecoder.py), except for a decorative header and Python's
 * silly rounding algorithm -- excuse me, "banker's rounding" -- which often
 * produces an difference in the least-significant digit of the logged
 * timestamp.
 *
 * Without USE_MAIN, though, this file just provides the library functions and
 * data-structure definitions for use in other programs, as defined in
 * lvdcTelemetryDecoder.h.
 */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include "lvdcTelemetryDecoder.h"

static int lvdcMode = 256; // 256 means "unknown".

#define MAX_DEFINITIONS 512
static teld_t forAS206RAM[MAX_DEFINITIONS];
static int numForAS206RAM = 0;
static teld_t forAS512[MAX_DEFINITIONS];
static int numForAS512 = 0;
static teld_t forAS513[MAX_DEFINITIONS];
static int numForAS513 = 0;
static teld_t *forMission = NULL;
static int *numForMission = NULL;

/*
 * Here are some substrings which *if* they appear in the the string defining
 * the units for a telemetry definition, I assume they mean that I should
 * present the data in base 10.  If none of these substrings appear, I assume
 * octal.  Besides the returned value, a second value that's scaled according
 * to the given binary scaler is set up as the global variable
 * lvdcScaledValue[].
 */
static char *lvdcDecimalUnits[] = { "RADIAN", "PIRAD", "/", "**", "SECOND",
                                    "METER", "KG", "QMS", "RTC", "DECIMAL"};
static int numLvdcDecimalUnits = sizeof(lvdcDecimalUnits) / sizeof(char *);
char lvdcScaledValue[64];
char *
lvdcFormatData(int value, float scale, char *units)
{
  static char formattedData[64];
  int i;
  for (i = 0; i < numLvdcDecimalUnits; i++)
    if (NULL != strstr(units, lvdcDecimalUnits[i]))
      {
        if (value & 0200000000) // Supposed to be negative?
          value = -(value ^ 0377777777); // Negate it.
        sprintf(formattedData, "%d", value);
        if (scale != -1000 && scale != 0)
          sprintf(lvdcScaledValue, "%g", value * pow(2, scale - 25));
        else
          strcpy(lvdcScaledValue, formattedData);
        return formattedData;
      }
  sprintf(formattedData, "O%09o", value);
  strcpy(lvdcScaledValue, "");
  return formattedData;
}

static char *copyString(char *s)
{
  char *ss;
  ss = malloc(strlen(s) + 1);
  if (ss != NULL)
    strcpy(ss, s);
  return (ss);
}

// For sorting and searching.
static int
cmpDefinitions(const void *d1, const void *d2)
{
  return (((teld_t *) d1)->modeAndPio -
          ((teld_t *) d2)->modeAndPio);
}

int
lvdcReadDefinitions(char *definitionPath)
{
  FILE *fp;
  char rawLine[1024], *line, *end, *fields[6], *next;
  int numFields, i, *numForMission;

  fp = fopen(definitionPath, "r");
  if (fp == NULL)
    return (1);
  while (NULL != fgets(rawLine, sizeof(rawLine), fp))
    {
      // Trim leading and trailing space from line.
      for (line = rawLine; isspace(*line); line++);
      for (end = line + strlen(line) - 1; end > line && isspace(*end); end--);
      end[1] = 0;
      // Split the line at the tabs.
      numFields = 0;
      next = line;
      for (i = 0; i < 6; i++)
        {
          fields[i] = next;
          numFields++;
          next = strstr(next, "\t");
          if (next == NULL)
            break;
          *next++ = 0;
        }
      // Now process the fields.
      if (numFields == 1)
        {
          if (!strcmp(fields[0], "forAS206RAM"))
            {
              forMission = forAS206RAM;
              numForMission = &numForAS206RAM;
            }
          else if (!strcmp(fields[0], "forAS512"))
            {
              forMission = forAS512;
              numForMission = &numForAS512;
            }
          else if (!strcmp(fields[0], "forAS513"))
            {
              forMission = forAS513;
              numForMission = &numForAS513;
            }
          else
            {
              forMission = NULL;
              numForMission = NULL;
            }
        }
      else if (numFields <= 6 && forMission != NULL)
        {
          for (; numFields < 6; numFields++)
            fields[numFields] = "";
          forMission[*numForMission].modeAndPio = strtol(fields[0], NULL, 8);
          forMission[*numForMission].variableName = copyString(fields[1]);
          forMission[*numForMission].scale1 = atoi(fields[2]);
          forMission[*numForMission].scale2 = atoi(fields[3]);
          forMission[*numForMission].units = copyString(fields[4]);
          forMission[*numForMission].description = copyString(fields[5]);
          (*numForMission)++;
        }
    }
  fclose(fp);
  qsort(forAS206RAM, numForAS206RAM, sizeof(teld_t), cmpDefinitions);
  qsort(forAS512, numForAS512, sizeof(teld_t), cmpDefinitions);
  qsort(forAS513, numForAS513, sizeof(teld_t), cmpDefinitions);
  return (0);
}

void
lvdcModeReset(void)
{
  lvdcMode = 256;
}

void
lvdcSetVersion(int version)
{
  if (version == 1)
    {
      forMission = forAS206RAM;
      numForMission = &numForAS206RAM;
    }
  else if (version == 2)
    {
      forMission = forAS512;
      numForMission = &numForAS512;
    }
  else if (version == 3)
    {
      forMission = forAS513;
      numForMission = &numForAS513;
    }
  else
    {
      forMission = NULL;
      numForMission = NULL;
    }
}

teld_t defaultDef = {-1, "", -1000, -1000, "", ""};
telm_t defaultReturn = {&defaultDef, -1, ""};
telm_t *
lvdcTelemetryDecoder(int ioType, int channelNumber, int data)
{
  teld_t key, *teld;
  static telm_t telemetry;
  if (ioType != 0)
    return (&defaultReturn);
  if ((channelNumber & 0177) == 006)
    {
      lvdcMode = (data >> 20) & 7;
      return (&defaultReturn);
    }
  if (lvdcMode == 256)
    return (&defaultReturn);
  key.modeAndPio = (lvdcMode << 9) | channelNumber;
  teld = bsearch(&key, forMission, *numForMission, sizeof(teld_t),
                       cmpDefinitions);
  if (teld == NULL)
    return (&defaultReturn);
  telemetry.definition = teld;
  telemetry.data = data;
  telemetry.errorMessage = "";
  return (&telemetry);
}

#ifdef USE_MAIN

#if 0
static void
printDefinition(teld_t *definition, int doNewline)
{
  printf("%04o\t%-8s\t%6d\t%6d\t%-12s\t%-32s",
      definition->modeAndPio, definition->variableName,
      definition->scale1, definition->scale2,
      definition->units, definition->description);
  if (doNewline)
    printf("\n");
}
#endif

int
main(int argc, char **argv)
{
  telm_t *telemetry;
  int i, version = 2;
  char *path = "./lvdcTelemetryDefinitions.tsv";
  char fmt[] = "%12.3f\t%-8s\t%-12s\t%-12s\t%-12s\t%-12s\t%s\n";
  char line[1024], *fields[5], *next, scaleString[64], *dataString;
  int numFields;
  float t;


  for (i = 1; i < argc; i++)
    {
      if (!strncmp(argv[i], "--teld=", 7))
        path = &argv[i][7];
      else if (!strncmp(argv[i], "--version=", 10))
        version = atoi(&argv[i][10]);
      else
        {
          printf("Interpret a PIO log file from yaLVDC.  Usage:\n");
          printf("\tlvdcTelemetryDecoder [OPTIONS] <LOG.tsv >TELEMETRY.tsv\n");
          printf("The available OPTIONS are:\n");
          printf("--teld=P     Required file lvdcTelemetryDefinitions.tsv\n");
          printf("             is assumed by default to be in the current\n");
          printf("             working directory.  If not, or if the file\n");
          printf("             has been renamed, P is the full path to it.\n");
          printf("--version=N  By default, AS-512 FP is assumed.  If not,\n");
          printf("             then N specifies a different LVDC version:\n");
          printf("                   1     AS-206RAM FP\n");
          printf("                   2     AS-512 FP\n");
          printf("                   3     AS-513 FP\n");
          printf("Using an unrecognized OPTION (such as --help) results in\n");
          printf("this display of the instructions.\n");
          exit(0);
        }
    }

  lvdcReadDefinitions(path);
  lvdcModeReset();
  lvdcSetVersion(version);

  while (NULL != fgets(line, sizeof(line), stdin))
    {
      // Get rid of EOL terminator(s).
      while (isspace(line[strlen(line)-1]))
        line[strlen(line)-1] = 0;
      // Split the line at the tabs.
      numFields = 0;
      next = line;
      for (i = 0; i < 5; i++)
        {
          fields[i] = next;
          numFields++;
          next = strstr(next, "\t");
          if (next == NULL)
            break;
          *next++ = 0;
        }
      if (numFields < 5 || strlen(fields[4]) != 9) // End of file.
        break;
      t = (168.0 * atoi(fields[0])) / 2048000;
      telemetry = lvdcTelemetryDecoder(0, strtol(fields[2], NULL, 8),
                                       strtol(fields[4], NULL, 8));
      if (telemetry->definition->modeAndPio != -1)
        {
          dataString = lvdcFormatData(telemetry->data,
                                      telemetry->definition->scale1,
                                      telemetry->definition->units);
          strcpy(scaleString, "");
          if (telemetry->definition->scale1 != -1000)
            {
              if (telemetry->definition->scale2 == -1000)
                sprintf(scaleString, "B%d", telemetry->definition->scale1);
              else
                sprintf(scaleString, "B%d/B%d", telemetry->definition->scale1,
                                         telemetry->definition->scale2);
            }
          printf(fmt, t, telemetry->definition->variableName,
                 dataString, scaleString, lvdcScaledValue,
                 telemetry->definition->units,
                 telemetry->definition->description);
        }
    }

#if 0
    {
      int i;
      printf("forAS206RAM\n");
      for (i = 0; i < numForAS206RAM; i++)
        printDefinition(&forAS206RAM[i], 1);
      printf("forAS512\n");
      for (i = 0; i < numForAS512; i++)
        printDefinition(&forAS512[i], 1);
      printf("forAS513\n");
      for (i = 0; i < numForAS513; i++)
        printDefinition(&forAS513[i], 1);
    }
#endif

  return (0);
}

#endif // USE_MAIN

