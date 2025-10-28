PROMPT "Dropping Account Schema"
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      dropaccount.sql                                                 *
 * Created:   13/10/2025, 11:05                                               *
 * Modified:  28/10/2025, 21:07                                               *
 *                                                                            *
 * Copyright (c)  2025.  Aerosimo Ltd                                         *
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

PROMPT "Dropping Tables"

DROP TABLE multifactor_history_tbl CASCADE CONSTRAINTS purge;
DROP TABLE verification_history_tbl CASCADE CONSTRAINTS purge;
DROP TABLE credentials_history_tbl CASCADE CONSTRAINTS purge;
DROP TABLE person_history_tbl CASCADE CONSTRAINTS purge;
DROP TABLE address_history_tbl CASCADE CONSTRAINTS purge;
DROP TABLE images_history_tbl CASCADE CONSTRAINTS purge;
DROP TABLE contact_history_tbl CASCADE CONSTRAINTS purge;
DROP TABLE profile_history_tbl CASCADE CONSTRAINTS purge;
DROP TABLE horoscope_history_tbl CASCADE CONSTRAINTS purge;
DROP TABLE images_tbl CASCADE CONSTRAINTS purge;
DROP TABLE person_tbl CASCADE CONSTRAINTS purge;
DROP TABLE address_tbl CASCADE CONSTRAINTS purge;
DROP TABLE contact_tbl CASCADE CONSTRAINTS purge;
DROP TABLE profile_tbl CASCADE CONSTRAINTS purge;
DROP TABLE horoscope_tbl CASCADE CONSTRAINTS purge;
DROP TABLE multifactor_tbl CASCADE CONSTRAINTS purge;
DROP TABLE verification_tbl CASCADE CONSTRAINTS purge;
DROP TABLE scrutiny_tbl CASCADE CONSTRAINTS purge;
DROP TABLE credentials_tbl CASCADE CONSTRAINTS purge;

PROMPT "Dropping Packages"

DROP PACKAGE auth_pkg;
DROP PACKAGE profile_pkg;
DROP PACKAGE utility_pkg;
DROP PACKAGE account_pkg;

SHOW ERRORS
/

PROMPT "End of dropping Authentication Schema."