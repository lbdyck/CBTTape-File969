/* --------------------  rexx procedure  -------------------- *
 * Name:      pdsegfnd                                        *
 *                                                            *
 * Function:  Find string in PDSEGEN backup data set with     *
 *            SuperC Search-For. Replace @nnnnnnn generated   *
 *            name with real name and relative generation     *
 *            in the Search-For output (NEWDD).               *
 *                                                            *
 *            Also works in any PDS/PDSE without Member Gens. *
 *                                                            *
 * Syntax:    %pdsegfnd pdsegen-backupdsn 'string'            *
 *         or %pdsegfnd pdsegen-backupdsn 'string' '/\/\'     *
 *                                                            *
 *            if the /\/\ option is present then the ispf     *
 *            variable mhits will be created with the member  *
 *            names where the search was successful and will  *
 *            not view the superc report.                     *
 *                                                            *
 *            ISPF Variable FTMEMS contains a list of         *
 *            members if member filtering was active or       *
 *            is null if no filtering.                        *
 *                                                            *
 * Author:    John Kalinich, Lionel Dyck                      *
 *                                                            *
 * History:                                                   *
 *            08/07/19 - Add short/long message               *
 *            08/06/19 - enable use of SuperC in non-MG PDSes *
 *                     - return members with hit (lbd)        *
 *            02/23/18 - change to use ispexec select         *
 *            08/02/16 - created                              *
 * ---------------------------------------------------------- */
  arg pdsedsn string
  parse value '' with null ispf
  if right(string,4) = '/\/\' then do
    parse value string with string '/\/\'
    string = strip(string)
    ispf = 1
  end
  Address ISPExec
  if sysdsn(pdsedsn) /= 'OK' then do
    zedsmsg = null
    zedlmsg = 'Error.' pdsedsn sysdsn(pdsedsn)
    'setmsg msg(isrz001)'
    return
  end
  if left(pdsedsn,1) = "'" then do
    wdsn = substr(pdsedsn,2,length(pdsedsn)-2)
  end
  else do
    if sysvar('syspref') = null then hlq = sysvar('sysuid')
    else hlq = sysvar('syspref')
    wdsn = hlq'.'pdsedsn
  end

Process_Find:

  call read_$index
  call superc_srchfor
  exit

Read_$Index:
  @names. = null
  if sysdsn("'"wdsn"($index)'") /= "OK" then do
    Address ISPExec
    "dsinfo dataset('"wdsn"')"
    if zdsngen = 0 then     /* allow non member generations */
    return
    zedsmsg = 'Error'
    zedlmsg = 'Error.' "'"wdsn"($index)'" sysdsn("'"wdsn"($index)'")
    Address ISPExec
    'setmsg msg(isrz001)'
    exit
  end
  Address TSO
  "alloc f($index) da('"wdsn"($index)') shr reuse"
  'execio * diskr $index (stem index. finis'
  do im = 1 to index.0
    parse value index.im with backup_name real_name abs_gen rel_gen .
    @names.backup_name = Left(real_name,8) right(rel_gen,5)
  end
  'free f($index)'
  return

SuperC_Srchfor:
  Address ISPExec
  'vget (zscreen) shared'
  pdstname = 'RESULT'zscreen
  Address TSO
  x = outtrap('delete.','*')
  'delete srchfor.'pdstname
  x= outtrap('off')
  'alloc f(sysin) unit(vio) new reuse space(1,1) tracks',
    'lrecl(80) recfm(f b) blksize(0) dsorg(ps)'
  if pos("'",string) > 0 then
  push "SRCHFOR "string
  else
  push "SRCHFOR '"string"'"
  address ispexec 'vget (ftmems)'
  if strip(ftmems) /= '' then
  do mi = 1 to words(ftmems)
    queue "SELECT" word(ftmems,mi)
  end
  queue ""
  'execio * diskw sysin (finis'
  'delstack'
  "alloc f(newdd) da('"wdsn"') shr reuse"
  'alloc f(outdd) da(srchfor.'pdstname') new reuse unit(sysallda)',
    'space(15,15) tracks recfm(f b a) lrecl(132) blksize(0) dsorg(ps)'
  parm = 'SRCHCMP,ANYC,NOPRTCC'
  Address ISPExec 'Select pgm(isrsupc) Parm('parm')'
  'execio * diskr outdd (stem pds. finis'
  Address TSO
  'alloc f(sysin) da(*) shr reuse'
  'free  f(newdd)'
  'free  f(outdd) delete'

  do fi = 1 to pds.0
    if substr(pds.fi,2,1) = '@' then
    do
      target = substr(pds.fi,2,8)
      repl_name = left(@names.target,8)
      repl_gen  = substr(@names.target,10,5)
      pds.fi = ' 'target repl_name repl_gen '    ' substr(pds.fi,30,45)
    end
  end

  if sysdsn("'"wdsn"($index)'") /= "OK" then do
    if ispf = 1 then do
      mhits = ''
      do i = 1 to pds.0
        if pos('FOUND -',pds.i) = 0 then iterate
        mhits = mhits word(pds.i,1)
      end
      mhits = strip(mhits)
      address ispexec 'vput (mhits)'
      return
    end
  end

  Address TSO
  'alloc f('dd') unit(vio) new reuse space(10,10) tracks',
    'lrecl(255) recfm(f b) blksize(0) dsorg(ps)'
  'execio * diskw' dd '(finis stem pds.'
  Address ISPExec
  'lminit dataid(id) ddname('dd') enq(exclu)'
  if rc ^= 0 then do
    zedsmsg = 'Error'
    zedlmsg = 'Error.  LMINIT failed for VIO output file'
    'setmsg msg(isrz001)'
    exit
  end
  do x = pds.0 to 1 by -1
    if pos('MEMBERS-W/LNS',pds.x) > 0 then leave
  end
  x = x + 1
  hits = substr(pds.x,26,10)
  if datatype(hits) /= 'NUM' then hits = 0
  zedsmsg = 'hits' hits+0
  zedlmsg = 'Search resulted in' hits+0 'hits.'
  'Setmsg msg(isrz001)'
  'view   dataid('id')'
  'lmfree dataid('id')'
  if ispf = 1 then do
    mhits = ''
    do i = 1 to pds.0
      if pos('FOUND -',pds.i) = 0 then iterate
      mhits = mhits word(pds.i,1)
    end
    mhits = strip(mhits)
    address ispexec 'vput (mhits)'
    return
  end
  return
/* End of PDSEGFND exec */
