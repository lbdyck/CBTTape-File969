```
//***FILE 969 is from Lionel Dyck in Austin, Texas and contains     *   FILE 969
//*           the PDSEGEN ISPF application.                         *   FILE 969
//*                                                                 *   FILE 969
//*           website: http://www.lbdsoftware.com                   *   FILE 969
//*           email:  lbdyck@gmail.com                              *   FILE 969
//*                                                                 *   FILE 969
//*    Lionel Dyck's large collection of utilities has now been     *   FILE 969
//*    divided between Files 312, 313, 314, and 969.  All member    *   FILE 969
//*    names beginning with A-R are on File 312.  Names beginning   *   FILE 969
//*    with S-TS are on File 313.  Names from TX-Z are on File      *   FILE 969
//*    314.  File 969 contains the PDSEGEN ISPF application to      *   FILE 969
//*    exploit the capabilities of using PDSE Version 2 member      *   FILE 969
//*    generations.                                                 *   FILE 969
//*                                                                 *   FILE 969
//*    These four files contain quite a few separate utility        *   FILE 969
//*    packages which are unrelated to each other.  You can tell    *   FILE 969
//*    which members of these files belong to the same utility      *   FILE 969
//*    package, by the similarities in their member names.          *   FILE 969
//*                                                                 *   FILE 969
//*       NAME       VER.MOD   LAST MODIFIED     SIZE   ID          *   FILE 969
//*       $$$DOC      01.28   2022/04/12 09:42    430 PDSE          *   FILE 969
//*       $CHANGES    01.17   2022/06/15 07:54   1803 PDSE          *   FILE 969
//*       $INSTALL    01.12   2020/02/02 11:02     76 PDSE          *   FILE 969
//*       $MODULES    01.04   2018/03/19 10:52     63 PDSE          *   FILE 969
//*       $MONITOR    01.00   2019/11/01 06:35     11 PDSE          *   FILE 969
//*       $RECV       01.44   2019/11/01 06:36    150 PDSE          *   FILE 969
//*       $RFES       01.01   2021/12/18 13:27      9 PDSE          *   FILE 969
//*       $UNDOC      01.07   2020/01/26 08:22     16 PDSE          *   FILE 969
//*       @ASMCLS     01.00   2020/03/09 12:35     38 PDSE          *   FILE 969
//*       @BACKUP     01.00   2020/03/09 12:35    119 PDSE          *   FILE 969
//*       ASM         01.00   2022/06/15 08:25   1505 XMIT          *   FILE 969
//*       ASMJCL      01.00   2021/11/25 12:13     30 PDSE          *   FILE 969
//*       CLS         01.00   2020/12/14 11:48      6 PDSE          *   FILE 969
//*       EXEC        01.00   2022/06/15 08:25  11940 XMIT          *   FILE 969
//*       FIXPDSEG    01.08   2021/11/25 12:33     27 PDSE          *   FILE 969
//*       LICENSE     01.00   2016/06/10 13:52    674 PDSE          *   FILE 969
//*       LOAD        01.00   2022/06/15 08:25    234 XMIT          *   FILE 969
//*       PANELS      01.00   2022/06/15 08:25   7866 XMIT          *   FILE 969
//*       PDSEGQW     01.08   2018/03/21 06:08    414 PDSE          *   FILE 969
//*       PDSEPDF     05.56   2019/07/22 12:46  28543 PDF           *   FILE 969
//*       PDSEREFC    01.02   2019/06/25 14:15   2403 PDF           *   FILE 969
//*       QWLOAD      01.00   2018/03/20 13:15     22 PDSE          *   FILE 969
//*       SAMPBR      01.09   2017/09/27 14:09     50 PDSE          *   FILE 969
//*       SAMPCOPY    01.00   2016/10/27 13:30     48 PDSE          *   FILE 969
//*       SAMPLE      01.00   2022/06/15 08:25   1188 XMIT          *   FILE 969
//*       SUPPORT     01.02   2017/07/17 14:05     10 PDSE          *   FILE 969
//*       WISHLIST    01.00   2018/03/26 14:16     12 PDSE          *   FILE 969
//*                                                                 *   FILE 969
//*  Member $DOC - basic information                                *   FILE 969
//*                                                                 *   FILE 969
//*  Member PDSEGEN - PDSE V2 Member Generation dialog              *   FILE 969
//*         Updated 06/15/2022 - Version 6.0.1                      *   FILE 969
//*                                                                 *   FILE 969
//*     The PDSEGEN ISPF Dialog found in this package will          *   FILE 969
//*     present the user with a list of all members of their        *   FILE 969
//*     PDSE, including all generations.  There are several         *   FILE 969
//*     commands and many line selection options available,         *   FILE 969
//*     including Browse, Edit, View, Compare, Delete, Promote,     *   FILE 969
//*     and Recover.  The list of members will be updated           *   FILE 969
//*     appropriately as members are edited, added, deleted,        *   FILE 969
//*     recovered, or promoted. Full member filtering using         *   FILE 969
//*     * and % is available as are date filters.                   *   FILE 969
//*                                                                 *   FILE 969
//*     Now with action bars (optional).                            *   FILE 969
//*                                                                 *   FILE 969
//*     Other capabilities include the ability to Backup your       *   FILE 969
//*     PDSE, with ALL generations, to a standard PDS so that       *   FILE 969
//*     it can be transported/copied by other utilities. Then       *   FILE 969
//*     there is the Restore capability to rebuild the PDSE with    *   FILE 969
//*     all generations.                                            *   FILE 969
//*                                                                 *   FILE 969
//*     The Copy command will copy a PDS into a PDSE with           *   FILE 969
//*     generations enabled or copy a PDSE with members and         *   FILE 969
//*     generations to another PDSE without the loss of any         *   FILE 969
//*     generations.                                                *   FILE 969
//*                                                                 *   FILE 969
//*     The PRUNE function will let you remove older (or all)       *   FILE 969
//*     generations that the user considers obsolete. Or            *   FILE 969
//*     completely empty the PDSE of all members and generations.   *   FILE 969
//*     PRUNE can be limited using FILTERs.                         *   FILE 969
//*                                                                 *   FILE 969
//*     The Validate command will invoke the IBM IEBPDSE utility    *   FILE 969
//*     which will validate the integrity of the PDSE and, if       *   FILE 969
//*     the correct PTF is installed clean up pending delete        *   FILE 969
//*     members/generations.                                        *   FILE 969
//*                                                                 *   FILE 969
//*     NOTES: This application requires z/OS 2.1 or newer to       *   FILE 969
//*           support access via ISPF to generations and does       *   FILE 969
//*           NOT support load libraries or aliases at this         *   FILE 969
//*           time.                                                 *   FILE 969
//*                                                                 *   FILE 969
//*           PDS/PDSE's are supported with up to approx 22,000     *   FILE 969
//*           members. The more members, the slower the opening     *   FILE 969
//*           process.                                              *   FILE 969
//*                                                                 *   FILE 969
//*           Full documentation is included in DOCX amd PDF in     *   FILE 969
//*           this file (see the member ID for them) and the        *   FILE 969
//*           EPUB and MOBI versions can be found at these urls:    *   FILE 969
//*                                                                 *   FILE 969
//*           EPUB foramt: http://tinyurl.com/ybl3un5z              *   FILE 969
//*           MOBI format: http://tinyurl.com/y9dck3dy              *   FILE 969
//*           PDF format:  https://tinyurl.com/y725a2qj             *   FILE 969
//*                                                                 *   FILE 969
//*           A reference card in PDF format can be found at:       *   FILE 969
//*           https://tinyurl.com/y9tbgpdw                          *   FILE 969
//* --------------------------------------------------------------- *   FILE 969
//*     Lionel B. Dyck                                              *   FILE 969
//*     email:   lbdyck@gmail.com                                   *   FILE 969
//*     website: www.lbdsoftware.com                                *   FILE 969
//* --------------------------------------------------------------- *   FILE 969
```
