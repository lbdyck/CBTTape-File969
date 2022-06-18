/* --------------------  rexx procedure  -------------------- */
 pdsegver = pdsegver()
/* Name:      pdsegbak                                        *
 *                                                            *
 * Function:  backup and restore a pdse with member           *
 *            generations.                                    *
 *                                                            *
 *            the backup file is a pds with an index member   *
 *            and then members using created names            *
 *                                                            *
 *            this backup pds can then be copied using        *
 *            iebcopy, tso transmit, or other normal tool     *
 *                                                            *
 *            the backup process will allocate a backup       *
 *            dataset as a pdse v2 without maxgen.            *
 *                                                            *
 *            the output/backup dataset will have information *
 *            needed to recreate the backup source.           *
 *                                                            *
 *            Can be run in batch                             *
 *                                                            *
 * Syntax:    %pdsegbak input output options                  *
 *                                                            *
 *            input  is either the pdse with member/gens      *
 *                   or the backup pds                        *
 *            output is the target dataset for backup or      *
 *                   restore.  this dataset will be           *
 *                   allocated based on the input dataset     *
 *            options are: backup, restore and/or batch       *
 *                                                            *
 *            if no parameters or only the fromdsn is         *
 *            provided then a prompting panel will be         *
 *            displayed.                                      *
 *                                                            *
 *            batch may be used with both backup and restore  *
 *                                                            *
 *            if the batch option is used the report will     *
 *            be written to the terminal instead of browsed   *
 *                                                            *
 * Dependencies:   PDSEGENI rexx function                     *
 *                 ISPF                                       *
 *                                                            *
 * Special members in the target PDSE                         *
 *            $ALLOC    contains the maxgen information used  *
 *                      to allocate the restore PDSE          *
 *            $BACKUP   contains the backup report            *
 *            $INDEX    a map of original name/generation to  *
 *                      backup name (@nnnnnnn)                *
 *                                                            *
 * Author:    Lionel B. Dyck                                  *
 *                                                            *
 * History:                                                   *
 *            12/05/21 - Move Numeric Digits to top of code   *
 *            09/10/19 - Update pdsegeni parse for mmod       *
 *            06/25/19 - Set return code                      *
 *            03/04/19 - Add Numeric Digits for Maxgen check  *
 *            11/24/17 - Update to support changed PDSEGENS   *
 *            08/14/17 - Change to use pdsegver for pdsegen   *
 *                       version                              *
 *            06/20/17 - Version change                       *
 *            06/08/17 - Version change                       *
 *            05/30/17 - Version change                       *
 *            05/19/17 - Change to use edit macro parm        *
 *            04/04/17 - Make panel a popup                   *
 *                     - Recurse into ISPF APPL(PDSE)         *
 *            01/19/17 - Version change                       *
 *            01/05/17 - Version change                       *
 *            10/07/16 - Allow null default unit              *
 *                     - correction for ttr test              *
 *                     - correct backup messages              *
 *                     - change from edit to view             *
 *                     - removed stats from backup summary    *
 *                       members ($*) as that fails in batch  *
 *                     - changed to use relative gen instead  *
 *                       of absolute gen for replace          *
 *            09/12/16 - Use PDSEGENS for default unit        *
 *                     - additional test for null member name *
 *            09/07/16 - Fix batch test                       *
 *            09/01/16 - If TTR is x'000000' then ignore as   *
 *                       it's a dummy member                  *
 *            08/24/16 - Add preparing message                *
 *                     - update code for performance          *
 *            08/23/16 - Correct progress display             *
 *            08/16/16 - Add batch option                     *
 *            08/12/16 - Correct backup to ignore dummys      *
 *                       and process members with no stats    *
 *            07/27/16 - Add check for maxgen limit on restore*
 *            07/27/16 - Add timestamp for start of processing*
 *            07/25/16 - Change from msg isrz001 to isrz002   *
 *            07/21/16 - Get pdsebopt from ispf variable      *
 *                     - add elapsed time to report           *
 *            07/20/16 - Add progress meter                   *
 *                     - correction for batch processing      *
 *                       to NOT call ISPF Browse              *
 *                     - make sure report dataset is not there*
 *            07/19/16 - Minor updates                        *
 *                     - add more doc and $backup member      *
 *            07/18/16 - Enhance the reporting with rel gen   *
 *            07/16/16 - Change to display panel if passed    *
 *                       only the fromdsn                     *
 *                     - change to use replace instead of     *
 *                       cut/paste for backup process         *
 *            07/15/16 - Creation                             *
 *                                                            *
 * ---------------------------------------------------------- */
 arg options

/* ---------------------------------------------------- *
 | Check for Applid of PDSE and recurse into it if not. |
 * ---------------------------------------------------- */
 Address ISPExec
 'Control Errors Return'
 "Vget (Zapplid)"
 if zapplid <> "PDSE" then do
     "Select CMD(%"sysvar('sysicmd') options ") Newappl(PDSE)" ,
         "Passlib"
    exit rc
    end

 parse value options with fromdsn targetds options

 if wordpos('BACKUP',options)  > 0 then pdsebopt = 'BACKUP'
 if wordpos('RESTORE',options) > 0 then pdsebopt = 'RESTORE'
 if wordpos('BATCH',options)   > 0 then batch    = 'BATCH'
                                   else batch    = null

/* ------------------------------------------ *
 * Default the addressing environment to ISPF *
 * and setup our other defaults               *
 * ------------------------------------------ */
 Address ISPExec
 'Control Errors Return'
 null   = ''
 ddn    = 'PDSE'random(999)
 mc     = 0
 zerrhm   = 'PDSEGH0'
 zerralrm = 'NO'
 Numeric Digits 10

/* ------------------------------------------------- *
 * Now get current environment - must be ISPF Active *
 * ------------------------------------------------- */
 ispf = sysvar('sysispf')

 if ispf /= 'ACTIVE' then do
    say 'Error: This tool must be run under ISPF' ,
        'either online or it ISPF/TSO batch.'
    exit 8
    end
 else ispf = 1

/* ------------------------------------------- *
 * Now turn off ISPF flag for batch processing *
 * ------------------------------------------- */
 if sysvar('sysenv') /= 'FORE' then ispf = 0
 if ispf = 0 then batch = null

 if batch = 'BATCH' then ispf = 0

/* -------------------------- *
 * Get defaults from PDSEGENS *
 * -------------------------- */
 x = pdsegens()
 parse value x with  mail '/' etime '/' higen ,
              '/' base_color '/' sort_color '/' clean ,
              '/' prune_prompt '/' tempmem '/' def_unit ,
              '/' x
 base_color   = strip(base_color)
 sort_color   = strip(sort_color)
 clean        = strip(clean)
 prune_prompt = strip(prune_prompt)
 tempmem      = strip(tempmem)
 def_unit     = strip(def_unit)
 if def_unit /= null then
    def_unit = 'unit('def_unit')'

/* ----------------------------------------------- *
 * If no parms then check for foreground and if so *
 * display the prompting panel.                    *
 * ----------------------------------------------- */
 if length(targetds) = 0 then do
    if pdsebopt = null then
       'vget (pdsebopt)'
    if sysvar('sysenv') = 'FORE'
       then do forever
            "addpop"
            "Display panel(PDSEGBAK)"
            xrc = rc
            "rempop"
            if xrc > 4 then exit 4
            call start
            end
    end

Start:
/* --------------------------------- *
 * Now validate the provided options *
 * --------------------------------- */
 if length(fromdsn) = 0 then do
    zerrsm  = 'Error'
    zerrlm  = 'Invalid syntax.' ,
              '%pdsegbak input output option'
    call do_msg
    exit 8
    end

 if length(targetds) = 0 then do
    zerrsm  = 'Error'
    zerrlm  = 'Invalid syntax.' ,
              '%pdsegbak input output option'
    call do_msg
    exit 8
    end

 if length(pdsebopt) = 0 then do
    zerrsm  = 'Error'
    zerrlm  = 'Invalid syntax.' ,
              '%pdsegbak input output option'
    call do_msg
    exit 8
    end

 if sysdsn(fromdsn) /= 'OK' then do
    zerrsm  = 'Error'
    zerrlm  = fromdsn sysdsn(fromdsn)
    call do_msg
    return
    end

 if sysdsn(targetds) = 'OK' then do
    zerrsm  = 'Error'
    zerrlm  = targetds 'exists and it must not exist.'
    call do_msg
    return
    end

 Select
   When abbrev('BACKUP',pdsebopt,1) = 1 then pdsebopt = 'BACKUP'
   When abbrev('RESTORE',pdsebopt,1) = 1 then pdsebopt = 'RESTORE'
   Otherwise do
    zerrsm  = 'Error'
    zerrlm  = 'Invalid option - must be BACKUP or RESTORE'
    call do_msg
    exit 8
    end
  end

/* ------------------------------------------------- *
 * Completed the parameter validation - now to begin *
 * the processing we were called to do.              *
 * ------------------------------------------------- */

/* --------------------------------------------- *
 * First validate the dataset for backup/restore *
 * --------------------------------------------- */
 "dsinfo dataset("fromdsn")"
 zdsngen = zdsngen + 0
 if pdsebopt = 'BACKUP' then
    if zdsngen = 0 then do
        zerrsm  = 'Error'
        zerrlm  = 'Backup will only process PDSE Version 2' ,
                  'datasets with generations. Use a real' ,
                  'product for this dataset (it will be faster).'
        call do_msg
        return
        end
 if pdsebopt = 'RESTORE' then
    if zdsngen >  0 then do
        zerrsm  = 'Error'
        zerrlm  = 'Restore was requested from a dataset' ,
                  'which is NOT a backup dataset.'
        call do_msg
        return
        end

/* --------------------------------------------------- *
 * Now create variables with the fully qualified input *
 * and output dsnames without quotes.                  *
 * --------------------------------------------------- */
 if left(fromdsn,1) = "'" then do
    wfromdsn = substr(fromdsn,2,length(fromdsn)-2)
    end
 else do
      if sysvar('syspref') = null
         then wfromdsn = fromdsn
         else wfromdsn = sysvar('sysuid')'.'fromdsn
      end
 if left(targetds,1) = "'" then do
    wtargetds = substr(targetds,2,length(targetds)-2)
    end
 else do
      if sysvar('syspref') = null
         then wtargetds = targetds
         else wtargetds = sysvar('sysuid')'.'targetds
      end

/* --------------- *
 * Start our timer *
 * --------------- */
 x = time('r')

/* ------------------------------------------------------------ *
 * Backup processing:                                           *
 * 1. allocate the backup (output) dataset using the ALLOC LIKE *
 *    with MAXGEN(0)                                            *
 * 2. create member $ALLOC with MAXGEN information of the       *
 *    backup (input) dataset                                    *
 * 3. get all members/generations using the pdsegeni rexx       *
 *    function (member. stem)                                   *
 * 4. copy base members using lmcopy and generations using      *
 *    ispf edit using the pdsegenm macro (copy/paste)           *
 *    - members in output pds will be created member names      *
 *      e.g. $1 to $9999999                                     *
 * 5. lmmstats will be used to update $nnnnnnn with the source  *
 *    members ispf stats so they are retained.                  *
 * 6. $index member will contain a record for each $nnnnnnn     *
 *    member with original name, generation                     *
 * 7. after all members/generations copied write out $INDEX     *
 * 8. after all members/generations copied write out $BACKUP    *
 * 9. insert ISPF stats for $alloc, $backup, and $index         *
 * ------------------------------------------------------------ */

 if pdsebopt = 'BACKUP' then do

 if ispf = 1 then do
    prog = 'Preparing...'
    "Control Display Lock"
    'addpop'
    'display panel(pdsegpr)'
    'rempop'
    end

 call do_say 'Processing backup from' fromdsn
 call do_say '                    to' targetds
 call do_say ' '
 call do_say 'Time:' time()' Date:' date()
 call do_say ' '

/* ------------------------------------------------------- *
 * Allocate the output dataset and prime the $ALLOC member *
 * ------------------------------------------------------- */
  Address TSO
  'Alloc f('ddn') ds('targetds') like('fromdsn') maxgen(0)' ,
        def_unit
  $alloc.0 = 1
  $alloc.1 = 'MAXGEN('zdsngen')'
  "Alloc f("ddn"o) ds('"wtargetds"($alloc)') shr reuse"
  "Execio * diskw "ddn"o (finis stem $alloc."
  "Free  f("ddn"o)"
  Address ISPExec

/* ----------------------------------------- *
 * Establish the ISPF setup for the datasets *
 * ----------------------------------------- */
 "lminit dataid(fromid) dataset("fromdsn")"
 "lminit dataid(toid)   dataset("targetds")"
 'dsinfo dataset('fromdsn')'

/* ------------------------------------- *
 * Get the list of members from PDSEIGEN *
 * ------------------------------------- */
 Address TSO
 'Alloc f('ddn'I) ds('fromdsn') shr reuse'
 rc = pdsegeni(ddn'I')
 'Free f('ddn'I)'
  Address ISPExec

/* ----------------------------------- *
 * setup for the copy/backup operation *
 *                                     *
 * bc      counter for target member   *
 * ic      counter for $index          *
 * members work variable               *
 * tot_members counter for total mbrs  *
 * omem    old member                  *
 * ----------------------------------- */
 bc = 0
 ic = 0
 tot_members = 0
 members = null
 omem  = null

/* -------------------------------------------- *
 * Process the members from pdsegeni (member.i) *
 * -------------------------------------------- */
 do ifm = 1 to member.0
    parse value member.ifm with 5 cmem 13 agen 21 . 22 vrm 27 . ,
          35 cdate 42 . 46 ttr ,
          49 mdate 56 mtime 63 muser 70 . mmod 73 . 75 mcur 79 minit 83 .
    cmem = strip(cmem)
    agen = strip(agen)

    /* check for null member name */
    if left(cmem,1) = '00'x then iterate

    if strip(cdate) = null then do
        parse value '' with cdate mdate mtime vrm ,
                            muser scdate smdate ,
                            mcur minit mmod state
        sgen = mgen
        mgen = agen
        end

   /* --------------------------------- *
    * Test for dummy members and ignore *
    * --------------------------------- */
    if c2x(ttr) == '000000' then iterate
    if omem /= cmem then do
       omem = cmem
       if agen > 0 then do
          omem = null
          iterate
          end
       end

   /* --------------------- *
    * Test for dummy Member *
    * --------------------- */
    if agen /= 0 then
    if cdate = null then do
       call test_mem
       if rc > 4 then iterate
       end

   /* ------------------------------- *
    | Save member info for processing |
    * ------------------------------- */
    if wordpos(cmem,members) = 0 then do
       members = members cmem
       mem.cmem.A = ''
       end
    mem.cmem.A = mem.cmem.A agen
    if mcur = '    '
    then mcur = 0
    else mcur = x2d(c2x(mcur))
    if minit = '    '
    then minit = 0
    else minit = x2d(c2x(minit))
    mtime = Substr(mtime,2,2)||':'||Substr(mtime,4,2)
    mmod = c2x(mmod)
    mmod = x2d(mmod)
    if mdate /= '' then do
       smdate = substr(mdate,1,7)
       mdate = substr(mdate,3,5)
       mdate = date('o',mdate,'j')
       end
    if cdate /= '' then do
       scdate = substr(cdate,1,7)
       cdate = substr(cdate,3,5)
       cdate = date('o',cdate,'j')
       end
  /* ------------------------------- *
   * Add the member info to our stem *
   * ------------------------------- */
   parse value vrm with iver'.'imod
   if strip(iver)  = null then iver  = 0
   if strip(imod)  = null then imod  = 0
   if strip(cdate) = null then cdate = 0
   if strip(mdate) = null then mdate = 0
   if strip(mtime) = null then mtime = '0:0'
   if strip(muser) = null then muser = '??'
   mem.cmem.agen = cmem agen'\'iver'\'imod'\'cdate,
                   '\'mdate'\' mtime'\'mcur'\'minit'\'mmod'\'muser
   tot_members = tot_members + 1

   /* ------------------------------------- *
    | Check to see if we should display the |
    | progress meter.                       |
    * ------------------------------------- */
   if tot_members//10 = 0 then
   if ispf = 1 then do
      prog = 'Analyzed' tot_members 'members/generations'
      "Control Display Lock"
      'addpop'
      'display panel(pdsegpr)'
      'rempop'
      end
   end

   if ispf = 1 then do
      prog = 'Preparing to backup:' tot_members 'members/generations'
      "Control Display Lock"
      'addpop'
      'display panel(pdsegpr)'
      'rempop'
      end
   else do
        call do_say 'Preparing to backup:' tot_members 'members/generations'
        call do_say ' '
        end

/* ------------------------------- *
 * Now process the members to copy *
 * ------------------------------- */
 dcount = 0
 if ispf = 1 then
    call set_prog
 do im = 1 to words(members)
   cmem = word(members,im)
   rgen = words(mem.cmem.a) - 1
   do ix = words(mem.cmem.A) to 1 by -1
      dcount = dcount + 1
      if ispf = 1 then call disp_progress
      igen = word(mem.cmem.A,ix)
      parse value mem.cmem.igen with x y'\'iver'\'imod'\'cdate,
                                    '\'mdate'\' mtime'\'mcur'\'minit,
                                    '\'mmod'\'muser
      if igen = 0 then do
          rgen = 0
          call update_target
          call do_say 'Backing up base member' left(cmem,8) ,
              'to' bmem
         "lmcopy fromid("fromid") todataid("toid")" ,
                "frommem("cmem") tomem("bmem") replace"
         end
      else do
           call update_target
           bgen = rgen *-1
           call do_say 'Backing up gen member ' left(cmem,8) 'rel gen:' ,
                       left(bgen,5) 'generation' igen 'to' bmem
           /* --------------------------------------- *
            * Replace all records from current to new *
            * Output dataset is pre-allocated and     *
            * then freed.                             *
            * --------------------------------------- */
            pdsemopt = 'R'
            pdsecpds = "'"wtargetds"("bmem")'"
            'vput (pdsecpds)'
            'view dataid('fromid') member('cmem') gen('bgen')' ,
                 'macro(pdsegenm) parm(pdsemopt)'
            rgen = rgen - 1
           /* ------------------------------------------------ *
            * Update the target member with the old ISPF stats *
            * ------------------------------------------------ */
            if iver > 0 then
            'LMMStats Dataid('toid')' ,
                     'Member('bmem') version('iver') modlevel('imod')' ,
                     'Created('cdate') Moddate('mdate')' ,
                     'Modtime('mtime') Cursize('mcur')' ,
                     'Initsize('minit') Modrecs('mmod')' ,
                     'User('muser')'
            else 'LMMStats Dataid('toid') Member('bmem') Delete'
            end
      end
   end

 call do_say ' '
 call do_say 'Backed up' bc 'members from' fromdsn
 call do_say '                         to' targetds
 call do_say ' '
 call proc_etime
 call do_say 'Elapsed time:' etime

/* ------------------------------------------------------ *
 * Allocate the output dataset and write the $index member*
 * ------------------------------------------------------ */
 Address TSO
 $index.0 = ic
 "Alloc f("ddn"o) ds('"wtargetds"($index)') shr reuse"
 "Execio * diskw "ddn"o (finis stem $index."
 "Free  f("ddn"o)"
 Address ISPExec

/* -------------------------------------------------------- *
 * Allocate the output dataset and write the $backup member *
 * -------------------------------------------------------- */
 Address TSO
 msg.0 = mc
 "Alloc f("ddn"o) ds('"wtargetds"($backup)') shr reuse"
 "Execio * diskw "ddn"o (finis stem msg."
 "Free  f("ddn"o)"
 Address ISPExec

/* ------------------------------------------------ *
 | Add the ISPF Stats to $ALLOC, $BACKUP and $INDEX |
 * ------------------------------------------------ */
/* --------------------- *
 | first prime the stats |
 * --------------------- */
 iver = 1
 imod = 0
 cdate = date('o')
 mdate = cdate
 mtime = time()
 mmod  = 0
 muser = sysvar('sysuid')
/* --------------- *
 | First to $INDEX |
 * --------------- */
 mcur  = $index.0
 minit = mcur
 'LMMStats Dataid('toid')' ,
          'Member($INDEX) version('iver') modlevel('imod')' ,
          'Created('cdate') Moddate('mdate')' ,
          'Modtime('mtime') Cursize('mcur')' ,
          'Initsize('minit') Modrecs('mmod')' ,
          'User('muser')'
/* --------------- *
 | Now for $BACKUP |
 * --------------- */
 mcur  = msg.0
 minit = mcur
 'LMMStats Dataid('toid')' ,
          'Member($BACKUP) version('iver') modlevel('imod')' ,
          'Created('cdate') Moddate('mdate')' ,
          'Modtime('mtime') Cursize('mcur')' ,
          'Initsize('minit') Modrecs('mmod')' ,
          'User('muser')'
/* ---------------------- *
 | And finally for $ALLOC |
 * ---------------------- */
 'LMMStats Dataid('toid')' ,
          'Member($ALLOC) version('iver') modlevel('imod')' ,
          'Created('cdate') Moddate('mdate')' ,
          'Modtime('mtime') Cursize(1)' ,
          'Initsize(1) Modrecs(0)' ,
          'User('muser')'

/* ------------------------------------- *
 * Free up the ISPF allocations and exit *
 * ------------------------------------- */
 "lmfree dataid("fromid")"
 "lmfree dataid("toid")"
 Address TSO 'Free f('ddn')'
 end

/* ------------------------------------------------------------- *
 * Restore processing                                            *
 * 1. read in $ALLOC member to get MAXGEN value                  *
 *    check the maxgen value against the system limit and        *
 *    if the maxgen value is greater then set to system limit    *
 *    and tell the user                                          *
 * 2. Allocate the output PDSE with the ALLOC LIKE of the backup *
 *    dataset using the MAXGEN value                             *
 * 3. Read in the $INDEX member and process each member in       *
 *    sequence using lmcopy                                      *
 *                                                               *
 * The original generation number will be lost but the relative  *
 * generation will be retained.                                  *
 * ------------------------------------------------------------- */
 if pdsebopt = 'RESTORE' then do

 if ispf = 1 then do
    prog = 'Preparing...'
    "Control Display Lock"
    'addpop'
    'display panel(pdsegpr)'
    'rempop'
    end

 call do_say 'Processing restore from' fromdsn
 call do_say '                     to' targetds
 call do_say ' '
 call do_say 'Time:' time()' Date:' date()
 call do_say ' '

/* ------------------------------------ *
 * Get the current system maxgens_limit *
 * ------------------------------------ */

  CVT      = C2D(Storage(10,4))
  CVTDFA   = C2D(Storage(D2X(CVT + 1216),4))   /* cvt + 4c0 */
  DFAMGEN  = C2D(Storage(D2X(cvtdfa + 76),4))  /* dfa + 4c */

/* --------------------------------------------------------- *
 * Read in the $ALLOC member so we know what the generations *
 * should be and then allocate the target PDSE.              *
 * Read in the $INDEX member so we know what members to      *
 * restore.                                                  *
 * --------------------------------------------------------- */
  Address TSO
  "Alloc f("ddn"i) ds('"wfromdsn"($alloc)') shr reuse"
  "Execio * diskr "ddn"i (finis stem $alloc."
  parse value $alloc.1 with .'('amgen')' .
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
  'Alloc f('ddn') ds('targetds') like('fromdsn')' $alloc.1 ,
    'dsntype(library,2)' def_unit
  "Alloc f("ddn"i) ds('"wfromdsn"($index)') shr reuse"
  "Execio * diskr "ddn"i (finis stem $index."
  "Free  f("ddn"i)"
  Address ISPExec

/* ----------------------------------------- *
 * Establish the ISPF setup for the datasets *
 * ----------------------------------------- */
 "lminit dataid(fromid) dataset("fromdsn") enq(shrw)"
 "lminit dataid(toid)   dataset("targetds") enq(shrw)"
 'dsinfo dataset('fromdsn')'

/* --------------------------------------------- *
 * Now process the $index member which lists the *
 * backup member name and then the real member   *
 * name.                                         *
 *                                               *
 * The list is in order with the oldest/highest  *
 * generation first with the base member last.   *
 *                                               *
 * Thus we can just do lmcopy for each.          *
 * --------------------------------------------- */
 dcount = 0
 if ispf = 1 then do
    tot_members = $index.0
    call set_prog
    end
 do im = 1 to $index.0
    parse value $index.im with from to gen rgen .
    dcount = dcount + 1
    if ispf = 1 then call disp_progress
    "lmcopy fromid("fromid") todataid("toid")" ,
           "frommem("from") tomem("to") replace"
     call do_say 'Restoring member' left(to,8) 'from backup member' from ,
                 'rel gen' rgen
     end

/* ------------------------------------- *
 * Free up the ISPF allocations and exit *
 * ------------------------------------- */
   call do_say ' '
   call do_say 'Restored' $index.0 'members from' fromdsn
   call do_say '                             to' targetds
   call do_say ' '
   call proc_etime
   call do_say 'Elapsed time:' etime
   "lmfree dataid("fromid")"
   "lmfree dataid("toid")"
    Address TSO "Free f("ddn")"
   end

 if ispf = 1 then
 if mc > 0 then do
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
    msg.0 = mc
    "Execio * diskw" ddn "(finis stem msg."
    Address TSO "Free f("ddn")"
    Address ISPExec
    "Browse dataset('"temp"')"
    call outtrap 'x.'
    Address TSO "Delete '"temp"'"
    call outtrap 'off'
    mc = 0
    drop msg.
    end
 return

/* ------------------------------------ *
 * Setup for Progress Indicator Display *
 * ------------------------------------ */
 set_prog:
 division = 10
 incr = (tot_members % division) + 1
 progc = null
 perc# = 0
 return

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

/* -------------------------------------- *
 * Update_Target                          *
 *                                        *
 * 1. add 1 to backup ocunter             *
 * 2. add 1 to index counter              *
 * 3. update bmem with backup member name *
 *    absolute gen and relative gen       *
 * -------------------------------------- */
 Update_Target:
 bc = bc + 1
 ic = ic + 1
 bmem = '@'right(bc,7,'0')
 $index.ic = bmem cmem igen rgen*-1
 return

/* -------------------------------------------------- *
 * do_say routine                                     *
 *                                                    *
 * put the message in a stem and if ispf is not       *
 * active then say it                                 *
 * -------------------------------------------------- */
 do_say:
 parse arg message
 mc = mc + 1
 msg.mc = message
 if ispf /= 1 then
    say message
 return

/* -------------------------------- *
 * Test member and get record count *
 * -------------------------------- */
 Test_Mem:
   pdsemopt = 'T'
   'view dataid('fromid') member('cmem') gen('agen')' ,
        'macro(pdsegenm) parm(pdsemopt)'
 return

/* ----------------- *
 * Generate messages *
 * ----------------- */
 do_msg:
 if ispf = 1 then 'Setmsg msg(isrz002)'
    else do
         say zerrsm
         say zerrlm
         end
 return

 Proc_eTime:
    e_time = time("E")
    parse value e_time with ss "." uu
    numeric digits 6
    mm = ss % 60 /* get minutes integer */
    ss = ss // 60 /* get seconds integer */
    uu = uu // 100 /* get micro seconds integer */
    etime =  right(mm+100,2)':'right(ss+100,2)'.'right(uu+100,2) '(mm:ss:th)'
    return
