/******************************************************************************
 * This piece of work is to enhance hats project functionality.          	  *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      dropidentity.sql                                                *
 * Created:   16/11/2024, 11:59                                               *
 * Modified:  16/11/2024, 11:59                                               *
 *                                                                            *
 * Copyright (c)  2024.  Aerosimo Ltd                                         *
 *                                                                            *
 * Permission is hereby granted, free of charge, to any person obtaining a    *
 * copy of this software and associated documentation files (the "Software"), *
 * to deal in the Software without restriction, including without limitation  *
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,   *
 * and/or sell copies of the Software, and to permit persons to whom the      *
 * Software is furnished to do so, subject to the following conditions:       *
 *                                                                            *
 * The above copyright notice and this permission notice shall be included    *
 * in all copies or substantial portions of the Software.                     *
 *                                                                            *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,            *
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES            *
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND                   *
 * NONINFINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT                 *
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,               *
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING               *
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE                 *
 * OR OTHER DEALINGS IN THE SOFTWARE.                                         *
 *                                                                            *
 ******************************************************************************/


PROMPT "Dropping Identity Schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

PROMPT "Dropping Identity Triggers"
DROP TRIGGER images_trg;
DROP TRIGGER contact_trg;
DROP TRIGGER address_trg;
DROP TRIGGER person_trg;
DROP TRIGGER syncaccount_trg;

PROMPT "Dropping Identity Tables"
DROP TABLE images_tbl CASCADE CONSTRAINTS purge;
DROP TABLE contact_tbl CASCADE CONSTRAINTS purge;
DROP TABLE address_tbl CASCADE CONSTRAINTS purge;
DROP TABLE person_tbl CASCADE CONSTRAINTS purge;

PROMPT "Dropping Identity Package"
DROP PACKAGE identity_pkg;

SHOW ERRORS
/

PROMPT "End of dropping Identity Schema."