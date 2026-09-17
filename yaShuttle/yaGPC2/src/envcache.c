/* See envcache.h for why this exists. */
#include "envcache.h"

#include <stdint.h>
#include <stdlib.h>

/* 128 slots against ~50 distinct variables: enough that the literals in any
 * one hot path are unlikely to collide, and small enough to stay in cache.
 * A collision is not an error -- the slot is simply rewritten, and the only
 * cost is the next lookup of the evicted name. */
#define ENV_MEMO 128
#define ENV_MEMO_SLOT(p) ((((uintptr_t)(p)) >> 3) & (ENV_MEMO - 1))

static _Thread_local const char *envMemoKey[ENV_MEMO];
static _Thread_local const char *envMemoVal[ENV_MEMO];
/* A separate "this slot has been answered" flag, because a cached NULL --
 * the variable is not set -- is a real answer and the common one. */
static _Thread_local unsigned char envMemoFilled[ENV_MEMO];

const char *yagpc_getenv(const char *name)
{
    size_t h = ENV_MEMO_SLOT(name);
    if (envMemoFilled[h] && envMemoKey[h] == name)
        return envMemoVal[h];
    const char *v = getenv(name);
    envMemoKey[h] = name;
    envMemoVal[h] = v;
    envMemoFilled[h] = 1;
    return v;
}
