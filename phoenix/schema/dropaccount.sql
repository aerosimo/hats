PROMPT "Dropping Account Schema"
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      dropaccount.sql                                                 *
 * Created:   20/01/2026, 19:10                                               *
 * Modified:  20/01/2026, 20:42                                               *
 *                                                                            *
 * Copyright (c)  2026.  Aerosimo Ltd                                         *
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

DROP TABLE verification_history_tbl CASCADE CONSTRAINTS purge;
DROP TABLE images_history_tbl CASCADE CONSTRAINTS purge;
DROP TABLE person_history_tbl CASCADE CONSTRAINTS purge;
DROP TABLE address_history_tbl CASCADE CONSTRAINTS purge;
DROP TABLE contact_history_tbl CASCADE CONSTRAINTS purge;
DROP TABLE credence_history_tbl CASCADE CONSTRAINTS purge;
DROP TABLE credentials_history_tbl CASCADE CONSTRAINTS purge;
DROP TABLE verification_tbl CASCADE CONSTRAINTS purge;
DROP TABLE images_tbl CASCADE CONSTRAINTS purge;
DROP TABLE person_tbl CASCADE CONSTRAINTS purge;
DROP TABLE address_tbl CASCADE CONSTRAINTS purge;
DROP TABLE contact_tbl CASCADE CONSTRAINTS purge;
DROP TABLE credence_tbl CASCADE CONSTRAINTS purge;
DROP TABLE credentials_tbl CASCADE CONSTRAINTS purge;

PROMPT "Dropping Schedule job"

DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM user_scheduler_jobs
    WHERE job_name = 'CREDENCE_SESSION_CLEANUP';

    IF v_count > 0 THEN
        DBMS_SCHEDULER.DROP_JOB(job_name => 'CREDENCE_SESSION_CLEANUP', force => TRUE);
    END IF;
END;
/

SHOW ERRORS
/

PROMPT "End of dropping Authentication Schema."