/*
 * License:    The author (Ronald Burkey) declares this program to be in the
 *             Public Domain, usable or modifiable in any way desired.
 * Filename:   lvdcTelemetryDecoder.h
 * Purpose:    Parses a "virtual wire" datastream from the yaLVDC CPU
 *             emulator, and pulls out just a telemetry datastream.
 * History:    2023-08-11 RSB  Separated from lvdcTelemetryDecoder.c.
 *
 * How to use.  First, there's a setup:
 *
 *      // Read all of the telemetry definitions from the file
 *      // lvdcTelemetryDefinitions.tsv, specifying to full path to the file.
 *      // For example:
 *      lvdcReadDefinitions("./lvdcTelemetryDefinitions.tsv");
 *      // Reset the mode register to an "unknown" state.  This is actually the
 *      // default at startup, so the call to lvdcModeReset() isn't normally
 *      // needed, but it's reasonable to use it.
 *      lvdcModeReset();
 *      // Set the LVDC software version.  For example, for AS-513:
 *      lvdcSetVersion(3);
 *
 * After that, just feed lvdcTelemetryDecoder() each PIO as it arrives.
 * For example:
 *
 *      telm_t *telemetry;
 *      ...
 *      telemetry = lvdcTelemetryDecoder(0, 0006, 0360000000);
 *      ...
 *      telemetry = lvdcTelemetryDecoder(0, 0470, 123456);
 *      ...
 *
 * Parsing the telemetry by lvdcTelemetryDecoder() depends on the current mode-
 * register setting, which is unknown at startup, and hence all PIOs are ignored
 * until a valid mode is received via a PIO 006 (or 206, 406, 606).  In the
 * example above, the first call to lvdcTelemetryDecoder shown sets the mode
 * to 4, thus in the second call the telemetry for 04470 (V.DDTL) is returned.
 */

#ifndef LVDC_TELEMETRY_DECODER_H
#define LVDC_TELEMETRY_DECODER_H 1

// A telemetry definition.
typedef struct {
  int modeAndPio;
  char *variableName;
  int scale1;
  int scale2; // -1000 if none.
  char *units;
  char *description;
} teld_t;

// A telemetry record.
typedef struct {
  teld_t *definition;
  int data;
  char *errorMessage;
} telm_t;

/*
 * Get lists of telemetry PIOs.  These are stored in a tab-delimited file so
 * that they can be easily used by other software without being locked in a
 * Python data structure. Once read into Python dictionaries, however, the keys
 * are the PIO 9-bit channel numbers, augmented
 * by putting the 3-bit mode register (as I understand it) at the top, turning
 * the channel numbers into 4 octal digits.  The values are 5-tuples:
 *    Variable name (string)
 *    Scale (or first scale, if two are specified as in "23/27")
 *    Second scale, or -1000 if none is specified.
 *    Units (string)
 *    Description (string)
 * The tab-delimited file I mentioned, lvdcTelemetryDefinitions.tsv, is found
 * in the source tree in the same folder as lvdcTelemetryDecoder.c itself.
 * The function sets up a series of dictionaries, forAS206RAM{}, forAS512{},
 * forAS513{}, one for each supported LVDC software version.
 * Returns nonzero on error.
 */
int
lvdcReadDefinitions(char *definitionPath);

/*
 * Set the current mode register to an "unknown" type.
 */
void
lvdcModeReset(void);

/*
 * Set the LVDC software version:
 *      1       AS-206RAM
 *      2       AS-512
 *      3       AS-513
 *      4       AS-206 (fingers crossed!)
 */
void
lvdcSetVersion(int version);

/*
 * Register reception of a new PIO, and extract its telemetry, if any.  Each
 * new PIO should be run through this function, whether containing telemetry or
 * not, and particularly PIO 006, 206, 406, 606.  The arguments are:
 *
 *      ioType          Indicates the data source.  Presently, only 0 (LVDC)
 *                      is supported, and all others are silently ignored.
 *      channelNumber   The 9-bit PIO channel number.
 *      data            The 26-bit data of the PIO.  Note that there is no
 *                      parity bit, so this data is shifted right by one bit
 *                      position relative to assembly language like:
 *                              CLA     =O71    (710000000)
 *                              PIO     006
 *                      This language would result in data=0o344000000.
 *
 * If the PIO contains valid telemetry, then a pointer to the telemetry is
 * returned. Since a telm_t record contains the associated teld_t record, the
 * format and description of the data, can be gotten directly from the returned
 * value.  Otherwise (i.e., if error or non-telemetry data), a pointer to the
 * following is returned:
 *
 *      {
 *              &{-1, "", -1000, -1000, "", ""},
 *              -1,
 *              &errorMessageString
 *      }
 *
 * The non-telemetry nature can be recognized by the returned mode+channel
 * (i.e., telm->definition->modeAndPIO) having the value -1.  The
 * errorMessageString is "" for non-telemetry data, or an actual error message
 * in case of error.
 *
 * The returned value is actually a pointer to a statically-defined structure,
 * so you don't need to free it after use, but also cannot rely on it remaining
 * unchanged.  Copy it elsewhere if you need to save it.  However, the pointer
 * within it to the teld_t can be relied on, and only its pointer needs to be
 * preserved rather than its full contents.
 */
telm_t *
lvdcTelemetryDecoder(int ioType, int channelNumber, int data);

/*
 * This function attempts to guess, on the basis of the "units" field in the
 * telemetry definition, whether the data should be formatted in base 10 vs
 * base 8 for presentation.  The returned value is a statically-defined
 * string, so memory for it should not be freed, and its value is likely to
 * change upon the next call to the function.
 */
extern char lvdcScaledValue[64];
char *
lvdcFormatData(int value, float scale, char *units);


#endif // LVDC_TELEMETRY_DECODER_H
