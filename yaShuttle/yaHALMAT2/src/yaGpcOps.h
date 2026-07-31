#ifndef YAGPC_OPS_H
#define YAGPC_OPS_H

#include "yaGpcIntegration.h"

/* engine/debugger/initializer/release/debuggerStateCreate/
 * debuggerStateDestroy are all reachable only through this table now
 * (issue #79: a driver working only from yaGpcIntegration.h's own types
 * must be able to manage a GPC instance's and a debug session's full
 * lifetime without reaching for yaHALMAT2-specific function names). */
extern const GpcOps yaHALMAT2_ops;

#endif
