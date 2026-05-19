PROMPT "Creating Starcast Schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      starcast.sql                                                    *
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

PROMPT "Creating Tables"
--------------------------------------
-- TABLES creating the required tables
--------------------------------------

-- Daily starcast table
CREATE TABLE starcast_tbl
(
    zodiacSign   VARCHAR2(20 BYTE),
    currentDay   VARCHAR2(50 BYTE),
    narrative    VARCHAR2(4000 BYTE),
    modifiedBy   VARCHAR2(100 BYTE),
    modifiedDate TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

PROMPT "Setting Constraints"
------------------------------------------------------------
-- CONSTRAINTS / CHECKS creating the constraints and checks
------------------------------------------------------------
-- Create index to quickly find active sessions for an email
CREATE INDEX starcast_idx ON starcast_tbl (zodiacSign);

-- Setting Primary Key
ALTER TABLE starcast_tbl
    ADD CONSTRAINT starcast_pk PRIMARY KEY (zodiacSign);

-- Setting Check Constraint
ALTER TABLE starcast_tbl
    ADD CONSTRAINT zodiacSign_chk CHECK (zodiacSign IN
                                         ('Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio',
                                          'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces')) ENABLE;

---------------------------------------------------------------------
-- HISTORY for archived purpose
---------------------------------------------------------------------
-- Create history tables
CREATE TABLE starcast_history_tbl AS
SELECT *
FROM starcast_tbl
WHERE 1 = 0;

ALTER TABLE starcast_history_tbl
    ADD modifiedReason VARCHAR2(200);
ALTER TABLE starcast_history_tbl
    ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;

PROMPT "Commenting Tables"
---------------------------------------------------------------------
-- COMMENTS for clarity (shorter and clearer)
---------------------------------------------------------------------

COMMENT ON TABLE starcast_tbl IS 'Profile information for list of daily horoscope based on signs.';
COMMENT ON COLUMN starcast_tbl.zodiacSign IS 'The zodiacSign is an area of the sky that extends approximately 8° north or south (as measured in celestial latitude) of the ecliptic, the apparent path of the Sun across the celestial sphere over the course of the year.';
COMMENT ON COLUMN starcast_tbl.currentDay IS 'The current date means the date today or the date when something will happen.';
COMMENT ON COLUMN starcast_tbl.narrative IS 'Your zodiacSign sign, or star sign, reflects the position of the sun when you were born. With its strong influence on your personality, character, and emotions, your sign is a powerful tool for understanding yourself and your relationships and of course, your sign can show you the way to an incredible life.';
COMMENT ON COLUMN starcast_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN starcast_tbl.modifiedDate IS 'Audit column - date of last update.';

COMMENT ON TABLE starcast_history_tbl IS 'Profile information for list of daily horoscope based on signs.';
COMMENT ON COLUMN starcast_history_tbl.zodiacSign IS 'The zodiacSign is an area of the sky that extends approximately 8° north or south (as measured in celestial latitude) of the ecliptic, the apparent path of the Sun across the celestial sphere over the course of the year.';
COMMENT ON COLUMN starcast_history_tbl.currentDay IS 'The current date means the date today or the date when something will happen.';
COMMENT ON COLUMN starcast_history_tbl.narrative IS 'Your zodiacSign sign, or star sign, reflects the position of the sun when you were born. With its strong influence on your personality, character, and emotions, your sign is a powerful tool for understanding yourself and your relationships and of course, your sign can show you the way to an incredible life.';
COMMENT ON COLUMN starcast_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN starcast_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN starcast_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN starcast_history_tbl.archivedDate IS 'Audit column - date of it was archived.';

PROMPT "Creating Triggers"
--------------------------------------------------------------
-- TRIGGERS: update modified_date & modified_by automatically
--------------------------------------------------------------
CREATE OR REPLACE TRIGGER starcast_trg
    BEFORE INSERT OR UPDATE
    ON starcast_tbl
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
                i_faultservice => 'starcast_trg for profile: ' || :NEW.zodiacSign,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER starcast_audit_trg
    AFTER UPDATE OR DELETE
    ON starcast_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage   VARCHAR2(4000);
    v_response       VARCHAR2(100);
    v_modifiedReason VARCHAR2(10);
BEGIN
    -- Determine whether the action is an update or delete
    IF UPDATING THEN
        v_modifiedReason := 'Updated';
        -- Log the update or delete in the history table
        INSERT INTO starcast_history_tbl(zodiacSign, currentDay, narrative, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.zodiacSign, :OLD.currentDay, :OLD.narrative, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO starcast_history_tbl(zodiacSign, currentDay, narrative, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.zodiacSign, :OLD.currentDay, :OLD.narrative, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN ROLLBACK;
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'starcast_trg (INSERT): ' || :NEW.zodiacSign,
                o_response => v_response
        );
        RAISE;
END;
/

PROMPT "Enabling Triggers"

-- Enable Triggers
ALTER TRIGGER starcast_trg ENABLE;
ALTER TRIGGER starcast_audit_trg ENABLE;

PROMPT "Creating Package Header"
--------------------------------------------------------------
-- PACKAGE: Creating Starcast header package
--------------------------------------------------------------
-- Create Header Package
CREATE OR REPLACE PACKAGE starcast_pkg
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
Name: starcast_pkg
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
-- Find details from the constellation table
    PROCEDURE getHoroscope(
        i_zodiacSign IN VARCHAR2,
        o_astrologyList OUT SYS_REFCURSOR);

    -- Find details from the constellation table based on user
    PROCEDURE getUserHoroscope(
        i_username IN VARCHAR2,
        o_astrologyList OUT SYS_REFCURSOR);

    -- Update constellation table
    PROCEDURE saveHoroscope(
        i_zodiacSign IN VARCHAR2,
        i_currentDay IN VARCHAR2,
        i_narrative IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_response OUT VARCHAR2);

END starcast_pkg;
/

PROMPT "Creating Package Body"
--------------------------------------------------------------
-- PACKAGE: Creating Starcast body package
--------------------------------------------------------------
-- Create Body Package
CREATE OR REPLACE PACKAGE BODY starcast_pkg
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
Name: starcast_pkg
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
-- Find details from the constellation table
    PROCEDURE getHoroscope(
        i_zodiacSign IN VARCHAR2,
        o_astrologyList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        OPEN o_astrologyList FOR
            SELECT *
            FROM starcast_tbl
            WHERE zodiacSign = i_zodiacSign;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'starcast_pkg (GET HOROSCOPE): ' || i_zodiacSign,
                    o_response => v_response
            );
    END getHoroscope;

    -- Find details from the constellation table based on user
    PROCEDURE getUserHoroscope(
        i_username IN VARCHAR2,
        o_astrologyList OUT SYS_REFCURSOR)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_sign          VARCHAR2(100);
    BEGIN
        SELECT zodiacSign
        INTO v_sign
        FROM person_tbl
        WHERE i_username = username;
        OPEN o_astrologyList FOR
            SELECT *
            FROM starcast_tbl
            WHERE zodiacSign = v_sign;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'starcast_pkg (GET HOROSCOPE): ' || v_sign,
                    o_response => v_response
            );
    END getUserHoroscope;

    -- Update constellation table
    PROCEDURE saveHoroscope(
        i_zodiacSign IN VARCHAR2,
        i_currentDay IN VARCHAR2,
        i_narrative IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        UPDATE starcast_tbl
        SET zodiacSign = i_zodiacSign,
            currentDay = i_currentDay,
            narrative  = i_narrative,
            modifiedBy = i_modifiedBy
        WHERE zodiacSign = i_zodiacSign;
        IF SQL%NOTFOUND THEN
            INSERT INTO starcast_tbl(zodiacSign, currentDay, narrative, modifiedBy)
            VALUES (i_zodiacSign, i_currentDay, i_narrative, i_modifiedBy);
        END IF;
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'starcast_pkg (SAVE HOROSCOPE): ' || i_zodiacSign,
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END saveHoroscope;

END starcast_pkg;
/