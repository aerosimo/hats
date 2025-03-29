PROMPT "Creating Account Schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      account.sql                                                     *
 * Created:   02/03/2025, 19:00                                               *
 * Modified:  15/03/2025, 11:12                                               *
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

PROMPT "Creating Account Schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

PROMPT "Creating Tables"

-- Create Tables
CREATE TABLE account_tbl
(
    recordid         NUMBER GENERATED ALWAYS AS IDENTITY,
    accountid        VARCHAR2(20 BYTE),
    uname            VARCHAR2(100 BYTE),
    pword            VARCHAR2(400 BYTE),
    email            VARCHAR2(50 BYTE),
    emailVerified    CHAR(1),
    verificationCode VARCHAR2(100 BYTE),
    failedLogin      NUMBER DEFAULT 0,
    lastLogin        TIMESTAMP,
    status           VARCHAR2(50 BYTE),
    modifiedBy       VARCHAR2(50 BYTE),
    modifiedDate     TIMESTAMP
);

PROMPT "Commenting Tables"

-- Comment on tables
COMMENT ON COLUMN account_tbl.recordid IS 'This is the account record primary identifier';
COMMENT ON COLUMN account_tbl.accountid IS 'This is the account primary identifier';
COMMENT ON COLUMN account_tbl.uname IS 'This is contact username this could be an alias';
COMMENT ON COLUMN account_tbl.pword IS 'This is contact set encrypted password';
COMMENT ON COLUMN account_tbl.email IS 'Electronic mail is a method of exchanging messages between people using electronic devices.';
COMMENT ON COLUMN account_tbl.emailVerified IS 'Indicates whether a user has verified their email (Y or N).';
COMMENT ON COLUMN account_tbl.verificationCode IS 'Random code sent to the user for email verification.';
COMMENT ON COLUMN account_tbl.failedLogin IS 'Track failed attempts and lock the account if too many failed attempts occur';
COMMENT ON COLUMN account_tbl.lastLogin IS 'Timestamp of the most recent login attempt for lockout management.';
COMMENT ON COLUMN account_tbl.status IS 'This the state of the user account either (Active or Inactive).';
COMMENT ON COLUMN account_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN account_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE account_tbl IS 'A user account is a location on a network server used to store a computer username, password, and other information. A user account allows or does not allow a user to connect to a network, another computer, or other shares.';

PROMPT "Setting Constraints"

-- Setting Primary Key
ALTER TABLE account_tbl
    ADD CONSTRAINT account_pk PRIMARY KEY (recordid);

-- Setting Unique Key
ALTER TABLE account_tbl
    ADD CONSTRAINT account_unq UNIQUE (accountid);
ALTER TABLE account_tbl
    ADD CONSTRAINT email_unq UNIQUE (email);
ALTER TABLE account_tbl
    ADD CONSTRAINT username_unq UNIQUE (uname);

-- Setting Check Constraint
ALTER TABLE account_tbl
    ADD CONSTRAINT email_chk CHECK (emailVerified IN ('Y', 'N')) ENABLE;
ALTER TABLE account_tbl
    ADD CONSTRAINT account_chk CHECK (status IN ('Active', 'Inactive')) ENABLE;

-- Create an account history table
CREATE TABLE account_history_tbl AS
SELECT *
FROM account_tbl
WHERE 1 = 0;
ALTER TABLE account_history_tbl
    ADD modifiedReason VARCHAR2(200);
ALTER TABLE account_history_tbl
    ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;

PROMPT "Creating Triggers"

-- Creating Triggers
CREATE OR REPLACE TRIGGER account_trg
    BEFORE INSERT
    ON account_tbl
    FOR EACH ROW
DECLARE
    v_error_message VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    -- Generate unique account ID for new accounts
    :NEW.accountid := 'AER' || LPAD((1 + ABS(MOD(dbms_random.random, 100000))), 6, '000');
    -- Generate random verification code
    :NEW.verificationCode := dbms_random.string('X', 10);
    -- Ensure N is selected upon inserting a new record
    :NEW.emailVerified := 'N';
    -- Ensure required fields are populated
    IF :NEW.uname IS NULL THEN
        RAISE_APPLICATION_ERROR(-20004, 'Username is Mandatory and cannot be empty.');
    END IF;
    IF :NEW.pword IS NULL THEN
        RAISE_APPLICATION_ERROR(-20005, 'Password is Mandatory and cannot be empty.');
    END IF;
    IF :NEW.email IS NULL THEN
        RAISE_APPLICATION_ERROR(-20006, 'Email is Mandatory and cannot be empty.');
    END IF;
    -- Default values
    IF :NEW.status IS NULL THEN
        :NEW.status := 'Active';
    END IF;
    IF :NEW.modifiedBy IS NULL THEN
        :NEW.modifiedBy := USER;
    END IF;
    IF :NEW.modifiedDate IS NULL THEN
        :NEW.modifiedDate := SYSTIMESTAMP;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'account_trg (INSERT): ' || :NEW.accountid,
                o_response => v_response
        );
        RAISE;
END;
/

-- Creating Triggers
CREATE OR REPLACE TRIGGER account_audit_trg
    AFTER UPDATE OR DELETE
    ON account_tbl
    FOR EACH ROW
DECLARE
    v_error_message   VARCHAR2(4000);
    v_response        VARCHAR2(100);
    v_modified_reason VARCHAR2(10);
BEGIN
    -- Determine whether the action is an update or delete
    IF UPDATING THEN
        v_modified_reason := 'Updated';
    ELSIF DELETING THEN
        v_modified_reason := 'Deleted';
    END IF;
    -- Log the update or delete in the history table
    INSERT INTO account_history_tbl(recordid, accountid, uname, pword, email, emailVerified, verificationCode,
                                    failedLogin, lastLogin, status, modifiedBy, modifiedDate, modifiedReason)
    VALUES (:OLD.recordid, :OLD.accountid, :OLD.uname, :OLD.pword, :OLD.email, :OLD.emailVerified,
            :OLD.verificationCode, :OLD.failedLogin, :OLD.lastLogin, :OLD.status, :OLD.modifiedBy,
            :OLD.modifiedDate, v_modified_reason);
EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'account_audit_trg (UPDATE/DELETE): ' || :NEW.accountid,
                o_response => v_response
        );
        RAISE;
END;
/

PROMPT "Enabling Triggers"

-- Enable Triggers
ALTER TRIGGER account_trg ENABLE;
ALTER TRIGGER account_audit_trg ENABLE;

PROMPT "Creating Account Header Package"

-- Create Packages
CREATE OR REPLACE PACKAGE account_pkg
AS
    /* $Header: account_pkg. 1.0.0 15-Mar-25 11:12 Package
=================================================================================
  Copyright (c) 2025 Aerosimo

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
================================================================================
Name: account_pkg
Program Type: Package Specification
Purpose: ADD/FIND/UPDATE/DELETE entity
=================================================================================
HISTORY
=================================================================================
| DATE 		| Owner 	| Activity
=================================================================================
| 02-Mar-25	| eomisore 	| Created initial script.|
=================================================================================
| 15-Mar-25	| eomisore 	| Introduce Account history.|
=================================================================================
*/
    -- Create or Update Account
    PROCEDURE SaveAccount(
        i_username IN account_tbl.uname%TYPE,
        i_password IN account_tbl.pword%TYPE,
        i_email IN account_tbl.email%TYPE,
        i_modifiedBy IN account_tbl.modifiedBy%TYPE,
        o_response OUT VARCHAR2);

    PROCEDURE VerifyAccount(
        i_email IN account_tbl.email%TYPE,
        i_code IN account_tbl.verificationCode%TYPE,
        i_modifiedBy IN account_tbl.modifiedBy%TYPE,
        o_response OUT VARCHAR2);

END account_pkg;
/

PROMPT "Creating Account Body Package"

-- Create Packages
CREATE OR REPLACE PACKAGE BODY account_pkg
AS
    /* $Body: account_pkg. 1.0.0 15-Mar-25 11:12 Package
=================================================================================
  Copyright (c) 2025 Aerosimo

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
================================================================================
Name: account_pkg
Program Type: Package Specification
Purpose: ADD/FIND/UPDATE/DELETE entity
=================================================================================
HISTORY
=================================================================================
| DATE 		| Owner 	| Activity
=================================================================================
| 02-Mar-25	| eomisore 	| Created initial script.|
=================================================================================
| 15-Mar-25	| eomisore 	| Introduce Account history.|
=================================================================================
*/
    -- Create or Update Account
    PROCEDURE SaveAccount(
        i_username IN account_tbl.uname%TYPE,
        i_password IN account_tbl.pword%TYPE,
        i_email IN account_tbl.email%TYPE,
        i_modifiedBy IN account_tbl.modifiedBy%TYPE,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE account_tbl
        SET uname      = i_username,
            pword      = i_password,
            email      = i_email,
            modifiedBy = i_modifiedBy
        WHERE uname = i_username
          AND email = i_email
        RETURNING accountid INTO o_response;
        IF SQL%NOTFOUND THEN
            INSERT INTO account_tbl(uname, pword, email, modifiedBy)
            VALUES (i_username, utl_encode.base64_encode(utl_raw.cast_to_raw(enc_dec.encrypt(i_password))), i_email,
                    i_modifiedBy)
            RETURNING accountid INTO o_response;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN ROLLBACK;
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'account_pkg.SaveAccount: ' || i_username,
                o_response => v_response
        );
        o_response := SQLCODE || SUBSTR(SQLERRM, 1, 2000);
    END SaveAccount;

    PROCEDURE VerifyAccount(
        i_email IN account_tbl.email%TYPE,
        i_code IN account_tbl.verificationCode%TYPE,
        i_modifiedBy IN account_tbl.modifiedBy%TYPE,
        o_response OUT VARCHAR2)
    AS
        v_count         NUMBER;
        v_response      VARCHAR2(100);
        v_error_message VARCHAR2(4000);
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM account_tbl
        WHERE email = i_email
          AND verificationCode = i_code
          AND emailVerified = 'N';
        IF v_count = 1 THEN
            UPDATE account_tbl
            SET emailVerified = 'Y',
                modifiedBy    = i_modifiedBy
            WHERE email = i_email;
            o_response := 'Email verified successfully';
        ELSE
            o_response := 'Invalid verification code';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN ROLLBACK;
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'account_pkg.VerifyAccount: ' || i_email,
                o_response => v_response
        );
        o_response := 'Error occurred during verification: ' || SQLCODE || SUBSTR(SQLERRM, 1, 2000);
    END VerifyAccount;

END account_pkg;
/

PROMPT "Compiling Account Package"

ALTER PACKAGE account_pkg COMPILE PACKAGE;
ALTER PACKAGE account_pkg COMPILE BODY;
/

SHOW ERRORS
/

PROMPT "End of creating Account Schema"