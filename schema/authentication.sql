/******************************************************************************
 * This piece of work is to enhance hats project functionality.          	  *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      authentication.sql                                              *
 * Created:   16/11/2024, 16:03                                               *
 * Modified:  16/11/2024, 16:03                                               *
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

PROMPT "Creating Authentication Schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

PROMPT "Creating Tables"

-- Create Tables
CREATE TABLE usertoken_tbl
(
    accountid    VARCHAR2(20 BYTE),
    authtoken    VARCHAR2(300 BYTE),
    issued       TIMESTAMP,
    expires      TIMESTAMP,
    status       CHAR(1),
    modifiedBy   VARCHAR2(50 BYTE),
    modifiedDate TIMESTAMP
);

PROMPT "Commenting Tables"

-- Comment on tables
COMMENT ON COLUMN usertoken_tbl.accountid IS 'The account identifier for user tokens';
COMMENT ON COLUMN usertoken_tbl.authtoken IS 'Stores the generated session token for user authentication.';
COMMENT ON COLUMN usertoken_tbl.issued IS 'Track token validity period';
COMMENT ON COLUMN usertoken_tbl.expires IS 'Track token validity period';
COMMENT ON COLUMN usertoken_tbl.status IS 'Indicates whether the user token is active or not (Y or N).';
COMMENT ON COLUMN usertoken_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN usertoken_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE usertoken_tbl IS 'A user account is a location on a network server used to store a computer username, password, and other information. A user account allows or does not allow a user to connect to a network, another computer, or other shares.';

PROMPT "Setting Constraints"

-- Setting Foreign Key
ALTER TABLE usertoken_tbl ADD CONSTRAINT token_fk FOREIGN KEY (accountid) REFERENCES account_tbl (accountid) ON DELETE CASCADE;

-- Setting Check Constraint
ALTER TABLE usertoken_tbl ADD CONSTRAINT status_chk CHECK (status IN ('Y', 'N')) ENABLE;

PROMPT "Creating Triggers"

-- Creating Triggers
CREATE OR REPLACE TRIGGER usertoken_trg
    BEFORE INSERT OR UPDATE
    ON usertoken_tbl
    FOR EACH ROW
DECLARE
    v_error_message VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        SELECT dbms_random.String('X', 50) INTO :NEW.authtoken FROM DUAL;
        IF :NEW.issued IS NULL THEN SELECT SYSTIMESTAMP INTO :NEW.issued FROM DUAL; END IF;
        IF :NEW.status IS NULL THEN SELECT 'Y' INTO :NEW.status FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT USER INTO :NEW.modifiedBy FROM DUAL; END IF;
        IF :NEW.modifiedDate IS NULL THEN SELECT SYSTIMESTAMP INTO :NEW.modifiedDate FROM DUAL; END IF;
    ELSIF UPDATING THEN
        IF :NEW.expires IS NULL THEN SELECT SYSTIMESTAMP INTO :NEW.expires FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT USER INTO :NEW.modifiedBy FROM DUAL; END IF;
        IF :NEW.modifiedDate IS NULL THEN SELECT SYSTIMESTAMP INTO :NEW.modifiedDate FROM DUAL; END IF;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'usertoken_trg for authentication: ' || :NEW.accountid,
                o_response => v_response
        );
        RAISE;
END;
/

PROMPT "Enabling Triggers"

-- Enable Triggers
ALTER TRIGGER usertoken_trg ENABLE;

PROMPT "Creating Authentication Header Package"

-- Create Packages
CREATE OR REPLACE PACKAGE authentication_pkg
AS
    /* $Header: authentication_pkg. 1.0.0 26-OCT-24 22:44 Package
=================================================================================
  Copyright (c) 2024 Aerosimo

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
Name: authentication_pkg
Program Type: Package Specification
Purpose: ADD/FIND/UPDATE/DELETE entity
=================================================================================
HISTORY
=================================================================================
| DATE 		| Owner 	| Activity
=================================================================================
| 26-OCT-24	| eomisore 	| Created initial script.|
=================================================================================
*/
    -- Create or Update Authentication
    PROCEDURE loginUser(
        i_username IN account_tbl.uname%TYPE,
        i_password IN account_tbl.pword%TYPE,
		o_accountid OUT VARCHAR2,
        o_token OUT VARCHAR2,
        o_response OUT VARCHAR2);

    PROCEDURE generateToken(
        i_accountid IN account_tbl.accountid%TYPE,
        o_token OUT VARCHAR2,
        o_response OUT VARCHAR2);

    PROCEDURE validateToken(
        i_token IN usertoken_tbl.authtoken%TYPE,
        o_status OUT BOOLEAN);

    PROCEDURE invalidateToken(
        i_token IN usertoken_tbl.authtoken%TYPE);

END authentication_pkg;
/

PROMPT "Creating Authentication Body Package"

-- Create Packages
CREATE OR REPLACE PACKAGE BODY authentication_pkg
AS
    /* $Body: authentication_pkg. 1.0.0 26-OCT-24 22:44 Package
=================================================================================
  Copyright (c) 2024 Aerosimo

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
Name: authentication_pkg
Program Type: Package Specification
Purpose: ADD/FIND/UPDATE/DELETE entity
=================================================================================
HISTORY
=================================================================================
| DATE 		| Owner 	| Activity
=================================================================================
| 26-OCT-24	| eomisore 	| Created initial script.|
=================================================================================
*/
    -- Create or Update Authentication
    PROCEDURE loginUser(
        i_username IN account_tbl.uname%TYPE,
        i_password IN account_tbl.pword%TYPE,
		o_accountid OUT VARCHAR2,
        o_token OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_accountid     VARCHAR2(20);
        v_pword         VARCHAR2(400);
        v_failedLogin   NUMBER;
        v_status        VARCHAR2(50);
        v_token         VARCHAR2(100);
        v_error_message VARCHAR2(4000);
    BEGIN
        -- Fetch account details and status
        SELECT accountid, pword, failedLogin, status
        INTO v_accountid, v_pword, v_failedLogin, v_status
        FROM account_tbl
        WHERE uname = i_username;

        -- Check if account is active and password matches
        IF v_status != 'Active' THEN
            o_response := 'Account inactive';
            RETURN;
        ELSIF v_pword != i_password THEN
            UPDATE account_tbl
            SET failedLogin = failedLogin + 1,
                lastLogin = SYSTIMESTAMP
            WHERE accountid = v_accountid;
            o_response := 'Invalid credentials';
            RETURN;
        END IF;

        -- Reset failed attempts and update login
        UPDATE account_tbl
        SET failedLogin = 0, lastLogin = SYSTIMESTAMP
        WHERE accountid = v_accountid;

        -- Generate and return authentication token
        generateToken(v_accountid, o_token, v_token);
        o_accountid := v_accountid;
		o_token := v_token;
        o_response := 'Login successful';

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            o_response := 'User not found or account inactive';
        WHEN OTHERS THEN
            v_error_message := SUBSTR(SQLERRM, 1, 4000);
            ErrorHospital_pkg.ErrorCollector(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_error_message,
                    i_faultservice => 'account_pkg.loginUser',
                    o_response => o_response
            );
    END loginUser;

    PROCEDURE generateToken(
        i_accountid IN account_tbl.accountid%TYPE,
        o_token OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_expires       TIMESTAMP := SYSTIMESTAMP + INTERVAL '1' HOUR;
        v_error_message VARCHAR2(4000);
    BEGIN
        -- Generate and insert token
        INSERT INTO usertoken_tbl (accountid, issued, expires, status)
        VALUES (i_accountid, SYSTIMESTAMP, v_expires, 'Y')
        RETURNING authtoken INTO o_token;
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            v_error_message := SUBSTR(SQLERRM, 1, 4000);
            ErrorHospital_pkg.ErrorCollector(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_error_message,
                    i_faultservice => 'account_pkg.generateToken',
                    o_response => o_response
            );
    END generateToken;

    PROCEDURE validateToken(
        i_token IN usertoken_tbl.authtoken%TYPE,
        o_status OUT BOOLEAN)
    AS
        v_count         NUMBER;
        v_expires       TIMESTAMP;
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        SELECT COUNT(*), expires
        INTO v_count, v_expires
        FROM usertoken_tbl
        WHERE authtoken = i_token
          AND status = 'Y';
        IF v_count = 1 AND v_expires > SYSTIMESTAMP THEN
            o_status := TRUE;
        ELSE
            o_status := FALSE;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            o_status := FALSE;
        WHEN OTHERS THEN ROLLBACK;
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'account_pkg.validateToken',
                o_response => v_response
        );
    END validateToken;

    PROCEDURE invalidateToken(
        i_token IN usertoken_tbl.authtoken%TYPE)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE usertoken_tbl
        SET status       = 'N',
            modifiedBy   = USER,
            modifiedDate = SYSTIMESTAMP
        WHERE authtoken = i_token
          AND status = 'Y';

    EXCEPTION
        WHEN OTHERS THEN ROLLBACK;
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'account_pkg.invalidateToken',
                o_response => v_response
        );
    END invalidateToken;

END authentication_pkg;
/

PROMPT "Compiling Authentication Package"

ALTER PACKAGE authentication_pkg COMPILE PACKAGE;
ALTER PACKAGE authentication_pkg COMPILE BODY;
/

SHOW ERRORS
/

PROMPT "End of Authentication Schema."