//SNAKE JOB (SYS),'INSTALL SNAKE',CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             USER=IBMUSER,PASSWORD=SYS1,REGION=2048K,COND=(0,NE)
//* ********************************************************
//* *                                                      *
//* *        INSTALL THE 'SNAKE' TSO COMMAND               *
//* *                                                      *
//* ********************************************************
//ASM     EXEC PGM=IFOX00,PARM='NODECK,LOAD,TERM'
//SYSGO    DD  DSN=&&LOADSET,DISP=(MOD,PASS),SPACE=(CYL,(1,1)),
//             UNIT=VIO,DCB=(DSORG=PS,RECFM=FB,LRECL=80,BLKSIZE=800)
//SYSLIB   DD  DSN=SYS1.MACLIB,DISP=SHR
//SYSTERM  DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*
//SYSPUNCH DD  DSN=NULLFILE
//SYSUT1   DD  UNIT=VIO,SPACE=(CYL,(6,1))
//SYSUT2   DD  UNIT=VIO,SPACE=(CYL,(6,1))
//SYSUT3   DD  UNIT=VIO,SPACE=(CYL,(6,1))
//SYSIN    DD  *
SNAKE    TITLE ' A PROGRAM FOR TSO 3270 TERMINALS '
         ENTRY HALFSNAK
         ENTRY HS
         ENTRY QUARTERS
         ENTRY QS
***********************************************************************
*                                                                     *
*        WRITTEN AUGUST 1987 BY GREG PRICE OF PRYCROFT SIX PTY LTD.   *
*                                                                     *
*        FOR USE UNDER TSO ON 3270-FAMILY VDU IN FULLSCREEN           *
*        MODE.  SNAKE SUPPORTS ALL SCREEN SIZES.                      *
*                                                                     *
*        OBJECT: TO PICK UP AS MANY $25 BUNDLES AS POSSIBLE AND       *
*        MAKE IT "HOME" WITHOUT BEING EATEN BY THE SNAKE.  MONEY IS   *
*        IS DENOTED BY A '$', THE PLAYER BY A 'I', HOME BY '#',       *
*        AND THE SNAKE BY A STRING OF 'S'S IN LOWER CASE, WITH THE    *
*        SNAKE'S HEAD BEING IN UPPER CASE.  EACH TIME THE PLAYER      *
*        MOVES THE SNAKE MOVES.  AT FIRST THE SNAKE WILL MOVE ALMOST  *
*        RANDOMLY, BUT WILL MAKE AN "INTELLIGENT" MOVE MORE OFTEN     *
*        AS THE GAME PROGRESSES.  WHEN THE PLAYER GETS "HOME" THE     *
*        GAME ENDS AND THE SCORE IS CREDITED.  IF THE PLAYER GETS     *
*        "EATEN" THEN THE GAME ENDS AND NO SCORE IS CREDITED.         *
*                                                                     *
*        METHOD: THE PLAYER DEPRESSES KEYS TO INDICATE WHICH          *
*        DIRECTION THE 'I' SHOULD MOVE.  MONEY IS GAINED BY MOVING    *
*        THE 'I' TO A LOCATION OCCUPIED BY A '$', WHEREUPON           *
*        ANOTHER '$' WILL BE RANDOMLY GENERATED AT A VACANT           *
*        LOCATION.  GETTING TO "HOME" IS ACHIEVED BY MOVING THE 'I'   *
*        TO THE LOCATION OCCUPIED BY THE '#' WHICH DOES NOT MOVE      *
*        DURING A GAME.  GETTING "EATEN" BY THE SNAKE OCCURS WHEN     *
*        THE SNAKE'S HEAD MOVES TO THE LOCATION OCCUPIED BY THE 'I'.  *
*                                                                     *
***********************************************************************
         EJECT
***********************************************************************
*                                                                     *
*        INPUT:                                                       *
*        PA KEYS - REFRESH THE SCREEN IMAGE                           *
*        PFK  01 - DISPLAY HELP SCREEN                                *
*        PFK  03 - CANCEL - END WITHOUT SCORING                       *
*        PFK  04 - TOGGLE SHOW-SNAKE-TRAIL SWITCH                     *
*        PFK  05 - TOGGLE BURST-MODE-WHEN-RUNNING SWITCH              *
*        PFK  07 - MOVE UP ONE LOCATION                               *
*        PFK  08 - MOVE DOWN ONE LOCATION                             *
*        PFK  10 - MOVE LEFT ONE LOCATION                             *
*        PFK  11 - MOVE RIGHT ONE LOCATION                            *
*        PFK  12 - CANCEL - END WITHOUT SCORING                       *
*        PFK  13 - DISPLAY HELP SCREEN                                *
*        PFK  15 - CANCEL - END WITHOUT SCORING                       *
*        PFK  16 - TOGGLE SHOW-SNAKE-TRAIL SWITCH                     *
*        PFK  17 - TOGGLE BURST-MODE-WHEN-RUNNING SWITCH              *
*        PFK  19 - RUN UP UNTIL LEVEL WITH MONEY                      *
*        PFK  20 - RUN DOWN UNTIL LEVEL WITH MONEY                    *
*        PFK  22 - RUN LEFT UNTIL LEVEL WITH MONEY                    *
*        PFK  23 - RUN RIGHT UNTIL LEVEL WITH MONEY                   *
*        PFK  24 - CANCEL - END WITHOUT SCORING                       *
*                                                                     *
*        ANY OTHER INPUT, OR TRYING TO MOVE THROUGH AN OBSTRUCTION,   *
*        IS EQUIVALENT TO STANDING STILL WHILE THE SNAKE GETS A       *
*        MOVE.                                                        *
*                                                                     *
*        NOTE THAT RUNNING IS STOPPED BY AN OBSTRUCTION, BUT ONLY     *
*        AFTER FAILING A MOVE ATTEMPT, THUS GIVING THE SNAKE AN       *
*        EXTRA MOVE.                                                  *
*                                                                     *
*        ANY SNAKE TRAIL DATA PRESENT IS CLEARED BY A SCREEN          *
*        IMAGE RESHOW/REFRESH.                                        *
*                                                                     *
***********************************************************************
         EJECT
***********************************************************************
*                                                                     *
*        IF THE FILE ISPTABL (CAN BE CHANGED TO ANY PDS DD WHICH      *
*        EFFECTIVELY HAS UACC(UPDATE)) IS ALLOCATED THEN THE          *
*        HIGHEST SCORE IS KEPT AS USER DATA (PFD (NOT SPF) STATS)     *
*        OF MEMBER SNKTAB##  (REVIEW WILL SHOW PFD AND SPF STATS)     *
*        WHERE ## IS THE NUMBER OF LINES THAT THE SCREEN HAS.         *
*                                                                     *
*        IF THE TERMINAL'S VTAM QUERY BIT IS ON THEN A QUERY WILL     *
*        BE DONE TO DETERMINE IF 3270 EXTENDED DATA STREAM DATA       *
*        CAN BE SENT.                                                 *
*                                                                     *
*        IF INVOKED AS 'HALFSNAK' OR 'HS' THEN ONLY THE TOP HALF      *
*        (INTEGER ARITHMETIC) OF THE SCREEN WILL BE USED.             *
*        NATURALLY A DIFFERENT SCOREBOARD MEMBER WILL BE USED.        *
*        SIMILARLY WITH 'QUARTERS' AND 'QS'.                          *
*                                                                     *
*        RUNNING CAN BE SPEEDED UP BY ACTIVATING BURST MODE.  WHEN    *
*        THIS IS DONE CONSECUTIVE RUNNING MOVES ARE DISPLAYED WITH    *
*        ONE TPUT, THUS OPTIMIZING TERMINAL I/O.  HOWEVER, DEPENDING  *
*        UPON THE TERMINAL AND ITS CONTROLLER, EACH INDIVIDUAL MOVE   *
*        MAY BE INVISIBLE AND THE USER WILL BE PRESENTED WITH THE     *
*        FINAL SCREEN IMAGE.                                          *
*                                                                     *
***********************************************************************
         SPACE 2
***********************************************************************
*                                                                     *
*        SNAKE REQUIRES MACROS FROM SYS1.MACLIB.                      *
*        SNAKE REQUIRES AMODE=24 AND RMODE=24.                        *
*        SNAKE IS NOT RE-ENTRANT NOR SERIALLY REUSEABLE.              *
*        SNAKE DOES NOT ISSUE ANY GETMAIN OR FREEMAIN MACROS.         *
*                                                                     *
***********************************************************************
         TITLE ' INITIALIZATION '
SNAKE    CSECT
HALFSNAK DS    0D                 HALF-SCREEN VERSION ENTRY POINT.
HS       DS    0D                 SHORT FORM (ALIAS) OF HALFSNAK.
QUARTERS DS    0D                 QUARTER-SCREEN VERSION ENTRY POINT.
QS       DS    0D                 SHORT FORM (ALIAS) OF QUARTERS.
         STM   R14,R12,12(R13)    SAVE REGISTERS.
         LR    R11,R15            FIRST BASE.
         LA    R12,2048(,R11)
         LA    R12,2048(,R12)     SECOND BASE.
         LA    R7,2048(,R12)
         LA    R7,2048(,R7)       THIRD BASE.
         USING SNAKE,R11,R12,R7   HOME BASE(?).
         GTSIZE
         LTR   R0,R0              ZERO LINES?
         BNZ   HAVEVDU            NO, SHOULD MEAN 3270 CRT OR SIMILAR.
         LA    R1,SORRYMSG        YES, PROBABLY ON A TTY.
         LA    R0,L'SORRYMSG
LEAVEMSG TPUT  (1),(0),R          SORRY, BUT VDU IS REQUIRED.
         LM    R14,R12,12(R13)    RESTORE REGISTERS.
         LA    R15,8              RETURN CODE EIGHT.
         BR    R14                RETURN TO CALLER.
         SPACE 2
HAVEVDU  CH    R0,=H'24'          LESS THAN TWENTY-FOUR LINES?
         BL    WACKYVDU           YES, I DON'T BELIEVE IT.
         CH    R0,=H'99'          MORE THAN NINETY-NINE LINES?
         BH    WACKYVDU           YES, SCOREBOARD NAME WON'T WORK.
         CH    R1,=H'40'          LESS THAN FORTY COLUMNS?
         BNL   SCREENOK           NO, ACCEPT THIS SCREEN SIZE.
WACKYVDU LA    R1,WACKYMSG        YES, CAN'T BE AN HONEST-TO-GOD VDU.
         LA    R0,L'WACKYMSG      THE USER IS A CLOWN.
         B     LEAVEMSG           TELL THE USER AND GO HOME.
SCREENOK LR    R8,R0              SAVE LINES ON SCREEN.
         LR    R9,R1              SAVE COLUMNS ON SCREEN.
         L     R1,=V(SNAKECMN)
         ST    R1,8(,R13)         CHAIN SAVE AREAS.
         ST    R13,4(,R1)
         LR    R13,R1
         USING SNAKECMN,R13
         XC    ZEROAREA(ZEROLEN),ZEROAREA  ZERO A FEW VARIABLES.
         MVI   GRAFLAGS,0         ALL GRAPHIC FEATURES TO BE VERIFIED.
         L     R1,16              POINT TO THE CVT.
         MVC   OSBITS,116(R1)     COPY THE OPERATING SYSTEM FLAGS.
         TM    OSBITS,X'13'       SOME SORT OF MVS?
         BO    DDOKAY             YES.
         MVC   SNAKFILE+DCBDDNAM-IHADCB(8),PFDATTRS     NO, OSIV/F4.
DDOKAY   L     R1,540             POINT TO THE CURRENT TCB.
         L     R3,0(,R1)          POINT TO THE ACTIVE RB.
         L     R3,12(,R3)         POINT TO THE ACTIVE CDE.
         ICM   R1,X'F',164(R1)    POINT TO THE TIMING CONTROL TABLE.
         BZ    SIZCHECK           SMF NOT ACTIVE SO FORGET IT.
         ST    R1,TCTADDR         SAVE TIMING CONTROL TABLE ADDRESS.
         MVC   TGETCNTO(8),48(R1) GET CURRENT TGET AND TPUT COUNTS.
SIZCHECK CLI   8(R3),C'H'         INVOKED AS HALFSNAK?
         BE    HALFSIZE           NO, ONLY USE HALF OF THE LINES.
         CLI   8(R3),C'Q'         INVOKED AS QUARTERS?
         BNE   HAVESIZE           NO, USE ALL OF THE SCREEN.
         SRL   R8,1               HALVE OF THE NUMBER OF LINES.
HALFSIZE SRL   R8,1               HALVE OF THE NUMBER OF LINES (AGAIN).
HAVESIZE STM   R8,R9,LINES        STORE SCREEN DIMENSIONS.
         LR    R3,R9              NUMBER OF COLUMNS.
         CVD   R8,WORK            GET THE DECIMAL NUMBER OF LINES
         OI    WORK+7,X'0F'           TO SUFFIX THE MEMBER NAME.
         UNPK  BORDNAME+6(2),WORK+6(2)
         SH    R8,=H'2'           TWO BORDERS.
         ST    R8,MOVLINES        NUMBER OF NON-BORDER LINES.
         SH    R9,=H'2'           TWO BORDERS.
         ST    R9,MOVECOLS        NUMBER OF NON-BORDER COLUMNS.
         MR    R2,R8              COLUMNS TIMES NUMBER OF BLANK LINES.
         ST    R3,ELIGIBLS        SAVE FOR LATER (SIDE BORDRS WEIGHTED)
         AL    R3,COLUMNS         GET BOTTOM BORDER LOCATION.
         BCTR  R3,0               POINT TO LAST RIGHT SIDE BORDER.
         ST    R3,LASTSPOT        SAVE LAST ELIGIBLE SPOT LOCATION.
         L     R1,COLUMNS
         M     R0,LINES           GET TOTAL SCREEN SIZE.
         STH   R1,SCRNSIZE        SAVE IT FOR LATER.
         GTTERM PRMSZE=WASTE,ATTRIB=TERMATTR  GET TERMINAL ATTRIBUTES.
         LTR   R15,R15            SUCCESSFUL?
         BZ    GOTTERM            YES, CHECK QUERY BIT.
         STFSMODE ON,INITIAL=YES  NO, GET INTO FULLSCREEN MODE.
         CLI   OSBITS,X'13'       PRE-XA MVS (WITHOUT ACF/VTAM)?
         BNE   GTSACODE           NO, MAKE NO ASSUMPTIONS.
         MVI   GRAFLAGS,COLR+HLIT+GEOK
         B     GTSACODE           YES, ASSUME THE BEST.
*                                 ACTIVATE VTAM FULL SCREEN MODE.
GOTTERM  STFSMODE ON,INITIAL=YES,NOEDIT=YES
         TM    TERMATTR+3,X'01'   QUERY BIT ON?
         BZ    NOTGRAFC           NO, CAN'T DO QUERY.
         LA    R1,RESETAID        YES, RESET THE TERMINAL AID AND
         LA    R0,L'RESETAID           WAIT TILL THIS IS DONE
         ICM   R1,8,=X'0B'             BEFORE PROCEEDING.
         TPUT  (1),(0),R          TPUT FULLSCR,WAIT,HOLD.
         TPG   QUERY,L'QUERY,NOEDIT,WAIT
QUERYGET LA    R1,BUFFER          TEMPORARY TGET BUFFER FOR RESPONSE
         LA    R0,1024                      FROM READ PARTITION.
         ICM   R1,8,=X'81'        FLAGS FOR TGET ASIS,WAIT.
         TGET  (1),(0),R          TGET ASIS,WAIT.
         CLI   BUFFER,X'6B'       VTAM RESHOW REQUEST (PA/CLEAR KEY)?
         BL    NOTGRAFC           NO, ASSUME QUERY NOT FUNCTIONAL.
         CLI   BUFFER,X'6F'
         BL    QUERYGET           YES, IGNORE AND GET QUERY RESPONSE.
         CLI   BUFFER,X'88'       QUERY RESPONSE AID?
         BNE   NOTGRAFC           NO, UNEXPECTED DATA, FORGET QUERY.
         SLR   R0,R0              CLEAR FOR INSERTS.
         LA    R15,BUFFER         POINT TO THE AID.
NOTSBFLD LA    R15,1(,R15)        IGNORE A BYTE.
         BCT   R1,QUERYFIX        DECREMENT THE LENGTH.
         B     NOTGRAFC           JUST IN CASE THAT WAS THE LAST BYTE.
QUERYFIX TM    3(R15),X'80'       LOOK LIKE A VALID QCODE?
         BNO   NOTSBFLD           NO, SKIP A BYTE.
         CLI   0(R15),0           LENGTH LESS THAT 256?
         BNE   NOTSBFLD           NO, SKIP A BYTE.
QUERYPRS CLI   2(R15),X'81'       QUERY REPLY ID?
         BNE   NOTSBFLD           NO, SKIP A BYTE.
         CLI   3(R15),X'86'       QUERY REPLY COLOUR ID?
         BE    QUERYCLR           YES, PROCESS COLOUR SUPPORT.
         CLI   3(R15),X'87'       QUERY REPLY HIGHLIGHTING ID?
         BE    QUERYHLT           YES, PROCESS HIGHLIGHTING SUPPORT.
         CLI   3(R15),X'85'       QUERY REPLY SYMBOL SETS ID?
         BE    QUERYSYM           YES, PROCESS SYMBOL SETS SUPPORT.
         CLI   3(R15),X'93'       QUERY REPLY PC ATTACHMENT ID?
         BE    QUERYPCA           YES, PROCESS PC/PS2 3270 EMULATION.
         CLI   3(R15),X'A6'       QUERY REPLY IMPLICIT PARTITION ID?
         BE    QUERYIMP           YES, PROCESS PC/PS2 3270 EMULATION.
NXTSBFLD ICM   R0,3,0(R15)        NO, LOAD SUB-FIELD LENGTH.
         SR    R1,R0              SUBTRACT IT FROM TGET DATA LENGTH.
         BZ    NOTGRAFC           END OF QUERY, INITIALIZATION DONE.
         BM    QUERYGET           QUERY CONTINUES IN NEXT BLOCK.
         AR    R15,R0             POINT TO NEXT SUB-FIELD.
         B     QUERYPRS           EXAMINE IT.
QUERYCLR CLI   5(R15),8           AT LEAST EIGHT COLOUR PAIRS?
         BL    NXTSBFLD           NO, NO 7-COLOUR SUPPORT.
         CLC   8(14,R15),=CL14'11223344556677'  YES, ALL 7 SUPPORTED?
         BNE   NXTSBFLD           NO, DON'T SET 7-COLOUR MODE.
         OI    GRAFLAGS,COLR      FLAG COLOUR SUPPORT CERTAINTY.
         B     NXTSBFLD           EXTENDED CAPABILITY NOW FLAGGED.
QUERYHLT CLI   4(R15),4           AT LEAST FOUR HIGHLIGHTING PAIRS?
         BL    NXTSBFLD           NO, SO DO NOT FLAG IT.
         CLC   7(6,R15),=CL6'112244' YES, BLINK, REVERSE+UNDERSCORE OK?
         BNE   NXTSBFLD           NO.
         OI    GRAFLAGS,HLIT      YES, FLAG HIGHLIGHTING SUPPORT.
         B     NXTSBFLD           EXTENDED CAPABILITY NOW FLAGGED.
QUERYSYM OI    GRAFLAGS,SYMSET    FLAG SYMBOL-SETS SUB-FIELD RETURNED.
         TM    4(R15),X'80'       IS GRAPHICS ESCAPE SUPPORTED?
         BZ    NXTSBFLD           NO, SO DO NOT FLAG IT.
         OI    GRAFLAGS,GEOK      YES, FLAG GRAPHICS ESCAPE SUPPORT.
         B     NXTSBFLD           EXTENDED CAPABILITY NOW FLAGGED.
QUERYPCA OI    GRAFLAGS,PCAF      FLAG PC ATTACHMENT FACILITY TERMINAL.
         B     NXTSBFLD
QUERYIMP OI    GRAFLAGS,IMPLIC    FLAG IMPLICIT PARTITION SUB-FIELD.
         B     NXTSBFLD
NOTGRAFC STFSMODE ON,NOEDIT=NO    TURN OFF NOEDIT INPUT MODE.
GTSACODE LA    R0,X'28'           LOAD IBM SET ATTRIBUTE ORDER CODE.
         TM    OSBITS,X'13'       IS THIS OSIV/F4?  (ASSUME NOT SVS!)
         BO    GOTSACDE           NO, ASSUME NO FJ GEAR ON IBM SYSTEM.
         TM    GRAFLAGS,SYMSET+PCAF+IMPLIC   NON-FUJITSU DATA?
         BNZ   GOTSACDE           YES, CAN'T BE 6682 OR 6683 SCREEN.
         LA    R0,X'0E'           LOAD FACOM SET ATTRIBUTE ORDER CODE.
GOTSACDE STC   R0,BLUE            INSERT CORRECT SA INTO DATA STREAMS.
         STC   R0,RED
         STC   R0,PINK
         STC   R0,GREEN
         STC   R0,TURQ
         STC   R0,YELLOW
         STC   R0,WHITE
         STC   R0,NOHILITE
         STC   R0,BLINKING
         STC   R0,REVERSE
         STC   R0,UNDERSCR
         STC   R0,RESETSA
         MVC   BUFFER(HDRLEN),BUFHDR
         LA    R2,HDRLEN          LENGTH OF DATA STREAM SO FAR.
         LA    R1,BUFFER+HDRLEN   POINT TO NEXT VACANT BUFFER POSITION.
         MVI   BORDCHAR,C'X'      LOAD THE BORDER CHARACTER.
         TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BZ    NOTURQ             NO.
         MVC   0(3,R1),TURQ       YES, USE A PRETTY COLOUR.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
NOTURQ   TM    GRAFLAGS,HLIT      EXTENDED HIGHLIGHTING SUPPORTED?
         BZ    X4BORDER           NO, USE 'X'S FOR BORDER.
         MVC   0(3,R1),REVERSE    USE REVERSE VIDEO BLANKS FOR BORDER.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
         MVI   BORDCHAR,C' '      LOAD THE BORDER CHARACTER.
X4BORDER MVI   0(R1),X'3C'        REPEAT-TO-ADDRESS.
         LA    R0,1
         AL    R0,COLUMNS         GET LOCATION OF 1ST NON-BORDER POSI.
         STH   R0,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF SAME.
         STCM  R0,3,1(R1)         ADDRESS PART OF REPEAT-TO-ADDRESS.
         MVC   3(1,R1),BORDCHAR   MAKE THE TOP BORDER.
         LA    R1,4(,R1)          ADJUST BUFFER POINTER.
         LA    R2,4(,R2)          ADJUST LENGTH COUNTER.
         L     R3,COLUMNS
         BCTR  R3,0               POINT TO TOP RIGHT CORNER.
         L     R15,MOVLINES       LOOP COUNTER.
BORDERLP AL    R3,COLUMNS         POINT TO NEXT RIGHT SIDE BORDER.
         STH   R3,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF SAME.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,3,1(R1)         ADDRESS PART OF SET-BUFFER-ADDRESS.
         MVC   3(1,R1),BORDCHAR   SUPPLY RIGHT SIDE BORDER.
         MVC   4(1,R1),BORDCHAR   SUPPLY LEFT SIDE BORDER ON NEXT LINE.
         LA    R1,5(,R1)          ADJUST BUFFER POINTER.
         LA    R2,5(,R2)          ADJUST LENGTH COUNTER.
         BCT   R15,BORDERLP       MAKE THE NEXT LINE'S BORDER.
         CLI   COLUMNS+3,80       LESS THAN EIGHTY COLUMNS?
         BL    ACRNOKAY           YES, FORGET ABOUT SHOWING ACRONYM.
         MVC   0(ACRNMLEN,R1),ACRNMMSG     MAKE THE BOTTOM BORDER.
         LA    R1,ACRNMLEN(,R1)   ADJUST BUFFER POINTER.
         LA    R2,ACRNMLEN(,R2)   ADJUST LENGTH COUNTER.
ACRNOKAY MVC   0(3,R1),REPTOTOP
         MVC   3(1,R1),BORDCHAR
         LA    R1,4(,R1)          ADJUST BUFFER POINTER.
         LA    R2,4(,R2)          ADJUST LENGTH COUNTER.
         TM    GRAFLAGS,HLIT      EXTENDED HIGHLIGHTING SUPPORTED?
         BZ    UNREVSNK           NO.
         MVC   0(3,R1),NOHILITE   YES, NO HIGHLIGHTING FOR SNAKE.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
UNREVSNK TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BZ    NOGRNSNK           NO.
         MVC   0(3,R1),GREEN      YES, COLOUR THE SNAKE.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
NOGRNSNK L     R5,LINES
         SRL   R5,1
         BCTR  R5,0
         BCTR  R5,0               GET INITIAL LINE NUMBER.
         M     R4,COLUMNS
         LA    R5,10(,R5)         FIXED INITIAL LOCATION FOR SNAKE.
         LA    R3,SNAKELOC
         LA    R4,THESNAKE
         LA    R15,SNAKELEN/4
INITLOOP STH   R5,TOLOC           LOCATION OF THIS SNAKE SEGMENT.
         STH   R5,0(,R3)          SAVE IT IN SNAKELOC.
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF SAME.
         STCM  R0,3,1(R4)         SAVE IT IN THESNAKE.
         LA    R5,1(,R5)          GET INITIAL LOCATION OF NEXT SEGMENT.
         LA    R3,2(,R3)          UPDATE SNAKELOC POINTER.
         LA    R4,4(,R4)          UPDATE THESNAKE POINTER.
         BCT   R15,INITLOOP       INITIALIZE NEXT SNAKE SEGMENT.
         BCTR  R5,0               POINT BACK TO SNAKE'S HEAD.
         SLR   R4,R4              CLEAR FOR DIVIDE.
         D     R4,COLUMNS
         STM   R4,R5,SNAKEX       SAVE SNAKE'S HEAD'S CO-ORDS.
         ST    R1,SNAKEPTR        SAVE ADDRESS OF SNAKE IN DATA STREAM.
         MVC   0(SNAKELEN-4,R1),THESNAKE+4
         LA    R1,SNAKELEN-4(,R1) ADJUST LENGTH POINTER.
         LA    R2,SNAKELEN-4(,R2) ADJUST LENGTH COUNTER.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         ST    R1,HOMEPNTR        SAVE ADDRESS OF HOME IN DATA STREAM.
         TM    GRAFLAGS,HLIT      EXTENDED HIGHLIGHTING SUPPORTED?
         BZ    NORMHOME           NO, NORMAL VIDEO FOR HOME.
         MVC   3(3,R1),REVERSE    YES, PUT REVERSE VIDEO BACK ON.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
NORMHOME TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BZ    MONOHOME           NO, MONOCHROME.
         MVC   3(3,R1),RED        YES, LOAD THE COLOUR FOR HOME.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
MONOHOME MVI   3(R1),C'#'         LOAD THE CHARACTER DENOTING HOME.
         TM    GRAFLAGS,GEOK      GRAPHIC ESCAPE SUPPORTED?
         BZ    MADEHOME           NO, HOME NOW BUILT.
         MVC   3(2,R1),=X'08C3'   YES, USE A GRAPHIC CHAR FOR HOME.
         LA    R1,1(,R1)          ADJUST BUFFER POINTER.
         LA    R2,1(,R2)          ADJUST LENGTH COUNTER.
MADEHOME LA    R1,4(,R1)          ADJUST BUFFER POINTER.
         LA    R2,4(,R2)          ADJUST LENGTH COUNTER.
         TM    GRAFLAGS,HLIT      EXTENDED HIGHLIGHTING SUPPORTED?
         BZ    HOMEDONE           NO, ALREADY NORMAL.
         MVC   0(3,R1),NOHILITE   YES, TURN OFF REVERSE VIDEO.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
HOMEDONE MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         ST    R1,PLAYRPTR        SAVE ADDRESS OF PLAYER DATA.
         TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BZ    MONOPLYR           NO, MONOCHROME.
         MVC   3(3,R1),WHITE      YES, LOAD THE COLOUR FOR THE PLAYER.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
MONOPLYR MVI   3(R1),C'I'         LOAD CHARACTER DENOTING THE PLAYER.
         LA    R1,4(,R1)          ADJUST BUFFER POINTER.
         LA    R2,4(,R2)          ADJUST LENGTH COUNTER.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         ST    R1,MONEYPTR        SAVE ADDRESS OF MONEY IN DATA STREAM.
         TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BZ    MONOMONY           NO, MONOCHROME.
         MVC   3(3,R1),YELLOW     YES, LOAD THE COLOUR FOR THE MONEY.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
MONOMONY MVI   3(R1),C'$'         LOAD THE CHARACTER DENOTING MONEY.
         LA    R1,4(,R1)          ADJUST BUFFER POINTER.
         LA    R2,4(,R2)          ADJUST LENGTH COUNTER.
         ST    R1,TRLRPNTR        SAVE ADDRESS OF DATA STREAM TRAILER.
         MVC   0(4,R1),STRMTRLR   TACK ON DATA STREAM TRAILER.
         LA    R2,4(,R2)          ADJUST LENGTH COUNTER.
         ST    R2,IMAGESIZ        SAVE IT FOR SCREEN REFRESHES.
         MVI   UPDTSTRM,X'C1'     WCC TO RESET MDT.
         TITLE ' GENERATE A NEW TARGET '
NEWTARGT TIME  TU                 GET A "RANDOM NUMBER".
         ST    R0,RANDOMTU        SAVE NEW RANDOM NUMBER SEED.
         LR    R6,R0              SAVE THE TIMER UNITS VALUE.
NEWISHTG LR    R3,R6              USE CURRENT TIMER UNITS FOR RANDOM #.
         SLR   R2,R2              CLEAR FOR DIVIDE.
         D     R2,ELIGIBLS        DIVIDE BY # ELIGIBLES + VERT BORDERS.
         L     R5,COLUMNS         GET NUMBER OF COLUMNS.
         AR    R2,R5              ADD OFFSET FOR TOP BORDER TO GET LOC.
CHEKSPOT LR    R4,R2              COPY THE SCREEN LOCATION.
         SRDL  R2,32              PREPARE THE LOCATION FOR DIVIDE.
         DR    R2,R5              DIVIDE SCREEN LOCN OFFSET BY COLUMNS.
         LR    R1,R5
         BCTR  R1,0               GET COLUMNS-1 FOR LATER.
         LTR   R2,R2              ON LEFT SIDE BORDER?
         BNZ   NOTONLFT           NO BECAUSE REMAINDER IS NOT ZERO.
         LA    R4,1(,R4)          YES, SO ADD ONE FOR NEXT LOCATION.
         B     NOTONRIT
USEDSPOT LA    R2,1(,R4)          POINT TO THE NEXT SPOT.
         B     CHEKSPOT           RESTART VERIFICATION.
NOTONLFT CR    R2,R1              ON RIGHT SIDE BORDER?
         BNE   NOTONRIT           NO.
         LA    R4,2(,R4)          YES, SO ADD TWO (SKIP LEFT ALSO).
NOTONRIT C     R4,LASTSPOT        GONE PASSED END OF SCREEN?
         BL    STILLLOW           NO.  (NOT YET ANYWAY.)
         LA    R4,1               YES, START AT TOP LEFT AGAIN.
         AL    R4,COLUMNS         POINT PAST TOP BORDER LINE.
STILLLOW LA    R15,SNAKELEN/4-1   GET NUMBER OF SNAKE SEGMENTS.
         LA    R3,SNAKELOC        POINT TO SNAKE LOCATION VECTOR.
SNKCHKLP CH    R4,2(,R3)          "RANDOM" SPOT FILLED BY SNAKE?
         BE    USEDSPOT           YES.
         LA    R3,2(,R3)          NO, POINT TO NEXT SEGMENT.
         BCT   R15,SNKCHKLP       LOOP THROUGH SNAKE CHECK AGAIN.
         ICM   R15,3,HOMELOCN     GET LOCATION OF HOME.
         BNZ   HOMEOKAY           HOME HAS BEEN MADE ALREADY.
         STH   R4,HOMELOCN        NO HOME - BUT THERE IS NOW.
         STH   R4,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF HOME.
         L     R1,HOMEPNTR
         STCM  R0,3,1(R1)         UPDATE REFRESH DATA STREAM.
         SRL   R6,1               SIMULATE NEW "RANDOM NUMBER".
         B     NEWISHTG           NEED NEW LOCATION FOR MONEY NOW.
HOMEOKAY CR    R4,R15             IS NEW SPOT OCCUPIED BY HOME?
         BE    USEDSPOT           YES, SELECT ANOTHER.
         ICM   R15,3,PLAYRLOC     NO, GET LOCATION OF PLAYER.
         BNZ   PLYROKAY           PLAYER HAS BEEN LOCATED.
         STH   R4,PLAYRLOC        NO PLAYER - BUT THERE IS NOW.
         STH   R4,TOLOC
         SRDL  R4,32              PREPARE FOR DIVIDE.
         D     R4,COLUMNS
         STM   R4,R5,PLAYERX      SAVE PLAYER'S CO-ORDINATES.
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF PLAYER.
         L     R1,PLAYRPTR
         STCM  R0,3,1(R1)         UPDATE REFRESH DATA STREAM.
         SRL   R6,1               SIMULATE NEW "RANDOM NUMBER".
         B     NEWISHTG           NEED NEW LOCATION FOR MONEY NOW.
PLYROKAY CR    R4,R15             IS NEW SPOT OCCUPIED THE PLAYER?
         BE    USEDSPOT           YES, SELECT ANOTHER.
         STH   R4,MONEYLOC        SAVE THE MONEY LOCATION.
         STH   R4,TOLOC
         SRDL  R4,32              PREPARE FOR DIVIDE.
         D     R4,COLUMNS
         STM   R4,R5,MONEYX       SAVE MONEY'S CO-ORDINATES.
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF THE MONEY.
         L     R1,MONEYPTR
         STCM  R0,3,1(R1)         UPDATE REFRESH DATA STREAM.
         ICM   R15,3,TPUTLEN      GET UPDATE DATA STREAM LENGTH.
         BZ    RESHOW             IF ZERO THEN SEND INITIAL SCREEN.
         ICM   R3,X'F',SCOREPTR   POINT TO SCORE DISPLAY.
         BNZ   UPDTESCR           GO AND UPDATE IT.
         L     R3,TRLRPNTR        NO SCORE DISPLAY YET SO MAKE ONE.
         ST    R3,SCOREPTR        SAVE SCORE DISPLAY POINTER.
         SLR   R2,R2              ZERO EXTRA DATA LENGTH COUNTER.
         MVC   1(2,R3),=X'40C2'   SBA ALREADY OK SO JUST GIVE ADDRESS.
         TM    GRAFLAGS,HLIT      EXTENDED HIGHLIGHTING SUPPORTED?
         BZ    NORMSCOR           NO, ALREADY NORMAL.
         MVC   3(3,R3),REVERSE    YES, REVERSE LIKE REST OF BORDER.
         LA    R3,3(,R3)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
NORMSCOR MVC   3(1,R3),BORDCHAR   NORMAL BORDER UP TO DOLLAR SIGN.
         TM    GRAFLAGS,HLIT      EXTENDED HIGHLIGHTING SUPPORTED?
         BZ    NORMTRLR           NO, ALREADY NORMAL.
         MVC   9(3,R3),NOHILITE   YES, TURN OFF REVERSE.
         LA    R3,3(,R3)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
NORMTRLR LA    R3,9(,R3)          ADJUST BUFFER POINTER.
         LA    R2,9(,R2)          ADJUST LENGTH COUNTER.
         ST    R3,TRLRPNTR        SAVE NEW TRAILER DATA ADDRESS.
         MVC   0(4,R3),STRMTRLR   SUPPLY TRAILER AGAIN.
         A     R2,IMAGESIZ        ADD PREVIOUS IMAGE SIZE.
         ST    R2,IMAGESIZ        SAVE NEW IMAGE SIZE FOR REFRESH.
         L     R3,SCOREPTR        POINT TO SCORE DATA.
UPDTESCR TM    GRAFLAGS,HLIT      EXTENDED HIGHLIGHTING SUPPORTED?
         BZ    NORMUPDT           NO.
         LA    R3,3(,R3)          YES, POINT PAST REVERSE.
NORMUPDT MVC   4(5,R3),=X'2020202120'    BIG ENOUGH FOR HALFWORD.
         LH    R1,SCORE           GET THE LATEST POTENTIAL SCORE.
         CVD   R1,WORK            MAKE IT DECIMAL, CAN'T BE ZERO.
         EDMK  3(6,R3),WORK+5     DISPLAY THE SCORE.
         BCTR  R1,0               POINT TO BEFORE FIRST DIGIT.
         MVI   0(R1),C'$'         SUPPLY DOLLAR SIGN.
         LA    R1,UPDTSTRM(R15)   GET CURRENT BUFFER POSITION.
         L     R5,PLAYRPTR        POINT TO SBA FOR PLAYER.
         L     R4,MONEYPTR        POINT TO SBA FOR MONEY.
         LR    R3,R4              COPY IT.
         SR    R4,R5              GET LENGTH OF MONEY DATA STREAM.
         BCTR  R4,0               LESS ONE FOR EXECUTE.
         EX    R4,DATAMOVE        COPY THE MONEY DATA STREAM.
         LA    R1,1(R4,R1)        ADJUST DATA STREAM BUFFER POINTER.
         LA    R15,1(R4,R15)      ADJUST DATA STREAM LENGTH COUNTER.
         L     R3,SCOREPTR        POINT TO SCORE DATA STREAM.
         L     R4,TRLRPNTR        POINT TO TRAILER DATA STREAM.
         SR    R4,R3              GET SCORE DATA STREAM LENGTH.
         BCTR  R4,0               LESS ONE FOR EXECUTE.
         EX    R4,DATAMOVE        COPY THE SCORE DATA STREAM.
         LA    R15,1(R4,R15)      ADJUST DATA STREAM LENGTH COUNTER.
         STH   R15,TPUTLEN        SAVE THE UPDATE DATA STREAM LENGTH.
         NI    SNAKFLAG,255-NEXT  NEXT TARGET NO LONGER REQUIRED.
         L     R1,CASHCNTR        GET THE NUMBER OF MONEY BUNDLES
         LA    R1,1(,R1)          GRABBED SO FAR, INCREMENT IT,
         ST    R1,CASHCNTR        AND SAVE IT AGAIN.
         L     R1,CASHMOVS        GET MOVE COUNT FOR PREVIOUS MONEY.
         A     R1,THISTREK        ADD MOVES FOR THIS MONEY BUNDLE.
         ST    R1,CASHMOVS
         SLR   R1,R1
         ST    R1,THISTREK        RESET MOVES-SINCE-LAST-CASH COUNTER.
         B     TPUTSOME           DISPLAY THE NEW MONEY.
DATAMOVE MVC   0(0,R1),0(R3)      <<< EXECUTED >>>
         TITLE ' TERMINAL INPUT/OUTPUT '
TPUTSOME CLC   TPUTLEN,MAXACCUM   IS THE DATA STREAM A BIT LONGISH?
         BH    FORCTPUT           YES, BETTER SEND IT.
         TM    SNAKFLAG,EATEN     IS PLAYER NOW SWALLOWED?
         BO    FORCTPUT           YES, SEND ACCUMULATED DATA.
         TM    SNAKFLAG,RUN+BURST CURRENTLY RUNNING IN BURST MODE?
         BO    RUNAWAY            YES, ACCUMULATE MORE DATA FOR TPUT.
FORCTPUT LH    R15,TPUTLEN        NO, GET THE DATA STREAM LENGTH.
         LA    R1,UPDTSTRM(R15)   POINT PAST END OF DATA.
         MVC   0(4,R1),STRMTRLR   TACK ON DATA STREAM TRAILER.
         LA    R0,4(,R15)         GET TOTAL DATA STREAM LENGTH.
         LA    R1,UPDTSTRM        POINT TO THE DATA STREAM.
         ICM   R1,8,=X'03'        LOAD TPUT FULLSCREEN FLAGS.
         TPUT  (1),(0),R          SHOW THE DATA UPDATES.
         TM    SNAKFLAG,EATEN     IS PLAYER NOW SWALLOWED?
         BO    IAREDEAD           YES, A NOD'S AS GOOD AS A WINK.
TGETSOME LA    R15,1
         STH   R15,TPUTLEN        RESET THE UPDATE DATA ACCUMULATOR.
         TM    SNAKFLAG,RUN       CURRENTLY RUNNING?
         BO    RUNAWAY            YES, DECIDE WHICH WAY.
         XC    WORK,WORK          ERASE PREVIOUS INPUT.
         LA    R1,WORK            POINT TO THE INPUT BUFFER.
         LA    R0,8               GET THE BUFFER LENGTH.
         ICM   R1,8,=X'81'        LOAD TGET ASIS,WAIT FLAGS.
         TGET  (1),(0),R          GET THE PLAYER'S RESPONSE.
         LR    R2,R1              SAVE TGET INPUT DATA LENGTH.
         LA    R0,X'0F'           PREPARE TO EXAMINE THE LOW-ORDER
         NR    R15,R0             NIBBLE OF THE TGET RETURN CODE.
         CH    R15,=H'12'         WAS REPLY AREA LONG ENOUGH?
         BNE   TGETOKAY           YES, EXAMINE INPUT.
         TCLEARQ INPUT            NO, FLUSH THE INPUT BUFFERS.
TGETOKAY CH    R2,BORDBLDL        PA KEY HIT?  (ONE INPUT DATA BYTE?)
         BNH   RESHOW             YES, PERFORM SCREEN REFRESH.
         CLI   WORK,C'1'          PFK 1?
         BE    HELPSCRN           YES, FORMAT AND DISPLAY HELP SCREEN.
         CLI   WORK,C'3'          PFK 3?
         BE    CLEANUP            YES, TERMINATE.
         CLI   WORK,C'4'          PFK 4?
         BE    TRAILSW            YES, SWITCH TRAIL.
         CLI   WORK,C'5'          PFK 5?
         BE    BURSTSW            YES, SWITCH BURST MODE.
         CLI   WORK,C'7'          PFK 7?
         BE    STEPUP             YES, MOVE UP.
         CLI   WORK,C'8'          PFK 8?
         BE    STEPDOWN           YES, MOVE DOWN.
         CLI   WORK,C':'          PFK 10?
         BE    STEPLEFT           YES, MOVE LEFT.
         CLI   WORK,C'#'          PFK 11?
         BE    STEPRITE           YES, MOVE RIGHT.
         CLI   WORK,C'@'          PFK 12?
         BE    CLEANUP            YES, TERMINATE.
         CLI   WORK,C'A'          PFK 13?
         BE    HELPSCRN           YES, FORMAT AND DISPLAY HELP SCREEN.
         CLI   WORK,C'C'          PFK 15?
         BE    CLEANUP            YES, TERMINATE.
         CLI   WORK,C'D'          PFK 16?
         BE    TRAILSW            YES, SWITCH TRAIL.
         CLI   WORK,C'E'          PFK 17?
         BE    BURSTSW            YES, SWITCH BURST MODE.
         CLI   WORK,C'G'          PFK 19?
         BE    RUNUP              YES, MOVE UP.
         CLI   WORK,C'H'          PFK 20?
         BE    RUNDOWN            YES, MOVE DOWN.
         CLI   WORK,X'4A'         PFK 22?  (CENT SIGN.)
         BE    RUNLEFT            YES, MOVE LEFT.
         CLI   WORK,C'.'          PFK 23?
         BE    RUNRIGHT           YES, MOVE RIGHT.
         CLI   WORK,C'<'          PFK 24?
         BE    CLEANUP            YES, TERMINATE.
         B     SLITHER            USELESS INPUT SO JUST MOVE THE SNAKE.
         SPACE
RESHOW   LA    R1,BUFFER          POINT TO SCREEN IMAGE START.
         L     R0,IMAGESIZ        GET DATA STREAM LENGTH.
         ICM   R1,X'8',=X'03'     LOAD FULLSCREEN FLAGS.
         TPUT  (1),(0),R          DISPLAY ENTIRE SCREEN IMAGE.
         B     TGETSOME           GO WAIT FOR MORE INPUT.
         SPACE
TRAILSW  XI    THESNAKE+3,X'0B'   TOGGLE TRAIL BETWEEN BLANK AND DOT.
         B     TGETSOME           GO WAIT FOR MORE INPUT.
         SPACE
BURSTSW  XI    SNAKFLAG,BURST     TOGGLE BURST-MODE FLAG.
         B     TGETSOME           GO WAIT FOR MORE INPUT.
         SPACE
HELPSCRN MVC   UPDTSTRM(HDRLEN),BUFHDR
         LA    R2,HDRLEN          LENGTH OF DATA STREAM SO FAR.
         LA    R1,UPDTSTRM+HDRLEN POINT TO NEXT VACANT BUFFER POSITION.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         L     R5,COLUMNS
         SLL   R5,1
         LA    R15,1(,R5)         GET LOCATION FOR SNAKE LEGEND.
         STH   R15,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         STCM  R0,3,1(R1)
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
         TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BZ    HNGRNSNK           NO.
         MVC   0(3,R1),GREEN      YES, COLOUR THE SNAKE.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
HNGRNSNK MVI   0(R1),X'A2'        SHOW A PICTURE OF THE SNAKE.
         MVC   1(6,R1),0(R1)
         MVI   7(R1),X'E2'
         LA    R1,8(,R1)          ADJUST BUFFER POINTER.
         LA    R2,8(,R2)          ADJUST LENGTH COUNTER.
         TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BZ    HLPCOLR1           NO.
         MVC   0(3,R1),BLUE       YES, COLOUR THE TEXT.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
HLPCOLR1 MVC   0(L'HLPMSG01,R1),HLPMSG01
         LA    R1,L'HLPMSG01(,R1) ADJUST BUFFER POINTER.
         LA    R2,L'HLPMSG01(,R2) ADJUST LENGTH COUNTER.
         L     R3,PLAYRPTR        POINT TO PLAYER'S SBA.
         L     R4,MONEYPTR        POINT TO SBA FOR MONEY.
         SR    R4,R3              GET LENGTH OF PLAYER DATA STREAM.
         BCTR  R4,0               LESS ONE FOR EXECUTE.
         EX    R4,DATAMOVE        COPY THE PLAYER DATA STREAM.
         LA    R15,27(,R5)        GET LOCATION FOR PLAYER LEGEND.
         STH   R15,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         STCM  R0,3,1(R1)
         LA    R1,1(R4,R1)        ADJUST BUFFER POINTER.
         LA    R2,1(R4,R2)        ADJUST LENGTH COUNTER.
         TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BZ    HLPCOLR2           NO.
         MVC   0(3,R1),BLUE       YES, COLOUR THE TEXT.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
HLPCOLR2 MVC   0(L'HLPMSG02,R1),HLPMSG02
         LA    R1,L'HLPMSG02(,R1) ADJUST BUFFER POINTER.
         LA    R2,L'HLPMSG02(,R2) ADJUST LENGTH COUNTER.
         L     R3,HOMEPNTR        POINT TO SBA FOR HOME.
         L     R4,PLAYRPTR        POINT TO PLAYER'S SBA.
         SR    R4,R3              GET LENGTH OF HOME DATA STREAM.
         BCTR  R4,0               LESS ONE FOR EXECUTE.
         EX    R4,DATAMOVE        COPY THE PLAYER DATA STREAM.
         A     R5,COLUMNS
         LA    R15,1(,R5)         GET LOCATION FOR HOME LEGEND.
         STH   R15,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         STCM  R0,3,1(R1)
         LA    R1,1(R4,R1)        ADJUST BUFFER POINTER.
         LA    R2,1(R4,R2)        ADJUST LENGTH COUNTER.
         TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BZ    HLPCOLR3           NO.
         MVC   0(3,R1),BLUE       YES, COLOUR THE TEXT.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
HLPCOLR3 MVC   0(L'HLPMSG03,R1),HLPMSG03
         LA    R1,L'HLPMSG03(,R1) ADJUST BUFFER POINTER.
         LA    R2,L'HLPMSG03(,R2) ADJUST LENGTH COUNTER.
         L     R3,MONEYPTR        POINT TO SBA FOR MONEY.
         ICM   R4,X'F',SCOREPTR   POINT TO SCORE DISPLAY.
         BNZ   MONEYEND           GOT END OF THE MONEY DATA STREAM.
         L     R4,TRLRPNTR        POINT TO SBA FOR TRAILER.
MONEYEND SR    R4,R3              GET LENGTH OF MONEY DATA STREAM.
         BCTR  R4,0               LESS ONE FOR EXECUTE.
         EX    R4,DATAMOVE        COPY THE PLAYER DATA STREAM.
         LA    R15,18(,R5)        GET LOCATION FOR MONEY LEGEND.
         STH   R15,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         STCM  R0,3,1(R1)
         LA    R1,1(R4,R1)        ADJUST BUFFER POINTER.
         LA    R2,1(R4,R2)        ADJUST LENGTH COUNTER.
         TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BZ    HLPCOLR4           NO.
         MVC   0(3,R1),BLUE       YES, COLOUR THE TEXT.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
HLPCOLR4 MVC   0(L'HLPMSG04,R1),HLPMSG04
         LA    R1,L'HLPMSG04(,R1) ADJUST BUFFER POINTER.
         LA    R2,L'HLPMSG04(,R2) ADJUST LENGTH COUNTER.
         TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BZ    HLPCOLR5           NO.
         MVC   0(3,R1),TURQ       YES, COLOUR THE TEXT.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
HLPCOLR5 A     R5,COLUMNS
         A     R5,COLUMNS         GET LOCATION FOR PFK HELP.
         STH   R5,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,3,1(R1)
         MVC   3(L'HLPMSG05,R1),HLPMSG05
         LA    R1,L'HLPMSG05+3(,R1)
         LA    R2,L'HLPMSG05+3(,R2)
         A     R5,COLUMNS         GET LOCATION FOR PFK HELP.
         STH   R5,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,3,1(R1)
         MVC   3(L'HLPMSG06,R1),HLPMSG06
         LA    R1,L'HLPMSG06+3(,R1)
         LA    R2,L'HLPMSG06+3(,R2)
         A     R5,COLUMNS         GET LOCATION FOR PFK HELP.
         STH   R5,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,3,1(R1)
         MVC   3(L'HLPMSG07,R1),HLPMSG07
         LA    R1,L'HLPMSG07+3(,R1)
         LA    R2,L'HLPMSG07+3(,R2)
         A     R5,COLUMNS         GET LOCATION FOR PFK HELP.
         STH   R5,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,3,1(R1)
         MVC   3(L'HLPMSG08,R1),HLPMSG08
         LA    R1,L'HLPMSG08+3(,R1)
         LA    R2,L'HLPMSG08+3(,R2)
         A     R5,COLUMNS         GET LOCATION FOR PFK HELP.
         STH   R5,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,3,1(R1)
         MVC   3(L'HLPMSG09,R1),HLPMSG09
         LA    R1,L'HLPMSG09+3(,R1)
         LA    R2,L'HLPMSG09+3(,R2)
         A     R5,COLUMNS         GET LOCATION FOR PFK HELP.
         STH   R5,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,3,1(R1)
         MVC   3(L'HLPMSG10,R1),HLPMSG10
         LA    R1,L'HLPMSG10+3(,R1)
         LA    R2,L'HLPMSG10+3(,R2)
         A     R5,COLUMNS         GET LOCATION FOR PFK HELP.
         STH   R5,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,3,1(R1)
         MVC   3(L'HLPMSG11,R1),HLPMSG11
         LA    R1,L'HLPMSG11+3(,R1)
         LA    R2,L'HLPMSG11+3(,R2)
         TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BZ    HLPCOLR6           NO.
         MVC   0(3,R1),BLUE       YES, COLOUR THE TEXT.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
HLPCOLR6 A     R5,COLUMNS
         A     R5,COLUMNS         GET LOCATION FOR HELP TEXT.
         STH   R5,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,3,1(R1)
         MVC   3(L'HLPMSG12,R1),HLPMSG12
         LA    R1,L'HLPMSG12+3(,R1)
         LA    R2,L'HLPMSG12+3(,R2)
         A     R5,COLUMNS         GET LOCATION FOR HELP TEXT.
         STH   R5,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,3,1(R1)
         MVC   3(L'HLPMSG13,R1),HLPMSG13
         LA    R1,L'HLPMSG13+3(,R1)
         LA    R2,L'HLPMSG13+3(,R2)
         A     R5,COLUMNS         GET LOCATION FOR HELP TEXT.
         STH   R5,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,3,1(R1)
         MVC   3(L'HLPMSG14,R1),HLPMSG14
         LA    R1,L'HLPMSG14+3(,R1)
         LA    R2,L'HLPMSG14+3(,R2)
         A     R5,COLUMNS         GET LOCATION FOR HELP TEXT.
         STH   R5,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,3,1(R1)
         MVC   3(L'HLPMSG15,R1),HLPMSG15
         LA    R1,L'HLPMSG15+3(,R1)
         LA    R2,L'HLPMSG15+3(,R2)
         A     R5,COLUMNS         GET LOCATION FOR HELP TEXT.
         STH   R5,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,3,1(R1)
         MVC   3(L'HLPMSG16,R1),HLPMSG16
         LA    R1,L'HLPMSG16+3(,R1)
         LA    R2,L'HLPMSG16+3(,R2)
         A     R5,COLUMNS         GET LOCATION FOR HELP TEXT.
         STH   R5,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF TEXT.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,3,1(R1)
         MVC   3(L'HLPMSG17,R1),HLPMSG17
         LA    R1,L'HLPMSG17+3(,R1)
         LA    R2,L'HLPMSG17+3(,R2)
         MVC   0(4,R1),STRMTRLR   TACK ON DATA STREAM TRAILER.
REDOHELP LA    R0,4(,R2)          GET FINAL HELP DATA STREAM LENGTH.
         LA    R1,UPDTSTRM        POINT TO HELP SCREEN IMAGE START.
         ICM   R1,X'8',=X'03'     LOAD FULLSCREEN FLAGS.
         TPUT  (1),(0),R          DISPLAY ENTIRE SCREEN IMAGE.
         XC    WORK,WORK          ERASE PREVIOUS INPUT.
         LA    R1,WORK            POINT TO THE INPUT BUFFER.
         LA    R0,8               GET THE BUFFER LENGTH.
         ICM   R1,8,=X'81'        LOAD TGET ASIS,WAIT FLAGS.
         TGET  (1),(0),R          GET THE PLAYER'S RESPONSE.
         LR    R3,R1              SAVE TGET INPUT DATA LENGTH.
         LA    R0,X'0F'           PREPARE TO EXAMINE THE LOW-ORDER
         NR    R15,R0             NIBBLE OF THE TGET RETURN CODE.
         CH    R15,=H'12'         WAS REPLY AREA LONG ENOUGH?
         BNE   HELPOKAY           YES, EXAMINE INPUT.
         TCLEARQ INPUT            NO, FLUSH THE INPUT BUFFERS.
HELPOKAY CH    R3,BORDBLDL        PA KEY HIT?  (ONE INPUT DATA BYTE?)
         BNH   REDOHELP           YES, RESHOW HELP SCREEN.
         CLI   WORK,C'1'          PFK 1?
         BE    REDOHELP           YES, RESHOW HELP SCREEN.
         CLI   WORK,C'3'          PFK 3?
         BE    CLEANUP            YES, TERMINATE.
         CLI   WORK,C'@'          PFK 12?
         BE    CLEANUP            YES, TERMINATE.
         CLI   WORK,C'A'          PFK 13?
         BE    REDOHELP           YES, RESHOW HELP SCREEN.
         CLI   WORK,C'C'          PFK 15?
         BE    CLEANUP            YES, TERMINATE.
         CLI   WORK,C'<'          PFK 24?
         BE    CLEANUP            YES, TERMINATE.
         B     RESHOW             NO, BACK TO THE MATTER AT HAND.
         TITLE ' PLAYER MOVEMENT '
RUNAWAY  SLR   R1,R1              PLAYER IS RUNNING, BUT WHICH WAY?
         IC    R1,RUNINDEX
         L     R1,RUNTABLE(R1)    POINT TO CORRECT DIRECTION'S CODE.
         BR    R1                 GO TO IT.
         SPACE
RUNUP    MVI   RUNINDEX,0         LOAD RUNTABLE INDEX.
         OI    SNAKFLAG,RUN       FLAG RUNNING STATUS.
STEPUP   LH    R1,PLAYRLOC        GET THE PLAYER'S LOCATION.
         SL    R1,COLUMNS         POINT TO NEW LOCATION.
         B     TAKESTEP           GO PERFORM FEASIBILITY STUDY.
         SPACE
RUNDOWN  MVI   RUNINDEX,4         LOAD RUNTABLE INDEX.
         OI    SNAKFLAG,RUN       FLAG RUNNING STATUS.
STEPDOWN LH    R1,PLAYRLOC        GET THE PLAYER'S LOCATION.
         AL    R1,COLUMNS         POINT TO NEW LOCATION.
         B     TAKESTEP           GO PERFORM FEASIBILITY STUDY.
         SPACE
RUNLEFT  MVI   RUNINDEX,8         LOAD RUNTABLE INDEX.
         OI    SNAKFLAG,RUN       FLAG RUNNING STATUS.
STEPLEFT LH    R1,PLAYRLOC        GET THE PLAYER'S LOCATION.
         BCTR  R1,0               POINT TO NEW LOCATION.
         B     TAKESTEP           GO PERFORM FEASIBILITY STUDY.
         SPACE
RUNRIGHT MVI   RUNINDEX,12        LOAD RUNTABLE INDEX.
         OI    SNAKFLAG,RUN       FLAG RUNNING STATUS.
STEPRITE LH    R1,PLAYRLOC        GET THE PLAYER'S LOCATION.
         LA    R1,1(,R1)          POINT TO NEW LOCATION.
         SPACE
TAKESTEP LA    R0,1               PERFORM THE SELECTED MOVE.
         A     R0,THISTREK        ADJUST THE MOVES-FOR-MONEY COUNTER.
         ST    R0,THISTREK
         BAL   R14,CHECKLOC       VALIDATE THE MOVE.
         TM    LOCFLAGS,BRDR+SNKE BORDER OR SNAKE THERE?
         BNZ   STOPRUN            YES, IGNORE THE MOVE.
         STH   R1,PLAYRLOC        NO, SAVE THE PLAYER'S NEW LOCATION.
         STH   R1,TOLOC
         SLR   R0,R0              CLEAR FOR DIVIDE.
         D     R0,COLUMNS
         STM   R0,R1,PLAYERX      SAVE PLAYER'S CO-ORDINATES.
         BAL   R14,CALCPOSI       GET THE 3270 BUFFER ADDRESS OF SAME.
         LH    R15,TPUTLEN        GET UPDATE DATA STREAM LENGTH.
         LA    R1,UPDTSTRM(R15)   GET CURRENT BUFFER POSITION.
         MVI   0(R1),X'11'        SET-BUFFER-ADDRESS.
         L     R3,PLAYRPTR        POINT TO PLAYER'S SBA.
         MVC   1(2,R1),1(R3)      GET PREVIOUS BUFFER ADDRESS.
         MVI   3(R1),C' '         BLANK PREVIOUS PLAYER TOKEN.
         LA    R1,4(,R1)          ADJUST BUFFER POINTER.
         STCM  R0,3,1(R3)         UPDATE THE PLAYER'S BUFFER ADDRESS.
         L     R4,MONEYPTR        POINT TO SBA FOR MONEY.
         SR    R4,R3              GET LENGTH OF PLAYER DATA STREAM.
         BCTR  R4,0               LESS ONE FOR EXECUTE.
         EX    R4,DATAMOVE        COPY THE PLAYER DATA STREAM.
         LA    R15,5(R4,R15)      ADJUST DATA STREAM LENGTH COUNTER.
         STH   R15,TPUTLEN        SAVE THE UPDATE DATA STREAM LENGTH.
         TM    LOCFLAGS,HOME      REACHED HOME-SWEET-HOME?
         BO    GONEHOME           YES.
         TM    LOCFLAGS,CASH      PICKED UP SOME CASH?
         BZ    RUNCHECK           NO, RUN CHECKS.
         OI    SNAKFLAG,NEXT      YES, NEXT MONEY BUNDLE REQUIRED.
         LH    R1,SCORE           GET THE POTENTIAL SCORE SO FAR.
         LA    R1,25(,R1)         ADD BUNDLE MONETARY VALUE.
         STH   R1,SCORE           SAVE THE NEW POTENTIAL SCORE.
STOPRUN  NI    SNAKFLAG,255-RUN   STOP RUNNING.
         B     SLITHER            GO MOVE THE SNAKE.
RUNCHECK TM    SNAKFLAG,RUN       CURRENTLY RUNNING?
         BZ    SLITHER            NO, MOVE THE SNAKE.
         TM    RUNINDEX,8         IS RUN INDEX 8 OR 12?
         BO    RUNVERT            YES, RUNNING LEFT OR RIGHT.
         CLC   PLAYERY,MONEYY     REACHED LINE WITH MONEY?
         BE    STOPRUN            YES, STOP RUNNING.
         B     SLITHER            NO, KEEP RUNNING UP OR DOWN.
RUNVERT  CLC   PLAYERX,MONEYX     REACHED COLUMN WITH MONEY?
         BE    STOPRUN            YES, STOP RUNNING.
         TITLE ' SNAKE MOVEMENT '
SLITHER  LA    R1,THESNAKE        POINT TO SNAKE DATA STREAM.
         LA    R0,SNAKELEN/4-1    GET NUMBER OF SEGMENTS.
SLTHERNG MVC   1(2,R1),5(R1)      PERCOLATE SNAKE SEGMENTS.
         LA    R1,4(,R1)          POINT TO NEXT SEGMENT.
         BCT   R0,SLTHERNG        PROCESS NEXT SEGMENT.
         MVC   SNAKELOC(SNAKELEN/2-2),SNAKELOC+2
         LH    R1,SNKHDLOC        GET CURRENT SNAKE'S HEAD LOCATION.
         SL    R1,COLUMNS         POINT TO "UP".
         BAL   R14,CHECKLOC       PERFORM LOCATION VALIDATION.
         MVC   SNAKEUP,LOCFLAGS   REMEMBER DETAILS OF THIS LOCATION.
         STH   R1,SNAKEUP+2       REMEMBER THE LOCATION.
         LA    R1,1(,R1)          POINT TO "UP-AND-RIGHT".
         BAL   R14,CHECKLOC       PERFORM LOCATION VALIDATION.
         MVC   SNAKEUPR,LOCFLAGS  REMEMBER DETAILS OF THIS LOCATION.
         STH   R1,SNAKEUPR+2      REMEMBER THE LOCATION.
         AL    R1,COLUMNS         POINT TO "RIGHT".
         BAL   R14,CHECKLOC       PERFORM LOCATION VALIDATION.
         MVC   SNAKERHT,LOCFLAGS  REMEMBER DETAILS OF THIS LOCATION.
         STH   R1,SNAKERHT+2      REMEMBER THE LOCATION.
         AL    R1,COLUMNS         POINT TO "DOWN-AND-RIGHT".
         BAL   R14,CHECKLOC       PERFORM LOCATION VALIDATION.
         MVC   SNAKEDNR,LOCFLAGS  REMEMBER DETAILS OF THIS LOCATION.
         STH   R1,SNAKEDNR+2      REMEMBER THE LOCATION.
         BCTR  R1,0               POINT TO "DOWN".
         BAL   R14,CHECKLOC       PERFORM LOCATION VALIDATION.
         MVC   SNAKEDWN,LOCFLAGS  REMEMBER DETAILS OF THIS LOCATION.
         STH   R1,SNAKEDWN+2      REMEMBER THE LOCATION.
         BCTR  R1,0               POINT TO "DOWN-AND-LEFT".
         BAL   R14,CHECKLOC       PERFORM LOCATION VALIDATION.
         MVC   SNAKEDNL,LOCFLAGS  REMEMBER DETAILS OF THIS LOCATION.
         STH   R1,SNAKEDNL+2      REMEMBER THE LOCATION.
         SL    R1,COLUMNS         POINT TO "LEFT".
         BAL   R14,CHECKLOC       PERFORM LOCATION VALIDATION.
         MVC   SNAKELFT,LOCFLAGS  REMEMBER DETAILS OF THIS LOCATION.
         STH   R1,SNAKELFT+2      REMEMBER THE LOCATION.
         SL    R1,COLUMNS         POINT TO "UP-AND-LEFT".
         BAL   R14,CHECKLOC       PERFORM LOCATION VALIDATION.
         MVC   SNAKEUPL,LOCFLAGS  REMEMBER DETAILS OF THIS LOCATION.
         STH   R1,SNAKEUPL+2      REMEMBER THE LOCATION.
         SPACE
         L     R1,RANDOMTU        GET PREVIOUS "RANDOM" NUMBER.
         SLR   R0,R0              PREPARE FOR DIVIDE.
         D     R0,=F'13'          DIVIDE BY A PRIME NUMBER.
         X     R1,RANDOMTU        XOR ANSWER WITH PREVIOUS NUMBER.
         ST    R1,RANDOMTU        SAVE THE NEW "RANDOM" NUMBER.
         CLM   R1,1,RNDMCNTR+3    COMPARE IT WITH RANDOM MOVE COUNTER.
         BL    CLEVERMV           PERHAPS MAKE AN "INTELLIGENT" MOVE.
FORCRAND CLI   RNDMCNTR+3,120     "STEADY STATE RANDOMNESS CONSTANT".
         BH    NORNDINC           DO NOT INCREMENT ABOVE THIS VALUE.
         L     R3,RNDMCNTR        GET THE "RANDOM MOVE" COUNTER.
         LA    R3,1(,R3)          INCREMENT IT.
         ST    R3,RNDMCNTR        SAVE IT AGAIN.
NORNDINC STC   R1,WORK
         NI    WORK,B'00011100'   GET THREE "RANDOM" BITS.
         LA    R15,EOSNKMVS       POINT TO END OF TABLE.
         SLR   R1,R1
         IC    R1,WORK            GET INDEX.
         LA    R3,SNKMOVES(R1)    POINT TO "RANDOM" MOVE ENTRY.
TESTRAND TM    0(R3),BRDR+HOME+CASH
         BZ    RANDMOVE           ACCEPTABLE LOCATION SO USE IT.
         LA    R3,4(,R3)          UNACCEPTABLE, SO TRY NEXT ONE.
         CLR   R3,R15             PAST THE END OF THE TABLE?
         BL    TESTRAND           NO, GO AHEAD.
         LA    R3,SNKMOVES        YES, WRAP AROUND TO START OF TABLE.
         B     TESTRAND           TEST FIRST ENTRY.
RANDMOVE LH    R1,2(,R3)          LOAD TARGET LOCATION.
         TM    0(R3),YUMMY        LANDED ON PLAYER?
         BO    SNAKSNAK           YES, WELL, I AM RATHER PECKISH.
         B     WRITHE             NO, JUST MAKE THE MOVE.
         SPACE
CLEVERMV LH    R1,SNKHDLOC        GET CURRENT SNAKE'S HEAD LOCATION.
         CLC   SNAKEX,PLAYERX     IS SNAKE TO LEFT OR RIGHT?
         BH    SISRIGHT           TO THE RIGHT.
         BL    SISLEFT            TO THE LEFT.
YCHECK   CLC   SNAKEY,PLAYERY     NEITHER, IS IT ABOVE OR BELOW?
         BH    SISBELOW           BELOW.
         BL    SISABOVE           ABOVE.
CHEKCLVR BAL   R14,CHECKLOC       CHECK OUT "CLEVER" DECISION.
         TM    LOCFLAGS,BRDR+HOME+CASH
         BNZ   FORCRAND           UNACCEPTABLE LOCATION SO GO "RANDOM".
         TM    LOCFLAGS,YUMMY     LANDED ON THE PLAYER?
         BZ    WRITHE             NO, JUST MAKE THE MOVE.
SNAKSNAK OI    SNAKFLAG,EATEN     YES, GOBBLE UP PLAYER AND MONEY.
         SPACE
WRITHE   STH   R1,SNKHDLOC        SAVE SNAKE'S NEW LOCATION.
         STH   R1,TOLOC           SAVE SNAKE'S NEW LOCATION.
         SLR   R0,R0              CLEAR FOR DIVIDE.
         D     R0,COLUMNS
         STM   R0,R1,SNAKEX       SAVE SNAKE'S HEAD'S CO-ORDS.
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF SAME.
         STCM  R0,3,THESNAKE+SNAKELEN-3
         L     R1,SNAKEPTR        SAVE NEW SNAKE IN DATA STREAM.
         MVC   0(SNAKELEN-4,R1),THESNAKE+4
         LH    R2,TPUTLEN         THE THE DATA STREAM LENGTH SO FAR.
         LA    R1,UPDTSTRM(R2)    POINT TO CURRENT BUFFER ADDRESS.
         TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BZ    NOGRENSN           NO.
         MVC   0(3,R1),GREEN      YES, COLOUR THE SNAKE.
         LA    R1,3(,R1)          ADJUST BUFFER POINTER.
         LA    R2,3(,R2)          ADJUST LENGTH COUNTER.
NOGRENSN MVC   0(SNAKELEN,R1),THESNAKE  LOAD THE SNAKE.
         LA    R2,SNAKELEN(,R2)   ADJUST THE BUFFER LENGTH COUNTER.
         STH   R2,TPUTLEN         SAVE IT.
         TM    SNAKFLAG,NEXT      MORE MONEY REQUIRED?
         BO    NEWTARGT           YES, MAKE IT.
         B     TPUTSOME           NO, SHOW THE DATA STREAM.
         SPACE
SISABOVE AL    R1,COLUMNS         GO DOWN.
         B     CHEKCLVR
         SPACE
SISBELOW SL    R1,COLUMNS         GO UP.
         B     CHEKCLVR
         SPACE
SISRIGHT BCTR  R1,0               GO LEFT.
         B     YCHECK
SISLEFT  LA    R1,1(,R1)          GO RIGHT.
         B     YCHECK
         TITLE ' LOCATION VALIDATION SUBROUTINE '
CHECKLOC STM   R14,R12,12(R13)    SAVE CALLER'S REGISTERS.
         MVI   LOCFLAGS,0         RESET ALL LOCATION FLAGS.
         L     R5,COLUMNS         GET THE NUMBER OF SCREEN COLUMNS.
         CR    R1,R5              IS IT ON TOP BORDER?
         BNH   ONBORDER           YES, THAT WAS EASY.
         C     R1,LASTSPOT        IS IT ON BOTTOM BORDER?
         BNL   ONBORDER           YES, THAT WAS EASY.
         LR    R2,R1              COPY THE LOCATION TO BE CHECKED.
         SRDL  R2,32              PREPARE THE LOCATION FOR DIVIDE.
         DR    R2,R5              DIVIDE SCREEN LOCN OFFSET BY COLUMNS.
         LTR   R2,R2              ON LEFT SIDE BORDER?
         BZ    ONBORDER           YES, THAT WAS FAIRLY EASY TOO.
         BCTR  R5,0               GET COLUMNS-1.
         CR    R2,R5              ON RIGHT SIDE BORDER?
         BE    ONBORDER           YES, THAT WAS ALSO FAIRLY EASY.
         LA    R15,SNAKELEN/4-1   GET NUMBER OF SNAKE SEGMENTS.
         LA    R3,SNAKELOC+2      POINT TO SNAKE LOCATION VECTOR.
SNKLOCHK CH    R1,0(,R3)          A SNAKE LOCATION?
         BE    ONSNAKE            YES.
         LA    R3,2(,R3)          NO, POINT TO NEXT SEGMENT.
         BCT   R15,SNKLOCHK       LOOP THROUGH SNAKE CHECK AGAIN.
         CH    R1,HOMELOCN        IS THIS THE LOCATION OF HOME?
         BE    ATHOME             YES.
         CH    R1,MONEYLOC        IS THIS THE LOCATION OF THE MONEY?
         BE    GOLDPILE           YES, COULD GET GOLDEN PILES.
         CH    R1,PLAYRLOC        IS THIS THE LOCATION OF THE PLAYER?
         BE    MEALTIME           YES, COULD BE SNAKE FEEDING TIME.
LOCHKRET LM    R14,R12,12(R13)    END OF LOCATION VALIDATION.
         BR    R14                RETURN TO CALLER.
         SPACE
ONBORDER OI    LOCFLAGS,BRDR      LOCATION IS A BORDER.
         B     LOCHKRET
ONSNAKE  OI    LOCFLAGS,SNKE      LOCATION HAS A SNAKE SEGMENT.
         CH    R1,SNKHDLOC        IS IT THE SNAKE'S HEAD?
         BNE   LOCHKRET           NO.
         OI    LOCFLAGS,SNKHD     YES, FLAG THIS AS WELL.
         B     LOCHKRET
ATHOME   OI    LOCFLAGS,HOME      LOCATION IS HOME-SWEET-HOME.
         B     LOCHKRET
GOLDPILE OI    LOCFLAGS,CASH      HERE IS WHERE THE CASH IS STASHED.
         B     LOCHKRET
MEALTIME OI    LOCFLAGS,YUMMY     PLAYER IS STANDING/RUNNING HERE.
         B     LOCHKRET
         TITLE ' TERMINATION - SCORING '
IAREDEAD MVI   UPDTSTRM+1,X'11'   SET-BUFFER-ADDRESS.
         LH    R5,SNKHDLOC        LOAD DEADY-BONES LOCATION POINTER.
         BCTR  R5,0               POINT TO ONE BEFORE IT.
         STH   R5,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF SAME.
         STCM  R0,3,UPDTSTRM+2
         LA    R3,4               UPDATE DATA STREAM LENGTH SO FAR.
         LA    R2,UPDTSTRM+4      POINT TO NEXT VACANT POSITION.
         TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BZ    GREENSNK           NO.
         MVC   0(3,R2),GREEN      YES, MAKE SNAKE'S FACE GREEN.
         LA    R2,3(,R2)          ADJUST BUFFER POINTER.
         LA    R3,3(,R3)          ADJUST LENGTH COUNTER.
GREENSNK TM    GRAFLAGS,HLIT      EXTENDED HIGHLIGHTING SUPPORTED?
         BZ    FACEIT             NO.
         MVC   0(3,R2),REVERSE    YES, MAKE SNAKE'S FACE REVERSE.
         LA    R2,3(,R2)          ADJUST BUFFER POINTER.
         LA    R3,3(,R3)          ADJUST LENGTH COUNTER.
FACEIT   LA    R8,2(,R5)          POINT TO SNAKE'S LEFT EYE.
         STM   R2,R3,BUFFER       SAVE COUNTERS FOR LATER.
         MVC   0(3,R2),SNKFACE1   LOAD SNAKE'S EYES AND NOSE.
         MVI   3(R2),X'11'        SET-BUFFER-ADDRESS.
         A     R5,COLUMNS         POINT TO SAME COLUMN NEXT LINE.
         STH   R5,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF SAME.
         STCM  R0,3,4(R2)
         MVC   6(3,R2),SNKFACE2   SUPPLY SNAKE'S MOUTH.
         LA    R0,9(,R3)          GET DATA STREAM LENGTH.
         LA    R1,UPDTSTRM        GET DATA STREAM ADDRESS.
         ICM   R1,8,=X'0B'        LOAD TPUT FULLSCR,WAIT,HOLD FLAGS.
         TPUT  (1),(0),R          SHOW THE SNAKE'S FACE.
         STIMER WAIT,BINTVL==F'100'    WAIT A SECOND.
         LM    R2,R3,BUFFER       RESTORE DATA STREAM REGISTERS.
         MVI   0(R2),C'-'         MAKE THE SNAKE WINK.
         STH   R8,TOLOC
         BAL   R14,CALCPOSI       GET 3270 BUFFER ADDRESS OF LEFT EYE.
         STCM  R0,3,UPDTSTRM+2
         LA    R0,1(,R3)          GET DATA STREAM LENGTH.
         LA    R1,UPDTSTRM        GET DATA STREAM ADDRESS.
         ICM   R1,8,=X'0B'        LOAD TPUT FULLSCR,WAIT,HOLD FLAGS.
         TPUT  (1),(0),R          SHOW THE SNAKE WINKING.
         STIMER WAIT,BINTVL==F'100'    WAIT A SECOND.
         MVI   0(R2),X'96'        MAKE THE SNAKE WINK.
         LA    R0,1(,R3)          GET DATA STREAM LENGTH.
         LA    R1,UPDTSTRM        GET DATA STREAM ADDRESS.
         ICM   R1,8,=X'0B'        LOAD TPUT FULLSCR,WAIT,HOLD FLAGS.
         TPUT  (1),(0),R          SHOW THE SNAKE NOT WINKING.
         STIMER WAIT,BINTVL==F'100'    WAIT A SECOND.
         B     END                GATHER STATISTICS.
         SPACE
ENDPUT   LTR   R5,R5              IS TARGET LOCATION NEGATIVE?
         BMR   R14                YES, SUPPRESS OUTPUT.
         CH    R5,SCRNSIZE        IS IT LARGER THAN THE SCREEN SIZE?
         BNLR  R14                YES, SUPPRESS OUTPUT.
         STH   R5,TOLOC
         LR    R15,R14            SAVE RETURN REGISTER.
         BAL   R14,CALCPOSI       GET 3270 DISPLAY BUFFER ADDRESS.
         LR    R14,R15            RESTORE RETURN REGISTER.
         STCM  R0,3,UPDTSTRM+2    SUPPLY BUFFER ADDRESS IN DATA STREAM.
         LR    R0,R3              LOAD DATA STREAM LENGTH.
         LA    R1,UPDTSTRM        LOAD DATA STREAM ADDRESS.
         ICM   R1,8,=X'03'        LOAD TPUT FULLSCR,WAIT FLAGS.
         TPUT  (1),(0),R          DISPLAY THE DATA.
         BR    R14                RETURN TO "GONEHOME" MAINLINE.
         SPACE
GONEHOME LH    R3,TPUTLEN         GET DATA STREAM LENGTH SO FAR.
         LA    R2,UPDTSTRM(R3)    POINT TO NEXT VACANT POSITION.
         MVI   0(R2),X'11'        SET-BUFFER-ADDRESS.
         LH    R5,HOMELOCN        LOAD DATA LOCATION POINTER.
         STH   R5,TOLOC
         BAL   R14,CALCPOSI       GET 3270 DISPLAY BUFFER ADDRESS.
         STCM  R0,3,1(R2)         SUPPLY BUFFER ADDRESS IN DATA STREAM.
         LA    R3,3(,R3)          UPDATE DATA STREAM LENGTH SO FAR.
         LA    R2,3(,R2)          POINT TO NEXT VACANT POSITION.
         TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BZ    NOREDEND           NO.
         MVC   0(3,R2),RED        YES, COLOUR THESE SNAZZIES.
         LA    R2,3(,R2)          ADJUST BUFFER POINTER.
         LA    R3,3(,R3)          ADJUST LENGTH COUNTER.
NOREDEND MVI   0(R2),C'I'         PUT THE PLAYER HOME.
         LA    R0,1(,R3)          LOAD DATA STREAM LENGTH.
         LA    R1,UPDTSTRM        LOAD DATA STREAM ADDRESS.
         ICM   R1,8,=X'03'        LOAD TPUT FULLSCR,WAIT FLAGS.
         TPUT  (1),(0),R          DISPLAY THE DATA.
         MVI   UPDTSTRM+1,X'11'   SET-BUFFER-ADDRESS.
         LA    R3,5               GET LENGTH PLUS ONE FOR CHARACTER.
         LA    R2,UPDTSTRM+4      POINT TO NEXT VACANT POSITION.
         TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BZ    NOREDSQR           NO.
         MVC   0(3,R2),RED        YES, COLOUR THESE SNAZZIES.
         LA    R2,3(,R2)          ADJUST BUFFER POINTER.
         LA    R3,3(,R3)          ADJUST LENGTH COUNTER.
NOREDSQR MVI   0(R2),C'#'         NEW DISPLAY CHARACTER.
         TM    GRAFLAGS,HLIT      EXTENDED HIGHLIGHTING SUPPORTED?
         BZ    NOREVSPC           NO.
         MVC   0(3,R2),REVERSE    YES, USE REVERSE VIDEO.
         LA    R2,3(,R2)          ADJUST BUFFER POINTER.
         LA    R3,3(,R3)          ADJUST LENGTH COUNTER.
         MVI   0(R2),C' '         NEW DISPLAY CHARACTER.
NOREVSPC LA    R5,1(,R5)          GO RIGHT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         S     R5,COLUMNS         GO UP.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         BCTR  R5,0               GO LEFT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         BCTR  R5,0               GO LEFT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         A     R5,COLUMNS         GO DOWN.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         A     R5,COLUMNS         GO DOWN.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         LA    R5,1(,R5)          GO RIGHT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         LA    R5,1(,R5)          GO RIGHT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         LA    R5,1(,R5)          GO RIGHT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         S     R5,COLUMNS         GO UP.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         S     R5,COLUMNS         GO UP.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         S     R5,COLUMNS         GO UP.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         BCTR  R5,0               GO LEFT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         BCTR  R5,0               GO LEFT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         BCTR  R5,0               GO LEFT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         BCTR  R5,0               GO LEFT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         A     R5,COLUMNS         GO DOWN.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         A     R5,COLUMNS         GO DOWN.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         A     R5,COLUMNS         GO DOWN.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         A     R5,COLUMNS         GO DOWN.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         LA    R5,1(,R5)          GO RIGHT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         LA    R5,1(,R5)          GO RIGHT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         LA    R5,1(,R5)          GO RIGHT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         LA    R5,1(,R5)          GO RIGHT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         LA    R5,1(,R5)          GO RIGHT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         S     R5,COLUMNS         GO UP.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         S     R5,COLUMNS         GO UP.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         S     R5,COLUMNS         GO UP.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         S     R5,COLUMNS         GO UP.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         S     R5,COLUMNS         GO UP.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         BCTR  R5,0               GO LEFT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         BCTR  R5,0               GO LEFT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         BCTR  R5,0               GO LEFT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         BCTR  R5,0               GO LEFT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         BCTR  R5,0               GO LEFT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         BCTR  R5,0               GO LEFT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         A     R5,COLUMNS         GO DOWN.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         A     R5,COLUMNS         GO DOWN.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         A     R5,COLUMNS         GO DOWN.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         A     R5,COLUMNS         GO DOWN.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         A     R5,COLUMNS         GO DOWN.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         A     R5,COLUMNS         GO DOWN.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         LA    R5,1(,R5)          GO RIGHT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         LA    R5,1(,R5)          GO RIGHT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         LA    R5,1(,R5)          GO RIGHT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         LA    R5,1(,R5)          GO RIGHT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         LA    R5,1(,R5)          GO RIGHT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         LA    R5,1(,R5)          GO RIGHT.
         BAL   R14,ENDPUT         DISPLAY THIS LITTLE UPDATE.
         SPACE
END      SLR   R5,R5              PREPARE FOR IC.
         MVI   LOCFLAGS,0         CLEAR FOR LATER.
         L     R4,540             GET POINTER TO CURRENT TCB.
         L     R4,12(,R4)         POINT TO TIOT.
         MVC   SNAKEUSR,0(R4)     GET USERID.
         LA    R4,24(,R4)         POINT TO TIOELNGH.
CHKDDNAM CLC   4(8,R4),SNAKFILE+DCBDDNAM-IHADCB
         BE    OPENFILE           FILE EXISTS SO GO AND OPEN IT.
         IC    R5,0(,R4)          GET TIOT ENTRY LENGTH.
         AR    R4,R5              POINT TO NEXT TIOT ENTRY.
         CLI   0(R4),0            ZERO LENGTH ENTRY?
         BNE   CHKDDNAM           NO, CHECK OUT THIS ENTRY.
         B     FAREWELL           YES, NOT IN TIOT SO FORGET SCOREBOARD
OPENFILE TIME  DEC                GET DATE AND TIME.
         LR    R4,R0              SAVE TIME.
         LR    R5,R1              SAVE DATE.
         OPEN (SNAKFILE,(UPDAT))  OPEN SNAKFILE FOR UPDATE.
         BLDL  SNAKFILE,BORDBLDL  CHECK FOR MEMBER.
         LA    R3,255             GET X'FF'.
         NR    R15,R3             GET BLDL RETURN CODE - MEMBER THERE?
         BZ    GOTBOARD           YES.
         CH    R15,=H'4'          NASTY PROBLEM?
         BH    EOPDSDIR           YES, FORGET THE WHOLE THING.
         TM    SNAKFLAG,EATEN     WAS THE PLAYER EATEN?
         BO    EOPDSDIR           YES, DON'T MAKE A SCOREBOARD.
         CLOSE (SNAKFILE)         CLOSE THE FILE - NOTHING DONE YET.
         OPEN (SNAKFILE,(OUTPUT)) OPEN SNAKFILE FOR OUTPUT.
GOTBOARD MVC   WORK(1),BORDC      GET ENTRY LENGTH CODE.
         NI    WORK,X'7F'         TURN OFF ALIAS BIT.
         CLI   WORK,15            SPF STATS?
         BE    RIGHTMEM           YES, SCOREBOARD CHECK IS ON.
         CLI   WORK,14            PFD STATS?
         BE    RIGHTMEM           YES, SCOREBOARD CHECK IS ON.
         MVI   BORDC,14           USER DATA OF PFD STATS.
*        OK FOR REVIEW WITH X-RAY VISION BUT INVISIBLE TO SPF.
         MVI   BORDV,1            SNAKE R1 - LATER RLSES MAY TEST THIS.
         MVI   BORDM,0            NO UPDATES YET.
         STCM  R5,X'F',BORDCR     SAVE CREATION DATE.
         B     STOWREST           SAVE THE REMAINING NECESSARIES.
RIGHTMEM MVC   DATEO,BORDCD       SAVE DATE OF PREVIOUS BEST.
         MVC   TIMEO,BORDCT       SAVE TIME OF PREVIOUS BEST.
         MVC   SCOREO,BORDMD      SAVE PREVIOUS BEST SCORE.
         MVC   BESTUSER,BORDID    SAVE PREVIOUS BEST USERID.
         TM    SNAKFLAG,EATEN     WAS THE PLAYER EATEN?
         BO    EOPDSDIR           YES, DO NOT WRITE TO FILE.
         CLC   SCORE,SCOREO       IS THIS A BETTER SCORE?
         BNH   EOPDSDIR           NO, DO NOT WRITE TO FILE.
* COULD USE CONTENTS OF MEMBER TO LIST TOP 10 - LESS CHANCE OF CORUPTN.
         SLR   R3,R3
         IC    R3,BORDM           GET UPDATE COUNTER.
         LA    R3,1(,R3)          INCREMENT.
         STC   R3,BORDM           SAVE IT AGAIN.
STOWREST STCM  R5,X'F',BORDCD     SAVE CURRENT DATE.
         STCM  R4,X'C',BORDCT     SAVE CURRENT TIME.
         MVC   BORDMD,SCORE       SAVE NEW BEST SCORE.
         MVC   BORDID,SNAKEUSR    SAVE NEW BEST SNAKE.
         MVC   BORDK(USERLEN),BORDC    CHANGE FROM BLDL TO STOW FORMAT.
         STOW  SNAKFILE,BORDNAME,R ZAP IN NEW DETAILS QUICK.
         STC   R15,LOCFLAGS       SAVE STOW RETURN CODE.
EOPDSDIR CLOSE (SNAKFILE)         CLOSE THE FILE - HOPE NO CORRUPTIONS.
         TITLE ' TERMINATION - STATISTICS AND MESSAGE DISPLAY '
FAREWELL DS    0H
         L     R1,540             POINT TO THE CURRENT TCB.
         ICM   R1,X'F',164(R1)    POINT TO THE TIMING CONTROL TABLE.
         BZ    MAKEMSGS           SMF NOT ACTIVE SO FORGET IT.
         MVC   TGETCNTN(8),48(R1) GET CURRENT TGET AND TPUT COUNTS.
         SPACE
MAKEMSGS MVC   UPDTSTRM(8),CLEARALL NO, CLEAR THE SCREEN FOR MESSAGES.
         MVC   UPDTSTRM+8(2),=X'1DF8'  PROTECT THE STATS ON THE SCREEN.
         LA    R8,10              DATA STREAM LENGTH SO FAR.
         LA    R9,UPDTSTRM+10     CURRENT BUFFER POSITION.
         TM    GRAFLAGS,COLR+HLIT IN GRAPHIC MODE?
         BNO   PINKYPOO           NO, SKIP PINK.
         MVC   UPDTSTRM+10(3),PINK     SA,COLOUR,PINK.
         MVC   UPDTSTRM+13(3),UNDERSCR SA,HILITE,UNDERSCR.
         LA    R8,16              DATA STREAM LENGTH SO FAR.
         LA    R9,UPDTSTRM+16     CURRENT BUFFER POSITION.
PINKYPOO ICM   R3,X'F',TCTADDR    ANY TSO STATISTICS TO REPORT?
         BZ    TREKPUT            NO.
         SPACE
         LA    R1,STATSPOS        LINE NUMBER FOR STATSMSG.
         M     R0,COLUMNS         GET SCREEN LOCATION.
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN.
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR STATSMSG BUFFER ADDR.
         MVI   0(R9),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,X'3',1(R9)
         L     R1,TGETCNTN
         S     R1,TGETCNTO
         CVD   R1,WORK
         ED    TSOTGETS,WORK+4    SHOW SNAKE TSO TERMINAL GET COUNT.
         L     R1,TPUTCNTN
         S     R1,TPUTCNTO
         CVD   R1,WORK
         ED    TSOTPUTS,WORK+4    SHOW SNAKE TSO TERMINAL PUT COUNT.
         MVC   3(STATSLEN,R9),STATSMSG
         LA    R8,STATSLEN+3(,R8) UPDATE DATA STREAM LENGTH.
         LA    R9,STATSLEN+3(,R9) UPDATE BUFFER POINTER.
         SPACE
TREKPUT  LA    R1,TREKPOS         LINE NUMBER FOR TREKMSG.
         M     R0,COLUMNS         GET SCREEN LOCATION.
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN.
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR TREKMSG BUFFER ADDRESS.
         MVI   0(R9),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,X'3',1(R9)
         ICM   R1,X'F',CASHCNTR   GET TOTAL NUMBER OF MONEY BUNDLES.
         BZ    ZEROCASH           NO MONEY WAS GATHERED.
         L     R1,CASHMOVS        GET NUMBER OF MOVES FOR ALL CASH.
         M     R0,=F'100'         TWO DECIMAL PLACES FOR AVERAGE.
         D     R0,CASHCNTR        GET THE AVERAGE MOVES FOR A BUNDLE.
         CVD   R1,WORK
         ED    TREKMSG,WORK+4
         MVC   3(TREKMLEN,R9),TREKMSG
         LA    R8,TREKMLEN+3(,R8) UPDATE DATA STREAM LENGTH
         LA    R9,TREKMLEN+3(,R9) UPDATE BUFFER POINTER
         SPACE
ZEROCASH TM    GRAFLAGS,COLR      EXTENDED COLOUR SUPPORTED?
         BNO   YELABACK           NO, SKIP YELLOW.
         MVC   0(3,R9),YELLOW     YES, COLOUR THESE SNAZZIES.
         LA    R8,3(,R8)          ADJUST BUFFER POINTER.
         LA    R9,3(,R9)          ADJUST LENGTH COUNTER.
         SPACE
YELABACK TM    SNAKFLAG,EATEN     WAS THE PLAYER EATEN?
         BZ    YELAFRNT           NO.
         LA    R1,THISPOS         LINE NUMBER FOR THISMSG/EATENMSG.
         M     R0,COLUMNS         GET SCREEN LOCATION.
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN.
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR THISMSG BUFFER ADDRESS.
         MVI   0(R9),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,X'3',1(R9)
         LH    R1,SCORE
         STCM  R0,X'C',SCORE      ZERO THE SCORE.
         CVD   R1,WORK
         LA    R1,DEADCASH+5
         EDMK  DEADCASH,WORK+5
         BCTR  R1,0
         MVI   0(R1),C'$'
         MVC   3(EATENLEN,R9),EATENMSG
         LA    R8,EATENLEN+3(,R8) UPDATE DATA STREAM LENGTH.
         LA    R9,EATENLEN+3(,R9) UPDATE BUFFER POINTER.
         SPACE
YELAFRNT CLI   LOCFLAGS,8         SCOREBOARD JUST CREATED?
         BE    SHOWSHOW           YES, GIVE THE GOOD NEWS.
         CLI   BESTUSER,0         WAS THE SCOREBOARD FOUND?
         BE    ASTERPUT           NO, NO SCORING DETAILS TO REPORT.
         SPACE
         LA    R1,PREVPOS         LINE NUMBER FOR PREVMSG.
         M     R0,COLUMNS         GET SCREEN LOCATION.
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN.
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR PREVMSG BUFFER ADDRESS.
         MVI   0(R9),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,X'3',1(R9)
         LH    R1,SCOREO
         CVD   R1,WORK
         LA    R1,PREVSCOR+5
         EDMK  PREVSCOR,WORK+5
         BCTR  R1,0
         MVI   0(R1),C'$'
         ED    PREVDATE,DATEO+1
         ICM   R1,X'6',TIMEO
         IC    R1,CHARZERO
         SRL   R1,4
         ST    R1,WORK+4
         UNPK  PREVTIME+1(4),WORK+5(3)
         MVC   PREVTIME(2),PREVTIME+1
         MVI   PREVTIME+2,C':'
         MVC   3(PREVMLEN,R9),PREVMSG
         LA    R8,PREVMLEN+3(,R8) UPDATE DATA STREAM LENGTH.
         LA    R9,PREVMLEN+3(,R9) UPDATE BUFFER POINTER.
         SPACE
         TM    SNAKFLAG,EATEN     WAS THE PLAYER EATEN?
         BO    SHOWSHOW           YES, THIS SCORE DIDN'T COUNT.
         LA    R1,THISPOS         LINE NUMBER FOR THISMSG.
         M     R0,COLUMNS         GET SCREEN LOCATION.
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN.
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR THISMSG BUFFER ADDRESS.
         MVI   0(R9),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,X'3',1(R9)
         LH    R1,SCORE
         CVD   R1,WORK
         LA    R1,THISSCOR+5
         EDMK  THISSCOR,WORK+5
         BCTR  R1,0
         MVI   0(R1),C'$'
         ST    R5,WORK+4
         ED    THISDATE,WORK+5
         ICM   R4,X'2',CHARZERO
         SRL   R4,12
         ST    R4,WORK+4
         UNPK  THISTIME+1(4),WORK+5(3)
         MVC   THISTIME(2),THISTIME+1
         MVI   THISTIME+2,C':'
         CLC   SCORE,SCOREO       HOW WAS THE SCORE?
         BNH   BADLUCK            BAD LUCK - JUST WASN'T GOOD ENOUGH.
         MVC   BDLUKSUF,GDLUKSUF  GOOD LUCK -  CONGRATS.
BADLUCK  MVC   3(THISMLEN,R9),THISMSG
         LA    R8,THISMLEN+3(,R8) UPDATE DATA STREAM LENGTH.
         LA    R9,THISMLEN+3(,R9) UPDATE BUFFER POINTER.
         SPACE
SHOWSHOW LA    R1,LUCKPOS         LINE NUMBER FOR APPROPRIATE MESSAGE.
         M     R0,COLUMNS         GET SCREEN LOCATION.
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN.
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR MESSAGE BUFFER ADDRESS.
         MVI   0(R9),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,X'3',1(R9)
         CLI   LOCFLAGS,8         SCOREBOARD JUST CREATED?
         BE    GOODGOOD           YES, GIVE THE GOOD NEWS.
         CLC   SCORE,SCOREO       HOW WAS THE SCORE?
         BNH   BADSHOW            BAD LUCK - JUST WASN'T GOOD ENOUGH.
GOODGOOD TM    GRAFLAGS,COLR+HLIT IN GRAPHIC MODE?
         BZ    GOODSHOW           NO, SKIP HIGHLIGHTING CHANGE.
         MVC   3(3,R9),BLINKING   HIGHLIGHT PREVIOUS TOP SNAKE-DODGER
         MVC   6(3,R9),RED                  BEING DEPOSED.
         LA    R8,6(,R8)          UPDATE DATA STREAM LENGTH.
         LA    R9,6(,R9)          UPDATE BUFFER POINTER.
GOODSHOW MVC   3(GDLUKLEN,R9),GDLUKMSG
         LA    R8,GDLUKLEN+3(,R8) UPDATE DATA STREAM LENGTH.
         LA    R9,GDLUKLEN+3(,R9) UPDATE BUFFER POINTER.
         B     DONELUCK
BADSHOW  CLC   BESTUSER,SNAKEUSR  IS THIS THE TOP SNAKE-DODGER?
         BE    OKAYLUCK           YES, DON'T WORRY.
         MVC   3(BDLUKLEN,R9),BDLUKMSG
         LA    R8,BDLUKLEN+3(,R8) UPDATE DATA STREAM LENGTH.
         LA    R9,BDLUKLEN+3(,R9) UPDATE BUFFER POINTER.
         B     DONELUCK
OKAYLUCK MVC   3(URTOPLEN,R9),URTOPMSG
         LA    R8,URTOPLEN+3(,R8) UPDATE DATA STREAM LENGTH.
         LA    R9,URTOPLEN+3(,R9) UPDATE BUFFER POINTER.
         SPACE
DONELUCK TM    GRAFLAGS,HLIT      EXTENDED HIGHLIGHTING SUPPORTED?
         BZ    ASTERPUT           NO, SKIP HIGHLIGHTING CHANGE.
         MVC   0(3,R9),NOHILITE   RESET HIGHLIGHTING.
         LA    R8,3(,R8)          UPDATE DATA STREAM LENGTH.
         LA    R9,3(,R9)          UPDATE BUFFER POINTER.
         SPACE
ASTERPUT LA    R1,ASTERPOS        LINE NUMBER FOR ASTERISKS.
         M     R0,COLUMNS         GET SCREEN LOCATION.
         LA    R1,1(,R1)          START FROM THE SECOND COLUMN.
         STH   R1,TOLOC
         BAL   R14,CALCPOSI       GET CODE FOR CHEATMSG BUFFER ADDRESS.
         MVI   0(R9),X'11'        SET-BUFFER-ADDRESS.
         STCM  R0,X'3',1(R9)
         TM    GRAFLAGS,COLR+HLIT IN GRAPHIC MODE?
         BZ    STARSPUT           NO, SKIP RED INSERTION.
         MVC   3(3,R9),RED        YES, ASTERISKS IN RED.
         MVC   6(3,R9),NOHILITE   RESET ANY HIGHLIGHTING.
         LA    R8,6(,R8)          UPDATE DATA STREAM LENGTH.
         LA    R9,6(,R9)          UPDATE BUFFER POINTER.
STARSPUT MVC   3(ASTERLEN,R9),ASTERMSG
         LA    R8,ASTERLEN+3(,R8) UPDATE DATA STREAM LENGTH.
*        LA    R9,ASTERLEN+3(,R9) UPDATE BUFFER POINTER (NOT NEEDED).
         SPACE
FINALPUT LA    R1,UPDTSTRM        POINT TO TERMINATION MESSAGES.
         LR    R0,R8              GET DATA STREAM LENGTH.
         ICM   R1,X'8',=X'03'     LOAD FULLSCREEN,HOLD FLAGS.
         TPUT  (1),(0),R
         LA    R1,WORK
         LA    R0,8
         ICM   R1,X'8',=X'81'     LOAD TGET ASIS,WAIT FLAGS.
         TGET  (1),(0),R          END FOR ANY ALMOST ANY INPUT.
         CLI   WORK,X'4D'
         BL    CLEANUP            PF 22, 23 OR 24.
         CLI   WORK,X'6F'
         BL    FINALPUT           RESHOW IN CASE OF INTERCOM.
         TITLE ' TERMINATION - EXIT '
CLEANUP  DS    0H
         STLINENO LINE=1,MODE=OFF DEACTIVATE VTAM FULL SCREEN MODE.
         TCLEARQ INPUT            FLUSH ANY RESIDUAL INPUT.
         L     R13,SAVEAREA+4     POINT TO CALLER'S SAVE AREA.
         LM    R14,R12,12(R13)    RESTORE REGISTERS.
         SLR   R15,R15            RETURN CODE ZERO.
         BR    R14                RETURN TO CALLER.
         TITLE ' ENCODE SCREEN LOCATION TO 3270 BUFFER ADDRESS '
CALCPOSI LH    R0,TOLOC           GET CODE FOR 3270 BUFFER ADDRESS.
         CH    R0,=H'4095'        LOCATION GREATER THAN 4K (12 BITS)?
         BHR   R14                YES, NO CONVERSION TO BE DONE.
         STC   R0,WORK+1          NO, DO ORIGINAL 3270 ADDRESSING.
         NI    WORK+1,B'00111111' GET LOW-ORDER SIX-BIT NUMBER.
         SRL   R0,6
         STC   R0,WORK            GET HIGH-ORDER SIX-BIT NUMBER.
         TR    WORK(2),TABLE      CONVERT TO 3270 DATA STREAM CHARS.
         ICM   R0,X'3',WORK       SAVE IN BOTTOM TWO BYTES OF R0.
         BR    R14                RETURN TO MAINLINE.
         SPACE
CHAREPET MVC   1(0,R1),0(R1)      <<< EXECUTED >>>
         SPACE
TABLE    DC    X'40C1C2C3C4C5C6C7C8C94A4B4C4D4E4F'
         DC    X'50D1D2D3D4D5D6D7D8D95A5B5C5D5E5F'
         DC    X'6061E2E3E4E5E6E7E8E96A6B6C6D6E6F'
CHARZERO DC    X'F0F1F2F3F4F5F6F7F8F97A7B7C7D7E7F'
         TITLE ' LITERALS AND INITIALIZED VARIABLES '
CLEARALL DC    XL8'401140403C404000'      WCC,SBA,(1,1),RTA,(1,1),NULL.
REPTOTOP EQU   CLEARALL+4,3               RTA,(1,1).
STRMTRLR DC    XL4'11404013'              SBA,(1,1),IC.
TERMATTR DC    F'0'                       FILLED IN BY GTTERM.
RUNTABLE DC    A(STEPUP,STEPDOWN,STEPLEFT,STEPRITE)
MAXACCUM DC    AL2(L'UPDTSTRM-80)         DATA STREAM LENGTH THRESHOLD.
WASTE    DC    H'0'                       FILLED IN BY GTTERM.
BORDBLDL DC    H'1',H'44'                 ONE 44 BYTE ENTRY.
BORDNAME DC    CL8'SNKTAB00'              NAME OF SCOREBOARD MEMBER.
BORDTTR  DC    XL3'000000'                FILLED IN BY BLDL/STOW.
BORDK    DC    XL1'00'                    CONCATENATION CODE.
BORDZ    DC    XL1'00'                    LOCATION CODE.
BORDC    DC    XL1'00'
BORDV    DC    XL1'00'                    VERSION NUMBER.
BORDM    DC    XL1'00'                    REVISION NUMBER.
         DC    XL2'0000'                  NOT USED.
BORDCR   DC    XL4'0000000F'              CREATION DATE.
BORDCD   DC    XL4'0000000F'              LAST CHANGE DATE.
BORDCT   DC    XL2'0000'                  LAST CHANGE TIME.
BORDSI   DC    XL2'0000'                  NUMBER OF LINES CURRENTLY.
BORDIN   DC    XL2'0000'                  NUMBER OF LINES INITIALLY.
BORDMD   DC    XL2'0000'                  NUMBER OF LINES MODIFIED.
BORDID   DC    XL8'0000000000000000'      USERID (10 BYTES FOR SPF).
USERLEN  EQU   *-BORDC                    USER DATA LENGTH + 1.
PFDATTRS DC    CL8'PFDATTRS'              DDNAME FOR OSIV/F4
RUNINDEX DC    X'00'                      OFFSET INTO RUNTABLE.
RESETAID DC    X'27F1C3'                  ESCAPE,WRITE,WCC.
QUERY    DC    X'F3000501FF02'            WRITE STRUCTURED FIELD,QUERY.
SORRYMSG DC   C'SORRY, THIS PROGRAM USES 3270 FULL-SCREEN TERMINAL I/O'
WACKYMSG DC   C'WHAT SORT OF WACKY SCREEN HAVE YOU GOT, BOZO-FEATURES?'
ACRNMMSG DC    C'(SNAKE=SYSTEM-NODE-ACTIVITY-KNOWLEDGE-EXIT)'
         DC    C'(PF5/17=JOG/SPRINT)(PF4/16=TRAIL)'
ACRNMLEN EQU   *-ACRNMMSG
HLPMSG01 DC    C'  THE SNAKE'             HELP SCREEN TEXT.
HLPMSG02 DC    C'  THE PLAYER'
HLPMSG03 DC    C'  HOME'
HLPMSG04 DC    C'  TWENTY-FIVE DOLLARS'
HLPMSG05 DC    C' PF03/12/15/24 - THE BOSS IS COMING'
HLPMSG06 DC    C' PF07 - MOVE UP ONE LOCATION'
HLPMSG07 DC    C' PF08 - MOVE DOWN ONE LOCATION'
HLPMSG08 DC    C' PF10 - MOVE LEFT ONE LOCATION'
HLPMSG09 DC    C' PF11 - MOVE RIGHT ONE LOCATION'
HLPMSG10 DC    C' PF19 - RUN UP      PF20 - RUN DOWN'
HLPMSG11 DC    C' PF22 - RUN LEFT    PF23 - RUN RIGHT'
HLPMSG12 DC    C' RUNNING STOPS WHEN THE PLAYER REACHES'
HLPMSG13 DC    C' THE MONEY, REACHES THE ROW OR COLUMN'
HLPMSG14 DC    C' THAT THE MONEY IS IN, OR *AFTER* A MOVE'
HLPMSG15 DC    C' FAILS DUE TO AN OBSTRUCTION.  SCORES'
HLPMSG16 DC    C' ARE ONLY CREDITED AFTER THE PLAYER'
HLPMSG17 DC    C' REACHES HOME, WHEREUPON THE GAME ENDS.'
STATSPOS EQU   2                          TERMINATION MESSAGE DETAILS.
STATSMSG DC    C' TERMINAL I/O:'
TSOTGETS DC    X'4020202020202120'
         DC    C' GETS  AND'
TSOTPUTS DC    X'4020202020202120'
         DC    C' PUTS. '
STATSLEN EQU   *-STATSMSG
TREKPOS  EQU   4
TREKMSG  DC    X'4020202021204B2020'
         DC    C' WAS THE AVERAGE NUMBER OF MOVES FOR EACH MONEY BUNDLE+
               . '
TREKMLEN EQU   *-TREKMSG
SNKFACE1 DC    X'964B96'    O.O
SNKFACE2 DC    X'E06D61'    \_/
BLUE     DC    X'2842F1'
RED      DC    X'2842F2'
PINK     DC    X'2842F3'
GREEN    DC    X'2842F4'
TURQ     DC    X'2842F5'
YELLOW   DC    X'2842F6'
WHITE    DC    X'2842F7'
NOHILITE DC    X'284100'     RESET CHARACTER HIGHLIGHTING.
BLINKING DC    X'2841F1'     SET CHARACTER HIGHLIGHTING TO BLINKING.
REVERSE  DC    X'2841F2'     SET CHARACTER HIGHLIGHT TO REVERSE VIDEO.
UNDERSCR DC    X'2841F4'     SET CHARACTER HIGHLIGHT TO UNDERSCORES.
RESETSA  DC    X'280000'     RESET ALL CHARACTER ATTRIBUTES.
PREVPOS  EQU   8
PREVMSG  DC    C' THE TOP SNAKE-DODGER WAS '
BESTUSER DC    XL8'0000000000000000'
         DC    C'WITH A SCORE OF'
PREVSCOR DC    X'402020202120'
         DC    C' ON'
PREVDATE DC    X'4021204B202020'
         DC    C' AT '
PREVTIME DC    C'HH:MM'
         DC    C'. '
PREVMLEN EQU   *-PREVMSG
THISPOS  EQU   10
THISMSG  DC    C' YOUR SCORE OF'
THISSCOR DC    X'402020202120'
         DC    C' ON'
THISDATE DC    X'4021204B202020'
         DC    C' AT '
THISTIME DC    C'HH:MM'
BDLUKSUF DC    C' DID NOT SURPASS THIS. '
THISMLEN EQU   *-THISMSG
GDLUKSUF DC    C' SURPASSES EVEN THIS!! '
EATENMSG DC    C' YOU AND YOUR'
DEADCASH DC    X'402020202120'
         DC    C' HAVE BEEN EATEN.  WHO SAID YOU CAN''T TAKE IT WITH YO+
               U? '
EATENLEN EQU   *-EATENMSG
LUCKPOS  EQU   12
BDLUKMSG DC    C' WITH ALL THIS PRACTICE YOU''LL PROBABLY DO BETTER NEX+
               T TIME. '
BDLUKLEN EQU   *-BDLUKMSG
URTOPMSG DC    C' DON''T WORRY, YOU ARE STILL THE TOP SNAKE-DODGER. '
URTOPLEN EQU   *-URTOPMSG
GDLUKMSG DC   C' CONGRATULATIONS!!  YOU ARE THE NEW TOP SNAKE-DODGER! '
GDLUKLEN EQU   *-GDLUKMSG
ASTERPOS EQU   14
ASTERMSG DC    C'***'
         DC    X'1D40'       UNPROTECTED LOW-INTENSITY.
         DC    X'13'         INSERT-CURSOR.
ASTERLEN EQU   *-ASTERMSG
BUFHDR   DC    X'C11140403C4040401DF0'
HDRLEN   EQU   *-BUFHDR
THESNAKE DC    X'11000040'   BLANK OUT PREVIOUS TAIL.
         DC    X'110000A2'   END OF THE TAIL.
         DC    X'110000A2'   \
         DC    X'110000A2'     \
         DC    X'110000A2'       \ ___BODY OF THE SNAKE.
         DC    X'110000A2'       /
         DC    X'110000A2'     /
         DC    X'110000A2'   /
SNAKEHED DC    X'110000E2'   HEAD OF THE SNAKE.
SNAKELEN EQU   *-THESNAKE    LENGTH OF THE SNAKE DATA STREAM.
         SPACE
         PRINT NOGEN
SNAKFILE DCB   DSORG=PO,MACRF=(R,W),DDNAME=ISPTABL
         PRINT GEN
         SPACE
         LTORG
         SPACE
         DS    0D
         DC    C'   ANOTHER QUALITY PRODUCT FOR TSO BY GREG PRICE'
         DC    C' OF PRYCROFT SIX PTY LTD'
         DS    0D
         TITLE ' UNINITIALIZED VARIABLES AND DSECTS '
SNAKECMN COM
SAVEAREA DS    18F
WORK     DS    D
SNAKEUSR DS    D
RANDOMTU DS    F
TGETCNTO DS    F
TPUTCNTO DS    F
TGETCNTN DS    F
TPUTCNTN DS    F
LINES    DS    F
COLUMNS  DS    F
MOVLINES DS    F
MOVECOLS DS    F
ELIGIBLS DS    F
SNAKEX   DS    F
SNAKEY   DS    F
MONEYX   DS    F
MONEYY   DS    F
PLAYERX  DS    F
PLAYERY  DS    F
IMAGESIZ DS    F
LASTSPOT DS    F
SNAKEPTR DS    F
HOMEPNTR DS    F
PLAYRPTR DS    F
MONEYPTR DS    F
DATEO    DS    F
ZEROAREA EQU   *                  THIS AREA ZEROED AT INITIALIZATION.
CASHCNTR DS    F
CASHMOVS DS    F
THISTREK DS    F
RNDMCNTR DS    F
TRLRPNTR DS    F
SCOREPTR DS    F
TCTADDR  DS    F
HOMELOCN DS    H
MONEYLOC DS    H
PLAYRLOC DS    H
TPUTLEN  DS    H
SCORE    DS    H
ZEROLEN  EQU   *-ZEROAREA         END OF INITIALLY ZEROED AREA.
SCOREO   DS    H
TIMEO    DS    H
TOLOC    DS    H
SCRNSIZE DS    H
SNAKELOC DS    9H
SNKHDLOC EQU   *-2,2
BORDCHAR DS    C
SNAKFLAG DS    C
NEXT     EQU   X'80'
EATEN    EQU   X'40'
RUN      EQU   X'20'
BURST    EQU   X'10'
GRAFLAGS DS    X                  TERMINAL GRAPHIC CAPABILITY FLAGS.
COLR     EQU   X'80'              AT LEAST SEVEN COLOURS SUPPORTED.
HLIT     EQU   X'40'              BLINK, REVERSE, UNDERSCORE SUPPORTED.
GEOK     EQU   X'20'              GRAPHICS ESCAPE SUPPORTED.
SYMSET   EQU   X'10'              SYMBOL-SETS SUB-FIELD RETURNED.
PCAF     EQU   X'08'              PC ATTACHMENT FACILITY TERMINAL.
IMPLIC   EQU   X'04'              IMPLICIT PARTITION SUB-FIELD PRESENT.
LOCFLAGS DS    X                  STATUS FLAGS FOR A GIVEN LOCATION.
BRDR     EQU   X'80'              LOCATION IS A BORDER.
SNKE     EQU   X'40'              LOCATION OCCUPIED BY SNAKE SEGMENT.
SNKHD    EQU   X'20'              THE SNAKE SEGMENT IS THE HEAD.
HOME     EQU   X'10'              LOCATION IS HOME-SWEET-HOME.
CASH     EQU   X'08'              HERE IS WHERE THE CASH IS STASHED.
YUMMY    EQU   X'04'              PLAYER IS STANDING/RUNNING HERE.
OSBITS   DS    C
SNKMOVES DS    0D
SNAKEUP  DS    X,X,H
SNAKEUPR DS    X,X,H
SNAKERHT DS    X,X,H
SNAKEDNR DS    X,X,H
SNAKEDWN DS    X,X,H
SNAKEDNL DS    X,X,H
SNAKELFT DS    X,X,H
SNAKEUPL DS    X,X,H
EOSNKMVS EQU   *
UPDTSTRM DS    CL1024
BUFFER   DS    CL1024
         SPACE 2
         PRINT NOGEN
         DCBD  DSORG=PO,DEVD=DA
         PRINT GEN
         SPACE 2
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
         SPACE 2
         END
/*
//LKED    EXEC PGM=IEWL,PARM='MAP,LIST'
//SYSLIN   DD  DSN=&&LOADSET,DISP=(OLD,DELETE)
//         DD  *
  ALIAS HALFSNAK,HS,QUARTERS,QS
  NAME SNAKE(R)
/*
//SYSLMOD  DD  DSN=SYS2.CMDLIB,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  UNIT=VIO,SPACE=(CYL,(5,2))
//
