/*
  Declared to be in the Public Domain by its original author, Ron Burkey.

  Filename:     DecodeDownlinkListHardcodes.c
  Purpose:      This file is used only by DecodeDigitalDownlink.c.  It provides
                hard-code downlist specifications for yaTelemetry.  The original
                version of this file was manually coded, but future versions
                may be generated via scripts such as dddUnscrape.py from
                files ddd-*-*.tsv.  Therefore, no modification history is
                maintained internally to this file.
  Contact:      Ron Burkey <info@sandroid.org>
  Ref:          http://www.ibiblio.org/apollo/index.html
  History:      2025-04-02 RSB  Replaced all of these default downlists with
				absolutely generic ones having only ID, SYNC,
				and TIME as named items, since any *real*
				downlist specifications are going to be read
				from files anyway.
*/

#define DEFAULT_LIST \
{ 0, "ID=", B0, FMT_OCT }, \
{ 1, "SYNC=", B0, FMT_OCT }, \
{ 2, "ITEM002=", B0, FMT_OCT }, \
{ 3, "ITEM003=", B0, FMT_OCT }, \
{ 4, "ITEM004=", B0, FMT_OCT }, \
{ 5, "ITEM005=", B0, FMT_OCT }, \
{ 6, "ITEM006=", B0, FMT_OCT }, \
{ 7, "ITEM007=", B0, FMT_OCT }, \
{ 8, "ITEM008=", B0, FMT_OCT }, \
{ 9, "ITEM009=", B0, FMT_OCT }, \
{ 10, "ITEM010=", B0, FMT_OCT }, \
{ 11, "ITEM011=", B0, FMT_OCT }, \
{ 12, "ITEM012=", B0, FMT_OCT }, \
{ 13, "ITEM013=", B0, FMT_OCT }, \
{ 14, "ITEM014=", B0, FMT_OCT }, \
{ 15, "ITEM015=", B0, FMT_OCT }, \
{ 16, "ITEM016=", B0, FMT_OCT }, \
{ 17, "ITEM017=", B0, FMT_OCT }, \
{ 18, "ITEM018=", B0, FMT_OCT }, \
{ 19, "ITEM019=", B0, FMT_OCT }, \
{ 20, "ITEM020=", B0, FMT_OCT }, \
{ 21, "ITEM021=", B0, FMT_OCT }, \
{ 22, "ITEM022=", B0, FMT_OCT }, \
{ 23, "ITEM023=", B0, FMT_OCT }, \
{ 24, "ITEM024=", B0, FMT_OCT }, \
{ 25, "ITEM025=", B0, FMT_OCT }, \
{ 26, "ITEM026=", B0, FMT_OCT }, \
{ 27, "ITEM027=", B0, FMT_OCT }, \
{ 28, "ITEM028=", B0, FMT_OCT }, \
{ 29, "ITEM029=", B0, FMT_OCT }, \
{ 30, "ITEM030=", B0, FMT_OCT }, \
{ 31, "ITEM031=", B0, FMT_OCT }, \
{ 32, "ITEM032=", B0, FMT_OCT }, \
{ 33, "ITEM033=", B0, FMT_OCT }, \
{ 34, "ITEM034=", B0, FMT_OCT }, \
{ 35, "ITEM035=", B0, FMT_OCT }, \
{ 36, "ITEM036=", B0, FMT_OCT }, \
{ 37, "ITEM037=", B0, FMT_OCT }, \
{ 38, "ITEM038=", B0, FMT_OCT }, \
{ 39, "ITEM039=", B0, FMT_OCT }, \
{ 40, "ITEM040=", B0, FMT_OCT }, \
{ 41, "ITEM041=", B0, FMT_OCT }, \
{ 42, "ITEM042=", B0, FMT_OCT }, \
{ 43, "ITEM043=", B0, FMT_OCT }, \
{ 44, "ITEM044=", B0, FMT_OCT }, \
{ 45, "ITEM045=", B0, FMT_OCT }, \
{ 46, "ITEM046=", B0, FMT_OCT }, \
{ 47, "ITEM047=", B0, FMT_OCT }, \
{ 48, "ITEM048=", B0, FMT_OCT }, \
{ 49, "ITEM049=", B0, FMT_OCT }, \
{ 50, "ITEM050=", B0, FMT_OCT }, \
{ 51, "ITEM051=", B0, FMT_OCT }, \
{ 52, "ITEM052=", B0, FMT_OCT }, \
{ 53, "ITEM053=", B0, FMT_OCT }, \
{ 54, "ITEM054=", B0, FMT_OCT }, \
{ 55, "ITEM055=", B0, FMT_OCT }, \
{ 56, "ITEM056=", B0, FMT_OCT }, \
{ 57, "ITEM057=", B0, FMT_OCT }, \
{ 58, "ITEM058=", B0, FMT_OCT }, \
{ 59, "ITEM059=", B0, FMT_OCT }, \
{ 60, "ITEM060=", B0, FMT_OCT }, \
{ 61, "ITEM061=", B0, FMT_OCT }, \
{ 62, "ITEM062=", B0, FMT_OCT }, \
{ 63, "ITEM063=", B0, FMT_OCT }, \
{ 64, "ITEM064=", B0, FMT_OCT }, \
{ 65, "ITEM065=", B0, FMT_OCT }, \
{ 66, "ITEM066=", B0, FMT_OCT }, \
{ 67, "ITEM067=", B0, FMT_OCT }, \
{ 68, "ITEM068=", B0, FMT_OCT }, \
{ 69, "ITEM069=", B0, FMT_OCT }, \
{ 70, "ITEM070=", B0, FMT_OCT }, \
{ 71, "ITEM071=", B0, FMT_OCT }, \
{ 72, "ITEM072=", B0, FMT_OCT }, \
{ 73, "ITEM073=", B0, FMT_OCT }, \
{ 74, "ITEM074=", B0, FMT_OCT }, \
{ 75, "ITEM075=", B0, FMT_OCT }, \
{ 76, "ITEM076=", B0, FMT_OCT }, \
{ 77, "ITEM077=", B0, FMT_OCT }, \
{ 78, "ITEM078=", B0, FMT_OCT }, \
{ 79, "ITEM079=", B0, FMT_OCT }, \
{ 80, "ITEM080=", B0, FMT_OCT }, \
{ 81, "ITEM081=", B0, FMT_OCT }, \
{ 82, "ITEM082=", B0, FMT_OCT }, \
{ 83, "ITEM083=", B0, FMT_OCT }, \
{ 84, "ITEM084=", B0, FMT_OCT }, \
{ 85, "ITEM085=", B0, FMT_OCT }, \
{ 86, "ITEM086=", B0, FMT_OCT }, \
{ 87, "ITEM087=", B0, FMT_OCT }, \
{ 88, "ITEM088=", B0, FMT_OCT }, \
{ 89, "ITEM089=", B0, FMT_OCT }, \
{ 90, "ITEM090=", B0, FMT_OCT }, \
{ 91, "ITEM091=", B0, FMT_OCT }, \
{ 92, "ITEM092=", B0, FMT_OCT }, \
{ 93, "ITEM093=", B0, FMT_OCT }, \
{ 94, "ITEM094=", B0, FMT_OCT }, \
{ 95, "ITEM095=", B0, FMT_OCT }, \
{ 96, "ITEM096=", B0, FMT_OCT }, \
{ 97, "ITEM097=", B0, FMT_OCT }, \
{ 98, "ITEM098=", B0, FMT_OCT }, \
{ 99, "ITEM099=", B0, FMT_OCT }, \
{ 100, "TIME=", B0, FMT_2DEC }, \
{ 102, "ITEM102=", B0, FMT_OCT }, \
{ 103, "ITEM103=", B0, FMT_OCT }, \
{ 104, "ITEM104=", B0, FMT_OCT }, \
{ 105, "ITEM105=", B0, FMT_OCT }, \
{ 106, "ITEM106=", B0, FMT_OCT }, \
{ 107, "ITEM107=", B0, FMT_OCT }, \
{ 108, "ITEM108=", B0, FMT_OCT }, \
{ 109, "ITEM109=", B0, FMT_OCT }, \
{ 110, "ITEM110=", B0, FMT_OCT }, \
{ 111, "ITEM111=", B0, FMT_OCT }, \
{ 112, "ITEM112=", B0, FMT_OCT }, \
{ 113, "ITEM113=", B0, FMT_OCT }, \
{ 114, "ITEM114=", B0, FMT_OCT }, \
{ 115, "ITEM115=", B0, FMT_OCT }, \
{ 116, "ITEM116=", B0, FMT_OCT }, \
{ 117, "ITEM117=", B0, FMT_OCT }, \
{ 118, "ITEM118=", B0, FMT_OCT }, \
{ 119, "ITEM119=", B0, FMT_OCT }, \
{ 120, "ITEM120=", B0, FMT_OCT }, \
{ 121, "ITEM121=", B0, FMT_OCT }, \
{ 122, "ITEM122=", B0, FMT_OCT }, \
{ 123, "ITEM123=", B0, FMT_OCT }, \
{ 124, "ITEM124=", B0, FMT_OCT }, \
{ 125, "ITEM125=", B0, FMT_OCT }, \
{ 126, "ITEM126=", B0, FMT_OCT }, \
{ 127, "ITEM127=", B0, FMT_OCT }, \
{ 128, "ITEM128=", B0, FMT_OCT }, \
{ 129, "ITEM129=", B0, FMT_OCT }, \
{ 130, "ITEM130=", B0, FMT_OCT }, \
{ 131, "ITEM131=", B0, FMT_OCT }, \
{ 132, "ITEM132=", B0, FMT_OCT }, \
{ 133, "ITEM133=", B0, FMT_OCT }, \
{ 134, "ITEM134=", B0, FMT_OCT }, \
{ 135, "ITEM135=", B0, FMT_OCT }, \
{ 136, "ITEM136=", B0, FMT_OCT }, \
{ 137, "ITEM137=", B0, FMT_OCT }, \
{ 138, "ITEM138=", B0, FMT_OCT }, \
{ 139, "ITEM139=", B0, FMT_OCT }, \
{ 140, "ITEM140=", B0, FMT_OCT }, \
{ 141, "ITEM141=", B0, FMT_OCT }, \
{ 142, "ITEM142=", B0, FMT_OCT }, \
{ 143, "ITEM143=", B0, FMT_OCT }, \
{ 144, "ITEM144=", B0, FMT_OCT }, \
{ 145, "ITEM145=", B0, FMT_OCT }, \
{ 146, "ITEM146=", B0, FMT_OCT }, \
{ 147, "ITEM147=", B0, FMT_OCT }, \
{ 148, "ITEM148=", B0, FMT_OCT }, \
{ 149, "ITEM149=", B0, FMT_OCT }, \
{ 150, "ITEM150=", B0, FMT_OCT }, \
{ 151, "ITEM151=", B0, FMT_OCT }, \
{ 152, "ITEM152=", B0, FMT_OCT }, \
{ 153, "ITEM153=", B0, FMT_OCT }, \
{ 154, "ITEM154=", B0, FMT_OCT }, \
{ 155, "ITEM155=", B0, FMT_OCT }, \
{ 156, "ITEM156=", B0, FMT_OCT }, \
{ 157, "ITEM157=", B0, FMT_OCT }, \
{ 158, "ITEM158=", B0, FMT_OCT }, \
{ 159, "ITEM159=", B0, FMT_OCT }, \
{ 160, "ITEM160=", B0, FMT_OCT }, \
{ 161, "ITEM161=", B0, FMT_OCT }, \
{ 162, "ITEM162=", B0, FMT_OCT }, \
{ 163, "ITEM163=", B0, FMT_OCT }, \
{ 164, "ITEM164=", B0, FMT_OCT }, \
{ 165, "ITEM165=", B0, FMT_OCT }, \
{ 166, "ITEM166=", B0, FMT_OCT }, \
{ 167, "ITEM167=", B0, FMT_OCT }, \
{ 168, "ITEM168=", B0, FMT_OCT }, \
{ 169, "ITEM169=", B0, FMT_OCT }, \
{ 170, "ITEM170=", B0, FMT_OCT }, \
{ 171, "ITEM171=", B0, FMT_OCT }, \
{ 172, "ITEM172=", B0, FMT_OCT }, \
{ 173, "ITEM173=", B0, FMT_OCT }, \
{ 174, "ITEM174=", B0, FMT_OCT }, \
{ 175, "ITEM175=", B0, FMT_OCT }, \
{ 176, "ITEM176=", B0, FMT_OCT }, \
{ 177, "ITEM177=", B0, FMT_OCT }, \
{ 178, "ITEM178=", B0, FMT_OCT }, \
{ 179, "ITEM179=", B0, FMT_OCT }, \
{ 180, "ITEM180=", B0, FMT_OCT }, \
{ 181, "ITEM181=", B0, FMT_OCT }, \
{ 182, "ITEM182=", B0, FMT_OCT }, \
{ 183, "ITEM183=", B0, FMT_OCT }, \
{ 184, "ITEM184=", B0, FMT_OCT }, \
{ 185, "ITEM185=", B0, FMT_OCT }, \
{ 186, "ITEM186=", B0, FMT_OCT }, \
{ 187, "ITEM187=", B0, FMT_OCT }, \
{ 188, "ITEM188=", B0, FMT_OCT }, \
{ 189, "ITEM189=", B0, FMT_OCT }, \
{ 190, "ITEM190=", B0, FMT_OCT }, \
{ 191, "ITEM191=", B0, FMT_OCT }, \
{ 192, "ITEM192=", B0, FMT_OCT }, \
{ 193, "ITEM193=", B0, FMT_OCT }, \
{ 194, "ITEM194=", B0, FMT_OCT }, \
{ 195, "ITEM195=", B0, FMT_OCT }, \
{ 196, "ITEM196=", B0, FMT_OCT }, \
{ 197, "ITEM197=", B0, FMT_OCT }, \
{ 198, "ITEM198=", B0, FMT_OCT }, \
{ 199, "ITEM199=", B0, FMT_OCT }

static DownlinkListSpec_t CmPoweredListSpec = {
  077774,
  "Powered List",
  DEFAULT_URL,
  {
    DEFAULT_LIST
  }
};

static DownlinkListSpec_t LmOrbitalManeuversSpec = {
  077774,
  "Orbital Maneuvers List",
  DEFAULT_URL,
  {
    DEFAULT_LIST
  }
};

static DownlinkListSpec_t CmCoastAlignSpec = {
  077777,
  "Coast and Align List",
  DEFAULT_URL,
  {
    DEFAULT_LIST
  }
};

static DownlinkListSpec_t LmCoastAlignSpec = {
  077777,
  "Coast and Align List",
  DEFAULT_URL,
  {
    DEFAULT_LIST
  }
};

static DownlinkListSpec_t CmRendezvousPrethrustSpec = {
  077775,
  "Rendezvous and Prethrust List",
  DEFAULT_URL,
  {
      DEFAULT_LIST
  }
};

static DownlinkListSpec_t LmRendezvousPrethrustSpec = {
  077775,
  "Rendezvous and Prethrust List",
  DEFAULT_URL,
  {
      DEFAULT_LIST
  }
};

static DownlinkListSpec_t CmProgram22Spec = {
  077773,
  "Program 22 List",
  DEFAULT_URL,
  {
      DEFAULT_LIST
  }
};

static DownlinkListSpec_t LmDescentAscentSpec = {
  077773,
  "Descent and Ascent List",
  DEFAULT_URL,
  {
      DEFAULT_LIST
  }
};

static DownlinkListSpec_t LmLunarSurfaceAlignSpec = {
  077772,
  "Lunar Surface Align List",
  DEFAULT_URL,
  {
      DEFAULT_LIST
  }
};

static DownlinkListSpec_t CmEntryUpdateSpec = {
  077776,
  "Entry and Update List",
  DEFAULT_URL,
  {
      DEFAULT_LIST
  }
};

static DownlinkListSpec_t LmAgsInitializationUpdateSpec = {
  077776,
  "AGS Initialization and Update List",
  DEFAULT_URL,
  {
      DEFAULT_LIST
  }
};

