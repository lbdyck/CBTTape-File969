         TITLE 'ROUTINE TO EXTRACT PDSE DIRECTORY INFORMATION'
*-------------------------------------------------------------------*
* NAME:         PDSEGENI                                            *
* AUTHOR:       REM PERRETTA                                        *
* LANGUAGE:     IBM ASM/370                                         *
* REMARKS:      THIS ROUTINE WILL EXTRACT PDS AND PDSE DIRECTORY    *
*               INFORMATION, USING THE GET_ALL FUNCTION OF THE      *
*               DESERV MACRO.                                       *
*                                                                   *
* INVOCATION:   FROM A REXX EXEC AS FOLLOWS:                        *
*                                                                   *
*               DDNAME= 'PDSEFILE'                                  *
*               X= PDSEGENI(DDNAME)                                 *
*                                                                   *
*               WHERE DDNAME MUST CONTAIN THE NAME OF THE ALLOCATED *
*               PDS OR PDSE.                                        *
*                                                                   *
* RETURN CODES: THE FOLLOWING VALUES ARE RETURNED IN THE RESULT     *
*               FIELD OF THE REXX EVALUATION BLOCK:                 *
*                                                                   *
*               RETURN CODE              DESCRIPTION                *
*                                                                   *
*                    0                   SUCCESSFUL INVOCATION      *
*                   -1                   NO ARGUMENTS FOUND         *
*                   -2                   DDNAME LENGTH ERROR        *
*                   -3                   DDNAME IS ALL SPACES       *
*                   -4                   DDNAME IS NOT ALLOCATED    *
*                   -5                   OPEN ERROR                 *
*                   -6                   IKJCT441 INVOCATION ERROR  *
*                   -7                   DESERV INVOCATION ERROR    *
*                   -8                   NO SMDE ENTRIES            *
*                   -9                   LIBRARY TYPE IS NOT A PDS  *
*                                        OR PDSE                    *
*                   -10                  PDS OR PDSE IS NOT A       *
*                                        PROGRAM TYPE               *
*                   -11                  IKJCT441 INVOCATION ERROR  *
*                   -12                  IKJCT441 INVOCATION ERROR  *
*                                                                   *
* INVOCATION:   INFORMATION FOR EACH PDS OR PDSE MEMBER IS RETURNED *
*               IN THE FOLLOWING REXX STEM VARIABLES:               *
*                                                                   *
*                   MEMBER.0            NUMBER OF ENTRIES           *
*                   MEMBER.N            PDS OR PDSE DIRECTORY       *
*                                       INFORMATION                 *
*                                                                   *
*              REFER TO THE ASSEMBLER VARIABLE PDS_MEMBER_VARIABLE, *
*              FOR A DESCRIPTION OF THE DIRECTORY INFORMATION THAT  *
*              IS RETURNED IN REXX VARIABLE MEMBER.N.               *
*                                                                   *
* AUTHOR:       R F PERRETTA                                        *
*               SYSTEMS CONSULTANT                                  *
*               MILLENIUM COMPUTER CONSULTANCY (UK)                 *
*                                                                   *
*-------------------------------------------------------------------*
*                                                                   *
* UPDATED BY GP@P6 IN JUNE 2016                                     *
* IN AN EFFORT TO ADD SUPPORT FOR MEMBER GENERATIONS.               *
*                                                                   *
* UPDATED BY *LBD* IN JUNE 2016 BY LIONEL DYCK                      *
* FOR USE IN THE PDSEGEN APPLICATION. NOW ONLY SUPPORTS             *
* PDSE V2 GENERATION DATASETS.                                      *
*                                                                   *
* UPDATE BY *LBD* JAN 2018 CHANGE DESERV BUFFER FROM 1024 TO 10240  *
* TO SUPPORT LARGER PDSE MEMBER COUNTS - UP TO 22000 MEMBERS +/-    *
*                                                                   *
* UPDATE BY *LBD* MAY 2020 TO ADD DCBE WITH EADSCB=OK TO SUPPORT    *
* EAV VOLUME LOCATIONS OF A PDS/PDSE.                               *
*                                                                   *
* UPDATE BY GAP JUNE 2020 TO RELOCATE THE DCBE POINTER TO RESOLVE   *
* AND ISSUE IF THIS LMOD IS IN LINKLIST.                            *
*                                                                   *
* THE MEMBER. VARIABLE LAYOUT:                                      *
*                                                                   *
*    FIELD    START LENGTH                                          *
*    HEADER   1     4  PDSE                                         *
*    MEMBER   5     8                                               *
*    ABSGEN   14    6                                               *
*    VRM      22    6                                               *
*    CDATE    35    7   YYYYDDD                                     *
*    ALIASF   43    1   Y OR N FOR ALIAS                            *
*    MDATE    49    7   YYYYDDD                                     *
*    MTIME    56    7   0HHMMSS                                     *
*    USERID   63    8                                               *
*    MMOD     72    2   HEX MOD RECORDS                             *
*    CUR SIZE 75    5                                               *
*    INIT SIZE 79   4                                               *
*                                                                   *
*-------------------------------------------------------------------*
         TITLE 'EQUATES'
R0       EQU   0                       REGISTER 0
R1       EQU   1                       REGISTER 1
R2       EQU   2                       REGISTER 2
R3       EQU   3                       REGISTER 3
R4       EQU   4                       REGISTER 4
R5       EQU   5                       REGISTER 5
R6       EQU   6                       REGISTER 6
R7       EQU   7                       REGISTER 7
R8       EQU   8                       REGISTER 8
R9       EQU   9                       REGISTER 9
R10      EQU   10                      REGISTER 10
R11      EQU   11                      REGISTER 11
R12      EQU   12                      REGISTER 12
R13      EQU   13                      REGISTER 13
R14      EQU   14                      REGISTER 14
R15      EQU   15                      REGISTER 15
ZERO     EQU   X'00'                   ZERO
SPACE    EQU   C' '                    SPACE
SIGNF    EQU   X'F0'                   POSITIVE SIGN
MAIN_AMODE24   EQU   X'00'             MAIN  AMODE 24  IN PMAR
MAIN_AMODE31   EQU   X'02'             MAIN  AMODE 31  IN PMAR
MAIN_AMODEANY  EQU   X'03'             MAIN  AMODE ANY IN PMAR
ALIAS_AMODE24  EQU   X'00'             ALIAS AMODE IN 24 IN PMAR
ALIAS_AMODE31  EQU   X'08'             ALIAS AMODE 31  IN PMAR
ALIAS_AMODEANY EQU   X'0C'             ALIAS AMODE ANY IN PMAR
PDSEGENI RSECT
PDSEGENI AMODE 31
PDSEGENI RMODE ANY
         BAKR  R14,0                   SAVE CALLERS ARS + GPRS
*                                      IN THE LINKAGE STACK
         USING PDSEGENI,R12            INFORM THE ASSEMBLER
         LAE   R12,0(R15,0)            SETUP PROGRAM BASE REGISTER
         LR    R3,R1                   SAVE PARMS
         USING EFPL,R3                 ADDR REXX FUNC PARMS
         L     R9,=AL4(WORKALEN)       WORK AREA LENGTH
         STORAGE OBTAIN,                                               X
               LENGTH=(R9),                                            X
               ADDR=(R10),                                             X
               SP=0,                                                   X
               KEY=8,                                                  X
               LOC=BELOW,                                              X
               COND=NO,                                                X
               RELATED=(FREEWORK,'FREE WORK AREA')
         LAE   R13,0(R10,0)            @ THE WORKAREA
         USING SAVEAREA,R13            INFORM THE ASSEMBLER
         LA    R0,SAVEAREA              @ THE WORKAREA
         ICM   R1,B'1111',=AL4(WORKALEN) LENGTH
         SR    R14,R14                 ZEROFILL
         SR    R15,R15                 PROBAGATE
         MVCL  R0,R14                  CLEAR THE AREA
         MVC   PREVSA,=C'F1SA'         PUT ACRONYM INTO SAVEAREA
*                                      TO INDICATE STATUS SAVED ON
*                                      THE LINKAGE STACK.
         TITLE 'MAIN PROGRAM CONTROL'
CONTROL  EQU   *
         BAS   R2,INIT                 PERFORM INITIALIZATION
         BAS   R2,GETARGS              GET THE PDS/PDSE DDNAME
         LTR   R15,R15                 DDNAME OBTAINED?
         BNZ   RETURN                  NO
         BAS   R2,OPEN                 OPEN THE PDSE
         LTR   R15,R15                 LIBRARY OPENED?
         BNZ   RETURN                  NO
         BAS   R2,DESERV               ISSUE THE DESERV
         LTR   R15,R15                 DE OBTAINED?
         BNZ   CLOSE_PDSE              NO
         BAS   R2,PROCESS_SMDE         PROCESS THE SMDE ENTRIES
CLOSE_PDSE EQU *
         BAS   R2,CLOSE                CLOSE THE PDSE
RETURN   EQU   *
         LAE   R1,0(R13,0)             ADDRESS TO FREE
         L     R9,=AL4(WORKALEN)       WORK AREA LENGTH
         STORAGE RELEASE,                                              X
               ADDR=(R1),                                              X
               LENGTH=(R9),                                            X
               SP=0,                                                   X
               KEY=8,                                                  X
               COND=NO,                                                X
               RELATED=(GETWORK,'OBTAIN WORK AREA')
EXIT     EQU   *
         XR    R15,R15                 SWITCH THE RETURN CODE
         PR                            RESTORE CALLER'S ARS
*                                      GPR'S 2-14 AND RETURN
*                                      TO CALLER
         TITLE 'LETS DO SOME INITIALIZATION'
INIT     EQU   *
*...................................................................
*                                                                  .
*  LET'S ADDRESS THE CVT AND BITS.                                 .
*...................................................................
         USING PSA,0                   INFORM THE ASSEMBLER
         L     R8,FLCCVT               @ OF THE CVT
         USING CVT,R8                  INFORM THE ASSEMBLER
         MVC   PDSEDCB,PDSECB          SETUP PDSE DCB AREA
         MVC   OPENARA,OPENLST         SETUP OPEN MACRO AREA
         MVC   CLOSEARA,CLOSELST       SETUP CLOSE MACRO AREA
         MVC   DSABAREA,DSABLST        SETUP GETDSAB MACRO AREA
         LA    R9,PDSEDCB              @ PDSE DCB
         USING IHADCB,R9               INFORM THE ASSEMBLER
         ZAP   STEMNO,=P'0'            SET TO ZERO
         BR    R2                      RETURN TO CALLER
         TITLE 'GET THE REXX ARGUMENT'
*...................................................................
*                                                                  .
* GET THE PDS OR PDSE ALLOCATED DDNAME.                            .
*...................................................................
GETARGS  EQU   *
         XR    R15,R15                 ZEROIZE
         L     R4,EFPLEVAL             ADDR OF ADDR
         L     R4,0(,R4)               REXX EVAL BLOCK ADDR
         USING EVALBLOCK,R4            ADDRESS IT
         L     R5,EFPLARG              REXX ARG LIST
         USING ARGTABLE_ENTRY,R5       ADDRESS ARG TABLE
         CLC   0(4,R5),=XL4'FFFFFFFF'  ANY ARGS?
         BNE   PROCARGS                YES - SOMETHING IS THERE
         MVC   EVALBLOCK_EVLEN(4),=F'2'   SET LENGTH OF RESULT
         MVC   EVALBLOCK_EVDATA(2),=C'-1' MOVE IN RESULT DATA
         LA    R15,4(0,0)              SET RC = 4
         BR    R2                      RETURN TO CALLER
*------------------------------------------------------------------ *
* PROCESS THE FIRST ARG PASSED IN THE REXX COMMAND. THIS MUST BE    *
* THE DDNAME OF THE ALLOCATED PDS OR PDSE.                          *
*------------------------------------------------------------------ *
PROCARGS EQU   *
         L     R6,ARGTABLE_ARGSTRING_PTR     R6 POINTS TO ARG
         L     R7,ARGTABLE_ARGSTRING_LENGTH  R7 POINTS TO LENGTH
         C     R7,=F'8'                LENGTH > 8?
         BH    LENERR                  YES - ERROR
         BCTR  R7,0                    -1 FOR MVC
         EX    R7,DDNSPACE             ALL SPACES?
         BE    ALLSPACE                YES
         MVI   DDNAME,C' '             CLEAR THEDDNAME
         MVC   DDNAME+1(L'DDNAME-1),DDNAME FIELD TO BLANKS
         EX    R7,DDNMOVE              MOVE THE PDS/PDSE DDN
         GETDSAB DDNAME=DDNAME,        POINT TO THE DDNAME             X
               DSABPTR=DSABPTR,        DSAB POINTER                    X
               MF=(E,DSABAREA)         GETDSAB MACRO AREA
         LTR   R15,R15                 DSAB FOUND?
         BNZ   DDNALLOC                NO
         XR    R15,R15                 ALL OK
         MVC   EVALBLOCK_EVLEN(4),=F'1'    SET LENGTH OF RESULT
         MVC   EVALBLOCK_EVDATA(2),=C'0'   MOVE IN RESULT DATA
         BR    R2                      RETURN TO CALLER
LENERR   EQU   *
         MVC   EVALBLOCK_EVLEN(4),=F'2'    SET LENGTH OF RESULT
         MVC   EVALBLOCK_EVDATA(2),=C'-2'  MOVE IN RESULT DATA
         LA    R15,4(0,0)                  SET RC = 4
         BR    R2                      RETURN TO CALLER
ALLSPACE EQU   *
         MVC   EVALBLOCK_EVLEN(4),=F'2'    SET LENGTH OF RESULT
         MVC   EVALBLOCK_EVDATA(2),=C'-3'  MOVE IN RESULT DATA
         LA    R15,4(0,0)                  SET RC = 4
         BR    R2                      RETURN TO CALLER
DDNALLOC EQU   *
         MVC   EVALBLOCK_EVLEN(4),=F'2'    SET LENGTH OF RESULT
         MVC   EVALBLOCK_EVDATA(2),=C'-4'  MOVE IN RESULT DATA
         LA    R15,4(0,0)                  SET RC = 4
         BR    R2                      RETURN TO CALLER
DDNMOVE  MVC   DDNAME(*-*),0(R6)       MOVE THE PDS/PDSE DDN
DDNSPACE CLC   0(*-*,R6),=8X'40'       ALL SPACES
         TITLE 'OPEN THE PDS OR PDSE'
OPEN     EQU   *
*...................................................................
*                                                                  .
* OPEN THE PDS/PDSE.                                               .
*                                                                  .
*...................................................................
         XR    R15,R15                 ZEROIZE
         MVC   DCBDDNAM,DDNAME         PDS/PDSE DDNAME
         LA    R1,IHADCB+(DCBE-PDSECB) RELOCATED DCBE ADDRESS  *GAP*
         ST    R1,DCBDCBE              STORE POINTER IN DCB    *GAP*
         LA    R1,OPENARA              @ THE OPEN AREA CB
         OPEN  ((R9),INPUT),MODE=31,MF=(E,(R1)) OPEN THE PDSE
         TM    DCBOFLGS,DCBOFOPN       OPEN SUCCESSFUL?
         BZ    OPENERR                 NO - LET'S ABEND
         MVC   ISITAREA,ISITLST        PRIME PARAMETER LIST
         USING ISM,ISITAREA
         ISITMGD DCB=(R9),DATATYPE=YES,MF=(E,ISITAREA)
         LAM   R0,R0,ZEROS             CLEAR AR0
         BR    R2                      RETURN TO CALLER
OPENERR  EQU   *
         MVC   EVALBLOCK_EVLEN(4),=F'2'   SET LENGTH OF RESULT
         MVC   EVALBLOCK_EVDATA(2),=C'-5' MOVE IN RESULT DATA
         LA    R15,4(0,0)              SET RC = 4
         BR    R2                      RETURN TO CALLER
         TITLE 'CLOSE THE PDS OR PDSE'
CLOSE    EQU   *
*...................................................................
*                                                                  .
* CLOSE THE PDS/PDSE.                                              .
*                                                                  .
*...................................................................
         LA    R1,CLOSEARA                @ THE CLOSE AREA CB
         CLOSE ((R9)),MODE=31,MF=(E,(R1)) CLOSE TAPE DATASET
         BR    R2                      RETURN TO CALLER
         TITLE 'ISSUE THE DESERV MACRO'
*...................................................................
*                                                                  .
* DESERV INVOCATION                                                .
*                                                                  .
*...................................................................
DESERV   EQU   *
         STCM  R2,B'1111',DESERV_ENTRY STORE THE RETURN ADDRESS
         MVC   DESERVA,DESERVL         MOVE THE DESERV PARAMETER AREA
         TM    ISMOFLG2,ISMMGENS       GENERATIONS ENABLED?
         BO    DSRVGEN                 YES
         DESERV FUNC=GET_ALL,          GET ALL                         X
               AREAPTR=DESERV_BUFFER@, BUFFER ADDRESS                  X
               CONCAT=0,               FIRST PDSE IN CONCATENATION     X
               CONN_INTENT=NONE,       NO CONNECTION                   X
               DCB=(R9),               DCB ADDRESS                     X
               ENTRY_GAP=0,            NO RESERVED SPACE               X
               RETCODE=DESERV_RETCODE, RETURN CODE                     X
               RSNCODE=DESERV_RSNCODE, REASON CODE                     X
               MF=(E,DESERVA)          RE-ENTRANT AREA
         B     DSRVOVER
DSRVGEN  L     R0,DESERV_BFL           GET ARBITRARY BUFFER SIZE
         GETMAIN RU,LV=(0),LOC=(31,64) GET A BUFFER FOR DESERV
         ST    R1,DESERV_BUFFER@       SAVE THE STORAGE ADDRESS
         LR    R2,R1                   POINT TO THE NEW STORAGE
         L     R0,DESERV_BFL           IN CASE SVC CHANGED GPR0
         DESERV FUNC=GET_ALL_G,        GET ALL GENERATIONS             X
               AREA=((R2),(R0)),       BUFFER ADDRESS AND LENGTH       X
               DCB=(R9),               DCB ADDRESS                     X
               RETCODE=DESERV_RETCODE, RETURN CODE                     X
               RSNCODE=DESERV_RSNCODE, REASON CODE                     X
               MF=(E,DESERVA)          RE-ENTRANT AREA
DSRVOVER LMH   R15,R1,ZEROS            CLEAR REGISTER HIGH HALVES
         LTR   R15,R15                 DESERV OK?
         BZ    DESERV_EXIT             YES
         MVC   ECODE,=AL4(TSVEUPDT)    UPDATE OR CREATE A VARIABLE
         LA    R15,DESERV_RC           DESERV RC VAR NAME
         STCM  R15,B'1111',PVARPTR     STORE IN PARAMETER LIST
         LA    R15,L'DESERV_RC(0,0)    VARIABLE NAME LENGTH
         STCM  R15,B'1111',PVARLEN     STORE IN PARAMETER LIST
         LA    R15,DESERV_RETCODE      @ OF VARIABLE VALUE
         STCM  R15,B'1111',PVARVAL@    STORE IN PARAMETER LIST
         LA    R15,L'DESERV_RETCODE(0,0) LENGTH OF VARIABLE AREA
         STCM  R15,B'1111',PVARVALL    LENGTH OF VARIABLE VALUE
         BAS   R2,IKJCT441             CALL IKJCT441
         LTR   R15,R15                 ALL OK?
         BNZ   DESERV_EXIT             NO - LET'S QUIT
         MVC   ECODE,=AL4(TSVEUPDT)    UPDATE OR CREATE A VARIABLE
         LA    R15,DESERV_RSN          DESERV RC VAR NAME
         STCM  R15,B'1111',PVARPTR     STORE IN PARAMETER LIST
         LA    R15,L'DESERV_RSN(0,0)   VARIABLE NAME LENGTH
         STCM  R15,B'1111',PVARLEN     STORE IN PARAMETER LIST
         LA    R15,DESERV_RSNCODE      @ OF VARIABLE VALUE
         STCM  R15,B'1111',PVARVAL@    STORE IN PARAMETER LIST
         LA    R15,L'DESERV_RSNCODE(0,0) LENGTH OF VARIABLE AREA
         STCM  R15,B'1111',PVARVALL    LENGTH OF VARIABLE VALUE
         BAS   R2,IKJCT441             CALL IKJCT441
         LTR   R15,R15                 ALL OK?
         BNZ   DESERV_EXIT             NO - LET'S QUIT
         MVC   EVALBLOCK_EVLEN(4),=F'2'  SET LENGTH OF RESULT
         MVC   EVALBLOCK_EVDATA(2),=C'-7' MOVE IN RESULT DATA
         B     DESERV_EXIT             LET'S QUIT
DESERV_EXIT EQU *
         ICM   R2,B'1111',DESERV_ENTRY RETURN ADDRESS
         BR    R2                      RETURN TO CALLER
         TITLE 'PROCESS THE SMDE ENTRIES'
*...................................................................
*                                                                  .
* PROCESS THE SMDE ENTRIES                                         .
*                                                                  .
*...................................................................
PROCESS_SMDE  EQU *
         STCM  R2,B'1111',PROCESS_SMDE_ENTRY STORE THE RETURN ADDRESS
         XR    R15,R15                 INIT
         ICM   R3,B'1111',DESERV_BUFFER@ DESERV BUFFER ADDRESS
PROCESS_DESB  EQU *
         USING DESB,R3                 INFORM THE ASSEMBLER
         ICM   R5,B'1111',DESB_COUNT   ANY SMDE ENTRIES?
         BNZ   ADDRESS_SMDE_ENTRIES    YES
         MVC   EVALBLOCK_EVLEN(4),=F'2'  SET LENGTH OF RESULT
         MVC   EVALBLOCK_EVDATA(2),=C'-8' MOVE IN RESULT DATA
         B     FREE_DE_STORAGE         LET'S FREE THE STORAGE
ADDRESS_SMDE_ENTRIES EQU *
         LA    R6,L'DESB_FIXED(,R3)    POSITION ONTO FIRST SMDE
         USING SMDE,R6                 INFORM THE ASSEMBLER
         CLI   SMDE_LIBTYPE,SMDE_LIBTYPE_PDSE  PDSE?
         BE    CHK_FOR_LMOD            YES
         CLI   SMDE_LIBTYPE,SMDE_LIBTYPE_PDS   PDS?
         BE    CHK_FOR_LMOD            YES
         MVC   EVALBLOCK_EVLEN(4),=F'2'  SET LENGTH OF RESULT
         MVC   EVALBLOCK_EVDATA(2),=C'-9' MOVE IN RESULT DATA
         B     FREE_DE_STORAGE         LET'S FREE THE STORAGE
CHK_FOR_LMOD EQU *
         MVI   P_MEMBER,C' '           CLEAR REXX MEMBER VARIABLE
         MVC   P_MEMBER+1(PDS_MEMBER_LENGTH-1),P_MEMBER
         MVI   P_MTYPE,C'P'             FLAG MEMBER IS PROGRAM
         TM    SMDE_FLAG,SMDE_FLAG_LMOD LMOD?
         BO    BUILD_DE_VARS            YES
         MVI   P_MTYPE,C'N'             FLAG MEMBER HAS NO USERDATA
**       MVC   EVALBLOCK_EVLEN(4),=F'3' SET LENGTH OF RESULT
**       MVC   EVALBLOCK_EVDATA(3),=C'-10' MOVE IN RESULT DATA
**       B     FREE_DE_STORAGE         LET'S FREE THE STORAGE
BUILD_DE_VARS EQU *
         XC    R15_SAVE,R15_SAVE       RESET
         MVC   P_TYPE,=CL4'PDSE'       DEFAULT
         TM    SMDE_LIBTYPE,SMDE_LIBTYPE_PDSE PDSE?
         BO    SMDE_ALIAS              YES
         MVC   P_TYPE,=CL4'PDS '       SET TO PDS
SMDE_ALIAS  EQU *
         MVC   P_TTR,SMDE_MLT          MLT OF MEMBER
         MVI   P_ALIAS,C'Y'            DEFAULT              *LBD*
         TM    SMDE_FLAG,SMDE_FLAG_ALIAS ALIAS?
         BO    SMDE_DE_PRIMARY_NAME    YES, CANNOT BE A GENERATION
         MVI   P_ALIAS,C'N'            MAIN PROGRAM
         B     SMDE_MEMBER_NAME        GET THE MEMBER NAME
SMDE_DE_PRIMARY_NAME EQU *
         XR    R7,R7                   ZEROIZE
         ICM   R7,B'0011',SMDE_PNAME_OFF PRIMARY NAME
         BZ    SMDE_MEMBER_NAME        NO THERE. GET THE MEMBER NAME
         LA    R7,0(R7,R6)             POSITION ONTO SMDE_NAME
         USING SMDE_PNAME,R7           INFORM THE ASSEMBLER
         XR    R14,R14                 ZEROIZE
         ICM   R14,B'0011',SMDE_PNAME_LEN MEMBER NAME OFFSET
         BCTR  R14,0                   -1 FOR MVC
         EX    R14,MEMBER_PNAME_MOVE   MOVE THE MEMBER NAME
SMDE_MEMBER_NAME EQU *
         XR    R7,R7                   ZEROIZE
         TM    ISMOFLG2,ISMMGENS       GENERATIONS ENABLED?
         BZ    SMDE_DE_NOT_GEN_NAME    NO
         ICM   R7,B'0011',SMDE_GENE_OFF GENERATION SECTION
         BZ    SMDE_DE_NOT_GEN_NAME    NO THERE. GET THE MEMBER NAME
         LA    R7,0(R7,R6)             POSITION ONTO SMDE_GENE
         USING SMDE_GENE,R7            INFORM THE ASSEMBLER
         MVC   P_MEMBER,SMDE_GENE_NAME LOAD MEMBER NAME
* ADDED TO TEST FOR A DUMMY GENERATION AND FLAG IT
         MVI   P_FLAG,C' '
         TM    SMDE_GENE_FLGS1,SMDE_IS_DUMMY   DUMMY?
         BZ    NOT_DUMMY
         MVI   P_FLAG,C'D'
NOT_DUMMY DS 0H
         ICM   R0,15,SMDE_GENE_NUMBER  ABSOLUTE GENERATION NUMBER
         CVD   R0,DBL
         MVC   P_GEN#,ED7
         ED    P_GEN#,DBL+4
         MVC   DW,SMDE_GENE_TIMESTAMP  COPY STCK VALUE
         MVC   P_USER,SMDE_GENE_USERID
         LM    R14,R15,DW              LOAD STCK VALUE
         L     R1,FLCCVT               CVT
         L     R1,CVTEXT2-CVT(,R1)     OS/VS2 COMMON EXTENSION
         USING CVTXTNT2,R1
         AL    R15,CVTLDTOR            ADD CVTLDTO RIGHT WORD
         BC    12,GENFMTL2             CVTLDTO = LOCAL DATE/TIME OFFSET
         ALR   R14,R0                  CARRY ONE FROM OVERFLOW
GENFMTL2 AL    R14,CVTLDTOL            ADD CVTLDTO LEFT WORD
         SL    R15,CVTLSOL             SUBTRACT CVTLSO LOW WORD
         BC    3,GENFMTL3              CVTLSO = LEAP SECOND OFFSET
         SR    R14,R0                  BORROW ONE FROM OVERFLOW
GENFMTL3 SL    R14,CVTLSOH             SUBTRACT CVTLSO HIGH WORD
         STM   R14,R15,DW              SAVE THE LOCALIZED STCK VALUE
         DROP  R1                      CVTXTNT2
         STCKCONV STCKVAL=DW,          POINT TO INPUT STCK VALUE       +
               CONVVAL=QW,             POINT TO OUTPUT FOUR WORDS      +
               TIMETYPE=DEC,           GET TIME DECIMAL DIGITS         +
               DATETYPE=YYYYDDD,       SPECIFY DATE FORMAT             +
               MF=(E,STCKCNVL)         SPECIFY PARAMETER LIST
         L     R0,QW+8                 GET 0YYYYDDD
         SLL   R0,4                    GET YYYYDDD0
         OILL  R0,X'F'                 GET YYYYDDDF
         ST    R0,DW
         UNPK  P_DATE,DW(4)            LOAD THE DATE
         L     R0,QW                   GET HHMMSSTH
         SRL   R0,4                    GET 0HHMMSST
         OILL  R0,X'F'                 GET 0HHMMSSF
         ST    R0,DW
         UNPK  P_TIME,DW(4)            LOAD THE TIME
         XR    R7,R7                   ZEROIZE
         ICM   R7,B'0011',SMDE_USRD_OFF GET USERDATA OFFSET
         BZ    BUILD_REXX_VAR          THAT'S ALL FOR THIS MEMBER
         LA    R7,0(R7,R6)             POSITION ONTO USERDATA
         TM    ISMOFLG3,ISMDTPGM       PROGRAM LIBRARY?
         BO    SMDE_IS_PGMLIB          YES
         TM    DCBRECFM,DCBRECU        RECFM=U?
         BNO   SMDE_LOOKAT_USERDATA    NO, NOT A PROGRAM LIBRARY
         CLI   0(R7),30                REALLY PMAR+1?
         BNO   SMDE_LOOKAT_USERDATA    NO, NOT A PROGRAM LIBRARY
SMDE_IS_PGMLIB EQU *
         BCTR  R7,0                    YES, BACK UP ONE
         MVI   P_MTYPE,C'P'            FLAG MEMBER IS PROGRAM
         B     SMDE_LOOKAT_PMAR        GO LOOK AT PROGRAM ATTRIBUTES
SMDE_DE_NOT_GEN_NAME EQU *
         ICM   R7,B'0011',SMDE_NAME_OFF MEMBER NAME OFFSET
         BZ    BUILD_REXX_VAR          THIS SHOULD NOT HAPPEN
         LA    R7,0(R7,R6)             POSITION ONTO SMDE_NAME
         USING SMDE_NAME,R7            INFORM THE ASSEMBLER
         XR    R14,R14                 ZEROIZE
         ICM   R14,B'0011',SMDE_NAME_LEN MEMBER NAME OFFSET
         BCTR  R14,0                   -1 FOR MVC
         EX    R14,MEMBER_NAME_MOVE    MOVE THE MEMBER NAME
         XR    R7,R7                   ZEROIZE
         ICM   R7,B'0011',SMDE_PMAR_OFF PROGRAM MANAGEMENT
*                                      ATTRIBUTE RECORD OFFSET
**LBD*   BZ    PROCESS_NEXT_SMDE       THIS SHOULD NOT HAPPEN
         BZ    BUILD_REXX_VAR  *LBD*   THIS SHOULD NOT HAPPEN
         LA    R7,0(R7,R6)             POSITION ONTO THE PMAR
         CLI   P_MTYPE,C'P'            IS MEMBER A PROGRAM?
         BE    SMDE_LOOKAT_PMAR        YES, THE USERDATA IS THE PMAR
SMDE_LOOKAT_USERDATA EQU *
         SR    R0,R0                   NO PMAR BUT HAVE USERDATA
         ICM   R0,3,SMDE_USRD_LEN      GET THE USERDATA LENGTH
         CHI   R0,4                    SSI?
         BNE   SMDE_ISPF_STATS         NO, GO CHECK FOR ISPF STATS
         MVC   P_SSI,0(R7)             LOAD MEMBER SSI
         B     BUILD_REXX_VAR          THAT'S ALL FOR THIS MEMBER
SMDE_ISPF_STATS EQU *
         USING SPFSTATS,R7             INFORM THE ASSEMBLER
         CHI   R0,30                   CLASSIC ISPF USERDATA LENGTH?
         BNE   SMDE_XTND_STATS         NO
         TM    SPFFLAGS,SPFXSTAT       EXTENDED STATISTICS?
         BO    BUILD_REXX_VAR          YES, SO NOT ISPF STATS
         B     SMDE_TEST_STATS         NO, AS EXPECTED
SMDE_XTND_STATS EQU *
         CHI   R0,40                   EXTENDED ISPF USERDATA LENGTH?
         BNE   BUILD_REXX_VAR          NO, NOT ISPF STATISTICS
         TM    SPFFLAGS,SPFXSTAT       EXTENDED STATISTICS?
         BNO   BUILD_REXX_VAR          NO, SO NOT ISPF STATS
SMDE_TEST_STATS EQU *
         CLI   SPFVM,0                 VALID VERSION?
         BE    BUILD_REXX_VAR          NO
         CLI   SPFVM,99                VALID VERSION?
         BH    BUILD_REXX_VAR          NO
         CLI   SPFVM+1,99              VALID LEVEL?
         BH    BUILD_REXX_VAR          NO
         TM    SPFCREDT+3,X'0F'        EXPECTED DATE FORMAT?
         BNO   BUILD_REXX_VAR          NO
         TM    SPFCHGDT+3,X'0F'        EXPECTED DATE FORMAT?
         BNO   BUILD_REXX_VAR          NO
         TP    SPFCREDT                EXPECTED DATE FORMAT?
         BNZ   BUILD_REXX_VAR          NO
         TP    SPFCHGDT                EXPECTED DATE FORMAT?
         BNZ   BUILD_REXX_VAR          NO
         MVC   P_SSI(2),SPFMOD         MOVE MODIFIED COUNT *LBD*
         MVI   P_MTYPE,C'I'            FLAG ISPF STATISTICS LOADED
         SR    R0,R0
         IC    R0,SPFVM
         CVD   R0,DW
         OI    DW+7,X'0F'
         UNPK  P_VVMM(2),DW            LOAD MEMBER VERSION LEVEL
         MVI   P_VVMM+2,C'.'           SUPPLY PERIOD
         IC    R0,SPFVM+1
         CVD   R0,DW
         OI    DW+7,X'0F'
         UNPK  P_VVMM+3(2),DW          LOAD MEMBER MODIFICATION LEVEL
         ICM   R0,12,SPFHHMM           GET HHMM????
         ICM   R0,2,SPFSECS            GET HHMMSS??
         SRL   R0,4                    GET 0HHMMSS?
         OILL  R0,X'F'                 GET 0HHMMSSF
         ST    R0,DW
         UNPK  P_TIME,DW(4)            LOAD THE LAST CHANGE TIME
         AP    SPFCHGDT,=P'1900000'
         OI    SPFCHGDT+3,X'0F'        RESTORE EXPECTED SIGN CODE
         UNPK  P_DATE,SPFCHGDT         LOAD THE LAST CHANGE DATE
         AP    SPFCREDT,=P'1900000'
         OI    SPFCREDT+3,X'0F'        RESTORE EXPECTED SIGN CODE
         UNPK  P_IDATE,SPFCREDT        LOAD THE CREATION DATE
         MVC   P_USER,SPFUSER          LOAD THE USER ID
         XC    P_VSTOR,P_VSTOR         PREPARE FOR HALFWORD
         MVC   P_VSTOR+2(2),SPFCCNT     AND ISPF CURRENT SIZE
         XC    P_EPA,P_EPA             PREPARE FOR HALFWORD
         MVC   P_EPA+2(2),SPFICNT       AND ISPF INITIAL SIZE
         TM    SPFFLAGS,SPFXSTAT       EXTENDED STATISTICS?
         BNO   BUILD_REXX_VAR          NO, THAT'S ALL FOR THIS MEMBER
         MVC   P_VSTOR,SPFXCCNT        YES, GET ISPF CURRENT SIZE
         MVC   P_EPA,SPFXICNT               AND ISPF INITIAL SIZE
         B     BUILD_REXX_VAR          THAT'S ALL FOR THIS MEMBER
SMDE_LOOKAT_PMAR EQU *
         USING PMAR,R7                 INFORM THE ASSEMBLER
         IC    R0,P_APFCDE+L'P_APFCDE  APF CODE
         UNPK  P_APFCDE(L'P_APFCDE+1),PMAR_AC(L'PMAR_AC+1)
         TR    P_APFCDE,HEX-C'0'
         STC   R0,P_APFCDE+L'P_APFCDE
         MVC   P_VSTOR,PMAR_STOR       VIRTUAL STORAGE REQUIRED
         MVC   P_EPA,PMAR_EPA          ENTRY POINT ADDRESS
         TM    PMAR_ATR3,PMAR_XSSI     SSI PRESENT?
         BNO   TEST_RMODE              NO
         MVC   P_SSI,PMAR_SSI          SSI
TEST_RMODE EQU *
         MVC   P_RMODE,=CL3'ANY'       DEFAULT
         TM    PMAR_ATR4,PMAR_RMOD     RMODE = ANY?
         BO    TEST_AMODE              YES
         MVC   P_RMODE,=CL3' 24'       DEFAULT
TEST_AMODE EQU *
         MVC   P_AMODE,=CL3'ANY'       AMODE ANY
         TM    PMAR_ATR4,MAIN_AMODEANY AMODE ANY?
         BO    TEST_ALIAS_AMODE        YES
         MVC   P_AMODE,=CL3' 31'       DEFAULT
         TM    PMAR_ATR4,MAIN_AMODE31  AMODE31?
         BO    TEST_ALIAS_AMODE        YES
         MVC   P_AMODE,=CL3' 24'       MUST BE AMODE 24
TEST_ALIAS_AMODE EQU *
*                                                           *LBD*
*        MVC   P_AAMODE,=CL3'ANY'      AMODE ANY            *LBD*
         TM    PMAR_ATR4,ALIAS_AMODEANY AMODE ANY?
         BO    CHECK_FOR_RENT          YES
*        MVC   P_AAMODE,=CL3' 31'      DEFAULT              *LBD*
         TM    PMAR_ATR4,ALIAS_AMODE31 AMODE31?
*        BO    CHECK_FOR_RENT          YES                  *LBD*
         MVC   P_AAMODE,=CL3' 24'      MUST BE AMODE 24
CHECK_FOR_RENT EQU *
         MVI   P_RENT,C'Y'             DEFAULT
         TM    PMAR_ATR1,PMAR_RENT     REENTERABLE?
         BO    CHECK_FOR_REUS          YES
         MVI   P_RENT,C'N'             NO
CHECK_FOR_REUS EQU *
         MVI   P_REUS,C'Y'             DEFAULT
         TM    PMAR_ATR1,PMAR_REUS     REUSABLE?
         BO    CHECK_FOR_OVLY          YES
         MVI   P_REUS,C'N'             NO
CHECK_FOR_OVLY EQU *
         MVI   P_OVLY,C'Y'             DEFAULT
         TM    PMAR_ATR1,PMAR_OVLY     OVERLAY STRUCTURE?
         BO    CHECK_FOR_TSO_TEST      YES
         MVI   P_OVLY,C'N'             NO
CHECK_FOR_TSO_TEST EQU *
         MVI   P_TEST,C'Y'             DEFAULT
         TM    PMAR_ATR1,PMAR_TEST     TSO/E TEST?UCTURE?
         BO    CHECK_FOR_LOAD          YES
         MVI   P_TEST,C'N'             NO
CHECK_FOR_LOAD EQU *
         MVI   P_LOAD,C'Y'             DEFAULT
         TM    PMAR_ATR1,PMAR_LOAD     ONLY LOADABLE?
         BO    CHECK_FOR_EXEC          YES
         MVI   P_LOAD,C'N'             NO
CHECK_FOR_EXEC EQU *
         MVI   P_EXEC,C'Y'             DEFAULT
         TM    PMAR_ATR1,PMAR_EXEC     EXECUTABLE?
         BO    CHECK_FOR_SCTR          YES
         MVI   P_EXEC,C'N'             NO
CHECK_FOR_SCTR EQU *
         MVI   P_SCTR,C'Y'             DEFAULT
         TM    PMAR_ATR1,PMAR_SCTR     EXECUTABLE?
         BO    CHECK_FOR_1BLK          YES
         MVI   P_SCTR,C'N'             NO
CHECK_FOR_1BLK EQU *
         MVI   P_1BLK,C'Y'             DEFAULT
         TM    PMAR_ATR1,PMAR_1BLK     LOAD MODULE CONTAINS ONLY
*                                      ONE BLOCK OF TEXT DATA AND
*                                      HAS NO RLD RECORDS
         BO    CHECK_FOR_TSTN          YES
         MVI   P_1BLK,C'N'             NO
CHECK_FOR_TSTN EQU *
         MVI   P_TSTN,C'Y'             DEFAULT
         TM    PMAR_ATR2,PMAR_TSTN     MODULE CONTAINS TSO/E TEST
*                                      SYMBOL CARDS
         BO    CHECK_FOR_REFR          YES
         MVI   P_TSTN,C'N'             NO
CHECK_FOR_REFR EQU *
         MVI   P_REFR,C'Y'             DEFAULT
         TM    PMAR_ATR2,PMAR_REFR     REFRESHABLE?
         BO    CHECK_FOR_PAGE_ALIGNMENT YES
         MVI   P_REFR,C'N'             NO
CHECK_FOR_PAGE_ALIGNMENT EQU *
         MVI   P_PAGA,C'Y'             DEFAULT
         TM    PMAR_ATR3,PMAR_PAGA     PAGE ALIGNMENT?
         BO    CHECK_FOR_BIG           YES
         MVI   P_PAGA,C'N'             NO
CHECK_FOR_BIG  EQU *
         MVI   P_BIG,C'Y'              DEFAULT
         TM    PMAR_ATR3,PMAR_BIG      PROGRAM REQUIRES => 16M?
         BO    PMARL_SECTION
         MVI   P_BIG,C'N'              NO
PMARL_SECTION  EQU *
         TM    PMAR_ATR3,PMAR_LFMT     PMARL FOLLOWS PMAR?
         BNO   BUILD_REXX_VAR          YES
         LA    R7,L'PMAR_ENTRY(,R7)    POSITION ONTO THE PMARL
         USING PMARL,R7                INFORM THE ASSEMBLER
         CLC   PMARL_SLEN,=X'0052'     AUDIT TRACE DATA PRESENT?
         BL    BUILD_REXX_VAR          NO
         UNPK  P_DATE,PMARL_DATE       DATE SAVED
         OI    P_DATE+L'P_DATE-1,X'F0' FORCE SIGN TO F
         UNPK  P_TIME,PMARL_TIME       TIME SAVED
         OI    P_TIME+L'P_TIME-1,X'F0' FORCE SIGN TO F
         MVC   P_USER,PMARL_USER       USER OR JOB IDENTIFICATION
BUILD_REXX_VAR EQU *
         AP    STEMNO,=P'1'            NEXT STEM NO
         XR    R15,R15                 ZEROIZE
         MVC   P_MEMBER_STEM,=C'MEMBER.'  MEMBER STEM PREFIX
         UNPK  STEMWORK,STEMNO         CONVERT STEMO NO TO CHARACTER
         OI    STEMWORK+L'STEMWORK-1,X'F0' FORCE SIGN TO F
         LA    R14,STEMWORK            @ STEM
         LA    R15,L'STEMWORK(0,0)     MAX LENGTH OF STEM
         BAS   R2,STEMCHK              CALCULATE FIRST NON-ZERO STEMNO
         XC    P_MEMBER_STEM_NO,P_MEMBER_STEM_NO NICE AND TIDY
         BCTR  R15,0                   -1 FOR MVC
         EX    R15,P_MEMBER_STEM_MOVE  MOVE THE STEM NO
         LA    R15,1(,R15)             + 1 FOR EX
         LA    R15,L'P_MEMBER_STEM(,R15) FULL LENGTH
         LR    R14,R15                 LET'S SWITCH
         MVC   ECODE,=AL4(TSVEUPDT)    UPDATE OR CREATE A VARIABLE
         LA    R15,P_MEMBER_VARNAME    @ OF VARIABLE NAME
         STCM  R15,B'1111',PVARPTR     STORE IN PARAMETER LIST
         STCM  R14,B'1111',PVARLEN     STORE IN PARAMETER LIST
         LA    R15,PDS_MEMBER_VARIABLE @ OF VARIABLE VALUE
         STCM  R15,B'1111',PVARVAL@    STORE IN PARAMETER LIST
         XR    R15,R15                 CLEAR
         ICM   R15,B'1111',=AL4(PDS_MEMBER_LENGTH) LENGTH OF VAR
         STCM  R15,B'1111',PVARVALL    LENGTH OF VARIABLE VALUE
         BAS   R2,IKJCT441             CALL IKJCT441
         LTR   R15,R15                 ALL OK?
         BNZ   CREATE_STEM_ERROR       YES
PROCESS_NEXT_SMDE  EQU *
         ICM   R14,B'1111',SMDE_LEN    SMDE CONTROL BLOCK LENGTH
         LA    R6,0(R14,R6)            NEXT ENTRY
         BCT   R5,CHK_FOR_LMOD         DO WHILE R5 > 0?
         ICM   R3,B'1111',DESB_NEXT    NEXT BUFFER IN CHAIN?
         BNZ   PROCESS_DESB            PROCESS NEXT DESB
         B     CREATE_STEM0            NO - ALL DONE
CREATE_STEM_ERROR EQU *
         MVC   EVALBLOCK_EVLEN(4),=F'3'  SET LENGTH OF RESULT
         MVC   EVALBLOCK_EVDATA(3),=C'-11' MOVE IN RESULT DATA
         STCM  R15,B'1111',R15_SAVE    SAVE R15 FOR A WHILE
         B     FREE_DE_STORAGE         LET'S FREE THE STORAGE
CREATE_STEM0   EQU *
         MVC   ECODE,=AL4(TSVEUPDT)    UPDATE OR CREATE A VARIABLE
         LA    R15,P_MEMBER_STEM0      VARIABLE NAME STEM.0
         STCM  R15,B'1111',PVARPTR     STORE IN PARAMETER LIST
         LA    R15,L'P_MEMBER_STEM0(0,0) VARIABLE NAME LENGTH
         STCM  R15,B'1111',PVARLEN     STORE IN PARAMETER LIST
         UNPK  STEMWORK,STEMNO         CONVERT STEMO NO TO CHARACTER
         OI    STEMWORK+L'STEMWORK-1,X'F0' FORCE SIGN TO F
         LA    R14,STEMWORK            @ STEM
         LA    R15,L'STEMWORK(0,0)     MAX LENGTH OF STEM
         BAS   R2,STEMCHK              CALCULATE FIRST NON-ZERO CHAR
         STCM  R14,B'1111',PVARVAL@    STORE IN PARAMETER LIST
         STCM  R15,B'1111',PVARVALL    LENGTH OF VARIABLE VALUE
         BAS   R2,IKJCT441             CALL IKJCT441
         LTR   R15,R15                 ALL OK?
         BZ    FREE_DE_STORAGE         LET'S FREE THE STORAGE
         MVC   EVALBLOCK_EVLEN(4),=F'3'  SET LENGTH OF RESULT
         MVC   EVALBLOCK_EVDATA(3),=C'-12' MOVE IN RESULT DATA
         STCM  R15,B'1111',R15_SAVE    SAVE R15 FOR A WHILE
         B     FREE_DE_STORAGE         LET'S FREE THE STORAGE
FREE_DE_STORAGE     EQU *
         ICM   R3,B'1111',DESERV_BUFFER@ DESERV BUFFER ADDRESS
INVOKE_FREE_ROUTINE EQU *
         ICM   R0,B'1111',DESB_LEN     LENGTH
         ICM   R7,B'1111',DESB_NEXT    NEXT BLOCK IN CHAIN
         BAS   R2,DESB_FREEMAIN        FREE THE DESB/SMDE BLOCKS
         LR    R3,R7                   RELOAD
         LTR   R3,R3                   NEXT BUFFER?
         BNZ   INVOKE_FREE_ROUTINE     FREE IT
         ICM   R15,B'1111',R15_SAVE    RESTORE R15
         B     PROCESS_SMDE_EXIT       ALL DONE
PROCESS_SMDE_EXIT   EQU *
         ICM   R2,B'1111',PROCESS_SMDE_ENTRY RETURN ADDRESDS
         BR    R2                      RETURN TO CALLER
         USING SMDE_NAME,R7            INFORM THE ASSEMBLER
MEMBER_NAME_MOVE     MVC P_MEMBER(*-*),SMDE_NAME_VAL
         USING SMDE_PNAME,R7           INFORM THE ASSEMBLER
MEMBER_PNAME_MOVE    MVC P_PNAME(*-*),SMDE_PNAME_VAL
P_MEMBER_STEM_MOVE   MVC P_MEMBER_STEM_NO(*-*),0(R14)
         TITLE 'FREE DE STORAGE'
*...................................................................
*                                                                  .
* FREE THE DESB/SMDE ETC                                           .
*                                                                  .
*...................................................................
DESB_FREEMAIN  EQU *
         STORAGE RELEASE,                                              X
               ADDR=(R3),                                              X
               LENGTH=(R0),                                            X
               SP=0,                                                   X
               KEY=8,                                                  X
               COND=NO,                                                X
               RELATED=(GETSTOR,'DESERV INVOCATION')
         BR    R2                      RETURN TO CALLER
         TITLE 'CREATE THE REXX VARIABLES'
*...................................................................
*                                                                  .
* INVOKE THE TSO FACILITY IKJCT441                                 .
*                                                                  .
*...................................................................
IKJCT441 EQU   *
         XC    IKJTOKEN,IKJTOKEN       NO REQUIRED FOR THIS CALL
         XC    RCODE441,RCODE441       RETURN CODE
         L     R15,CVTTVT              TSCT @
         USING TSVT,R15                INFORM THE ASSEMBLER
         L     R15,TSVTVACC            IKJCT441 @
         LTR   R15,R15                 ENTRY POINT FOUND?
         BNZ   CALL441                 YES - DO A CALL
LINK441  EQU   *
         MVC   LINKAREA,LINKL          LINK SL=L
         MVC   CALLAREA,CALLL          PROG PROGRAM LIST
         LINK  EP=IKJCT441,                                            X
               PARAM=(ECODE,           ENTRY CODE                      X
               PVARPTR,                POINTER TO PANEL VAR NAME       X
               PVARLEN,                LENGTH  OF PANEL VAR NAME       X
               PVARVAL@,               POINTER TO PAN VAR VALUE        X
               PVARVALL,               LENGTH  OF PAN VAR VALUE        X
               IKJTOKEN,               TOKEN                           X
               ECTPARM,                NOT REQUIRED                    X
               RCODE441),              RETURN CODE                     X
               VL=1,                   EOL                             X
               MF=(E,CALLAREA),        CALL AREA                       X
               SF=(E,LINKAREA)         LINK AREA
         B     IKJCT441_CHECK          CHECK THE RETURN CODE
CALL441  EQU   *
         MVC   CALLAREA,CALLL          PROG PROGRAM LIST
         CALL  (15),                                                   X
               (ECODE,                 ENTRY CODE                      X
               PVARPTR,                POINTER TO PANEL VAR NAME       X
               PVARLEN,                LENGTH  OF PANEL VAR NAME       X
               PVARVAL@,               POINTER TO PAN VAR VALUE        X
               PVARVALL,               LENGTH  OF PAN VAR VALUE        X
               IKJTOKEN,               TOKEN                           X
               ECTPARM,                NOT REQUIRED                    X
               RCODE441),              RETURN CODE                     X
               VL,                     EOL                             X
               MF=(E,CALLAREA)
         B     IKJCT441_CHECK          CHECK THE RETURN CODE
IKJCT441_CHECK EQU *
         LTR   R15,R15                 ALL OK?
         BZR   R2                      YES - RETURN TO CALLER
         MVC   EVALBLOCK_EVLEN(4),=F'2'  SET LENGTH OF RESULT
         MVC   EVALBLOCK_EVDATA(2),=C'-6' MOVE IN RESULT DATA
         BR    R2                      RETURN TO CALLER
*...................................................................
*                                                                  .
* STEM CHECK ROUTINE                                               .
*                                                                  .
*...................................................................
STEMCHK  EQU   *
*****************************************************************
* R14 = ADDRESS OF STEM NUMBER
* R15 = LENGTH  OF STEM NUMBER
*****************************************************************
STEMSCAN_FORNONZERO EQU *
         CLI   0(R14),X'F0'            NON-ZERO CHARACTER?
         BNER  R2                      YES
         LA    R14,1(,R14)             NEXT CHARACTER
         BCT   R15,STEMSCAN_FORNONZERO DO WHILE R15 > 0?
         BCTR  R14,0                   RE-POSITION TO LAST CHAR
         LA    R15,1(0,0)              SET TO 1
         BR    R2                      RETURN TO CALLER
         TITLE 'LITERALS'
         LTORG
         TITLE 'STORAGE ITEMS'
DESERV_BFL DC   A(512*10240)  *LBD*    DESERV FUNC=GET_ALL_G BUFFER LEN
DESERV_RC  DC   CL8'DESERVRC'          DESERV RC VAR NAME
DESERV_RSN DC   CL8'DESERVRS'          DESERV RS VAR NAME
P_MEMBER_STEM0 DC CL8'MEMBER.0'        MEMBER STEM 0
ECTPARM    DC   X'FFFFFFFF'            ECT
HEX        DC   CL16'0123456789ABCDEF'
ED7        DC   XL8'4020202020202120'
ZEROS      DC   3F'0'
         TITLE 'MACRO LIST AREA'
DESERVL  DESERV MF=L
DSERVLEN EQU   *-DESERVL               LENGTH
         TITLE 'DATA MANAGEMENT ITEMS'
PDSECB   DCB   DDNAME=REMSDCB,DSORG=PO,MACRF=EXCP,DCBE=DCBE *LBD*
DCBE     DCBE  EADSCB=OK                             *LBD*
*DSECB   DCB   DDNAME=REMSDCB,DSORG=PS,MACRF=GM      *LBD*
PDCBLEN  EQU *-PDSECB                  PDSE DCB MACRO LENGTH
OPENLST  OPEN  (,),MF=L,MODE=31
OPENLEN  EQU *-OPENLST                 OPEN MACRO LENGTH
CLOSELST CLOSE (,),MF=L,MODE=31
CLOSELEN EQU *-CLOSELST                CLOSE MACRO LENGTH
DSABEXP  GETDSAB MF=(L,DSABLST)
DSABLLEN EQU *-DSABLST                 GETDSAB MACRO LENGTH
ISITLST  ISITMGD DCB=0,DATATYPE=YES,MF=L
ISITLEN  EQU   *-ISITLST
LINKL    LINK SF=L
LINKLEN  EQU  *-LINKL                  LINK LENGTH
CALLL    CALL ,(,,,,),MF=L
CALLLEN  EQU  *-CALLL                  CALL LENGTH
         DC   0D
         TITLE 'WORKAREA DSECT'
WORKAREA DSECT
SAVEAREA DS    XL72                    SAVEAREA
DBL      DS    D                       WORK AREA
PREVSA   EQU   SAVEAREA+4,4            @ OF PREVIOUS SAVEAREA
STEMNO   DS    PL3                     STEM NO IN PACKED FORMAT
STEMWORK DS    CL5                     STEM NO IN CHARACTER FORMAT
P_MEMBER_VARNAME DS   CL12             ENTRY POINT ADDRESS
P_MEMBER_STEM     EQU P_MEMBER_VARNAME,7   VARIABLE NAME
P_MEMBER_STEM_NO  EQU P_MEMBER_VARNAME+7,5 VARIABLE STEM NO
DW       DS    D                       WORK AREA
QW       DS    4F                      WORK AREA
DESERV_ENTRY   DS F                    DESERV RETURN ADDRESS
PROCESS_SMDE_ENTRY  DS F               SMDE SECTION RETURN ADDRESS
R15_SAVE DS    F                       R15 SAVE AREA
DDNAME   DS    CL8                     PDS/PDSE DDNAME
STCKCNVL STCKCONV MF=L                 PARAMETER LIST FOR STCKCONV
PDS_MEMBER_VARIABLE DS 0XL1
P_TYPE   DS    CL4                     PDS/PDSE
P_MEMBER DS    CL8                     MEMBER NAME
P_PNAME  DS    CL8                     PRIMARY NAME
P_GEN#   EQU   P_PNAME                 GENERATION NUMBER
P_MTYPE  DS    C                       MEMBER TYPE P=PGM/I=ISPF/N=NULL
P_VVMM   DS    0CL5                    ISPF STATISTICS VV.MM
P_RENT   DS    C                       RENT
P_REUS   DS    C                       REUS
P_REFR   DS    C                       REFR
P_OVLY   DS    C                       OVERLAY
P_TEST   DS    C                       TEST
P_TSTN   DS    C                       TESTN
P_LOAD   DS    C                       ONLY LOADABLE
P_EXEC   DS    C                       EXECUTABLE
P_SCTR   DS    C                       SCATTER
P_1BLK   DS    C                       NO RLD RECORDS, 1 TEXT RECORD
P_BIG    DS    C                       PROGRAM REQUIRES 16M OR >
P_PAGA   DS    C                       PAGE ALIGNMENT REQUIRED
*   P_IDATE WAS 0CL7   *LBD*
P_IDATE  DS    0CL8                    INITIAL OR CREATION DATE
P_RMODE  DS    CL3                     RMODE
P_AMODE  DS    CL3                     MAIN AMODE
P_AAMODE DS    CL3                     ALIAS AMODE
P_ALIAS  DS    C                       ALIAS
P_APFCDE DS    CL2                     APF CODE
P_TTR    DS    XL3                     TTR
P_DATE   DS    CL7                     DATE
P_TIME   DS    CL7                     TIME
P_USER   DS    CL8                     USER/JOBNAME
P_SSI    DS    XL4                     SSI
P_VSTOR  DS    XL4                     VIRTUAL STORAGE REQUIRED
P_EPA    DS    XL4                     ENTRY POINT ADDRESS
P_INIT   DS    XL4                     ENTRY POINT ADDRESS
P_FLAG   DS    CL1                     FLAG - DUMMY GENERATION
PDS_MEMBER_LENGTH EQU *-PDS_MEMBER_VARIABLE LENGTH
ECODE    DC    AL4(TSVNOIMP)           CREATE CODE
PARMLIST DS    0F
PVARPTR  DS    F                       VAR PTR
PVARLEN  DS    F                       VAR LEN
PVARVAL@ DS    F                       VAR VALUE @
PVARVALL DS    F                       VAR VAL LENGTH
IKJTOKEN DS    F                       TOKEN
RCODE441 DS    F                       RETURN CODE
         DS    0F
DESERVA  DS    CL(DSERVLEN)            DESERV AREA
LINKAREA DS    CL(LINKLEN)             LINK AREA
CALLAREA DS    CL(CALLLEN)             PARM LIST AREA
PDSEDCB  DS    CL(PDCBLEN)             PDSE DCB AREA
OPENARA  DS    CL(OPENLEN)             OPEN AREA
CLOSEARA DS    CL(CLOSELEN)            CLOSE AREA
ISITAREA DS    CL(ISITLEN)             ISITMGD AREA
DSABAREA DS    CL(DSABLLEN)            GETDSAB AREA
DSABPTR  DS    A                       DSAB @
DESERV_BUFFER@ DS A                    DESERV BUFFER ADDRESS
DESERV_RETCODE DS A                    DESERV RETURN CODE
DESERV_RSNCODE DS A                    DESERV REASON CODE
WORKALEN EQU   *-WORKAREA              WORK AREA LENGTH


SPFSTATS DSECT
SPFVM    DS    XL2                     VERSION, LEVEL
SPFFLAGS DS    X                       FLAGS
SPFSCLM  EQU   X'80'                   SCLM-MANAGED
SPFXSTAT EQU   X'20'                   EXTENDED STATISTICS
SPFSECS  DS    X                       TIME LAST UPDATED (SS)
SPFCREDT DS    PL4                     DATE CREATED
SPFCHGDT DS    PL4                     DATE LAST UPDATED
SPFHHMM  DS    XL2                     TIME LAST UPDATED (HHMM)
SPFCCNT  DS    H                       CURRENT SIZE
SPFICNT  DS    H                       INITIAL SIZE
SPFMOD   DS    H                       MODS
SPFUSER  DS    CL7                     USERID
SPFBLANK DS    CL3                     1 OR 3 BLANKS TILL Z/OS 2.4
         ORG   SPFBLANK+1
SPFXCCNT DS    F                       CURRENT SIZE
SPFXICNT DS    F                       INITIAL SIZE
SPFXMOD  DS    F                       MODS
         TITLE 'REXX MAPPINGS'
         IRXEFPL                       REXX MAPPING MACROS
         IRXEVALB                      REXX EVALUATION BLOCK
         IRXARGTB DECLARE=YES          REXX ARG TABLE
         TITLE 'PSA DSECT'
         IHAPSA DSECT=YES,LIST=NO
         TITLE 'CVT'
         CVT DSECT=YES,LIST=NO,PREFIX=NO
         TITLE 'JESCT'
         IEFJESCT
         TITLE 'TSVT'
         IKJTSVT
         TITLE 'IHADSAB'
         IHADSAB
         TITLE 'SYSTEM MANAGED DIRECTORY ENTRY'
         IGWSMDE
         TITLE 'ISITMGD PARAMETER LIST'
         IGWCISM DSECT=YES
         TITLE 'DCB DSECT'
         DCBD  DSORG=(PS),DEVD=DA
         END   PDSEGENI
