/* --------------------  rexx procedure  -------------------- */
  ver = "3.8"
/* Name:      TryIT                                           *
 *                                                            *
 * Function:  Used to test the file currently being edited    *
 *            under ISPF Edit.                                *
 *                                                            *
 *            Supported member types are:                     *
 *               REXX Execs                                   *
 *               CLISTs                                       *
 *               ISPF Panels (normal, tutorial, popup, table) *
 *               Assembler Code                               *
 *               JCL (if a syntax checker is defined)         *
 *                                                            *
 *            For Assembler members the Assembler will be     *
 *            called to assemble the member prompting for     *
 *            options, maclibs, and object data set.          *
 *                                                            *
 *            For both CLIST and EXEC members the active      *
 *            data set will be allocated via ALTLIB and       *
 *            the member executed with any parms passed       *
 *            to it.                                          *
 *                                                            *
 *            For ISPF Panels the member will be copied into  *
 *            a temporary data set. The active library will   *
 *            then be allocated to a temp dd and both will be *
 *            concatenated using bpxwdyn. Then both will be   *
 *            LIBDEF'd to ISPPLIB. This is so that other      *
 *            panels might be found if SEL or TUT is used.    *
 *            This is being done because ISPF will 'remember' *
 *            the bldl information for the panel and thus     *
 *            changes will not be reflected in subsequent     *
 *            uses of this exec.                              *
 *                                                            *
 *            The type of member is determined by:            *
 *            1) word REXX in record 1 for REXX Execs         *
 *               *and* there is a comment marker prior to     *
 *               the word rexx                                *
 *            2) )ATTR in record 1 for ISPF Panels            *
 *               as well as )PANEL )CCSID )BODY               *
 *            3) PROC followed by a numeric in record 1       *
 *               for a CLIST                                  *
 *            4) CLIST if data set suffix is:                 *
 *               CLIST, CMDPROC and SYSPROC                   *
 *            5) ISPF Panel if data set suffix is:            *
 *               PANEL, PANELS, or ISPPLIB                    *
 *            6) REXX Exec if data set suffix is:             *
 *               REXX, EXEC, or SYSEXEC                       *
 *            7) Assembler programs set if the suffix is:     *
 *               ASM, ASSEM                                   *
 *            8) )CM   in record 1 for ISPF Skeletons         *
 *               as well as )SET   )SEL                       *
 *                                                            *
 * Syntax:    tryit parms                                     *
 *                                                            *
 *            Where parms is any optional parameter to        *
 *            pass to the CLIST or EXEC.                      *
 *                                                            *
 *            If trying an ISPF Panel then parms may be       *
 *            POP to cause the panel to be displayed in a     *
 *            popup panel.                                    *
 *                                                            *
 *            To Select an ISPF Panel instead of Displaying   *
 *            it use the option SEL (may be used with POP)    *
 *                                                            *
 *            If using POP then immediately after POP you     *
 *            can specify the row # and column # to use:      *
 *                                                            *
 *              e.g. tryit pop 5 6                            *
 *                                                            *
 *            Add TUT to the parms to fully test an ISPF      *
 *            tutorial panel                                  *
 *                                                            *
 *            Add APPL xxxx to have the panel selected in     *
 *            ISPF application ID xxxx.                       *
 *                                                            *
 *            Add TRAP to capture and view the output         *
 *                                                            *
 * NOTE:      This command is invoked as an ISPF Edit Macro   *
 *                                                            *
 * Restrictions: This tool will *NOT* work to test ISPF Edit  *
 *               Macros.                                      *
 *                                                            *
 * Customization: Set Temp_Opt to 1 to create a temp member   *
 *                if the active member has changed and not    *
 *                been saved. Or set to 0 to prompt the user  *
 *                to save and retry.          find *custom*   *
 *                                                            *
 *                site dependent datasets     find *custom*   *
 *                                                            *
 *                JCL Syntax Checker          find *custom*   *
 *                                                            *
 * Author:    Lionel B. Dyck                                  *
 *                                                            *
 * History:                                                   *
 *            2021-05-07 - 3.8 - Replace non-display chars    *
 *                               in TRYIT asm panel           *
 *                             - Fixup the panel load routine *
 *            2020-07-13 - 3.7 - Fix typo                     *
 *            2020-07-13 - 3.6 - Support Table Panels         *
 *            2020-04-23 - 3.5 - Add TRAP option              *
 *            2019-07-02 - 3.4 - If Tut then don't addpop     *
 *            2019-05-02 - 3.3 - Improved non-Edit message    *
 *            2019-04-26 - 3.2 - Look for )END and set Panel  *
 *            2019-04-10 - 3.1 - Define (vget) zscreenw for   *
 *                               panels                       *
 *            2019-03-21 - 3.0 - Make popup intelligent       *
 *            2019-02-28 - 2.9 - Add pop row/column           *
 *            2018-03-22 - 2.8 - increase random # for dd's   *
 *            2017-06-20 - 2.7 - add checks for SKL lines     *
 *                             - add generic type support     *
 *                               like *PENU and *PDEU         *
 *            2017-06-19 - 2.6 - add Stack to LIBDEF's        *
 *            2017-04-27 - 2.5 - Fix tutorial to use appl     *
 *            2017-04-26 - Add ISPF tutorial                  *
 *            2017-04-24 - Enhance ASM detection              *
 *            2016-02-24 - update for CA-JCLCheck             *
 *            2016-02-23 - remove obsolete author company,    *
 *                         address, etc.                      *
 *            2005-03-08 - add check being invoked as a macro *
 *            2005-03-07 - add support for skeletons          *
 *            07/09/2004 - panel TRYASM now scrollable        *
 *            07/08/2004 - Change option for ASM SYSLIB       *
 *                         if maclib = * then add active d/s  *
 *                         otherwise the active d/s is at the *
 *                         end of the maclibs in syslib.      *
 *                       - Correct to ASM parms               *
 *            07/08/2004 - Message cleanup for JCL            *
 *            07/07/2004 - Add JCL Syntax Checker             *
 *            06/30/2004 - Add SYS1.MODGEN and add site macs  *
 *                       - Add site syslibs (i.e. ISPF GDDM)  *
 *                         thx to Hartmut Beckmann            *
 *            06/28/2004 - Add SYS1.MACLIB and redo panel     *
 *                         thx to Hartmut Beckmann            *
 *            06/24/2004 - Add TERM option to tryitasm panel  *
 *                         with new panel by hartmut          *
 *                       - add option to delete list/obj d/s  *
 *                       - All Panels will now be in a temp   *
 *                         library.                           *
 *                       - add hlq for list/obj and temp term *
 *                         data sets (for asm)                *
 *            06/14/2004 - change to find dynamic panel to    *
 *                         speed it up                        *
 *                       - Add % to clist/rexx calls          *
 *            06/04/2004 - dynamically created panel tryitasm *
 *                         no need to copy panel into ispplib *
 *                         thx to Hartmut Beckmann            *
 *            05/21/2004 - Improve detection of REXX Exec     *
 *                         and Assembler code                 *
 *            05/19/2004 - Correct link edit parm setup       *
 *            05/18/2004 - ADD code to create a temp member   *
 *                         if member changed but not saved.   *
 *                       - Add Assembler support              *
 *            05/17/2004 - ADD APPL option                    *
 *            05/15/2004 - Move Control Errors Return         *
 *            05/14/2004 - Correct setmsg for panels          *
 *                       - Correct source changed msg         *
 *                       - Correct test for prep panel        *
 *            05/14/2004 - Update to:                         *
 *                       - improve test for ISPF Panels       *
 *                       - add SEL option for ISPF panels     *
 *                         to Select                          *
 *                       - add TUT option for ISPF tutorial   *
 *                         panels                             *
 *            05/14/2004 - Update by Kenneth Tomiak to find   *
 *                         PROC # on first line, )PANEL, and  *
 *                         moved check for changed code up.   *
 *            05/13/04 - Clean up messages                    *
 *            05/13/04 - Update to msgs by Asher Aremband     *
 *                     - Support for CLIST, EXEC, and ISPF    *
 *                       Panel members thanks to a suggestion *
 *                       by Hartmut Beckmann.                 *
 *            05/12/04 - Creation                             *
 *                                                            *
 * ---------------------------------------------------------- */

  signal on novalue name sub_novalue
/* ----------------------------------------- *
 * Determine our environment and get details *
 * ----------------------------------------- */
  if sysvar('sysispf') /= 'ACTIVE' then do
    say "Error. The TRYIT command is an ISPF Edit Command"
    say "       and *NOT* a TSO command. It must be executed"
    say "       from the ISPF Edit command line thus:"
    say "       "
    say "       Command ===> TRYIT"
    say "       "
    say "Exiting...."
    exit 16
  end
  Address ISREdit
  "Macro (parms) NOPROCESS"
  if rc > 0 then do
    Address ISPexec
    zedsmsg = "Must be in Edit Mode"
    zedlmsg = "This utility is an edit macro",
      "and will only work when editing",
      "or viewing a PDS(MBR) or Sequential",
      "file.  It is not a TSO command."
    "SETMSG MSG(isrz001)"
    Exit 8
  END
  if parms = '?' then do
    Address ISPExec 'Select pgm(isptutor) parm(#tryit)'
    Exit
  end
  Address ISPexec
  "CONTROL ERRORS CANCEL"
  Address ISREdit
  "(Dataset) = dataset"
  "(Member)  = member"
  "(changed) = data_changed"

  if wordpos('TRAP',translate(parms)) > 0 then do
    trap = 1
    p = wordpos('TRAP',translate(parms))
    parms = delword(parms,p,1)
  end
  else trap = 0

/* ------------------ *
 * Setup our defaults *
 * ------------------ */
  orig_mem = member
 /* reorder values and add some generic patterns                  */
 /* 1st word is used to set type if llq matches a generic pattern */
  clist = "CLIST   SYSPROC CMDPROC"
  rexx  = "REXX    SYSEXEC  EXEC"
  asm   = "ASM     ASSEM"
  jcl   = "JCL     CNTL"
  panel = "PANEL   PANELS          ISPPLIB *PLIB *PENU *PDEU"
  skl   = "SKL     SKEL     SKELS  ISPSLIB *SLIB *SENU *SDEU"
  if length(sysvar("syspref")) = 0 ,
    then hlq = sysvar("sysuid")
  else hlq = sysvar("syspref")
  parse value "" with null type zerrsm zerrlm proc ,
    tobject tlisting pp table ,
    tut appl temp newappl popup

/* ------------------------------------------------------- *
 * *custom*                                                *
 * Temp_Opt:  Determines what happens if the active member *
 *            has changed and not been saved.              *
 *                                                         *
 *            0 = tell the user to save and retry tryit    *
 *            1 = create temp member                       *
 *                                                         *
 * Note: ISPF Panels will always be copied into a temp     *
 *       panel library because of an ISPF restriction.     *
 * ------------------------------------------------------- */
  Temp_Opt = 1

/* ------------------------------------------------------- *
 * *custom*                                                *
 * JCL_Check set to null for no syntax checker or to the   *
 *            name of an ISPF Edit command to do the       *
 *            syntax checking.                             *
 *                                                         *
 *            e.g JCL_Check = "PREP" (for JCL Prep)        *
 *            e.g JCL_Check = "!JCK" (for CA JCL Check     *
 * ------------------------------------------------------- */
  JCL_Check = "!JCK"
 /* JCL_Check = "Prep" */
 /* JCL_Check = "JEM"  */
 /* JCL_Check = "!JCK" */

/* -------------------------------- *
 * Get the data from the first line *
 * -------------------------------- */
  "(line) = line 1"
  uline = translate(line)
  "(lst) = line .zlast"
  ulast = translate(lst)

/* -------------------------------------------- *
 * Dynamically determine if this is a REXX Exec *
 * -------------------------------------------- */
  if wordpos("REXX",uline) > 0 then do
    pc  = pos("/*",uline)
    pcr = wordindex(uline,wordpos("REXX",uline))
    if pc > 0
    then if pcr > pc then do
      type     = "REXX"
      alt_type = "exec"
    end
  end

/* ------------------------------------ *
 * Dynamically determine if this is ASM *
 * ------------------------------------ */
  if wordpos("CSECT",uline) > 0 |,
    wordpos("TITLE",uline) > 0 then type = "ASM"

/* -------------------------------------------- *
 * Dynamically determine if this is a TSO clist *
 * -------------------------------------------- */
  if ((wordpos("PROC",uline) > 0) &,
    (datatype(word(line,2)) = "NUM")) then do
    type     = "CLIST"
    alt_type = "clist"
  end

/* ------------------------------------ *
 * Dynamically determine if this is JCL *
 * ------------------------------------ */
  if left(line,2) = "//" then type = "JCL"

/* ---------------------------------------------- *
 * Dynamically determine if this is an ISPF Panel *
 * ---------------------------------------------- */
  Select
    When word(uline,1) = ")ATTR"   then type = "PANEL"
    When word(uline,1) = ")PANEL"  then type = "PANEL"
    When word(uline,1) = ")CCSID"  then type = "PANEL"
    When word(uline,1) = ")PROC"   then type = "PANEL"
    When word(uline,1) = ")BODY"   then type = "PANEL"
    When word(uline,1) = ")INIT"   then type = "PANEL"
    When word(uline,1) = ")REINIT" then type = "PANEL"
    When word(ulast,1) = ")END"    then type = "PANEL"
    When substr(line,3,5) = "PREP:"
    then type = "PANEL"
    Otherwise nop
  end

/* ---------------------------------------------- *
 * Dynamically determine if this is an ISPF Skel  *
 * ---------------------------------------------- */
  Select
    When word(uline,1) = ")CM"     then type = "SKL"
    When word(uline,1) = ")SET"    then type = "SKL"
    When word(uline,1) = ")SEL"    then type = "SKL"
    Otherwise nop
  end

/* ----------------------- *
 * determine the file type *
 * ----------------------- */
  td = translate(dataset,' ','.')
  w = words(td)
  llq = word(td,w)

  if type = null then do
    Select
      When wordpos(word(td,w),rexx)  > 0 then do
        type     = "REXX"
        alt_type = "exec"
      end
      When wordpos(word(td,w),panel) > 0 then do
        type     = "PANEL"
      end
      When wordpos(word(td,w),skl)   > 0 then do
        type     = "SKL"
      end
      When wordpos(word(td,w),clist) > 0 then do
        type    = "CLIST"
        alt_type = "clist"
      end
      When wordpos(word(td,w),asm)   > 0 then do
        type    = "ASM"
      end
      Otherwise nop
    end /* end select */
  end

  if type = null then do
    type = sub_generic_llq(llq)
  end
  if type = null then do
    type     = "REXX"
    alt_type = "exec"
  end

/* ----------------------------------------------------- *
 * Verify that the code has been saved before proceeding *
 * ----------------------------------------------------- */
  if wordpos(type,"PANEL JCL SKL") = 0 then
  If changed = "YES" then do
    If temp_opt = 1 then do
      temp        = 0
      Call find_temp
      Address ISREdit ,
        "Create" tempmem ".zf .zl"
      temp   = 1
      member = tempmem
    end
    else do
      Address ISPExec
      zedsmsg = "Warning source changed"
      zedlmsg = "Please save" member "and",
        "try again."
      "Setmsg msg(isrz001)"
      exit 8
    end
  end

  if wordpos(type,"PANEL SKL") > 0 then do
    ispfddt = "$"random(99999)
    ispfddo = "$"random(99999)
    Address TSO
    "Alloc f("ispfddt") unit(sysda) spa(5,5) dir(1)",
      "recfm(f b) lrecl(80) blksize(27920)"
    "Alloc f("ispfddo") shr ds('"dataset"')"
    Address ISPExec
    "Lminit dataid(lmispf) ddname("ispfddt")"
    "LmOpen dataid("lmispf") Option(Output)"
    Address ISREdit
    "(first) = linenum .zf"
    "(last)  = linenum .zl"
    do lr = first to last
      "(record) = line" lr
      Address ISPExec ,
        "LmPut dataid("lmispf") MODE(INVAR)" ,
        "DataLoc(record) DataLen(80)"
    end
    Address ISPExec
    "LmmAdd dataid("lmispf") Member("member")"
    "LmFree dataid("lmispf")"
    Address TSO
    call  bpxwdyn "concat ddlist("ispfddt","ispfddo") msg(2)"
    Address ISPExec
    select
      when ( type = "SKL" ) then ,
        "Libdef ISPSLIB Library ID("ispfddt") Stack"
      otherwise ,
        "Libdef ISPPLIB Library ID("ispfddt") Stack"
    end
  end

/* ------------------- *
 * Setup Errors Return *
 * ------------------- */
  Address ISPExec ,
    "Control Errors Return"
  types_libdef = "ASM other_types"
  If find(types_libdef,type) > 0 then do
    Call setup_libdefs      /* Create ISPF libraries        */
  end

/* -------------------------------------- *
 * If type is Assembler then:             *
 * -> display panel for assembler options *
 * -> allocate assembler data sets        *
 * -> allocate maclibs (if any)           *
 * -> call assembler                      *
 * -> free data sets                      *
 * - browse assembly listing              *
 * -------------------------------------- */
  If type = "ASM" then do
    Address ISPExec
    "Vget (tterm trent tauth tother tretain" ,
      "tmac1 tmac2 tmac3 tmac4" ,
      "tlink tsyslib tloadlib)" ,
      "Profile"
    "Display Panel(tryitasm)"
    if rc > 0 then do
      zedsmsg = "Cancelled"
      zedlmsg = "Assembly cancelled for" member ,
        "as your request."
      "Setmsg msg(isrz001)"
    end
    else do
      "Vput (tterm trent tauth tother" ,
        "tmac1 tmac2 tmac3 tmac4" ,
        "tlink tsyslib tloadlib)" ,
        "Profile"
      Address TSO
      tlisting = "'"hlq"."orig_mem".LIST'"
      tobject  = "'"hlq"."orig_mem".OBJ'"
      ttermds  = "'"hlq"."orig_mem".term'"
      _x_ = check_dataset(""tlisting" DELETE")
      _x_ = check_dataset(""tobject " DELETE")
      _x_ = check_dataset(""ttermds " DELETE")

      if tmac1 = "*" then tmac1 = "'"dataset"'"
      if tmac2 = "*" then tmac2 = "'"dataset"'"
      if tmac3 = "*" then tmac3 = "'"dataset"'"
      if tmac4 = "*" then tmac4 = "'"dataset"'"
      tmacu = tmac1 tmac2 tmac3 tmac4
      if pos(dataset,tmacu) = 0 then tmacu = "'"dataset"'"
      else tmacu = null

      /* ------------------------------------ *
       * Add site dependent datasets          *
       * ------------------------------------ */
      tmacs = null
      tmac.5 = site_dependent_datasets("tmac5")
      tmac.6 = site_dependent_datasets("tmac6")
      tmac.7 = site_dependent_datasets("tmac7")
      tmac.8 = site_dependent_datasets("tmac8")
      tmac.9 = site_dependent_datasets("tmac9")
      do i = 5 to 9
        tmacs = tmacs" "tmac.i
      end
      tmacs = strip(tmacs)
      msg_save = MSG("OFF")
      "free fi(sysprint syslin syslib sysin systerm " ,
        " sysut1 sysut2 sysut3)"
      msg_reset = MSG(msg_save)
      "Alloc f(sysprint) new spa(30,30) tr" ,
        "dsname("tlisting") reuse"
      "Alloc f(syslin) new spa(30,30) tr" ,
        "dsname("tobject") reuse"
      "Alloc f(syslib) ds(" ,
        tmac1 tmac2 tmac3 tmac4 tmacs tmacu ,
        ") shr reuse"
      "Alloc f(sysut1) spa(30,30) tr"
      "Alloc f(sysut2) spa(30,30) tr"
      "Alloc f(sysut3) spa(30,30) tr"
      "Alloc f(sysin) ds('"dataset"("member")') shr reuse"
      if translate(tterm) = "TERM" then
      "Alloc f(systerm) spa(15,15) tr ds("ttermds") new" ,
        "recfm(f b) lrecl(80) reuse"
      parm = null
      if trent = "Yes" then parm = "RENT"
      if tterm <> null then
      if parm <> null
      then parm = parm","tterm
      else parm = tterm
      if tother <> null then
      if parm <> null
      then parm = parm","tother
      else parm = tother
      Address ISPExec "Select Pgm(asma90) Parm("parm")"
      return_code = rc
      "Free f(sysut1 sysut2 sysut3 syslin sysprint syslib sysin)"
      "Alloc f(sysin)    ds(*) reuse"
      "Alloc f(sysprint) ds(*) reuse"
      Address ISPExec
      zedsmsg = "RC:" return_code
      zedlmsg = orig_mem "has been assembled and ended with a",
        "return code of" return_code
      left(" ",20) zerrlm
      "Setmsg msg(isrz001)"
      if translate(tterm) = "TERM" then do
        "Browse Dataset("ttermds")"
        Address TSO
        call msg "off"
        "Delete" ttermds
        "Alloc f(systerm) ds(*) reuse"
        Address ISPExec
      end
      "Browse Dataset("tlisting")"
      if return_code < 8 then
      if tloadlib <> null then do
        Address TSO
        parse value "" with auth rent
        if tauth = "Yes" then auth = "AC(1)"
        if trent = "Yes" then rent = "RENT REUS"
        if left(tloadlib,1) = "'" ,
          then do
          parse value tloadlib with "'"tloadlib"'"
          linkload = "'"tloadlib"("orig_mem")'"
        end
        else linkload = tloadlib"("orig_mem")"
        print = "'"hlq"."orig_mem".Linklist'"
                               /* site dependent SYSLIBs */
                               /* i.e. SISPLOAD SADMMOD  */
        syslib_free = "N"
        tsyslibs = null
        tsyslib.5 = site_dependent_datasets("tsyslib5")
        tsyslib.6 = site_dependent_datasets("tsyslib6")
        tsyslib.7 = site_dependent_datasets("tsyslib7")
        tsyslib.8 = site_dependent_datasets("tsyslib8")
        tsyslib.9 = site_dependent_datasets("tsyslib9")
        do i = 5 to 9
          tsyslibs = tsyslibs" "tsyslib.i
        end
        tsyslibs = strip(tsyslibs)
        if tsyslib""tsyslibs <> null then do
          "Alloc f(syslib) shr reuse ds("tsyslib  tsyslibs")"
          syslib_free = "Y"
        end
        "Link" tobject "Load("linkload")" auth rent ,
          "Print("print") xref map list let noterm"
        zedsmsg = "RC:" rc
        zedlmsg = "Linkage Editor completed with a return" ,
          "code of" rc
        Address ISPExec
        "Setmsg msg(isrz001)"
        "Browse Dataset("print")"
        Address TSO
        call msg "off"
        "Delete" print
        if syslib_free = "Y" then
        "Free f(syslib)"
      end
      parse value "" with zedsmsg zedlmsg
    end
    if translate(tretain) = "NO" then do
      if tobject  /= null then ,
        _x_ = check_dataset(""tobject  " DELETE")
      if tlisting /= null then ,
        _x_ = check_dataset(""tlisting " DELETE")
    end
    If find(types_libdef,type) > 0 then do
      Call destroy_libdefs    /* Clean up temp library        */
    end
  end

/* ---------------------------------------------------- *
 * If CLIST or EXEC then:                               *
 * -> Check the Trap variable and setup outtrap if 1    *
 * -> Altlib CLIST or EXEC library                      *
 * -> Execute the member passing any passed parms       *
 * -> Save the return code                              *
 * -> Free the Altlib                                   *
 * -> if trap is 1 then view outtrap                    *
 * ---------------------------------------------------- */
  If pos(type,"REXX CLIST") > 0 then do
    Address TSO
    "Altlib Activate Application("alt_type")" ,
      "Dataset('"dataset"')"
    if trap = 1 then call outtrap 'trap.'
    "%"member parms
    return_code = right(rc,4,'0')
    if trap = 1 then call outtrap 'off'
    "Altlib Deactivate Application("alt_type")"
    xrc = right(D2X(return_code),4,'0')
    zedsmsg = "RC:" return_code
    zedlmsg = orig_mem" has been executed and ended with a",
      "return code of" return_code "(x'"xrc"')" ,
      left(" ",20) zerrlm
    Address ISPExec
    'setmsg msg(isrz001)'
    if trap = 1 then do
      tdd = 'TRY'random(9999)
      Address TSO
      'alloc f('tdd') new spa(15,15) tr recfm(v b) lrecl(128)'
      'execio * diskw 'tdd '(finis stem trap.'
      Address ISPExec
      'lminit dataid(ddb) ddname('tdd')'
      'view dataid('ddb')'
      'lmfree dataid('ddb')'
      Address TSO 'Free f('tdd')'
    end
  end

/* ---------------------------------------------------- *
 * If JCL then:                                         *
 *   - test for JCL_Check                               *
 *     - if null then message                           *
 *     - otherwise invoke it                            *
 * ---------------------------------------------------- */
  If pos(type,"JCL") > 0 then do
    if strip(jcl_check) = null then do
      zedsmsg = "Not Supported"
      zedlmsg = "There is no JCL Syntax Checker defined" ,
        "so this command will not work with JCL."
      Address ISPExec
    end
    else do
      Address ISREdit JCL_Check
      return_code = rc
      zedsmsg = "RC:" return_code
      zedlmsg = orig_mem" has been syntax checked"
      Address ISPExec
    end
  end

  If pos(type,"SKL") > 0 then do
    save_address = ADDRESS()
    ADDRESS ISPEXEC
    "CONTROL ERRORS CANCEL"
    "FTCLOSE"
    "FTOPEN TEMP"
    "FTINCL " member
    return_code = rc
    "FTCLOSE"
    "LIBDEF ispslib "
    call msg 'off'
    Address TSO "Free f("ispfddt")"
    Address TSO "Free f("ispfddo")"
    if return_code > 0 then do
      zedsmsg = zerrsm
      zedlmsg = zerrlm
    end
    else do
      zedsmsg = "RC: 0"
      zedlmsg = "ISPF SKEL" orig_mem "has successfully" ,
        "been tested by the ISPF Display Service."
    end
    " vget ( ztempf ztempn )"
    ztempdsn = "'"ztempf"'"
    ztempdd  =    ztempn
    "lminit dataid(idtemp)    ddname("ztempdd") enq(shr)"
    "edit   dataid("idtemp")  "
    "lmfree dataid("idtemp")"
    ADDRESS value(save_address)
  end

/* ------------------------------------- *
 * For ISPF Panels:                      *
 *  -> Return errors to us               *
 *  -> build the panel lib and libdef    *
 *  -> If parms POP passed then ADDPOP   *
 *  -> If parms SEL then Select instead  *
 *     of Display                        *
 *  -> If parms TUT then call ISPTUTOR   *
 *  -> Display the ISPF Panel            *
 *  -> save the return code              *
 *  -> REMPOP if applicable              *
 *  -> Free the Libdef                   *
 * ------------------------------------- */
  if type = "PANEL" then do
    'vget (zscreenw)'
    parms = translate(parms)
    if wordpos("APPL",parms) > 0 then do
      w = wordpos("APPL",parms)
      appl = word(parms,w+1)
      newappl = 'Newappl('appl')'
    end
    Address ISPExec
    if appl = null then do
      "Vget (Zapplid)"
      appl = zapplid
    end

    if wordpos("POP",parms) = 0 then
    if wordpos('TUT',parms) = 0 then do
      Address ISREdit "Find 'WINDOW(' First"
      if rc = 0 then do
        'Addpop'
        popup = 1
      end
    end

    if wordpos("POP",parms) > 0 then do
      parse value parms with . 'POP' row col .
      if strip(row) /= null then pp = 'row('row')'
      if strip(col) /= null then pp = 'row('row') column('col')'
      "Addpop" pp
      popup = 1
    end

    if wordpos("SEL",parms) > 0 ,
      then "Select Panel("member") Passlib" ,
      "Newappl("appl")"

    else if wordpos("TUT",parms) > 0 ,
      then do
      if wordpos("APPL",parms) > 0 then do
        w = wordpos("APPL",parms)
        appl = word(parms,w+1)
        newappl = 'Newappl('appl')'
      end
      "Select pgm(isptutor) parm("member")" newappl
    end
    else do
      Address ISREdit "Find ')MODEL' First"
      if rc = 0 then table = 'T'time('s')
    if table = null
        then "Display Panel("member")"
    else do
         'TBCreate' table 'names(a b c) nowrite'
         'TBDispl' table 'Panel('member')'
         zedsmsg = zerrsm
         zedlmsg = zerrlm
         if rc > 0 then 'setmsg msg(isrz001)'
         'TBEnd' table
         end
    end

    return_code = rc

    if popup = 1 then "Rempop"
    "Libdef ISPPLIB"
    call msg 'off'
    Address TSO "Free f("ispfddt")"
    Address TSO "Free f("ispfddo")"
    if return_code > 0 then do
      zedsmsg = zerrsm
      zedlmsg = zerrlm
    end
    else do
      zedsmsg = "RC: 0"
      zedlmsg = "ISPF Panel" orig_mem "has successfully" ,
        "been tested by the ISPF Display Service."
    end
  end

/* ------------------------------------------------- *
 * Now issue any messages and then test for any temp *
 * member.                                           *
 *                                                   *
 * If no temp member then exit                       *
 * If temp member then delete it and exit            *
 * ------------------------------------------------- */
  Address ISPExec
  if table = null then
  "Setmsg msg(isrz001)"

  /*  clean up - delete tempmem member */
  If temp <> 1 then exit 0

  Address ISPExec
  "LMInit  Dataid(tryit)   Dataset('"dataset"') enq(shrw)"
  "LMOpen  Dataid("tryit") Option(Output)"
  "LMMDel  Dataid("tryit") Member("tempmem") NoEnq"
  "LMClose Dataid("tryit")"
  "LMFree  Dataid("tryit")"

  Exit 0

/* ----------------------------------------------*
 * Find_Temp:  - routine to generate a temporary *
 * member name if temp_opt is set to 0.          *
 * Try 10 times for available member name        *
 * --------------------------------------------- */
Find_Temp:
  do try = 1 to 10
    tempmem = "ZYX"Random(999)
    if sysdsn("'"dataset"("tempmem")'") = "MEMBER NOT FOUND"
    then return 0
  end

  zedsmsg = "Severe Error"
  zedlmsg = "Tryit attempted to allocate a temporary member" ,
    "to test" member "and was unsuccessful. Contact" ,
    "systems programming."
  Address ISPExec
  "Setmsg msg(isrz001)"
  Exit 8

/* --------------------------------------------------------*
 * *custom*                                                *
 * site dependent datasets                                 *
 *   MACLIBs                                               *
 *   SYSLIBs  i.e. SISPLOAD SADMMOD                        *
 * ------------------------------------------------------- */
site_dependent_datasets: procedure expose null
  s_dsn = null
  PARSE UPPER ARG s_type .
  select
    when (s_type="TMAC5"    ) then s_dsn=null
    when (s_type="TMAC6"    ) then s_dsn=null
    when (s_type="TMAC7"    ) then s_dsn=null
    when (s_type="TMAC8"    ) then s_dsn="'SYS1.MACLIB'"
    when (s_type="TMAC9"    ) then s_dsn="'SYS1.MODGEN'"
    when (s_type="TSYSLIB5" ) then s_dsn=null
    when (s_type="TSYSLIB6" ) then s_dsn=null
    when (s_type="TSYSLIB7" ) then s_dsn=null
    when (s_type="TSYSLIB8" ) then s_dsn="'isp.sispload'"
    when (s_type="TSYSLIB9" ) then s_dsn="'GDDM.SADMMOD'"
    OTHERWISE NOP
  end
 /* mvs_sysplex = MVSVAR("SYSPLEX")  */
 /* mvs_sysname = MVSVAR("SYSNAME")  */
 /* site dependent LIBs */
  RETURN s_dsn

/* ----------------------------------------------*
 * check existence of dataset                    *
 *   optionally delete / hdelete                 *
 * --------------------------------------------- */
check_dataset: procedure expose null
  PARSE ARG listc_entry action_to_do .
  volser = null
  "NEWSTACK"
  x = outtrap("listc.",'*',"noconcat")
  ADDRESS TSO "LISTC ENTRY(" listc_entry ") VOLUME"
  listc_rcode = RC
  x = outtrap("OFF")
  "DELSTACK"
  rcode = listc_rcode
  IF listc_rcode = 0 ,
    THEN DO
          /* format: VOLSER------------volid      DEVTYPE-- ... */
    DO i = 1 to listc.0
      line_part1  = TRANSLATE(WORD(listc.i,1)," ","-")
      IF WORD(line_part1,1) /= "VOLSER" then iterate
      volser = WORD(line_part1,2)
      LEAVE
    END
  end
  if volser /= "" then
  do
    select
      when ( action_to_do = "DELETE" ) then ,
        do
        msg_save = msg("OFF")
        if left(volser,3) =" MIG" ,
          then ADDRESS TSO "HDELETE "listc_entry" WAIT"
        else ADDRESS TSO " DELETE "listc_entry" "
        msg_reset  = msg(msg_save)
      end
      otherwise nop
    end
  end
  RETURN rcode

/**************************************************************
* check generic                                               *
***************************************************************/
sub_generic_llq: procedure expose null ,
    clist rexx asm jcl panel skl
  parse arg _llq_  .
  _type_ = null
  n=0
  n=n+1;gentyp.n.1 = clist    ;gentyp.n.2 = word(gentyp.n.1,1)
  n=n+1;gentyp.n.1 = rexx     ;gentyp.n.1 = word(gentyp.n.1,1)
  n=n+1;gentyp.n.1 = asm      ;gentyp.n.2 = word(gentyp.n.1,1)
  n=n+1;gentyp.n.1 = jcl      ;gentyp.n.2 = word(gentyp.n.1,1)
  n=n+1;gentyp.n.1 = panel    ;gentyp.n.2 = word(gentyp.n.1,1)
  n=n+1;gentyp.n.1 = skl      ;gentyp.n.2 = word(gentyp.n.1,1)
  gentyp.0 = n
  _found_ = "NO"
  do idxg = 1 to gentyp.0
    do idxw = 1 to words(gentyp.idxg.1)
      type_value = word(gentyp.idxg.1,idxw)
      if left(type_value,1) = "*" ,
        then nop
      else iterate
      parse var type_value 1 . "*" type_value .
      if right(_llq_,length(type_value)) = type_value ,
        then do
        _type_ = word(gentyp.idxg.1,1)
        _found_ = "YES"
        leave
      end
    end
    if _found_ = "YES" then leave
  end
  return _type_

/**************************************************************
* Trap uninitialized variables                                *
***************************************************************/
Sub_Novalue:
  Say "Variable" ,
    condition("Description") "undefined in line" sigl":"
  Say sourceline(sigl)
  if sysvar("sysenv") <> "FORE" then exit 8
  say "Report the error in this application along with the",
    "syntax used."
  exit 8

/********************** setup_libdefs ********************************/
setup_libdefs: Procedure Expose ddname /* Create and populate temp   */
                                       /* data set and libdef to it  */
  ddname = '$'right(time("s"),7,"0")     /* create unique ddname       */
                                       /* Allocate data set          */
  Address tso "ALLOC NEW DEL F("ddname") DIR(1) SP(1) TR RECF(F B) ",
    "BLKS(0) LRECL(80) REU"
  Address ispexec
  'LMINIT DATAID(DID) DDNAME('ddname') ENQ(EXCLU)'
  'LMOPEN DATAID(&DID) OPTION(OUTPUT)'
  a=sourceline()  /* get last line */

/* now try to find the start of the panel */
  do al = a to 1 by -1
    line = sourceline(al)
    a = al
    if left(line,8) = "/*MEMBER" then leave
  end

  Do 1                                 /* read and create 1 member(s)  */
    Do a=a to 9999 Until substr(line,1,8)='/*MEMBER'
      line = sourceline(a)
    End
    Parse Var line . memname .
    Do a=a+1 to 9999 While substr(line,1,2) /= '*/'
      line = sourceline(a)
      'LMPUT DATAID(&DID) MODE(INVAR) DATALOC(LINE) DATALEN(80)'
    End
    'LMMADD DATAID(&DID) MEMBER(&MEMNAME)'
  End
  'LMFREE DATAID(&DID)'
  "LIBDEF ISPPLIB LIBRARY ID("ddname") STACK" /* LIBDEF panels */
  Return

/************************ DESTROY_LIBDEFS ***************************/
destroy_libdefs:
  Address ispexec 'LIBDEF ISPPLIB '  /* Remove Panels libdef         */
  Address tso 'FREE F('ddname')'     /* Free and delete temp file    */
  Return

/*------------------------------------------------------------------*/
/* In-line panels and messages are defined below                    */
/*------------------------------------------------------------------*/

/*MEMBER TRYITASM This is a panel ...
)ATTR  FORMAT(MIX)
 @  TYPE(NT)
 [  TYPE(PT)
 ]  TYPE(CH)
 $  TYPE(FP)
 {  TYPE(DT)
 ~  AREA(SCRL) EXTEND(ON)
 `  TYPE(Input) CAPS(ON) PADC(USER)

)BODY  CMD(ZCMD)
@                     [       Try20 Assembler Dialog    @                      @
$Command ===>`Z                                                                @
~SAREA38                                                                       ~
)AREA SAREA38
@
]Assembler options:]                                                           @
@@$Term  . . .`Z     @{(TERM or NOTERM)@
@@$Rent  . . .`Z  @   {(YES  or NO)    @
@@$Other . . .`Z                                                            @
@
]Additional Macro Libraries:](* to include active dataset)                     @
]Maclib$===>`tmac1                                                            @
@ @$    ===>`tmac2                                                            @
@ @$    ===>`tmac3                                                            @
@ @$    ===>`tmac4                                                            @
@
]Linkage Editor Options:](in addition to assembler rent)
@@$Auth  . . .`Z  @   {(YES or NO - AC=1)  @
@@$Other . . .`tlink                                                        @
@
]Syslib$===>`tsyslib                                                          @
]Load  $===>`tloadlib                                                         @
@           (If blank then no link will be performed)                         @
@                                                                             @
@Retain Listing and Obj Data Sets$===>`z  @ {(YES or NO)     @                @
@                                                                             @
)Init
 .zvars = '(Zcmd tterm trent tother tauth tretain)'
 .cursor = zcmd
 &tauth = trans(trunc(&tauth,1) y,Yes n,&z Y,Yes N,No &z,No)
 &trent = trans(trunc(&trent,1) y,Yes n,&z Y,Yes N,No &z,No)
 &tterm = trans(trunc(&tterm,1) T,Term &z,Term N,Noterm t,Term n,Noterm)
 &tretain = trans(trunc(&tretain,1) y,Yes n,&z Y,Yes N,No &z,No)
 if (&tmac1 = &z)
     &tmac1 = '*'
)Proc
 &tauth = trans(trunc(&tauth,1) y,Yes n,&z Y,Yes N,No *,*)
 &trent = trans(trunc(&trent,1) y,Yes n,&z Y,Yes N,No *,*)
 &tterm = trans(trunc(&tterm,1) T,Term &z,Term N,Noterm t,Term n,Noterm *,*)
 &tretain = trans(trunc(&tretain,1) y,Yes n,&z Y,Yes N,No &z,No *,*)
 ver (&tterm,nb,list,Term,Noterm)
 ver (&trent,list,Yes,No)
 ver (&tauth,list,Yes,No)
 ver (&tretain,list,Yes,No)
 if (&tmac1 NE *)
     ver (&tmac1,dsnameq)
 if (&tmac2 NE *)
     ver (&tmac2,dsnameq)
 if (&tmac3 NE *)
     ver (&tmac3,dsnameq)
 if (&tmac4 NE *)
     ver (&tmac4,dsnameq)
 ver (&tlink,dsnameq)
 ver (&tsyslib,dsnameq)
 ver (&tloadlib,dsnameq)
)End
*/
