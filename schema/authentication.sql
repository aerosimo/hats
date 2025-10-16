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
    username       VARCHAR2(200 BYTE) NOT NULL,
    email          VARCHAR2(200 BYTE) NOT NULL,
    password       VARCHAR2(400 BYTE),
    emailVerified  CHAR(1) DEFAULT 'N' NOT NULL,
    failedLogin    NUMBER DEFAULT 0,
    lastLogin      TIMESTAMP,
    accountStatus  VARCHAR2(20) DEFAULT 'Inactive' NOT NULL,
    modifiedBy     VARCHAR2(100 BYTE),
    modifiedDate   TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- Create email verification codes (for new signup or after password reset)
CREATE TABLE verification_tbl
(
    username            VARCHAR2(200 BYTE) NOT NULL,
    email               VARCHAR2(200 BYTE) NOT NULL,
    verificationCode    VARCHAR2(100 BYTE),
    issuedAt            TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    expiresAt           TIMESTAMP,
    usedFlag            CHAR(1) DEFAULT 'N' NOT NULL,
    modifiedBy          VARCHAR2(100 BYTE),
    modifiedDate        TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- Create MFA codes generated on every (successful password) login attempt
CREATE TABLE mfa_tbl
(
    mfaId        NUMBER GENERATED ALWAYS AS IDENTITY,
    username     VARCHAR2(200 BYTE) NOT NULL,
    email        VARCHAR2(200 BYTE) NOT NULL,
    mfaCode      VARCHAR2(64) NOT NULL,
    issuedAt     TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    expiresAt    TIMESTAMP NOT NULL,
    status       CHAR(1) DEFAULT 'N' NOT NULL,
    inetAddr     VARCHAR2(80),
    deviceInfo   VARCHAR2(200),
    modifiedBy   VARCHAR2(100 BYTE),
    modifiedDate TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- Session table (session token representing authenticated session)
CREATE TABLE session_tbl
(
    sessionId     NUMBER GENERATED ALWAYS AS IDENTITY,
    username      VARCHAR2(200 BYTE) NOT NULL,
    email         VARCHAR2(200 BYTE) NOT NULL,
    sessionToken  VARCHAR2(128) NOT NULL,
    issuedAt      TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    expiresAt     TIMESTAMP,
    activeFlag    CHAR(1) DEFAULT 'Y' NOT NULL,
    inetAddr      VARCHAR2(80),
    deviceInfo    VARCHAR2(200),
    modifiedBy    VARCHAR2(100 BYTE),
    modifiedDate  TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- Scrutiny / audit table for login/logout and password changes
CREATE TABLE scrutiny_tbl
(
    auditId      NUMBER GENERATED ALWAYS AS IDENTITY,
    username     VARCHAR2(200 BYTE) NOT NULL,
    email        VARCHAR2(200 BYTE) NOT NULL,
    actionType   VARCHAR2(50) NOT NULL,
    actionAt     TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    notes        VARCHAR2(4000),
    modifiedBy   VARCHAR2(100 BYTE),
    modifiedDate TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- jwt tokenization table
CREATE TABLE jwt_tbl
(
    username        VARCHAR2(200 BYTE) NOT NULL,
    email           VARCHAR2(200 BYTE) NOT NULL,
    password        VARCHAR2(400 BYTE),
    jwtToken        VARCHAR2(2000 BYTE),
    issued          TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    expires         TIMESTAMP,
    status          CHAR(1),
    accountStatus   VARCHAR2(20) DEFAULT 'Inactive',
    modifiedBy      VARCHAR2(100 BYTE),
    modifiedDate    TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

PROMPT "Setting Constraints"
------------------------------------------------------------
-- CONSTRAINTS / CHECKS creating the constraints and checks
------------------------------------------------------------
-- Create index to quickly find active sessions for an email
CREATE INDEX authentication_idx ON authentication_tbl (email, username);
CREATE INDEX verification_idx ON verification_tbl (email, username);
CREATE INDEX mfa_idx ON mfa_tbl (email, username);
CREATE INDEX session_idx ON session_tbl (email, username);
CREATE INDEX jwt_idx ON jwt_tbl (email, username);

-- Setting Primary Key
ALTER TABLE authentication_tbl ADD CONSTRAINT auth_pk PRIMARY KEY (email);
ALTER TABLE mfa_tbl ADD CONSTRAINT mfa_pk PRIMARY KEY (mfaId);
ALTER TABLE session_tbl ADD CONSTRAINT sess_pk PRIMARY KEY (sessionId);
ALTER TABLE scrutiny_tbl ADD CONSTRAINT audit_pk PRIMARY KEY (auditId);

-- Setting Foreign Key
ALTER TABLE verification_tbl ADD CONSTRAINT verification_fk FOREIGN KEY (email) REFERENCES authentication_tbl (email) ON DELETE CASCADE;
ALTER TABLE mfa_tbl ADD CONSTRAINT mfa_fk FOREIGN KEY (email) REFERENCES authentication_tbl (email) ON DELETE CASCADE;
ALTER TABLE session_tbl ADD CONSTRAINT sess_fk FOREIGN KEY (email) REFERENCES authentication_tbl (email) ON DELETE CASCADE;

-- Setting Unique Key
ALTER TABLE authentication_tbl ADD CONSTRAINT uname_unq UNIQUE (username);
ALTER TABLE verification_tbl ADD CONSTRAINT verification_code_unq UNIQUE (verificationCode);
ALTER TABLE session_tbl ADD CONSTRAINT session_unq UNIQUE (sessionToken);
ALTER TABLE jwt_tbl ADD CONSTRAINT jwt_uname_unq UNIQUE (username);
ALTER TABLE jwt_tbl ADD CONSTRAINT jwt_email_unq UNIQUE (email);
ALTER TABLE mfa_tbl ADD CONSTRAINT mfa_unq UNIQUE (mfaCode);

-- Setting Check Constraint
ALTER TABLE authentication_tbl ADD CONSTRAINT email_verified_chk CHECK (emailVerified IN ('Y', 'N')) ENABLE;
ALTER TABLE authentication_tbl ADD CONSTRAINT account_status_chk CHECK (accountStatus IN ('Active', 'Inactive', 'Locked')) ENABLE;
ALTER TABLE session_tbl ADD CONSTRAINT session_active_chk CHECK (activeFlag IN ('Y', 'N')) ENABLE;
ALTER TABLE mfa_tbl ADD CONSTRAINT mfa_status_chk CHECK (status IN ('Y', 'N')) ENABLE;
ALTER TABLE verification_tbl ADD CONSTRAINT verification_used_chk CHECK (usedFlag IN ('Y', 'N')) ENABLE;
ALTER TABLE jwt_tbl ADD CONSTRAINT jwt_status_chk CHECK (status IN ('A','R','E')) ENABLE;
-- ALTER TABLE jwt_tbl ADD CONSTRAINT jwt_account_chk CHECK (accountStatus IN ('Active', 'Inactive', 'Locked')) ENABLE;

---------------------------------------------------------------------
-- HISTORY for archived purpose
---------------------------------------------------------------------
-- Create history tables
CREATE TABLE authentication_history_tbl AS SELECT * FROM authentication_tbl WHERE 1 = 0;
CREATE TABLE verification_history_tbl AS SELECT * FROM verification_tbl WHERE 1 = 0;
CREATE TABLE mfa_history_tbl AS SELECT * FROM mfa_tbl WHERE 1 = 0;
CREATE TABLE session_history_tbl AS SELECT * FROM session_tbl WHERE 1 = 0;
CREATE TABLE jwt_history_tbl AS SELECT * FROM jwt_tbl WHERE 1 = 0;

ALTER TABLE authentication_history_tbl ADD modifiedReason VARCHAR2(200);
ALTER TABLE authentication_history_tbl ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE verification_history_tbl ADD modifiedReason VARCHAR2(200);
ALTER TABLE verification_history_tbl ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE mfa_history_tbl ADD modifiedReason VARCHAR2(200);
ALTER TABLE mfa_history_tbl ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE session_history_tbl ADD modifiedReason VARCHAR2(200);
ALTER TABLE session_history_tbl ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE jwt_history_tbl ADD modifiedReason VARCHAR2(200);
ALTER TABLE jwt_history_tbl ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;

PROMPT "Commenting Tables"
---------------------------------------------------------------------
-- COMMENTS for clarity (shorter and clearer)
---------------------------------------------------------------------
COMMENT ON COLUMN authentication_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN authentication_tbl.password IS 'This is contact set encrypted password';
COMMENT ON COLUMN authentication_tbl.email IS 'This is the account record primary identifier and also electronic mail is a method of exchanging messages between people using electronic devices.';
COMMENT ON COLUMN authentication_tbl.emailVerified IS 'Y = email verified, N = not verified';
COMMENT ON COLUMN authentication_tbl.failedLogin IS 'Consecutive failed password attempts';
COMMENT ON COLUMN authentication_tbl.lastLogin IS 'Timestamp of most recent successful login (after MFA).';
COMMENT ON COLUMN authentication_tbl.accountStatus IS 'Active / Inactive / Locked - account lifecycle state.';
COMMENT ON COLUMN authentication_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN authentication_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE authentication_tbl IS 'A user account is a location on a network server used to store a computer username, password, and other information. A user account allows or does not allow a user to connect to a network, another computer, or other shares.';

COMMENT ON COLUMN authentication_history_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN authentication_history_tbl.password IS 'This is contact set encrypted password';
COMMENT ON COLUMN authentication_history_tbl.email IS 'This is the account record primary identifier and also electronic mail is a method of exchanging messages between people using electronic devices.';
COMMENT ON COLUMN authentication_history_tbl.emailVerified IS 'Y = email verified, N = not verified';
COMMENT ON COLUMN authentication_history_tbl.failedLogin IS 'Consecutive failed password attempts';
COMMENT ON COLUMN authentication_history_tbl.lastLogin IS 'Timestamp of most recent successful login (after MFA).';
COMMENT ON COLUMN authentication_history_tbl.accountStatus IS 'Active / Inactive / Locked - account lifecycle state.';
COMMENT ON COLUMN authentication_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN authentication_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN authentication_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN authentication_history_tbl.archivedDate IS 'Audit column - date of it was archived.';
COMMENT ON TABLE authentication_history_tbl IS 'A user account is a location on a network server used to store a computer username, password, and other information. A user account allows or does not allow a user to connect to a network, another computer, or other shares.';

COMMENT ON TABLE verification_tbl IS 'Stores email verification codes for signup or password reset. Expire after configured interval.';
COMMENT ON COLUMN verification_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN verification_tbl.email IS 'This is the primary identifier';
COMMENT ON COLUMN verification_tbl.verificationCode IS 'This the generated verification code';
COMMENT ON COLUMN verification_tbl.issuedAt IS 'This store the time the verification code was issued';
COMMENT ON COLUMN verification_tbl.expiresAt IS 'This store the time the verification code expires';
COMMENT ON COLUMN verification_tbl.usedFlag IS 'This indicates if the verification code was used or not';
COMMENT ON COLUMN verification_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN verification_tbl.modifiedDate IS 'Audit column - date of last update.';

COMMENT ON TABLE verification_history_tbl IS 'Stores email verification codes for signup or password reset. Expire after configured interval.';
COMMENT ON COLUMN verification_history_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN verification_history_tbl.email IS 'This is the primary identifier';
COMMENT ON COLUMN verification_history_tbl.verificationCode IS 'This the generated verification code';
COMMENT ON COLUMN verification_history_tbl.issuedAt IS 'This store the time the verification code was issued';
COMMENT ON COLUMN verification_history_tbl.expiresAt IS 'This store the time the verification code expires';
COMMENT ON COLUMN verification_history_tbl.usedFlag IS 'This indicates if the verification code was used or not';
COMMENT ON COLUMN verification_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN verification_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN verification_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN verification_history_tbl.archivedDate IS 'Audit column - date of it was archived.';

COMMENT ON TABLE mfa_tbl IS 'Stores one-time MFA (authentication) codes generated on login; short-lived (e.g., 15 minutes).';
COMMENT ON COLUMN mfa_tbl.mfaId IS 'This is the primary identifier';
COMMENT ON COLUMN mfa_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN mfa_tbl.email IS 'This is the primary identifier';
COMMENT ON COLUMN mfa_tbl.mfaCode IS 'This the generated authentication code';
COMMENT ON COLUMN mfa_tbl.issuedAt IS 'This store the time the authentication code was issued';
COMMENT ON COLUMN mfa_tbl.expiresAt IS 'This store the time the authentication code expires';
COMMENT ON COLUMN mfa_tbl.status IS 'This indicates if the authentication code was used or not';
COMMENT ON COLUMN mfa_tbl.inetAddr IS 'This user internet IP address';
COMMENT ON COLUMN mfa_tbl.deviceInfo IS 'any device info such as mac address';
COMMENT ON COLUMN mfa_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN mfa_tbl.modifiedDate IS 'Audit column - date of last update.';

COMMENT ON TABLE mfa_history_tbl IS 'Stores one-time MFA (authentication) codes generated on login; short-lived (e.g., 15 minutes).';
COMMENT ON COLUMN mfa_history_tbl.mfaId IS 'This is the primary identifier';
COMMENT ON COLUMN mfa_history_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN mfa_history_tbl.email IS 'This is the primary identifier';
COMMENT ON COLUMN mfa_history_tbl.mfaCode IS 'This the generated authentication code';
COMMENT ON COLUMN mfa_history_tbl.issuedAt IS 'This store the time the authentication code was issued';
COMMENT ON COLUMN mfa_history_tbl.expiresAt IS 'This store the time the authentication code expires';
COMMENT ON COLUMN mfa_history_tbl.status IS 'This indicates if the authentication code was used or not';
COMMENT ON COLUMN mfa_history_tbl.inetAddr IS 'This user internet IP address';
COMMENT ON COLUMN mfa_history_tbl.deviceInfo IS 'any device info such as mac address';
COMMENT ON COLUMN mfa_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN mfa_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN mfa_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN mfa_history_tbl.archivedDate IS 'Audit column - date of it was archived.';

COMMENT ON TABLE session_tbl IS 'Active sessions for users; session_token is random and unique.';
COMMENT ON COLUMN session_tbl.sessionId IS 'This is the primary identifier';
COMMENT ON COLUMN session_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN session_tbl.email IS 'This is the primary identifier';
COMMENT ON COLUMN session_tbl.sessionToken IS 'This the generated session code';
COMMENT ON COLUMN session_tbl.issuedAt IS 'This store the time the session code was issued';
COMMENT ON COLUMN session_tbl.expiresAt IS 'This store the time the session code expires';
COMMENT ON COLUMN session_tbl.activeFlag IS 'This indicates if the session code is active or not';
COMMENT ON COLUMN session_tbl.inetAddr IS 'This user internet IP address';
COMMENT ON COLUMN session_tbl.deviceInfo IS 'any device info such as mac address';
COMMENT ON COLUMN session_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN session_tbl.modifiedDate IS 'Audit column - date of last update.';

COMMENT ON TABLE session_history_tbl IS 'Active sessions for users; session_token is random and unique.';
COMMENT ON COLUMN session_history_tbl.sessionId IS 'This is the primary identifier';
COMMENT ON COLUMN session_history_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN session_history_tbl.email IS 'This is the primary identifier';
COMMENT ON COLUMN session_history_tbl.sessionToken IS 'This the generated session code';
COMMENT ON COLUMN session_history_tbl.issuedAt IS 'This store the time the session code was issued';
COMMENT ON COLUMN session_history_tbl.expiresAt IS 'This store the time the session code expires';
COMMENT ON COLUMN session_history_tbl.activeFlag IS 'This indicates if the session code is active or not';
COMMENT ON COLUMN session_history_tbl.inetAddr IS 'This user internet IP address';
COMMENT ON COLUMN session_history_tbl.deviceInfo IS 'any device info such as mac address';
COMMENT ON COLUMN session_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN session_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN session_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN session_history_tbl.archivedDate IS 'Audit column - date of it was archived.';

COMMENT ON TABLE scrutiny_tbl IS 'Audit log for authentication events (login/logout/password change/etc).';
COMMENT ON COLUMN scrutiny_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN scrutiny_tbl.auditId IS 'This is the primary identifier';
COMMENT ON COLUMN scrutiny_tbl.email IS 'This is the primary identifier';
COMMENT ON COLUMN scrutiny_tbl.actionType IS 'This stores the type of action such as LOGIN, LOGOUT, PASSWORD_RESET, SIGNUP, MFA_ISSUED, MFA_CONFIRMED, EMAIL_VERIFIED';
COMMENT ON COLUMN scrutiny_tbl.actionAt IS 'This store the time the action occurs';
COMMENT ON COLUMN scrutiny_tbl.notes IS 'This stores any other information';
COMMENT ON COLUMN scrutiny_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN scrutiny_tbl.modifiedDate IS 'Audit column - date of last update.';

COMMENT ON COLUMN jwt_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN jwt_tbl.password IS 'This is contact set encrypted password';
COMMENT ON COLUMN jwt_tbl.email IS 'This is the account record primary identifier and also electronic mail is a method of exchanging messages between people using electronic devices.';
COMMENT ON COLUMN jwt_tbl.jwtToken IS 'Stores the generated token for user authentication.';
COMMENT ON COLUMN jwt_tbl.issued IS 'Track token validity period';
COMMENT ON COLUMN jwt_tbl.expires IS 'Track token validity period';
COMMENT ON COLUMN jwt_tbl.status IS 'Indicates whether the user token is active or not (Y or N).';
COMMENT ON COLUMN jwt_tbl.accountStatus IS 'Active / Inactive / Locked - account lifecycle state.';
COMMENT ON COLUMN jwt_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN jwt_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE jwt_tbl IS 'A user account is a location on a network server used to store a computer username, password, and other information. A user account allows or does not allow a user to connect to a network, another computer, or other shares.';

COMMENT ON COLUMN jwt_history_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN jwt_history_tbl.password IS 'This is contact set encrypted password';
COMMENT ON COLUMN jwt_history_tbl.email IS 'This is the account record primary identifier and also electronic mail is a method of exchanging messages between people using electronic devices.';
COMMENT ON COLUMN jwt_history_tbl.jwtToken IS 'Stores the generated token for user authentication.';
COMMENT ON COLUMN jwt_history_tbl.issued IS 'Track token validity period';
COMMENT ON COLUMN jwt_history_tbl.expires IS 'Track token validity period';
COMMENT ON COLUMN jwt_history_tbl.status IS 'Indicates whether the user token is active or not (Y or N).';
COMMENT ON COLUMN jwt_history_tbl.accountStatus IS 'Active / Inactive / Locked - account lifecycle state.';
COMMENT ON COLUMN jwt_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN jwt_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN jwt_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN jwt_history_tbl.archivedDate IS 'Audit column - date of it was archived.';
COMMENT ON TABLE jwt_history_tbl IS 'A user account is a location on a network server used to store a computer username, password, and other information. A user account allows or does not allow a user to connect to a network, another computer, or other shares.';

PROMPT "Creating Triggers"
--------------------------------------------------------------
-- TRIGGERS: update modified_date & modified_by automatically
--------------------------------------------------------------
CREATE OR REPLACE TRIGGER verification_trg
    BEFORE INSERT OR UPDATE
    ON verification_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage    VARCHAR2(4000);
    v_response        VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'Username is mandatory and cannot be empty.');
        END IF;
        IF :NEW.email IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Email is mandatory and cannot be empty.');
        END IF;
        :NEW.verificationCode := dbms_random.string('X', 10);
        :NEW.expiresAt := SYSTIMESTAMP + INTERVAL '15' MINUTE;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN SELECT :OLD.username INTO :NEW.username FROM DUAL; END IF;
        IF :NEW.email IS NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        :NEW.verificationCode := dbms_random.string('X', 10);
        :NEW.expiresAt := SYSTIMESTAMP + INTERVAL '15' MINUTE;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'verification_trg (UPSERT): ' || :NEW.email,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER verification_audit_trg
    AFTER UPDATE OR DELETE
    ON verification_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage    VARCHAR2(4000);
    v_response        VARCHAR2(100);
    v_modifiedReason  VARCHAR2(10);
BEGIN
    -- Determine whether the action is an update or delete
    IF UPDATING THEN
        v_modifiedReason := 'Updated';
        -- Log the update or delete in the history table
        INSERT INTO verification_history_tbl(username,email,verificationCode,issuedAt,expiresAt,usedFlag,modifiedBy,modifiedDate,modifiedReason)
        VALUES (:OLD.username,:OLD.email,:OLD.verificationCode,:OLD.issuedAt,:OLD.expiresAt,:OLD.usedFlag,:OLD.modifiedBy,:OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO verification_history_tbl(username,email,verificationCode,issuedAt,expiresAt,usedFlag,modifiedBy,modifiedDate,modifiedReason)
        VALUES (:OLD.username,:OLD.email,:OLD.verificationCode,:OLD.issuedAt,:OLD.expiresAt,:OLD.usedFlag,:OLD.modifiedBy,:OLD.modifiedDate, v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'verification_audit_trg: ' ||
                                  CASE
                                      WHEN UPDATING THEN :NEW.email
                                      WHEN DELETING THEN :OLD.email
                                      END,
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
    v_errorMessage    VARCHAR2(4000);
    v_response        VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'Username is mandatory and cannot be empty.');
        END IF;
        IF :NEW.email IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Email is mandatory and cannot be empty.');
        END IF;
        :NEW.mfaCode := dbms_random.string('X', 6);
        :NEW.expiresAt := SYSTIMESTAMP + INTERVAL '10' MINUTE;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN SELECT :OLD.username INTO :NEW.username FROM DUAL; END IF;
        IF :NEW.email IS NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        :NEW.mfaCode := dbms_random.string('X', 6);
        :NEW.expiresAt := SYSTIMESTAMP + INTERVAL '10' MINUTE;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'mfa_trg (UPSERT): ' || :NEW.email,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER mfa_audit_trg
    AFTER UPDATE OR DELETE
    ON mfa_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage    VARCHAR2(4000);
    v_response        VARCHAR2(100);
    v_modifiedReason  VARCHAR2(10);
BEGIN
    -- Determine whether the action is an update or delete
    IF UPDATING THEN
        v_modifiedReason := 'Updated';
        -- Log the update or delete in the history table
        INSERT INTO mfa_history_tbl(mfaId,username,email,mfaCode,issuedAt,expiresAt,status,inetAddr,deviceInfo,modifiedBy,modifiedDate,modifiedReason)
        VALUES (:OLD.mfaId,:OLD.username,:OLD.email,:OLD.mfaCode,:OLD.issuedAt,:OLD.expiresAt,:OLD.status,:OLD.inetAddr,:OLD.deviceInfo,:OLD.modifiedBy,:OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO mfa_history_tbl(mfaId,username,email,mfaCode,issuedAt,expiresAt,status,inetAddr,deviceInfo,modifiedBy,modifiedDate,modifiedReason)
        VALUES (:OLD.mfaId,:OLD.username,:OLD.email,:OLD.mfaCode,:OLD.issuedAt,:OLD.expiresAt,:OLD.status,:OLD.inetAddr,:OLD.deviceInfo,:OLD.modifiedBy,:OLD.modifiedDate, v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'mfa_audit_trg: ' ||
                                  CASE
                                      WHEN UPDATING THEN :NEW.email
                                      WHEN DELETING THEN :OLD.email
                                      END,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER session_trg
    BEFORE INSERT OR UPDATE
    ON session_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage    VARCHAR2(4000);
    v_response        VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'Username is mandatory and cannot be empty.');
        END IF;
        IF :NEW.email IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Email is mandatory and cannot be empty.');
        END IF;
        IF :NEW.sessionToken IS NULL THEN
            :NEW.sessionToken := dbms_random.string('X', 30);
        END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN SELECT :OLD.username INTO :NEW.username FROM DUAL; END IF;
        IF :NEW.email IS NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        IF :NEW.sessionToken IS NULL THEN
            :NEW.sessionToken := dbms_random.string('X', 30);
        END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'session_trg (UPSERT): ' || :NEW.email,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER session_audit_trg
    AFTER UPDATE OR DELETE
    ON session_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage    VARCHAR2(4000);
    v_response        VARCHAR2(100);
    v_modifiedReason  VARCHAR2(10);
BEGIN
    -- Determine whether the action is an update or delete
    IF UPDATING THEN
        v_modifiedReason := 'Updated';
        -- Log the update or delete in the history table
        INSERT INTO session_history_tbl(sessionId,username,email,sessionToken,issuedAt,expiresAt,activeFlag,inetAddr,deviceInfo,modifiedBy,modifiedDate,modifiedReason)
        VALUES (:OLD.sessionId, :OLD.username,:OLD.email, :OLD.sessionToken, :OLD.issuedAt,:OLD.expiresAt,:OLD.activeFlag,:OLD.inetAddr,:OLD.deviceInfo,:OLD.modifiedBy,:OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO session_history_tbl(sessionId,username,email,sessionToken,issuedAt,expiresAt,activeFlag,inetAddr,deviceInfo,modifiedBy,modifiedDate,modifiedReason)
        VALUES (:OLD.sessionId, :OLD.username,:OLD.email, :OLD.sessionToken, :OLD.issuedAt,:OLD.expiresAt,:OLD.activeFlag,:OLD.inetAddr,:OLD.deviceInfo,:OLD.modifiedBy,:OLD.modifiedDate, v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'session_audit_trg: ' ||
                                  CASE
                                      WHEN UPDATING THEN :NEW.email
                                      WHEN DELETING THEN :OLD.email
                                      END,
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
    v_errorMessage    VARCHAR2(4000);
    v_response        VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'Username is mandatory and cannot be empty.');
        END IF;
        IF :NEW.email IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Email is mandatory and cannot be empty.');
        END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN SELECT :OLD.username INTO :NEW.username FROM DUAL; END IF;
        IF :NEW.email IS NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'scrutiny_trg (UPSERT): ' || :NEW.email,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER jwt_trg
    BEFORE INSERT OR UPDATE
    ON jwt_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage    VARCHAR2(4000);
    v_response        VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'Username is mandatory and cannot be empty.');
        END IF;
        IF :NEW.email IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Email is mandatory and cannot be empty.');
        END IF;
        IF :NEW.jwtToken IS NULL THEN :NEW.jwtToken := dbms_random.string('X', 50);END IF;
        IF :NEW.issued IS NULL THEN SELECT SYSTIMESTAMP INTO :NEW.issued FROM DUAL; END IF;
        IF :NEW.status IS NULL THEN SELECT 'A' INTO :NEW.status FROM DUAL; END IF;
        IF :NEW.accountStatus IS NULL THEN SELECT 'Active' INTO :NEW.accountStatus FROM DUAL; END IF;
        IF :NEW.expires IS NULL THEN SELECT SYSTIMESTAMP + INTERVAL '30' MINUTE INTO :NEW.expires FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN SELECT :OLD.username INTO :NEW.username FROM DUAL; END IF;
        IF :NEW.email IS NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        IF :NEW.password IS NULL THEN SELECT :OLD.password INTO :NEW.password FROM DUAL; END IF;
        IF :NEW.jwtToken IS NULL THEN :NEW.jwtToken := dbms_random.string('X', 50);END IF;
        IF :NEW.issued IS NULL THEN SELECT SYSTIMESTAMP INTO :NEW.issued FROM DUAL; END IF;
        IF :NEW.status IS NULL THEN SELECT 'A' INTO :NEW.status FROM DUAL; END IF;
        IF :NEW.accountStatus IS NULL THEN SELECT :OLD.accountStatus INTO :NEW.accountStatus FROM DUAL; END IF;
        IF :NEW.expires IS NULL THEN SELECT SYSTIMESTAMP + INTERVAL '30' MINUTE INTO :NEW.expires FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'jwt_trg (UPSERT): ' || :NEW.email,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER jwt_audit_trg
    AFTER UPDATE OR DELETE
    ON jwt_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage    VARCHAR2(4000);
    v_response        VARCHAR2(100);
    v_modifiedReason  VARCHAR2(10);
BEGIN
    -- Determine whether the action is an update or delete
    IF UPDATING THEN
        v_modifiedReason := 'Updated';
        -- Log the update or delete in the history table
        INSERT INTO jwt_history_tbl(username,email,password,jwtToken,issued,expires,status,modifiedBy,modifiedDate,modifiedReason)
        VALUES (:OLD.username, :OLD.email,:OLD.password, :OLD.jwtToken, :OLD.issued,:OLD.expires,:OLD.status,:OLD.modifiedBy,:OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO jwt_history_tbl(username,email,password,jwtToken,issued,expires,status,modifiedBy,modifiedDate,modifiedReason)
        VALUES (:OLD.username, :OLD.email,:OLD.password, :OLD.jwtToken, :OLD.issued,:OLD.expires,:OLD.status,:OLD.modifiedBy,:OLD.modifiedDate, v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'jwt_audit_trg: ' ||
                                  CASE
                                      WHEN UPDATING THEN :NEW.email
                                      WHEN DELETING THEN :OLD.email
                                      END,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER authentication_trg
    BEFORE INSERT OR UPDATE
    ON authentication_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage    VARCHAR2(4000);
    v_response        VARCHAR2(100);
BEGIN
    -- Determine whether the action is an update or delete
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'Username is mandatory and cannot be empty.');
        END IF;
        IF :NEW.email IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Email is mandatory and cannot be empty.');
        END IF;
        IF :NEW.password IS NULL THEN
            RAISE_APPLICATION_ERROR(-20004, 'Password is mandatory and cannot be empty.');
        END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN SELECT :OLD.username INTO :NEW.username FROM DUAL; END IF;
        IF :NEW.email IS NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        IF :NEW.password IS NULL THEN SELECT :OLD.password INTO :NEW.password FROM DUAL; END IF;
        IF :NEW.emailVerified IS NULL THEN SELECT :OLD.emailVerified INTO :NEW.emailVerified FROM DUAL; END IF;
        IF :NEW.failedLogin IS NULL THEN SELECT :OLD.failedLogin INTO :NEW.failedLogin FROM DUAL; END IF;
        IF :NEW.lastLogin IS NULL THEN SELECT :OLD.lastLogin INTO :NEW.lastLogin FROM DUAL; END IF;
        IF :NEW.accountStatus IS NULL THEN SELECT :OLD.accountStatus INTO :NEW.accountStatus FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'authentication_trg (UPSERT): ' || :NEW.email,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER authentication_audit_trg
    AFTER INSERT OR UPDATE OR DELETE
    ON authentication_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage    VARCHAR2(4000);
    v_response        VARCHAR2(100);
    v_modifiedReason  VARCHAR2(10);
BEGIN
    -- Determine whether the action is an update or delete
    IF INSERTING THEN
        INSERT INTO verification_tbl(username,email,modifiedBy) VALUES (:NEW.username,:NEW.email,'Authentication Trigger');
        INSERT INTO session_tbl(username,email,modifiedBy) VALUES (:NEW.username,:NEW.email,'Authentication Trigger');
        INSERT INTO mfa_tbl(username,email,modifiedBy) VALUES (:NEW.username,:NEW.email,'Authentication Trigger');
    ELSIF UPDATING THEN
        v_modifiedReason := 'Updated';
        -- Log the update or delete in the history table
        INSERT INTO authentication_history_tbl(username,email,password,emailVerified,failedLogin,lastLogin,accountStatus,modifiedBy,modifiedDate,modifiedReason)
        VALUES (:OLD.username, :OLD.email, :OLD.password, :OLD.emailVerified,:OLD.failedLogin,:OLD.lastLogin,:OLD.accountStatus,:OLD.modifiedBy,:OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO authentication_history_tbl(username,email,password,emailVerified,failedLogin,lastLogin,accountStatus,modifiedBy,modifiedDate,modifiedReason)
        VALUES (:OLD.username, :OLD.email, :OLD.password, :OLD.emailVerified,:OLD.failedLogin,:OLD.lastLogin,:OLD.accountStatus,:OLD.modifiedBy,:OLD.modifiedDate, v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'authentication_audit_trg: ' ||
                                  CASE
                                      WHEN UPDATING THEN :NEW.email
                                      WHEN DELETING THEN :OLD.email
                                      END,
                o_response => v_response
        );
        RAISE;
END;
/

PROMPT "Enabling Triggers"

-- Enable Triggers
ALTER TRIGGER authentication_trg ENABLE;
ALTER TRIGGER authentication_audit_trg ENABLE;
ALTER TRIGGER verification_trg ENABLE;
ALTER TRIGGER verification_audit_trg ENABLE;
ALTER TRIGGER mfa_trg ENABLE;
ALTER TRIGGER mfa_audit_trg ENABLE;
ALTER TRIGGER session_trg ENABLE;
ALTER TRIGGER session_audit_trg ENABLE;
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
    | 11-OCT-25	| eomisore 	| Add extra feature such as delete, update.|
    =================================================================================
    */

    -- Audit records
    PROCEDURE audit(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_actionType IN VARCHAR2,
        i_notes IN VARCHAR2,
        i_modifiedBy IN VARCHAR2);

    -- Check Token
    PROCEDURE checkToken(
        i_token IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Verify email
    PROCEDURE confirmEmail(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_verificationCode IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Verify multi factor
    PROCEDURE confirmMfa(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_mfaCode IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        o_token OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Forgot Password
    PROCEDURE forgotPassword(
        i_email IN VARCHAR2,
        o_verificationCode OUT VARCHAR2,
        o_username OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Get MFA token
    PROCEDURE getMfa(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        o_mfaCode OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Get session token
    PROCEDURE getSession(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        o_token OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Get Verification Code
    PROCEDURE getVerification(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        o_verificationCode OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Revoke Token
    PROCEDURE revokeToken(
        i_token IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Login
    PROCEDURE login(
        i_username IN VARCHAR2,
        i_password IN VARCHAR2,
        o_email IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Reset Password
    PROCEDURE resetPassword(
        i_email IN VARCHAR2,
        i_verificationCode IN VARCHAR2,
        i_password IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Signin
    PROCEDURE signin(
        i_email IN VARCHAR2,
        i_password IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        o_mfaCode OUT VARCHAR2,
        o_username OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Logout
    PROCEDURE signout(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_sessionToken IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Sign up
    PROCEDURE signup(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_password IN VARCHAR2,
        o_verificationCode OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Store Token
    PROCEDURE storeToken(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_token IN VARCHAR2,
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
    | 11-OCT-25	| eomisore 	| Add extra feature such as delete, update.|
    =================================================================================
    */
    -- Audit records
    PROCEDURE audit(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_actionType IN VARCHAR2,
        i_notes IN VARCHAR2,
        i_modifiedBy IN VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        -- insert audit records
        INSERT INTO scrutiny_tbl(username, email, actionType, notes, modifiedBy)
        VALUES (i_username, i_email, i_actionType, i_notes, i_modifiedBy);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (LOG AUDIT): ' || i_email,
                    o_response => v_response
            );
    END audit;

    -- Check Token
    PROCEDURE checkToken(
        i_token IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_count         NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM jwt_tbl WHERE jwtToken = i_token AND status = 'R';
        IF v_count = 1 THEN
            o_response := 'true';
        ELSE
            o_response := 'false';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (CHECK TOKEN): ',
                    o_response => v_response
            );
    END checkToken;

    -- Verify email
    PROCEDURE confirmEmail(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_verificationCode IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_count         NUMBER;
    BEGIN
        -- Fetch authentication details and status
        SELECT COUNT(*)
        INTO v_count
        FROM verification_tbl
        WHERE email = i_email
          AND username = i_username
          AND verificationCode = i_verificationCode
          AND usedFlag = 'N'
          AND expiresAt >= SYSTIMESTAMP;
        IF v_count = 1 THEN
            UPDATE authentication_tbl
            SET emailVerified = 'Y',
                accountStatus = 'Active',
                modifiedBy     = i_username
            WHERE email = i_email;
            -- insert records for audit purpose
            audit(i_username, i_email, 'EMAIL VERIFIED', 'User verified email successfully', i_username);
            o_response := 'success';
        ELSE
            o_response := 'invalid or expired verification code';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (CONFIRM EMAIL): ' || i_email,
                    o_response => v_response
            );
            o_response := 'invalid or expired verification code';
    END confirmEmail;

    -- Verify multi factor
    PROCEDURE confirmMfa(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_mfaCode IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        o_token OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_count         NUMBER;
    BEGIN
        -- Fetch authentication details and status
        SELECT COUNT(*)
        INTO v_count
        FROM mfa_tbl
        WHERE email = i_email
          AND mfaCode = i_mfaCode;
        IF v_count = 1 THEN
            UPDATE mfa_tbl
            SET status = 'Y',
                modifiedBy = i_username
            WHERE email = i_email;
            -- get session token identification
            getSession(i_username,i_email,i_inet,i_device,o_token,o_response);
            -- set last_login timestamp in authentication_tbl
            UPDATE authentication_tbl
            SET lastLogin = SYSTIMESTAMP, modifiedBy = i_username
            WHERE email = i_email;
            -- insert records for audit purpose
            audit(i_username,i_email, 'CONFIRM MFA', 'User successfully confirmed MFA', i_username);
            o_response := 'success';
        ELSE
            o_response := 'invalid or expired MFA token';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (CONFIRM MFA): ' || i_email,
                    o_response => v_response
            );
            o_response := 'invalid or expired MFA token';
    END confirmMfa;

    -- Forgot Password
    PROCEDURE forgotPassword(
        i_email IN VARCHAR2,
        o_verificationCode OUT VARCHAR2,
        o_username OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_count         NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM authentication_tbl WHERE email = i_email;
        IF v_count = 1 THEN
            UPDATE authentication_tbl
            SET accountStatus = 'Locked'
            WHERE email = i_email
            RETURNING username INTO o_username;
            -- Generate and return authentication token
            getVerification(o_username, i_email, o_verificationCode, o_response);
            -- insert records for audit purpose
            audit(o_username, i_email, 'FORGOT PASSWORD', 'Verification code issued for forget password', o_username);
            o_response := 'success';
        ELSE
            o_response := 'invalid email';
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (LOGIN): ' || i_email,
                    o_response => v_response
            );
            o_response := 'invalid credentials';
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (FORGET PASSWORD): ' || i_email,
                    o_response => v_response
            );
            o_response := 'invalid credentials';
    END forgotPassword;

    -- Get MFA token
    PROCEDURE getMfa(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        o_mfaCode OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        -- insert mfa records
        UPDATE mfa_tbl SET username = i_username, inetAddr = i_inet, deviceInfo = i_device, modifiedBy = i_username
        WHERE email = i_email
        RETURNING mfaCode INTO o_mfaCode;
        IF SQL%NOTFOUND THEN
            INSERT INTO mfa_tbl(username, email, inetAddr, deviceInfo, modifiedBy)
            VALUES (i_username, i_email, i_inet, i_device, i_username)
            RETURNING mfaCode INTO o_mfaCode;
        END IF;
        -- insert records for audit purpose
        audit(i_username, i_email, 'MFA REQUEST', 'Multi factor token was successfully requested', i_username);
        o_response := 'success';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (GET MFA): ' || i_email,
                    o_response => v_response
            );
            o_response := 'MFA unsuccessful';
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (GET MFA): ' || i_email,
                    o_response => v_response
            );
            o_response := 'MFA unsuccessful';
    END getMfa;

    -- Get session token
    PROCEDURE getSession(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        o_token OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        -- insert mfa records
        UPDATE session_tbl SET username = i_username, inetAddr = i_inet, deviceInfo = i_device, modifiedBy = i_username
        WHERE email = i_email
        RETURNING sessionToken INTO o_token;
        IF SQL%NOTFOUND THEN
            INSERT INTO session_tbl(username, email, inetAddr, deviceInfo, modifiedBy)
            VALUES (i_username,i_email, i_inet, i_device, i_username)
            RETURNING sessionToken INTO o_token;
        END IF;
        -- insert records for audit purpose
        audit(i_username, i_email, 'SESSION REQUEST', 'Session token was successfully requested', i_username);
        o_response := 'success';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (GET SESSION): ' || i_email,
                    o_response => v_response
            );
            o_response := 'session unsuccessful';
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (GET SESSION): ' || i_email,
                    o_response => v_response
            );
            o_response := 'session unsuccessful';
    END getSession;

    -- Get Verification Code
    PROCEDURE getVerification(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        o_verificationCode OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        -- insert verification records
        UPDATE verification_tbl SET username = i_username, modifiedBy = i_username
        WHERE email = i_email
        RETURNING verificationCode INTO o_verificationCode;
        IF SQL%NOTFOUND THEN
            INSERT INTO verification_tbl(username, email, modifiedBy)
            VALUES (i_username,i_email, i_username)
            RETURNING verificationCode INTO o_verificationCode;
        END IF;
        -- insert records for audit purpose
        audit(i_username, i_email, 'VERIFICATION_REQUESTED', 'Verification code was successfully requested', i_username);
        o_response := 'success';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (GET VERIFICATION CODE): ' || i_email,
                    o_response => v_response
            );
            o_response := 'verification unsuccessful';
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (GET VERIFICATION CODE): ' || i_email,
                    o_response => v_response
            );
            o_response := 'verification unsuccessful';
    END getVerification;

    -- Login
    PROCEDURE login(
        i_username IN VARCHAR2,
        i_password IN VARCHAR2,
        o_email IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_password      VARCHAR2(400);
        v_email         VARCHAR2(400);
        v_status        VARCHAR2(50);
    BEGIN
        -- Fetch authentication details and status
        SELECT email, password, accountStatus INTO v_email, v_password, v_status FROM jwt_tbl WHERE username = i_username;
        -- Check if an account is active and password matches
        IF v_status != 'Active' THEN
            o_response := 'account locked';
        ELSIF enc_dec.decrypt(utl_raw.cast_to_varchar2(utl_encode.base64_decode(v_password))) != i_password THEN
            o_response := 'invalid credentials';
        ELSE
            v_email := o_email;
            o_response := 'success';
        END IF;
    END login;

    -- Reset Password
    PROCEDURE resetPassword(
        i_email IN VARCHAR2,
        i_verificationCode IN VARCHAR2,
        i_password IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_username      VARCHAR2(100);
        v_count         NUMBER;
    BEGIN
        -- Fetch authentication details and status
        SELECT username, COUNT(*) INTO v_username, v_count FROM authentication_tbl WHERE email = i_email GROUP BY username;
        IF v_count = 1 THEN
            UPDATE verification_tbl SET usedFlag = 'Y', modifiedBy = v_username
            WHERE email = i_email AND verificationCode = i_verificationCode;
            UPDATE authentication_tbl
            SET password = utl_encode.base64_encode(utl_raw.cast_to_raw(enc_dec.encrypt(i_password))),
                modifiedBy = v_username, accountStatus = 'Active'
            WHERE email = i_email;
            -- insert records for audit purpose
            audit(v_username, i_email, 'PASSWORD RESET', 'Password reset via verification code', v_username);
            o_response := 'success';
        ELSE
            o_response := 'invalid credentials';
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (RESET PASSWORD): ' || i_email,
                    o_response => v_response
            );
            o_response := 'invalid credentials';
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (RESET PASSWORD): ' || i_email,
                    o_response => v_response
            );
            o_response := 'invalid credentials';
    END resetPassword;

    -- Revoke Token
    PROCEDURE revokeToken(
        i_token IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_username      VARCHAR2(100);
        v_email         VARCHAR2(100);
    BEGIN
        SELECT username, email INTO v_username, v_email FROM jwt_tbl WHERE jwtToken = i_token;
        IF v_username IS NOT NULL THEN
            UPDATE jwt_tbl SET status = 'R', modifiedBy = v_username
            WHERE jwtToken = i_token;
        ELSE
            UPDATE jwt_tbl SET status = 'R', modifiedBy = v_username
            WHERE email = v_email;
        END IF;
        -- insert records for audit purpose
        audit(v_username, v_email, 'REVOKE TOKEN', 'JWT Token revoked', v_username);
        o_response := 'success';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (REVOKE TOKEN): ' || v_email,
                    o_response => v_response
            );
            o_response := 'invalid token';
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (REVOKE TOKEN): ' || v_email,
                    o_response => v_response
            );
            o_response := 'invalid token';
    END revokeToken;

    -- Login
    PROCEDURE signin(
        i_email IN VARCHAR2,
        i_password IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        o_mfaCode OUT VARCHAR2,
        o_username OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_verify        VARCHAR2(20);
        v_password      VARCHAR2(400);
        v_status        VARCHAR2(50);
    BEGIN
        -- Fetch authentication details and status
        SELECT username, password, emailVerified, accountStatus
        INTO o_username, v_password, v_verify, v_status
        FROM authentication_tbl
        WHERE email = i_email;
        -- Check if an account is active and password matches
        IF v_status != 'Active' THEN
            -- insert records for audit purpose
            audit(o_username, i_email, 'FAILED LOGIN', 'Account locked', o_username);
            o_response := 'account locked';
        ELSIF enc_dec.decrypt(utl_raw.cast_to_varchar2(utl_encode.base64_decode(v_password))) != i_password THEN
            UPDATE authentication_tbl SET failedLogin = NVL(failedLogin,0) + 1, modifiedBy = o_username
            WHERE email = i_email;
            -- insert records for audit purpose
            audit(o_username, i_email, 'FAILED LOGIN', 'Failed password', o_username);
            o_response := 'invalid credentials';
        ELSE
            -- password matched. Reset failed_login.
            UPDATE authentication_tbl SET failedLogin = 0, modifiedBy = o_username WHERE email = i_email;
            getMfa(o_username, i_email,i_inet,i_device,o_mfaCode,o_response);
            -- insert records for audit purpose
            audit(o_username, i_email, 'MFA ISSUED', 'MFA code issued (login step)', o_username);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (LOGIN): ' || i_email,
                    o_response => v_response
            );
            o_response := 'invalid credentials';
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (RESET PASSWORD): ' || i_email,
                    o_response => v_response
            );
            o_response := 'invalid credentials';
    END signin;

    -- Logout
    PROCEDURE signout(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_sessionToken IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        -- Reset active flag of token.
        UPDATE session_tbl SET activeFlag = 'N', modifiedBy = i_username
        WHERE email = i_email AND sessionToken = i_sessionToken AND activeFlag = 'Y';
        -- insert records for audit purpose
        audit(i_username, i_email, 'LOGOUT', 'User logout successfully', i_username);
        o_response := 'success';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (LOGOUT): ' || i_email,
                    o_response => v_response
            );
            o_response := 'invalid credentials';
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (LOGOUT): ' || i_email,
                    o_response => v_response
            );
            o_response := 'invalid credentials';
    END signout;

    -- Sign up
    PROCEDURE signup(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_password IN VARCHAR2,
        o_verificationCode OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        -- insert authentication details and verification details
        INSERT INTO authentication_tbl(username, email, password, modifiedBy)
        VALUES (i_username,i_email, utl_encode.base64_encode(utl_raw.cast_to_raw(enc_dec.encrypt(i_password))), i_username);
        -- Generate and return authentication token
        getVerification(i_username, i_email,  o_verificationCode, v_response);
        -- insert records for audit purpose
        audit(i_username, i_email, 'EMAIL VERIFICATION ISSUED', 'Verification code issued', i_username);
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (SIGNUP): ' || i_email,
                    o_response => v_response
            );
            o_response := 'signup error';
    END signup;

    -- Store Token
    PROCEDURE storeToken(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_token IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE jwt_tbl SET username = i_username, jwtToken = i_token, status = 'A', modifiedBy = i_username WHERE email = i_email;
        IF SQL%NOTFOUND THEN
            INSERT INTO jwt_tbl(username, email, jwtToken, status, modifiedBy) VALUES (i_username,i_email,i_token,'A',i_username);
        END IF;
        -- insert records for audit purpose
        audit(i_username, i_email, 'STORE TOKEN', 'JWT Token stored', i_username);
        o_response := 'success';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (STORE TOKEN): ' || i_email,
                    o_response => v_response
            );
            o_response := 'invalid credentials';
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (STORE TOKEN): ' || i_email,
                    o_response => v_response
            );
            o_response := 'invalid credentials';
    END storeToken;

END auth_pkg;
/

SHOW ERRORS
/

PROMPT "End of creating Authentication Schema"