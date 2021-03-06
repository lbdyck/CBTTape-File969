/* --------------------  rexx procedure  -------------------- *
 * Name:      pdsegenx                                        *
 *                                                            *
 * Function:  dynamically allocate the pdsegen libraries      *
 *            for testing purposes                            *
 *                                                            *
 * Syntax:    %pdsegenx pdse-library filter                   *
 *                                                            *
 *            pdse-library is optional and if not provided    *
 *            will present a prompt to the user               *
 *                                                            *
 *            filter is optional                              *
 *                                                            *
 * Note:      hlq. will be changed by the $RECV exec to       *
 *            match what you restore the libraries to         *
 *                                                            *
 * Author:    Lionel B. Dyck                                  *
 *                                                            *
 * History:                                                   *
 *            08/31/16 - Add filter                           *
 *            07/13/16 - Add stack to the libdef              *
 *            06/20/16 - Creation                             *
 *                                                            *
 * ---------------------------------------------------------- *
 * Copyright (c) 2017-2021 by Lionel B. Dyck                  *
 * ---------------------------------------------------------- */
 arg pdselib filter

 exec   = "'hlq..exec'" /* changed during receive */
 load   = "'hlq..load'" /* changed during receive */
 panels = "'hlq..panels'" /* changed during receive */

 'altlib activate dataset('exec') application(exec)'
 address ispexec
 'libdef ispllib dataset id('load') stack'
 'libdef ispplib dataset id('panels') stack'
 'Select cmd(%pdsegen' pdselib filter ') scrname(pdsegen)'
 'libdef ispllib'
 'libdef ispplib'
 address tso
 'altlib deactivate application(exec)'
