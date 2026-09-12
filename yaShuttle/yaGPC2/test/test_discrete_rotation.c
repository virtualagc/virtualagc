/* The rotation table from SSSRC/BILDNEW5.asm, "GPC DISCRETE INPUTS AND
 * OUTPUTS":
 *      STATION ID   N+1  N+2  N+3  N+4
 *               1     2    3    4    5
 *               2     3    4    5    1
 *               3     4    5    1    2
 *               4     5    1    2    3
 *               5     1    2    3    4
 * Read as: at station ID m, the group numbered N+k carries GPC TABLE[m][k].
 * So a signal from GPC n must arrive at reader m in group k where
 * TABLE[m][k] == n -- for every ordered pair.  */
#include <stdio.h>
#include <stdint.h>
uint32_t discretes_rotate_out(int sourceGpc, int readerGpc, uint32_t outMask);

static const int TABLE[6][5] = {   /* [id][k], k 1..4 */
    {0,0,0,0,0},
    {0, 2,3,4,5},
    {0, 3,4,5,1},
    {0, 4,5,1,2},
    {0, 5,1,2,3},
    {0, 1,2,3,4},
};
#define BIT(n) (0x80000000u >> (n))

int main(void) {
    int bad = 0, checked = 0;
    for (int m = 1; m <= 5; m++) {           /* the reader */
        for (int k = 1; k <= 4; k++) {
            int n = TABLE[m][k];             /* whose signal lands in N+k */
            /* All four lines at once: STBY 20, BFS RUN 22, RUN 24, SYNC 28. */
            uint32_t out = BIT(20) | BIT(22) | BIT(24) | BIT(28);
            uint32_t want = BIT(20 + k - 1) | BIT(8 + k - 1) |
                            BIT(24 + k - 1) | BIT(28 + k - 1);
            uint32_t got = discretes_rotate_out(n, m, out);
            checked++;
            if (got != want) {
                printf("  GPC%d seen by GPC%d (N+%d): got %08x want %08x\n",
                       n, m, k, got, want);
                bad++;
            }
        }
        /* A computer is not its own neighbour. */
        if (discretes_rotate_out(m, m, 0xffffffffu) != 0u) {
            printf("  GPC%d sees itself\n", m);
            bad++;
        }
        checked++;
    }
    /* The 3-bit sync code must rotate as a UNIT: null X'0888' is bits
     * 20, 24 and 28 set together. */
    for (int m = 1; m <= 5; m++)
        for (int k = 1; k <= 4; k++) {
            int n = TABLE[m][k];
            uint32_t got = discretes_rotate_out(n, m, 0x00000888u  /* TCVTNULS: bits 20, 24, 28 */);
            uint32_t want = BIT(20+k-1) | BIT(24+k-1) | BIT(28+k-1);
            checked++;
            if (got != want) { printf("  null code GPC%d->GPC%d wrong\n", n, m); bad++; }
        }
    printf("ROTATION: %d checks, %d mismatches against BILDNEW5's table\n",
           checked, bad);
    return bad != 0;
}
