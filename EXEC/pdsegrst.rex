/* --------------------  rexx procedure  -------------------- *
 | Name:      PDSEGRST                                        |
 |                                                            |
 | Function:  PDSEGEN Selective Restore                       |
 |                                                            |
 | Syntax:    %pdsegrst backup-dsn target-dsn mbr gen / NEW   |
 |                                                            |
 |            backup-dsn   PDSEGEN Backup PDS                 |
 |            target-dsn   PDS/PDSE to restore to             |
 |                         ** must exist **                   |
 |            mbr          Member name or member pattern      |
 |            gen          Absolute or Relative Gen to        |
 |                         restore                            |
 |                                                            |
 |            / NEW        allocate the target PDSE           |
 |                                                            |
 |            mbr is optional - default is all                |
 |            gen is optional - default is all generations    |
 |            / NEW is optional and may be any non-blank char |
 |                                                            |
 | Usage Notes:                                               |
 |           1. If restoring to a PDS or PDSE without         |
 |              generations then only the base (gen 0)        |
 |              will be restored.                             |
 |           2. If gen is not specified then all generations  |
 |              will be restored starting with the oldest to  |
 |              the newest. This retains the relative         |
 |              generations number.                           |
 |           3. The absolute generation number cannot be      |
 |              retained on restoration.                      |
 |           4. If the member already exists in the target    |
 |              then the existing member/generations will     |
 |              be pushed up the relative generation range    |
 |              until they roll out.                          |
 |           5. If the option / NEW is specified then the     |
 |              target PDSE will be allocated using the DCB   |
 |              and space of the backup PDS/PDSE and using    |
 |              the MAXGEN found in the Backup $ALLOC member  |
 |                                                            |
 | Dependencies:                                              |
 |           1. The PDSEGEN Backup PDS Must have the $INDEX   |
 |              member.                                       |
 |           2. The target PDS must be pre-allocated          |
 |           3. The PDSEGMAT REXX function module must be     |
 |              accessible for pattern matching on the        |
 |              member name if a pattern is used              |
 |           4. Must be run under ISPF or ISPF in Batch       |
 |              as ISPF Services are used                     |
 |                                                            |
 | Author:    Lionel B. Dyck                                  |
 |                                                            |
 | History:  (most recent on top)                             |
 |            02/22/21 - Correct Typo in Report               |
 |            03/04/19 - Add numerics for maxgen check        |
 |            11/24/17 - Update to support changed PDSEGENS   |
 |            09/27/17 - Add Progress Meter                   |
 |            09/25/17 - Correct testing for gen selection    |
 |            09/22/17 - Creation                             |
 |                                                            |
 * ---------------------------------------------------------- */

 arg parms
 parse value parms with fromdsn targetds mbr gen '/' target_new

 parse value '' with null msgnum ispf
 env      = sysvar('sysenv')
 pdsedd   = 'PRST'random(9999)
 mc       = 0
 rcount   = 0
 msgnum   = 0
 zerrhm   = 'PDSEGH0'
 zerralrm = 'NO'
 target_new = strip(target_new)

/* --------------- *
 * Start our timer *
 * --------------- */
 x = time('r')

 if env   = 'FORE' then  do
    ispf = 1
    end

 call do_say 'PDSEGRST Processing on:' date() 'at' time()
 call do_say ' '
 call do_say 'Calling parameters:'
 call do_say '%'sysvar('sysicmd') parms
 call do_say ' '
 call do_say 'Input Backup PDSE: ' fromdsn
 call do_say 'Output Target PDSE:' targetds
 call do_say 'Member (mask):     ' mbr
 call do_say 'Generation:        ' gen
 call do_say 'New Flag:          ' target_new
 call do_say ' '

/* --------------------------------------------------- *
 | Validate that the fromdsn and targetds exist        |
 | and that the $INDEX member exists in the fromdsn |
 * --------------------------------------------------- */

 if sysdsn(fromdsn) /= 'OK' then do
    call do_say 'Backup Dataset Name error:'
    call do_say "Dataset:" fromdsn
    call do_say "Error message:" sysdsn(fromdsn)
    call do_say 'Try again...'
    call exit
    end

 if target_new = null then do
    if sysdsn(targetds) /= 'OK' then do
       call do_say 'Target Dataset Name error:'
       call do_say "Dataset:" targetds
       call do_say "Error message:" sysdsn(targetds)
       call do_say 'Try again...'
       call exit
       end
       end
 else do
    if sysdsn(targetds) = 'OK' then do
       call do_say 'Target Dataset Name Exists and NEW was specified.'
       call do_say 'Either remove the' target_new '(New) option or change'
       call do_say 'the target dataset name.'
       call do_say 'Try again...'
       call exit
       end
       end

 if left(fromdsn,1) = "'"
    then bdsn = "'"substr(fromdsn,2,length(fromdsn)-2)"($INDEX)'"
    else bdsn = fromdsn"($INDEX)"
 if sysdsn(bdsn) /= 'OK' then do
    call do_say 'Backup Dataset $INDEX Member Missing'
    call do_say "Dataset:" bdsn
    call do_say "Error message:" sysdsn(bdsn)
    call do_say 'Try again...'
    call exit
    end

/* -------------------------- *
 * Get defaults from PDSEGENS *
 * -------------------------- */
 x = pdsegens()
 parse value x with  x '/' x '/' x ,
              '/' x '/' x '/' x ,
              '/' x '/' x '/' def_unit '/' x
 def_unit     = strip(def_unit)
 if def_unit /= null then
    def_unit = 'unit('def_unit')'

/* ------------------------------------------------ *
 | If NEW then read in the $ALLOC and get DCB/Space |
 * ------------------------------------------------ */
 if target_new /= null then do
 if left(fromdsn,1) = "'"
    then adsn = "'"substr(fromdsn,2,length(fromdsn)-2)"($ALLOC)'"
    else adsn = fromdsn"($ALLOC)"
 'Alloc f('pdsedd') shr reuse ds('adsn')'
 'Execio * diskr' pdsedd '(finis stem $alloc.'
 'Free  f('pdsedd')'
  parse value $alloc.1 with .'('amgen')' .
  Numeric Digits 10
  CVT      = C2D(Storage(10,4))
  CVTDFA   = C2D(Storage(D2X(CVT + 1216),4))   /* cvt + 4c0 */
  DFAMGEN  = C2D(Storage(D2X(cvtdfa + 76),4))  /* dfa + 4c */
  if amgen > dfamgen then do
     $alloc.1 = 'MAXGEN('dfamgen')'
     call do_say 'The requested MAXGEN('amgen') is greater than' ,
                 'the current system'
     call do_say 'MAXGENS_LIMIT of' dfamgen'.' ,
                 'The restore will use the system MAXGENS_LIMIT.'
     call do_say 'Warning: It is possible that generations beyond the' ,
                 dfamgen' limit will be'
     call do_say 'lost during the restore process.'
     call do_say ' '
     end
  'Alloc f('pdsedd') ds('targetds') like('fromdsn')' $alloc.1 ,
    'dsntype(library,2)' def_unit
  call do_say 'Allocating target PDSE with' $alloc.1
  'Free  f('pdsedd')'
  end

/* ------------------------------- *
 | Read in the Backup Member Index |
 * ------------------------------- */
 'Alloc f('pdsedd') shr reuse ds('bdsn')'
 'Execio * diskr' pdsedd '(finis stem index.'
 'Free  f('pdsedd')'

 Address ISPExec
 'Control Errors Return'

/* ------------------------------------ *
 * Setup for Progress Indicator Display *
 * ------------------------------------ */
 division = 10
 incr = (index.0 % division) + 1
 progc = null
 perc# = 0

/* --------------------------------------------- *
 | If ISPF active (foreground) do progress popup |
 * --------------------------------------------- */
 if ispf = 1 then do
    prog = 'Preparing...'
    "Control Display Lock"
    'addpop'
    'display panel(pdsegpr)'
    'rempop'
    end

/* --------------------------------------- *
 | Define the From and To Datasets to ISPF |
 * --------------------------------------- */
 "lminit dataid(fromid) dataset("fromdsn")"
 "lminit dataid(toid)   dataset("targetds")"

/* ----------------------------------------- *
 | Process the $INDEX for members to restore |
 * ----------------------------------------- */
 dcount = 0
 do in = 1 to index.0
    parse value index.in with backup_member real_member abs_gen rel_gen .
    dcount = dcount + 1
    call disp_progress
    if mbr = null then call Restore
    testmrc = test_mask(real_member mbr)
    if testmrc = 0 then iterate
    hit = 1
    if gen /= null then do
       if gen < 0
          then if gen /= rel_gen then hit = 0
       if gen > 0
          then if gen /= abs_gen then hit = 0
       if gen = 0
          then if gen /= abs_gen then hit = 0
       end
    if hit = 1 then call Restore
    end

/* ---------------- *
 | All done so exit |
 * ---------------- */
 Exit:
 if msgnum > 0 then do
    call proc_etime
    call do_say ' '
    call do_say 'Total members/generations restored:' rcount
    call do_say 'Elapsed Time:                      ' etime
    call do_say 'PDSEGRST Processing Completed on:  ' date() 'at' time()
    end
 call Display_Msgs
 "lmfree dataid("fromid")"
 "lmfree dataid("toid")"
 Exit 0

/* ---------------- *
 * Display progress *
 * ---------------- */
 Disp_Progress:
 if dcount//incr = 0 then do
    progc = progc'**'
    perc# = perc# + division
    perc = perc#"%"
    prog = progc '('perc')'
    "Control Display Lock"
    'addpop'
    'display panel(pdsegpr)'
    'rempop'
    end
 return

/* --------------- *
 | Restore Routine |
 * --------------- */
Restore:
  call do_say 'Restoring member' left(backup_member,8) ,
              'to member' left(real_member,8) ,
              'with relative generation' rel_gen
  "lmcopy fromid("fromid") todataid("toid")" ,
         "frommem("backup_member") tomem("real_member") replace"
  if rc > 0 then do
    call do_say 'LMCopy failure rc:' rc
    call do_say zerrsm
    call do_say zerrlm
    call exit
  end
  rcount = rcount + 1
  return

/* ----------------------- *
 | Format the Elapsed Time |
 * ----------------------- */
 Proc_eTime:
    e_time = time("E")
    parse value e_time with ss "." uu
    numeric digits 6
    mm = ss % 60 /* get minutes integer */
    ss = ss // 60 /* get seconds integer */
    uu = uu // 100 /* get micro seconds integer */
    etime =  right(mm+100,2)':'right(ss+100,2)'.'right(uu+100,2) '(mm:ss:th)'
    return

/* -------------------------------------------- *
 | Do_Say routine - put the message into a stem |
 * -------------------------------------------- */
 do_say:
 parse arg message
 msgnum = msgnum + 1
 msgs.msgnum = message
 return

/* --------------------------------------------------------- *
 | Test_Mask routine used when the command contains a member |
 | or member with mask.                                      |
 |                                                           |
 | Arguments passed: member-name mask                        |
 | Return code:  0 - no match                                |
 |               1 - match                                   |
 * --------------------------------------------------------- */
Test_Mask: procedure
  arg string mask
/* ----------------------- *
 | Define the type of mask |
 |                         |
 | 0 = no mask             |
 | 1 = mask % or *         |
 | 2 = pattern with :      |
 | 3 = pattern with /      |
 * ----------------------- */
  hit = 0
  if pos('*',mask) > 0 then hit = 1
  if pos('%',mask) > 0 then hit = 1
  if pos(':',mask) > 0 then hit = 2
  if pos('/',mask) > 0 then hit = 3

  Select
    When hit = 1 then do
      rtn = pdsegmat(string,mask)
      return rtn
    end
    When hit = 2 then do
      p1 = pos(':',mask)
      tname = left(mask,p1-1)
      if tname = left(string,p1-1) then return 1
      else return 0
    end
    When hit = 3 then do
      tname = strip(translate(mask,' ','/'))
      if pos(tname,string) > 0 then return 1
      else return 0
    end
    When hit = 0 then do
      if mask = string then return 1
      else return 0
    end
    Otherwise return 0
  End
  return

/* ----------------------------------- *
 | Display messages or Browse messages |
 * ----------------------------------- */
 Display_Msgs:
 if ispf /= 1 then
    if msgnum > 0 then
       do i = 1 to msgnum
          say msgs.i
          end
 if ispf = 1 then
 if msgnum > 0 then do
    if sysvar('syspref') = null
       then temp = sysvar('sysuid')'.pdsegbak.report'
       else temp = sysvar('syspref')'.pdsegbak.report'
    Address TSO
    if sysdsn("'"temp"'") = 'OK' then do
       call outtrap 'x.'
       Address TSO "Delete '"temp"'"
       call outtrap 'off'
       end
    "Alloc f("ddn") ds('"temp"') new spa(1,1) tr" ,
      "recfm(f b) lrecl(80) blksize(6160)"
    msgs.0 = msgnum
    "Execio * diskw" ddn "(finis stem msgs."
    Address TSO "Free f("ddn")"
    Address ISPExec
    "Browse dataset('"temp"')"
    call outtrap 'x.'
    Address TSO "Delete '"temp"'"
    call outtrap 'off'
    end
 Return
