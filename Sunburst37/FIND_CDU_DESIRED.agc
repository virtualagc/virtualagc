### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     FIND_CDU_DESIRED.agc
## Purpose:      A module for revision 0 of BURST120 (Sunburst). It 
##               is part of the source code for the Lunar Module's
##               (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      www.ibiblio.org/apollo/index.html
## Mod history:  2016-09-30 RSB  Created draft version.
##               2016-10-29 MAS  Transcribed.
##		 2016-12-06 RSB	 Comment-proofing via octopus/ProoferComments;
##				 changes were made.

## Page 838
# THIS ROUTINE FINDCDUD COMPUTES DESIRED CDU,S WHICH CAN BE FED TO
# DAP LATER ON.
# DESIRED CDU,S WILL BE IN 2,S COMP

# INPUT

# DESIRED THRUST VECTOR AXISD COMING FROM GUIDANCE EQUATIONS
# CDUX,CDUY,CDUZ INFORM OF A SP VECTOR CDUTEMP,+2,+4.
# DELV HALF UNIT VECTOR. PIPAS READING
# AXISD IS A HALF UNIT VECTOR
# CDUX,Y,Z  ARE IN 2,S COMP

# THIS ROUTINE CAN BE ENTERED FROM INTERPRETIVE . CALL FINDCDUD

# CALLING SEQUENCE
# L-1  CALL
# L        FINDCDUD
# L+1              INTERPRETIVE RETURN



# USER TO HAVE A UNIT VECTOR  AXIS   (1,0,0)



                BANK            30
                EBANK=          DELR
2/PI            2DEC            .6366198

LIMOMG          2DEC            .0001234



FINDCDUD        SETPD           EXIT
                                0
                CA              CDUTEMP         +2
                TS              SINCDU                          # TEMPORARY LOCATION FOR CDUY
                CA              CDUTEMP         +4
                TS              SINCDU          +2              # TEMPORARY LOCATION FOR CDUZ
                CA              CDUTEMP
                TS              SINCDU          +4              # TEMPORARY LOCATION FOR CDUX



# AXISFILT   COMPUTES AXIS AND CORRECTS IT FOR  QUANTIZATION ERROR AND OTH
# ER ERRORS


                EBANK=          OMEGA
                CAF             PRIO3                           # OCT  03000     SWITCH EBANK
## Page 839
                XCH             EBANK
                TS              MPAC
                CAF             ZERO
                TS              TEMX                            # SQOMEGA
                TS              TEMX            +1              # SQOMEGA  +1
                INHINT
                CAE             OMEGAP
                EXTEND
                SQUARE
                DAS             TEMX                            # SQOMEGA
                CAE             OMEGAQ
                EXTEND
                SQUARE
                DAS             TEMX                            # SQOMEGA
                CAE             OMEGAR
                EXTEND
                SQUARE
                DAS             TEMX                            # SQOMEGA
                RELINT
                XCH             MPAC
                TS              EBANK
                TC              INTPRET
                EBANK=          DELR
                STQ
                                RETSAVE
AXISFILT        DLOAD           DSU



                                TEMX                            # SQOMEGA
                                LIMOMG
                BPL             LXA,1
                                ROTANGLE
                                FIXLOC
                INCR,1          XCHX,1
                                20D
                                S1
                VLOAD
                                SINCDU                          # TEMPORARY LOCATION FOR CDUY,Z,X IN
                STORE           20D                             # SP  2,S COMP
                VLOAD           UNIT
                                DELV
                STORE           32D
                CALL
                                SMNB                            # TRANSFORM DELV FROM SM TO NB
                SETPD           VSU
                                0
                                AXIS
                VSR3            VAD
                                AXIS

## Page 840
                UNIT
                STORE           AXIS
ROTANGLE        LXA,1           INCR,1
                                FIXLOC
                                20D
                XCHX,1          VLOAD
                                S1
                                SINCDU                          # TEMPORARY LOCATION FOR CDUY,Z,X IN
                STORE           20D                             # SP  2,S COMP
                VLOAD
                                AXIS
                STORE           32D
                CALL                                            # TRANSFORM  AXIS FROM NB TO SM
                                NBSM
                SETPD           VXV
                                0
                                AXISD
                VXSC
                                2/PI
                STORE           10D                             # DTHETASM  SCALETO ONE REVOLUTION
                CALL                                            # COMPUTE SIN AND COS OF CDUS FOR
                                SINCOSCD                        # LATER USE


# SMCDURES     COMPUTES CDU(GIMBAL) ANGLES FROM INCREMENTAL
# CHANGES ABOUT SM AXES.    IT REQUIRES  SM  INCREMENTAL CHANGES
# AS DP  VECTOR SCALED AT  ONE REVOLUTION(DTHETASM,+2,+4).  SIN,COS(CDUX,Y
# ,Z)   ARE IN SINCDU,+2,+4 AND COSCDU,+2,+4  RESPECTIVELY,SCALED TO 2.
# CDU INCREMENTS  ARE PLACED IN DCDU,+2,+4   SCALED TO ONE REVOLUTION



SMCDURES        DLOAD           DMP
                                10D                             # DTHETASM
                                COSCDU          +2
                PDDL            DMP
                                14D                             # DTHETASM +4
                                SINCDU          +2
                BDSU
                DDV
                                COSCDU          +4
                STORE           20D                             # DCDU
                DMP             SL1                             # SCALE
                                SINCDU          +4
                BDSU
                                12D                             # DTHETASM +2
                STODL           22D                             # DCDU +2
                                10D
                DMP             PDDL
                                SINCDU          +2
## Page 841
                                14D                             # DTHETASM +4
                DMP             DAD
                                COSCDU          +2
                SL1                                             # SCALE
                STODL           24D                             # DCDU +4
                                22D                             # DCDU +2
                DMP             DCOMP
                                SINCDU          +4              # DCDUX =-DCDUY*SIN(CDUZ)
                SL1                                             # SCALE
                STORE           20D                             # DCDU
                VLOAD           VAD
                                20D                             # DCDU
                                CDUTEMP
                RTB
                                V1STO2S                         # SCALE FROM 1,S TO 2,S
                STORE           CDUXD
                GOTO
                                RETSAVE


# SINCOSCD    COMPUTES SIN AND COS OF CDU  AND STORES AS DP VECTORS
# SINCDU ,COSCDU
# INPUT IS CDUS AS A VECTOR CDUTEMP
# OUTPUT IS SIN AND COS OF CDU,S
# CDUS ARE AVAILABLE IN 2,S COMP
# SIN AND COS ARE SCALED TO 2
# SINCOSCD CAN BE ENTERED FROM INTERPRETIVE



SINCOSCD        SSP             AXT,1                           # SET X1 TO 6
                                S1                              # SET S1 TO 2
                OCT             2
                OCT             6
REPEAT1         SLOAD*          RTB
                                CDUTEMP         +6,1
                                CDULOGIC                        # CONVERT CDU FROM 2,S TO 1,S.  SCALE
                STORE           CDUTEMP         +6,1            # TO ONE REVOLUTION
                SIN
                STORE           SINCDU          +6,1
                DLOAD*          COS
                                CDUTEMP         +6,1
                STORE           COSCDU          +6,1
                TIX,1           RVQ
                                REPEAT1
