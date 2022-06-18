  /* --------------------  rexx procedure  -------------------- */
  pdsegver = pdsegver()
  /* Name:      pdsegen                                         *
  *                                                            *
  * Function:  Display a PDSE member list with generations     *
  *            and allow Browse, Edit, View on all members     *
  *                                                            *
  * Syntax:    %pdsegen  dsn filter SET=x \ flags              *
  *                                                            *
  * If a dataset name is not provided then a prompting panel   *
  * will be displayed.                                         *
  *                                                            *
  * If a dataset name of * is provided then the PDSEGEN        *
  * change dataset selection list will be displayed.           *
  *                                                            *
  * If a dataset name of ? is provided then the ISPF Tutorial  *
  * will be presented and when the tutorial ends the dialog    *
  * will start.                                                *
  *                                                            *
  * filter is any valid member name filter or a date filter.   *
  *                                                            *
  * SET defines the default Select option (B,E,V,/)            *
  * If not specified then will use the default or the          *
  * value set using the dialog or the SET command.             *
  *                                                            *
  * SET= may be anywhere in the parameters                     *
  *                                                            *
  * flags may be Time to enable time reporting or HIGEN        *
  * to display HIGEN members, or both.                         *
  *                                                            *
  * If flags is E or Edit then if the member name has no mask  *
  * then the member will be edited.                            *
  *                                                            *
  * Note: Must be started in any ISPF APPLID other than PDSE   *
  *       so that the ISPF command table can be built and      *
  *       then the exec is reinvoked under the PDSE APPLID.    *
  *                                                            *
  * Commands:  Backup the PDSE with generations                *
  *            Browse member                                   *
  *            C or C dsname to change to another PDSE         *
  *            HIGEN to add HIGEN members to the display       *
  *              or HIGEN ? to display short tutorial          *
  *            Compare member from-mem to-mem                  *
  *            Copy to copy current PDSE to another/new PDSE   *
  *            Edit member                                     *
  *            Filter member-mask (*x, x*, x:, x/ or /x or OFF *
  *            Find 'string'                                   *
  *            GENOnly - hide all base members (toggle)        *
  *            Hide - hide all generations (toggle)            *
  *            ID char(s) - display only members with the      *
  *                         characters.                        *
  *            Info to display info on the dataset (PDSE only) *
  *            Locate member or member*                        *
  *            MIne - display only active users members        *
  *            Model - Allocate a new dataset based on the     *
  *                  allocation info of the active dataset     *
  *            OPtions to prompt for a PDSEGEN command         *
  *            Output to create a file with all members and    *
  *                   information                              *
  *            Prune to remove old generations                 *
  *                  or to delete ALL members/generations      *
  *            Reflist - List last 30 data sets referenced to  *
  *                  select a data set from                    *
  *            Refresh - rebuild the member list               *
  *            Reset is an alias of Refresh that isn't doc'd   *
  *            Restore - restore a backup pdse                 *
  *            S member (alias of Edit member)                 *
  *            Set to change the action for the S line option  *
  *            Sort Create, Change, Size, or Userid A/D        *
  *              - only one at a time                          *
  *              - A for ascending and D for descending        *
  *            Submit - to submit a member or members          *
  *            Validate using IEBPDSE                          *
  *              - if clean is enabled in PDSEGENS then the    *
  *                validate will also force a clean for all    *
  *                pending deletes.                            *
  *            View member                                     *
  *            Today, Week, Month, Year, Since yy/mm/dd,       *
  *                Since -nn, Since day  (toggles)             *
  *                                                            *
  * Selection options:                                         *
  * Short - Long - Description                                 *
  * A Attrib   - Attributes (Ver/Mod/Userid) (gen 0 only)      *
  * B Browse   - Browse                                        *
  * C COPy     - Copy a member to another PDSE/PDS (gen 0 only)*
  *            - Will also copy all generations                *
  * D Delete   - Delete                                        *
  * E Edit     - Edit     (for gen 0 only)                     *
  *              converted to V for non-0 gen                  *
  * G RECover  - Recover  (for non-0 generations)              *
  * H Hide     - Hide the current row                          *
  * I Info     - display Info on the individual member/gen     *
  * J Submit   - Submit the member (JCL) to the internal       *
  *              reader                                        *
  * K Klone    - Clone the member (gen 0 only)                 *
  *   CLone      generations are not cloned                    *
  * M MAil     - Mail the member (if enabled)                  *
  * P Promote  - Promote  (for non-0 generations)              *
  * R REName   - reName the member and all generations         *
  *            - prompt for option                             *
  * S Select   - Select   (based on the prompt panel           *
  * U User     - User command                                  *
  * V View     - View                                          *
  * X EXecute  - eXecute the member (rexx only)                *
  * Z COMpare  - Compare  (for gen 0 to non-0 generation)      *
  * /          - prompt for option                             *
  * =          - repeat last used line command                 *
  *                                                            *
  * Notes:                                                     *
  *   0. Generation browse/edit/view only works with z/OS 2.1  *
  *      and later.                                            *
  *   1. Multiple members may be selected for Browse or View   *
  *      but Edit will only work if the member IS NOT          *
  *      saved or updated.  If a member is saved or updated    *
  *      then all rows for that member are deleted and         *
  *      re-added to include the updated generation info.      *
  *   2. It shouldn't have to be stated but generations are    *
  *      only supported for PDSE Version 2 datasets where      *
  *      generations have been enabled.                        *
  *   3. Promote will take the specified generation and have   *
  *      it replace the base generation.                       *
  *   4. Recover will take the specified generation and prompt *
  *      for a new member to copy it into.                     *
  *   5. Refresh will completely rebuild the member list.      *
  *   6. The Compare command will ONLY accept relative         *
  *      generations number (e.g. -n)                          *
  *   7. The Locate command uses tbskip and compare to get     *
  *      close to the requested member if an exact isn't found *
  *   8. The mail option must be enabled - see PDSEGENS exec.  *
  *   9. The elapsed time display may be enabled or disabled   *
  *      see PDSEGENS exec.                                    *
  *  10. The COPY function uses the PDSEGENC exec for the      *
  *      processing.                                           *
  *  11. Aliases are NOT support by this application.          *
  *  12. If you prefer to show HIGEN members to your users     *
  *      then update PDSEGENS to change the HIGEN variable     *
  *      to 1.                                                 *
  *  13. Filter will limit the members, with their generations *
  *      that are displayed.                                   *
  *         x: will filter for members starting with x         *
  *         x/ will filter for members with x anywhere         *
  *         /x will filter for members with x anywhere         *
  *         % will match any single character                  *
  *         * will match any number of characters              *
  *         /x will filter for members with x anywhere         *
  *         OFF will turn off filtering                        *
  *  14. Find searches all members in the member display. To   *
  *      speed up the find use a filter before find            *
  *  15. When Hide is active, Delete, Prune, and Rename are    *
  *      not available.                                        *
  *                                                            *
  * Author:    Lionel B. Dyck                                  *
  *            lbdyck@gmail.com                                *
  *                                                            *
  * Acknowledgement: Thanks to Thomas Reed of IBM for his      *
  *                  presentation at SHARE Session 16957 at    *
  *                  Seattle 2015                              *
  *                                                            *
  *                  MAJOR thanks to John Kalinich, Bill Smith,*
  *                  and Bruce Koss for their testing and      *
  *                  constructive feedback on this tool        *
  *                                                            *
  *                  Thanks to John Kalinich for many useful   *
  *                  contributions to the code.                *
  *                                                            *
  *                  Special THANKs to Greg Price for updating *
  *                  a REXX Function from Rem Perretta via     *
  *                  Xephon to provide the PDSE generation     *
  *                  info and to John Kalinich who helped me.  *
  *                                                            *
  *                  Special THANKs to Salvador Carrasco whose *
  *                  code, IRXF@MAT, I found on CBT File 386   *
  *                  and have incorporated as PDSEGMAT.        *
  *                                                            *
  * History:                                                   *
  *          06/15/22 - v6.0.1 - Fix day check for since       *
  *          06/14/22 - v6.0.0 - Fix typo for thurSday :(      *
  *          06/06/22 - v5.9.9 - Support day of week for filter*
  *                              e.g. Friday                   *
  *          05/02/22 - v5.9.7 - Dynamically calculate size of *
  *                              temp file used for gen access *
  *          04/27/22 - v5.9.6 - Change REFRESH to retain      *
  *                              active filters                *
  *          04/12/22 - v5.9.5 - Support SINCE day (Sun, ...)  *
  *          04/07/22 - v5.9.4 - Support YESTERDAY filter      *
  *          12/05/21 - v5.9.2 - Move numeric digits to top of *
  *                              the code                      *
  *          05/24/21 - v5.9.1 - Fix bug with S MINE processing*
  *                            - Change do_zcmd to select/when *
  *          04/26/21 - v5.9.0 - Allow short dataset names on  *
  *                              prompt panel                  *
  *          02/25/21 - v5.8.9 - Clean up the do_find for PDS  *
  *                              and PDSE without gens         *
  *          02/23/21 - v5.8.8 - Fix typo in msel unknown msg  *
  *          02/17/21 - v5.8.6 - Fix return from PDSEGDSL if 0 *
  *          12/14/20 - v5.8.5 - Correct return if recfm=u     *
  *          09/17/20 - v5.8.3 - Enhance cursor location       *
  *          08/11/20 - v5.8.2 - Free MODEL allocation         *
  *          08/07/20 - v5.8.1 - Support dsname(mem)           *
  *          08/03/20 - v5.8.0 - Fix bug if invalid dsn        *
  *          08/02/20 - v5.7.9 - Add SETMSG if C dsn invalid   *
  *          07/26/20 - v5.7.7 - Add TPC command to invoke PDS *
  *                            - Change ? to use new PDSEGDSL  *
  *                            - Support PDSEGENS MaxHist var  *
  *          07/09/20 - v5.7.6 - Correct bug Edit new member   *
  *          06/03/20 - v5.7.4 - Remove member cursor and fix  *
  *                              bugs introduced by that       *
  *          06/02/20 - v5.7.3 - Correct Scrolling bug         *
  *          06/01/20 - v5.7.2 - Correction for member cursor  *
  *          05/27/20 - v5.7.1 - Fix cursor positioning        *
  *          04/22/20 - v5.7.0 - Support flag of E/Edit        *
  *                            - Add flag of *Kloned for the   *
  *                              cloned member (eye catcher)   *
  *                            - Update to support use of      *
  *                              Compare with SAVELAB          *
  *          03/09/20 - v5.6.7 - Fix code bug in Model         *
  *                            - If invalid line command report*
  *          03/02/20 - v5.6.6 - New option to use Action Bar  *
  *          02/28/20 - v5.6.5 - New option to use Action Bar  *
  *                              panels on SET menu.           *
  *                            - Action Bars are now default   *
  *          01/31/20 - v5.6.4 - Implement an Initial Edit     *
  *                              Macro by dataset suffix       *
  *                              Commands: SETMACRO or SM      *
  *          01/18/20 - v5.6.3 - Prevent Copy from/to the same *
  *                              dataset.                      *
  *          01/08/20 - v5.6.2 - Enable G (Recover) on Orphan  *
  *                              member base 0 (agen >0)       *
  *          12/11/19 - v5.6.1 - Add AGE command (thx JK)      *
  *          11/18/19 - v5.6.0 - Change ISRZ002 to ISRZ003     *
  *                            - Fix E XX (new member) issue   *
  *          10/10/19 - v5.5.9 - Correction to mod size parse  *
  *                            - Improve PFSHOW routine        *
  *                            - Clean up Z compare process    *
  *                            - Allow C 'dsname and add close *
  *                              quote.                        *
  *          08/21/19 - v5.5.7 - Add setmsg after b/e/v        *
  *                            - Enable Find for non-MG DS     *
  *                            - Support filter from:to        *
  *                            - Correct Sort ID               *
  *                            - Support filter (x y z) with   *
  *                              masking                       *
  *                            - Correct INIT sorting          *
  *          07/22/19 - v5.5.6 - Allow Options abbrev of O     *
  *          06/25/19 - v5.5.5 - Check Backup return code      *
  *                            - Fix C * after using REFList   *
  *                            - Fix E XX if filter X/ and XX  *
  *                              does not exist (yet)          *
  *          06/05/19 - v5.5.4 - Add REFLIST command (thx JK)  *
  *                            - Change disp_change (PDSEGENS) *
  *          04/29/19 - v5.5.3 - Correct entry/exit processing *
  *          04/27/19 - v5.5.2 - Restore * calling parm        *
  *          04/24/19 - v5.5.1 - Improve Prefix/Noprefix use   *
  *                            - Add option T (for Tryit)      *
  *          03/07/19 - v5.5.0 - Add Row/Column to Addpops     *
  *                            - Add Addpop for panel PDSEGENI *
  *                            - Improved msgs for Block cmds  *
  *          02/22/19 - v5.4.9 - Update msg options if zOSOK   *
  *          12/31/18 - v5.4.8 - Small change from JK if the   *
  *                              requested data set is not     *
  *                              RECFM F or V.                 *
  *          12/20/18 - v5.4.7 - Change call to XMITIPFE (mail)*
  *                              to ISPF Select so that if     *
  *                              mail not installed can get    *
  *                              error message.                *
  *          12/19/18 - v5.4.6 - Correction to message when    *
  *                              browsing a PDSE with MAXGEN   *
  *                              of zero                       *
  *          10/22/18 - v5.4.4 - Add ID and MINE commands      *
  *                            - Correct support for 8 char    *
  *                              userids (thx JK)              *
  *          08/22/18 - v5.4.3 - Small update to eliminate     *
  *                              setmsg after edit if rc <= 4  *
  *          04/30/18 - v5.4.0 - Add Numeric Digits 10 for     *
  *                              system limit check (thx Marv) *
  *                            - Clean up the member Info disp *
  *                            - Renamed table panels and added*
  *                              a set with and without the    *
  *                              absolute generation number    *
  *          04/12/18 - v5.3.1 - Fix edit cancel that was      *
  *                              broken with 5.3.0             *
  *          04/10/18 - v5.3.0 - Require REST instead of RES   *
  *                              for Restore                   *
  *                            - Change RESET to an alias of   *
  *                              Refresh instead of Prune      *
  *                            - Change USER column to ID      *
  *                              and change SORT USER to ID    *
  *                            - Allow F instead of FIN        *
  *                              for Find                      *
  *                            - Find will now also find string*
  *                              in the member name            *
  *                            - Improve filter time if the    *
  *                              filter ends in *              *
  *                            - Improve filter time if the    *
  *                              filter starting with *        *
  *                            - Correct intial panel prompt   *
  *                              failure if a filter is used   *
  *                            - Update for z/OS 2.1 for scroll*
  *                              returning command table       *
  *          04/03/18 - v5.2.3 - Check member name from status *
  *                              field for validity (G, K, R)  *
  *                            - For G, K, and R make sure the *
  *                              target member does not exist  *
  *                            - Clean up logging messages     *
  *          03/31/18 - v5.2.2 - Add RenSwap or Q to support   *
  *                              Rename Swap for a member      *
  *                            - correct bug in  dsn parse     *
  *          03/27/18 - v5.2.1 - Correct TBSort typos          *
  *                            - Add IBM FileManager variable  *
  *          03/26/18 - v5.2.0 - Improve performance           *
  *                              - initial table build         *
  *                              - replace tbmod with tbput    *
  *                              - remove ORDER from TBADD     *
  *                              - eliminate extra call to     *
  *                                table rebuild on mbr changes*
  *                            - Check for Dummy flag from geni*
  *                            - E mask will only work on gen 0*
  *                            - Support B/V/E * -n            *
  *                            - Clean up to retain last opt   *
  *                              after an Edit                 *
  *                            - For HIGen check for dummy gen *
  *                              flag from pdsegeni            *
  *                            - Fix OUTPUT alignment          *
  *                            - Fix Sort size, init, mod      *
  *          03/09/18 - v5.1.8 - Add logging of startup        *
  *                            - minor code cleanup            *
  *                            - Add more comments             *
  *                            - Remove PDSECMDS table and use *
  *                              CONTROL LRSCROLL command      *
  *                            - Remove HELP primary command   *
  *                              as PF1 works just fine        *
  *          02/27/18 - v5.1.7 - Change tbend to tbclose       *
  *                            - Update to new randstr routine *
  *          02/22/18 - v5.1.6 - Change to new random routine  *
  *          02/16/18 - v5.1.5 - Fix to not update the member  *
  *                              list for b/e/v if member not  *
  *                              in the filter                 *
  *                            - Change from random to time(s) *
  *                              to get random variables       *
  *          02/13/18 - v5.1.4 - Fix hlq for OUTPUT command if *
  *                              NOPREFIX in use               *
  *          02/02/18 - v5.1.3 - Support empty pds/pdse        *
  *                            - Enable C > after Model        *
  *                            - Enable Z (compare) on gen 0   *
  *                              to display the Compare prompt *
  *                            - Add short message on unknown  *
  *                              primary and line options.     *
  *                            - Validate Rename target        *
  *                            - Improve Rename prompting      *
  *          01/25/18 - v5.1.2 - Change last used option var   *
  *                              for short and long panels     *
  *          01/24/18 - v5.1.1 - Fix tbvclear error            *
  *                            - Change TBCreate and TBAdds    *
  *          01/04/18 - v5.1.0 - Support C > to change to      *
  *                              the COPY target Dataset       *
  *                            - Check B/E/S/V commands for    *
  *                              a member name/mask            *
  *                            - New OPtions command to prompt *
  *                              for a PDSEGEN command         *
  *                            - Update no generation warning  *
  *                              message                       *
  *                            - Correctly add dsnames to the  *
  *                              dataset list if noprefix      *
  *                            - Display line selection popup  *
  *                              on invalid selections         *
  *                            - Add aliases to FIND for SRCh  *
  *                              and SEArch                    *
  *                            - Correct issue with sort colors*
  *                              for sorted/unsorted columns   *
  *          12/18/17 - v5.0.2 - Allow member name/mask on     *
  *                              a dsname in the comamnd       *
  *                              e.g. sys1.parmlib(ieasys*)    *
  *                            - Correct bug for dslist > 16   *
  *          12/03/17 - v5.0.1 - Change to MODEL (JK) alloc    *
  *                            - Allow opening empty PDS/PDSE  *
  *                            - Log all PDSEGEN commands      *
  *          12/01/17 - v5.0.0 - Change 1 char comamnds:       *
  *                              C (Compare) becomes Z         *
  *                              R (Recover) becomes G         *
  *                              N (reName) becomes R          *
  *                              C will now be COPy to new DS  *
  *                              R will now be REName          *
  *                            - Alloc filter of ? to be       *
  *                              converted to %                *
  *                            - Add MODEL command to allocate *
  *                              a new dataset based on the    *
  *                              active dataset.               *
  *                            - Correct initial sort order    *
  *                            - Change HIGEN relative gen to -*
  *                              a - instead of x'ff'          *
  *                            - Speed up HIGen off process    *
  *                            - Allow non-PDS/PDSE by calling *
  *                              ISPF 3.4 (DSLIST)             *
  *                            - Support 9 character selection *
  *                              and enhance left/right panels *
  *                              rotation                      *
  *                            - Increase DSList from 16 to 25 *
  *                            - Allow any line selection to   *
  *                              be a block command XX/XX or   *
  *                              X99999                        *
  *                            - Support expanded commands     *
  *                            - Support expanded Block cmds   *
  *                              by doubling the 1st character *
  *                            - Expanded commands block by    *
  *                              doubling the 1st character    *
  *                              but no counts allowed         *
  *                            - For Expanded display show full*
  *                              line command selection in     *
  *                              the status field              *
  *                            - Enable the expanded status    *
  *                              field as input and use for    *
  *                              N (rename), K (klone), and    *
  *                              R (recover) to use the status *
  *                              as the target name.           *
  *                            - If user commands have / in the*
  *                              status field then prompt, if  *
  *                              not then just execute passing *
  *                              the dataset(member) or temp   *
  *                              dataset (if generation)       *
  *                            - Add Transfer line selection   *
  *                              to copy to another PDSE/PDS   *
  *                            - Add option (see PDSEGENS) to  *
  *                              display the Changes tutorial  *
  *                              panel when the version changes*
  *          11/08/17 - v4.5.0 - Allow E * with filter         *
  *                              and if filter member doesn't  *
  *                              exist.                        *
  *                            - Support using empty PDS/PDSE  *
  *                            - Fix Time display if cpu=time  *
  *                            - Increase DSList from 15 to 16 *
  *                            - Enable DSList remove for last *
  *                              active dataset                *
  *                            - Remove unexpected SORT with   *
  *                              HIGEN command                 *
  *                            - Fix sort after table change   *
  *          10/20/17 - v4.4.9 - Improve warning message text  *
  *                              when attempts are made to     *
  *                              process a dummy member (jk)   *
  *                            - At close null the zcmd var    *
  *                            - For eXec selection prompt for *
  *                              execution parms               *
  *          10/11/17 - v4.4.8 - Tweaks to clean up code       *
  *                            - Add more info to \ time info  *
  *          09/29/17 - v4.4.7 - Allow copy to dsn on COPY     *
  *                            - Changed RESTORE command to    *
  *                              call PDSEGRST                 *
  *                            - Update member info (I) display*
  *                              with accurate current/init    *
  *                              counts if > 99k               *
  *          09/19/17 - v4.4.6 - Improve the INFo metrics      *
  *                              display with generation info  *
  *                            - Update allocation on COPY to  *
  *                              allow changing space units    *
  *          09/14/17 - v4.4.5 - Additional performance updates*
  *                            - improved pending delete       *
  *                              awareness                     *
  *                            - Performance tweak using tbscan*
  *                              instead of tbskip/compare in  *
  *                              many places                   *
  *          09/05/17 - v4.4.4 - Bug fix to resolve issue with *
  *                              edit command for member that  *
  *                              was deleted outside pdsegen   *
  *          09/01/17 - v4.4.3 - Improve Submit long message   *
  *                              in the case where submit fails*
  *                              And test DCB before Submit    *
  *          09/01/17 - v4.4.2 - Enable B/E/Sub/V on members   *
  *                              not in the active member list *
  *                            - And make them work the way one*
  *                              expects                       *
  *                            - Use pdsegdel for all deletes  *
  *          08/29/17 - v4.4.1 - Enable commands:              *
  *                              B member, B *                 *
  *                              E member, E *                 *
  *                              V member, V *                 *
  *                              by making browse, edit, view  *
  *                              sub-routines                  *
  *                            - New H (hide) line option      *
  *                            - Add SUBmit command            *
  *                              SUB member or SUB *           *
  *                            - Update OUTPUT to use 4 digit  *
  *                              year for dates in the report  *
  *                            - Clean up old change history   *
  *                              entries - see panel PDSEGHCG  *
  *                              for entire history.           *
  *                            - Bug fix if filter find nada   *
  *          08/16/17 - v4.4.0 - Clean up message isrz002 if   *
  *                              pds doesn't have members gens *
  *                            - Clean up message isrz002 after*
  *                              browse in a pds without gens  *
  *          08/14/17 - v4.3.9 - Change to use pdsegver to get *
  *                              the version of the pdsegen    *
  *                              package                       *
  *          07/05/17 - v4.3.9 - Back to using LMMDEL but with *
  *                              LMINIT ENQ(SHRW)              *
  *          07/03/17 - v4.3.8 - Change LMMDEL to TSO Delete   *
  *          06/20/17 - v4.3.7 - Add PFSHOW routine and use    *
  *                              around addpop/rempop          *
  *                            - If line selection unknown then*
  *                              issue msg and change to /     *
  *                            - If PDS/PDSE not generation    *
  *                              enabled use LMMDEL for deletes*
  *          06/12/17 - v4.3.6 - Allow ? for pdsedsn to display*
  *                              the tutorial to start with    *
  *          06/08/17 - v4.3.5 - Fix problem with dsn=* on exit*
  *          05/30/17 - v4.3.4 - Update to set last option for *
  *                              mail                          *
  *          05/19/17 - v4.3.3 - Use Edit Macro Parm instead   *
  *                              if variable pool              *
  *          04/26/17 - v4.3.2 - Fix bug in Dummy detection    *
  *          04/20/17 - v4.3.1 - Add error message if edit     *
  *                              member fails                  *
  *          04/12/17 - v4.3.0 - Support new table member      *
  *                              setting for member position   *
  *                            - Support user color settings   *
  *                            - Enable EDIT * command for the *
  *                              last selected member          *
  *                            - Add GENOnly option            *
  *                            - Correct EDIT MBR Gen use      *
  *                            - Allow VIEW on command like    *
  *                              EDIT                          *
  *          03/21/17 - v4.2.2 - Add flag TIME and HIGEN       *
  *                              and expand time reporting     *
  *                            - Improved test for Dummy       *
  *                              members - only ttr 000000     *
  *                            - Add MULT to TBADD for max     *
  *                              anticipated members           *
  *                            - Add progress flag for copy    *
  *                            - Msg if unknown line cmd       *
  *                            - Support MEMLIST/ML for        *
  *                              Filter alias (from PDS)       *
  *          01/23/17 - v4.2.1 - Add Selection A (base only)   *
  *                            - Allow Exit and Quit on        *
  *                              dataset selection panel       *
  *                            - Clean up delete promote code  *
  *          01/05/17 - v4.2.0 - Update Delete processing to   *
  *                              delete base and promote       *
  *          12/13/16 - v4.1.9 - Version change only           *
  *          12/12/16 - v4.1.8 - If mail=0 then prevent mail   *
  *                              option                        *
  *          12/05/16 - v4.1.7 - Correction for sorting with   *
  *                              extended stats (thanks JK)    *
  *          11/07/16 - v4.1.6 - Allow SET= anywhere in the    *
  *                              parameters                    *
  *          10/25/16 - v4.1.5 - Add 4 digit year fields       *
  *                            - Add Left/Right table command  *
  *                              to switch table for year size *
  *                            - Add PASSLIB to HELP command   *
  *          10/07/16 - v4.1.4 - Allow null default unit       *
  *                            - correct test for ghosts       *
  *                            - After using the dataset list  *
  *                              then return to it to exit     *
  *                            - If enter using dsn prompt     *
  *                              then return to it to exit     *
  *          09/08/16 - v4.1.3 - Check for zdsngen > 0 before  *
  *                              doing generation msgs in b/e/v*
  *                            - Check for zdsngen > 0 before  *
  *                              doing Compare                 *
  *                            - Get def_unit for allocs from  *
  *                              pdsegens                      *
  *                            - Additional test for null      *
  *                              member name as a Dummy mbr    *
  *          09/08/16 - v4.1.2 - Add sort prompt popup         *
  *          09/08/16 - v4.1.1 - version change only           *
  *                            - change short browse/edit msg  *
  *          09/07/16 - v4.1.0 - Clean up from 4.0 and change  *
  *                              from V.R to V.R.M             *
  *                            - Add message for Browse of a   *
  *                              non-0 gen to inform the gen   *
  *                            - Add message for Edit of gen 0 *
  *                            - If C * is used and there is   *
  *                              no previous dsn then display  *
  *                              change DSN list               *
  *                            - If called with a DSN of *     *
  *                              then display change DSN list  *
  *                            - Promote display issue fixed   *
  *                            - Display panel PDSEGFIL popup  *
  *                              for FILTER blank or ?         *
  *                            - Add unknown command message   *
  *                            - Add HIDE command to hide      *
  *                              all generations.              *
  *                            - Change user command to use    *
  *                              select cmd(xx)                *
  *                            - error msg if unknown line     *
  *                              selection option              *
  *                            - Correct Find to handle strings*
  *                            - Add datasets in the change    *
  *                              list will now be fully qual'd *
  *                            - Added date filters Today,     *
  *                              Week, Month, Since yy/mm/dd,  *
  *                              Since -nn, and Year           *
  *                            - Allow both member and date    *
  *                              filters where ever a filter   *
  *                              can be specified.             *
  *                            - Call PDSEGMAT for enhanced    *
  *                              pattern matching (* and %)    *
  *                            - if ttr is x'000000' then it   *
  *                              is a Dummy member so flag it  *
  *                            - Add CLEAR and SORT commands   *
  *                              to change dataset list        *
  *                            - Allow Locate on last sorted   *
  *                              column (default name column)  *
  *                            - Allow SET x on the startup    *
  *                            - Allow S or E member gen       *
  *                            - Add popup if Find blank       *
  *                            - Add filter option on REFRESH  *
  *                            - New PDSEGENS option for prune *
  *                              prompting                     *
  *            08/19/16 - v4.0 - Change Version to 4.0 due to  *
  *                              the number of enhancements    *
  *                            - If Filter in place use for    *
  *                              Copy                          *
  *                            - Add C ? option for a list of  *
  *                              15 previous datasets or C #   *
  *                              to get directly to entry #    *
  *                            - Allow a filter on the C       *
  *                              (change) command              *
  *                            - Improve test of invalid dsn   *
  *                            - Reset Delete Prompt after each*
  *                              group of deletes              *
  *                            - Change default Selection opt  *
  *                              to /                          *
  *                            - Add QUIT and EXIT as commands *
  *                            - Allow option on PRUNE command *
  *                            - Add line selection U          *
  *                            - Message if Filter with blank  *
  *                            - Correction if Edit is canceled*
  *                              on new member to not update   *
  *                              the row with last option.     *
  *                            - If selection is O or / then   *
  *                              display panel PDSEGSLN or     *
  *                              PDSEGSL0                      *
  *                            - Correction for Dummy member   *
  *                              appearing in table after del  *
  *                            - Correction for members/gens   *
  *                              with no stats                 *
  *                            - Reset table title row after   *
  *                              Prune Reset if Filter was on  *
  *                            - Fix rename issue with just    *
  *                              recovered member              *
  *                            - Fix so multiple line commands *
  *                              can be selected at once       *
  *                            - Clean up of last used opt     *
  *            07/18/16 - v3.0 - Add BACKUP and RESTORE cmds   *
  *                            - Change to use Replace for     *
  *                              cut/paste                     *
  *            06/21/16 - v2.0 - Convert to use PDSEGENI REXX  *
  *                              function.                     *
  *                            - Access HIGEN members using P  *
  *                            - Allow D for HIGEN members     *
  *            06/13/16 - v1.0 - First general release         *
  *            05/26/16 - v0.1 - creation                      *
  *                                                            *
  * ---------------------------------------------------------- *
  * Copyright (c) 2017-2020 by Lionel B. Dyck                  *
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
  arg options

  /* -------------------------------- *
  * Check for supported z/OS Release *
  * -------------------------------- */
  parse value mvsvar('sysmvs') with 'SP'level
  if level >= '7.2.1'
  then zOSOK  = 1
  else do
    zerrhm   = 'PDSEGH0'
    zerralrm = 'NO'
    zerrtp   = 'Notify'
    zerrsm  = ''
    zerrlm  = 'This application assists in managing PDSE' ,
      'generations. The release of z/OS that you are' ,
      'running does not support these capabilities.'
    Address ISPExec ,
      'Setmsg msg(isrz003)'
    exit 4
  end
  parse value level with  vv'.'rr'.'mm
  if rr > 1 then if mm < 2 then cmdtbl = 1
  else cmdtbl = 0

  /* -------------------------------------------------- *
  * Test for our ISPF Applid and if not then:          *
  * - re-invoke ourselves with our APPLID              *
  * - upon return exit                                 *
  * -------------------------------------------------- */
  Address ISPExec
  "Vget (Zapplid)"
  "Control Errors Return"
  if zapplid <> "PDSE" then do
    /* --------------------------------------- *
    | Create the ISPF Commands table for PDSE |
    | to enable Left/Right commands           |
    * --------------------------------------- */
    if cmdtbl = 1 then do
      'tbquery pdsecmds rownum('rows')'
      if rc > 0 then do
        "TBCreate pdsecmds names(zctverb zcttrunc zctact zctdesc)",
          "replace share nowrite"
        zctverb  = "RIGHT"
        zcttrunc = 0
        zctact   = "&PDSECMD"
        zctdesc  = "RIGHT for PDSE Dialog"
        "TBAdd pdsecmds"
        zctverb  = "LEFT"
        zcttrunc = 0
        zctact   = "&PDSECMD"
        zctdesc  = "LEFT for PDSE Dialog"
        "TBAdd pdsecmds"
        zctverb  = "HELP"
        zcttrunc = 0
        zctact   = "SELECT PGM(ISPTUTOR) PARM(&ZPARM) NOFUNC NEWAPPL(PDSE)" ,
          "PASSLIB"
        zctact   = translate(zctact)
        zctdesc  = "Help for PDSE Dialog"
        "TBAdd pdsecmds"
        cmdtbl = 1
      end
    end
    callit = sysvar('sysicmd')
    "Select CMD(%"callit options ") Newappl(PDSE)" ,
      "Passlib"
    if cmdtbl = 1 then
    "TBClose pdsecmds"
    exit 0
  end

  /* ------------------------------------------------- *
  * Check for SET= in the options on the start command *
  * ------------------------------------------------- */
  if pos('SET=',options) > 0 then do
    p = pos('SET=',options)
    lf = left(options,p-1)
    rf = substr(options,p+5)
    pdsedo = substr(options,p,5)
    parse value pdsedo with 'SET='pdsedo
    call logit 'Setting:' pdsedo
    'vput (pdsedo) profile'
    options = lf''rf
  end

  /* --------------- *
  | Process options |
  * --------------- */
  parse value options with pdsedsn filter '\' flag

  /* --------------- *
  * Define defaults *
  * --------------- */
  parse value '' with null tfilter tfilterl tfiltert filter_title ,
    save_pdsedsn HIGEN_title metric_table ,
    proc_mems hide_title do_pdsedsl date_filter ,
    date_filter_title gen_hide hide_title ft ,
    date_filterv last_date_filter dfilter ,
    dsn_prompt table_panelo last_mem last_mgen ,
    last_agen first_pass docmd blockcmd ,
    save_bcmd topdse hfilter bypass_tb ,
    update_table open_pdse filter_id ,
    tfilter_from tfilter_to tfilter_list srowcrp
  pdsedd   = randstr()
  pdsegdd  = randstr()
  tblmet   = randstr()
  pdsedelp = 'N'
  zerrhm   = 'PDSEGH0'
  zerralrm = 'NO'
  zerrtp   = 'NOTIFY'
  closed   = 1   /* 1 = closed 0 = open */
  sortcol  = 'NAME'
  sortf = 'mbr,c,'A',mgen,n,d'
  sort.sortcol = 'A'
  date_filter_words = 'SINCE YESTERDAY TODAY WEEK MONTH YEAR' ,
   'SUNDAY MONDAY TUESDAY WEDNESDAY THURSDAY FRIDAY SATURDAY'
  Numeric Digits 10

  /* ----------------------------- *
  * Get the current MAXGENS_LIMIT *
  * ----------------------------- */
  CVT      = C2D(Storage(10,4))
  CVTDFA   = C2D(Storage(D2X(CVT + 1216),4))   /* cvt + 4c0 */
  DFAMGEN  = C2D(Storage(D2X(cvtdfa + 76),4))  /* dfa + 4c */

  /* ----------------------------------------- *
  * Define the default addressing environment *
  * and save the version in the profile pool  *
  * so that the tutorial panels can use it    *
  * ----------------------------------------- */
  Address ISPExec
  'vput (pdsegver)'

  /* -------------------------- *
  | Log the Dataset being used |
  * -------------------------- */
  call logit 'Starting PDSEGEN Version:' pdsegver

  /* --------------------------------------------------- *
  * Call PDSEGENS to setup the local site customization *
  * values for this application.                        *
  * --------------------------------------------------- */
  x = pdsegens()
  parse value x with  mail '/' etime '/' higenf ,
    '/' base_color '/' sort_color '/' clean ,
    '/' prune_prompt '/' tempmem '/' def_unit ,
    '/' def_panel '/' disp_change '/' maxhist
  clean        = strip(clean)
  prune_prompt = strip(prune_prompt)
  tempmem      = strip(tempmem)
  def_unit     = strip(def_unit)
  def_panel    = strip(def_panel)
  base_color   = translate(strip(base_color))
  sort_color   = translate(strip(sort_color))
  if def_unit  /= null then
  def_unit  = 'unit('def_unit')'
  if clean = 1 then valparm = 'clean'
  else valparm = null

  if datatype(maxhist) = 'NUM'
  then 'vput (maxhist) profile'
  else do
    maxhist = 100
    'vput (maxhist) profile'
  end

  'vget (useab tpanel) profile'
  if tpanel = null then tpanel = def_panel
  if useab = null then do
    useab = 'Y'
    'vput (useab) profile'
    call change_panels
  end
  call set_panels
  if left(translate(tpanel),7) /= 'PDSEGED'
     then tpanel = def_panel

  /* --------------------------------------------- *
  | Save mail value so the tutorial panel sees it |
  * --------------------------------------------- */
  'vput (mail)'

  /* --------------------------------------- *
  | Call Proc_Settings for initial defaults |
  * --------------------------------------- */
  call proc_settings 'initial'
  'Vget (clrb clrg clrp clrr clrt clrw clry clrh clrhr' ,
    'sortb sortc pdsetb csrloc changed useab) profile'
  base_color = sortb
  sort_color = sortc
  if changed = 'N'  then
  disp_change = 0

  /* ----------------------------------------------------------- *
  | Check for version change and change display tutorial option |
  | - only check the v.r and ignore the .m                      |
  * ----------------------------------------------------------- */
  'vget (pdselver) profile'
  change_hit = 0
  if disp_change = 1 then
  if left(pdselver,3) /= left(pdsegver,3) then change_hit = 1
  if disp_change = 2 then
  if left(pdselver,5) /= left(pdsegver,5) then change_hit = 1
  if change_hit = 1 then do
    pdselver = pdsegver
    'vput (pdselver) profile'
    'Select pgm(isptutor) parm(pdseghcg)'
  end

  /* --------------------------- *
  | Check for saved Table Panel |
  * --------------------------- */

  /* ------------------------- *
  | Test for any Flag options |
  * ------------------------- */
  if flag /= null then do i = 1 to words(flag)
    if abbrev("CASPER",word(flag,i),1) = 1 then higenf = 1
    if abbrev("ACHMED",word(flag,i),1) = 1 then higenf = 1
    if abbrev("ZOMBIE",word(flag,i),1) = 1 then higenf = 1
    if abbrev("HIGEN",word(flag,i),1)  = 1 then higenf = 1
    if higenf = 1 then HIGEN_title = 'HIGen members'
    if abbrev("TIME",word(flag,i),1)   = 1 then etime  = 1
    if abbrev("EDIT",word(flag,i),1)   = 1 then do
      fm = translate(filter,'&&& ','*%/')
      if pos('&',fm) = 0 then
      editit = 1
    end
  end

Restart:
  if pdsedsn /= null then
  call fixup_pdsedsn
  else if first_pass /= null then exit
  first_pass = 1
  /* ------------------------------------- *
  | Restart processing                    |
  | - test for a member in the dsname     |
  |   - extract and use for a member-mask |
  | - test for a filter (member-mask)     |
  |   - setup the filter processing       |
  * ------------------------------------- */
  if pos('(',pdsedsn) > 0 then do
    if filter /= null then hfilter = filter
    else hfilter = null
    parse value pdsedsn with pdsedsn '('filter')' .
    if left(pdsedsn,1) = "'" then pdsedsn = pdsedsn"'"
    if hfilter /= null then filter = filter
  end
  if pdsedsn /= null then
  if filter /= null then do
    last_date_filter = null
    date_filter = null
    call setup_filter
  end

  /* ----------------------------------------------------- *
  | Set the IBM FileManager variable to allow those sites |
  | with it to use EFIND and ECHG                         |
  * ----------------------------------------------------- */
  crzdsnx = wdsn
  'vput (crzdsnx) shared'

  /* ----------------------------------------------- *
  | Set the flag used to indicate if the dataset is |
  | pdse member generation enabled                  |
  * ----------------------------------------------- */
  zdsngen_first = null

  /* ---------------------------------------------------- *
  * Test for supplied dsname and if none then            *
  * prompt the user for the dsname.                      *
  * ---------------------------------------------------- */
  if pdsedsn = '?' then do
    pdsedsn = null
    'Select pgm(isptutor) parm(pdsegh0)'
  end
  if pdsedsn = '*' then do
    pdsedsn = null
    zcmd = null
    x = pdsegdsl()
    if x /= 0 then do
      pdsedsn = word(x,1)
      if words(x) > 1 then filter = subword(x,2)
      zcmd = 'C' x
      signal restart
      exit 0
    end
    else pdsedsn = null
    zcmd = null
    signal restart
    exit 0
  end
  if pdsedsn /= null then do
    call test_dsn_alias
    if sysdsn(pdsedsn) = 'OK' then do
      call start
      exit 0
    end
    else do
      zerrsm = 'Error'
      zerrlm = pdsedsn sysdsn(pdsedsn)
      'setmsg msg(isrz003)'
      'vput (pdsedsn)'
    end
  end

  'vget (pdsedsn)'
  do forever
    dsn_prompt = 1
    "Display panel(pdsegenp)"
    if rc > 0 then exit
    'vput (pdsedsn pdsedo) profile'
    if pdsedsn = '*' then do
      pdsedsn = null
      'vput (pdsedsn)'
      pdsedsn = pdsegdsl()
      if pdsedsn = 0 then pdsedsn = '*'
      if words(pdsedsn) > 1 then
      parse value pdsedsn with pdsedsn filter
      call close
      signal restart
    end
    if length(pdsedsn) < 9 then
       if pos('.',pdsedsn) = 0
          then do
               call close
               signal restart
               end
    if sysdsn(pdsedsn) /= 'OK' then do
      zerrsm = 'Invalid DSN'
      zerrlm = sysdsn(pdsedsn)
      'Setmsg msg(isrz003)'
    end
    else if pdsedsn /= null then do
      if filter = null then  signal start
      else do
        call setup_filter
        signal start
      end
    end
  end
  Exit 0

Start:
  if etime = 1 then
  x = time('r')
  s_service = sysvar('SYSSRV')
  s_stime   = sysvar('SYSCPU')

  sortcol = 'NAME'
  sort.NAME = 'A'
  parse value '' with lopt lopts msel

  /* ------------------------------------------------------ *
  * Test that the supplied dsname is a valid dataset name. *
  *                                                        *
  * Save the dsname in the ispf profile pool               *
  *                                                        *
  * Create a working variable with a fully qualifed dsname *
  * if the dsname was not by prefixing with either the     *
  * syspref or sysuid.                                     *
  * ------------------------------------------------------ */
  call fixup_pdsedsn
  if sysdsn(pdsedsn) /= 'OK' then do
    zerrsm  = null
    zerrlm  = 'Error.' pdsedsn sysdsn(pdsedsn)
    'setmsg msg(isrz003)'
    return
  end

  /* ------------------------------------- *
  | Get the dataset info using dsinfo and |
  | test for RECFM=U (load library) which |
  | is not supported.                     |
  * ------------------------------------- */
  'dsinfo dataset('pdsedsn')'
  if wordpos(left(strip(zdsrf),1),'F V') = 0 then do
    zerrsm  = 'Error: RECFM='zdsrf
    zerrlm = 'PDSEGEN does not support RECFM='zdsrf
    'setmsg msg(isrz003)'
    "Select PGM(isrdslst) parm(DSL "pdsedsn") suspend scrname(udlist)"
    exit 8
  end

  /* ---------------------------------------------- *
  | If the ZDSNGEN varaible is not set then we are |
  | running on a non supported version of z/OS so  |
  | set the value to 0.                            |
  * ---------------------------------------------- */
  if zdsngen /= 'ZDSNGEN' then  zdsngen = zdsngen + 0
  else zdsngen = 0 /* unsupported level of z/OS */
  'vput (zdsngen)'

  /* --------------------------------------------- *
  | Save the pdse dsn in the profile for next use |
  * --------------------------------------------- */
  'Vput (pdsedsn) Profile'

  /* ------------------------------------ *
  | Update the dataset list with new dsn |
  * ------------------------------------ */
  x = pdsegdsl(pdsedsn)

  /* ------------------------------------ *
  * Define our defaults for this session *
  * ------------------------------------ */
  parse value "" with member ,
    ZLCDATE ZLMDATE ZLVERS ZLMOD ZLMTIME ZLCNORC,
    ZLINORC ZLMNORC ZLUSER

  /* --------------------------------- *
  * Get the default Selection options *
  * --------------------------------- */
  'vget (pdsedo pdsetb)'
  if pdsedo = null then pdsedo = '/'
  if pdsetb = null then pdsetb = 0

  /* ----------------------------------------- *
  * Define the default colors for the columns *
  * ----------------------------------------- */
  call reset_color

  /* ------------------------------------ *
  | Test for DSORG of PO and for Members |
  * ------------------------------------ */
  if zdsorg /= 'PO' then do
    zerrsm  = 'Error'
    zerrlm  = pdsedsn 'is not a PDS or PDSE. Try with' ,
      'another dataset that is a PDS/PDSE.'
    'Setmsg msg(isrz003)'
    return
  end
  if zds#mem = 0 then do
    zerrsm  = 'Warning'
    zerrlm  = pdsedsn 'has no members. Use EDIT to create' ,
      'your first member in this PDS/PDSE.'
    'Setmsg msg(isrz003)'
  end

  /* ------------------ *
  * Define ISPF Dataid *
  * and Allocate       *
  * ------------------ */
  "LMINIT DATAID(pdsegend) DATASET("pdsedsn")"
  "LMOPEN DATAID("pdsegend") OPTION(INPUT)"
  Address TSO ,
    "Alloc f("pdsedd") ds('"wdsn"') shr reuse"

  /* ----------------------- *
  * Now process all members *
  * ----------------------- */
  s_spdsi_service = sysvar('SYSSRV')
  s_spdsi_stime   = sysvar('SYSCPU')
  drop member.
  if zds#mem > 0
  then x=pdsegeni(pdsedd)
  else do
    rc = 0
    member.0 = 0
  end
  xrc = rc
  e_spdsi_stime   = sysvar('SYSCPU')
  e_spdsi_service = sysvar('SYSSRV')
  Address TSO 'Free f('pdsedd')'
  if rc > 7 then do
    zerrsm  = 'Error'
    zerrlm  = 'Error encountered getting PDSE member' ,
      'generation info. RC=' rc
    "Setmsg msg(isrz003)"
    call close
    Exit 0
  end
  mbr = null
  s_ppdsi_service = sysvar('SYSSRV')
  s_ppdsi_stime   = sysvar('SYSCPU')
  call proc_pdsegeni
  e_ppdsi_stime   = sysvar('SYSCPU')
  e_ppdsi_service = sysvar('SYSSRV')
  'tbstats' pdset 'rowcurr(tabr)'
  if tabr = 0 then
  if filter /= null then do
    zerrsm  = 'Error'
    zerrlm  = 'The FILTER' filter 'resulted in zero' ,
      'members being displayed. Issue Filter Off' ,
      'to display all members or try a different' ,
      'dataset.'
    'Setmsg msg(isrz003)'
  end
  call do_sort

  /* ------------------------------------------- *
  * Display the table of members to select from *
  * ------------------------------------------- */
  'tbtop' pdset
  parse  value '0 0 0' with crp rowcrp ztdsels
  if zdsngen_first /= 1 then
  if zdsngen = 0 then do
    zdsngen_first = 1
    zerrsm  = 'No Generations'
    zerrlm  = 'This dataset does not support generations' ,
      'so this dialog will not be as useful as' ,
      'normal ISPF member processing.'
    "setmsg msg(isrz003)"
    zerrlm = null
  end
  if zds#mem = 0 then do
    if left(zdsdsnt,1) = 'L' then dsnt = 'PDSE'
    else dsnt = 'PDS'
    zerrsm  = 'Empty' dsnt
    zerrlm  = 'This dataset is empty. Use Edit to create' ,
      'to create a member in this' dsnt
    "setmsg msg(isrz003)"
    zerrlm = null
  end

  /* ------------------------------------------------ *
  | If the TIME option was enable then collect the   |
  | service units and cpu time used so that it can   |
  | be reported on if the user pressed F1 when the   |
  | short message with processing time is displayed. |
  * ------------------------------------------------ */
  if etime = 1 then do
    e_time = time("E")
    e_stime   = sysvar('SYSCPU')
    e_service = sysvar('SYSSRV')
    parse value e_time with ss "." uu
    numeric digits 6
    mm = ss % 60   /* get minutes integer */
    ss = ss // 60  /* get seconds integer */
    uu = uu // 100 /* get micro seconds integer */
    'tbstats' pdset 'rowcurr(tabr)'
    pwtime  =  right(mm+100,2)':'right(ss+100,2)'.'right(uu+100,2)
    zerrsm  = pwtime
    zerrlm  = ''
    zerrhm  = 'pdsegtim'
    ptgrows = grows
    pttm    =  member.0
    pttabr  = tabr * 1
    ptserv  = e_service - s_service
    ptctime = e_stime - s_stime
    ptsserv = e_spdsi_service - s_spdsi_service
    ptcpu   = e_spdsi_stime - s_spdsi_stime
    ptpserv = e_ppdsi_service - s_ppdsi_service
    ptpcpu  = e_ppdsi_stime - s_ppdsi_stime
    poserv  = ptserv - (ptsserv + ptpserv)
    pocpu   = ptctime - (ptcpu + ptpcpu)
    numeric digits 2
    ptsservp = (ptsserv / ptserv  ) * 100 ||'%'
    ptcpup   = (ptcpu  /  ptctime ) * 100 ||'%'
    ptpservp = (ptpserv / ptserv  ) * 100 ||'%'
    ptpcpup  = (ptpcpu /  ptctime ) * 100 ||'%'
    poservp  = (poserv / ptserv   ) * 100 ||'%'
    if pocpu = ptctime then pocpup = 0'%'
    else pocpup   = (pocpu  / ptctime  ) * 100 ||'%'
    numeric digits 6
    'vput (ptgrows pttm pttabr ptserv ptctime ptsserv ptcpu' ,
      'poserv pocpu poservp pocpup pwtime' ,
      'ptsservp ptcpup ptpservp ptpcpup' ,
      'ptpserv ptpcpu pdsegver) profile'
    zerrhm = 'pdsegh0'
    Address ISPExec
    'setmsg msg(isrz003)'
  end

  /* ------------------------------------- *
  * Now display the ISPF Table of Members *
  * ------------------------------------- */
  call logit 'Opening Dataset:' wdsn 'Maxgens:' strip(zdsngen)
  open_pdse = 1

  do forever
    /* ------------------------ *
    * Define the dynamic title *
    * ------------------------ */
    if strip(filter_title HIGEN_title hide_title date_filter_title) ,
      /= null then ft = 'Filter:' ,
      filter_title date_filter_title HIGEN_title hide_title
    else ft = null

    pdsetitl = 'DSN='wdsn' - MaxGens='strip(zdsngen)  ft

    if editit = 1 then do
      zcmd = 'E' filter
      editit = null
      call do_command 'E'
    end

    /* ----------------- *
    * Display the table *
    * ----------------- */
    if bypass_tb = null then do
      zcmd    = null
      if cmdtbl = 0
      then 'CONTROL PASSTHRU LRSCROLL PASON'
      else  pdsecmd = 'PASSTHRU'
      parse value '' with zerrsm zerrlm proc_mems clinecmd
      if ztdsels > 1 then src = 4
      else src = 0
      if src = 4 then "TBDispl" pdset
      else do
      if srowcrp /= null then do
         rowcrp = srowcrp
         srowcrp = null
         end
        "TBTOP" pdset
        "TBSKIP" pdset "NUMBER("crp")"
        if csrloc = 0 then rowcrp = 0
        if rowcrp = 0 then
        "TBDISPL" pdset "PANEL("tpanel")"
        else
        "TBDISPL" pdset "PANEL("tpanel")",
          "AUTOSEL(NO) CSRROW("rowcrp")"
        crp = ztdtop
      end
    end
    src = rc
    docmd = null
    if cmdtbl = 0
    then 'CONTROL PASSTHRU LRSCROLL PASOFF'
    else pdsecmd = null
    if src = 20 then
    if zerrlm /= 'Attempt to process a table row that no longer exists.'
    then leave
    else do
      src = 0
      ztdsels = 0
    end
    if src > 4
    then if do_pdsedsl /= 1 then leave
    else do
      pdsedsn = '*'
      zcmd = 'C ?'
      signal do_zcmd
    end

    if ztdsels > 1 then
       if srowcrp = null
          then srowcrp = rowcrp

    /* ------------------------------ *
    | Process any immediate commands |
    * ------------------------------ */
    if zcmd = 'QUIT' then leave
    if zcmd = 'EXIT' then leave
    if zcmd = 'RIGHT' then do
      zcmd = null
      Select
        When tpanel = table_panel1 then tpanel = table_panel2
        When tpanel = table_panel2 then tpanel = table_panel3
        When tpanel = table_panel3 then tpanel = table_panel4
        When tpanel = table_panel4 then tpanel = table_panel5
        When tpanel = table_panel5 then tpanel = table_panel6
        When tpanel = table_panel6 then tpanel = table_panel7
        When tpanel = table_panel7 then tpanel = table_panel8
        When tpanel = table_panel8 then tpanel = table_panel1
        otherwise tpanel = def_panel
      End
      'vput (tpanel) profile'
    end
    if zcmd = 'LEFT' then do
      zcmd = null
      Select
        When tpanel = table_panel8 then tpanel = table_panel7
        When tpanel = table_panel7 then tpanel = table_panel6
        When tpanel = table_panel6 then tpanel = table_panel5
        When tpanel = table_panel5 then tpanel = table_panel4
        When tpanel = table_panel4 then tpanel = table_panel3
        When tpanel = table_panel3 then tpanel = table_panel2
        When tpanel = table_panel2 then tpanel = table_panel1
        When tpanel = table_panel1 then tpanel = table_panel8
        otherwise tpanel = def_panel
      End
      'vput (tpanel) profile'
    end

    /* ----------------------------- *
    | Check for the Options command |
    * ----------------------------- */
    if abbrev("OPTIONS",word(zcmd,1),1) = 1 then
    do forever
      zcmd = null
      bypass_tb = null
      'Display Panel(pdsegopt)'
      if rc > 0 then leave
      if zcmd /= null
      then zcmd = zcmd gopt
      if zcmd /= null then leave
    end

    /* ------------------------------- *
    | Handle point and shoot on a row |
    * ------------------------------- */
    if datatype(row) /= 'NUM' then row = 0
    if row /= 0 then do
      ssel = msel
      "TBTOP" pdset
      "TBSKIP" pdset "NUMBER("row")"
      msel = ssel
    end

    /* --------------------------------------------- *
    * Process any command options                   *
    * --------------------------------------------- */
  do_zcmd:
    if zcmd /= null then do
      edits = null
      call logit 'Processing Command:' zcmd
      Select
      when abbrev("CASPER",word(zcmd,1),3) = 1
      then zcmd = "HIGEN" subword(zcmd,2)
      when abbrev("ACHMED",word(zcmd,1),3) = 1
      then zcmd = "HIGEN" subword(zcmd,2)
      when abbrev("ZOMBIE",word(zcmd,1),3) = 1
      then zcmd = "HIGEN" subword(zcmd,2)
      when abbrev("SELECT",word(zcmd,1),1) = 1 then do
        zcmd = 'EDIT' subword(zcmd,2)
        edits = 'S'
      end
      when abbrev("RESET",word(zcmd,1),3) = 1 then zcmd = "REFRESH"
      when abbrev("SRCH",word(zcmd,1),3) = 1
      then zcmd = "FIND" subword(zcmd,2)
      when abbrev("SEARCH",word(zcmd,1),3) = 1
      then zcmd = "FIND" subword(zcmd,2)

      /* ----------------------------------------- *
      | Support PDSE memlist/ml syntax for filter |
      * ----------------------------------------- */
      when abbrev('MEMLIST',word(zcmd,1),3) = 1 then do
        zcmd = 'FILTER' subword(zcmd,2)
      end
      when word(zcmd,1) = 'ML' then
      zcmd = 'FILTER' subword(zcmd,2)
      Otherwise nop
      end

      /* -------------------------------- *
      | Now check for supported commands |
      * -------------------------------- */
      Select
        /* ----------------------- *
        | Check for userid filter |
        * ----------------------- */
        When 'MINE' = zcmd > 0 then do
          if wordpos('MINE',filter_title) > 0 then do
            filter_id = null
            if wordpos('MINE',filter_title) > 0 then do
              wp = wordpos('MINE',filter_title)
              filter_title = delword(filter_title,wp,1)
            end
            if wordpos('ID',filter_title) > 0 then do
              wp = wordpos('ID',filter_title)
              filter_title = delword(filter_title,wp,2)
            end
            call proc_refresh
          end
          if wordpos('MINE',filter_title) > 0 then do
            wp = wordpos('MINE',filter_title)
            filter_title = delword(filter_title,wp,1)
          end
          if wordpos('ID',filter_title) > 0 then do
            wp = wordpos('ID',filter_title)
            filter_title = delword(filter_title,wp,2)
          end
          filter_id = sysvar('sysuid')
          filter_title = strip(filter_title 'MINE')
          call proc_refresh
        end
        When abbrev("ID",word(zcmd,1),2) = 1 then do
          if words(zcmd) = 1 then call cmd_prompt 'ID'
          if words(zcmd) = 1 then
          if wordpos('ID',filter_title) > 0 then do
            filter_id = null
            if wordpos('ID',filter_title) > 0 then do
              wp = wordpos('ID',filter_title)
              filter_title = delword(filter_title,wp,2)
            end
            call proc_refresh
          end
          filter_id = word(zcmd,2)
          if filter_id = '*' then filter_id = null
          if wordpos('MINE',filter_title) > 0 then do
            wp = wordpos('MINE',filter_title)
            filter_title = delword(filter_title,wp,1)
          end
          if wordpos('ID',filter_title) > 0 then do
            wp = wordpos('ID',filter_title)
            filter_title = delword(filter_title,wp,2)
          end
          if filter_id /= null then
          filter_title = strip(filter_title 'ID' filter_id)
          call proc_refresh
        end
        /* ----------------- *
        * Date filter check *
        * ----------------- */
        When wordpos(word(zcmd,1),date_filter_words) > 0
        then do
          call setup_date_filter
          zcmd = null
          call proc_refresh
        end
        /* ------------------ *
        | C - Change Dataset |
        * ------------------ */
        When abbrev("CHANGE",word(zcmd,1),1) = 1 then do
          zerrsm = null
          zcmd = 'C' subword(zcmd,2)
          if word(zcmd,2) = '>' then do
            if topdse /= null
            then zcmd = 'C' topdse
            else do
              zerrsm = 'Error'
              zerrlm = 'Unable to change to the COPY' ,
                'PDS/PDSE because COPY has not' ,
                'been used in this PDSEGEN session.'
              'Setmsg msg(isrz003)'
            end
          end
          if zerrsm = null then do
            if word(zcmd,3) /= null then
            filter = subword(zcmd,3)
            else filter = filter date_filterv
            if datatype(word(zcmd,2)) = 'NUM' then do
              dnum = word(zcmd,2)
              x = pdsegdsl(dnum)
              if x /= 0 then  do
                if words(x) = 1
                then zcmd = 'C' x filter
                else do
                  zcmd = 'C' word(x,1)
                  filter = subword(x,2)
                end
              end
            end
            if strip(zcmd) = 'C' then zcmd = 'C ?'
            if word(zcmd,2) = '?' then do
              x = pdsegdsl()
              if x /= 0
              then do
                if words(x) = 1
                then zcmd = 'C' x filter
                else do
                  zcmd = 'C' word(x,1)
                  filter = subword(x,2)
                end
              end
              else zcmd = null
            end
            if zcmd /= null then do
              tds = word(zcmd,2)
              if tds = '*' then do
                zcmd = 'C' save_pdsedsn filter
                tds = save_pdsedsn
              end
              if pos('.',tds) = 0 then
              if length(tds) < 8 then do
                x = pdsegdsl(tds)
                if x /= 0 then do
                  if words(x) = 1
                  then zcmd = 'C' x filter
                  else zcmd = 'C' x
                end
              end
              x = listdsi(word(zcmd,2))
              if x > 0 then do
                zerrsm = 'Error.'
                zerrlm = tds 'is not a valid dataset' sysmsglvl2
                'setmsg msg(isrz003)'
              end
              else do
                save_pdsedsn = pdsedsn
                hcmd = zcmd
                call close
                zcmd = hcmd
                pdsedsn = word(zcmd,2)
                signal restart
              end
            end
          end
        end
        /* -------------------- *
        | REFLIST from John K. |
        * -------------------- */
        When abbrev("REFLIST",word(zcmd,1),4) = 1 then do
          'Control Display Save'
          "Select pgm(isrdslst) parm(PL1 REFLIST)"
          'Control Display Restore'
          'vget zrdsn shared'
          if zrdsn <> '' then do
            save_pdsedsn = pdsedsn
            if pos('(',zrdsn) > 0 then
            pdsedsn = substr(zrdsn,1,pos('(',zrdsn)-1)||"'"
            else
            pdsedsn = zrdsn
            zcmd = 'C' pdsedsn
            zrdsn = ''
            'vput zrdsn shared'
          end
          signal restart
        end
        /* ------ *
        * Backup *
        * ------ */
        when abbrev("BACKUP",word(zcmd,1),3) = 1 then do
          fromdsn = pdsedsn
          zcmd = null
          pdsebopt = 'B'
          'vput (pdsebopt)'
          'Select cmd(%pdsegbak' fromdsn
          if rc = 0 then do
            zerrsm  = 'Completed'
            zerrlm  = 'Backup operation completed.'
          end
          else do
            zerrsm  = 'Cancelled'
            zerrlm  = 'Backup operation cancelled.'
          end
          'Setmsg msg(isrz003)'
        end
        /* ------ *
        * Restore *
        * ------ */
        when abbrev("RESTORE",word(zcmd,1),4) = 1 then do
          fromdsn = pdsedsn
          zcmd = null
          'Control Display Save'
          'Addpop Row(3) Column(3)'
          'Display Panel(pdsegrst)'
          xrc = rc
          'Rempop'
          'Control Display Restore'
          if xrc = 0 then do
            if newtarg /= 'Y' then newtarg = null
            else newtarg = 'NEW'
            'Select cmd(%pdsegrst' fromdsn targetds ,
              restmem restgen '/' newtarg ')'
            zerrsm  = 'Completed'
            zerrlm  = 'Restore operation completed.'
            'Setmsg msg(isrz003)'
            newtarg = null
          end
          else do
            zerrsm = 'Cancelled'
            zerrlm = 'Restore operation cancelled.'
            'Setmsg msg(isrz003)'
          end
        end
        /* ------- *
        * Compare *
        * ------- */
        when abbrev("COMPARE",word(zcmd,1),3) = 1 then
        call compare_prompt
        /* ------------------------ *
        * Copy to Another/New PDSE *
        * ------------------------ */
        when abbrev("COPY",word(zcmd,1),3) = 1 then do
          frompdse = pdsedsn
          if word(zcmd,2) /= null then
          topdse = word(zcmd,2)
          zcmd = null
          select
            when left(zdsspc,1) = 'C' then spaceu = 'Cyl'
            when left(zdsspc,1) = 'T' then spaceu = 'Trk'
            when left(zdsspc,1) = 'B' then spaceu = 'Trk'
            otherwise spaceu = 'Trk'
          end

          newgen = zdsngen

          if newgen = 0 then newgen = dfamgen
          mempat = null
          if filter /= null then mempat = filter
          if date_filter /= null
          then mempat = strip(mempat) date_filterv

          do forever
            call pfshow 'off'
            'Addpop Row(3) Column(3)'
            "Display Panel(pdsegcpy)"
            xrc = rc
            'Rempop'
            call pfshow 'reset'
            zerrsm = null
            if xrc > 7 then leave
            if left(topdse,1) = "'"
            then wtpds = strip(topdse,'B',"'")
            else wtpds = sysvar('syspref')'.'topdse
            if left(frompdse,1) = "'"
            then wfpds = strip(frompdse,'B',"'")
            else wfpds = sysvar('syspref')'.'frompdse
            if wtpds = wfpds then do
              zerrsm = 'Error.'
              zerrlm = 'The from and to datasets may not be the same.'
              'setmsg msg(isrz003)'
            end
            if zerrsm = null then do
              if create = 'Y' then do
                replace = null
                if 'OK' /= sysdsn(topdse) then do
                  if spaceu = 'BLK' then spaceu = 'TRACKS'
                  if spaceu = 'TRK' then spaceu = 'TRACKS'
                  if spaceu = 'CYL' then spaceu = 'CYLINDERS'
                  Address TSO
                  "Alloc ds("topdse") like("frompdse")" ,
                    "dsntype(library,2) maxgens("newgen")" ,
                    "space("zdstota','zds2ex') new' ,
                    def_unit spaceu
                  "Free ds("topdse")"
                  Address ISPExec
                  create = 'N'
                end
                else do
                  zerrsm  = 'Error'
                  zerrlm  = topdse 'already exists - try a new' ,
                    'name or change create to N.'
                  'Setmsg msg(isrz003)'
                end
              end
            end
            if zerrsm = null then do
              if create = 'N' then do
                if 'OK' = sysdsn(topdse) then do
                  if replace = 'Y'
                  then repopt = '( replace'
                  else repopt = null
                  if progress = 'N' then do
                    if repopt = null then repopt = '( batch'
                    else repopt = repopt 'batch'
                  end
                  'Select cmd(%pdsegenc' frompdse topdse ,
                    mempat repopt
                  leave
                end
                else do
                  zerrsm  = 'Error'
                  zerrlm  = topdse sysdsn(topdse)
                  'Setmsg msg(isrz003)'
                end
              end
            end
          end
        end
        /* ------ *
        | Browse |
        * ------ */
        when abbrev("BROWSE",word(zcmd,1),1) = 1 then do
          if words(zcmd) = 1 then call cmd_prompt 'B'
          call do_command 'B'
        end
        /* ------- *
        | HIGEN   |
        * ------- */
        when abbrev("HIGEN",word(zcmd,1),3) = 1 then do
          if word(zcmd,2) = '?' then do
            'Select pgm(isptutor) parm(pdseghhw)'
          end
          else do
            if zdsngen = 0 then do
              zerrsm = 'Error'
              zerrlm = 'HIGen is not supported for datasets without' ,
                'PDSE member generations.'
              'Setmsg msg(isrz003)'
              higenf = 0
            end
            else do
              if higenf = 0 then higenf = 1
              else higenf = 0
              if higenf = 1
              then do
                HIGEN_title = 'HIGen members'
                call proc_refresh
              end
              else do
                HIGEN_title = null
                'tbtop' pdset
                do forever
                  'tbskip' pdset
                  if rc > 0 then leave
                  if muser = 'HIGen' then 'tbdelete' pdset
                end
              end
            end
          end
        end
        /* ---- *
        | Edit |
        * ---- */
        when abbrev("EDIT",word(zcmd,1),1) = 1 then do
          if words(zcmd) = 1 then call cmd_prompt 'E'
          call do_command 'E'
        end
        /* ------ *
        | Filter |
        * ------ */
        when abbrev("FILTER",word(zcmd,1),3) = 1
        then do
          if word(zcmd,2) = '?' then zcmd = null
          if word(zcmd,2) = null then do
            zcmd = null
            call pfshow 'off'
            'Addpop Row(3) Column(3)'
            'Display Panel(pdsegfil)'
            'Rempop'
            call pfshow 'reset'
            if filter = null then filter = 'OFF'
          end
          else filter = subword(zcmd,2)
          if filter /= null then call setup_filter
        end
        /* ------- *
        * Find    *
        * ------- */
        when abbrev("FIND",word(zcmd,1),1) = 1 then do
          if word(zcmd,2) = null then do
            zcmd = null
            call pfshow 'off'
            'Addpop Row(3) Column(3)'
            'Display Panel(pdsegfnd)'
            'Rempop'
            call pfshow 'reset'
          end
          else pdsegfnd = subword(zcmd,2)
          select
            when words(pdsegfnd) = 1 then nop
            when left(pdsegfnd,1) = "'"
            then if right(pdsegfnd,1) /= "'"
            then pdsegfnd = '"'pdsegfnd'"'
            when left(pdsegfnd,1) = '"'
            then if right(pdsegfnd,1) /= '"'
            then pdsegfnd = '"'pdsegfnd'"'
            when words(pdsegfnd) > 1
            then pdsegfnd = "'"pdsegfnd"'"
            otherwise nop
          end
          if pdsegfnd = null then do
            zerrsm  = 'Error'
            zerrlm  = 'Find requires a find string'
            'Setmsg msg(isrz003)'
          end
          else do
            call do_find
          end
        end
        /* ------- *
        | GENOnly |
        * ------- */
        when abbrev("GENONLY",word(zcmd,1),1) = 1
        then do
          zcmd = null
          if gen_hide = 1 then do
            gen_hide = 0
            hide_title = null
            zerrsm = 'UnHide'
            zerrlm = 'Base members are now displayed.'
            'setmsg msg(isrz003)'
            call proc_refresh
          end
          gen_hide = 1
          gcount = 0
          'tbtop' pdset
          do forever
            'tbskip' pdset
            if rc > 0 then leave
            if agen = null then iterate
            if agen = 0 then do
              'tbdelete' pdset
              gcount = gcount + 1
            end
          end
          'tbtop' pdset
          zerrsm = 'Hidden'
          zerrlm = gcount 'base members have been hidden. ' ,
            'Use GENOnly toggle to unhide them.' ,
            'Delete, Prune, and Rename are not supported' ,
            'when GENOnly/Hide mode is active.'
          'setmsg msg(isrz003)'
          hide_title = 'GENOnly'
        end
        /* ------ *
        * Hide   *
        * ------ */
        when abbrev("HIDE",word(zcmd,1),1) = 1
        then do
          zcmd = null
          if gen_hide = 1 then do
            gen_hide = 0
            hide_title = null
            zerrsm = 'UnHide'
            zerrlm = 'Generations are now displayed.'
            'setmsg msg(isrz003)'
            call proc_refresh
          end
          gen_hide = 1
          gcount = 0
          'tbtop' pdset
          do forever
            'tbskip' pdset
            if rc > 0 then leave
            if agen = null then iterate
            if agen > 0 then do
              'tbdelete' pdset
              gcount = gcount + 1
            end
          end
          'tbtop' pdset
          zerrsm = 'Hidden'
          zerrlm = gcount 'generations have been hidden. ' ,
            'Use Hide toggle to unhide them.' ,
            'Delete, Prune, and Rename are not supported' ,
            'when Hide mode is active.'
          'setmsg msg(isrz003)'
          hide_title = 'Hide'
        end
        /* ------ *
        * Info   *
        * ------ */
        when abbrev("INFO",word(zcmd,1),1) = 1
        then do
          'dsinfo dataset('pdsedsn')'
          zcmd = null
          call do_metric
          do forever
            'tbdispl' tblmet 'panel(pdseginf)'
            if rc > 0 then leave
          end
        end
        /* ------ *
        * Locate *
        * ------ */
        when abbrev("LOCATE",word(zcmd,1),1) = 1
        then do
          if words(zcmd) = 1 then call cmd_prompt 'L'
          lstring = word(zcmd,2)
          if lstring = null then do
            zerrsm = null
            zerrlm = 'Locate requires locate string.'
            'setmsg msg(isrz003)'
          end
          else call do_locate 'x'
        end
       /* -------------- *
       * The PDS Command *
       * --------------- */
        when abbrev("TPC",word(zcmd,1),3) = 1 then do /* pds.command */
          parse var zcmd cmd pds_sub_cmd
          zcmd = null
          'control display line start(1)'
          "select cmd(pds "pdsedsn pds_sub_cmd")"
        end
        /* ------ *
        * Output *
        * ------ */
        When abbrev("OUTPUT",word(zcmd,1),3) = 1
        then do
          zcmd = null
          if sysvar('syspref') = null
          then do
            hlq = sysvar('sysuid')
            odsn = hlq'.PDSEGEN.REPORT'
          end
          else do
            hlq = sysvar('syspref')
            odsn = "'"hlq".PDSEGEN.REPORT'"
          end
          if sysdsn(odsn) = 'OK' then do
            call outtrap 'x.'
            Address TSO ,
              'Delete' odsn
            call outtrap 'off'
          end
          oc = 0
          drop ocl.
          oc = oc + 1
          ocl.oc = '1'pdsetitl
          oc = oc + 1
          ocl.oc = ' Date:' date() 'Time:' time()
          oc = oc + 1
          ocl.oc = ' '
          oc = oc + 1
          ocl.oc = '0Name      Gen  Abs Created      Changed        ',
            'V.M   Size  Init   Mod ID'
          'tbtop' pdset
          do forever
            'tbskip' pdset
            if rc > 0 then leave
            oc = oc + 1
            ocl.oc =' 'left(mbr,8),
              right(mgen,4),
              right(agen,4),
              left(cdate4,10),
              left(mdate4,10),
              left(mtime,5),
              left(vrm,5),
              right(mcur,5),
              right(minit,5),
              right(mmod,5),
              left(muser,8)
          end
          oc = oc + 1
          ocl.oc = '0'ztdmark
          ocl.0 = oc
          Address TSO
          odd = randstr()
          'Alloc f('odd') ds('odsn') new spa(15,15) tr' ,
            'Recfm(f b a) lrecl(121) blksize(0)'
          'Execio * diskw' odd '(finis stem ocl.'
          'Free f('odd')'
          Address ISPExec
          'Browse dataset('odsn')'
          zerrsm  = ' '
          zerrlm  = 'Member table has been successfully listed.' ,
            'The dataset' odsn 'has been retained to allow' ,
            'additional processing.'
          'Setmsg msg(isrz003)'
        end
        /* ------- *
        * Prune   *
        * ------- */
        when abbrev("PRUNE",word(zcmd,1),1) = 1 then do
          if gen_hide = 1 then do
            zerrsm = 'Warning'
            zerrlm = 'Prune is not supported when generations are' ,
              'hidden. Use the REFRESH command to restore the' ,
              'generations to the member list and then you can' ,
              'use prune.'
            'Setmsg msg(isrz003)'
          end
          else do
            if zdsngen = 0 then do
              zerrsm = 'Error'
              zerrlm = 'Prune does not support datasets' ,
                'that are not generation enabled.'
              'setmsg msg(isrz003)'
            end
            else do
              prune = word(zcmd,2)
              zcmd = null
              do forever
                if datatype(prune) /= 'NUM' ,
                  | prune_prompt = 0 then do
                  call pfshow 'off'
                  'Addpop Row(3) Column(3)'
                  'display panel(pdsegpru)'
                  xrc = rc
                  'Rempop'
                  call pfshow 'reset'
                  if xrc > 0 then leave
                end
                val = 'NO'
                if prune = 'RESET' then
                do forever
                  call pfshow 'off'
                  'Addpop Row(3) Column(3)'
                  'display panel(pdsegprv)'
                  xrc = rc
                  'Rempop'
                  call pfshow 'reset'
                  if xrc > 0 then leave
                  if val = 'YES' then leave
                end
                if datatype(prune) = 'NUM' then do
                  if prune > -1 then
                  if prune < zdsngen+1
                  then call do_prune
                  else do
                    zerrsm = 'Error'
                    zerrlm = prune 'value is not within the valid range' ,
                      'of 0 to ' zdsngen
                    'setmsg msg(isrz003)'
                    iterate
                  end
                  leave
                end
                if prune = 'RESET' then if val /= 'YES' then leave
                if prune = 'RESET' then call prune_all
                else call do_prune
                if prune = null then leave
              end
            end
          end
        end
        /* ------- *
        * Refresh *
        * ------- */
        when abbrev("REFRESH",word(zcmd,1),3) = 1 then do
          /* Comment Start
          parse value '' with tfilter tfilterl tfiltert ,
            date_filter date_filter_title ,
            filter filter_title hide_title ,
            HIGEN_title last_date_filter filter_id
          higenf = 0
          gen_hide = 0
             Comment End */
          if word(zcmd,2) /= null then do
            filter = subword(zcmd,2)
            call setup_filter
          end
          else call proc_refresh
        end
        /* ------ *
        * Set    *
        * ------ */
        when abbrev("SET",word(zcmd,1),2) = 1
        then do
          if word(zcmd,2) /= null
          then do
            pset = word(zcmd,2)
            if pos(pset,'EBV/') = 0 then zcmd = 'SET'
            pdsedo = pset
            'vput (pdsedo)'
            zerrsm = 'Set' pdsedo
            zerrlm = pdsedo 'has been set as the default' ,
              'action for the Select line option.'
            'setmsg msg(isrz003)'
          end
          if word(zcmd,2) = null then do
            zcmd = null
            call Proc_Settings
            'Vget (clrb clrg clrp clrr clrt clrw clry clrh clrhr' ,
              'sortb sortc pdsetb useab) profile'
            base_color = sortb
            sort_color = sortc
            call reset_color
            Select
              When sortcol = 'NAME'     then clrmbr   = sort_color
              When sortcol = 'CREATED'  then clrcdate = sort_color
              When sortcol = 'CHANGED'  then clrchang = sort_color
              When sortcol = 'ID'       then clrmuser = sort_color
              When sortcol = 'SIZE'     then clrmcur  = sort_color
              When sortcol = 'MOD'      then clrmmod  = sort_color
              When sortcol = 'INIT'     then clrminit = sort_color
              Otherwise clrmbr = sort_color
            End
          end
        end
       /* ----------------------------------------------- *
        | Support the SetMacro commands (SETMACRO and SM) |
        * ----------------------------------------------- */
        when abbrev("SETMACRO",word(zcmd,1),2) = 1 then call do_imacro
        when zcmd = 'SM' then call do_imacro
        /* ------- *
        * Sort    *
        * ------- */
        when abbrev("SORT",word(zcmd,1),2) = 1 then do
          sortcol = word(zcmd,2)
          sort_order = left(word(zcmd,3),1)
          zcmd = null
          if pos(sort_order,'A D') = 0 then sort_order = null
          if sortcol = '?' then sortcol = null
          if sortcol = null then do
            call ask_sort
          end
          if sortcol  /= null then do
            sortseq  = word(zcmd,3)
            lsort    = sort.sortcol
            if lsort = 'D' then lsort = 'A'
            else lsort = 'D'
            if sort_order /= null then lsort = sort_order
            sortseq       = lsort
            sort.sortcol  = lsort
            select
              when abbrev("CREATED",sortcol,2) = 1 then do
                sortcol = 'CREATED'
                sortf = 'scdate,c,'sortseq',mbr,c,a,mgen,n,d'
                call reset_color
                clrcdate = sort_color
              end
              when abbrev("CHANGED",sortcol,2) = 1 then do
                sortcol = 'CHANGED'
                sortf = 'smdate,c,'sortseq,
                  ',mtime,c,'sortseq',mbr,c,a,mgen,n,d'
                call reset_color
                clrchang = sort_color
              end
              when abbrev("ID",sortcol,2) = 1 then do
                sortcol = 'ID'
                sortf = 'muser,c,'sortseq',mbr,c,',
                  sortseq',mgen,n,d'
                call reset_color
                clrmuser = sort_color
              end
              when abbrev("SIZE",sortcol,1) = 1 then do
                sortcol = 'SIZE'
                sortf = 'mcur,n,'sortseq
                call reset_color
                clrmcur  = sort_color
              end
              when abbrev("MOD",sortcol,1) = 1 then do
                sortcol = 'MOD'
                sortf = 'mmod,n,'sortseq
                call reset_color
                clrmmod  = sort_color
              end
              when abbrev("INIT",sortcol,2) = 1 then do
                sortcol = 'INIT'
                sortf = 'minit,n,'sortseq
                call reset_color
                clrminit = sort_color
              end
              when abbrev("NAME",sortcol,1) = 1 then do
                sortcol = 'NAME'
                sortf = 'mbr,c,'sortseq',mgen,n,d'
                call reset_color
                clrmbr   = sort_color
              end
              when sortcol = '?' then do
                call ask_sort
              end
              otherwise do
                call ask_sort
              end
            end
            'tbsort' pdset 'fields('sortf')'
            'tbtop'  pdset
          end
        end
        /* ------------------------------------------ *
        | Model - Allocate a new dataset using       |
        |         the characteristics of the current |
        |         dataset.                           |
        * ------------------------------------------ */
        When abbrev("MODEL",word(zcmd,1),3) = 1 then do
          call do_model
        end
        /* ------ *
        | Submit |
        * ------ */
        when abbrev("SUBMIT",word(zcmd,1),3) = 1 then do
          if words(zcmd) = 1 then call cmd_prompt 'SUB'
          call do_command 'S'
        end
        /* -------- *
        * Validate *
        * -------- */
        when abbrev("VALIDATE",word(zcmd,1),2) = 1 then do
          'Control Display Save'
          zcmd = null
          "Select cmd(%pdsegval '"wdsn"' "valparm")"
          'Control Display Restore'
        end
        /* ---- *
        | View |
        * ---- */
        when abbrev("VIEW",word(zcmd,1),1) = 1 then do
          if words(zcmd) = 1 then call cmd_prompt 'V'
          call do_command 'V'
        end
        /* ------------------- *
        | Age - From John K.  |
        * ------------------- */
        when abbrev("AGE",word(zcmd,1),2) = 1 then call do_age
        /* ------------------------------- *
        | Command not found or recognized |
        * ------------------------------- */
        Otherwise do
          zerrsm = 'Unknown Command'
          zerrlm = 'Command entered is not recognized:' word(zcmd,1)
          bypass_tb = 1
          gopt = subword(zcmd,2)
          zcmd = 'OP'
          'Setmsg msg(isrz003)'
        end
      end
    end            /* end of zcmd processing */

    /* --------------- line commands ---------------------------- *
    * Process the member selections commands:                    *
    *             A - Attributes (Ver/Mod/Userid) (gen 0 only)   *
    *             B - browse                                     *
    *             C - transfer (gen 0 only)                      *
    *             D - delete                                     *
    *             E - edit     (for gen 0 only)                  *
    *                 converted to V for non-0 gen)              *
    *             G - recover  (for non-0 generations)           *
    *             H - Hide the row                               *
    *             J - Submit the member                          *
    *             K - Clone the member (gen 0 only)              *
    *                 generations are not cloned                 *
    *             R - Rename a member and generations            *
    *             P - promote  (for non-0 generations)           *
    *             O - prompt for option                          *
    *             S - select   (based on the prompt panel        *
    *             V - view                                       *
    *             X - eXecute the member (rexx only)             *
    *             Z - compare  (compare the gen 0 to this non-0) *
    *             / - prompt for option                          *
    * ---------------------------------------------------------- */
    if datatype(row) /= 'NUM' then row = 0
    last_mem  = mbr
    last_mgen = mgen
    last_agen = agen
    if row > 0 then
    if msel /= null then ztdsels = 1
    if ztdsels > 0 then do
      if msel = 'S' then msel = pdsedo
      if Dummy = 'G' then do
        zerrsm  = 'Warning'
        zerrlm  = "This is a Dummy member that holds information about a" ,
          "previously deleted member. That information includes the" ,
          "highest absolute generation that was used for the member" ,
          "before it, or it's generations, were deleted."
        'Setmsg msg(isrz003)'
        msel = null
        iterate
      end

      /* ------------------------------------- *
      | Validate the member selection options |
      * ------------------------------------- */
      if length(msel) = 1 then
      if pos(msel,'/ABCDEGHIJKMOPQRTUVWXZ') = 0 then do
        zerrsm = 'Unknown Selection'
        zerrlm = msel 'is an unknown option - select a valid option.'
        'Setmsg msg(isrz003)'
        msel = '/'
      end

      /* ------------------------------------------------ *
      | Block Command Processing                         |
      |                                                  |
      | Block = doubling the line command character or   |
      |         doubling the 1st character               |
      |                                                  |
      | Any line selection can be blocked or a count     |
      | e.g. X99    (expanded commands can't be counts)  |
      * ------------------------------------------------ */
      if abbrev('CCLONE',msel,4)  = 1 then msel = 'KK'
      if abbrev('CCOPY',msel,4)   = 1 then msel = 'CC'
      if abbrev('SSUBMIT',msel,4) = 1 then msel = 'JJ'
      if abbrev('TTRANSFER',msel,2) = 1 then msel = 'CC'
      linecmds = '// OO AA BB CC DD EE GG HH II JJ KK MM NN' ,
        'PP RR UU VV WW XX'
      if wordpos(left(msel,2),linecmds) > 0  then do
        if blockcmd = 1 then do
          if save_msel /= msel then do
            zerrsm = 'Error'
            zerrlm = left('Invalid/Mismatched block command.',70) ,
              left('Starting block command:' save_msel,70) ,
              'Ending block command:' msel
            'Setmsg msg(isrz003)'
            blockcmd = 0
            block_rows = null
          end
        end
        else if blockcmd /= 1 then do
          block_rows = null
          blockcmd = 1
          save_msel = msel
        end
        'tbquery' pdset 'position(rownum)'
        block_rows = block_rows rownum+0
        msel = null
        if words(block_rows) = 2
        then call proc_block
        else if ztdsels = 1 then do
          zerrsm = 'Block Started'
          zerrlm = save_msel 'block started at row:' block_rows
          'Setmsg msg(isrz003)'
          lopt = '*Block'
          'tbput' pdset 'Order'
        end
      end

      /* ------------------------------- *
      | Check for block count commands: |
      |                                 |
      |    Snnnnn                       |
      * ------------------------------- */
      if datatype(substr(msel,2)) = 'NUM' then do
        'tbquery' pdset 'position(rownum) rownum(maxrow)'
        tblend = rownum+substr(msel,2)-1
        if tblend > maxrow then tblend = maxrow
        block_rows = rownum+0 tblend
        save_msel = msel
        msel = null
        if words(block_rows) = 2 then call proc_block
      end

      /* ---------------------------- *
      | Process the member selection |
      * ---------------------------- */
    Proc_Selection:
      zerrsm = null

      call logit 'Processing Selection Option:' msel 'on Member:' mbr ,
        'Gen:' agen

      if pos(msel,'O/') > 0 then do forever
        msel = null
        if agen > 0 then panel = 'pdsegsln'
        else panel = 'pdsegsl0'
        call pfshow 'off'
        'Addpop Row(3) Column(3)'
        'Display Panel('panel')'
        xrc = rc
        'Rempop'
        call pfshow 'reset'
        if xrc > 0 then leave
        if rc = 0
        then if msel /= null
        then leave
      end

      /* ------------------------------------ *
      | Process long line selection commands |
      * ------------------------------------ */
      Select
        When abbrev("ATTRIB",msel,1)    = 1 then msel = 'A'
        When abbrev("BROWSE",msel,1)    = 1 then msel = 'B'
        When abbrev("CLONE",msel,2)     = 1 then msel = 'K'
        When abbrev("COMPARE",msel,3)   = 1 then msel = 'Z'
        When abbrev("COPY",msel,3)      = 1 then msel = 'C'
        When abbrev("DELETE",msel,1)    = 1 then msel = 'D'
        When abbrev("EDIT",msel,1)      = 1 then msel = 'E'
        When abbrev("EXECUTE",msel,2)   = 1 then msel = 'X'
        When abbrev("HIDE",msel,1)      = 1 then msel = 'H'
        When abbrev("INFO",msel,1)      = 1 then msel = 'I'
        When abbrev("KLONE",msel,1)     = 1 then msel = 'K'
        When abbrev("MAIL",msel,2)      = 1 then msel = 'M'
        When abbrev("PROMOTE",msel,1)   = 1 then msel = 'P'
        When abbrev("RECOVER",msel,3)   = 1 then msel = 'G'
        When abbrev("RENAME",msel,3)    = 1 then msel = 'R'
        When msel = "RENS"                  then msel = 'Q'
        When msel = "RENSWAP"               then msel = 'Q'
        When abbrev("SELECT",msel,2)    = 1 then msel = 'S'
        When abbrev("SUBMIT",msel,2)    = 1 then msel = 'J'
        When abbrev("TRANSFER",msel,2)  = 1 then msel = 'C'
        When abbrev("TRYIT",msel,1)      = 1 then msel = 'T'
        When abbrev("USER",msel,1)      = 1 then msel = 'U'
        When abbrev("VIEW",msel,1)      = 1 then msel = 'V'
        Otherwise nop
      end

      Select
        /* ---------------------------------------------------- *
        | When the selection is > 1 character                  |
        | - checks for EE/EE, Enn, Dnn, DD/DD must be prior to |
        |   this test                                          |
        * ---------------------------------------------------- */
        when length(msel) > 1 then do
          zucmd = msel '/'
          call do_user
          lopt  = '*'msel
          lopts = lopt
          msel  = null
          'tbput' pdset 'Order'
        end
        /* ---------- *
        | Attributes |
        * ---------- */
        When msel = 'A' then do
          if mgen < 0 then do
            zerrsm  = 'Invalid option'
            zerrlm  = 'Attributes is only allowed for generation 0' ,
              'members.'
            'Setmsg msg(isrz003)'
          end
          else do
            parse value vrm with avr'.'amd
            aid = muser
            'control display save'
            call pfshow 'off'
            'Addpop Row(3) Column(3)'
            'Display Panel(pdsegat)'
            xrc = rc
            'Rempop'
            call pfshow 'reset'
            'control display restore'
            if xrc = 0 then do
              avr = avr * 1
              amd = amd * 1
              if avr < 10 then avr = '0'avr
              if amd < 10 then amd = '0'amd
              'LMMStats Dataid('pdsegend')' ,
                'Member('mbr') version('avr') modlevel('amd')' ,
                'User('aid')'
              lrc = rc
              if lrc = 0 then do
                vrm = avr'.'amd
                muser = aid
                zerrsm = 'Updated'
                zerrlm = 'Attributes updated for member' mbr 'to' ,
                  'Version:' avr 'Modification Level:' amd ,
                  'Userid:' muser
                'setmsg msg(isrz003)'
                lopt  = '*Attrib'
                lopts = lopt
                msel  = null
                'tbput' pdset 'Order'
              end
              else do
                'setmsg msg(isrz003)'
              end
            end
            else do
              zerrsm = 'Canceled'
              zerrlm = 'Attributes update canceled'
              'setmsg msg(isrz003)'
            end
          end
        end
        /* ------ *
        * Browse *
        * ------ */
        when msel = 'B' then call do_browse
        /* ---------------------------------------------------- *
        | C - Copy a member to another PDSE (or PDS)           |
        |   - only works for Base members                      |
        |   - will transfer generations                        |
        |   - prompts for target PDSE/PDS (must already exist) |
        |   - invokes PDSEGENC                                 |
        * ---------------------------------------------------- */
        When msel = 'C' then do
          zerrsm = null
          if mgen < 0 then
          if blockcmd /= 1 then do
            zerrsm  = 'Invalid option'
            zerrlm  = 'Copy is only allowed for generation 0' ,
              'members.'
            'Setmsg msg(isrz003)'
          end
          'Control Display Save'
          if zerrsm = null then
          do forever
            xrc = 0
            if blockcmd /= 1 then topdse = null
            if topdse /= null then leave
            'Addpop Row(3) Column(3)'
            'Display Panel(pdsegxfr)'
            xrc = rc
            'Rempop'
            if xrc > 0 then leave
            zerrsm = null
            x = listdsi(ztdsn)
            if x > 0 then do
              zerrsm = 'Invalid DSN'
              zerrlm = ztdsn sysdsn(ztdsn)
              'Setmsg msg(isrz003)'
            end
            if left(ztdsn,1) = "'"
            then wtdsn = strip(ztdsn,'B',"'")
            else wtdsn = sysvar('syspref')'.'ztdsn
            if wdsn = wtdsn then do
              zerrsm = 'Error.'
              zerrlm = 'The from and the to datasets may not be the same.'
              'Setmsg msg(isrz003)'
            end
            if zerrsm = null then leave
          end
          'Control Display Restore'
          topdse = ztdsn
          if zerrsm = null then
          if xrc = 0 then do
            if repxfr = 'Y' then replopt = '( Replace'
            else replopt = null
            address tso ,
              "%pdsegenc '"wdsn"'" ztdsn mbr replopt
            if rc = 0 then do
              lopt  = '*Copy'
              lopts = lopt
              msel  = null
              'tbput' pdset 'Order'
            end
          end
        end
        /* ---------------------------------------------------- *
        * D - Delete process                                   *
        *                                                      *
        * If pending delete then create a dummy member to hold *
        * the base and allow access to the generations         *
        * ---------------------------------------------------- */
        when msel = 'D' then do
          pdsedelu = 'N'
          if gen_hide = 1 then do
            zerrsm = 'Warning'
            zerrlm = 'Delete is not supported when generations are' ,
              'hidden. Use the REFRESH command to restore the' ,
              'generations to the member list and then you can' ,
              'use delete.'
            'Setmsg msg(isrz003)'
          end
          else do
            if Dummy = 'G' then do
              Address TSO
              "Alloc f("pdsegdd") shr reuse" ,
                "dsn('"wdsn"("mbr")')"
              s.0 = 1;s.1 = 'Primary member for Dummy member'
              "Execio * diskw" pdsegdd "(finis stem s."
              "Free f("pdsegdd")"
              Address ISPExec
              mgen = 0
            end
            if pdsedelp = 'N' then do
              pdsedel  = 'N'
              call pfshow 'off'
              'Addpop Row(3) Column(3)'
              if mgen = 0
              then 'display panel(pdsegdlb)'
              else 'display panel(pdsegdlg)'
              'Rempop'
              call pfshow 'reset'
            end
            else pdsedel = 'Y'
            if pdsedel = 'Y' then
            if pdsedelu = 'Y' then call del_promote
            else
            if pdsedel = 'Y' then do
              if agen > 0 then do
                Address TSO
                'Alloc f('pdsedd') shr reuse ds('pdsedsn')'
                x = proc_del(mbr agen pdsedd)
                'Free f('pdsedd')'
                zerrsm  = 'Deleted'
                zerrlm  = mbr 'gen' mgen 'deleted.'
                Address ISPExec
                'tbdelete' pdset
                'Setmsg msg(isrz003)'
                proc_mems = proc_mems mbr 'D'
              end
              else do
                save_top = ztdtop
                'tbtop' pdset
                dmbr  = mbr
                dgens = null
                do forever
                  'tbvclear' pdset
                  mbr = dmbr
                  'tbscan' pdset 'arglist(mbr)'
                  if rc > 0 then leave
                  if mbr > dmbr then leave
                  if mbr = dmbr then do
                    if strip(agen) = null then agen = 0
                    dgens = dgens strip(agen)
                  end
                end
                idw = words(dgens)
                Address TSO ,
                  'Alloc f('pdsedd') shr reuse ds('pdsedsn')'
                do id = idw to 1 by -1
                  x = proc_del(dmbr word(dgens,id) pdsedd)
                end
                Address TSO ,
                  'Free f('pdsedd')'
                mbr = dmbr
                call delete_mem
                ztdtop = save_top
                zerrsm  = 'Deleted'
                zerrlm  = dmbr 'and all generations have been deleted.'
                'Setmsg msg(isrz003)'
              end
            end
          end
        end
        /* ---------------------------------------- *
        * Edit                                     *
        * If non-0 generation then convert to View *
        * ---------------------------------------- */
        when msel = 'E' then call do_edit
        /* ------ *
        * eMail  *
        * ------ */
        when msel = 'M' then
        if mail /= 0 then do
          'control display save'
          call do_email
          'control display restore'
          lopt = '*eMail'
          lopts = lopt
          msel  = null
          'tbput' pdset 'Order'
        end
        else do
          zerrsm  = 'Error'
          zerrlm  = 'The M (mail) option is not supported by' ,
            'this installation.'
          'Setmsg Msg(isrz003)'
        end
        /* ------------ *
        | H - Hide row |
        * ------------ */
        when msel = 'H' then 'TBDelete' pdset
        /* ----------------------------------------- *
        * K - Klone member                          *
        *   - prompt the user for a new member name *
        *     into which this base member will      *
        *     be copied into.                       *
        * ----------------------------------------- */
        when msel = 'K' then do
          zerrsm  = null
          znewmem = null
          if agen > 0 then do
            zerrsm  = 'Error'
            zerrlm  = 'The K (Clone) operation can only be done' ,
              'on a base (generation 0) member.'
            'Setmsg Msg(isrz003)'
            znewmem = null
          end
          if lopt /= null then
          if left(lopt,1) /= '*' then do
            znewmem = translate(lopt)
            bypass = 1
          end
          if znewmem /= null
          then x = valname(znewmem)
          if x /= 0 then do
            bypass = 0
            zerrsm = 'Error'
            zerrlm = x
            'Setmsg msg(isrz003)'
            zerrsm = null
          end
          if znewmem /= null then
          if sysdsn("'"wdsn"("znewmem")'") = 'OK' then do
            bypass = 0
            zerrsm = 'Error'
            zerrlm = znewmem 'currently exists - pick a new name.'
            'Setmsg msg(isrz003)'
            zerrsm = null
          end
          if zerrsm = null then do forever
            zerrsm  = null
            if bypass /= 1 then do
              call pfshow 'off'
              'Addpop Row(3) Column(3)'
              'Display Panel(pdsegcl)'
              xrc = rc
              'Rempop'
              call pfshow 'reset'
            end
            else do
              xrc = 0
              bypass = 0
            end
            if xrc > 0 then do
              znewmem = null
              leave
            end
            if xrc = 0 then do
              if znewmem = null then leave
              if sysdsn("'"wdsn"("znewmem")'") /= 'OK' then leave
              zerrsm  = 'Error'
              zerrlm  = znewmem "exists - pick a new name"
              'Setmsg Msg(isrz003)'
            end
          end
          if znewmem = null then
          if zerrsm  = null then do
            zerrsm  = 'Cancelled'
            zerrlm  = 'Cloning (K) cancelled'
            'Setmsg Msg(isrz003)'
          end
          if zerrsm  = null then do
            lopt = '*Klone'
            lopts = lopt
            msel  = null
            call do_klone
            'tbput' pdset 'Order'
            mbr = znewmem
            proc_mems = proc_mems znewmem 'Klone'
            lopt = null
            lopts = null
          end
        end
        /* --------------------------------------------------- *
        * Promote process                                     *
        *   Copies the non-0 generation into the generation 0 *
        *   member leaving the user in Edit.                  *
        *   Also promotes HIGEN members to gen 0              *
        * --------------------------------------------------- */
        when msel = 'P' then do
          zerrsm  = null
          if mgen = 0 then do
            zerrsm  = 'Error'
            zerrlm  = 'Promote can only be done on a generation' ,
              'other than generation 0.'
            'Setmsg Msg(isrz003)'
          end
          if mgen = null then do
            zerrsm  = 'Error'
            zerrlm  = 'Promote can not be done on a non-generation' ,
              'dataset member.'
            'Setmsg Msg(isrz003)'
          end
          if zerrsm  = null then do
            call create_temp
            pdsemopt = 'R'
            pdsecpds = "'"wdsn"("mbr")'"
            'vput (pdsecpds)'
            'control display save'
            'edit dataset('tdsn') macro(pdsegenm) parm(pdsemopt)'
            'control display restore'
            Address TSO 'Free f('zpdsendd') Delete'
            pmbr = mbr
            if cdate /= null then do
              parse var vrm iver'.'imod
              'LMMStats Dataid('pdsegend')' ,
                'Member('mbr') version('iver') modlevel('imod')' ,
                'Created('cdate') Moddate('mdate')' ,
                'Modtime('mtime') Cursize('mcur')' ,
                'Initsize('minit') Modrecs('mmod')' ,
                'User('muser')'
            end
            lopt = '*Promote'
            lopts = lopt
            msel  = null
            proc_mems = proc_mems mbr 'Promote'
            'tbput' pdset 'Order'
            lopt = null
            lopts = null
          end
        end
        /* ----------------------------------------- *
        * G - Recover generation to base member     *
        *   - prompt the user for a new member name *
        *     into which this non-0 generation will *
        *     be created into.                      *
        * ----------------------------------------- */
        when msel = 'G' then do
          zerrsm  = null
          znewmem = null
          if Dummy = 'G' then mgen = -1
          if agen = 0 then
          if mgen = 0 then do
            zerrsm  = 'Error'
            zerrlm  = 'Recovery can only be done on a generation' ,
              'other than generation 0.'
            'Setmsg Msg(isrz003)'
            znewmem = null
          end
          if agen = null then do
            zerrsm  = 'Error'
            zerrlm  = 'Recovery cannot be performed on a non-generation' ,
              'dataset mamber. '
            'Setmsg Msg(isrz003)'
            znewmem = null
          end
          if zerrsm = null then do forever
            zerrsm  = null
            if lopt /= null then
            if left(lopt,1) /= '*'
            then do
              bypass = 1
              znewmem = translate(lopt)
            end
            if znewmem /= null
            then x = valname(znewmem)
            if x /= 0 then do
              bypass = 0
              zerrsm = 'Error'
              zerrlm = x
              'Setmsg msg(isrz003)'
              zerrsm = null
            end
            if znewmem /= null then
            if sysdsn("'"wdsn"("znewmem")'") = 'OK' then do
              bypass = 0
              zerrsm = 'Error'
              zerrlm = znewmem 'currently exists - pick a new name.'
              'Setmsg msg(isrz003)'
              zerrsm = null
            end
            if bypass /= 1 then do
              call pfshow 'off'
              'Addpop Row(3) Column(3)'
              if Dummy = 'G'
              then 'Display Panel(pdsegrmp)'
              else 'Display Panel(pdsegrm)'
              xrc = rc
              'Rempop'
              call pfshow 'reset'
            end
            else do
              bypass = 0
              xrc = 0
            end
            if xrc > 0 then do
              znewmem = null
              leave
            end
            if xrc = 0 then do
              if znewmem = null then leave
              if mbr /= znewmem then
              if sysdsn("'"wdsn"("znewmem")'") /= 'OK' then leave
              zerrsm  = 'Error'
              if Dummy = 'G' then
              zerrlm  = "Recovery not allowed to the same member name."
              else
              zerrlm  = znewmem "exists - pick a new name"
              'Setmsg Msg(isrz003)'
            end
          end
          if znewmem = null then
          if zerrsm  = null then do
            zerrsm  = 'Cancelled'
            zerrlm  = 'Recovery cancelled'
            'Setmsg Msg(isrz003)'
          end
          if zerrsm  = null then do
            lopt = '*Recover'
            lopts = '*G'
            msel  = null
            if Dummy /= 'G' then do
              'tbput' pdset 'Order'
              lopt = null
              lopts = null
              msel = null
              pdsemopt = 'R'
              pdsecpds = "'"wdsn"("znewmem")'"
              'vput (pdsecpds)'
              'edit dataid('pdsegend') member('mbr') gen('agen')' ,
                'macro(pdsegenm) parm(pdsemopt)'
              mbr = znewmem
            end
            if Dummy = 'G' then do
              'tbdelete' pdset
              mgen = agen
              Address TSO
              "Alloc f("pdsegdd") shr reuse" ,
                "dsn('"wdsn"("znewmem")')"
              s.0 = 1;s.1 = 'Primary member for HIGen members'
              "Execio * diskw" pdsegdd "(finis stem s."
              "Free f("pdsegdd")"
              Address ISPExec
              pdsecpds = "'"wdsn"("znewmem")'"
              pdsemopt = 'R'
              'vput (pdsecpds)'
              'edit dataid('pdsegend') member('mbr') gen('agen')' ,
                'macro(pdsegenm) parm(pdsemopt)'
              'tbtop' pdset
              do forever
                'tbvclear' pdset
                mbr = znewmem
                'tbscan' pdset 'arglist(mbr)'
                if rc > 0 then leave
                'tbdelete' pdset
              end
              mbr = znewmem
              call update_mem
              'tbtop' pdset
              do forever
                'tbvclear' pdset
                mbr = znewmem
                'tbscan' pdset 'arglist(mbr)'
                if rc > 0 then leave
                address tso
                'Alloc f('pdsedd') shr reuse ds('pdsedsn')'
                x = proc_del(mbr agen pdsedd)
                agen = agen - 1
                x = proc_del(mbr agen pdsedd)
                'Free f('pdsedd')'
                address ispexec
                call update_mem
                gclean = 1
              end
            end
            if gclean /= 1 then do
              mbr = znewmem
              call new_mem
              lstring = mbr
              call do_locate
              msel  = null
              Dummy = null
              proc_mems = proc_mems mbr 'Recover'
              lopt = null
              lopts = null
            end
          end
        end
        /* ----------------------------------------- *
        * R - Rename member                         *
        *   - prompt the user for a new member name *
        *     that this member and its generations  *
        *     will be renamed to.                   *
        * ----------------------------------------- */
        when msel = 'R' then do
          if gen_hide = 1 then do
            zerrsm = 'Warning'
            zerrlm = 'Rename is not supported when generations are' ,
              'hidden. Use the REFRESH command to restore the' ,
              'generations to the member list and then you can' ,
              'use rename.'
            'Setmsg msg(isrz003)'
          end
          zerrsm  = null
          znewmem = null
          if agen > 0 then do
            zerrsm  = 'Error'
            zerrlm  = 'Rename can only be done on a generation 0' ,
              'member.'
            'Setmsg Msg(isrz003)'
            znewmem = null
          end
          if lopt /= null then
          if left(lopt,1) /= '*' then do
            znewmem = translate(lopt)
            bypass = 1
          end
          if znewmem /= null
          then x = valname(znewmem)
          if x /= 0 then do
            bypass = 0
            zerrsm = 'Error'
            zerrlm = x
            'Setmsg msg(isrz003)'
            zerrsm = null
          end
          if znewmem /= null then
          if sysdsn("'"wdsn"("znewmem")'") = 'OK' then do
            bypass = 0
            zerrsm = 'Error'
            zerrlm = znewmem 'currently exists - pick a new name.'
            'Setmsg msg(isrz003)'
            zerrsm = null
          end
          if zerrsm = null then do forever
            zerrsm  = null
            if bypass /= 1 then do
              call pfshow 'off'
              'Addpop Row(3) Column(3)'
              'Display Panel(pdsegrnm)'
              xrc = rc
              'Rempop'
              call pfshow 'reset'
            end
            else do
              xrc = 0
              bypass = 0
            end
            if xrc > 0 then do
              znewmem = null
              leave
            end
            if xrc = 0 then do
              if znewmem = null then leave
              if sysdsn("'"wdsn"("znewmem")'") /= 'OK' then leave
              zerrsm  = 'Error'
              zerrlm  = znewmem "exists - pick a new name"
              'Setmsg Msg(isrz003)'
            end
          end
          if znewmem = null then
          if zerrsm  = null then do
            zerrsm  = 'Cancelled'
            zerrlm  = 'Rename (R) cancelled'
            'Setmsg Msg(isrz003)'
          end
          if zerrsm  = null then do
            save_top = ztdtop
            'tbtop' pdset
            rmbr  = mbr
            rgens = null
            drop rmem.
            do forever
              'tbskip' pdset
              if rc > 0 then leave
              if mbr = rmbr then do
                parse var vrm iver'.'imod
                if strip(agen) = null then agen = 0
                rgens = rgens strip(agen)
                rmem.agen = mbr agen'\'iver'\'imod'\'cdate,
                  '\'mdate'\' mtime'\'mcur'\'minit'\'mmod'\'muser
              end
            end
            call do_rename
            /* remove the from member from the table */
            mbr = rmbr
            call delete_mem
            /* remove the new member from the table just in case */
            mbr = znewmem
            call delete_mem
            /* now add the new member to the table */
            mbr = znewmem
            call update_mem
            /* now update the table info */
            save_top = ztdtop
            'tbtop' pdset
            mbr = znewmem
            agen = 0
            'tbscan' pdset 'arglist(mbr agen) position(srowcrp)'
            'tbget' pdset
            lopt = '*RENAME'
            lopts = '*R'
            'tbput' pdset
          end
        end
        /* -------------------------------------------- *
        | Rename Swap (Q)                              |
        | - Rename swaps 2 members and all generations |
        * -------------------------------------------- */
        when msel = 'Q' then call do_rename_swap
        /* -------------------------------------------- *
        | TRYIT - Edit the member with the TRYIT macro |
        * -------------------------------------------- */
        when msel = 'T' then call do_tryit
        /* ---- *
        * View *
        * ---- */
        when msel = 'V' then call do_view
        /* ------------ *
        * User Command *
        * ------------ */
        when msel = 'U' then do
          call do_user
          lopt  = '*User'
          lopts = lopt
          msel  = null
          'tbput' pdset 'Order'
        end
        /* ------- *
        * eXecute *
        * ------- */
        when msel = 'X' then do
          'control display save'
          call do_eXecute
          'control display restore'
          lopt = '*eXecute'
          lopts = lopt
          msel = null
          'tbput' pdset 'Order'
        end
        /* ------- *
        * Info    *
        * ------- */
        when msel    = 'I' then do
          /* slick translate from Doug Nadel */
          xagen = strip(translate('0,123,456,789,abc,def', ,
            right(agen,16,','), ,
            '0123456789abcdef'),'L',',')
          'control display save'
          'Addpop row(3) column(3)'
          'Display Panel(pdsegeni)'
          'Rempop'
          'control display restore'
          lopt  = '*Info'
          lopts = lopt
          msel  = null
          'tbput' pdset 'Order'
        end
        /* ------- *
        * Submit  *
        * ------- */
        when msel = 'J' then do
          call do_submit
          lopt  = '*Submit'
          lopts = lopt
          msel  = null
          'tbput' pdset 'Order'
        end
        /* ---------------------------------------------------- *
        * Watch Out - allows editing any member or generation. *
        * When editing a non-0 generation any updates can be   *
        * saved but they cannot be accessed via JCL or         *
        * Dynamic Allocation.                                  *
        *                                                      *
        * Note the ISPF statistics will be updated for the     *
        * member when the member list display is refreshed.    *
        * ---------------------------------------------------- */
        when msel = 'W' then do
          if agen > 0 then do
            zerrsm = 'Warning'
            zerrlm = 'You are editing a non-0 generation and if you' ,
              'save your changes there will NOT be a new' ,
              'generation created and you can not access this' ,
              'update using JCL or Dynamic Allocation.'
            'Setmsg msg(isrz003)'
          end
          higen = (words(all_members.mbr) -2) *-1
          pdsemopt = 'EM'
          'vput (mgen agen higen) shared'
          'Control Display Save'
          'Edit dataid('pdsegend') member('mbr') gen('agen')' ,
            'macro(pdsegenm) parm(pdsemopt)'
          'Control Display Restore'
          lopt  = '*WarnEdit'
          lopts = lopt
          msel  = null
          'tbput' pdset 'Order'
          lopt = null
          lopts = null
        end
        /* ----------- *
        | Z - COMpare |
        * ----------- */
        when msel = 'Z' then do
          if mgen = 0 then do
            zcmd = '$' mbr 0
            lopt = '*Compare'
            lopts = '*Z'
            msel = null
            'tbput' pdset 'Order'
            lopt = null
            lopts = null
            call compare_prompt
          end
          else do
            cfrom = 0
            cto   = mgen
            cmem  = mbr
            lopt = '*Compare'
            lopts = '*Z'
            msel = null
            'tbput' pdset 'Order'
            lopt = null
            lopts = null
            call do_compare
          end
        end
        When msel = null then nop
        /* This routine should never be entered as the line
        selection options are validated much earlier */
        Otherwise do
          if zerrsm = null then do
            zerrsm = 'Invalid Option'
            zerrlm = msel 'is not a recognized line selection option.'
            'setmsg msg(isrz003)'
          end
        end
      end
      if words(block_rows) = 2 then return

      /* ---------------------------------------- *
      * Clean up and update the last used option *
      * ---------------------------------------- */
    Clean_Up:
      arg return_opt
      parse value '' with lopt lopts msel update_table edit_stat
      if ztdsels = 1 then
      if proc_mems /= null then do
        lopt  = null
        lopts = null
        lopts = null
        pdsedelp = 'N'
        pdsedelu = 'N'
        call refresh_pdsi
        do um = 1 to words(proc_mems) by 2
          mbr = word(proc_mems,um)
          mopt = word(proc_mems,um+1)
          call update_mem 'x'
          update_table = update_table mbr
          if left(mopt,1) = 'E' then edit_stat = edit_stat mbr
          if mopt = 'Recover' then edit_stat = edit_stat mbr
          if mopt = 'Klone'  then do
            mopt = 'Kloned'
            edit_stat = edit_stat mbr
          end
        end
        call proc_pdsegeni
        do um = 1 to words(edit_stat)
          mbr = word(edit_stat,um)
          'tbtop' pdset
          'tbscan' pdset 'arglist(mbr) position(scanrow) condlist(eq)'
          lopt = '*'mopt
          if mopt = 'Recover'
          then lopts = '*G'
          else lopts = lopt
          'tbput' pdset 'Order'
          lopt = null
          lopts = null
        end
        mbr = word(proc_mems,1)
        lstring = mbr
        scrp = crp
        call do_locate
        crp = scrp
        proc_mems = null
      end
      if return_opt /= null then do
        return_opt = null
        return
      end
      update_table = null
      edit_stat    = null
    end
  end

  if do_pdsedsl = 1 then do
    pdsedsn = '*'
    call close
    signal restart
  end

  if dsn_prompt = 1 then do
    pdsedsn = null
    call close
    signal restart
  end

Exit:
  call close
  call logit 'PDSEGEN processing ending - rc 0'
  exit 0

  /* -------------------------------- *
  | Enter/Manage Initial Edit Macros |
  * -------------------------------- */
Do_IMacro:
  'vget (imacvar) profile'
  imtab = 'im'random(9999)
  'tbcreate' imtab 'keys(imsuff) names(imacro imacprm) nowrite'
  workvar = imacvar
  do forever
    parse value workvar with imsuff imacro imacprm '%' workvar
    if strip(imsuff) = null then leave
    'tbadd' imtab
    'tbsort' imtab 'fields(imsuff,ch,a)'
  end
  ztdsels = 0
  do forever
    zcmd = null
    if ztdsels < 2 then do
      'tbtop' imtab
      'tbdispl' imtab 'panel(pdsegimc)'
    end
    else 'tbdispl' imtab
    if rc > 4 then leave
    if abbrev('INSERT',zcmd,1) = 1 then do forever
      zsel = null
      zcmd = null
      imsuff = null
      'control display save'
      'addpop row(3) column(3)'
      'display panel(pdsegima)'
      drc = rc
      'rempop'
      'control display restore'
      if drc > 0 then leave
      newmac = imsuff imacro imacprm
      if wordpos(imsuff,imacvar) > 0 then do
        zerrsm = 'Error'
        zerrlm = 'The suffix' imsuff 'already exists, use Change to' ,
          'update it if necessary.'
        'setmsg msg(isrz003)'
      end
      else imacvar = imacvar newmac '%'
      'vput (imacvar) profile'
      'tbadd' imtab
      'tbsort' imtab 'fields(imsuff,ch,a)'
      leave
    end
    if zsel = 'C' then do
      zsel = null
      zcmd = null
      osuff = imsuff
      'control display save'
      'addpop row(3) column(3)'
      'display panel(pdsegimu)'
      drc = rc
      'rempop'
      'control display restore'
      if drc = 0 then do
        cmac = imsuff imacro imacprm
        call del_imac
        imacvar = imacvar cmac '%'
        'vput (imacvar) profile'
        'tbmod' imtab
        'tbsort' imtab 'fields(imsuff,ch,a)'
      end
    end
    if zsel = 'D' then call del_imac
  end
  'tbend' imtab
  return

Del_Imac:
  zsel = null
  wp = wordpos(imsuff,imacvar)
  newmac = ''
  do until length(imacvar) = 0
    parse value imacvar with sfx smx smp '%' imacvar
    if sfx = imsuff then iterate
    newmac = newmac sfx smx smp '%'
  end
  imacvar = newmac
  'vput (imacvar) profile'
  'tbdelete' imtab
  return

  /* ------------------------- *
  | Process the Model command |
  * ------------------------- */
Do_Model: Procedure Expose pdsedsn zdsngen null zcmd dfamgen
  'dsinfo dataset('pdsedsn')'
  if words(zcmd) = 2 then mdsn = word(zcmd,2)
  else mdsn   = pdsedsn
  newgen = zdsngen
  munit  = left(zdsspc,1)
  dsnt   = left(zdsdsnt,1)
  'Control Display Save'
  'Addpop Row(3) Column(3)'
  do forever
    zcmd   = null
    'Display Panel(pdsegmdl)'
    xrc = rc
    if xrc > 0 then leave
    if sysdsn(mdsn) /= 'OK' then leave
    zerrsm = 'Error...'
    zerrlm = mdsn 'already exists - try a different dsn.'
    'setmsg msg(isrz003)'
  end
  'RemPop'
  'Control Display Restore'
  if xrc > 0 then do
    zerrsm = 'Cancelled'
    zerrlm = 'Model request has been cancelled.'
    'setmsg msg(isrz003)'
    return
  end
  zdsrf = strip(left(zdsrf,1)' 'substr(zdsrf,2,1)' 'substr(zdsrf,3,1))
  library = null
  if dsnt = 'P' then
  library = 'Dsntype(PDS) dsorg(po) dir('zdsdira')'
  if (dsnt = 'L' & newgen = 0) then
  library = 'Dsntype(Library,2) dsorg(po) dir(1)'
  if (dsnt = 'L' & newgen > 0) then
  library = 'Dsntype(Library,2) dsorg(po) dir(1) maxgens('newgen')'
  if zdsvol = null then vol = null
  else vol = 'Vol('zdsvol')'
  space = null
  if munit = 'B' then space = 'Block('zdsblk')'
  if munit = 'T' then space = 'Tracks'
  if munit = 'C' then space = 'Cylinders'
  Address TSO ,
    'Alloc ds('mdsn') new spa('zds1ex','zds2ex')' vol ,
    'Recfm('zdsrf') Lrecl('zdslrec') Blksize('zdsblk')' ,
    library space
  if rc = 0 then do
    zerrsm = 'Allocated'
    zerrlm = mdsn 'allocated with Space('zds1ex','zds2ex')' ,
      'Recfm('zdsrf') Lrecl('zdslrec') Blksize('zdsblk')' ,
      vol library space
    topdse = mdsn
    Address TSO ,
    "Free ds("mdsn")"
  end
  else do
    zerrsm = 'Error'
    zerrlm = 'Allocation failure for' mdsn
  end
  'setmsg msg(isrz003)'
  return

  /* -------------------------- *
  | Process the block commands |
  * -------------------------- */
Proc_Block:
  rstart = word(block_rows,1)
  rend   = word(block_rows,2)
  if rend < rstart then do
    rhold = rstart
    rstart = rend
    rend = rhold
  end
  if pos(left(save_msel,1),'HD') = 0
  then do pblk = rstart to rend
    'tbtop' pdset
    'tbskip' pdset 'number('pblk')'
    if rc > 0 then leave
    msel = left(save_msel,1)
    call proc_selection
  end
  else do pblk = rend to rstart by -1
    'tbtop' pdset
    'tbskip' pdset 'number('pblk')'
    if rc > 0 then leave
    msel = left(save_msel,1)
    call proc_selection
  end
  blockcmd = 0
  block_rows = null
  save_msel = null
  msel = null
  return

  /* --------------------------------------------- *
  | Do_Browse Routine.                            |
  |                                               |
  | Called by Browse command and B line selection |
  * --------------------------------------------- */
Do_Browse:
  if zdsngen > 0 then do
    higenr = (words(members.mbr) -1) *-1
    higena = word(members.mbr,2)
    if mgen /= 0 then do
      msggen = mgen'('agen')'
    end
    else msggen = 0
  end
  else do
    msggen = 0
    higenr = 0
    higena = 0
  end
  zerrsm = 'Gen' mgen
  if higenr = 0 then hm = 0
  else hm = higenr'('higena')'
  if zdsngen > 0 then
  zerrlm = 'Browsing generation' msggen 'with a high' ,
    'gen of' hm
  else
  zerrlm = 'Browsing a PDS member in a PDS with no' ,
    'generations defined.'
  'setmsg msg(isrz003)'
  'control display save'
  'Browse dataid('pdsegend') member('mbr') gen('agen')'
  if rc > 4 then 'setmsg msg(isrz003)'
  'control display restore'
  'tbtop' pdset
  'tbscan' pdset 'arglist(mbr agen)'
  msel = null
  lopt = '*Browse'
  lopts = lopt
  'tbput' pdset 'Order'
  lopt = null
  lopts = null
  return

  /* --------------- *
  | Do_Edit Routine |
  * --------------- */
Do_Edit:
  /* -------------------------------------------------------- *
  | If editing a Dummy member then set absolute and relative |
  | generations to 0 to allow editing.                       |
  |                                                          |
  | The Dummy is just a place holder retaining the high      |
  | water mark of absolute generations.                      |
  * -------------------------------------------------------- */
  if Dummy = 'G' then do
    msel = 'E'
    agen = 0
    mgen = 0
  end
  /* ------------------------------------------------- *
  | Check to determine if we allow Edit or if a non-0 |
  | generations for View                              |
  * ------------------------------------------------- */
  if agen = null then agen = 0
  if agen = 0 then mgen = 0
  if agen /= 0 then do
    zerrsm  = 'Changed to View'
    zerrlm  = 'Edit is ONLY allowed for generation 0' ,
      'members. Your request has been changed' ,
      'to View.'
    'Setmsg msg(isrz003)'
    if docmd /= null then
    higen = (words(all_members.mbr) -2) *-1
    pdsemopt = 'EMV'
    'vput (mgen agen higen) shared'
    'Control Display Save'
    'view   dataid('pdsegend') member('mbr') gen('agen')' ,
      'macro(pdsegenm) parm(pdsemopt)'
    if rc > 4 then 'setmsg msg(isrz003)'
    'Control Display Restore'
    'tbtop' pdset
    'tbscan' pdset 'arglist(mbr agen)'
    lopt = '*View'
    lopts = lopt
    msel = null
    'tbput' pdset 'Order'
    lopt = null
    lopts = null
  end
  else do
    if zdsngen > 0 then do
      higenr = (words(all_members.mbr) -2) *-1
      if higenr > 0 then higenr = 0
      higena = word(members.mbr,2)
      higen = higenr
      zerrsm = 'Gen' mgen
      zerrlm = 'Editing generation 0 with a high' ,
        'gen of' higenr'('higena')'
      'setmsg msg(isrz003)'
    end
    if zdsngen = 0 then
    parse value '0 0 0' with agen mgen higen
    pdsemopt = 'EM'
    'vput (mgen agen higen) shared'
    'Control Display Save'
    'edit   dataid('pdsegend') member('mbr') gen('agen')' ,
      'macro(pdsegenm) parm(pdsemopt)'
    xrc = rc
    'Control Display Restore'
    /* rc <= 4 is acceptable */
    if xrc > 4 then 'Setmsg Msg(isrz003)'
    /* rc = 0 then member updated */
    xmbr = mbr
    if xrc = 0 then do
      mbr = xmbr
      call update_mem
      mbr = xmbr
      call clean_up 'x'
      mbr = xmbr
      agen = 0
      'tbtop' pdset
      'tbscan' pdset 'arglist(mbr agen)'
      'tbget' pdset
      lopt  = '*Edit'
      lopts = lopt
      msel  = null
      'tbput' pdset 'Order'
      lopt = null
      lopts = null
      msel = null
    end
    /* rc > 0 then member not updated */
    else do
      'tbtop' pdset
      'tbscan' pdset 'arglist(mbr agen)'
      'tbget' pdset
      lopt  = '*Edit'
      lopts = lopt
      msel  = null
      'tbput' pdset 'order'
      lopt  = null
      lopts = null
    end
  end
  proc_mems = null
  return

  /* --------------- *
  | Do_Tryit Routine|
  * --------------- */
Do_Tryit:
  higen = (words(all_members.mbr) -2) *-1
  pdsemopt = 'EMV'
  'vput (mgen agen higen) shared'
  'control display save'
  if agen = 0
  then 'Edit   dataid('pdsegend') member('mbr') gen('agen')' ,
    'macro(tryit)'
  else 'View   dataid('pdsegend') member('mbr') gen('agen')' ,
    'macro(tryit)'
  'control display restore'
  'tbtop' pdset
  'tbscan' pdset 'arglist(mbr agen)'
  lopt = '*Tryit'
  lopts = lopt
  msel = null
  'tbput' pdset 'Order'
  lopt = null
  lopts = null
  return

  /* --------------- *
  | Do_View Routine |
  * --------------- */
Do_View:
  higen = (words(all_members.mbr) -2) *-1
  pdsemopt = 'EMV'
  'vput (mgen agen higen) shared'
  'control display save'
  'view   dataid('pdsegend') member('mbr') gen('agen')' ,
    'macro(pdsegenm) parm(pdsemopt)'
  if rc > 4 then 'setmsg msg(isrz003)'
  'control display restore'
  'tbtop' pdset
  'tbscan' pdset 'arglist(mbr agen)'
  lopt = '*View'
  lopts = lopt
  msel = null
  'tbput' pdset 'Order'
  lopt = null
  lopts = null
  return

  /* -------------------------------------------------- *
  | PFSHOW routine:                                    |
  |                                                    |
  | Option Off - check if it was On and then set to On |
  | Option Reset - save current value and set off      |
  * -------------------------------------------------- */
pfshow:
  arg pfkopt
  if pfkopt = 'RESET' then do
    if pfkeys = 'ON' then
    'select pgm(ispopf) parm(FKA,ON)'
  end
  if pfkopt = 'OFF' then do
    'vget (zpfshow)'
    pfkeys = zpfshow
    if zpfshow = 'OFF' then return
    'select pgm(ispopf) parm(FKA,OFF)'
  end
  return

  /* --------------------------------------------------- *
  | Delete member processing routine                    |
  * --------------------------------------------------- */
Proc_Del: procedure expose zdsngen wdsn
  arg member gen dd
  if zdsngen = 0 then mgflag = 'D'
  else mgflag = 'DG'
  xrc = pdsegdel(member,gen,dd,mgflag)
  return xrc

  /* ----------------------------------------------------- *
  | Del_Promote Routine:                                  |
  |                                                       |
  | This routine will:                                    |
  |                                                       |
  | 1. Promote the -1 generation to the base              |
  | 2. Delete the -1 (formerly base) and -2 (formerly -1) |
  |    generations                                        |
  * ----------------------------------------------------- */
Del_Promote:
  mgen = '-1'
  call create_temp
  mgen = 0
  pdsemopt = 'R'
  pdsecpds = "'"wdsn"("mbr")'"
  'vput (pdsecpds)'
  'edit dataset('tdsn') macro(pdsegenm) parm(pdsemopt)'
  Address TSO 'Free f('zpdsendd') Delete'
  'tbskip' pdset
  if cdate /= null then do
    parse var vrm iver'.'imod
    'LMMStats Dataid('pdsegend')' ,
      'Member('mbr') version('iver') modlevel('imod')' ,
      'Created('cdate') Moddate('mdate')' ,
      'Modtime('mtime') Cursize('mcur')' ,
      'Initsize('minit') Modrecs('mmod')' ,
      'User('muser')'
  end
  lopt = '*D'
  lopts = lopt
  msel = null
  proc_mems = proc_mems mbr 'D'
  lopt = null
  lopts = null
  Address TSO ,
    'Alloc f('pdsedd') shr reuse ds('pdsedsn')'
  delgen = find_highgen(pdsedsn,mbr)
  x = proc_del(mbr delgen pdsedd)
  delgen = word(members.mbr,2)
  x = proc_del(mbr delgen pdsedd)
  Address TSO ,
    'Free f('pdsedd')'
  return

  /* ------------------------------------------------- *
  * Update_stat routine                               *
  *                                                   *
  * Updates the ispf member statistics for our table. *
  *                                                   *
  * Note the changed number of records is NOT used    *
  * since we don't get it from pdsegeni               *
  * ------------------------------------------------- */
Update_stat:
  cdate   = zlcdate
  mdate   = zlmdate
  mtime   = zlmtime
  if zlvers /= null then
  vrm     = zlvers'.'zlmod
  mcur    = zlcnorc
  minit   = zlinorc
  mmod    = zlmnorc
  muser   = zluser
  scdate  = cdate
  smdate  = mdate
  smtime  = mtime
  smuser  = muser
  return

  /* ------------------------------------------ *
  * Do_Locate routine                          *
  * find the location of the requested member  *
  * near find (condlist) is supported and will *
  * reduce the row count by 1                  *
  *                                            *
  * Option of non-blank will generate a        *
  * message on locate end (good/bad)           *
  * ------------------------------------------ */
Do_Locate:
  arg loc_opt
  scrp = crp
  srowcrp = rowcrp
  crp = 0
  rowcrp = 0
  'tbtop' pdset
  if sortcol = null then sortcol = 'NAME'
  if sort.sortcol = null then cond = 'LE'
  if sort.sortcol = 'D' then cond = 'LE'
  else cond = 'GE'
  call do_sort
  'tbvclear' pdset
  mbr  = lstring
  scanrows = 0
  Select
    When sortcol = 'NAME' then do
      sortcoln = 'Name'
      'tbscan' pdset 'arglist(mbr) position(scanrow) condlist('cond')'
      if mbr /= lstring then scanrows = scanrow - 1
    end
    When sortcol = 'ID' then do
      sortcoln = 'ID'
      muser = lstring
      'tbscan' pdset 'arglist(muser) position(scanrow) condlist('cond')'
      if muser /= lstring then scanrows = scanrow - 1
    end
    When sortcol = 'CREATED' then do
      sortcoln = 'Created'
      cdate  = lstring
      'tbscan' pdset 'arglist(cdate) position(scanrow) condlist('cond')'
      if cdate /= lstring then scanrows = scanrow - 1
    end
    When sortcol = 'CHANGED' then do
      sortcoln = 'Changed'
      mdate  = lstring
      'tbscan' pdset 'arglist(mdate) position(scanrow) condlist('cond')'
      if mdate /= lstring then scanrows = scanrow - 1
    end
    When sortcol = 'MOD' then do
      sortcoln = 'Mod'
      mmod  = lstring
      'tbscan' pdset 'arglist(mmod) position(scanrow) condlist('cond')'
      if mmod /= lstring then scanrows = scanrow - 1
    end
    When sortcol = 'SIZE' then do
      sortcoln = 'Size'
      mcur  = lstring
      'tbscan' pdset 'arglist(mcur) position(scanrow) condlist('cond')'
      if mcur /= lstring then scanrows = scanrow - 1
    end
    When sortcol = 'INIT' then do
      sortcoln = 'Init'
      minit =  lstring
      'tbscan' pdset 'arglist(minit) position(scanrow) condlist('cond')'
      if minit /= lstring then scanrows = scanrow - 1
    end
    Otherwise do
      zerrsm = 'Invalid'
      zerrlm = 'Invalid sort column:' sortcol
      'Setmsg msg(isrz003)'
    end
  end
  lrc = rc
  if scanrows > 0 then found = 'Near Find'
  else found = 'Found'
  if lrc = 0
  then do
    crp = scanrow
    srowcrp = scanrow
    if loc_opt /= null then do
      zerrsm = found
      zerrlm = 'Locate on column' sortcoln' for value:' lstring
      'Setmsg msg(isrz003)'
    end
  end
  else do
    crp = scrp
    rowcrp = srowcrp
    if loc_opt /= null then do
      zerrsm = 'Not Found'
      zerrlm = 'Locate on column' sortcol' not found for:' lstring
      'Setmsg msg(isrz003)'
    end
  end
  return

  /* ----------------------------- *
  * Add a new member to the table *
  * ----------------------------- */
new_mem:
  "LMClose dataid("pdsegend")"
  "LMOPEN DATAID("pdsegend") OPTION(INPUT)"
  "LmmList Dataid("pdsegend") Option(List) Member(member)",
    'stats(yes)'
  if zdsngen > 0 then do
    agen    = 0
    mgen    = 0
  end
  call update_stat
  'tbadd' pdset 'Order'
  call do_sort
  return

  /* ---------------------------------------------- *
  * Process the results from the pdsegeni function *
  * ---------------------------------------------- */
Proc_pdsegeni:
  /* -------------------------------------- *
  * Now process each member and generation *
  * -------------------------------------- */
  /*
  Field    start length
  Member   5     8
  absgen   13    8
  vrm      22    5
  cdate    35    7   yyyyddd
  ttr      46    3
  mdate    49    7   yyyyddd
  mtime    56    7   0hhmmss
  userid   63    8
  mmod     71    2   hex mod records
  cur size 75    4  hex
  init size 79   4  hex
  dummy flag 87  1   D for dummy generation
  */
  mgen     = 0
  pdsegmem = 0   /* count of generations */
  smbr     = null  /* was mbr */
  ombr     = null
  grows    = 0
  metrics  = null
  drop members. all_members.
  members.     = null
  all_members. = null
  numeric digits 10

  /* ----------------------------------------------------- *
  | Create the ISPF Table for the Members and Generations |
  | If update_table not null then don't tbcreate          |
  * ----------------------------------------------------- */
  if update_table = null then do
    if closed = 0 then
    'tbclose' pdset
    pdset = randstr()           /* random table name for recursion */
    'tbcreate' pdset,
      'names(msel mbr mgen agen lopt lopts cdate mdate mtime' ,
      'vrm mcur minit muser mmod scdate smdate Dummy' ,
      'mcscale miscale mcurx minitx mttr cdate4 mdate4) nowrite'
    closed = 0
  end

  mult = 0
  if filter /= null
  then if date_filter /= null
  then if member.0 < 15000
  then mult = member.0
  if mult = 0 then
  Select
    When member.0 = 0 then return
    When member.0 > 5000 then mult = 5000
    when member.0 > 1000 then mult = 1000
    otherwise mult = 250
  end

  /* -------------------------------------------------- *
  | Now process the member info returned from pdsegeni |
  * -------------------------------------------------- */
  do i = 1 to member.0
    parse value member.i with 5 mbr 13 agen 21 . 22 vrm 27 . ,
      35 cdate 42 . 46 mttr ,
      49 mdate 56 mtime 63 muser 71 mmod 73 . 75 mcur 79 minit ,
      83 . 87 dmy .

    /* ---------------------------------------------- *
    | Test for Dummy/invalid members and ignore      |
    | unless the Dummy option (HIGEN) flag is set.   |
    * ---------------------------------------------- */
    mbr   = strip(mbr)
    if left(mbr,1) = '00'x then iterate
    mttr  = c2x(mttr)
    Dummy = null
    parse value '' with lopt lopts

    muser = strip(muser)
    agen  = strip(agen)

    if zdsngen = 0
    then parse value '0 0' with mgen agen
    else do
      /* ------------------------ *
      | Test for a Dummy member: |
      |                          |
      | dmy = D then set counter |
      | Iterate if not HIGen     |
      | else set mgen to -       |
      * ------------------------ */
      if dmy = 'D' then do
        Dummy = 'G'
        grows = grows + 1
        if higenf = 0 then iterate
      end
      if agen = 0 then mgen = 1
      if higenf = 1 then
      if mgen = '-' then mgen = 0
      if Dummy /= 'G'
      then mgen = mgen -1
      else  mgen = 0
    end

    /* -------------------------------- *
    | Increment the generation counter |
    * -------------------------------- */
    if agen > 0 then pdsegmem = pdsegmem + 1

    /* ---------------------------------- *
    | Keep track of members and gen info |
    * ---------------------------------- */
    if all_members.mbr = null
    then do
      all_members.mbr = mbr agen
      all_members.0 = all_members.0 mbr
    end
    else all_members.mbr = all_members.mbr agen

    if wordpos(mbr,all_members.0) = 0
    then all_members.0 = all_members.0 mbr
    if smbr /= null then if smbr /= mbr then iterate

    /* ----------------------------- *
    | Check and process any filters |
    * ----------------------------- */
    if filter /= null then do
      ftest = proc_filter(mbr)
      if ftest = 0 then iterate
    end

    /* --------------------------------- *
    | Make counts and dates displayable |
    * --------------------------------- */
    if mcur = '    '
    then mcur = 0
    else mcur = x2d(c2x(mcur))
    if minit = '    '
    then minit = 0
    else minit = x2d(c2x(minit))

    parse value '' with mcscale miscale mcurx minitx

    /* ---------------------------------------- *
    | Fixup the counts for display             |
    | if > 99,999 then use M (million) suffix  |
    | if > 9,999 then use K (thousands) suffix |
    | Note: STATS EXT is required for > 65k    |
    * ---------------------------------------- */
    Select
      when mcur > 999999 then do
        mcurx   = mcur
        mcur    = mcur%1000000||'M'
        mcscale = 'M'
      end
      when mcur > 99999 then do
        mcurx   = mcur
        mcur    = mcur%1000||'K'
        mcscale = 'K'
      end
      Otherwise nop
    end

    Select
      when minit > 999999 then do
        minitx  = minit
        minit   = minit%1000000||'M'
        miscale = 'M'
      end
      when minit > 99999 then do
        minitx  = minit
        minit   = minit%1000||'K'
        miscale = 'K'
      end
      Otherwise nop
    end

    mtime = Substr(mtime,2,2)||':'||Substr(mtime,4,2)
    mmod  = x2d(c2x(mmod))
    if mdate /= null then do
      smdate = substr(mdate,1,7)
      mdate  = substr(mdate,3,5)
      mdate4 = date('s',mdate,'j')
      mdate  = date('o',mdate,'j')
      mdate4 = left(mdate4,4)'/'substr(mdate,4,2)'/'right(mdate,2)
    end
    if cdate /= null then do
      scdate = substr(cdate,1,7)
      cdate  = substr(cdate,3,5)
      cdate4 = date('s',cdate,'j')
      cdate  = date('o',cdate,'j')
      cdate4 = left(cdate4,4)'/'substr(cdate,4,2)'/'right(cdate,2)
    end

    if zdsngen > 0 then do
      /* -------------------------------------------------- *
      * If the member name changes and the absolute gen is *
      * not zero (it should be zero) then set Dummy flag   *
      * -------------------------------------------------- */
      if ombr /= mbr then do
        ombr = mbr
        mgen = 0
      end
      if Dummy = 'G' then cdate  = null
    end

    /* ------------------------------------------------- *
    | If the creation date is null then nullify all the |
    | row variables                                     |
    * ------------------------------------------------- */
    if strip(cdate) = null then do
      parse value '' with cdate mdate mtime vrm ,
        muser scdate smdate ,
        mcur minit mmod state cdate4 mdate4
      sgen = mgen
    end
    if dummy = 'G' then do
      muser = 'HIGen'
      mgen  = '-'
    end

    /* ------------------------------------------------- *
    | Set the HIGEN into the Last Option (status) Field |
    * ------------------------------------------------- */
    if higenf = 1 then do
      if agen > 0 then
      if mgen = '-' then do
        lopt = agen
        lopts = lopt
        agen = mgen
      end
    end

    /* ----------------------- *
    * Test for Date Filtering *
    * ----------------------- */
    if date_filter /= null then do
      if mdate = null then iterate
      test_date = date('b',mdate,'o')
      if date_filter > test_date then iterate
    end

    /* ------------------------------------ *
    | Test if generations should be hidden |
    * ------------------------------------ */
    if gen_hide = 1 then do
      if agen = null then leave
      if agen > 0 then iterate
    end

    /* -------------------------- *
    | Check for userid filtering |
    * -------------------------- */
    if filter_id /= null then do
      if pos(filter_id,muser) = 0 then iterate
    end

    /* ----------------------------------------------------- *
    | Add the member/generation to the ISPF Table           |
    | and update the members. stem with member and gen info |
    * ----------------------------------------------------- */
    members.mbr = members.mbr agen
    /* --------------------------------------------------------- *
    | Only add those members found in the update_table variable |
    | if it isn't null                                          |
    * --------------------------------------------------------- */
    if update_table /= null
    then if wordpos(mbr,update_table) = 0 then iterate

    /* ------------------------------- *
    | Now add the member to the table |
    * ------------------------------- */
    'tbadd' pdset 'mult('mult')'
  end
  'tbsort' pdset 'fields('sortf')'
  return

  /* ---------------------------------------- *
  | Build metrics of the members/generations |
  * ---------------------------------------- */
do_metric:
  metric. = null
  metrics = null
  do dm = 1 to words(all_members.0)
    dm_mbr = word(all_members.0,dm)
    mg = words(all_members.dm_mbr) -2
    if wordpos(mg,metrics) > 0 then do
      metric.mg = metric.mg + 1
    end
    else do
      metrics = metrics mg
      metric.mg = 1
    end
  end

  /* ------------------------- *
  | Create Metrics ISPF Table |
  * ------------------------- */
  if metric_table /= null
  then 'TBClose' tblmet
  metric_table = 1
  'tbcreate' tblmet 'names(row) nowrite'
  call add_tblmet left('Volser:',20) left(strip(zdsvol),11) ,
    left('Management Class:',20) strip(zdsmc)
  call add_tblmet left('DSN Type:',20) left(strip(zdsdsnt),11) ,
    left('Storage Class:',20) strip(zdssc)
  call add_tblmet left('DSN Version:',20) left(strip(zdsdsnv),11),
    left('Data Class:',20) strip(zdsdc)
  if zdsdsnt = 'PDS' then
  call add_tblmet left('Directory Alloc:',20) left(strip(zdsdira),11),
    left('Directory Used:',20) strip(zdsdiru)
  call add_tblmet left('RECFM:',20) left(strip(zdsrf),11) ,
    left('Extents Allocated:',20) left(strip(zdsexta),11)
  call add_tblmet left('LRECL:',20) left(strip(zdslrec),11) ,
    left('Extents Used:',20) left(strip(zdsextu),11)
  call add_tblmet left('BLKSIZE:',20) left(strip(zdsblk),11) ,
    left('Base Members:',20) left(strip(zds#mem),11)
  call add_tblmet left('Units:',20) left(strip(zdsspc),11) ,
    left('Generation Members:',20) left(strip(pdsegmem),11)
  call add_tblmet left('Primary:',20) left(strip(zds1ex),11) ,
    left('MaxGen:',20) left(strip(zdsngen),11)
  call add_tblmet left('Secondary:',20) left(strip(zds2ex),11) ,
    left('System MaxGens:',20) left(strip(dfamgen),11)
  call add_tblmet left('Allocated:',20) left(strip(zdstota),11) ,
    left('Pages Used:',20) left(strip(zdspagu),11)
  call add_tblmet left('Used:',20) left(strip(zdstotu),11) ,
    left('Pages Utilized:',20) left(strip(zdsperu),11)
  call add_tblmet ' '
  call add_tblmet 'Member Distribution:'
  call add_tblmet 'GenNo  Members' ,
    ' GenNo  Members' ,
    ' GenNo  Members' ,
    ' GenNo  Members'
  /* ---------------------------- *
  | Sort the metrics for display |
  * ---------------------------- */
  do imx = 1 to words(metrics)-1
    do im = 1 to words(metrics)
      w1 = word(metrics,im)
      w2 = word(metrics,im+1)
      if w1 > w2 then do
        if im > 1
        then  lm = subword(metrics,1,im-1)
        else lm = ''
        rm = subword(metrics,im+2)
        metrics = lm w2 w1 rm
      end
    end
  end
  /* -------------------------------- *
  | Now add the metrics to the table |
  * -------------------------------- */
  do im = 1 to words(metrics)
    row = null
    metgen = word(metrics,im)
    metmem = metric.metgen
    if metgen > 0 then metgen = metgen * -1
    row = right(metgen,5) right(metmem,8)
    im = im + 1
    metgen = word(metrics,im)
    metmem = metric.metgen
    if metgen > 0 then metgen = metgen * -1
    row = row' ' right(metgen,5) right(metmem,8)
    im = im + 1
    metgen = word(metrics,im)
    metmem = metric.metgen
    if metgen > 0 then metgen = metgen * -1
    row = row' ' right(metgen,5) right(metmem,8)
    im = im + 1
    metgen = word(metrics,im)
    metmem = metric.metgen
    if metgen > 0 then metgen = metgen * -1
    row = row' ' right(metgen,5) right(metmem,8)
    'tbadd' tblmet
  end
  'tbtop' tblmet
  return

  /* ---------------------------- *
  | Add row to the metrics table |
  * ---------------------------- */
Add_tblmet:
  parse arg row
  'tbadd' tblmet
  return

  /* -------------------------------------- *
  * Update the member rows after edit save *
  * -------------------------------------- */
update_mem:
  arg umopt
  omem = mbr
  'tbtop' pdset
  do forever
    'tbvclear' pdset
    mbr = omem
    'tbscan' pdset 'arglist(mbr)'
    if rc > 0 then leave
    'tbdelete' pdset
  end
  mbr = omem
  if umopt = null then do
    call refresh_pdsi
    update_table = omem
    call proc_pdsegeni 'x'
  end
  src = 0
  return

  /* ---------------- *
  * Common Sort Call *
  * ---------------- */
do_sort:
  sorder = sort.sortcol
  'tbtop' pdset
  Select
    When sortcol = 'NAME'     then
    'tbsort' pdset 'fields(mbr,c,'sorder',mgen,n,d)'
    When sortcol = 'CREATED'  then
    'tbsort' pdset 'fields(scdate,c,'sorder',mbr,c,a,mgen,n,d)'
    When sortcol = 'CHANGED'  then
    'tbsort' pdset 'fields(smdate,c,'sorder',mtime,c,'sorder',',
      'mbr,c,a,mgen,n,d)'
    When sortcol = 'ID'       then
    'tbsort' pdset 'fields(muser,c,'sorder',mbr,c,a,mgen,n,d)'
    When sortcol = 'SIZE'     then
    'tbsort' pdset 'fields(mcur,n,'sorder',' ,
      'mbr,c,a,mgen,n,d)'
    When sortcol = 'MOD'      then
    'tbsort' pdset 'fields(mmod,n,'sorder',mbr,c,a,mgen,n,d)'
    When sortcol = 'INIT'     then
    'tbsort' pdset 'fields(minit,n,'sorder',' ,
      'mbr,c,a,mgen,n,d)'
    Otherwise nop
  end
  Select
    When sortcol = 'NAME'     then clrmbr   = sort_color
    When sortcol = 'CREATED'  then clrcdate = sort_color
    When sortcol = 'CHANGED'  then clrchang = sort_color
    When sortcol = 'ID'       then clrmuser = sort_color
    When sortcol = 'SIZE'     then clrmcur  = sort_color
    When sortcol = 'MOD'      then clrmmod  = sort_color
    When sortcol = 'INIT'     then clrminit = sort_color
    otherwise clrmbr = sort_color
  end
  return

  /* --------------------------- *
  | Refresh the member/gen list |
  * --------------------------- */
Refresh_pdsi:
  Address TSO
  "Alloc f("pdsedd") ds('"wdsn"') shr reuse"
  drop member.
  Address ISPExec ,
    "dsinfo dataset('"wdsn"')"
  if zds#mem > 0
  then x=pdsegeni(pdsedd)
  else do
    rc = 0
    member.0 = 0
  end
  'Free f('pdsedd')'
  Address ISPExec
  return

  /* -------------------------------------------------------- *
  | Compare Prompt                                           |
  |                                                          |
  | Entered from the Command Compare or from the Compare (Z) |
  | Line command if entered on generation 0 (base)           |
  * -------------------------------------------------------- */
Compare_Prompt:
  parse value zcmd with c cmem cfrom cto
  cpos = 'cmem'
  if words(zcmd) < 4 then do
    do forever
      zcmd = null
      call pfshow 'off'
      'Addpop Row(3) Column(3)'
      'Display Panel(pdsegcom) cursor('cpos')'
      xrc = rc
      'Rempop'
      call pfshow 'reset'
      if xrc > 4 then cmem = null
      if cmem = null then leave
      zerrsm = null
      cprgens = words(members.cmem)
      cprgens = '0 to -'words(members.cmem)-1
      rc = test_gen(cmem cfrom)
      if rc = 1 then do
        cpos = 'cfrom'
        zerrsm = 'Error'
        zerrlm = 'From generation does not exist. Try using:' ,
          cprgens
        'setmsg msg(isrz003)'
      end
      rc = test_gen(cmem cto)
      if rc = 1 then do
        cpos = 'cto'
        zerrsm = 'Error'
        zerrlm = 'To generation does not exist. Try using:' ,
          cprgens
        'setmsg msg(isrz003)'
      end
      if zerrsm = null then do
        if sysdsn("'"wdsn"("cmem")'") = "OK" then leave
        else do
          cpos = 'cmem'
          zerrsm  = 'Error'
          zerrlm  = "'"wdsn"("cmem")'" ,
            sysdsn("'"wdsn"("cmem")'")
          'Setmsg msg(isrz003)'
        end
      end
    end
  end
  if members.cmem = null then do
    zerrsm = 'Invalid Member'
    zerrlm = cmem 'is not a valid member name.'
    'setmsg msg(isrz003)'
    cmem = null
  end
  if datatype(cfrom) /= 'NUM' | datatype(cto) /= 'NUM'  then do
    zerrsm = 'Invalid Gen'
    zerrlm = 'Either the from or to generation is invalid.' ,
      'They must be relative generation number which' ,
      'are negative numbers.' ,
      'From:' cfrom 'To:' cto
    'setmsg msg(isrz003)'
    cmem = null
  end
  if cfrom > 0 | cto > 0 then do
    zerrsm = 'Invalid Gen'
    zerrlm = 'Either the from or to generation is invalid.' ,
      'They must be relative generation number which' ,
      'are negative numbers.' ,
      'From:' cfrom 'To:' cto
    'setmsg msg(isrz003)'
    cmem = null
  end
  if cmem /= null then do
    cbad = 0
    parse value '' with cbadfrom cbadto
    rc = test_gen(cmem cfrom)
    if rc = 1 then do
      cbad = 1
      cbadfrom = 'From:' cfrom
    end
    rc = test_gen(cmem cto)
    if rc = 1 then do
      cbad = cbad + 1
      cbadto = 'To:' cto
    end
    if cbad > 1 then genmsg = 'Both generations'
    else genmsg = 'A generation'
    if cbad > 0 then do
      zerrsm = 'Invalid Gen'
      zerrlm = genmsg 'specified for' cmem ,
        'is invalid:' cbadfrom cbadto
      'setmsg msg(isrz003)'
      cmem = null
    end
  end
  if cmem /= null then do
    scrp = crp
    call do_sort
    'tbtop' pdset
    do forever
      'tbskip' pdset
      if cmem < mbr then leave
      if cmem = mbr then if mgen = cfrom then cabso = mgen
      if cabso /= null then leave
    end
    'tbtop' pdset
    do forever
      'tbskip' pdset
      if cmem < mbr then leave
      if cmem = mbr then if mgen = cto then cabsn = mgen
      if cabsn /= null then leave
    end
    zerrsm  = null
    if cabsn = null then do
      crp = scrp
      zerrsm  = 'Error'
      zerrlm  = 'Generation' cto 'does not exist.'
      'Setmsg msg(isrz003)'
    end
    if cabso = null then do
      zerrsm  = 'Error'
      zerrlm  = 'Generation' cfrom 'does not exist.'
      'Setmsg msg(isrz003)'
    end
    if zerrsm  = null then call do_compare
  end
  return

  /* ------------------------------------------------------------- *
  * Do_Compare routine:                                           *
  *                                                               *
  * 1. Called by COMPARE command and                              *
  * 2. Called by Z line command                                   *
  * 3. calls PDSEGENM edit macro with option COM                  *
  *                                                               *
  * Compare will compare 2 members. If the from member is         *
  * generation 0 then it will be opened in Edit and compared      *
  * to to the to member.                                          *
  *                                                               *
  * If the to member is a generation then it will be copied       *
  * into a temp dataset for compare purposes.                     *
  *                                                               *
  * If the from member is a non-0 generation then it will         *
  * be copied into a temp member (defined in PDSEGENS using       *
  * the tempmem variable) and opened in View.                     *
  *                                                               *
  * The user may use the ISPF Edit or Replace commands to         *
  * save any changes made while in View. That member will not     *
  * be reflected in the member list until a refresh is performed. *
  * ------------------------------------------------------------- */
Do_Compare:
  if zdsngen < 1 then do
    zerrsm = 'Error'
    zerrlm = 'Compare is not supported in a dataset without' ,
      'generations.'
    'setmsg msg(isrz003)'
    return
  end
  parse value '' with todsn deltemp worktemp
  mbr = cmem
  if cto /= 0 then do
    mgen = cto
    call create_temp
    todsn = tdsn
  end
  else do
    todsn = "'"wdsn"("cmem")'"
  end
  mgen = cfrom
  if cfrom /= 0 then do
    call create_temp 'mem'
    deltemp = 1
  end
  /* ---------------------- *
  * Now Compare from to to *
  * ---------------------- */
  pdsemopt = 'COM'
  'vput (todsn todd cmem cto cfrom deltemp)'
  if cfrom = 0 then
  'edit dataid('pdsegend') member('cmem') gen('cfrom')' ,
    'macro(pdsegenm) parm(pdsemopt)'
  else 'view dataset('tdsn') confirm(no) chgwarn(no) macro(pdsegenm)' ,
    'parm(pdsemopt)'
  if deltemp = 1 then do
    Address TSO ,
      'Alloc f('pdsedd') shr reuse ds('pdsedsn')'
    x = proc_del(tempmem 0 pdsedd)
  end
  return

  /* ------------------------------------- *
  * Do_User routine:                      *
  * 1. Called by U line command           *
  *                                       *
  * - display prompting panel             *
  * - call create_temp to create temp d/s *
  *   if not generation 0                 *
  * - execute the user command            *
  * ------------------------------------- */
Do_user:
  if mgen < 0 then call create_temp
  else  zpdsendd = null
  if zpdsendd = null
  then zudsn = "'"wdsn"("mbr")'"
  else zudsn = tdsn

  do forever
    if msel /= 'U' then
    if lopt /= '/' then do
      bypass = 1
      zucmd = msel '/'
      xrc = 0
    end
    if bypass /= 1 then do
      call pfshow 'off'
      'Addpop Row(3) Column(3)'
      'Display Panel(pdseguc)'
      xrc = rc
      'Rempop'
      call pfshow 'reset'
    end
    if bypass = 1 then do
      bypass = 0
      xrc = 0
    end
    if xrc > 0 then do
      zerrsm = 'Cancelled'
      zerrlm = 'User command cancelled.'
      'Setmsg msg(isrz003)'
      if zpdsendd /= null then
      Address TSO ,
        'Free f('zpdsendd') Delete'
      return
    end
    if pos('/',zucmd) > 0 then leave
    zerrsm = 'Error'
    zerrlm = 'You must specify the location for the' ,
      'current dataset(member) using a /.'
    'Setmsg msg(isrz003)'
  end

  /* -------------------------- *
  * Now build the user command *
  * -------------------------- */
  p = pos('/',zucmd)
  zusercmd = left(zucmd,p-1) zudsn substr(zucmd,p+1)
  /* ------------------------ *
  * Now execute the user     *
  * command                  *
  * ------------------------ */
  call logit 'Executing User command:' zusercmd
  'Control display save'
  'select cmd('zusercmd')'
  if rc = 20 then do
    'setmsg msg(isrz003)'
  end
  if zpdsendd /= null
  then Address TSO ,
    'Free f('zpdsendd') Delete'
  'Control display restore'
  return

  /* ------------------------------------- *
  * Do_eXecute routine:                   *
  * 1. Called by X line command           *
  *                                       *
  * - call create_temp to create temp d/s *
  *   if not generation 0                 *
  * - eXecute the temp dataset            *
  * ------------------------------------- */
Do_eXecute:
  if mgen < 0 then call create_temp
  else  zpdsendd = null
  /* ------------------------ *
  * Now eXecute the temp d/s *
  * or the real d/s          *
  * ------------------------ */
  do forever
    if zpdsendd = null
    then sxdsn = "'"wdsn"("mbr")'"
    else sxdsn = tdsn
    call pfshow 'off'
    'Addpop Row(3) Column(3)'
    'Display Panel(pdsegxc)'
    xrc = rc
    'Rempop'
    call pfshow 'reset'
    if xrc > 0 then do
      zerrsm = 'Cancelled'
      zerrlm = 'Exec command cancelled.'
      'Setmsg msg(isrz003)'
      if zpdsendd /= null then
      Address TSO ,
        'Free f('zpdsendd') Delete'
      return
    end
    Address TSO
    if zpdsendd /= null
    then do
      'Exec' tdsn "'"zxcmd"'"
      'Free f('zpdsendd') Delete'
    end
    else "Exec  '"wdsn"("mbr")' '"zxcmd"'"
    Address ISPExec
    return
  end

  /* ------------------------------------- *
  * Do_Submit routine:                    *
  *    Called by J line command           *
  *    and by SUBmit command              *
  *                                       *
  * - call create_temp to create temp d/s *
  *   if not generation 0                 *
  * - submit the temp dataset             *
  * ------------------------------------- */
Do_Submit:
  if mgen < 0 then call create_temp
  else  zpdsendd = null

  /* ---------------- *
  | Check Submit DCB |
  * ---------------- */
  rc = test_submit()
  if rc > 0 then return

  /* ------------------------ *
  * Now Submit the temp d/s  *
  * or the real d/s          *
  * ------------------------ */
  Address TSO

  /* ---------------------------------------------- *
  * Get the current state of the TSO PROFILE MSGID *
  * and if on turn off for the submit.             *
  * ---------------------------------------------- */
  call outtrap 'x.'
  'profile'
  call outtrap 'off'
  if wordpos('NOMSGID',x.1) > 0 then msg = 'off'
  if wordpos('MSGID',x.1) > 0 then msg = 'on'
  if msg = 'on' then 'profile nomsgid'

  /* ------------------ *
  * Now submit the JCL *
  * ------------------ */
  call outtrap 'x.'
  if zpdsendd /= null
  then do
    'Submit' tdsn
    'Free f('zpdsendd') Delete'
  end
  else "submit '"wdsn"("mbr")'"
  call outtrap 'off'
  if msg = 'on' then 'profile msgid'

  Address ISPExec
  zerrsm  = 'Submitted'
  zerrlm  = x.1
  'setmsg msg(isrz003)'
  return

  /* ------------------------------------- *
  * Do_eMail routine:                     *
  * 1. Called by M line command           *
  *                                       *
  * - call create_temp to create temp d/s *
  *   if not generation 0                 *
  * - call %xmitipfe to e-mail            *
  * ------------------------------------- */
Do_eMail:
  if mgen < 0 then call create_temp
  else  zpdsendd = null
  /* ---------------------- *
  * Now eMail the temp d/s *
  * ---------------------- */
  if zpdsendd /= null
  then do
    cmd = "%xmitipfe" ,
      "File("tdsn")" ,
      "Filename("mbr".txt)" ,
      "Format(Txt)" ,
      "Subject("wdsn"  Member "mbr" Generation" mgen")"
    "Select cmd("cmd")"
    mrc = rc
    Address TSO 'Free f('zpdsendd') Delete'
  end
  else do
    cmd = "%xmitipfe" ,
      "File('"wdsn"("mbr")')" ,
      "Filename("mbr".txt)" ,
      "Format(Txt)" ,
      "Subject("wdsn" Member "mbr" Generation" mgen")"
    "Select cmd("cmd")"
    mrc = rc
  end
  if mrc > 0 then do
    zerrsm = 'Error'
    zerrlm = 'E-Mail (M) is not supported on this system. Contact' ,
      'your systems programmer.'
    'Setmsg msg(isrz003)'
  end
  return

  /* ---------------------------------------------- *
  | Create a temporary dataset, or member, for use |
  | with member generations.                       |
  * ---------------------------------------------- */
Create_Temp:
  arg temp_opt
  ct_space = 5
  zdslrec = zdslrec + 0
  if zdslrec /= null then
     if mcur /= null then do
      ct_space = mcur * zdslrec
      ct_space = (ct_space%50000) + 5
     end
  if temp_opt = null then do
    zpdsendd = randstr()
    if sysvar('syspref') = null then hlq = sysvar('sysuid')
    else hlq = sysvar('syspref')
    tdsn = "'"hlq'.PDSEGEN.TEMP.'zpdsendd'.'mbr"'"
    call logit 'Creating temp dataset:' tdsn
    if left(zdsrf,1) = 'F' then zdsrf = 'F B'
    else zdsrf = 'V B'
    Address TSO ,
      'Alloc f('zpdsendd') ds('tdsn') new spa('ct_space','ct_space') tr' ,
      'Recfm('zdsrf') lrecl('zdslrec') blksize('zdsblk')' ,
      def_unit
  end
  else do
    tdsn = "'"wdsn"("tempmem")'"
  end
  /* ---------------------------------- *
  * Copy all records from 'old' member *
  * using the Replace Edit command     *
  * ---------------------------------- */
  pdsemopt = 'R'
  pdsecpds = tdsn
  'vput (pdsecpds)'
  'edit dataid('pdsegend') member('mbr') gen('mgen')' ,
    'macro(pdsegenm) parm(pdsemopt)'
  return

  /* ------------------------------------------------------- *
  * Setup Filter procedure                                  *
  *                                                         *
  *    if filter is x then test for member x                *
  *       type is 3                                         *
  *    if filter is x: then test for member starting with x *
  *       type is 1                                         *
  *    if filter is x* then test for member starting with x *
  *       type is 1                                         *
  *    if filter is *x then test for member ending with x   *
  *       type is 5                                         *
  *    if filter is x/ then test for member with x anywhere *
  *       type is 2                                         *
  *    if filter is /x then test for member with x anywhere *
  *       type is 2                                         *
  *    if filter has * or %                                 *
  *       type is 4  (uses pdsegmat rexx function)          *
  *    if filter has : within                               *
  *       type is 6  from:to                                *
  *    if filter is (xxx yyy)                               *
  *       type is 7                                         *
  *                                                         *
  *    * and OFF turn off Filtering                         *
  *                                                         *
  * variables:                                              *
  *    tfilter = the test filter member                     *
  *    tfilterl = length of tfilter                         *
  *    tfiltert = filter type                               *
  *    tfilter_from = from member                           *
  *    tfilter_from = from member                           *
  *    tfilter_list = list of members                       *
  * ------------------------------------------------------- */
Setup_Filter:
  filter = strip(filter)
  if filter = '/' then filter = '*'
  if words(filter) > 1 then
  if left(filter,1) /= '(' then
  if wordpos(word(filter,1),date_filter_words) = 0 then do
    dfilter = subword(filter,2)
    filter = word(filter,1)
  end
  else dfilter = null
  Select
    When wordpos(word(filter,1),date_filter_words) > 0 then do
      zcmd = filter
      call setup_date_filter
      filter = null
      zcmd   = null
      call proc_refresh
    end
    When translate(filter) = 'OFF' then do
      parse value '' with tfilter tfilterl tfiltert ,
        date_filter date_filter_title ,
        filter filter_title
      call proc_refresh
    end
    When strip(filter) = '*' then do
      filter = null
      filter_title = null
      parse value '' with tfilter tfilterl tfiltert
      call proc_refresh
    end
    When left(filter,1) = '(' then do
      parse value filter with '('tfilter_list')'
      tfiltert = 7
    end
    When right(filter,1) = ':' then do
      tfilterl = length(filter) -1
      tfilter  = left(filter,tfilterl)
      tfiltert = 1
    end
    When pos(":",filter) > 1 then do
      tfilter  = filter
      parse value filter with tfilter_from":"tfilter_to .
      tfiltert = 6
    end
    When pos('%',filter) > 0 then do
      if length(filter) > 1 then
      tfiltert = 4
    end
    When pos('?',filter) > 0 then do
      filter = translate(filter,'%','?')
      if length(filter) > 1 then
      tfiltert = 4
    end
    When pos('*',filter) > 0 then do
      px = pos('*',filter)
      py = pos('*',filter,px+1)
      tfiltert = null
      if px = length(filter) then do
        tfiltert = 1
        tfilterl = length(filter)-1
        tfilter = left(filter,px-1)
      end
      if px = 1 then do
        tfiltert = 5
        tfilterl = length(filter)-1
        tfilter = substr(filter,px+1)
      end
      if py > 0 then tfiltert = 4
      if tfiltert = null then tfiltert = 4
    end
    When pos('/',filter) > 0 then do
      if pos('/',filter) > 1 then do
        tfilterl = length(filter) -1
        tfilter  = left(filter,tfilterl)
        tfiltert = 2
      end
      else do
        tfilterl = length(filter) -1
        tfilter  = substr(filter,2)
        tfiltert = 2
      end
    end
    Otherwise do
      tfilterl = length(filter)
      tfilter  = filter
      tfiltert = 3
    end
  end
  if filter /= null then do
    filter_title = filter
    if dfilter /= null then do
      zcmd = dfilter
      call setup_date_filter
      zcmd = null
    end
    signal proc_refresh
  end
  return

  /* --------------------------------- *
  * Proc_Refresh routine              *
  *                                   *
  * Call the close routine and then   *
  * start over from the beginning     *
  * with a clean updated member list. *
  * --------------------------------- */
Proc_Refresh:
  if open_pdse = null then return
  s_zerrsm = zerrsm
  s_zerrlm = zerrlm
  call logit 'Performing Refresh' wdsn
  call close
  parse value '' with zcmd lopt lopts
  zerrsm = s_zerrsm
  zerrlm = s_zerrlm
  signal start

  /* ------------------------- *
  * Close and Free the Dataid *
  * ------------------------- */
Close:
  if open_pdse = null then return
  call logit 'Closing Dataset:' wdsn
  "LMClose Dataid("pdsegend")"
  "LMFree  Dataid("pdsegend")"
  if closed = 0 then
  'TBClose' pdset
  closed = 1
  if metric_table /= null then
  'TBClose' tblmet
  metric_table = null
  zcmd = null
  return

Logit:
  parse arg zerrlm
  zerrsm = 'PDSEGEN'
  Address ISPExec
  'log msg(isrz003)'
  parse value '' with zerrsm zerrlm
  return

  /* ------------------------------------------------------- *
  * Filter testing using filter type                        *
  *                                                         *
  * return code 0 to bypass                                 *
  *             1 to accept                                 *
  * ------------------------------------------------------- */
Proc_Filter:
  arg filter_member
  rtn = 1
  Select
    /* filter = x */
    When tfiltert = 3 then do
      if tfilter /= filter_member then rtn = 0
    end
    /* filter = x: or x* */
    When tfiltert = 1 then do
      if left(filter_member,tfilterl) /= tfilter then rtn = 0
    end
    /* filter = x/ or /x */
    When tfiltert = 2 then do
      if pos(tfilter,filter_member) = 0 then rtn = 0
    end
    /* filter has * or % */
    When tfiltert = 4 then do
      rtn = pdsegmat(filter_member,filter)
    end
    /* filter = *x */
    When tfiltert = 5 then do
      if right(filter_member,tfilterl) /= tfilter then rtn = 0
    end
    /* filter = x:y */
    When tfiltert = 6 then do
      rtn = 0
      if left(filter_member,length(tfilter_from)) >= ,
        tfilter_from then
      if left(filter_member,length(tfilter_to)) <= ,
        tfilter_to then rtn = 1
    end
    When tfiltert = 7 then do
      rtn = 0
      do mc = 1 to words(tfilter_list)
        mw = word(tfilter_list,mc)
        select
          when pos('/',mw) > 0 then do
            mw = strip(translate(mw,' ','/'))
            if pos(mw,filter_member) > 0 then rtn = 1
          end
          when filter_member = mw then rtn = 1
          when pos('*',mw) > 0 then do
            rc = pdsegmat(filter_member,mw)
            if rc = 1 then rtn = 1
          end
          when pos('%',mw) > 0 then do
            rc = pdsegmat(filter_member,mw)
            if rc = 1 then rtn = 1
          end
          otherwise nop
        end
      end
    end
    Otherwise nop
  end
  return rtn

  /* --------------------------------------------------- *
  * do_klone routine:                                   *
  *                                                     *
  * Copy the requested base member to a new name        *
  * --------------------------------------------------- */
Do_klone:
  "LMInit Dataid(rename) dataset("pdsedsn")"
  "LMInit Dataid(toname) dataset("pdsedsn")"
  Address TSO ,
    'Alloc f('pdsedd') shr reuse ds('pdsedsn')'
  "lmcopy fromid("rename") todataid("toname")" ,
    "frommem("mbr") tomem("znewmem")"
  Address TSO ,
    'Free f('pdsedd')'
  "LMFree Dataid("rename")"
  "LMFree Dataid("toname")"
  return

  /* --------------------------------------------------- *
  * Do_Rename routine:                                  *
  *                                                     *
  * Copy each member using oldest generation to newest  *
  * to the new name to preserve the relative generation *
  * order and then delete the 'from' member.            *
  * --------------------------------------------------- */
Do_Rename:
  "LMInit Dataid(rename) dataset("pdsedsn")"
  "LMInit Dataid(toname) dataset("pdsedsn")"
  Address TSO ,
    'Alloc f('pdsedd') shr reuse ds('pdsedsn')'
  if strip(rgens) = null then rgens = 0
  do ix = words(rgens) to 1 by -1
    igen = word(rgens,ix)
    parse value rmem.igen with x y'\'iver'\'imod'\'cdate,
      '\'mdate'\' mtime'\'mcur'\'minit,
      '\'mmod'\'muser
    if igen = 0 then do
      "lmcopy fromid("rename") todataid("toname")" ,
        "frommem("rmbr") tomem("znewmem") replace"
      x = proc_del(rmbr igen pdsedd)
    end
    else do
      /* ---------------------------------- *
      * Copy all records from 'old' member *
      * using the Replace Edit command     *
      * ---------------------------------- */
      pdsemopt = 'R'
      pdsecpds = "'"wdsn"("znewmem")'"
      'vput (pdsecpds)'
      'edit dataid('rename') member('rmbr') gen('igen')' ,
        'macro(pdsegenm) parm(pdsemopt)'
      /* -------------------------------- *
      * Now delete the member/generation *
      * -------------------------------- */
      x = proc_del(rmbr igen pdsedd)
      /* ------------------------------------------------ *
      * Update the target member with the old ISPF stats *
      * ------------------------------------------------ */
      'LMMStats Dataid('rename')' ,
        'Member('znewmem') version('iver') modlevel('imod')' ,
        'Created('cdate') Moddate('mdate')' ,
        'Modtime('mtime') Cursize('mcur')' ,
        'Initsize('minit') Modrecs('mmod')' ,
        'User('muser')'
    end
  end
  Address TSO ,
    'Free f('pdsedd')'
  "LMFree Dataid("rename")"
  "LMFree Dataid("toname")"
  return

Do_Rename_Swap:
  /* ------------------------------- *
  | Rename Swap                     |
  |                                 |
  | 1. Prompt for both member names |
  | 2. Rename 1st to temp           |
  | 3. Rename 2nd to 1st            |
  | 4. Rename temp to 2nd           |
  * ------------------------------- */
  if gen_hide = 1 then do
    zerrsm = 'Warning'
    zerrlm = 'Rename Swap is not supported when generations are' ,
      'hidden. Use the REFRESH command to restore the' ,
      'generations to the member list and then you can' ,
      'use rename.'
    'Setmsg msg(isrz003)'
  end
  zerrsm  = null
  znewmem = null
  if agen > 0 then do
    zerrsm  = 'Error'
    zerrlm  = 'Rename-Swap can only be done on a generation 0' ,
      'member.'
    'Setmsg Msg(isrz003)'
    znewmem = null
  end
  if lopt /= null then
  if left(lopt,1) /= '*' then do
    znewmem = translate(lopt)
    bypass = 1
  end
  if zerrsm = null then do forever
    zerrsm  = null
    if bypass /= 1 then do
      call pfshow 'off'
      'Addpop Row(3) Column(3)'
      'Display Panel(pdsegrns)'
      xrc = rc
      'Rempop'
      call pfshow 'reset'
    end
    else do
      xrc = 0
      bypass = 0
    end
    if xrc > 0 then do
      znewmem = null
      leave
    end
    if xrc = 0 then do
      if znewmem = null then leave
      if sysdsn("'"wdsn"("znewmem")'") = 'OK' then leave
      zerrsm  = 'Error'
      zerrlm  = "'"wdsn"("znewmem")' does NOT exist" ,
        "and the swap cannot be done."
      'Setmsg Msg(isrz003)'
    end
  end
  if znewmem = null then
  if zerrsm  = null then do
    zerrsm  = 'Cancelled'
    zerrlm  = 'Rename-Swap (Q) cancelled'
    'Setmsg Msg(isrz003)'
  end
  if znewmem = mbr then
  if zerrsm  = null then do
    zerrsm  = 'Cancelled'
    zerrlm  = 'Rename-Swap (Q) cancelled' ,
      'as the from and to member names are the same.'
    'Setmsg Msg(isrz003)'
  end
  if zerrsm  = null then do
    save_top = ztdtop
    from_mbr = mbr
    to_mbr   = znewmem
    temp_mbr = tempmem
    call logit 'Rename Swap' from_mbr 'and' to_mbr
    /* make sure the tempmem doesn't exist */
    Address TSO
    'Alloc f('pdsedd') shr reuse ds('pdsedsn')'
    x = proc_del(tempmem 0 pdsedd)
    'Free f('pdsedd')'
    Address ISPExec
    /* rename from_mbr to temp_mbr */
    rmbr = from_mbr
    znewmem = temp_mbr
    rgens = members.rmbr
    call logit 'Rename Swap' from_mbr 'to' znewmem
    call do_rename
    /* rename to_mbr to from_mbr */
    rmbr = to_mbr
    znewmem = from_mbr
    rgens = members.rmbr
    call logit 'Rename Swap' to_mbr 'to' znewmem
    call do_rename
    /* rename temp_mbr to to_mbr */
    mbr = temp_mbr
    call update_mem
    mbr = temp_mbr
    call clean_up 'x'
    rmbr = temp_mbr
    znewmem = to_mbr
    rgens = members.rmbr
    call logit 'Rename Swap' mbr 'to' znewmem
    call do_rename
    /* clean up the member info */
    mbr = from_mbr
    call update_mem
    mbr = from_mbr
    call clean_up 'x'
    mbr = to_mbr
    call update_mem
    mbr = temp_mbr
    call clean_up 'x'
    mbr = temp_mbr
    call update_mem
    /* now update the table info */
    'tbtop' pdset
    mbr = from_mbr
    agen = 0
    'tbscan' pdset 'arglist(mbr agen)'
    'tbget' pdset
    lopt = '*RENSWAP'
    lopts = '*Q'
    'tbput' pdset
    'tbtop' pdset
    mbr = to_mbr
    agen = 0
    'tbscan' pdset 'arglist(mbr agen)'
    'tbget' pdset
    lopt = '*RENSWAP'
    lopts = '*Q'
    'tbput' pdset
    'tbtop' pdset
    'tbskip' pdset 'skip('save_top')'
  end
  return

  /* ------------------------------------ *
  * Setup for Progress Indicator Display *
  * ------------------------------------ */
set_prog:
  'tbstats' pdset 'rowcurr(tabr)'
  division = 10
  incr = (tabr % division) + 1
  progc = '**'
  perc# = 0
  return

  /* -------------------------------------------------- *
  * Reset Color routine                                *
  *                                                    *
  * Sets the color for the columns back to the default *
  * -------------------------------------------------- */
Reset_Color:
  clrn      = base_color
  clrmbr    = base_color
  clrcdate  = base_color
  clrchang  = base_color
  clrmcur   = base_color
  clrminit  = base_color
  clrmmod   = base_color
  clrmuser  = base_color
  return

  /* ---------------- *
  * Display progress *
  * ---------------- */
Disp_Progress:
  if qfind//incr = 0 then do
    progc = progc'**'
    perc# = perc# + division
    perc = perc#"%"
    prog = progc '('perc')'
    "Control Display Lock"
    call pfshow 'off'
    'Addpop Row(3) Column(3)'
    'display panel(pdsegfp)'
    'Rempop'
    call pfshow 'reset'
  end
  return

  /* ------------------------------------------ *
  * Delete the base member and all generations *
  * from the table display                     *
  * ------------------------------------------ */
delete_mem:
  omem = mbr
  'tbtop' pdset
  do forever
    'tbvclear' pdset
    mbr = omem
    'tbscan' pdset 'arglist(mbr)'
    if rc > 0 then leave
    'tbdelete' pdset
  end
  mbr = omem
  return

  /* ------------------------------------------ *
  * Delete All members and generations in the  *
  * member display list                        *
  * ------------------------------------------ */
Prune_all:
  prune = null
  'tbtop' pdset
  Address TSO ,
    'Alloc f('pdsedd') shr reuse ds('pdsedsn')'
  do forever
    'tbskip' pdset
    if rc > 0 then leave
    if agen = 0 then do
      x = proc_del(mbr agen pdsedd)
      'tbdelete' pdset
    end
  end
  Address TSO ,
    'Free f('pdsedd')'
  if filter /= null then do
    pfilterm = ' and filter has been turned off.',
      'The filter was:' filter
    filter = null
    filter_title = null
  end
  else pfilterm = '.'
  zerrsm = 'Pruned'
  if pfilterm = null then
  zerrlm = 'All members and generations in the display' ,
    'list have been deleted'pfilterm
  else
  zerrlm = 'The filtered members and generations have' ,
    'been deleted'pfilterm
  'setmsg msg(isrz003)'
  call proc_refresh
  return

  /* ---------------------------------------------------- *
  * Do_Prune Routine                                     *
  *                                                      *
  * Prune older generations to clean up the PDSE Library *
  * If the prune varaiable is RESET then remove all      *
  * members and generations.                             *
  * ---------------------------------------------------- */
Do_Prune:
  tpruned   = 0
  pmbr      = null
  Address TSO ,
    'Alloc f('pdsedd') shr reuse ds('pdsedsn')'
  do forever
    'tbskip' pdset
    if rc > 0 then do
      zerrsm = 'Pruned'
      zerrlm = tpruned 'generations pruned.'
      'Setmsg msg(isrz003)'
      'tbtop' pdset
      leave
    end
    else do
      if mgen < (prune * -1) then do
        x = proc_del(mbr agen pdsedd)
        'TBDelete' pdset
        tpruned = tpruned + 1
      end
    end
  end
  prune = null
  Address TSO ,
    'Free f('pdsedd')'
  return

  /* ---------------------------------------------------------- *
  * Do_Find routine                                            *
  *                                                            *
  * - If a PDSE or PDS with zdsngen (maxgen) = 0 then use      *
  *   pdsegfnd (superc)                                        *
  * - if not do PDSEGEN enhanced find (includes generations)   *
  * ---------------------------------------------------------- */
Do_Find:
  zcmd = null
  fhit = 0
  if zdsngen = 0 then
  do forever
    /* build selection list */
    ftmems = null
    'tbtop' pdset
    if ft /= null then do
      'tbskip' pdset
      if rc > 0 then leave
      ftmems = ftmems mbr
    end
    'vput (ftmems)'
    address tso "%pdsegfnd '"wdsn"'" pdsegfnd '/\/\'
    'vget (mhits)'
    if strip(mhits) /= null then do
      'tbtop' pdset
      do forever
        'tbskip' pdset
        if rc > 0 then leave
        if wordpos(mbr,mhits) = 0 then 'tbdelete' pdset
      end
    end
    'tbtop' pdset
    zerrsm  = words(mhits) 'hits'
    zerrlm  = 'String:' pdsegfnd 'found in' words(mhits) 'members.'
    'Setmsg msg(isrz003)'
    return
  end
  'tbtop' pdset
  mfind = 0
  qfind = 0
  pdsemopt = 'F'
  'vput (pdsegfnd)'
  call set_prog
  do forever
    'tbskip' pdset
    if rc > 0 then leave
    qfind = qfind + 1
    call  Disp_Progress
    /* find string in member name ? */
    if pos(pdsegfnd,mbr) > 0 then do
      pdsegrc = 0
    end
    else do
      /* find string within member/generation */
      'edit dataid('pdsegend') member('mbr') gen('agen')' ,
        'macro(pdsegenm) parm(pdsemopt)'
      'vget pdsegrc'
    end
    if pdsegrc > 0 then 'tbdelete' pdset
    else mfind = mfind + 1
  end
  'tbtop' pdset
  zerrsm  = mfind 'hits'
  zerrlm  = 'String:' pdsegfnd 'found in' mfind 'members.'
  'Setmsg msg(isrz003)'
  if mfind = 0 then
  call proc_refresh
  return

  /* --------------------------------------------------------- *
  * Update_DSList routine                                     *
  *                                                           *
  * Updates the recently used dsname variables in a push-down *
  * stack process.                                            *
  *                                                           *
  * variables pdseds01 thru pdseds25                          *
  * --------------------------------------------------------- */
Update_DSList:
  'vget (pdseds01 pdseds02 pdseds03 pdseds04' ,
    'pdseds05 pdseds06 pdseds07 pdseds08' ,
    'pdseds09 pdseds10 pdseds11 pdseds12' ,
    'pdseds13 pdseds14 pdseds15 pdseds16 ' ,
    'pdseds17 pdseds18 pdseds19 pdseds20 ' ,
    'pdseds21 pdseds22 pdseds23 pdseds24 ' ,
    'pdseds25)' ,
    'profile'

  /* ------------------------------------- *
  * Add dsnames to a variable for testing *
  * ------------------------------------- */
  dsnslist = null
  dsnslist = pdseds01 pdseds02 pdseds03 pdseds04 ,
    pdseds05 pdseds06 pdseds07 pdseds08 ,
    pdseds09 pdseds10 pdseds11 pdseds12 ,
    pdseds13 pdseds14 pdseds15 pdseds16 ,
    pdseds17 pdseds18 pdseds19 pdseds20 ,
    pdseds21 pdseds22 pdseds23 pdseds24 ,
    pdseds25

  /* ---------------------------- *
  * Remove the requested dataset *
  * ---------------------------- */
  if left(zcmd,1) = 'R' then do
    rnum = substr(zcmd,2)
    if datatype(rnum) /= 'NUM' then return
    dsl_dsn = subword(dsnslist,rnum,1)
    dsnslist = delword(dsnslist,rnum,1)
    pdseds25 = word(dsnslist,25)
    pdseds24 = word(dsnslist,24)
    pdseds23 = word(dsnslist,23)
    pdseds22 = word(dsnslist,22)
    pdseds21 = word(dsnslist,21)
    pdseds20 = word(dsnslist,20)
    pdseds19 = word(dsnslist,19)
    pdseds18 = word(dsnslist,18)
    pdseds17 = word(dsnslist,17)
    pdseds16 = word(dsnslist,16)
    pdseds15 = word(dsnslist,15)
    pdseds14 = word(dsnslist,14)
    pdseds13 = word(dsnslist,13)
    pdseds12 = word(dsnslist,12)
    pdseds11 = word(dsnslist,11)
    pdseds10 = word(dsnslist,10)
    pdseds09 = word(dsnslist,09)
    pdseds08 = word(dsnslist,08)
    pdseds07 = word(dsnslist,07)
    pdseds06 = word(dsnslist,06)
    pdseds05 = word(dsnslist,05)
    pdseds04 = word(dsnslist,04)
    pdseds03 = word(dsnslist,03)
    pdseds02 = word(dsnslist,02)
    pdseds01 = word(dsnslist,01)
    zcmd     = null
    zerrsm = 'Removed'
    zerrlm = 'Dataset' dsl_dsn 'removed from the table.'
    'Setmsg msg(isrz003)'
    call save_dslist
  end

  /* ------------------------------------- *
  * Move the requested dataset to the top *
  * ------------------------------------- */
  if left(zcmd,1) = 'M' then do
    rnum = substr(zcmd,2)
    if datatype(rnum) /= 'NUM' then return
    movedsn  = word(dsnslist,rnum)
    dsnslist = delword(dsnslist,rnum,1)
    dsnslist = movedsn dsnslist
    pdseds25 = word(dsnslist,25)
    pdseds24 = word(dsnslist,24)
    pdseds23 = word(dsnslist,23)
    pdseds22 = word(dsnslist,22)
    pdseds21 = word(dsnslist,21)
    pdseds20 = word(dsnslist,20)
    pdseds19 = word(dsnslist,19)
    pdseds18 = word(dsnslist,18)
    pdseds17 = word(dsnslist,17)
    pdseds16 = word(dsnslist,16)
    pdseds15 = word(dsnslist,15)
    pdseds14 = word(dsnslist,14)
    pdseds13 = word(dsnslist,13)
    pdseds12 = word(dsnslist,12)
    pdseds11 = word(dsnslist,11)
    pdseds10 = word(dsnslist,10)
    pdseds09 = word(dsnslist,09)
    pdseds08 = word(dsnslist,08)
    pdseds07 = word(dsnslist,07)
    pdseds06 = word(dsnslist,06)
    pdseds05 = word(dsnslist,05)
    pdseds04 = word(dsnslist,04)
    pdseds03 = word(dsnslist,03)
    pdseds02 = word(dsnslist,02)
    pdseds01 = word(dsnslist,01)
    zcmd     = null
    zerrsm = 'Moved'
    zerrlm = 'Dataset' movedsn 'moved to the top of the table.'
    'Setmsg msg(isrz003)'
    call save_dslist
  end

  /* ------------------------------------- *
  * Sort the datasets in the change list  *
  * ------------------------------------- */
  if word(zcmd,1) = 'SORT' then do
    sort_order = word(zcmd,2)
    if sort_order = null then sort_order = 'A'
    if sort_order /= 'A' then sort_order = 'D'
    zcmd     = null
    dstem.25 = word(dsnslist,25)
    dstem.24 = word(dsnslist,24)
    dstem.23 = word(dsnslist,23)
    dstem.22 = word(dsnslist,22)
    dstem.21 = word(dsnslist,21)
    dstem.20 = word(dsnslist,20)
    dstem.19 = word(dsnslist,19)
    dstem.18 = word(dsnslist,18)
    dstem.17 = word(dsnslist,17)
    dstem.16 = word(dsnslist,16)
    dstem.15 = word(dsnslist,15)
    dstem.14 = word(dsnslist,14)
    dstem.13 = word(dsnslist,13)
    dstem.12 = word(dsnslist,12)
    dstem.11 = word(dsnslist,11)
    dstem.10 = word(dsnslist,10)
    dstem.9 = word(dsnslist,09)
    dstem.8 = word(dsnslist,08)
    dstem.7 = word(dsnslist,07)
    dstem.6 = word(dsnslist,06)
    dstem.5 = word(dsnslist,05)
    dstem.4 = word(dsnslist,04)
    dstem.3 = word(dsnslist,03)
    dstem.2 = word(dsnslist,02)
    dstem.1 = word(dsnslist,01)
    dstem.0 = 25
    /* --------------------------------------- *
    * rexx command to sort a stem variable    *
    * Simple bubble sort of "stem' by dstem.1 *
    * Ken Singer, Shell Oil, Houston          *
    * --------------------------------------- */
    ctr =  dstem.0
    /* SORT Ascending */
    if sort_order = 'A' then
    do y = 1 to  ctr - 1
      do x = y+1 to ctr
        if dstem.x < dstem.y then do
          /* swap these 2 entries */
          t1 = dstem.y ;
          dstem.y = dstem.x
          dstem.x = t1
        end
      end x
    end y
    else
    do y = 1 to  ctr - 1
      do x = y+1 to ctr
        if dstem.x > dstem.y then do
          /* swap these 2 entries */
          t1 = dstem.y ;
          dstem.y = dstem.x
          dstem.x = t1
        end
      end x
    end y
    dsnslist = dstem.1 dstem.2 dstem.3 dstem.4 dstem.5 ,
      dstem.6 dstem.7 dstem.8 dstem.9 dstem.10 ,
      dstem.11 dstem.12 dstem.13 dstem.14 dstem.15 ,
      dstem.16 dstem.17 dstem.18 dstem.19 dstem.20 ,
      dstem.21 dstem.22 dstem.23 dstem.24 dstem.25
    pdseds25 = word(dsnslist,25)
    pdseds24 = word(dsnslist,24)
    pdseds23 = word(dsnslist,23)
    pdseds22 = word(dsnslist,22)
    pdseds21 = word(dsnslist,21)
    pdseds20 = word(dsnslist,20)
    pdseds19 = word(dsnslist,19)
    pdseds18 = word(dsnslist,18)
    pdseds17 = word(dsnslist,17)
    pdseds16 = word(dsnslist,16)
    pdseds15 = word(dsnslist,15)
    pdseds14 = word(dsnslist,14)
    pdseds13 = word(dsnslist,13)
    pdseds12 = word(dsnslist,12)
    pdseds11 = word(dsnslist,11)
    pdseds10 = word(dsnslist,10)
    pdseds09 = word(dsnslist,09)
    pdseds08 = word(dsnslist,08)
    pdseds07 = word(dsnslist,07)
    pdseds06 = word(dsnslist,06)
    pdseds05 = word(dsnslist,05)
    pdseds04 = word(dsnslist,04)
    pdseds03 = word(dsnslist,03)
    pdseds02 = word(dsnslist,02)
    pdseds01 = word(dsnslist,01)
    call save_dslist
    return
  end

  /* ------------------------------------- *
  * Clear the table                       *
  * ------------------------------------- */
  if zcmd = 'CLEAR' then do
    zcmd     = null
    parse value '' with dsnslist fqdsn ,
      pdseds01 pdseds02 pdseds03 pdseds04 ,
      pdseds05 pdseds06 pdseds07 pdseds08 ,
      pdseds09 pdseds10 pdseds11 pdseds12 ,
      pdseds13 pdseds14 pdseds15 pdseds16 ,
      pdseds17 pdseds18 pdseds19 pdseds20 ,
      pdseds21 pdseds22 pdseds23 pdseds24 ,
      pdseds25
    call save_dslist
    return
  end

  /* -------------------------------- *
  * Fully qualify the current dsname *
  * -------------------------------- */
  if strip(pdsedsn) = null then return
  if pdsedsn = '*' > 0 then return
  if left(pdsedsn,1) /= "'" then do
    if sysvar('syspref') = null
    then fqdsn = "'"pdsedsn"'"
    else fqdsn = "'"sysvar("syspref")"."pdsedsn"'"
  end
  else fqdsn = pdsedsn

  /* ------------------------------------------ *
  * Now test to see if the current pdse dsname *
  * is in the list - if so exit                *
  * ------------------------------------------ */
  if wordpos(fqdsn,dsnslist) > 0 then return

  /* ----------------------------- *
  * Now update the ispf variables *
  * ----------------------------- */
  pdseds25 = word(dsnslist,24)
  pdseds24 = word(dsnslist,23)
  pdseds23 = word(dsnslist,22)
  pdseds22 = word(dsnslist,21)
  pdseds21 = word(dsnslist,20)
  pdseds20 = word(dsnslist,19)
  pdseds19 = word(dsnslist,18)
  pdseds18 = word(dsnslist,17)
  pdseds17 = word(dsnslist,16)
  pdseds16 = word(dsnslist,15)
  pdseds15 = word(dsnslist,14)
  pdseds14 = word(dsnslist,13)
  pdseds13 = word(dsnslist,12)
  pdseds12 = word(dsnslist,11)
  pdseds11 = word(dsnslist,10)
  pdseds10 = word(dsnslist,09)
  pdseds09 = word(dsnslist,08)
  pdseds08 = word(dsnslist,07)
  pdseds07 = word(dsnslist,06)
  pdseds06 = word(dsnslist,05)
  pdseds05 = word(dsnslist,04)
  pdseds04 = word(dsnslist,03)
  pdseds03 = word(dsnslist,02)
  pdseds02 = word(dsnslist,01)
  pdseds01 = fqdsn
  call save_dslist
  return

Save_dslist:
  'vput (pdseds01 pdseds02 pdseds03 pdseds04' ,
    'pdseds05 pdseds06 pdseds07 pdseds08' ,
    'pdseds09 pdseds10 pdseds11 pdseds12' ,
    'pdseds13 pdseds14 pdseds15 pdseds16' ,
    'pdseds17 pdseds18 pdseds19 pdseds20' ,
    'pdseds21 pdseds22 pdseds23 pdseds24' ,
    'pdseds25)' ,
    'profile'
  return

  /* -------------------- *
  * Set Date Filters     *
  * (toggle)             *
  *                      *
  * Today - today's date *
  * Week  - last 7 days  *
  * Month - last 30 days *
  * Year  - this year    *
  * Since yy/mm/dd       *
  * Since -nn            *
  * Since day (Sun, Mon) *
  * -------------------- */
setup_date_filter:
  date_filterv = zcmd

 /* ---------------------------- *
  | Check for day of week filter |
  * ---------------------------- */
  Select
  When abbrev('SUNDAY',zcmd,3)    = 1 then zcmd = 'SINCE SUNDAY'
  When abbrev('MONDAY',zcmd,3)    = 1 then zcmd = 'SINCE MONDAY'
  When abbrev('TUESDAY',zcmd,3)   = 1 then zcmd = 'SINCE TUESDAY'
  When abbrev('WEDNESDAY',zcmd,3) = 1 then zcmd = 'SINCE WEDNESDAY'
  When abbrev('THURSDAY',zcmd,3)  = 1 then zcmd = 'SINCE THURSDAY'
  When abbrev('FRIDAY',zcmd,3)    = 1 then zcmd = 'SINCE FRIDAY'
  When abbrev('SATURDAY',zcmd,3)  = 1 then zcmd = 'SINCE SATURDAY'
  Otherwise nop
  end

  Select
    When last_date_filter = zcmd then do
      parse value '' with date_filter date_filterv ,
        date_filter_title last_date_filter
    end
    When zcmd = 'SINCE' then do
      parse value '' with date_filter date_filterv ,
        date_filter_title last_date_filter
    end
    When word(zcmd,1) = 'SINCE' then do
      stdate = word(zcmd,2)
      if stdate /= null then
         call check_since
      if left(stdate,1) = '-' then do
        parse value stdate with '-' sinced
        date_filter = date('b') - sinced
        date_filter_title = 'Since' stdate
        last_date_filter = zcmd
      end
      else do
        x = date_val(stdate)
        if x > 0 then do
          zerrsm = 'Invalid Date'
          zerrlm = stdate 'is an invalid date format.' ,
            'The date must be in the format of yy/mm/dd.'
          'Setmsg msg(isrz003)'
        end
        else do
          zerrsm = null
          parse value stdate with yy'/'mm'/'dd
          if mm > 12 then do
            zerrsm = 'Invalid Date'
            zerrlm = mm 'is an invalid month -' stdate
            'setmsg msg(isrz003)'
          end
          if yy//4 = 0 then mfb = 29
          else mfb = 28
          mlimit = '31' mfb '31 30 31 30 31 31 30 31 30 31'
          if zerrsm = null then
          if dd > word(mlimit,mm) then do
            zerrsm = 'Invalid Date'
            zerrlm = dd 'is an invalid number of days for the' ,
              'month of' mm '-' stdate
            'setmsg msg(isrz003)'
          end
          if zerrsm = null then do
            date_filter = date('b',stdate,'o')
            date_filter_title = 'Since' stdate
            last_date_filter = zcmd
          end
        end
      end
    end
    When zcmd = 'TODAY' then do
      if last_date_filter = zcmd then do
        date_filter = null
        date_filter_title = null
        last_date_filter = null
      end
      else do
        date_filter = date('b')
        date_filter_title = 'Today'
        last_date_filter = zcmd
      end
    end
    When zcmd = 'WEEK' then do
      if last_date_filter = zcmd then do
        date_filter = null
        date_filter_title = null
        last_date_filter = null
      end
      else do
        date_filter = date('b')-7
        date_filter_title = 'Week'
        last_date_filter = zcmd
      end
    end
    When abbrev('YESTERDAY',zcmd,4) = 1 then do
      if last_date_filter = zcmd then do
        date_filter = null
        date_filter_title = null
        last_date_filter = null
      end
      else do
        date_filter = date('b')-1
        date_filter_title = 'Yesterday'
        last_date_filter = zcmd
      end
    end
    When zcmd = 'MONTH' then do
      if last_date_filter = zcmd then do
        date_filter = null
        date_filter_title = null
        last_date_filter = null
      end
      else do
        date_filter = date('b')-30
        date_filter_title = 'Month'
        last_date_filter = zcmd
      end
    end
    When zcmd = 'YEAR' then do
      if last_date_filter = zcmd then do
        date_filter = null
        date_filter_title = null
        last_date_filter = null
      end
      else do
        yy          = left(date('o'),2)
        date_filter = date('b',yy'/01/01',o)
        date_filter_title = 'Year'
        last_date_filter = zcmd
      end
    end
    Otherwise nop
    zcmd = null
  end
  return

  /* ----------------------- *
  * Date Validation Routine *
  * ----------------------- */
Date_Val: Procedure
  arg tdate
  parse value tdate with y'/'m'/'d .
  if datatype(d) /= 'NUM' then return 1
  if datatype(m) /= 'NUM' then return 1
  if datatype(y) /= 'NUM' then return 1
  return 0

  /* ----------------------------------------------------- *
  * Test_Gen routine to verify that a relative generation *
  * is a valid generation.                                *
  *                                                       *
  * parms:  member gen                                    *
  *                                                       *
  * return:  0 = ok                                       *
  *          1 = ng                                       *
  * ----------------------------------------------------- */
Test_Gen: procedure expose members. null
  arg mem gen
  if gen = 0 then return 0
  if gen > 0 then return 1
  gen = substr(gen,2) + 1
  gw = word(members.mem,gen)
  if gw = null then return 1
  return 0

  /* ------------------------------------------- *
  * Ask_Sort routine                            *
  *                                             *
  * used to prompt the user for the sort column *
  * and sort order                              *
  * ------------------------------------------- */
Ask_Sort: Procedure Expose sortcol sort_order
  parse value '' with sc so scx sox sortcol sort_order null
  do forever
    call pfshow 'off'
    'Addpop Row(3) Column(3)'
    zcmd = null
    'display panel(pdsegsrt)'
    xrc = rc
    'Rempop'
    call pfshow 'reset'
    if xrc > 0 then do
      return
    end
    if left(sox,3) = 'Set' then do
      so = word(sox,2)
      sox = null
    end
    if scx /= null then do
      sortcol = scx
    end
    select
      when sc = '1' then sortcol = 'NAME'
      when sc = '2' then sortcol = 'CREATED'
      when sc = '3' then sortcol = 'CHANGED'
      when sc = '4' then sortcol = 'ID'
      when sc = '5' then sortcol = 'SIZE'
      when sc = '6' then sortcol = 'INIT'
      when sc = '7' then sortcol = 'MOD'
      otherwise nop
    end
    if sortcol /= null then do
      sort_order = so
      return
    end
  end
  return

  /* --------------------------------------- *
  | Find High Generation                    |
  |                                         |
  | Used by the Delete Promote routine      |
  |                                         |
  | Arguments:  dataset-name member-name    |
  | Returns:    highest absolute generation |
  * --------------------------------------- */
Find_HighGen: Procedure
  arg dsn mem
  pdseddx = randstr()
  Address TSO
  'alloc f('pdseddx') ds('dsn') shr reuse'
  drop member.
  Address ISPExec ,
    'dsinfo dataset('dsn')'
  if zds#mem > 0
  then x=pdsegeni(pdseddx)
  else do
    rc = 0
    member.0 = 0
  end
  'free f('pdseddx')'
  Address ISPExec
  do i = 1 to member.0
    if mem /= '' then if word(member.i,1) /= 'PDSE'mem then iterate
    parse value member.i with 5 mbr 13 agen 21 .
    mbr  = strip(mbr)
    agen = strip(agen)
    if agen > 0 then return agen
  end

  /* ------------------------------------------------ *
  | Common Do_Command routine to handle command line |
  | commands                                         |
  |                                                  |
  | arguments passed:  command-type                  |
  * ------------------------------------------------ */
Do_Command:
  Parse Arg clinecmd
  docmd = 1
  bmgen = null
  Select
    When clinecmd = 'B' then dcmd = 'Browse'
    When clinecmd = 'E' then dcmd = 'Edit'
    When clinecmd = 'S' then dcmd = 'Submit'
    When clinecmd = 'V' then dcmd = 'View'
    Otherwise return
  end
  /* --------------------------------- *
  | Check for a member or member-mask |
  * --------------------------------- */
  if words(zcmd) = 1 then do
    zerrsm = 'Error'
    zerrlm = dcmd 'requires a member name or mask.'
    'Setmsg msg(isrz003)'
    return
  end
  /* ------------------------------- *
  | Test for Submit and Correct DCB |
  * ------------------------------- */
  if clinecmd = 'S' then do
    rc = test_submit()
    if rc > 0 then return
  end
  /* ---------------------------------------------- *
  | Extract member and generation from the command |
  | and set submit long message to null            |
  * ---------------------------------------------- */
  bmbr = word(zcmd,2)
  bmgen = word(zcmd,3)
  agen  = bmgen
  sublm = null
  bhit = 0
  ghit = 0
  if clinecmd = 'E' then
  if bmgen = null
  then bmgen = 0
  if bmgen = null then do
    ghit = 0
    if pos('/',bmbr) > 0 then ghit = 1
    if pos('%',bmbr) > 0 then ghit = 1
    if pos('*',bmbr) > 0 then ghit = 1
    if pos(':',bmbr) > 0 then ghit = 1
    if ghit = 0 then bmgen = 0
  end
  /* -------------------------------------------------- *
  | Test for a real member being requested by checking |
  | that the member exists                             |
  * -------------------------------------------------- */
  if members.bmbr /= null then bhit = 1
  if all_members.bmbr /= null then bhit = 1
  if wordpos('0',all_members.bmbr) = 0 then bhit = 0
  if bhit = 1 then do
    mbr = bmbr
    agen = null
    if bmgen < 1 then do
      mgen = bmgen
      agen = word(all_members.mbr,(mgen*-1)+2)
      higen = words(all_members.mbr) - 2 * -1
    end
    if agen = null then
    if zdsngen > 0 then do
      zerrsm  = 'Error'
      zerrlm  = 'Member:' bmbr 'Gen:' bmgen 'not found'
      'setmsg msg(isrz003)'
      clinecmd = null
      bhit = 0
    end
    else do
      if word(all_members.mbr,2) /= 0 then do
        agen  = 0
        mgen  = 0
        higen = 0
        if clinecmd /= 'E'
        then bhit = 0
      end
    end
  end
  /* ------------------------------------------------ *
  | If the member is not found and edit is requested |
  | then set the member name to the member filter    |
  | and edit it. Only works if filter is not a mask. |
  * ------------------------------------------------ */
  if bhit = 0
  then if clinecmd = 'E'
  then if filter /= null
  then do
    bhit = 1
    if word(zcmd,2) = '*' then do
      rtn = test_mask(mbr filter)
      if rtn = 0 then bmbr = filter
      else bhit = 0
    end
  end
  /* -------------------------------------- *
  | The member is a mask or does not exist |
  * -------------------------------------- */
  if bhit = 0 then do
    'tbtop' pdset
    sublm = null
    do forever
      'tbskip' pdset
      if rc > 0 then leave
      rtn = test_mask(mbr bmbr)
      if rtn = 0 then leave
      if bmgen /= null then
      if bmgen /= mgen then iterate
      bhit = 1
      call Exec_Command
    end
  end
  else do
    mbr = bmbr
    call exec_command
  end
  if clinecmd /= 'E' then
  if bhit = 0 then do
    zerrsm  = 'Error'
    zerrlm  = 'Member:' bmbr 'Gen:' bmgen 'not found'
    'setmsg msg(isrz003)'
  end
  if clinecmd = 'E' then
  if bhit = 0 then do
    mbr = bmbr
    agen = 0
    if mbr /= '*' then do
      if mgen = null then do
        mgen = 0
        higen = 0
        'vput (mgen higen) shared'
      end
      call do_edit
    end
    else do
      zerrsm = 'Error'
      zerrlm = 'Member of * is not supported for Edit'
      'Setmsg msg(isrz003)'
    end
  end
  if update_table /= null then do
    call refresh_pdsi
    call proc_pdsegeni
    parse value '' with update_table lopt lopts
  end
  clinecmd = null
  if sublm /= null then do
    zerrsm = 'Submitted'
    zerrlm = 'Submitted:' sublm
    'Setmsg msg(isrz003)'
  end
  Return

  /* ------------------------------ *
  | Execute the Do_Command request |
  * ------------------------------ */
Exec_Command:
  Select
    When clinecmd = 'B' then call do_browse
    When clinecmd = 'E' then do
      call do_edit
    end
    When clinecmd = 'S' then do
      call do_submit
      if word(zerrlm,1) = 'JOB'
      then sublm = sublm word(zerrlm,2)
      else sublm = sublm zerrlm
    end
    When clinecmd = 'V' then call do_view
    Otherwise return
  end
  Return

  /* ----------------------------------------------------- *
  | Proc_Setting routine                                  |
  |                                                       |
  | Display the pdsegset panel to prompt for              |
  |                                                       |
  |    Default action for S and / selections              |
  |    Default table positioning for the last selected    |
  |      member.   1 positions the last selected member   |
  |      to the top and 0 leaves the last selected member |
  |      where it is in the table display.                |
  |    Default colors.                                    |
  * ----------------------------------------------------- */
Proc_Settings:
  arg PSoption
  Address ISPExec
  'Vget (clrb clrg clrp clrr clrt clrw clry clrh clrhr' ,
    'sortb sortc pdsetb csrloc changed useab umaxhist) profile'
  old_ab = useab
  if datatype(umaxhist) /= 'NUM'
  then umaxhist = maxhist
  if sortb = '' then do
    sortb = left(base_color,1)
    sortc = left(sort_color,1)
  end
  tb = pdsetb
  if datatype(csrloc) /= 'NUM' then csrloc = 0
  cp = csrloc
  if changed = null then changed = disp_change
  sc = changed
  if tb = null then tb = 0
  if cp = null then cp = 0
  if clrb = '' then do
    sb = 'B'
    sg = 'G'
    sp = 'P'
    sr = 'R'
    st = 'T'
    sw = 'W'
    sy = 'Y'
    sh = 'W'
    rh = 'N'
  end
  else do
    sortb = left(sortb,1)
    sortc = left(sortc,1)
    sb = left(clrb,1)
    sg = left(clrg,1)
    sp = left(clrp,1)
    sh = left(clrh,1)
    sr = left(clrr,1)
    st = left(clrt,1)
    sw = left(clrw,1)
    sy = left(clry,1)
    if left(clrhr,1) = 'R'
    then rh = 'Y'
    else rh = 'N'
  end
  Call Set_defaults
  if PSoption = null then
  do forever
    srtb = sortb
    srtc = sortc
    'Display panel(pdsegset)'
    if rc > 0 then leave
    sortb = srtb
    sortc = srtc
    if oldab /= useab then call change_panels
    Call Set_defaults
  end
  'VPut (clrb clrg clrp clrr clrt clrw clry clrh clrhr' ,
    'sortb sortc pdsetb csrloc changed useab umaxhist) profile'
  return

  /* ------------------------------------------------ *
  | Test the DCB of the current dataset to determine |
  | if a TSO Submit will work.                       |
  |                                                  |
  | DCB must be RECFM=Fx                             |
  * ------------------------------------------------ */
Test_Submit:
  if left(zdsrf,1) /= 'F' then do
    zerrsm = 'Error'
    zerrlm = 'Submit not supported with a RECFM='zdsrf
    'Setmsg msg(isrz003)'
    return 1
  end
  if zdslrec /= 80 then do
    zerrsm = 'Error'
    zerrlm = 'Submit not supported with a LRECL='strip(zdslrec)
    'Setmsg msg(isrz003)'
    return 1
  end
  else return 0

  /* ---------------------------- *
  | Set the defaults for PDSEGEN |
  * ---------------------------- */
Set_Defaults:
  If rh = 'Y' then clrhr = 'Reverse'
  else clrhr = ''
  csrloc = cp
  pdsetb = tb
  changed = sc
  Select  /* Sort Base */
    When sortb = 'B' then sortb = 'Blue'
    When sortb = 'G' then sortb = 'Green'
    When sortb = 'P' then sortb = 'Pink'
    When sortb = 'R' then sortb = 'Red'
    When sortb = 'T' then sortb = 'Turq'
    When sortb = 'W' then sortb = 'White'
    When sortb = 'Y' then sortb = 'Yellow'
    Otherwise sortb = 'Blue'
  end
  Select  /* Sort Color */
    When sortc = 'B' then sortc = 'Blue'
    When sortc = 'G' then sortc = 'Green'
    When sortc = 'P' then sortc = 'Pink'
    When sortc = 'R' then sortc = 'Red'
    When sortc = 'T' then sortc = 'Turq'
    When sortc = 'W' then sortc = 'White'
    When sortc = 'Y' then sortc = 'Yellow'
    Otherwise sortc = 'Turq'
  end
  Select  /* Blue */
    When sb = 'B' then clrb = 'Blue'
    When sb = 'G' then clrb = 'Green'
    When sb = 'P' then clrb = 'Pink'
    When sb = 'R' then clrb = 'Red'
    When sb = 'T' then clrb = 'Turq'
    When sb = 'W' then clrb = 'White'
    When sb = 'Y' then clrb = 'Yellow'
    Otherwise clrb = 'Blue'
  end
  Select  /* Green */
    When sg = 'B' then clrg = 'Blue'
    When sg = 'G' then clrg = 'Green'
    When sg = 'P' then clrg = 'Pink'
    When sg = 'R' then clrg = 'Red'
    When sg = 'T' then clrg = 'Turq'
    When sg = 'W' then clrg = 'White'
    When sg = 'Y' then clrg = 'Yellow'
    Otherwise clrg = 'Green'
  end
  Select  /* Pink */
    When sp = 'B' then clrp = 'Blue'
    When sp = 'G' then clrp = 'Green'
    When sp = 'P' then clrp = 'Pink'
    When sp = 'R' then clrp = 'Red'
    When sp = 'T' then clrp = 'Turq'
    When sp = 'W' then clrp = 'White'
    When sp = 'Y' then clrp = 'Yellow'
    Otherwise clrp = 'Pink'
  end
  Select  /* Red  */
    When sr = 'B' then clrr = 'Blue'
    When sr = 'G' then clrr = 'Green'
    When sr = 'P' then clrr = 'Pink'
    When sr = 'R' then clrr = 'Red'
    When sr = 'T' then clrr = 'Turq'
    When sr = 'W' then clrr = 'White'
    When sr = 'Y' then clrr = 'Yellow'
    Otherwise clrr = 'Red'
  end
  Select  /* Turq */
    When st = 'B' then clrt = 'Blue'
    When st = 'G' then clrt = 'Green'
    When st = 'P' then clrt = 'Pink'
    When st = 'R' then clrt = 'Red'
    When st = 'T' then clrt = 'Turq'
    When st = 'W' then clrt = 'White'
    When st = 'Y' then clrt = 'Yellow'
    Otherwise clrt = 'Turq'
  end
  Select  /* White */
    When sw = 'B' then clrw = 'Blue'
    When sw = 'G' then clrw = 'Green'
    When sw = 'P' then clrw = 'Pink'
    When sw = 'R' then clrw = 'Red'
    When sw = 'T' then clrw = 'Turq'
    When sw = 'W' then clrw = 'White'
    When sw = 'Y' then clrw = 'Yellow'
    Otherwise clrw = 'White'
  end
  Select  /* Yellow */
    When sy = 'B' then clry = 'Blue'
    When sy = 'G' then clry = 'Green'
    When sy = 'P' then clry = 'Pink'
    When sy = 'R' then clry = 'Red'
    When sy = 'T' then clry = 'Turq'
    When sy = 'W' then clry = 'White'
    When sy = 'Y' then clry = 'Yellow'
    Otherwise clry = 'Yellow'
  end
  Select  /* Header */
    When sh = 'B' then clrh = 'Blue'
    When sh = 'G' then clrh = 'Green'
    When sh = 'P' then clrh = 'Pink'
    When sh = 'R' then clrh = 'Red'
    When sh = 'T' then clrh = 'Turq'
    When sh = 'W' then clrh = 'White'
    When sh = 'Y' then clrh = 'Yellow'
    Otherwise clrh = 'White'
  end
  clrn      = base_color
  clrmbr    = base_color
  clrcdate  = base_color
  clrchang  = base_color
  clrmcur   = base_color
  clrminit  = base_color
  clrmmod   = base_color
  clrmuser  = base_color
  Select
    When sortcol = 'NAME'     then clrmbr   = sort_color
    When sortcol = 'CREATED'  then clrcdate = sort_color
    When sortcol = 'CHANGED'  then clrchang = sort_color
    When sortcol = 'ID'       then clrmuser = sort_color
    When sortcol = 'SIZE'     then clrmcur  = sort_color
    When sortcol = 'MOD'      then clrmmod  = sort_color
    When sortcol = 'INIT'     then clrminit = sort_color
    otherwise clrmbr = sort_color
  end
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
  /* ------------------------- *
  | Change a filter of ? to % |
  * ------------------------- */
  if pos('?',mask) > 0 then do
    mask = translate(mask,'%','?')
    hit = 1
  end

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

randstr: procedure
  /* --------------------  rexx procedure  -------------------- *
  | Name:      randstr                                         |
  |                                                            |
  | Function:  Generate a unique character string for use      |
  |            in an ISPF Table name, DDName, etc.             |
  |                                                            |
  |            This is for ISPF dialogs that may run           |
  |            concurrently in either multiple split           |
  |            screens or stacked so as to prevent duplicate   |
  |            DD or ISPF table names.                         |
  |                                                            |
  |            Or any length string with or without            |
  |            lowercase characters.                           |
  |                                                            |
  |            Thus this can be used to generate a random      |
  |            password or passphrase                          |
  |                                                            |
  |            This may also be used for any other need        |
  |            to have a unique character string that is       |
  |            a valid DDName, Member Name, etc.               |
  |                                                            |
  | Syntax:    x = randstr(n)                                  |
  |                                                            |
  |            Where n is the number of characters to          |
  |            return, always starting with an alpha.          |
  |                                                            |
  |            The default if not provided is 8                |
  |                                                            |
  |            If 'n' is preceded by L (e.g. L8) then          |
  |            50% of the characters will be lowercase         |
  |                                                            |
  | Notes:     In testing this generated 0 duplicates in 10    |
  |            tests with 100,000 iterations so this looks     |
  |            reasonably random - when n is 8.                |
  |                                                            |
  |            Using less than 8 will result in a higher       |
  |            probability of duplicates and using more        |
  |            will result in lowering the probabilty of       |
  |            duplicates.                                     |
  |                                                            |
  |            DO NOT call this routine RANDOM as it will      |
  |            confuse the use of the REXX RANDOM function     |
  |            within the code.                                |
  |                                                            |
  | Author:    Lionel B. Dyck                                  |
  |                                                            |
  | History:  (most recent on top)                             |
  |            02/27/18 - Ensure 1st position is alpha         |
  |            02/26/18 - Add LOTS of comments                 |
  |            02/23/18 - Insure 1st char is not special char  |
  |                     - Allow a parm for # of characters     |
  |                     - Allow Lowercase in string            |
  |            02/22/18 - Additional doc and randomness        |
  |            02/21/18 - Creation                             |
  |                                                            |
  * ---------------------------------------------------------- */
  arg numchars

  /* ------------------------------------ *
  | Check for L (lower case) in the parm |
  |  - set lowercase flag on             |
  |  - remove L from the parm (numchars) |
  | Otherwise set lower case flag off    |
  * ------------------------------------ */
  if left(numchars,1) = 'L' then do
    lowcase = 1
    numchars = substr(numchars,2)
  end
  else lowcase = 0

  /* ----------------------------------------------------- *
  | Check that numchars is numeric otherwise default to 8 |
  * ----------------------------------------------------- */
  if datatype(numchars) /= 'NUM' then numchars = 8

  /* -------------------------- *
  | Define our default strings |
  * -------------------------- */
  alpha  = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ$#@'
  lowchar= 'abcdefghijklmnopqrstuvwxyz'
  alpha# = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ$#@0123456789'

  /* -------------------------------------- *
  | Use 24 digit precision in calculations |
  * -------------------------------------- */
  numeric digits 24

  /* ----------------------------- *
  | Get random character position |
  * ----------------------------- */
  ra = random(1,26)
  /* ------------------------------------------ *
  | Start the return with the random character |
  | - then append the seconds since midnight   |
  |   multiplied by a random 5 digit number    |
  |   and then multiply again by another       |
  |   random 5 digit number.                   |
  | Then truncate at the request number of     |
  | characters (numchars)                      |
  * ------------------------------------------ */
  r = left(substr(alpha,ra,1) || ,
    time('s') * random(99999) ,
    * random(99999),numchars)

  /* --------------------------------------------------- *
  | Overlay the returned string with 3 different random |
  | characters from the alpha string to make it more    |
  | random.                                             |
  | ra = random char location                           |
  | rc = random target location                         |
  * --------------------------------------------------- */
  ra = random(1,29);rc = random(2,numchars)
  r = overlay(substr(alpha,ra,1),r,rc,1)
  ra = random(1,29);rc = random(2,numchars)
  r = overlay(substr(alpha,ra,1),r,rc,1)
  ra = random(1,29);rc = random(2,numchars)
  r = overlay(substr(alpha,ra,1),r,rc,1)
  ra = random(1,29);rc = random(2,numchars)
  r = overlay(substr(alpha,ra,1),r,rc,1)

  /* --------------------------------- *
  | Clean up any blanks in the return |
  | by replacing with random alpha#   |
  * --------------------------------- */
  do while pos(' ',r) > 0
    pb = pos(' ',r)         /* get position of blank           */
    ra = random(1,39)       /* get a random character position */
    /* now overlay the random character at the random position */
    r = overlay(substr(alpha#,ra,1),r,pb,1)
  end

  /* ------------------------------------- *
  | Process Lowercase request if provided |
  | by overlaying 1/2 of all return chars |
  | with a lower case character.          |
  * ------------------------------------- */
  if lowcase = 1 then do
    lc = numchars%2       /* get 50% of requested length */
    do i = 1 to lc
      /* ra = random lowercase character location */
      /* rc = random character position location  */
      ra = random(1,26);rc = random(1,numchars)
      /* now overlay the random character at the random position */
      r = overlay(substr(lowchar,ra,2),r,rc,1)
    end
  end

  /* --------------------- *
  | Now return the string |
  * --------------------- */
  return r

  /* -------------------------------------------- *
  | Define a fully qualified variable of the dsn |
  * -------------------------------------------- */
Fixup_pdsedsn:
  if pdsedsn = '*' then return
  if pdsedsn = '' then return    /* No dsn so return */
  if pos('(',pdsedsn) = 0
  then tdsn = pdsedsn
  else do
    parse value pdsedsn with tdsn'('.')'rd
    tdsn = tdsn''rd
  end
  x = listdsi(tdsn)
  wdsn = sysdsname
  return

Test_DSN_Alias:
  if length(pdsedsn) < 9
  then if pos('.',pdsedsn) = 0
  then do
    x = pdsegdsl('>'pdsedsn)
    if x /= 0 then pdsedsn = x
  end
  return

  /* --------------------  rexx procedure  -------------------- *
  | Name:      VALNAME                                         |
  |                                                            |
  | Function:  Validate a string as a valid PDS member name    |
  |                                                            |
  | Syntax:    x=valname(name)                                 |
  |                                                            |
  | Usage Notes: typically used from within a rexx program     |
  |                                                            |
  |            1st char must be alpha or @#$                   |
  |            2-8th must be alpha, @#$ or 0 thru 9            |
  |            must be 1 to 8 characters                       |
  |                                                            |
  | Author:    Lionel B. Dyck                                  |
  |                                                            |
  | History:  (most recent on top)                             |
  |            04/02/18 - Creation                             |
  |                                                            |
  | ---------------------------------------------------------- */
ValName:
  arg name
  if strip(name) = '' then return 0
  good_alpha = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ@#$'
  good_nums  = '0123456789'
  bad_chars  = '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
  tname = translate(translate(name,bad_chars,good_alpha good_nums),' ','%')
  Select
    when pos(left(name,1),good_alpha) = 0
    then bad = 'Invalid 1st Character' left(name,1)
    when length(name) > 8
    then bad = 'Too Many Characters' length(name)
    when strip(tname) /= ''
    then bad = 'Contains Invalid Characters' strip(tname)
    otherwise bad = 0
  end
  return bad

  /* -------------------------------- *
  | Age routine from John K's PGLite |
  * -------------------------------- */
do_age: procedure expose member. null
  tbl. = 0
  do x = 1 to member.0
    parse value member.x with . 5 mbr . 22 vrm . 49 adate 56 . 87 dmy .
    mbr   = strip(mbr)
    if left(mbr,1) = '00'x then iterate
    if dmy = 'D' then iterate
    if vrm = 'N' then do
      call stats 'unknown'
      iterate
    end
    else do
      adate  = substr(adate,3,5)
      adate  = date('o',adate,'j')
      call do_date_range
    end
  end
  name = 'today'     ; age1 = tbl.name
  name = 'yesterday' ; age2 = tbl.name
  name = 'week'      ; age3 = tbl.name
  name = 'current'   ; age4 = tbl.name
  name = 'biweek'    ; age5 = tbl.name
  name = 'month'     ; age6 = tbl.name
  name = 'bimonth'   ; age7 = tbl.name
  name = 'quarter'   ; age8 = tbl.name
  name = 'halfyear'  ; age9 = tbl.name
  name = 'year'      ; age10 = tbl.name
  name = 'biyear'    ; age11 = tbl.name
  name = 'dirt'      ; age12 = tbl.name
  name = 'unknown'   ; age13 = tbl.name
  'Addpop'
  'Display Panel(pdsegage)'
  'rempop'
  drop tbl.
  return
  /* --------------------------------- *
  | Member age routine                |
  * --------------------------------- */
do_date_range:
  if adate = null then
  return
  today = date('b')
  days  = date('b',adate,'o')
  Select
    when today - days < 1 then do; call stats 'today'    ; end
    when today - days = 1 then do; call stats 'yesterday'; end
    when today - days < 8 then do; call stats 'week'     ; end
    when today - days < 11 then do; call stats 'current' ; end
    when today - days < 15 then do; call stats 'biweek'  ; end
    when today - days < 31 then do; call stats 'month'   ; end
    when today - days < 61 then do; call stats 'bimonth' ; end
    when today - days < 91 then do; call stats 'quarter' ; end
    when today - days < 184 then do; call stats 'halfyear' ; end
    when today - days < 366 then do; call stats 'year'   ; end
    when today - days < 731 then do; call stats 'biyear' ; end
    when today - days > 730 then do; call stats 'dirt'   ; end
    Otherwise nop
  end
  return

Change_Panels:
  call set_panels
  suf = right(tpanel,1)
  if useab = 'Y'
  then suf = translate(suf,'abcdefgh','12345678')
  else suf = translate(suf,'12345678','abcdefgh')
  tpanel = left(tpanel,7)''suf
  'vput (tpanel) profile'
  return

Set_Panels:
  if pos(useab,'YN') = 0 then do
    useab = 'N'
    'vput (useab) profile'
  end
  if useab = 'N' then do
  /* panels with absolute gen */
    table_panel1 = 'pdseged1'  /* 1 character sel - 2 digit year */
    table_panel2 = 'pdseged2'  /* 1 character sel - 4 digit year */
    table_panel3 = 'pdseged3'  /* 9 character sel - 2 digit year */
    table_panel4 = 'pdseged4'  /* 9 character sel - 4 digit year */
  /* panels without absolute gen */
    table_panel5 = 'pdseged5'  /* 1 character sel - 2 digit year */
    table_panel6 = 'pdseged6'  /* 1 character sel - 4 digit year */
    table_panel7 = 'pdseged7'  /* 9 character sel - 2 digit year */
    table_panel8 = 'pdseged8'  /* 9 character sel - 4 digit year */
  end
  else do
  /* panels with absolute gen */
    table_panel1 = 'pdsegeda'  /* 1 character sel - 2 digit year */
    table_panel2 = 'pdsegedb'  /* 1 character sel - 4 digit year */
    table_panel3 = 'pdsegedc'  /* 9 character sel - 2 digit year */
    table_panel4 = 'pdsegedd'  /* 9 character sel - 4 digit year */
  /* panels without absolute gen */
    table_panel5 = 'pdsegede'  /* 1 character sel - 2 digit year */
    table_panel6 = 'pdsegedf'  /* 1 character sel - 4 digit year */
    table_panel7 = 'pdsegedg'  /* 9 character sel - 2 digit year */
    table_panel8 = 'pdsegedh'  /* 9 character sel - 4 digit year */
  end
  return

stats:
  parse arg type
  tbl.type = tbl.type + 1
  return

Cmd_Prompt:
  arg askopt
  askstr = null
  'vput (askopt)'
  'addpop row(3) column(3)'
  'display panel(pdsegask)'
  'rempop'
  zcmd = askopt askstr
  return

  /* ------------------------------------------------ *
   | Support Since day-of-week                        |
   |         Since Sunday, Monday, etc.               |
   |         Abbreviations of SU, M, TU, W, TH, F, SA |
   * ------------------------------------------------ */
Check_Since:
  w2 = word(zcmd,2)
  if left(w2,1) = '-' then return
  if pos('/',w2) > 0 then return
  if datatype(w2) /= 'CHAR' then return
  w2 = translate(w2)
  Select
    When abbrev('SUNDAY',w2,2)    = 1 then w2 = 1
    When abbrev('MONDAY',w2,1)    = 1 then w2 = 2
    When abbrev('TUESDAY',w2,2)   = 1 then w2 = 3
    When abbrev('WEDNESDAY',w2,1) = 1 then w2 = 4
    When abbrev('THURSDAY',w2,2)   = 1 then w2 = 5
    When abbrev('FRIDAY',w2,1)    = 1 then w2 = 6
    When abbrev('SATURDAY',w2,2)  = 1 then w2 = 7
    otherwise return
    end
    wt = translate(date('w'))
    wt = wordpos(wt,'SUNDAY MONDAY TUESDAY WEDNESDAY THURSDAY' ,
        'FRIDAY SATURDAY')
    stdate = w2 - wt
    if stdate > 0 then stdate = stdate - 7
    return
