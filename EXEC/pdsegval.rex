/* --------------------  rexx procedure  -------------------- *
 * Name:      pdsegval                                        *
 *                                                            *
 * Function:  Validate the PDSE using IEBPDSE                 *
 *                                                            *
 * Syntax:    %pdsegval pdsedsn clean                         *
 *                                                            *
 *            pdsedsn is the pdse dataset name                *
 *            clean forces pending delete cleanup             *
 *                                                            *
 * Author:    John Kalinich                                   *
 *            Lionel B. Dyck                                  *
 *                                                            *
 * History:                                                   *
 *            11/06/17 - Enhance the IEBPDSE Report           *
 *                     - Use Browse instead of View for report*
 *            09/12/16 - Removed parm of flush unless Clean   *
 *                       is specified. See OA50214.           *
 *            09/08/16 - Changed call to IEBPDSE and added    *
 *                       Parm of FLUSH                        *
 *                     - Change allocation for report dd      *
 *            08/23/16 - Add sysin dd allocation to make      *
 *                       sure it is dummy                     *
 *            08/16/16 - Update by Lionel to add optional     *
 *                       parm of PERFORMPENDINGDELETE         *
 *                       which forces a cleanup               *
 *            08/01/16 - Minor changes by Lionel Dyck         *
 *            08/01/16 - Creation                             *
 *                                                            *
 * ---------------------------------------------------------- */
 arg pdsedsn clean

/* --------------- *
 * Define defaults *
 * --------------- */
 zerrhm   = 'PDSEGH0'
 zerralrm = 'NO'
 null     = ''

/* ---------------------------- *
 * Test for a PDSE dataset name *
 * ---------------------------- */
 Address ISPExec
 if sysdsn(pdsedsn) /= 'OK' then do
    zerrsm = null
    zerrlm = 'Error.' pdsedsn sysdsn(pdsedsn)
   'setmsg msg(isrz002)'
   return
   end

/* ----------------------------------- *
 * Fixup PDSE dataset name if required *
 * ----------------------------------- */
 if left(pdsedsn,1) = "'" then do
    wdsn = substr(pdsedsn,2,length(pdsedsn)-2)
    end
 else do
      if sysvar('syspref') = null then hlq = sysvar('sysuid')
                                else hlq = sysvar('syspref')
      wdsn = hlq'.'pdsedsn
      end

/* -------------------------------------------- *
 * Check for the clean option and if found then *
 * set the parm to PERFORMPENDINGDELETE         *
 * -------------------------------------------- */
 if clean /= null
    then parm = 'FLUSH,PERFORMPENDINGDELETE'
    else parm = ''

/* -------------------- *
 * Call IEBPDSE routine *
 * -------------------- */
 call iebpdse
 exit

/* --------------- *
 * IEBPDSE routine *
 * --------------- */
IEBpdse:
/* ------------------------------------- *
 * Build temp dataset for IEBPDSE Report *
 * ------------------------------------- */
 'vget (zscreen) shared'
 result = 'RESULT'zscreen

/* ------------ *
 * Call IEBPDSE *
 * ------------ */
 Address TSO
 x = outtrap('delete.','*')
 'delete iebpdse.'result
 x= outtrap('off')
 "alloc f(syslib) da('"wdsn"') shr reuse"
 'alloc f(sysprint) new reuse unit(sysallda)',
   'space(1,1) tracks'
 'alloc f(sysin) dummy reuse'
 "call *(iebpdse) '"parm"'"

 'Execio * diskr sysprint (finis stem sysp.'
 rpt.1 = center('IEBPDSE Report',50)
 rpt.2 = center('Date:' date() 'Time:' time(),50)
 rpt.3 = center("PDSE:" wdsn,50)
 if parm = null then parm = 'None'
 rpt.4 = center("Parms:" parm,50)
 rpt.5 = center("System:" mvsvar('sysname'),50)
 rpt.6 = ' '
 c = 6
 do i = 1 to sysp.0
    c = c + 1
    rpt.c = sysp.i
    end
 rpt.0 = c
 'Execio * diskw sysprint (finis stem rpt.'

/* ------------------------------- *
 * Display the report using Browse *
 * ------------------------------- */
 Address ISPExec
 'lminit dataid(id) ddname(sysprint) enq(exclu)'
 if rc ^= 0 then do
    zerrsm = 'Error'
    zerrlm = 'Error.  LMINIT failed for SYSPRINT'
   'setmsg msg(isrz002)'
   exit
   end
 'Browse   dataid('id')'
 'lmfree dataid('id')'

 Address TSO
'free  f(syslib sysprint)'
'alloc f(sysin) ds(*) reuse'
 return
