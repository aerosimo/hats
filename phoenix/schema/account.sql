PROMPT "Creating Account Schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      account.sql                                                     *
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

-- Create main credentials tables
CREATE TABLE credentials_tbl
(
    username            VARCHAR2(200 BYTE) NOT NULL,
    email               VARCHAR2(200 BYTE) NOT NULL,
    password            VARCHAR2(400 BYTE) NOT NULL,
    emailVerified       CHAR(1) DEFAULT 'N',
    failedLogin         NUMBER DEFAULT 0,
    lastLogin           TIMESTAMP,
    accountStatus       VARCHAR2(20) DEFAULT 'Inactive',
    modifiedBy          VARCHAR2(100 BYTE),
    modifiedDate        TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- User token table
CREATE TABLE credence_tbl
(
   username             VARCHAR2(200) NOT NULL,
   authKey              VARCHAR2(4000),
   issuedAt             TIMESTAMP DEFAULT SYSTIMESTAMP,
   expiresAt            TIMESTAMP,
   activeFlag           CHAR(1) DEFAULT 'Y'
);

-- Create email verification codes (for new signup or after password reset)
CREATE TABLE verification_tbl
(
    username            VARCHAR2(200 BYTE) NOT NULL,
    verificationToken   VARCHAR2(100 BYTE),
    issuedAt            TIMESTAMP DEFAULT SYSTIMESTAMP,
    expiresAt           TIMESTAMP,
    usedFlag            CHAR(1) DEFAULT 'N',
    modifiedBy          VARCHAR2(100 BYTE),
    modifiedDate        TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- User avatar or image table
CREATE TABLE images_tbl
(
    username            VARCHAR2(200 BYTE) NOT NULL,
    avatar              VARCHAR2(100 BYTE),
    modifiedBy          VARCHAR2(100 BYTE),
    modifiedDate        TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- User personal record
CREATE TABLE person_tbl
(
    username            VARCHAR2(200 BYTE) NOT NULL,
    title               VARCHAR2(50 BYTE),
    firstName           VARCHAR2(100 BYTE),
    middleName          VARCHAR2(100 BYTE),
    lastName            VARCHAR2(100 BYTE),
    zodiacSign          VARCHAR2(20 BYTE),
    gender              VARCHAR2(30 BYTE),
    birthday            DATE,
    age                 VARCHAR2(10 BYTE),
    modifiedBy          VARCHAR2(100 BYTE),
    modifiedDate        TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- User address table
CREATE TABLE address_tbl
(
    username            VARCHAR2(200 BYTE) NOT NULL,
    firstline           VARCHAR2(100 BYTE),
    secondline          VARCHAR2(100 BYTE),
    thirdline           VARCHAR2(100 BYTE),
    city                VARCHAR2(100 BYTE),
    postcode            VARCHAR2(20 BYTE),
    country             VARCHAR2(100 BYTE),
    modifiedBy          VARCHAR2(100 BYTE),
    modifiedDate        TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- User contacts table
CREATE TABLE contact_tbl
(
    username            VARCHAR2(200 BYTE) NOT NULL,
    channel             VARCHAR2(40 BYTE),
    address             VARCHAR2(100 BYTE),
    consent             VARCHAR2(10 BYTE) DEFAULT 'YES',
    modifiedBy          VARCHAR2(100 BYTE),
    modifiedDate        TIMESTAMP DEFAULT SYSTIMESTAMP
);

PROMPT "Setting Constraints"
------------------------------------------------------------
-- CONSTRAINTS / CHECKS creating the constraints and checks
------------------------------------------------------------
-- Create index to quickly find active sessions for an email
CREATE INDEX credentials_idx ON credentials_tbl (email, username);
CREATE INDEX credence_idx ON credence_tbl (username);
CREATE INDEX verification_idx ON verification_tbl (username);

-- Setting Primary Key
ALTER TABLE credentials_tbl
    ADD CONSTRAINT credentials_pk PRIMARY KEY (email);
ALTER TABLE credence_tbl
    ADD CONSTRAINT credence_pk PRIMARY KEY (authKey);

-- Setting Unique Key
ALTER TABLE credentials_tbl
    ADD CONSTRAINT credentials_username_uk UNIQUE (username);
ALTER TABLE verification_tbl
    ADD CONSTRAINT verificationtoken_unq UNIQUE (verificationToken);

-- Setting Foreign Key
ALTER TABLE credence_tbl
    ADD CONSTRAINT credence_fk FOREIGN KEY (username)
        REFERENCES credentials_tbl (username) ON DELETE CASCADE;
ALTER TABLE verification_tbl
    ADD CONSTRAINT verification_fk FOREIGN KEY (username) REFERENCES credentials_tbl (username) ON DELETE CASCADE;
ALTER TABLE images_tbl
    ADD CONSTRAINT images_fk FOREIGN KEY (username) REFERENCES credentials_tbl (username) ON DELETE CASCADE;
ALTER TABLE person_tbl
    ADD CONSTRAINT person_fk FOREIGN KEY (username) REFERENCES credentials_tbl (username) ON DELETE CASCADE;
ALTER TABLE address_tbl
    ADD CONSTRAINT address_fk FOREIGN KEY (username) REFERENCES credentials_tbl (username) ON DELETE CASCADE;
ALTER TABLE contact_tbl
    ADD CONSTRAINT contact_fk FOREIGN KEY (username) REFERENCES credentials_tbl (username) ON DELETE CASCADE;

-- Setting Check Constraint
ALTER TABLE credentials_tbl
    ADD CONSTRAINT credentials_emailverified_chk CHECK (emailVerified IN ('Y', 'N')) ENABLE;
ALTER TABLE credentials_tbl
    ADD CONSTRAINT email_verified_chk CHECK (emailVerified IN ('Y', 'N')) ENABLE;
ALTER TABLE credentials_tbl
    ADD CONSTRAINT account_status_chk CHECK (accountStatus IN ('Active', 'Inactive', 'Locked')) ENABLE;
ALTER TABLE verification_tbl
    ADD CONSTRAINT verification_used_chk CHECK (usedFlag IN ('Y', 'N')) ENABLE;
ALTER TABLE person_tbl
    ADD CONSTRAINT pertit_chk CHECK (title IN ('Mr', 'Mrs', 'Miss', 'Dr', 'Ms')) ENABLE;
ALTER TABLE person_tbl
    ADD CONSTRAINT pergen_chk CHECK (gender IN ('Male', 'Female')) ENABLE;
ALTER TABLE contact_tbl
    ADD CONSTRAINT channel_chk CHECK (channel IN
                                      ('Phone', 'Email', 'X', 'Facebook', 'LinkedIn', 'Snapchat', 'Website')) ENABLE;

---------------------------------------------------------------------
-- HISTORY for archived purpose
---------------------------------------------------------------------
-- Create history tables
CREATE TABLE credentials_history_tbl AS
SELECT *
FROM credentials_tbl
WHERE 1 = 0;
CREATE TABLE credence_history_tbl AS
SELECT *
FROM credence_tbl
WHERE 1 = 0;
CREATE TABLE verification_history_tbl AS
SELECT *
FROM verification_tbl
WHERE 1 = 0;
CREATE TABLE person_history_tbl AS
SELECT *
FROM person_tbl
WHERE 1 = 0;
CREATE TABLE address_history_tbl AS
SELECT *
FROM address_tbl
WHERE 1 = 0;
CREATE TABLE images_history_tbl AS
SELECT *
FROM images_tbl
WHERE 1 = 0;
CREATE TABLE contact_history_tbl AS
SELECT *
FROM contact_tbl
WHERE 1 = 0;

ALTER TABLE credentials_history_tbl
    ADD modifiedReason VARCHAR2(200);
ALTER TABLE credentials_history_tbl
    ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE credence_history_tbl
    ADD modifiedReason VARCHAR2(200);
ALTER TABLE credence_history_tbl
    ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE verification_history_tbl
    ADD modifiedReason VARCHAR2(200);
ALTER TABLE verification_history_tbl
    ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE person_history_tbl
    ADD modifiedReason VARCHAR2(200);
ALTER TABLE person_history_tbl
    ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE address_history_tbl
    ADD modifiedReason VARCHAR2(200);
ALTER TABLE address_history_tbl
    ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE images_history_tbl
    ADD modifiedReason VARCHAR2(200);
ALTER TABLE images_history_tbl
    ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE contact_history_tbl
    ADD modifiedReason VARCHAR2(200);
ALTER TABLE contact_history_tbl
    ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;

PROMPT "Commenting Tables"
---------------------------------------------------------------------
-- COMMENTS for clarity (shorter and clearer)
---------------------------------------------------------------------
COMMENT ON COLUMN credentials_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN credentials_tbl.email IS 'This is the account record primary identifier and also electronic mail is a method of exchanging messages between people using electronic devices.';
COMMENT ON COLUMN credentials_tbl.password IS 'This is contact set encrypted password';
COMMENT ON COLUMN credentials_tbl.emailVerified IS 'Y = email verified, N = not verified';
COMMENT ON COLUMN credentials_tbl.failedLogin IS 'Consecutive failed password attempts';
COMMENT ON COLUMN credentials_tbl.lastLogin IS 'Timestamp of most recent successful login (after MFA).';
COMMENT ON COLUMN credentials_tbl.accountStatus IS 'Active / Inactive / Locked - account lifecycle state.';
COMMENT ON COLUMN credentials_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN credentials_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE credentials_tbl IS 'A user account is a location on a network server used to store a computer username, password, and other information. A user account allows or does not allow a user to connect to a network, another computer, or other shares.';

COMMENT ON COLUMN credentials_history_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN credentials_history_tbl.email IS 'This is the account record primary identifier and also electronic mail is a method of exchanging messages between people using electronic devices.';
COMMENT ON COLUMN credentials_history_tbl.password IS 'This is contact set encrypted password';
COMMENT ON COLUMN credentials_history_tbl.emailVerified IS 'Y = email verified, N = not verified';
COMMENT ON COLUMN credentials_history_tbl.failedLogin IS 'Consecutive failed password attempts';
COMMENT ON COLUMN credentials_history_tbl.lastLogin IS 'Timestamp of most recent successful login (after MFA).';
COMMENT ON COLUMN credentials_history_tbl.accountStatus IS 'Active / Inactive / Locked - account lifecycle state.';
COMMENT ON COLUMN credentials_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN credentials_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN credentials_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN credentials_history_tbl.archivedDate IS 'Audit column - date of it was archived.';
COMMENT ON TABLE credentials_history_tbl IS 'A user account is a location on a network server used to store a computer username, password, and other information. A user account allows or does not allow a user to connect to a network, another computer, or other shares.';

COMMENT ON TABLE credence_tbl IS 'Audit log for authentication events (login/logout/password change/etc).';
COMMENT ON COLUMN credence_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN credence_tbl.authKey IS 'This is the primary identifier, user authentication token';
COMMENT ON COLUMN credence_tbl.issuedAt IS 'This store the time the authentication code was issued';
COMMENT ON COLUMN credence_tbl.expiresAt IS 'This store the time the authentication code expires';
COMMENT ON COLUMN credence_tbl.activeFlag IS 'This indicates if the verification code was used or not';

COMMENT ON TABLE credence_history_tbl IS 'Audit log for authentication events (login/logout/password change/etc).';
COMMENT ON COLUMN credence_history_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN credence_history_tbl.authKey IS 'This is the primary identifier, user authentication token';
COMMENT ON COLUMN credence_history_tbl.issuedAt IS 'This store the time the authentication code was issued';
COMMENT ON COLUMN credence_history_tbl.expiresAt IS 'This store the time the authentication code expires';
COMMENT ON COLUMN credence_history_tbl.activeFlag IS 'This indicates if the verification code was used or not';
COMMENT ON COLUMN credence_history_tbl.archivedDate IS 'Audit column - date of it was archived.';
COMMENT ON COLUMN credence_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';

COMMENT ON TABLE verification_tbl IS 'Stores email verification codes for signup or password reset. Expire after configured interval.';
COMMENT ON COLUMN verification_tbl.username IS 'This is the primary identifier';
COMMENT ON COLUMN verification_tbl.verificationToken IS 'This the generated verification code';
COMMENT ON COLUMN verification_tbl.issuedAt IS 'This store the time the verification code was issued';
COMMENT ON COLUMN verification_tbl.expiresAt IS 'This store the time the verification code expires';
COMMENT ON COLUMN verification_tbl.usedFlag IS 'This indicates if the verification code was used or not';
COMMENT ON COLUMN verification_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN verification_tbl.modifiedDate IS 'Audit column - date of last update.';

COMMENT ON TABLE verification_history_tbl IS 'Stores email verification codes for signup or password reset. Expire after configured interval.';
COMMENT ON COLUMN verification_history_tbl.username IS 'This is the primary identifier';
COMMENT ON COLUMN verification_history_tbl.verificationToken IS 'This the generated verification code';
COMMENT ON COLUMN verification_history_tbl.issuedAt IS 'This store the time the verification code was issued';
COMMENT ON COLUMN verification_history_tbl.expiresAt IS 'This store the time the verification code expires';
COMMENT ON COLUMN verification_history_tbl.usedFlag IS 'This indicates if the verification code was used or not';
COMMENT ON COLUMN verification_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN verification_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN verification_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN verification_history_tbl.archivedDate IS 'Audit column - date of it was archived.';

COMMENT ON COLUMN images_tbl.username IS 'The account identifier for an image';
COMMENT ON COLUMN images_tbl.avatar IS 'This is user avatar image';
COMMENT ON COLUMN images_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN images_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE images_tbl IS 'A user image which is a visual representation of the user is stored here.';

COMMENT ON COLUMN images_history_tbl.username IS 'The account identifier for an image';
COMMENT ON COLUMN images_history_tbl.avatar IS 'This is user avatar image';
COMMENT ON COLUMN images_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN images_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN images_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN images_history_tbl.archivedDate IS 'Audit column - date of it was archived.';
COMMENT ON TABLE images_history_tbl IS 'A user image which is a visual representation of the user is stored here.';

COMMENT ON COLUMN person_tbl.title IS 'This is the title of a given contact (Mr., Ms., Dr., Rev., etc.)';
COMMENT ON COLUMN person_tbl.firstName IS 'This is contact''s first name.';
COMMENT ON COLUMN person_tbl.middleName IS 'This is contact''s middle name.';
COMMENT ON COLUMN person_tbl.lastName IS 'This is contact''s last name.';
COMMENT ON COLUMN person_tbl.gender IS 'This is contact''s Gender.';
COMMENT ON COLUMN person_tbl.birthday IS 'This is contact''s date of birth.';
COMMENT ON COLUMN person_tbl.age IS 'This is contact''s Age.';
COMMENT ON COLUMN person_tbl.zodiacSign IS 'The zodiacSign is an area of the sky that extends approximately 8° north or south of the ecliptic, the apparent path of the Sun across the celestial sphere over the course of the year.';
COMMENT ON COLUMN person_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN person_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE person_tbl IS 'Profile information for a person.';

COMMENT ON COLUMN person_history_tbl.title IS 'This is the title of a given contact (Mr., Ms., Dr., Rev., etc.)';
COMMENT ON COLUMN person_history_tbl.firstName IS 'This is contact''s first name.';
COMMENT ON COLUMN person_history_tbl.middleName IS 'This is contact''s middle name.';
COMMENT ON COLUMN person_history_tbl.lastName IS 'This is contact''s last name.';
COMMENT ON COLUMN person_history_tbl.gender IS 'This is contact''s Gender.';
COMMENT ON COLUMN person_history_tbl.birthday IS 'This is contact''s date of birth.';
COMMENT ON COLUMN person_history_tbl.age IS 'This is contact''s Age.';
COMMENT ON COLUMN person_history_tbl.zodiacSign IS 'The zodiacSign is an area of the sky that extends approximately 8° north or south of the ecliptic, the apparent path of the Sun across the celestial sphere over the course of the year.';
COMMENT ON COLUMN person_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN person_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN person_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN person_history_tbl.archivedDate IS 'Audit column - date of it was archived.';
COMMENT ON TABLE person_history_tbl IS 'Profile information for a person.';

COMMENT ON COLUMN address_tbl.username IS 'The account identifier for a Contact';
COMMENT ON COLUMN address_tbl.firstline IS 'This is the first line of the Address';
COMMENT ON COLUMN address_tbl.secondline IS 'This is the second line of the Address';
COMMENT ON COLUMN address_tbl.thirdline IS 'This is the third line of the Address.';
COMMENT ON COLUMN address_tbl.city IS 'The city in which the Address is located.';
COMMENT ON COLUMN address_tbl.postcode IS 'The postal code/zipcode of the Address.';
COMMENT ON COLUMN address_tbl.country IS 'The country of the Address.';
COMMENT ON COLUMN address_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN address_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE address_tbl IS 'Physical Address Information.';

COMMENT ON COLUMN address_history_tbl.username IS 'The account identifier for a Contact';
COMMENT ON COLUMN address_history_tbl.firstline IS 'This is the first line of the Address';
COMMENT ON COLUMN address_history_tbl.secondline IS 'This is the second line of the Address';
COMMENT ON COLUMN address_history_tbl.thirdline IS 'This is the third line of the Address.';
COMMENT ON COLUMN address_history_tbl.city IS 'The city in which the Address is located.';
COMMENT ON COLUMN address_history_tbl.postcode IS 'The postal code/zipcode of the Address.';
COMMENT ON COLUMN address_history_tbl.country IS 'The country of the Address.';
COMMENT ON COLUMN address_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN address_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN address_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN address_history_tbl.archivedDate IS 'Audit column - date of it was archived.';
COMMENT ON TABLE address_tbl IS 'Physical Address Information.';

COMMENT ON COLUMN contact_tbl.username IS 'The account identifier for a Contact.';
COMMENT ON COLUMN contact_tbl.channel IS 'This will list of available ways of contact. e.g Phone, email, twitter, facebook etc';
COMMENT ON COLUMN contact_tbl.address IS 'This will be the actual contact Address i.e someone@somewhere.com';
COMMENT ON COLUMN contact_tbl.consent IS 'This is an indicator to say if the medium is a prefer mode of contact or not';
COMMENT ON COLUMN contact_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN contact_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE contact_tbl IS 'Profile information for list of contacts';

COMMENT ON COLUMN contact_history_tbl.username IS 'The account identifier for a Contact.';
COMMENT ON COLUMN contact_history_tbl.channel IS 'This will list of available ways of contact. e.g Phone, email, twitter, facebook etc';
COMMENT ON COLUMN contact_history_tbl.address IS 'This will be the actual contact Address i.e someone@somewhere.com';
COMMENT ON COLUMN contact_history_tbl.consent IS 'This is an indicator to say if the medium is a prefer mode of contact or not';
COMMENT ON COLUMN contact_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN contact_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN contact_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN contact_history_tbl.archivedDate IS 'Audit column - date of it was archived.';
COMMENT ON TABLE contact_history_tbl IS 'Profile information for list of contacts';

PROMPT "Creating Triggers"
--------------------------------------------------------------
-- TRIGGERS: update modified_date & modified_by automatically
--------------------------------------------------------------
CREATE OR REPLACE TRIGGER credence_trg
    BEFORE INSERT OR UPDATE
    ON credence_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'username is mandatory and cannot be empty.');
        END IF;
        :NEW.issuedAt := SYSTIMESTAMP;
        :NEW.expiresAt := SYSTIMESTAMP + INTERVAL '2' HOUR;
        :NEW.activeFlag := 'Y';
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN
            :NEW.username := :OLD.username;
        END IF;
        IF :NEW.authKey IS NULL THEN
            :NEW.authKey := :OLD.authKey;
        END IF;
        IF :NEW.issuedAt IS NULL THEN
            :NEW.issuedAt := :OLD.issuedAt;
        END IF;
        IF :NEW.expiresAt IS NULL THEN
            :NEW.expiresAt := :OLD.expiresAt;
        END IF;
        IF :NEW.activeFlag IS NULL THEN
            :NEW.activeFlag := :OLD.activeFlag;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'credence_audit_trg (UPSERT): ' || :NEW.username,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER credence_audit_trg
    AFTER INSERT OR UPDATE OR DELETE
    ON credence_tbl
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
        INSERT INTO credence_history_tbl(username, authKey, issuedAt, expiresAt, activeFlag, modifiedReason)
        VALUES (:OLD.username, :OLD.authKey, :OLD.issuedAt, :OLD.expiresAt, :OLD.activeFlag,v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO credence_history_tbl(username, authKey, issuedAt, expiresAt, activeFlag, modifiedReason)
        VALUES (:OLD.username, :OLD.authKey, :OLD.issuedAt, :OLD.expiresAt, :OLD.activeFlag,v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'credence_audit_trg : ' || CASE WHEN UPDATING THEN :NEW.username WHEN DELETING THEN :OLD.username END,
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
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'username is mandatory and cannot be empty.');
        END IF;
        :NEW.verificationToken := dbms_random.string('X', 10);
        :NEW.issuedAt := SYSTIMESTAMP;
        :NEW.expiresAt := SYSTIMESTAMP + INTERVAL '10' MINUTE;
        :NEW.usedFlag := 'N';
        IF :NEW.modifiedBy IS NULL THEN
            :NEW.modifiedBy := USER;
        END IF;
        IF :NEW.modifiedDate IS NULL THEN
            :NEW.modifiedDate := SYSTIMESTAMP;
        END IF;
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN
            :NEW.username := :OLD.username;
        END IF;
        :NEW.verificationToken := dbms_random.string('X', 10);
        :NEW.expiresAt := SYSTIMESTAMP + INTERVAL '10' MINUTE;
        IF :NEW.modifiedBy IS NULL THEN
            :NEW.modifiedBy := USER;
        END IF;
        IF :NEW.modifiedDate IS NULL THEN
            :NEW.modifiedDate := SYSTIMESTAMP;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'verification_trg (UPSERT): ' || :NEW.username,
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
    v_errorMessage   VARCHAR2(4000);
    v_response       VARCHAR2(100);
    v_modifiedReason VARCHAR2(10);
BEGIN
    -- Determine whether the action is an update or delete
    IF UPDATING THEN
        v_modifiedReason := 'Updated';
        -- Log the update or delete in the history table
        INSERT INTO verification_history_tbl(username, verificationToken, issuedAt, expiresAt, usedFlag, modifiedBy,
                                             modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.verificationToken, :OLD.issuedAt, :OLD.expiresAt, :OLD.usedFlag, :OLD.modifiedBy,
                :OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO verification_history_tbl(username, verificationToken, issuedAt, expiresAt, usedFlag, modifiedBy,
                                             modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.verificationToken, :OLD.issuedAt, :OLD.expiresAt, :OLD.usedFlag, :OLD.modifiedBy,
                :OLD.modifiedDate, v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'verification_audit_trg : ' || CASE WHEN UPDATING THEN :NEW.username WHEN DELETING THEN :OLD.username END,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER images_trg
    BEFORE INSERT OR UPDATE
    ON images_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'username is mandatory and cannot be empty.');
        END IF;
        IF :NEW.modifiedBy IS NULL THEN
            :NEW.modifiedBy := USER;
        END IF;
        IF :NEW.modifiedDate IS NULL THEN
            :NEW.modifiedDate := SYSTIMESTAMP;
        END IF;
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN
            :NEW.username := :OLD.username;
        END IF;
        IF :NEW.avatar IS NULL THEN
            :NEW.avatar := :OLD.avatar;
        END IF;
        IF :NEW.modifiedBy IS NULL THEN
            :NEW.modifiedBy := USER;
        END IF;
        IF :NEW.modifiedDate IS NULL THEN
            :NEW.modifiedDate := SYSTIMESTAMP;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'images_trg (INSERT): ' || :NEW.username,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER images_audit_trg
    AFTER UPDATE OR DELETE
    ON images_tbl
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
        INSERT INTO images_history_tbl(username, avatar, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.avatar, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO images_history_tbl(username, avatar, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.avatar, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'images_trg (UPSERT) : ' || CASE WHEN UPDATING THEN :NEW.username WHEN DELETING THEN :OLD.username END,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER person_trg
    BEFORE INSERT OR UPDATE
    ON person_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'username is mandatory and cannot be empty.');
        END IF;
        IF :NEW.modifiedBy IS NULL THEN
            :NEW.modifiedBy := USER;
        END IF;
        IF :NEW.modifiedDate IS NULL THEN
            :NEW.modifiedDate := SYSTIMESTAMP;
        END IF;
        -- Ensure required fields are populated
        IF :NEW.birthday IS NOT NULL THEN
            IF (:NEW.birthday > SYSDATE) THEN
                RAISE_APPLICATION_ERROR(-20001, 'Date Of Birth Cannot Be In The Future');
            END IF;
            :NEW.age := FLOOR(MONTHS_BETWEEN(SYSDATE, :NEW.birthday) / 12);
            :NEW.zodiacSign :=
                CASE
                       WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                           BETWEEN TO_DATE('21-Mar-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                           AND TO_DATE('19-Apr-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Aries'
                       WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                           BETWEEN TO_DATE('20-Apr-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                           AND TO_DATE('20-May-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Taurus'
                       WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                           BETWEEN TO_DATE('21-May-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                           AND TO_DATE('20-Jun-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Gemini'
                       WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                           BETWEEN TO_DATE('21-Jun-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                           AND TO_DATE('22-Jul-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Cancer'
                       WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                           BETWEEN TO_DATE('23-Jul-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                           AND TO_DATE('22-Aug-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Leo'
                       WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                           BETWEEN TO_DATE('23-Aug-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                           AND TO_DATE('22-Sep-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Virgo'
                       WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                           BETWEEN TO_DATE('23-Sep-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                           AND TO_DATE('22-Oct-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Libra'
                       WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                           BETWEEN TO_DATE('23-Oct-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                           AND TO_DATE('21-Nov-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Scorpio'
                       WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                           BETWEEN TO_DATE('22-Nov-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                           AND TO_DATE('21-Dec-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Sagittarius'
                       WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                           BETWEEN TO_DATE('22-Dec-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                           AND TO_DATE('19-Jan-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Capricorn'
                       WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                           BETWEEN TO_DATE('20-Jan-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                           AND TO_DATE('18-Feb-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Aquarius'
                       WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                           BETWEEN TO_DATE('19-Feb-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                           AND TO_DATE('20-Mar-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Pisces'
                       ELSE 'Pisces'
                    END;
        END IF;
    ELSIF UPDATING THEN
        -- Ensure required fields are populated;
        IF :NEW.modifiedBy IS NULL THEN
            :NEW.modifiedBy := USER;
        END IF;
        IF :NEW.modifiedDate IS NULL THEN
            :NEW.modifiedDate := SYSTIMESTAMP;
        END IF;
        IF :NEW.username IS NULL AND :OLD.username IS NOT NULL THEN
            :NEW.username := :OLD.username;
        END IF;
        IF :NEW.title IS NULL AND :OLD.title IS NOT NULL THEN
            :NEW.title := :OLD.title;
        END IF;
        IF :NEW.firstName IS NULL AND :OLD.firstName IS NOT NULL THEN
            :NEW.firstName := :OLD.firstName;
        END IF;
        IF :NEW.middleName IS NULL AND :OLD.middleName IS NOT NULL THEN
            :NEW.middleName := :OLD.middleName;
        END IF;
        IF :NEW.lastName IS NULL AND :OLD.lastName IS NOT NULL THEN
            :NEW.lastName := :OLD.lastName;
        END IF;
        IF :NEW.gender IS NULL AND :OLD.gender IS NOT NULL THEN
            :NEW.gender := :OLD.gender;
        END IF;
        -- Ensure required fields are populated
        IF :NEW.birthday IS NOT NULL THEN
            IF (:NEW.birthday > SYSDATE) THEN
                RAISE_APPLICATION_ERROR(-20001, 'Date Of Birth Cannot Be In The Future');
            END IF;
            :NEW.age := FLOOR(MONTHS_BETWEEN(SYSDATE, :NEW.birthday) / 12);
            :NEW.zodiacSign :=
                    CASE
                        WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                            BETWEEN TO_DATE('21-Mar-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                            AND TO_DATE('19-Apr-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Aries'
                        WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                            BETWEEN TO_DATE('20-Apr-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                            AND TO_DATE('20-May-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Taurus'
                        WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                            BETWEEN TO_DATE('21-May-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                            AND TO_DATE('20-Jun-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Gemini'
                        WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                            BETWEEN TO_DATE('21-Jun-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                            AND TO_DATE('22-Jul-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Cancer'
                        WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                            BETWEEN TO_DATE('23-Jul-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                            AND TO_DATE('22-Aug-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Leo'
                        WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                            BETWEEN TO_DATE('23-Aug-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                            AND TO_DATE('22-Sep-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Virgo'
                        WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                            BETWEEN TO_DATE('23-Sep-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                            AND TO_DATE('22-Oct-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Libra'
                        WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                            BETWEEN TO_DATE('23-Oct-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                            AND TO_DATE('21-Nov-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Scorpio'
                        WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                            BETWEEN TO_DATE('22-Nov-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                            AND TO_DATE('21-Dec-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Sagittarius'
                        WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                            BETWEEN TO_DATE('22-Dec-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                            AND TO_DATE('19-Jan-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Capricorn'
                        WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                            BETWEEN TO_DATE('20-Jan-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                            AND TO_DATE('18-Feb-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Aquarius'
                        WHEN TO_DATE(TO_CHAR(:NEW.birthday, 'DD-Mon-YYYY'))
                            BETWEEN TO_DATE('19-Feb-' || TO_CHAR(:NEW.birthday, 'YYYY'))
                            AND TO_DATE('20-Mar-' || TO_CHAR(:NEW.birthday, 'YYYY')) THEN 'Pisces'
                        ELSE 'Pisces'
                        END;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'person_trg (INSERT): ' || :NEW.username,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER person_audit_trg
    AFTER UPDATE OR DELETE
    ON person_tbl
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
        INSERT INTO person_history_tbl(username, title, firstName, middleName, lastName, zodiacSign, gender, birthday, age,
                                       modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.title, :OLD.firstName, :OLD.middleName, :OLD.lastName, :OLD.zodiacSign, :OLD.gender,
                :OLD.birthday, :OLD.age, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO person_history_tbl(username, title, firstName, middleName, lastName, zodiacSign, gender, birthday, age,
                                       modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.title, :OLD.firstName, :OLD.middleName, :OLD.lastName, :OLD.zodiacSign, :OLD.gender,
                :OLD.birthday, :OLD.age, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'person_trg (UPDATE/DELETE): ' || CASE WHEN UPDATING THEN :NEW.username WHEN DELETING THEN :OLD.username END,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER address_trg
    BEFORE INSERT
    ON address_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    -- Determine the action
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'username is mandatory and cannot be empty.');
        END IF;
        IF :NEW.modifiedBy IS NULL THEN
            :NEW.modifiedBy := USER;
        END IF;
        IF :NEW.modifiedDate IS NULL THEN
            :NEW.modifiedDate := SYSTIMESTAMP;
        END IF;
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN
            :NEW.username := :OLD.username;
        END IF;
        IF :NEW.firstline IS NULL THEN
            :NEW.firstline := :OLD.firstline;
        END IF;
        IF :NEW.secondline IS NULL THEN
            :NEW.secondline := :OLD.secondline;
        END IF;
        IF :NEW.thirdline IS NULL THEN
            :NEW.thirdline := :OLD.thirdline;
        END IF;
        IF :NEW.city IS NULL THEN
            :NEW.city := :OLD.city;
        END IF;
        IF :NEW.postcode IS NULL THEN
            :NEW.postcode := :OLD.postcode;
        END IF;
        IF :NEW.country IS NULL THEN
            :NEW.country := :OLD.country;
        END IF;
        IF :NEW.modifiedBy IS NULL THEN
            :NEW.modifiedBy := USER;
        END IF;
        IF :NEW.modifiedDate IS NULL THEN
            :NEW.modifiedDate := SYSTIMESTAMP;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'address_trg (INSERT): ' || :NEW.username,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER address_audit_trg
    AFTER UPDATE OR DELETE
    ON address_tbl
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
        INSERT INTO address_history_tbl(username, firstline, secondline, thirdline, city, postcode, country, modifiedBy,
                                        modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.firstline, :OLD.secondline, :OLD.thirdline, :OLD.city, :OLD.postcode, :OLD.country,
                :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO address_history_tbl(username, firstline, secondline, thirdline, city, postcode, country, modifiedBy,
                                        modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.firstline, :OLD.secondline, :OLD.thirdline, :OLD.city, :OLD.postcode, :OLD.country,
                :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'address_trg (UPDATE/DELETE): ' || CASE WHEN UPDATING THEN :NEW.username WHEN DELETING THEN :OLD.username END,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER contact_trg
    BEFORE INSERT
    ON contact_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    -- Determine the action
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'username is mandatory and cannot be empty.');
        END IF;
        IF :NEW.consent IS NULL THEN
            :NEW.consent := 'YES';
        END IF;
        IF :NEW.modifiedBy IS NULL THEN
            :NEW.modifiedBy := USER;
        END IF;
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN
            :NEW.username := :OLD.username;
        END IF;
        IF :NEW.channel IS NULL THEN
            :NEW.channel := :OLD.channel;
        END IF;
        IF :NEW.address IS NULL THEN
            :NEW.address := :OLD.address;
        END IF;
        IF :NEW.consent IS NULL THEN
            :NEW.consent := :OLD.consent;
        END IF;
        IF :NEW.modifiedBy IS NULL THEN
            :NEW.modifiedBy := USER;
        END IF;
        IF :NEW.modifiedDate IS NULL THEN
            :NEW.modifiedDate := SYSTIMESTAMP;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'contact_trg (INSERT): ' || :NEW.username,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER contact_audit_trg
    AFTER UPDATE OR DELETE
    ON contact_tbl
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
        INSERT INTO contact_history_tbl(username, channel, address, consent, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.channel, :OLD.address, :OLD.consent, :OLD.modifiedBy, :OLD.modifiedDate,
                v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO contact_history_tbl(username, channel, address, consent, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.channel, :OLD.address, :OLD.consent, :OLD.modifiedBy, :OLD.modifiedDate,
                v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'contact_trg (UPDATE/DELETE): ' || CASE WHEN UPDATING THEN :NEW.username WHEN DELETING THEN :OLD.username END,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER credentials_trg
    BEFORE INSERT OR UPDATE
    ON credentials_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    -- Determine whether the action is an update or delete
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'username is mandatory and cannot be empty.');
        END IF;
        IF :NEW.email IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'email is mandatory and cannot be empty.');
        END IF;
        IF :NEW.password IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'password is mandatory and cannot be empty.');
        END IF;
        IF LENGTH(:NEW.password) < 8 THEN
            RAISE_APPLICATION_ERROR(-20001, 'password must be at least 8 characters long.');
        END IF;
        :NEW.emailVerified := 'N';
        :NEW.accountStatus := 'Inactive';
        IF :NEW.modifiedBy IS NULL THEN
            :NEW.modifiedBy := USER;
        END IF;
        IF :NEW.modifiedDate IS NULL THEN
            :NEW.modifiedDate := SYSTIMESTAMP;
        END IF;
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN
            :NEW.username := :OLD.username;
        END IF;
        IF :NEW.email IS NULL THEN
            :NEW.email := :OLD.email;
        END IF;
        IF :NEW.password IS NULL THEN
            :NEW.password := :OLD.password;
        END IF;
        IF :NEW.emailVerified IS NULL THEN
            :NEW.emailVerified := :OLD.emailVerified;
        END IF;
        IF :NEW.failedLogin IS NULL THEN
            :NEW.failedLogin := :OLD.failedLogin;
        END IF;
        IF :NEW.lastLogin IS NULL THEN
            :NEW.lastLogin := :OLD.lastLogin;
        END IF;
        IF :NEW.accountStatus IS NULL THEN
            :NEW.accountStatus := :OLD.accountStatus;
        END IF;
        IF :NEW.modifiedBy IS NULL THEN
            :NEW.modifiedBy := USER;
        END IF;
        IF :NEW.modifiedDate IS NULL THEN
            :NEW.modifiedDate := SYSTIMESTAMP;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'authentication_trg (UPSERT): ' || :NEW.username,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER credentials_audit_trg
    AFTER INSERT OR UPDATE OR DELETE
    ON credentials_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage   VARCHAR2(4000);
    v_response       VARCHAR2(100);
    v_modifiedReason VARCHAR2(10);
BEGIN
    -- Determine whether the action is an update or delete
    IF INSERTING THEN
        INSERT INTO contact_tbl(username,channel,address,modifiedBy)
        VALUES (:NEW.username,'Email',:NEW.email,:NEW.modifiedBy);
    ELSIF UPDATING THEN
        v_modifiedReason := 'Updated';
        -- Log the update or delete in the history table
        INSERT INTO credentials_history_tbl(username, email, password, emailVerified, failedLogin, lastLogin,
                                            accountStatus, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.email, :OLD.password, :OLD.emailVerified, :OLD.failedLogin, :OLD.lastLogin,
                :OLD.accountStatus, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO credentials_history_tbl(username, email, password, emailVerified, failedLogin, lastLogin,
                                            accountStatus, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.email, :OLD.password, :OLD.emailVerified, :OLD.failedLogin, :OLD.lastLogin,
                :OLD.accountStatus, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'authentication_audit_trg: ' || CASE WHEN UPDATING THEN :NEW.username WHEN DELETING THEN :OLD.username END,
                o_response => v_response
        );
        RAISE;
END;
/

PROMPT "Enabling Triggers"

-- Enable Triggers
ALTER TRIGGER verification_trg ENABLE;
ALTER TRIGGER verification_audit_trg ENABLE;
ALTER TRIGGER person_trg ENABLE;
ALTER TRIGGER person_audit_trg ENABLE;
ALTER TRIGGER address_trg ENABLE;
ALTER TRIGGER address_audit_trg ENABLE;
ALTER TRIGGER contact_trg ENABLE;
ALTER TRIGGER contact_audit_trg ENABLE;
ALTER TRIGGER images_trg ENABLE;
ALTER TRIGGER images_audit_trg ENABLE;
ALTER TRIGGER credence_trg ENABLE;
ALTER TRIGGER credence_audit_trg ENABLE;
ALTER TRIGGER credentials_trg ENABLE;
ALTER TRIGGER credentials_audit_trg ENABLE;
/

PROMPT "Creating Schedule"
--------------------------------------------------------------
-- SCHEDULER: Create schedule job
--------------------------------------------------------------
BEGIN
    DBMS_SCHEDULER.create_job (
            job_name        => 'CREDENCE_SESSION_CLEANUP',
            job_type        => 'PLSQL_BLOCK',
            job_action      => 'BEGIN DELETE FROM credence_tbl WHERE expiresAt < SYSTIMESTAMP OR activeFlag = ''N''; COMMIT; END;',
            start_date      => SYSTIMESTAMP,
            repeat_interval => 'FREQ=HOURLY',
            enabled         => TRUE
    );
END;
/

SHOW ERRORS
/

PROMPT "End of creating Account Schema"