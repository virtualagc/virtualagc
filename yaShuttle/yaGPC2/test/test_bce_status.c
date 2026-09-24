/* THE BCE STATUS REGISTER RECORDS THE CAUSE OF AN ERROR TERMINATION
 * (ledger #208; Table 1.2 of the Bus Control Element Principles of
 * Operation, IBM-6246556A part 3, pages 14-16).
 *
 * The manual gives an error termination three parts: the Program Exception
 * bit to 0, the BCE-MSC Indicator bit to 1, and "it records the cause of the
 * error in its own BCE status register".  Only the first two were done, so
 * the register read zero forever -- measured, 2,984 status stores in a run,
 * every one 00000000 -- and the flight software reads that register as the
 * TRANSACTION STATUS of every I/O it performs.  At least one path is gated
 * on it outright: DMIMCD will not look at a display unit's poll reply, and
 * so will never schedule AIG_DEU_LOADER to load that unit, unless the status
 * is non-zero.  A display powered up after the IPLs therefore stayed unloaded
 * for the whole run and drew its foreground over a blank background.
 *
 * WHICH HALF a bit lands in is part of the test, not an implementation
 * detail: the status is stored as a fullword and the flight software reads
 * the two halves separately -- DMIMCD tests halfword 1 (bits 0-15) while
 * AIGDEU tests 3 and 4 -- so a Sync Error and a Time Out are not
 * interchangeable to the software even though both are "an error".
 */
#include <stdio.h>

#include "../src/cpu.h"
#include "../src/iop.h"

static CPU cpu;
static IOP iop;
static int failures;

static void check(bool ok, const char *what) {
    if (ok) return;
    failures++;
    printf("FAIL [bce-status/%s]\n", what);
}

static uint32_t status_of(int p) {
    Register *h = iopls_at(&iop.ls, p, 2, 6);
    Register *l = iopls_at(&iop.ls, p, 2, 7);
    if (h == NULL || l == NULL) return 0xffffffffu;
    return ((uint32_t)register_get16(h) << 16) | (uint32_t)register_get16(l);
}

int main(void) {
    cpu_init(&cpu);
    iop_init(&iop, &cpu);

    /* The table itself: bit 0 is the most significant, so the masks have to
     * come out where the manual's figure puts them. */
    check(BST_M == 0x10000000u, "bit 3 is signature mismatch");
    check(BST_S == 0x00010000u, "bit 15 is sync error");
    check(BST_ST == 0x00000200u, "bit 22 is self test");
    check(BST_ITO == 0x00000040u, "bit 25 is initial time out");
    check(BST_TO == 0x00000020u, "bit 26 is time out");
    check(BST_I == 0x00000004u, "bit 29 is illegal opcode");

    /* A quiet BCE has nothing recorded. */
    check(status_of(6) == 0, "a BCE that has not erred reads zero");

    /* AND THE HALVES ARE THE HALVES.  A sync error is in the half DMIMCD
     * reads; a time out is not, which is why the two are not the same thing
     * to the flight software. */
    iop_bce_error_terminate(&iop, 6, BST_S);
    check(status_of(6) == BST_S, "a sync error is recorded");
    check((status_of(6) >> 16) != 0, "and lands in the half DMIMCD reads");

    iop_bce_error_terminate(&iop, 7, BST_ITO);
    check(status_of(7) == BST_ITO, "an initial time out is recorded");
    check((status_of(7) >> 16) == 0, "and is in the low half, not DMIMCD's");

    /* Causes ACCUMULATE: the register is cleared by the program that stores
     * it (#SSC), not by the next error. */
    iop_bce_error_terminate(&iop, 7, BST_TO);
    check(status_of(7) == (BST_ITO | BST_TO), "a second cause is OR'ed in");

    /* ONE BCE'S ERROR IS NOT ANOTHER'S.  The page is the BCE's own, not
     * whichever one the local store happens to be showing. */
    check(status_of(6) == BST_S, "BCE 6 is untouched by BCE 7's errors");
    check(status_of(8) == 0, "and a BCE that never erred still reads zero");

    /* A termination whose cause the model cannot name yet records nothing
     * rather than something invented. */
    iop_bce_error_terminate(&iop, 8, 0);
    check(status_of(8) == 0, "an unattributed termination invents no cause");

    /* The other two parts of the termination still happen. */
    check(iop_proc_get(&iop.regProgExcept, 8) == 0, "program exception to 0");
    check(iop_proc_get(&iop.regIndicator, 8) == 1, "indicator to 1");

    if (failures == 0) {
        printf("15/15 BCE status register checks passed\n");
        return 0;
    }
    printf("%d BCE status register check(s) failed\n", failures);
    return 1;
}
