/* THE KU-BAND RENDEZVOUS RADAR, as the flight software's RR SOP (GYNRRP)
 * sees it: ten words on forward MDM 3, card 3 channel 3 (FIOFFIC3,
 * X'24C69', in FF3's MFE sequence of FIOMFBCE).  See kuradar.c for the
 * sources and the model.
 *
 * Driven by mdmdev.c, which owns the MDMs; ON with YAGPC_MDM_DEVICES and
 * YAGPC_VEHDYN (it needs the truth vehicle and vehdyn's target). */
#ifndef YAGPC_KURADAR_H
#define YAGPC_KURADAR_H

#include <stdbool.h>
#include <stdint.h>

/* The panel's word (panel A1U, from panelO6.py on FF3's hardware-side
 * bus: op 4 VALUE, type 9, one word).  Until a panel sends one the radar
 * is off. */
#define KU_PWR_ON        0x8000u     /* KU-BAND POWER ON (else STBY / OFF) */
#define KU_MODE_MASK     0x0003u     /* MODE: */
#define KU_MODE_COMM     0x0000u
#define KU_MODE_PASSIVE  0x0001u     /*   RDR PASSIVE (skin track) */
#define KU_MODE_COOP     0x0002u     /*   RDR COOP (a transponder; the ISS has none) */
#define KU_SEL_MASK      0x000Cu     /* STEERING MODE: */
#define KU_SEL_GPC       0x0000u
#define KU_SEL_DESIG     0x0004u     /*   GPC DESIG */
#define KU_SEL_AUTO      0x0008u     /*   AUTO TRACK */
#define KU_SEL_SLEW      0x000Cu     /*   MAN SLEW */
#define KU_OUT_HIGH      0x0010u     /* RADAR OUTPUT HIGH (else LOW) */
#define KU_SELF_TEST     0x0020u     /* the SM antenna self-test running */

void kuradar_panel(uint16_t word, double t);

/* The ten data words, at vehicle time t (s). */
void kuradar_read(uint16_t w[10], double t);

/* A session capture, and back (tCap: the captured vehicle time, rebased to
 * 0 as vehdyn does). */
int kuradar_save(double *b, int max);
void kuradar_load(const double *b, int n, double tCap);

void kuradar_report(void);

/* For the tests: the truth the last read measured (range ft, range rate
 * ft/s, and the line of sight in the radar's sensor axes, CGNS_M_BODY_TO_RR
 * from body), whether it was locked; and noise off (true) or on. */
typedef struct {
    double rangeFt, rdotFps, u[3];
    bool locked, visible;
} KuTruth;
void kuradar_test_truth(KuTruth *o);
void kuradar_test_noiseless(bool off);

#endif
