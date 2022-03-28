// file = 0; split type = patterns; threshold = 100000; total count = 0.
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "rmapats.h"

scalar dummyScalar;
scalar fScalarIsForced=0;
scalar fScalarIsReleased=0;
scalar fScalarHasChanged=0;
scalar fForceFromNonRoot=0;
scalar fNettypeIsForced=0;
scalar fNettypeIsReleased=0;
void  hsG_0 (struct dummyq_struct * I1016, EBLK  * I1017, U  I719);
void  hsG_0 (struct dummyq_struct * I1016, EBLK  * I1017, U  I719)
{
    U  I1250;
    U  I1251;
    U  I1252;
    struct futq * I1253;
    I1250 = ((U )vcs_clocks) + I719;
    I1252 = I1250 & 0xfff;
    I1017->I652 = (EBLK  *)(-1);
    I1017->I656 = I1250;
    if (I1250 < (U )vcs_clocks) {
        I1251 = ((U  *)&vcs_clocks)[1];
        sched_millenium(I1016, I1017, I1251 + 1, I1250);
    }
    else if ((peblkFutQ1Head != ((void *)0)) && (I719 == 1)) {
        I1017->I657 = (struct eblk *)peblkFutQ1Tail;
        peblkFutQ1Tail->I652 = I1017;
        peblkFutQ1Tail = I1017;
    }
    else if ((I1253 = I1016->I981[I1252].I669)) {
        I1017->I657 = (struct eblk *)I1253->I668;
        I1253->I668->I652 = (RP )I1017;
        I1253->I668 = (RmaEblk  *)I1017;
    }
    else {
        sched_hsopt(I1016, I1017, I1250);
    }
}
#ifdef __cplusplus
extern "C" {
#endif
void SinitHsimPats(void);
#ifdef __cplusplus
}
#endif
