  /* --------------------  rexx procedure  -------------------- *
  * Name:      PDSEGDSL                                        *
  *                                                            *
  * Function:  Process the PDSEGEN Data Set List Table         *
  *                                                            *
  * Usage Notes: Called by PDSEGEN when a request is made      *
  *              for this table.                               *
  *                                                            *
  * Author:    Lionel B. Dyck                                  *
  *                                                            *
  * History:  (most recent on top)                             *
  *            06/03/22 LBD - Add Clean option                 *
  *            12/17/20 LBD - Allow single qualifier dsn       *
  *            08/06/20 LBD - Allow alias on command line like *
  *                           a number                         *
  *                         - Allow member in dsname field     *
  *            08/03/20 LBD - Add Max History to panel         *
  *            08/02/20 LBD - Correct cursor if insert dsn bad *
  *            07/31/20 LBD - Restructure and clean up         *
  *            07/27/20 LBD - Refinement                       *
  *            07/26/20 LBD - Refinement                       *
  *            07/25/20 LBD - Creation                         *
  *                                                            *
  * ---------------------------------------------------------- *
  * Copyright (c) 2017-2022 by Lionel B. Dyck                  *
  * ---------------------------------------------------------- *
  * Support is on a best effort and time available basis which *
  * is why the complete source is provided for this application*
  * so you can find and fix any issues you find. Please let    *
  * me know if you do make changes/enhancements/fixes.         *
  * ---------------------------------------------------------- *
  * License:   This EXEC and related components are released   *
  *            under terms of the GPLV3 License. Please        *
  *            refer to the LICENSE file for more information. *
  *            Or for the latest license text go to:           *
  *                                                            *
  *              http://www.gnu.org/licenses/                  *
  * ---------------------------------------------------------- *
  * ------------------- Soli Deo Gloria ---------------------- */
  arg option

  if left(option,1) = '>' then do
     if listdsi(substr(option,2)) = 0 then option = "'"sysdsname"'"
     end
  else if listdsi(option) = 0 then option = "'"sysdsname"'"

  Address ISPExec
  null = ''
  zerrhm   = 'PDSEGH0'
  zerralrm = 'NO'
  zerrtp   = 'Notify'

  /* ---------------------------- *
  | if user max is 0 then return |
  * ---------------------------- */
  'vget (umaxhist maxhist) profile'
  if umaxhist = 0 then return 0
  if datatype(umaxhist) /= 'NUM'
  then umaxhist = maxhist

  /* ------------------------------------------------------------ *
  | Open the ISPF Table of PDSEGEN Data Sets (PDSEGDSL) which is |
  | stored in the ISPPROF referenced dataset since everyone has  |
  | this allocated.                                              |
  |                                                              |
  | If the table does NOT exist then create it.                  |
  |                                                              |
  | Test for the PDSEDS01 variable and if found then convert the |
  | old format variables to the new ISPF Table.                  |
  |                                                              |
  | Then erase the obsolete variables from the Profile.          |
  * ------------------------------------------------------------ */
  'tbopen pdsegdsl library(ispprof) write share'
  if rc > 0 then do
    call table_create
    call check_oldstuff
  end
  call test_table

  /* ------------------------------------------------------------ *
  | Test for any passed option value.                            |
  |                                                              |
  | 1. If it contains a . then it is a dataset and will be added |
  |    to the table at position 1.                               |
  | 2. If it does not contain a . and it is numeric then return  |
  |    the dataset at that position                              |
  | 3. If it does not contain a . and is not numeric then check  |
  |    if it is a dataset alias and return that dataset name     |
  | 4. if all the above fails then display the table             |
  * ------------------------------------------------------------ */
  if option /= null then
  if option /= '?' then do
    if pos('.',option) > 0 then do
      zs = 0
      dsloc = 5
      if pos('(',option) > 0
      then do
        parse value option with option'('omem')'ro
        option = option''ro
      end
      else omem = null
      x = listdsi(option)
      if x > 0 then do
        zerrsm = null
        zerrlm = option sysmsglvl2
        'setmsg msg(isrz003)'
        return 0
      end
      if omem /= null then sysdsname = sysdsname"("omem")"
      tdsn = "'"sysdsname"'"
      x = does_dsn_exist()
      if x = 0 then call do_return 0
      pdsn = tdsn
      zs = 0
      dsloc = 5
      palias = null
      lastref = date('j')
      lastref = left(lastref,2)'.'right(lastref,3)
      'tbadd pdsegdsl'
      x = update_zs(0)
      call test_table_count
      call do_return 0
    end
    if left(option,1) = '>' then
    parse value option with one_time 2 option
    else one_time = null
    'tbtop pdsegdsl'
    do forever
      'tbskip pdsegdsl'
      if rc > 0 then do
        if one_time /= null then call do_return 0
        zerrsm = null
        zerrlm = 'Requested file not found:' option
        'setmsg msg(isrz003)'
        leave
      end
      select
        when datatype(option) = 'NUM' then do
          if zs = option then
          call do_return pdsn
        end
        otherwise do
          if option = palias then
          call do_return pdsn
        end
      end
    end
  end

  /* --------------------------------------------------------- *
  | Time to display the table to allow the user to manage the |
  | table and/or select a dataset to work with.               |
  * --------------------------------------------------------- */
  option = null
  'tbtop pdsegdsl'
  dtop = 1
  arow = null
  do forever
    dsel = null
    if ztdsels > 1 then do
      'tbdispl pdsegdsl'
    end
    else do
      update = 0
      sort = 0
      dloc = 0
      umhist = umaxhist
      'tbtop pdsegdsl'
      'tbskip pdsegdsl number('dtop')'
      if arow = null
      then 'tbdispl pdsegdsl panel(pdsegdsl)'
      else 'tbdispl pdsegdsl panel(pdsegdsl)' ,
        'csrrow('arow') cursor(pdsn)'
      arow = null
    end
    if rc > 4 then leave
    if umhist /= umaxhist then do
      umaxhist = umhist
      'vput (umaxhist) profile'
      call test_table_count
    end
    dtop = ztdtop
    if ztdsels > 0 then
    if dsel = null then do
      if row > 0 then
      if pos = 'DSEL'
      then dsel = 'S'
      else dsel = 'U'
      if row = 0 then do
        s_palias = palias
        'tbtop pdsegdsl'
        'tbscan pdsegdsl arglist(pdsn) rowid(row)'
        dsel = 'U'
        palias = s_palias
      end
    end
    Select
      When zcmd = 'EXIT' then leave
      When zcmd /= null then call do_zcmd
      Otherwise if dsel /= null then do
        call do_dsel
      end
    end
  end
  call do_return 0

  /* ------------------------------------ *
  | Return after save/close of the table |
  * ------------------------------------ */
Do_Return:
  arg return_value
  'tbclose pdsegdsl replcopy library(ispprof)'
  if pos('(',return_value) > 0 then do
     parse value return_value with return_value'('rm')'rd
     return_value = return_value''rd rm
     end
  Exit  return_value

  /* --------------------- *
  | Create the ISPF Table |
  * --------------------- */
Table_Create:
  'tbcreate pdsegdsl names(pdsn zs palias dsloc lastref) write' ,
    'library(ispprof) share'
  return

  /* -------------------- *
  | Process any commands |
  * -------------------- */
do_zcmd:
  Select
    When datatype(zcmd) = 'NUM' then do
      'tbtop pdsegdsl'
      'tbskip pdsegdsl number('zcmd')'
      if rc = 0 then
      call do_return pdsn
      else do
           zerrsm = 'Invalid.'
           zerrlm = zcmd 'is not a valid row selection. Select a row' ,
             'number from 1 to' rownum + 0 'and try again.'
           'setmsg msg(isrz003)'
           end
    end
    When zcmd = 'CLEAN' then do
      'tbtop pdsegdsl'
      do forever
         'tbskip pdsegdsl'
         if rc > 0 then leave
         if palias = null then 'tbdelete pdsegdsl'
         end
      x = update_zs(0)
      end
    When zcmd = 'CLEAR' then do
      'tbclose pdsegdsl library(ispprof)'
      'tberase pdsegdsl library(ispprof)'
      call table_create
      dtop = 1
    end
    /* ---------------- *
    | Insert a dataset |
    |  - blank         |
    |  - dataset       |
    |  - dataset alias |
    * ---------------- */
    When abbrev('INSERT',word(zcmd,1),1) = 1 then do
      zs = 1
      pdsn = word(zcmd,2)
      if pdsn /= null then do
        if pos('(',pdsn) > 0
        then do
          parse value pdsn with pdsn'('pmem')'rdsn
          pdsn = pdsn""rdsn
        end
        else pmem = null
        x = listdsi(pdsn)
        if x > 0 then do
          zerrsm = 'Error.'
          zerrlm = pdsn sysmsglvl2
          'setmsg msg(isrz003)'
        end
        else do
          if pmem = null
          then pdsn = "'"sysdsname"'"
          else pdsn = "'"sysdsname"("pmem")'"
        end
      end
      palias = word(zcmd,3)
      dsloc = 1
      'tbtop pdsegdsl'
      'tbadd pdsegdsl'
      x = update_zs(0)
      arow = 1
      update = 1
      ztdsels = 0
      zcmd = null
      dtop = 1
    end
    When abbrev('SORT',zcmd,1) = 1 then do
      'tbsort pdsegdsl fields(pdsn,c,a)'
      x = update_zs(0)
    end
    When abbrev('SORTD',zcmd,1) = 1 then do
      'tbsort pdsegdsl fields(pdsn,c,d)'
      x = update_zs(0)
    end
    Otherwise do
      'tbtop pdsegdsl'
      do forever
        'tbskip pdsegdsl'
        if rc > 0 then leave
        if zcmd = palias then call do_return pdsn
      end
    end
  end
  return

  /* ------------------------------------------ *
  | Update the table row counters and location |
  * ------------------------------------------ */
Update_zs:
  arg dc
  'tbtop pdsegdsl'
  dloc = 0
  do forever
    'tbskip pdsegdsl'
    if rc > 0 then leave
    dc = dc + 1
    zs = dc
    dloc = dloc +100
    dsloc = dloc
    'tbput pdsegdsl'
  end
  return 0

  /* --------------------------------------------------------------- *
  | Process Row Selections                                          |
  | - no selection but a change in the row then just update the row |
  | - R will remove the row (delete)                                |
  | - M will move the row to the top                                |
  | - I will inser a row below the current row                      |
  * --------------------------------------------------------------- */
do_dsel:
  Select
    When dsel = 'U' then do
      spdsn = pdsn
      spalias = palias
      szs = zs
      zdsloc = dsloc
      if pos('(',spdsn) = 0
      then pmem = null
      else do
        parse value spdsn with spdsn'('pmem')'rdsn
        spdsn = spdsn""rdsn
      end
      x = listdsi(spdsn)
      if x > 0 then do
        zerrsm = 'Error.'
        zerrlm = spdsn 'is not a valid dataset name or does not exist:' ,
          sysmsglvl2
        'setmsg msg(isrz003)'
        arow = row
      end
      else do
        if pmem = null
        then spdsn = "'"sysdsname"'"
        else spdsn = "'"sysdsname"("pmem")'"
      end
      pdsn = spdsn
      palias = spalias
      zs = 1
      dsloc = 10
      'tbput pdsegdsl'
      update = 1
    end
    When dsel = 'S' then call do_return pdsn
    When dsel = 'I' then do
      dsloc = dsloc + 5
      pdsn = null
      palias = null
      'tbadd pdsegdsl'
      arow = row + 1
      update = 0
    end
    When dsel = 'R' | dsel = 'D' then do
      'tbdelete pdsegdsl'
      update = 1
    end
    when dsel = 'M' then do
      dloc = dloc + 1
      dsloc = dloc
      zs = 1
      'tbput pdsegdsl'
      sort = 1
      update = 1
      dtop = 0
    end
    otherwise nop
  end
  if ztdsels = 1 then
  if update = 1 then do
    if sort = 1 then
    'tbsort pdsegdsl fields(dsloc,n,a)'
    x = update_zs(0)
    sort = 0
    update = 0
  end
  return 0

Does_DSN_Exist:
  'tbtop pdsegdsl'
  do forever
    'tbskip pdsegdsl'
    if rc > 0 then return 4
    if pdsn = tdsn then do
      lastref = date('j')
      lastref = left(lastref,2)'.'right(lastref,3)
      'tbput pdsegdsl'
      return 0
    end
  end
  return

  /* ---------------------------------------------------------- *
  | Test the table to see if the last reference field is there |
  | and if not recreate the table with it.                     |
  * ---------------------------------------------------------- */
Test_Table:
  'tbquery pdsegdsl names(rows) rownum(rownum)'
  if pos('LASTREF',rows) > 0 then return
  tc = 0
  'tbtop pdsegdsl'
  do forever
    'tbskip pdsegdsl'
    if rc > 0 then leave
    tc = tc + 1
    r.tc =  pdsn palias
  end
  'tbclose pdsegdsl library(ispprof)'
  'tberase pdsegdsl library(ispprof)'
  call table_create
  dsloc = 0
  do i = 1 to tc
    zs = 1
    dsloc = dsloc + 10
    lastref = date('j')
    lastref = left(lastref,2)'.'right(lastref,3)
    parse value r.i with pdsn palias
    'tbadd pdsegdsl'
  end
  x = update_zs(0)
  return

  /* ------------------------------------------------------------- *
  | Test if the table has reached the defined limit plus 1 and if |
  | so then delete all entries over the limit (typically that     |
  | should only be one row).                                      |
  * ------------------------------------------------------------- */
Test_Table_Count:
  'tbquery pdsegdsl rownum(rows)'
  'tbsort pdsegdsl fields(lastref,n,d)'
  remove = rows - umaxhist + 1
  'tbtop pdsegdsl'
  do ttr = 1 to remove
    'tbskip pdsegdsl'
    if rc > 0 then leave
    if palias /= null then do
      iterate
    end
    'tbdelete pdsegdsl'
  end
  'tbsort pdsegdsl fields(dsloc,n,a)'
  x = update_zs(0)
  return

Check_OldStuff:
  'vget (pdseds01 pdseds02 pdseds03 pdseds04' ,
    'pdseds05 pdseds06 pdseds07 pdseds08' ,
    'pdseds09 pdseds10 pdseds11 pdseds12' ,
    'pdseds13 pdseds14 pdseds15 pdseds16 ' ,
    'pdseds17 pdseds18 pdseds19 pdseds20 ' ,
    'pdseds21 pdseds22 pdseds23 pdseds24 ' ,
    'pdseds25)' ,
    'profile'
  if rc = 0 then do
    do i = 1 to 25
      interpret 'pdsn = pdseds'right(i+100,2)
      if pdsn = null then iterate
      zs = i
      dsloc = i * 100
      'tbadd pdsegdsl'
    end
  end
  'tbsave pdsegdsl library(ispprof)'
  'verase (pdseds01 pdseds02 pdseds03 pdseds04' ,
    'pdseds05 pdseds06 pdseds07 pdseds08' ,
    'pdseds09 pdseds10 pdseds11 pdseds12' ,
    'pdseds13 pdseds14 pdseds15 pdseds16 ' ,
    'pdseds17 pdseds18 pdseds19 pdseds20 ' ,
    'pdseds21 pdseds22 pdseds23 pdseds24 ' ,
    'pdseds25)' ,
    'profile'
  Return
