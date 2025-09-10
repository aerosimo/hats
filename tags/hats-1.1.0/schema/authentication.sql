PROMPT "Creating Authentication Schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;


/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      authentication.sql                                              *
 * Created:   07/09/2025, 19:10                                               *
 * Modified:  07/09/2025, 19:11                                               *
 *                                                                            *
 * Copyright (c)  2025.  Aerosimo Ltd                                         *
 *                                                                            *
 * Permission is hereby granted, free of charge, to any person obtaining a    *
 * copy of this software and associated documentation files (the "Software"), *
 * to deal with the Software without restriction, including without limitation*
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
---------------------------------------------------------
-- TABLES creating the required tables for authentication
---------------------------------------------------------
-- Create main authentication tables
CREATE TABLE authentication_tbl
(
    email          VARCHAR2(200 BYTE),
    password       VARCHAR2(400 BYTE),
    email_verified CHAR(1) DEFAULT 'N' NOT NULL,
    failed_login   NUMBER DEFAULT 0,
    last_login     TIMESTAMP WITH TIME ZONE,
    account_status VARCHAR2(20) DEFAULT 'Inactive' NOT NULL,
    modifiedBy     VARCHAR2(100 BYTE),
    modifiedDate   TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL
);

-- Create email verification codes (for new signup or after password reset)
CREATE TABLE verification_tbl
(
    email             VARCHAR2(200 BYTE),
    verification_code VARCHAR2(100 BYTE),
    issued_at         TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    expires_at        TIMESTAMP WITH TIME ZONE NOT NULL,
    used_flag         CHAR(1) DEFAULT 'N' NOT NULL,
    modifiedBy        VARCHAR2(100 BYTE),
    modifiedDate      TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL
);

-- Create MFA codes generated on every (successful password) login attempt
CREATE TABLE mfa_tbl
(
    mfa_id       NUMBER GENERATED ALWAYS AS IDENTITY,
    email        VARCHAR2(200 BYTE) NOT NULL,
    mfa_code     VARCHAR2(64) NOT NULL,
    issued_at    TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    expires_at   TIMESTAMP WITH TIME ZONE NOT NULL,
    status       CHAR(1) DEFAULT 'N' NOT NULL, -- Y = used/consumed, N = active
    inet_addr    VARCHAR2(80),
    device_info  VARCHAR2(200),
    modifiedBy   VARCHAR2(100 BYTE),
    modifiedDate TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL
);

-- Session table (session token representing authenticated session)
CREATE TABLE user_session_tbl
(
    session_id    NUMBER GENERATED ALWAYS AS IDENTITY,
    email         VARCHAR2(200 BYTE) NOT NULL,
    session_token VARCHAR2(128) NOT NULL,
    issued_at     TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    expires_at    TIMESTAMP WITH TIME ZONE, -- nullable: set if session TTL enforced
    active_flag   CHAR(1) DEFAULT 'Y' NOT NULL,
    inet_addr     VARCHAR2(80),
    device_info   VARCHAR2(200),
    modifiedBy    VARCHAR2(100 BYTE),
    modifiedDate  TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL
);

-- Scrutiny / audit table for login/logout and password changes
CREATE TABLE scrutiny_tbl
(
    audit_id     NUMBER GENERATED ALWAYS AS IDENTITY,
    email        VARCHAR2(200 BYTE) NOT NULL,
    inet_addr    VARCHAR2(80),
    device_info  VARCHAR2(200),
    action_type  VARCHAR2(50) NOT NULL, -- LOGIN, LOGOUT, PASSWORD_RESET, SIGNUP, MFA_ISSUED, MFA_CONFIRMED, EMAIL_VERIFIED
    action_at    TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    session_id   NUMBER, -- FK to session table if relevant
    notes        VARCHAR2(4000),
    modifiedBy   VARCHAR2(100 BYTE),
    modifiedDate TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL
);

PROMPT "Setting Constraints"
------------------------------------------------------------
-- CONSTRAINTS / CHECKS creating the constraints and checks
------------------------------------------------------------
-- Create index to quickly find active sessions for an email
CREATE INDEX idx_session_email_active ON user_session_tbl (email, active_flag);

-- Setting Primary Key
ALTER TABLE authentication_tbl
    ADD CONSTRAINT auth_pk PRIMARY KEY (email);
ALTER TABLE mfa_tbl
    ADD CONSTRAINT mfa_pk PRIMARY KEY (mfa_id);
ALTER TABLE user_session_tbl
    ADD CONSTRAINT sess_pk PRIMARY KEY (session_id);
ALTER TABLE scrutiny_tbl
    ADD CONSTRAINT audit_pk PRIMARY KEY (audit_id);

-- Setting Foreign Key
ALTER TABLE verification_tbl
    ADD CONSTRAINT verification_fk FOREIGN KEY (email) REFERENCES authentication_tbl (email) ON DELETE CASCADE;
ALTER TABLE mfa_tbl
    ADD CONSTRAINT mfa_fk FOREIGN KEY (email) REFERENCES authentication_tbl (email) ON DELETE CASCADE;
ALTER TABLE user_session_tbl
    ADD CONSTRAINT sess_fk FOREIGN KEY (email) REFERENCES authentication_tbl (email) ON DELETE CASCADE;
ALTER TABLE scrutiny_tbl
    ADD CONSTRAINT scrutiny_email_fk FOREIGN KEY (email) REFERENCES authentication_tbl (email) ON DELETE CASCADE;
ALTER TABLE scrutiny_tbl
    ADD CONSTRAINT scrutiny_session_fk FOREIGN KEY (session_id) REFERENCES user_session_tbl (session_id) ON DELETE CASCADE;

-- Setting Unique Key
ALTER TABLE verification_tbl
    ADD CONSTRAINT verification_code_unq UNIQUE (verification_code);
ALTER TABLE user_session_tbl
    ADD CONSTRAINT session_token_unq UNIQUE (session_token);

-- Setting Check Constraint
ALTER TABLE authentication_tbl
    ADD CONSTRAINT email_verified_chk CHECK (email_verified IN ('Y', 'N')) ENABLE;
ALTER TABLE authentication_tbl
    ADD CONSTRAINT account_status_chk CHECK (account_status IN ('Active', 'Inactive', 'Locked')) ENABLE;
ALTER TABLE user_session_tbl
    ADD CONSTRAINT session_active_chk CHECK (active_flag IN ('Y', 'N')) ENABLE;
ALTER TABLE mfa_tbl
    ADD CONSTRAINT mfa_status_chk CHECK (status IN ('Y', 'N')) ENABLE;
ALTER TABLE verification_tbl
    ADD CONSTRAINT verification_used_chk CHECK (used_flag IN ('Y', 'N')) ENABLE;

PROMPT "Commenting Tables"
---------------------------------------------------------------------
-- COMMENTS for clarity (shorter and clearer)
---------------------------------------------------------------------
COMMENT ON COLUMN authentication_tbl.password IS 'This is contact set encrypted password';
COMMENT ON COLUMN authentication_tbl.email IS 'This is the account record primary identifier and also electronic mail is a method of exchanging messages between people using electronic devices.';
COMMENT ON COLUMN authentication_tbl.email_verified IS 'Y = email verified, N = not verified';
COMMENT ON COLUMN authentication_tbl.failed_login IS 'Consecutive failed password attempts';
COMMENT ON COLUMN authentication_tbl.last_login IS 'Timestamp of most recent successful login (after MFA).';
COMMENT ON COLUMN authentication_tbl.account_status IS 'Active / Inactive / Locked - account lifecycle state.';
COMMENT ON COLUMN authentication_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN authentication_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE authentication_tbl IS 'A user account is a location on a network server used to store a computer username, password, and other information. A user account allows or does not allow a user to connect to a network, another computer, or other shares.';

COMMENT ON TABLE verification_tbl IS 'Stores email verification codes for signup or password reset. Expire after configured interval.';
COMMENT ON COLUMN verification_tbl.email IS 'This is the primary identifier';
COMMENT ON COLUMN verification_tbl.verification_code IS 'This the generated verification code';
COMMENT ON COLUMN verification_tbl.issued_at IS 'This store the time the verification code was issued';
COMMENT ON COLUMN verification_tbl.expires_at IS 'This store the time the verification code expires';
COMMENT ON COLUMN verification_tbl.used_flag IS 'This indicates if the verification code was used or not';
COMMENT ON COLUMN verification_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN verification_tbl.modifiedDate IS 'Audit column - date of last update.';

COMMENT ON TABLE mfa_tbl IS 'Stores one-time MFA (authentication) codes generated on login; short-lived (e.g., 15 minutes).';
COMMENT ON COLUMN mfa_tbl.mfa_id IS 'This is the primary identifier';
COMMENT ON COLUMN mfa_tbl.email IS 'This is the primary identifier';
COMMENT ON COLUMN mfa_tbl.mfa_code IS 'This the generated authentication code';
COMMENT ON COLUMN mfa_tbl.issued_at IS 'This store the time the authentication code was issued';
COMMENT ON COLUMN mfa_tbl.expires_at IS 'This store the time the authentication code expires';
COMMENT ON COLUMN mfa_tbl.status IS 'This indicates if the authentication code was used or not';
COMMENT ON COLUMN mfa_tbl.inet_addr IS 'This user internet IP address';
COMMENT ON COLUMN mfa_tbl.device_info IS 'any device info such as mac address';
COMMENT ON COLUMN mfa_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN mfa_tbl.modifiedDate IS 'Audit column - date of last update.';

COMMENT ON TABLE user_session_tbl IS 'Active sessions for users; session_token is random and unique.';
COMMENT ON COLUMN user_session_tbl.session_id IS 'This is the primary identifier';
COMMENT ON COLUMN user_session_tbl.email IS 'This is the primary identifier';
COMMENT ON COLUMN user_session_tbl.session_token IS 'This the generated session code';
COMMENT ON COLUMN user_session_tbl.issued_at IS 'This store the time the session code was issued';
COMMENT ON COLUMN user_session_tbl.expires_at IS 'This store the time the session code expires';
COMMENT ON COLUMN user_session_tbl.active_flag IS 'This indicates if the session code is active or not';
COMMENT ON COLUMN user_session_tbl.inet_addr IS 'This user internet IP address';
COMMENT ON COLUMN user_session_tbl.device_info IS 'any device info such as mac address';
COMMENT ON COLUMN user_session_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN user_session_tbl.modifiedDate IS 'Audit column - date of last update.';

COMMENT ON TABLE scrutiny_tbl IS 'Audit log for authentication events (login/logout/password change/etc).';
COMMENT ON COLUMN scrutiny_tbl.audit_id IS 'This is the primary identifier';
COMMENT ON COLUMN scrutiny_tbl.email IS 'This is the primary identifier';
COMMENT ON COLUMN scrutiny_tbl.action_type IS 'This stores the type of action such as LOGIN, LOGOUT, PASSWORD_RESET, SIGNUP, MFA_ISSUED, MFA_CONFIRMED, EMAIL_VERIFIED';
COMMENT ON COLUMN scrutiny_tbl.action_at IS 'This store the time the action occurs';
COMMENT ON COLUMN scrutiny_tbl.session_id IS 'This store the time the session id';
COMMENT ON COLUMN scrutiny_tbl.notes IS 'This stores any other information';
COMMENT ON COLUMN scrutiny_tbl.inet_addr IS 'This user internet IP address';
COMMENT ON COLUMN scrutiny_tbl.device_info IS 'any device info such as mac address';
COMMENT ON COLUMN scrutiny_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN scrutiny_tbl.modifiedDate IS 'Audit column - date of last update.';

PROMPT "Creating Triggers"
--------------------------------------------------------------
-- TRIGGERS: update modified_date & modified_by automatically
--------------------------------------------------------------

CREATE OR REPLACE TRIGGER authentication_trg
    BEFORE INSERT OR UPDATE
    ON authentication_tbl
    FOR EACH ROW
DECLARE
    v_error_message VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        IF :NEW.email IS NULL THEN
            RAISE_APPLICATION_ERROR(-20004, 'Email is mandatory and cannot be empty.');
        END IF;
        IF :NEW.password IS NULL THEN
            RAISE_APPLICATION_ERROR(-20005, 'Password is mandatory and cannot be empty.');
        END IF;
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
        error_vault_pkg.store_error(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'authentication_trg (UPSERT): ' || :NEW.email,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER verification_trg
    BEFORE INSERT OR UPDATE
    ON verification_tbl
    FOR EACH ROW
DECLARE
    v_error_message VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        :NEW.verification_code := dbms_random.string('X', 10);
        :NEW.expires_at := SYSTIMESTAMP + INTERVAL '30' MINUTE;
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
        error_vault_pkg.store_error(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'verification_trg (UPSERT): ' || :NEW.email,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER mfa_trg
    BEFORE INSERT OR UPDATE
    ON mfa_tbl
    FOR EACH ROW
DECLARE
    v_error_message VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        :NEW.mfa_code := dbms_random.string('X', 6);
        :NEW.expires_at := SYSTIMESTAMP + INTERVAL '10' MINUTE;
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
        error_vault_pkg.store_error(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'mfa_trg (UPSERT): ' || :NEW.email,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER user_session_trg
    BEFORE INSERT OR UPDATE
    ON user_session_tbl
    FOR EACH ROW
DECLARE
    v_error_message VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        :NEW.session_token := dbms_random.string('X', 30);
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
        error_vault_pkg.store_error(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'user_session_trg (UPSERT): ' || :NEW.email,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER scrutiny_trg
    BEFORE INSERT OR UPDATE
    ON scrutiny_tbl
    FOR EACH ROW
DECLARE
    v_error_message VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    IF :NEW.modifiedBy IS NULL THEN
        :NEW.modifiedBy := USER;
    END IF;
    IF :NEW.modifiedDate IS NULL THEN
        :NEW.modifiedDate := SYSTIMESTAMP;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        error_vault_pkg.store_error(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'scrutiny_trg (UPSERT): ' || :NEW.email,
                o_response => v_response
        );
        RAISE;
END;
/

PROMPT "Enabling Triggers"

-- Enable Triggers
ALTER TRIGGER authentication_trg ENABLE;
ALTER TRIGGER verification_trg ENABLE;
ALTER TRIGGER mfa_trg ENABLE;
ALTER TRIGGER user_session_trg ENABLE;
ALTER TRIGGER scrutiny_trg ENABLE;

PROMPT "Creating Package Header"
--------------------------------------------------------------
-- PACKAGE: Creating authentication header package
--------------------------------------------------------------
-- Create Header Package
CREATE OR REPLACE PACKAGE auth_pkg
AS
    /* Header Package
    =================================================================================
    Copyright (c) 2025 Aerosimo

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
    Name: auth_pkg
    Program Type: Package Specification
    Purpose: ADD/FIND/UPDATE/DELETE entity
    =================================================================================
    HISTORY
    =================================================================================
    | DATE 		| Owner 	| Activity
    =================================================================================
    | 08-SEP-25	| eomisore 	| Created initial script.|
    =================================================================================
    */

    -- Get Verification Code
    PROCEDURE get_verification(
        i_email IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_verificationCode OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Audit records
    PROCEDURE audit(
        i_email IN VARCHAR2,
        i_actionType IN VARCHAR2,
        i_notes IN VARCHAR2,
        i_sessionId IN VARCHAR2,
        i_modifiedBy IN VARCHAR2);

    -- Get MFA token
    PROCEDURE get_mfa(
        i_email IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_mfaCode OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Get session token
    PROCEDURE get_session(
        i_email IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_token OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Sign up
    PROCEDURE signup(
        i_email IN VARCHAR2,
        i_password IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_verificationCode OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Verify email
    PROCEDURE confirm_email(
        i_email IN VARCHAR2,
        i_verificationCode IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Verify multi factor
    PROCEDURE confirm_mfa(
        i_email IN VARCHAR2,
        i_mfaCode IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_token OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Login
    PROCEDURE login(
        i_email IN VARCHAR2,
        i_password IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_mfaCode OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Logout
    PROCEDURE logout(
        i_email IN VARCHAR2,
        i_sessionToken IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Forgot Password
    PROCEDURE forgot_password(
        i_email IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_verificationCode OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Reset Password
    PROCEDURE reset_password(
        i_email IN VARCHAR2,
        i_verificationCode IN VARCHAR2,
        i_password IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_response OUT VARCHAR2);

END auth_pkg;
/

PROMPT "Creating Package Body"
--------------------------------------------------------------
-- PACKAGE: Creating authentication body package
--------------------------------------------------------------
-- Create Body Package
CREATE OR REPLACE PACKAGE BODY auth_pkg
AS
    /* Body Package
    =================================================================================
    Copyright (c) 2025 Aerosimo

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
    Name: auth_pkg
    Program Type: Package Specification
    Purpose: ADD/FIND/UPDATE/DELETE entity
    =================================================================================
    HISTORY
    =================================================================================
    | DATE 		| Owner 	| Activity
    =================================================================================
    | 08-SEP-25	| eomisore 	| Created initial script.|
    =================================================================================
    */
    -- Get Verification Code
    PROCEDURE get_verification(
        i_email IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_verificationCode OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        -- insert verification records
        INSERT INTO verification_tbl(email, modifiedBy)
        VALUES (i_email, i_modifiedBy)
        RETURNING verification_code INTO o_verificationCode;
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            v_error_message := SUBSTR(SQLERRM, 1, 4000);
            error_vault_pkg.store_error(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_error_message,
                    i_faultservice => 'auth_pkg (GET VERIFICATION CODE): ' || i_email,
                    o_response => v_response
            );
            o_response := v_error_message;
    END get_verification;

    -- Audit records
    PROCEDURE audit(
        i_email IN VARCHAR2,
        i_actionType IN VARCHAR2,
        i_notes IN VARCHAR2,
        i_sessionId IN VARCHAR2,
        i_modifiedBy IN VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        -- insert audit records
        INSERT INTO scrutiny_tbl(email, action_type, notes, session_id, modifiedBy)
        VALUES (i_email, i_actionType, i_notes, i_sessionId, i_modifiedBy);
    EXCEPTION
        WHEN OTHERS THEN
            v_error_message := SUBSTR(SQLERRM, 1, 4000);
            error_vault_pkg.store_error(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_error_message,
                    i_faultservice => 'auth_pkg (LOG AUDIT): ' || i_email,
                    o_response => v_response
            );
    END audit;

    -- Get MFA token
    PROCEDURE get_mfa(
        i_email IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_mfaCode OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        -- insert mfa records
        INSERT INTO mfa_tbl(email, inet_addr, device_info, modifiedBy)
        VALUES (i_email, i_inet, i_device, i_modifiedBy)
        RETURNING mfa_code INTO o_mfaCode;
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            v_error_message := SUBSTR(SQLERRM, 1, 4000);
            error_vault_pkg.store_error(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_error_message,
                    i_faultservice => 'auth_pkg (GET MFA): ' || i_email,
                    o_response => v_response
            );
    END get_mfa;

    -- Get session token
    PROCEDURE get_session(
        i_email IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_token OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        -- insert mfa records
        INSERT INTO user_session_tbl(email, inet_addr, device_info, modifiedBy)
        VALUES (i_email, i_inet, i_device, i_modifiedBy)
        RETURNING session_token INTO o_token;
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            v_error_message := SUBSTR(SQLERRM, 1, 4000);
            error_vault_pkg.store_error(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_error_message,
                    i_faultservice => 'auth_pkg (GET SESSION): ' || i_email,
                    o_response => v_response
            );
    END get_session;

    -- Sign up
    PROCEDURE signup(
        i_email IN VARCHAR2,
        i_password IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_verificationCode OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        -- insert authentication details and verification details
        INSERT INTO authentication_tbl(email, password, modifiedBy)
        VALUES (i_email, utl_encode.base64_encode(utl_raw.cast_to_raw(enc_dec.encrypt(i_password))), i_modifiedBy);
        -- Generate and return authentication token
        get_verification(i_email, i_modifiedBy, o_verificationCode, v_response);
        -- insert records for audit purpose
        audit(i_email, 'EMAIL_VERIFICATION_ISSUED', 'Verification code issued', '', i_modifiedBy);
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            v_error_message := SUBSTR(SQLERRM, 1, 4000);
            error_vault_pkg.store_error(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_error_message,
                    i_faultservice => 'auth_pkg (SIGNUP): ' || i_email,
                    o_response => v_response
            );
            o_response := 'signup error: ' || v_error_message;
    END signup;

    -- Verify email
    PROCEDURE confirm_email(
        i_email IN VARCHAR2,
        i_verificationCode IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_count         NUMBER;
    BEGIN
        -- Fetch authentication details and status
        SELECT COUNT(*)
        INTO v_count
        FROM verification_tbl
        WHERE email = i_email
          AND verification_code = i_verificationCode
          AND used_flag = 'N'
          AND expires_at >= SYSTIMESTAMP;
        IF v_count = 1 THEN
            UPDATE authentication_tbl
            SET email_verified = 'Y',
                account_status = 'Active',
                modifiedBy     = i_modifiedBy
            WHERE email = i_email;
            -- insert records for audit purpose
            audit(i_email, 'EMAIL_VERIFIED', 'Email verified successfully', '', i_modifiedBy);
            o_response := 'success';
        ELSE
            o_response := 'invalid or expired verification code';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_error_message := SUBSTR(SQLERRM, 1, 4000);
            error_vault_pkg.store_error(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_error_message,
                    i_faultservice => 'auth_pkg (CONFIRM EMAIL): ' || i_email,
                    o_response => v_response
            );
            o_response := 'email verification error: ' || v_error_message;
    END confirm_email;

    -- Verify mfa token
    PROCEDURE confirm_mfa(
        i_email IN VARCHAR2,
        i_mfaCode IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_token OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_count         NUMBER;
    BEGIN
        -- Fetch authentication details and status
        SELECT COUNT(*)
        INTO v_count
        FROM mfa_tbl
        WHERE email = i_email
          AND mfa_code = i_mfaCode
          AND status = 'N'
          AND expires_at >= SYSTIMESTAMP;
        IF v_count = 1 THEN
            UPDATE mfa_tbl
            SET status = 'Y',
                modifiedBy = i_modifiedBy
            WHERE email = i_email;
            -- get session token identification
            get_session(i_email,i_inet,i_device,i_modifiedBy,o_token,o_response);
            -- set last_login timestamp in authentication_tbl
            UPDATE authentication_tbl
            SET last_login = SYSTIMESTAMP, modifiedBy = i_modifiedBy
            WHERE email = i_email;
            -- insert records for audit purpose
            audit(i_email, 'LOGIN', 'Login successful (MFA confirmed)', '', i_modifiedBy);
            o_response := 'success';
        ELSE
            o_response := 'invalid or expired MFA token';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_error_message := SUBSTR(SQLERRM, 1, 4000);
            error_vault_pkg.store_error(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_error_message,
                    i_faultservice => 'auth_pkg (CONFIRM MFA): ' || i_email,
                    o_response => v_response
            );
            o_response := 'confirm mfa error: ' || v_error_message;
    END confirm_mfa;

    -- Login
    PROCEDURE login(
        i_email IN VARCHAR2,
        i_password IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_mfaCode OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_count         NUMBER;
        v_verify        VARCHAR2(20);
        v_password      VARCHAR2(400);
        v_status        VARCHAR2(50);
    BEGIN
        -- Fetch authentication details and status
        SELECT password, email_verified,account_status
        INTO v_password, v_verify, v_status
        FROM authentication_tbl
        WHERE email = i_email;
            -- Check if an account is active and password matches
            IF v_status != 'Active' THEN
                -- insert records for audit purpose
                audit(i_email, 'FAILED_LOGIN', 'Account locked', '', i_modifiedBy);
                o_response := 'account locked';
            ELSIF enc_dec.decrypt(utl_raw.cast_to_varchar2(utl_encode.base64_decode(v_password))) != i_password THEN
                UPDATE authentication_tbl SET failed_login = NVL(failed_login,0) + 1, modifiedBy = i_modifiedBy
                WHERE email = i_email;
                -- insert records for audit purpose
                audit(i_email, 'FAILED_LOGIN', 'Failed password', '', i_modifiedBy);
                o_response := 'invalid credentials';
            ELSE
                -- password matched. Reset failed_login.
                UPDATE authentication_tbl SET failed_login = 0, modifiedBy = i_modifiedBy WHERE email = i_email;
                get_mfa(i_email,i_inet,i_device,i_modifiedBy,o_mfaCode,o_response);
                -- insert records for audit purpose
                audit(i_email, 'MFA_ISSUED', 'MFA code issued (login step)', '', i_modifiedBy);
            END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_error_message := SUBSTR(SQLERRM, 1, 4000);
            error_vault_pkg.store_error(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_error_message,
                    i_faultservice => 'auth_pkg (LOGIN): ' || i_email,
                    o_response => v_response
            );
            o_response := 'invalid credentials';
        WHEN OTHERS THEN
            v_error_message := SUBSTR(SQLERRM, 1, 4000);
            error_vault_pkg.store_error(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_error_message,
                    i_faultservice => 'auth_pkg (LOGIN): ' || i_email,
                    o_response => v_response
            );
            o_response := 'login request error:  ' || v_error_message;
    END login;

    -- Logout
    PROCEDURE logout(
        i_email IN VARCHAR2,
        i_sessionToken IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        -- Reset active flag of token.
        UPDATE user_session_tbl SET active_flag = 'N', modifiedBy = i_modifiedBy
        WHERE email = i_email AND session_token = i_sessionToken AND active_flag = 'Y';
        -- insert records for audit purpose
        audit(i_email, 'MFA_ISSUED', 'MFA code issued (login step)', i_sessionToken, i_modifiedBy);
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            v_error_message := SUBSTR(SQLERRM, 1, 4000);
            error_vault_pkg.store_error(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_error_message,
                    i_faultservice => 'auth_pkg (LOGOUT): ' || i_email,
                    o_response => v_response
            );
            o_response := 'logout error: ' || v_error_message;
    END logout;

    -- Forgot Password
    PROCEDURE forgot_password(
        i_email IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_verificationCode OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        -- Generate and return authentication token
        get_verification(i_email, i_modifiedBy, o_verificationCode, o_response);
        -- insert records for audit purpose
        audit(i_email, 'FORGOT PASSWORD', 'Verification code issued for forget password', '', i_modifiedBy);
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            v_error_message := SUBSTR(SQLERRM, 1, 4000);
            error_vault_pkg.store_error(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_error_message,
                    i_faultservice => 'auth_pkg (FORGET PASSWORD): ' || i_email,
                    o_response => v_response
            );
            o_response := 'forgot password error: ' || v_error_message;
    END forgot_password;

    -- Reset Password
    PROCEDURE reset_password(
        i_email IN VARCHAR2,
        i_verificationCode IN VARCHAR2,
        i_password IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_count         NUMBER;
    BEGIN
        -- Fetch authentication details and status
        SELECT COUNT(*)
        INTO v_count
        FROM verification_tbl
        WHERE email = i_email
          AND verification_code = i_verificationCode
          AND used_flag = 'N'
          AND expires_at >= SYSTIMESTAMP;
        IF v_count = 1 THEN
            UPDATE verification_tbl
                SET used_flag = 'Y', modifiedBy = i_modifiedBy
            WHERE email = i_email
              AND verification_code = i_verificationCode;
            UPDATE authentication_tbl
                SET password = utl_encode.base64_encode(utl_raw.cast_to_raw(enc_dec.encrypt(i_password))),
                    modifiedBy = i_modifiedBy
            WHERE email = i_email;
            -- insert records for audit purpose
            audit(i_email, 'PASSWORD_RESET', 'Password reset via verification code', '', i_modifiedBy);
            o_response := 'success';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_error_message := SUBSTR(SQLERRM, 1, 4000);
            error_vault_pkg.store_error(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_error_message,
                    i_faultservice => 'auth_pkg (RESET PASSWORD): ' || i_email,
                    o_response => v_response
            );
            o_response := 'reset password error: ' || v_error_message;
    END reset_password;
END auth_pkg;
/

PROMPT "Compiling Package"

ALTER PACKAGE auth_pkg COMPILE PACKAGE;
ALTER PACKAGE auth_pkg COMPILE BODY;
/

SHOW ERRORS
/

PROMPT "End of creating Authentication Schema"