#include "hal_fpu.h"
#include <string.h>

void hal_fpu_init(hal_fpu_state_t *fpu) {
    memset(fpu, 0, sizeof(*fpu));
}
