/* <strings.h> for the native Windows build; see posix_compat.h. */
#ifndef YAGPC_WIN32_STRINGS_H
#define YAGPC_WIN32_STRINGS_H

#include <string.h>

#define strcasecmp  _stricmp
#define strncasecmp _strnicmp

#endif
