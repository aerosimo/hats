PROMPT "Creating Manna Schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      manna.sql                                                       *
 * Created:   25/01/2026, 21:30                                               *
 * Modified:  25/01/2026, 21:31                                               *
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

PROMPT "Creating Tables"
--------------------------------------
-- TABLES creating the required tables
--------------------------------------

-- Daily manna table
CREATE TABLE manna_tbl
(
    passage         VARCHAR2(4000 BYTE),
    verse           VARCHAR2(50 BYTE),
    version         VARCHAR2(10 BYTE),
    modifiedBy      VARCHAR2(100 BYTE),
    modifiedDate    TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

PROMPT "Commenting Tables"
---------------------------------------------------------------------
-- COMMENTS for clarity (shorter and clearer)
---------------------------------------------------------------------
COMMENT ON TABLE manna_tbl IS 'Profile information for list of daily bible verse.';
COMMENT ON COLUMN manna_tbl.passage IS 'This column is for the actual daily passage.';
COMMENT ON COLUMN manna_tbl.verse IS 'The current daily bible verse.';
COMMENT ON COLUMN manna_tbl.version IS 'Current version of the bible used to get the passage';
COMMENT ON COLUMN manna_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN manna_tbl.modifiedDate IS 'Audit column - date of last update.';

PROMPT "Creating Triggers"
--------------------------------------------------------------
-- TRIGGERS: update modified_date & modified_by automatically
--------------------------------------------------------------
CREATE OR REPLACE TRIGGER manna_trg
    BEFORE INSERT OR UPDATE
    ON manna_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    IF :NEW.modifiedBy IS NULL THEN
        :NEW.modifiedBy := USER;
    END IF;
    IF :NEW.modifiedDate IS NULL THEN
        :NEW.modifiedDate := SYSTIMESTAMP;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'manna_trg',
                o_response => v_response
        );
        RAISE;
END;
/

PROMPT "Enabling Triggers"

-- Enable Triggers
ALTER TRIGGER manna_trg ENABLE;

PROMPT "Creating Package Header"
--------------------------------------------------------------
-- PACKAGE: Creating manna header package
--------------------------------------------------------------
-- Create Header Package
CREATE OR REPLACE PACKAGE manna_pkg
AS
    /* Header Package
    =================================================================================
    Copyright (c) 2026 Aerosimo

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    with the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or significant portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
    ================================================================================
    Name: manna_pkg
    Program Type: Package Specification
    Purpose: ADD/FIND/UPDATE/DELETE entity
    =================================================================================
    HISTORY
    =================================================================================
    | DATE 		| Owner 	| Activity
    =================================================================================
    | 20-JAN-26	| eomisore 	| Created initial script.|
    =================================================================================
    */
-- Find daily bread table
    PROCEDURE dailyBread(
        o_mannaList OUT SYS_REFCURSOR);

    -- Update manna table
    PROCEDURE saveManna(
        i_passage IN VARCHAR2,
        i_verse IN VARCHAR2,
        i_version IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_response OUT VARCHAR2);

END manna_pkg;
/

PROMPT "Creating Package Body"
--------------------------------------------------------------
-- PACKAGE: Creating manna body package
--------------------------------------------------------------
-- Create Body Package
CREATE OR REPLACE PACKAGE BODY manna_pkg
AS
    /* Body Package
    =================================================================================
    Copyright (c) 2026 Aerosimo

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    with the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or significant portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
    ================================================================================
    Name: manna_pkg
    Program Type: Package Specification
    Purpose: ADD/FIND/UPDATE/DELETE entity
    =================================================================================
    HISTORY
    =================================================================================
    | DATE 		| Owner 	| Activity
    =================================================================================
    | 20-JAN-26	| eomisore 	| Created initial script.|
    =================================================================================
    */
-- Find daily bread table
    PROCEDURE dailyBread(
        o_mannaList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        OPEN o_mannaList FOR
            SELECT *
            FROM manna_tbl
            WHERE TRUNC(modifiedDate) = TRUNC(SYSDATE);
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'manna_pkg (DAILY BREAD): ',
                    o_response => v_response
            );
    END dailyBread;

    -- Update manna table
    PROCEDURE saveManna(
        i_passage IN VARCHAR2,
        i_verse IN VARCHAR2,
        i_version IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        UPDATE manna_tbl
        SET passage = i_passage,
            verse = i_verse,
            version  = i_version,
            modifiedBy = i_modifiedBy
        WHERE TRUNC(modifiedDate) = TRUNC(SYSDATE);
        IF SQL%NOTFOUND THEN
            INSERT INTO manna_tbl(passage, verse, version, modifiedBy)
            VALUES (i_passage, i_verse, i_version, i_modifiedBy);
        END IF;
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'manna_pkg (SAVE MANNA): ',
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END saveManna;

END manna_pkg;
/