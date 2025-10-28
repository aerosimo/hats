PROMPT "Creating Account Schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      account.sql                                                     *
 * Created:   13/10/2025, 10:58                                               *
 * Modified:  27/10/2025, 21:08                                               *
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

PROMPT "Creating Tables"
--------------------------------------
-- TABLES creating the required tables
--------------------------------------

-- Create main credentials tables
CREATE TABLE credentials_tbl
(
    username      VARCHAR2(200 BYTE)                NOT NULL,
    email         VARCHAR2(200 BYTE)                NOT NULL,
    password      VARCHAR2(400 BYTE),
    securityToken VARCHAR2(4000 BYTE),
    emailVerified CHAR(1)      DEFAULT 'N'          NOT NULL,
    failedLogin   NUMBER       DEFAULT 0,
    lastLogin     TIMESTAMP,
    activeFlag    CHAR(1)      DEFAULT 'N'          NOT NULL,
    accountStatus VARCHAR2(20) DEFAULT 'Inactive'   NOT NULL,
    modifiedBy    VARCHAR2(100 BYTE),
    modifiedDate  TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL
);

-- Create email verification codes (for new signup or after password reset)
CREATE TABLE verification_tbl
(
    email             VARCHAR2(200 BYTE)             NOT NULL,
    verificationToken VARCHAR2(100 BYTE),
    issuedAt          TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    expiresAt         TIMESTAMP,
    usedFlag          CHAR(1)   DEFAULT 'N'          NOT NULL,
    modifiedBy        VARCHAR2(100 BYTE),
    modifiedDate      TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- Create multifactor codes generated on every (successful password) login attempt
CREATE TABLE multifactor_tbl
(
    email             VARCHAR2(200 BYTE)             NOT NULL,
    multifactorToken  VARCHAR2(64)                   NOT NULL,
    issuedAt          TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    expiresAt         TIMESTAMP                      NOT NULL,
    multifactorStatus CHAR(1)   DEFAULT 'N'          NOT NULL,
    inetAddr          VARCHAR2(80),
    deviceInfo        VARCHAR2(200),
    modifiedBy        VARCHAR2(100 BYTE),
    modifiedDate      TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- Scrutiny / audit table
CREATE TABLE scrutiny_tbl
(
    auditId      NUMBER GENERATED ALWAYS AS IDENTITY,
    username     VARCHAR2(200 BYTE)             NOT NULL,
    email        VARCHAR2(200 BYTE)             NOT NULL,
    actionType   VARCHAR2(50)                   NOT NULL,
    actionAt     TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    notes        VARCHAR2(4000),
    modifiedBy   VARCHAR2(100 BYTE),
    modifiedDate TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- User avatar or image table
CREATE TABLE images_tbl
(
    email        VARCHAR2(200 BYTE),
    avatar       BLOB,
    modifiedBy   VARCHAR2(100 BYTE),
    modifiedDate TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- User personal record
CREATE TABLE person_tbl
(
    email        VARCHAR2(200 BYTE),
    title        VARCHAR2(50 BYTE),
    firstName    VARCHAR2(100 BYTE),
    middleName   VARCHAR2(100 BYTE),
    lastName     VARCHAR2(100 BYTE),
    zodiacSign   VARCHAR2(20 BYTE),
    gender       VARCHAR2(30 BYTE),
    birthday     DATE,
    age          VARCHAR2(10 BYTE),
    modifiedBy   VARCHAR2(100 BYTE),
    modifiedDate TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- User address table
CREATE TABLE address_tbl
(
    email        VARCHAR2(200 BYTE),
    firstline    VARCHAR2(100 BYTE),
    secondline   VARCHAR2(100 BYTE),
    thirdline    VARCHAR2(100 BYTE),
    city         VARCHAR2(100 BYTE),
    postcode     VARCHAR2(20 BYTE),
    country      VARCHAR2(100 BYTE),
    modifiedBy   VARCHAR2(100 BYTE),
    modifiedDate TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- User contacts table
CREATE TABLE contact_tbl
(
    email        VARCHAR2(200 BYTE),
    channel      VARCHAR2(40 BYTE),
    address      VARCHAR2(100 BYTE),
    consent      VARCHAR2(10 BYTE) DEFAULT 'YES',
    modifiedBy   VARCHAR2(100 BYTE),
    modifiedDate TIMESTAMP         DEFAULT SYSTIMESTAMP NOT NULL
);

-- User profile table
CREATE TABLE profile_tbl
(
    email         VARCHAR2(200 BYTE),
    maritalStatus VARCHAR2(50 BYTE),
    height        VARCHAR2(20 BYTE),
    weight        VARCHAR2(20 BYTE),
    ethnicity     VARCHAR2(50 BYTE),
    religion      VARCHAR2(50 BYTE),
    eyeColour     VARCHAR2(20 BYTE),
    phenotype     VARCHAR2(50 BYTE),
    genotype      VARCHAR2(50 BYTE),
    modifiedBy    VARCHAR2(100 BYTE),
    modifiedDate  TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- Daily horoscope table
CREATE TABLE horoscope_tbl
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
CREATE INDEX credentials_idx ON credentials_tbl (email, username);
CREATE INDEX verification_idx ON verification_tbl (email);
CREATE INDEX multifactor_idx ON multifactor_tbl (email);

-- Setting Primary Key
ALTER TABLE credentials_tbl
    ADD CONSTRAINT cred_pk PRIMARY KEY (email);
ALTER TABLE scrutiny_tbl
    ADD CONSTRAINT audit_pk PRIMARY KEY (auditId);

-- Setting Foreign Key
ALTER TABLE verification_tbl
    ADD CONSTRAINT verification_fk FOREIGN KEY (email) REFERENCES credentials_tbl (email) ON DELETE CASCADE;
ALTER TABLE multifactor_tbl
    ADD CONSTRAINT multifactor_fk FOREIGN KEY (email) REFERENCES credentials_tbl (email) ON DELETE CASCADE;
ALTER TABLE images_tbl
    ADD CONSTRAINT images_fk FOREIGN KEY (email) REFERENCES credentials_tbl (email) ON DELETE CASCADE;
ALTER TABLE person_tbl
    ADD CONSTRAINT person_fk FOREIGN KEY (email) REFERENCES credentials_tbl (email) ON DELETE CASCADE;
ALTER TABLE address_tbl
    ADD CONSTRAINT address_fk FOREIGN KEY (email) REFERENCES credentials_tbl (email) ON DELETE CASCADE;
ALTER TABLE contact_tbl
    ADD CONSTRAINT contact_fk FOREIGN KEY (email) REFERENCES credentials_tbl (email) ON DELETE CASCADE;
ALTER TABLE profile_tbl
    ADD CONSTRAINT profile_fk FOREIGN KEY (email) REFERENCES credentials_tbl (email) ON DELETE CASCADE;

-- Setting Unique Key
ALTER TABLE credentials_tbl
    ADD CONSTRAINT uname_unq UNIQUE (username);
ALTER TABLE verification_tbl
    ADD CONSTRAINT verificationtoken_unq UNIQUE (verificationToken);
ALTER TABLE multifactor_tbl
    ADD CONSTRAINT mfa_unq UNIQUE (multifactorToken);
ALTER TABLE horoscope_tbl
    ADD CONSTRAINT zodiacSign_unq UNIQUE (zodiacSign);

-- Setting Check Constraint
ALTER TABLE credentials_tbl
    ADD CONSTRAINT email_verified_chk CHECK (emailVerified IN ('Y', 'N')) ENABLE;
ALTER TABLE credentials_tbl
    ADD CONSTRAINT active_flag_chk CHECK (activeFlag IN ('Y', 'N')) ENABLE;
ALTER TABLE credentials_tbl
    ADD CONSTRAINT account_status_chk CHECK (accountStatus IN ('Active', 'Inactive', 'Locked')) ENABLE;
ALTER TABLE multifactor_tbl
    ADD CONSTRAINT multifactor_status_chk CHECK (multifactorStatus IN ('Y', 'N')) ENABLE;
ALTER TABLE verification_tbl
    ADD CONSTRAINT verification_used_chk CHECK (usedFlag IN ('Y', 'N')) ENABLE;
ALTER TABLE person_tbl
    ADD CONSTRAINT pertit_chk CHECK (title IN ('Mr', 'Mrs', 'Miss', 'Dr', 'Ms', 'Professor')) ENABLE;
ALTER TABLE person_tbl
    ADD CONSTRAINT pergen_chk CHECK (gender IN ('Male', 'Female')) ENABLE;
ALTER TABLE contact_tbl
    ADD CONSTRAINT channel_chk CHECK (channel IN
                                      ('Phone', 'Email', 'X', 'Facebook', 'LinkedIn', 'Snapchat', 'Website')) ENABLE;
ALTER TABLE contact_tbl
    ADD CONSTRAINT consent_chk CHECK (consent IN ('YES', 'NO')) ENABLE;
ALTER TABLE profile_tbl
    ADD CONSTRAINT maritalStatus_Chk CHECK (maritalStatus IN
                                            ('Separated', 'Widowed', 'Single', 'Married', 'Divorced')) ENABLE;
ALTER TABLE profile_tbl
    ADD CONSTRAINT genotype_Chk CHECK (genotype IN ('AA', 'AS', 'SS', 'AC')) ENABLE;
ALTER TABLE profile_tbl
    ADD CONSTRAINT phenotype_Chk CHECK (phenotype IN ('A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-')) ENABLE;
ALTER TABLE profile_tbl
    ADD CONSTRAINT religion_Chk CHECK (religion IN
                                       ('Christianity', 'Islam', 'Atheist', 'Hinduism', 'Buddhism', 'Sikhism',
                                        'Judaism')) ENABLE;
ALTER TABLE profile_tbl
    ADD CONSTRAINT eyeColour_Chk CHECK (eyeColour IN
                                        ('Amber', 'Blue', 'Brown', 'Grey', 'Green', 'Hazel', 'Red', 'Violet')) ENABLE;
ALTER TABLE profile_tbl
    ADD CONSTRAINT ethnicity_Chk CHECK (ethnicity IN ('English, Welsh, Scottish, Northern Irish, or British',
                                                      'Irish', 'Gypsy or Irish Traveller', 'Roma',
                                                      'Any other White background',
                                                      'White and Black Caribbean', 'White and Black African',
                                                      'White and Asian',
                                                      'Any other Mixed or multiple ethnic background ',
                                                      'Indian', 'Pakistani', 'Bangladeshi', 'Chinese',
                                                      'Any other Asian background',
                                                      'Caribbean', 'African',
                                                      'Any other Black, Black British, or Caribbean background',
                                                      'Arab', 'Any other ethnic group')) ENABLE;
ALTER TABLE horoscope_tbl
    ADD CONSTRAINT zodiacSign_chk CHECK (zodiacSign IN
                                         ('Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio',
                                          'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces')) ENABLE;

---------------------------------------------------------------------
-- HISTORY for archived purpose
---------------------------------------------------------------------
-- Create history tables
CREATE TABLE credentials_history_tbl AS
SELECT *
FROM credentials_tbl
WHERE 1 = 0;
CREATE TABLE verification_history_tbl AS
SELECT *
FROM verification_tbl
WHERE 1 = 0;
CREATE TABLE multifactor_history_tbl AS
SELECT *
FROM multifactor_tbl
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
CREATE TABLE profile_history_tbl AS
SELECT *
FROM profile_tbl
WHERE 1 = 0;
CREATE TABLE horoscope_history_tbl AS
SELECT *
FROM horoscope_tbl
WHERE 1 = 0;

ALTER TABLE credentials_history_tbl
    ADD modifiedReason VARCHAR2(200);
ALTER TABLE credentials_history_tbl
    ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE verification_history_tbl
    ADD modifiedReason VARCHAR2(200);
ALTER TABLE verification_history_tbl
    ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE multifactor_history_tbl
    ADD modifiedReason VARCHAR2(200);
ALTER TABLE multifactor_history_tbl
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
ALTER TABLE profile_history_tbl
    ADD modifiedReason VARCHAR2(200);
ALTER TABLE profile_history_tbl
    ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE horoscope_history_tbl
    ADD modifiedReason VARCHAR2(200);
ALTER TABLE horoscope_history_tbl
    ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;

PROMPT "Commenting Tables"
---------------------------------------------------------------------
-- COMMENTS for clarity (shorter and clearer)
---------------------------------------------------------------------
COMMENT ON COLUMN credentials_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN credentials_tbl.email IS 'This is the account record primary identifier and also electronic mail is a method of exchanging messages between people using electronic devices.';
COMMENT ON COLUMN credentials_tbl.password IS 'This is contact set encrypted password';
COMMENT ON COLUMN credentials_tbl.securityToken IS 'This the base64 generated security code';
COMMENT ON COLUMN credentials_tbl.emailVerified IS 'Y = email verified, N = not verified';
COMMENT ON COLUMN credentials_tbl.failedLogin IS 'Consecutive failed password attempts';
COMMENT ON COLUMN credentials_tbl.lastLogin IS 'Timestamp of most recent successful login (after MFA).';
COMMENT ON COLUMN credentials_tbl.activeFlag IS 'This indicates if the account is active or not';
COMMENT ON COLUMN credentials_tbl.accountStatus IS 'Active / Inactive / Locked - account lifecycle state.';
COMMENT ON COLUMN credentials_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN credentials_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE credentials_tbl IS 'A user account is a location on a network server used to store a computer username, password, and other information. A user account allows or does not allow a user to connect to a network, another computer, or other shares.';

COMMENT ON COLUMN credentials_history_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN credentials_history_tbl.email IS 'This is the account record primary identifier and also electronic mail is a method of exchanging messages between people using electronic devices.';
COMMENT ON COLUMN credentials_history_tbl.password IS 'This is contact set encrypted password';
COMMENT ON COLUMN credentials_history_tbl.securityToken IS 'This the base64 generated security code';
COMMENT ON COLUMN credentials_history_tbl.emailVerified IS 'Y = email verified, N = not verified';
COMMENT ON COLUMN credentials_history_tbl.failedLogin IS 'Consecutive failed password attempts';
COMMENT ON COLUMN credentials_history_tbl.lastLogin IS 'Timestamp of most recent successful login (after MFA).';
COMMENT ON COLUMN credentials_history_tbl.activeFlag IS 'This indicates if the account is active or not';
COMMENT ON COLUMN credentials_history_tbl.accountStatus IS 'Active / Inactive / Locked - account lifecycle state.';
COMMENT ON COLUMN credentials_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN credentials_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN credentials_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN credentials_history_tbl.archivedDate IS 'Audit column - date of it was archived.';
COMMENT ON TABLE credentials_history_tbl IS 'A user account is a location on a network server used to store a computer username, password, and other information. A user account allows or does not allow a user to connect to a network, another computer, or other shares.';

COMMENT ON TABLE verification_tbl IS 'Stores email verification codes for signup or password reset. Expire after configured interval.';
COMMENT ON COLUMN verification_tbl.email IS 'This is the primary identifier';
COMMENT ON COLUMN verification_tbl.verificationToken IS 'This the generated verification code';
COMMENT ON COLUMN verification_tbl.issuedAt IS 'This store the time the verification code was issued';
COMMENT ON COLUMN verification_tbl.expiresAt IS 'This store the time the verification code expires';
COMMENT ON COLUMN verification_tbl.usedFlag IS 'This indicates if the verification code was used or not';
COMMENT ON COLUMN verification_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN verification_tbl.modifiedDate IS 'Audit column - date of last update.';

COMMENT ON TABLE verification_history_tbl IS 'Stores email verification codes for signup or password reset. Expire after configured interval.';
COMMENT ON COLUMN verification_history_tbl.email IS 'This is the primary identifier';
COMMENT ON COLUMN verification_history_tbl.verificationToken IS 'This the generated verification code';
COMMENT ON COLUMN verification_history_tbl.issuedAt IS 'This store the time the verification code was issued';
COMMENT ON COLUMN verification_history_tbl.expiresAt IS 'This store the time the verification code expires';
COMMENT ON COLUMN verification_history_tbl.usedFlag IS 'This indicates if the verification code was used or not';
COMMENT ON COLUMN verification_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN verification_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN verification_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN verification_history_tbl.archivedDate IS 'Audit column - date of it was archived.';

COMMENT ON TABLE multifactor_tbl IS 'Stores one-time MFA (authentication) codes generated on login; short-lived (e.g., 15 minutes).';
COMMENT ON COLUMN multifactor_tbl.email IS 'This is the primary identifier';
COMMENT ON COLUMN multifactor_tbl.multifactorToken IS 'This the generated authentication code';
COMMENT ON COLUMN multifactor_tbl.issuedAt IS 'This store the time the authentication code was issued';
COMMENT ON COLUMN multifactor_tbl.expiresAt IS 'This store the time the authentication code expires';
COMMENT ON COLUMN multifactor_tbl.multifactorStatus IS 'This indicates if the authentication code was used or not';
COMMENT ON COLUMN multifactor_tbl.inetAddr IS 'This user internet IP address';
COMMENT ON COLUMN multifactor_tbl.deviceInfo IS 'any device info such as mac address';
COMMENT ON COLUMN multifactor_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN multifactor_tbl.modifiedDate IS 'Audit column - date of last update.';

COMMENT ON TABLE multifactor_history_tbl IS 'Stores one-time MFA (authentication) codes generated on login; short-lived (e.g., 15 minutes).';
COMMENT ON COLUMN multifactor_history_tbl.email IS 'This is the primary identifier';
COMMENT ON COLUMN multifactor_history_tbl.multifactorToken IS 'This the generated authentication code';
COMMENT ON COLUMN multifactor_history_tbl.issuedAt IS 'This store the time the authentication code was issued';
COMMENT ON COLUMN multifactor_history_tbl.expiresAt IS 'This store the time the authentication code expires';
COMMENT ON COLUMN multifactor_history_tbl.multifactorStatus IS 'This indicates if the authentication code was used or not';
COMMENT ON COLUMN multifactor_history_tbl.inetAddr IS 'This user internet IP address';
COMMENT ON COLUMN multifactor_history_tbl.deviceInfo IS 'any device info such as mac address';
COMMENT ON COLUMN multifactor_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN multifactor_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN multifactor_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN multifactor_history_tbl.archivedDate IS 'Audit column - date of it was archived.';

COMMENT ON TABLE scrutiny_tbl IS 'Audit log for authentication events (login/logout/password change/etc).';
COMMENT ON COLUMN scrutiny_tbl.auditId IS 'This is the primary identifier';
COMMENT ON COLUMN scrutiny_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN scrutiny_tbl.email IS 'This is the primary identifier';
COMMENT ON COLUMN scrutiny_tbl.actionType IS 'This stores the type of action such as LOGIN, LOGOUT, PASSWORD_RESET, SIGNUP, MFA_ISSUED, MFA_CONFIRMED, EMAIL_VERIFIED';
COMMENT ON COLUMN scrutiny_tbl.actionAt IS 'This store the time the action occurs';
COMMENT ON COLUMN scrutiny_tbl.notes IS 'This stores any other information';
COMMENT ON COLUMN scrutiny_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN scrutiny_tbl.modifiedDate IS 'Audit column - date of last update.';

COMMENT ON COLUMN images_tbl.email IS 'The account identifier for an image';
COMMENT ON COLUMN images_tbl.avatar IS 'This is user avatar image';
COMMENT ON COLUMN images_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN images_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE images_tbl IS 'A user image which is a visual representation of the user is stored here.';

COMMENT ON COLUMN images_history_tbl.email IS 'The account identifier for an image';
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

COMMENT ON COLUMN address_tbl.email IS 'The account identifier for a Contact';
COMMENT ON COLUMN address_tbl.firstline IS 'This is the first line of the Address';
COMMENT ON COLUMN address_tbl.secondline IS 'This is the second line of the Address';
COMMENT ON COLUMN address_tbl.thirdline IS 'This is the third line of the Address.';
COMMENT ON COLUMN address_tbl.city IS 'The city in which the Address is located.';
COMMENT ON COLUMN address_tbl.postcode IS 'The postal code/zipcode of the Address.';
COMMENT ON COLUMN address_tbl.country IS 'The country of the Address.';
COMMENT ON COLUMN address_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN address_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE address_tbl IS 'Physical Address Information.';

COMMENT ON COLUMN address_history_tbl.email IS 'The account identifier for a Contact';
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

COMMENT ON COLUMN contact_tbl.email IS 'The account identifier for a Contact.';
COMMENT ON COLUMN contact_tbl.channel IS 'This will list of available ways of contact. e.g Phone, email, twitter, facebook etc';
COMMENT ON COLUMN contact_tbl.address IS 'This will be the actual contact Address i.e someone@somewhere.com';
COMMENT ON COLUMN contact_tbl.consent IS 'This is an indicator to say if the medium is a prefer mode of contact or not';
COMMENT ON COLUMN contact_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN contact_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE contact_tbl IS 'Profile information for list of contacts';

COMMENT ON COLUMN contact_history_tbl.email IS 'The account identifier for a Contact.';
COMMENT ON COLUMN contact_history_tbl.channel IS 'This will list of available ways of contact. e.g Phone, email, twitter, facebook etc';
COMMENT ON COLUMN contact_history_tbl.address IS 'This will be the actual contact Address i.e someone@somewhere.com';
COMMENT ON COLUMN contact_history_tbl.consent IS 'This is an indicator to say if the medium is a prefer mode of contact or not';
COMMENT ON COLUMN contact_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN contact_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN contact_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN contact_history_tbl.archivedDate IS 'Audit column - date of it was archived.';
COMMENT ON TABLE contact_history_tbl IS 'Profile information for list of contacts';

COMMENT ON COLUMN profile_tbl.email IS 'The account identifier for profile';
COMMENT ON COLUMN profile_tbl.maritalStatus IS 'This is contact''s marital status.';
COMMENT ON COLUMN profile_tbl.height IS 'The measurement of someone or something from head to foot or from base to top. ';
COMMENT ON COLUMN profile_tbl.weight IS 'This is the Weight of a person is usually taken to be the force on the person due to gravity.';
COMMENT ON COLUMN profile_tbl.ethnicity IS 'This is the fact or state of belonging to a social group that has a common national or cultural tradition.';
COMMENT ON COLUMN profile_tbl.religion IS 'The belief in and worship of a superhuman controlling power, especially a personal God or gods.';
COMMENT ON COLUMN profile_tbl.eyeColour IS 'This is a polygenic phenotypic character determined by two distinct factors: pigmentation of the eye and the scattering of light by the turbid medium in the stroma of the iris';
COMMENT ON COLUMN profile_tbl.phenotype IS 'This is a classification of blood based on the presence and absence of antibodies and inherited antigenic substances on the surface of red blood cells.';
COMMENT ON COLUMN profile_tbl.genotype IS 'This is the genetic constitution of an individual organism.';
COMMENT ON COLUMN profile_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN profile_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE profile_tbl IS 'Profile information for a Contact.';

COMMENT ON COLUMN profile_history_tbl.email IS 'The account identifier for profile';
COMMENT ON COLUMN profile_history_tbl.maritalStatus IS 'This is contact''s marital status.';
COMMENT ON COLUMN profile_history_tbl.height IS 'The measurement of someone or something from head to foot or from base to top. ';
COMMENT ON COLUMN profile_history_tbl.weight IS 'This is the Weight of a person is usually taken to be the force on the person due to gravity.';
COMMENT ON COLUMN profile_history_tbl.ethnicity IS 'This is the fact or state of belonging to a social group that has a common national or cultural tradition.';
COMMENT ON COLUMN profile_history_tbl.religion IS 'The belief in and worship of a superhuman controlling power, especially a personal God or gods.';
COMMENT ON COLUMN profile_history_tbl.eyeColour IS 'This is a polygenic phenotypic character determined by two distinct factors: pigmentation of the eye and the scattering of light by the turbid medium in the stroma of the iris';
COMMENT ON COLUMN profile_history_tbl.phenotype IS 'This is a classification of blood based on the presence and absence of antibodies and inherited antigenic substances on the surface of red blood cells.';
COMMENT ON COLUMN profile_history_tbl.genotype IS 'This is the genetic constitution of an individual organism.';
COMMENT ON COLUMN profile_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN profile_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN profile_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN profile_history_tbl.archivedDate IS 'Audit column - date of it was archived.';
COMMENT ON TABLE profile_history_tbl IS 'Profile information for a Contact.';

COMMENT ON TABLE horoscope_tbl IS 'Profile information for list of daily horoscope based on signs.';
COMMENT ON COLUMN horoscope_tbl.zodiacSign IS 'The zodiacSign is an area of the sky that extends approximately 8° north or south (as measured in celestial latitude) of the ecliptic, the apparent path of the Sun across the celestial sphere over the course of the year.';
COMMENT ON COLUMN horoscope_tbl.currentDay IS 'The current date means the date today or the date when something will happen.';
COMMENT ON COLUMN horoscope_tbl.narrative IS 'Your zodiacSign sign, or star sign, reflects the position of the sun when you were born. With its strong influence on your personality, character, and emotions, your sign is a powerful tool for understanding yourself and your relationships and of course, your sign can show you the way to an incredible life.';
COMMENT ON COLUMN horoscope_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN horoscope_tbl.modifiedDate IS 'Audit column - date of last update.';

COMMENT ON TABLE horoscope_history_tbl IS 'Profile information for list of daily horoscope based on signs.';
COMMENT ON COLUMN horoscope_history_tbl.zodiacSign IS 'The zodiacSign is an area of the sky that extends approximately 8° north or south (as measured in celestial latitude) of the ecliptic, the apparent path of the Sun across the celestial sphere over the course of the year.';
COMMENT ON COLUMN horoscope_history_tbl.currentDay IS 'The current date means the date today or the date when something will happen.';
COMMENT ON COLUMN horoscope_history_tbl.narrative IS 'Your zodiacSign sign, or star sign, reflects the position of the sun when you were born. With its strong influence on your personality, character, and emotions, your sign is a powerful tool for understanding yourself and your relationships and of course, your sign can show you the way to an incredible life.';
COMMENT ON COLUMN horoscope_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN horoscope_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN horoscope_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN horoscope_history_tbl.archivedDate IS 'Audit column - date of it was archived.';

PROMPT "Creating Triggers"
--------------------------------------------------------------
-- TRIGGERS: update modified_date & modified_by automatically
--------------------------------------------------------------
CREATE OR REPLACE TRIGGER verification_trg
    BEFORE INSERT OR UPDATE
    ON verification_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        IF :NEW.email IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Email is mandatory and cannot be empty.');
        END IF;
        :NEW.verificationToken := dbms_random.string('X', 10);
        :NEW.issuedAt := SYSTIMESTAMP;
        :NEW.expiresAt := SYSTIMESTAMP + INTERVAL '10' MINUTE;
        :NEW.usedFlag := 'N';
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
    ELSIF UPDATING THEN
        IF :NEW.email IS NULL THEN
            SELECT :OLD.email INTO :NEW.email FROM DUAL;
        END IF;
        :NEW.verificationToken := dbms_random.string('X', 10);
        :NEW.expiresAt := SYSTIMESTAMP + INTERVAL '10' MINUTE;
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
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
    v_errorMessage   VARCHAR2(4000);
    v_response       VARCHAR2(100);
    v_modifiedReason VARCHAR2(10);
BEGIN
    -- Determine whether the action is an update or delete
    IF UPDATING THEN
        v_modifiedReason := 'Updated';
        -- Log the update or delete in the history table
        INSERT INTO verification_history_tbl(email, verificationToken, issuedAt, expiresAt, usedFlag, modifiedBy,
                                             modifiedDate, modifiedReason)
        VALUES (:OLD.email, :OLD.verificationToken, :OLD.issuedAt, :OLD.expiresAt, :OLD.usedFlag, :OLD.modifiedBy,
                :OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO verification_history_tbl(email, verificationToken, issuedAt, expiresAt, usedFlag, modifiedBy,
                                             modifiedDate, modifiedReason)
        VALUES (:OLD.email, :OLD.verificationToken, :OLD.issuedAt, :OLD.expiresAt, :OLD.usedFlag, :OLD.modifiedBy,
                :OLD.modifiedDate, v_modifiedReason);
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

CREATE OR REPLACE TRIGGER multifactor_trg
    BEFORE INSERT OR UPDATE
    ON multifactor_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        IF :NEW.email IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Email is mandatory and cannot be empty.');
        END IF;
        :NEW.multifactorToken := dbms_random.string('X', 6);
        :NEW.expiresAt := SYSTIMESTAMP + INTERVAL '10' MINUTE;
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
    ELSIF UPDATING THEN
        IF :NEW.email IS NULL THEN
            SELECT :OLD.email INTO :NEW.email FROM DUAL;
        END IF;
        :NEW.multifactorToken := dbms_random.string('X', 6);
        :NEW.expiresAt := SYSTIMESTAMP + INTERVAL '10' MINUTE;
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'multifactor_trg (UPSERT): ' || :NEW.email,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER multifactor_audit_trg
    AFTER UPDATE OR DELETE
    ON multifactor_tbl
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
        INSERT INTO multifactor_history_tbl(email, multifactorToken, issuedAt, expiresAt, multifactorStatus, inetAddr,
                                            deviceInfo, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.email, :OLD.multifactorToken, :OLD.issuedAt, :OLD.expiresAt, :OLD.multifactorStatus, :OLD.inetAddr,
                :OLD.deviceInfo, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO multifactor_history_tbl(email, multifactorToken, issuedAt, expiresAt, multifactorStatus, inetAddr,
                                            deviceInfo, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.email, :OLD.multifactorToken, :OLD.issuedAt, :OLD.expiresAt, :OLD.multifactorStatus, :OLD.inetAddr,
                :OLD.deviceInfo, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
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

CREATE OR REPLACE TRIGGER scrutiny_trg
    BEFORE INSERT OR UPDATE
    ON scrutiny_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Username is mandatory and cannot be empty.');
        END IF;
        IF :NEW.email IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Email is mandatory and cannot be empty.');
        END IF;
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN SELECT :OLD.username INTO :NEW.username FROM DUAL; END IF;
        IF :NEW.email IS NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
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

CREATE OR REPLACE TRIGGER images_trg
    BEFORE INSERT OR UPDATE
    ON images_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        IF :NEW.email IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Email is mandatory and cannot be empty.');
        END IF;
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
    ELSIF UPDATING THEN
        IF :NEW.email IS NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        IF :NEW.avatar IS NULL THEN SELECT :OLD.avatar INTO :NEW.avatar FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'images_trg (INSERT): ' || :NEW.email,
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
        INSERT INTO images_history_tbl(email, avatar, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.email, :OLD.avatar, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO images_history_tbl(email, avatar, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.email, :OLD.avatar, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'images_trg (UPSERT): ' ||
                                  CASE
                                      WHEN UPDATING THEN :NEW.email
                                      WHEN DELETING THEN :OLD.email
                                      END,
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
        IF :NEW.email IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Email is mandatory and cannot be empty.');
        END IF;
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
        -- Ensure required fields are populated
        IF :NEW.birthday IS NOT NULL THEN
            IF (:NEW.birthday > SYSDATE) THEN
                RAISE_APPLICATION_ERROR(-20001, 'Date Of Birth Cannot Be In The Future');
            END IF;
            SELECT FLOOR(MONTHS_BETWEEN(SYSDATE, :NEW.birthday) / 12)
            INTO :NEW.age
            FROM DUAL;
            SELECT CASE
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
                       END
            INTO :NEW.zodiacSign
            FROM DUAL;
        END IF;
    ELSIF UPDATING THEN
        -- Ensure required fields are populated;
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
        IF :NEW.email IS NULL AND :OLD.email IS NOT NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        IF :NEW.title IS NULL AND :OLD.title IS NOT NULL THEN SELECT :OLD.title INTO :NEW.title FROM DUAL; END IF;
        IF :NEW.firstName IS NULL AND :OLD.firstName IS NOT NULL THEN
            SELECT :OLD.firstName INTO :NEW.firstName FROM DUAL;
        END IF;
        IF :NEW.middleName IS NULL AND :OLD.middleName IS NOT NULL THEN
            SELECT :OLD.middleName INTO :NEW.middleName FROM DUAL;
        END IF;
        IF :NEW.lastName IS NULL AND :OLD.lastName IS NOT NULL THEN
            SELECT :OLD.lastName INTO :NEW.lastName FROM DUAL;
        END IF;
        IF :NEW.gender IS NULL AND :OLD.gender IS NOT NULL THEN SELECT :OLD.gender INTO :NEW.gender FROM DUAL; END IF;
        IF :NEW.birthday IS NOT NULL THEN
            IF (:NEW.birthday > SYSDATE) THEN
                RAISE_APPLICATION_ERROR(-20005, 'Date Of Birth Cannot Be In The Future');
            END IF;
            SELECT FLOOR(MONTHS_BETWEEN(SYSDATE, :NEW.birthday) / 12)
            INTO :NEW.age
            FROM DUAL;
            SELECT CASE
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
                       END
            INTO :NEW.zodiacSign
            FROM DUAL;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'person_trg (INSERT): ' || :NEW.email,
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
        INSERT INTO person_history_tbl(email, title, firstName, middleName, lastName, zodiacSign, gender, birthday, age,
                                       modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.email, :OLD.title, :OLD.firstName, :OLD.middleName, :OLD.lastName, :OLD.zodiacSign, :OLD.gender,
                :OLD.birthday, :OLD.age, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO person_history_tbl(email, title, firstName, middleName, lastName, zodiacSign, gender, birthday, age,
                                       modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.email, :OLD.title, :OLD.firstName, :OLD.middleName, :OLD.lastName, :OLD.zodiacSign, :OLD.gender,
                :OLD.birthday, :OLD.age, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'person_trg (UPDATE/DELETE): ' || :NEW.email,
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
        IF :NEW.email IS NULL THEN RAISE_APPLICATION_ERROR(-20001, 'Email is mandatory and cannot be empty.'); END IF;
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
    ELSIF UPDATING THEN
        IF :NEW.email IS NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        IF :NEW.firstline IS NULL THEN SELECT :OLD.firstline INTO :NEW.firstline FROM DUAL; END IF;
        IF :NEW.secondline IS NULL THEN SELECT :OLD.secondline INTO :NEW.secondline FROM DUAL; END IF;
        IF :NEW.thirdline IS NULL THEN SELECT :OLD.thirdline INTO :NEW.thirdline FROM DUAL; END IF;
        IF :NEW.city IS NULL THEN SELECT :OLD.city INTO :NEW.city FROM DUAL; END IF;
        IF :NEW.postcode IS NULL THEN SELECT :OLD.postcode INTO :NEW.postcode FROM DUAL; END IF;
        IF :NEW.country IS NULL THEN SELECT :OLD.country INTO :NEW.country FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'address_trg (INSERT): ' || :NEW.email,
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
        INSERT INTO address_history_tbl(email, firstline, secondline, thirdline, city, postcode, country, modifiedBy,
                                        modifiedDate, modifiedReason)
        VALUES (:OLD.email, :OLD.firstline, :OLD.secondline, :OLD.thirdline, :OLD.city, :OLD.postcode, :OLD.country,
                :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO address_history_tbl(email, firstline, secondline, thirdline, city, postcode, country, modifiedBy,
                                        modifiedDate, modifiedReason)
        VALUES (:OLD.email, :OLD.firstline, :OLD.secondline, :OLD.thirdline, :OLD.city, :OLD.postcode, :OLD.country,
                :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'address_trg (UPDATE/DELETE): ' || :NEW.email,
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
        IF :NEW.email IS NULL THEN RAISE_APPLICATION_ERROR(-20001, 'Email is mandatory and cannot be empty.'); END IF;
        IF :NEW.consent IS NULL THEN SELECT 'YES' INTO :NEW.consent FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
    ELSIF UPDATING THEN
        IF :NEW.email IS NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        IF :NEW.channel IS NULL THEN SELECT :OLD.channel INTO :NEW.channel FROM DUAL; END IF;
        IF :NEW.address IS NULL THEN SELECT :OLD.address INTO :NEW.address FROM DUAL; END IF;
        IF :NEW.consent IS NULL THEN SELECT :OLD.consent INTO :NEW.consent FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'contact_trg (INSERT): ' || :NEW.email,
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
        INSERT INTO contact_history_tbl(email, channel, address, consent, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.email, :OLD.channel, :OLD.address, :OLD.consent, :OLD.modifiedBy, :OLD.modifiedDate,
                v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO contact_history_tbl(email, channel, address, consent, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.email, :OLD.channel, :OLD.address, :OLD.consent, :OLD.modifiedBy, :OLD.modifiedDate,
                v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'contact_trg (UPDATE/DELETE): ' || :NEW.email,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER profile_trg
    BEFORE INSERT
    ON profile_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    -- Determine the action
    IF INSERTING THEN
        IF :NEW.email IS NULL THEN RAISE_APPLICATION_ERROR(-20001, 'Email is mandatory and cannot be empty.'); END IF;
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
    ELSIF UPDATING THEN
        IF :NEW.email IS NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        IF :NEW.maritalStatus IS NULL THEN SELECT :OLD.maritalStatus INTO :NEW.maritalStatus FROM DUAL; END IF;
        IF :NEW.height IS NULL THEN SELECT :OLD.height INTO :NEW.height FROM DUAL; END IF;
        IF :NEW.weight IS NULL THEN SELECT :OLD.weight INTO :NEW.weight FROM DUAL; END IF;
        IF :NEW.ethnicity IS NULL THEN SELECT :OLD.ethnicity INTO :NEW.ethnicity FROM DUAL; END IF;
        IF :NEW.religion IS NULL THEN SELECT :OLD.religion INTO :NEW.religion FROM DUAL; END IF;
        IF :NEW.eyeColour IS NULL THEN SELECT :OLD.eyeColour INTO :NEW.eyeColour FROM DUAL; END IF;
        IF :NEW.phenotype IS NULL THEN SELECT :OLD.phenotype INTO :NEW.phenotype FROM DUAL; END IF;
        IF :NEW.genotype IS NULL THEN SELECT :OLD.genotype INTO :NEW.genotype FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'profile_trg (INSERT): ' || :NEW.email,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER profile_audit_trg
    AFTER UPDATE OR DELETE
    ON profile_tbl
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
        INSERT INTO profile_history_tbl(email, maritalStatus, height, weight, ethnicity, religion, eyeColour, phenotype,
                                        genotype, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.email, :OLD.maritalStatus, :OLD.height, :OLD.weight, :OLD.ethnicity, :OLD.religion, :OLD.eyeColour,
                :OLD.phenotype, :OLD.genotype, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO profile_history_tbl(email, maritalStatus, height, weight, ethnicity, religion, eyeColour, phenotype,
                                        genotype, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.email, :OLD.maritalStatus, :OLD.height, :OLD.weight, :OLD.ethnicity, :OLD.religion, :OLD.eyeColour,
                :OLD.phenotype, :OLD.genotype, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'profile_trg (INSERT): ' || :NEW.email,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER horoscope_trg
    BEFORE INSERT OR UPDATE
    ON horoscope_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    IF :NEW.modifiedDate IS NULL THEN SELECT SYSTIMESTAMP INTO :NEW.modifiedDate FROM DUAL; END IF;
    IF :NEW.modifiedBy IS NULL THEN SELECT USER INTO :NEW.modifiedBy FROM DUAL; END IF;

EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'horoscope_trg for profile: ' || :NEW.zodiacSign,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER horoscope_audit_trg
    AFTER UPDATE OR DELETE
    ON horoscope_tbl
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
        INSERT INTO horoscope_history_tbl(zodiacSign, currentDay, narrative, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.zodiacSign, :OLD.currentDay, :OLD.narrative, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO horoscope_history_tbl(zodiacSign, currentDay, narrative, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.zodiacSign, :OLD.currentDay, :OLD.narrative, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'horoscope_trg (INSERT): ' || :NEW.zodiacSign,
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
            RAISE_APPLICATION_ERROR(-20001, 'Username is mandatory and cannot be empty.');
        END IF;
        IF :NEW.email IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Email is mandatory and cannot be empty.');
        END IF;
        IF :NEW.password IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Password is mandatory and cannot be empty.');
        END IF;
        :NEW.emailVerified := 'N';
        :NEW.accountStatus := 'Inactive';
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN
            SELECT :OLD.username INTO :NEW.username FROM DUAL;
        END IF;
        IF :NEW.email IS NULL THEN
            SELECT :OLD.email INTO :NEW.email FROM DUAL;
        END IF;
        IF :NEW.password IS NULL THEN
            SELECT :OLD.password INTO :NEW.password FROM DUAL;
        END IF;
        IF :NEW.emailVerified IS NULL THEN
            SELECT :OLD.emailVerified INTO :NEW.emailVerified FROM DUAL;
        END IF;
        IF :NEW.failedLogin IS NULL THEN
            SELECT :OLD.failedLogin INTO :NEW.failedLogin FROM DUAL;
        END IF;
        IF :NEW.lastLogin IS NULL THEN
            SELECT :OLD.lastLogin INTO :NEW.lastLogin FROM DUAL;
        END IF;
        IF :NEW.accountStatus IS NULL THEN
            SELECT :OLD.accountStatus INTO :NEW.accountStatus FROM DUAL;
        END IF;
        IF :NEW.modifiedBy IS NULL THEN
            SELECT USER INTO :NEW.modifiedBy FROM DUAL;
        END IF;
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
        INSERT INTO verification_tbl(email, modifiedBy) VALUES (:NEW.email, 'Authentication Trigger');
        INSERT INTO multifactor_tbl(email, modifiedBy) VALUES (:NEW.email, 'Authentication Trigger');
        INSERT INTO profile_tbl(email, modifiedBy) VALUES (:NEW.email, 'Authentication Trigger');
        INSERT INTO images_tbl(email, modifiedBy) VALUES (:NEW.email, 'Authentication Trigger');
        INSERT INTO person_tbl(email, modifiedBy) VALUES (:NEW.email, 'Authentication Trigger');
        INSERT INTO address_tbl(email, modifiedBy) VALUES (:NEW.email, 'Authentication Trigger');
        INSERT INTO contact_tbl(email, channel, address, consent, modifiedBy)
        VALUES (:NEW.email, 'Email', :NEW.email, 'YES', 'Authentication Trigger');
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
ALTER TRIGGER verification_trg ENABLE;
ALTER TRIGGER verification_audit_trg ENABLE;
ALTER TRIGGER multifactor_trg ENABLE;
ALTER TRIGGER multifactor_audit_trg ENABLE;
ALTER TRIGGER scrutiny_trg ENABLE;
ALTER TRIGGER person_trg ENABLE;
ALTER TRIGGER person_audit_trg ENABLE;
ALTER TRIGGER address_trg ENABLE;
ALTER TRIGGER address_audit_trg ENABLE;
ALTER TRIGGER contact_trg ENABLE;
ALTER TRIGGER contact_audit_trg ENABLE;
ALTER TRIGGER images_trg ENABLE;
ALTER TRIGGER images_audit_trg ENABLE;
ALTER TRIGGER profile_trg ENABLE;
ALTER TRIGGER horoscope_trg ENABLE;
ALTER TRIGGER horoscope_audit_trg ENABLE;
ALTER TRIGGER profile_audit_trg ENABLE;
ALTER TRIGGER credentials_trg ENABLE;
ALTER TRIGGER credentials_audit_trg ENABLE;

PROMPT "Creating Package Header"
--------------------------------------------------------------
-- PACKAGE: Creating utility header package
--------------------------------------------------------------
-- Create Header Package
CREATE OR REPLACE PACKAGE utility_pkg
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
    Name: utility_pkg
    Program Type: Package Specification
    Purpose: ADD/FIND/UPDATE/DELETE entity
    =================================================================================
    HISTORY
    =================================================================================
    | DATE 		| Owner 	| Activity
    =================================================================================
    | 28-OCT-25	| eomisore 	| Created initial script.|
    =================================================================================
    */
    -- Audit records
    PROCEDURE audit(
        i_email IN VARCHAR2,
        i_actionType IN VARCHAR2,
        i_notes IN VARCHAR2);

    -- Base64 encoding and decoding
    PROCEDURE encoderDecoder(
        i_action IN VARCHAR2, -- 'ENCODE' or 'DECODE'
        i_data IN VARCHAR2,
        o_response OUT VARCHAR2);

END utility_pkg;
/

PROMPT "Creating Package Body"
--------------------------------------------------------------
-- PACKAGE: Creating utility body package
--------------------------------------------------------------
-- Create Body Package
CREATE OR REPLACE PACKAGE BODY utility_pkg
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
    Name: utility_pkg
    Program Type: Package Specification
    Purpose: ADD/FIND/UPDATE/DELETE entity
    =================================================================================
    HISTORY
    =================================================================================
    | DATE 		| Owner 	| Activity
    =================================================================================
    | 28-OCT-25	| eomisore 	| Created initial script.|
    =================================================================================
    */
    -- Audit records
    PROCEDURE audit(
        i_email IN VARCHAR2,
        i_actionType IN VARCHAR2,
        i_notes IN VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_username     VARCHAR2(100);
        v_count        NUMBER;
    BEGIN
        SELECT COUNT(*), username INTO v_count, v_username FROM credentials_tbl WHERE email = i_email GROUP BY username;
        IF v_count = 1 THEN
            -- insert audit records
            INSERT INTO scrutiny_tbl(username, email, actionType, notes, modifiedBy)
            VALUES (v_username, i_email, i_actionType, i_notes, v_username);
        END IF;
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

    -- Base64 encoding and decoding
    PROCEDURE encoderDecoder(
        i_action IN VARCHAR2, -- 'ENCODE' or 'DECODE'
        i_data IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_input        RAW(32767);
        v_output       RAW(32767);
    BEGIN
        v_input := UTL_RAW.CAST_TO_RAW(i_data);
        IF UPPER(i_action) = 'ENCODE' THEN
            -- Perform Base64 encoding
            v_output := UTL_ENCODE.BASE64_ENCODE(v_input);
            o_response := UTL_RAW.CAST_TO_VARCHAR2(v_output);
        ELSIF UPPER(i_action) = 'DECODE' THEN
            -- Convert Base64 string to RAW
            v_output := UTL_ENCODE.BASE64_DECODE(v_input);
            o_response := UTL_RAW.CAST_TO_VARCHAR2(v_output);
        ELSE
            o_response := 'Invalid action. Use ENCODE or DECODE.';
        END IF;
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'utility_pkg (BASE64 encoderDecoder): ',
                    o_response => v_response
            );
            o_response := 'Encoder and Decoder error';
    END encoderDecoder;

END utility_pkg;
/

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
    -- Get Verification Code
    PROCEDURE getVerification(
        i_email IN VARCHAR2,
        o_verificationToken OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Verify email
    PROCEDURE verifyEmail(
        i_email IN VARCHAR2,
        i_verificationToken IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Get multifactor token
    PROCEDURE getMultifactor(
        i_email IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        o_multifactorToken OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Verify multifactor
    PROCEDURE verifyMultifactor(
        i_email IN VARCHAR2,
        i_multifactorToken IN VARCHAR2,
        i_inetAddr IN VARCHAR2,
        i_deviceInfo IN VARCHAR2,
        o_securityToken OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- user login
    PROCEDURE login(
        i_email IN VARCHAR2,
        i_password IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        o_multifactorToken OUT VARCHAR2,
        o_username OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Forgot Password
    PROCEDURE forgotPassword(
        i_email IN VARCHAR2,
        o_verificationCode OUT VARCHAR2,
        o_username OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Reset Password
    PROCEDURE resetPassword(
        i_email IN VARCHAR2,
        i_verificationToken IN VARCHAR2,
        i_password IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Logout
    PROCEDURE logout(
        i_email IN VARCHAR2,
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
    -- Get Verification Code
    PROCEDURE getVerification(
        i_email IN VARCHAR2,
        o_verificationToken OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_username     VARCHAR2(100);
        v_exists       NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_exists
        FROM verification_tbl
        WHERE email = i_email;
        SELECT username
        INTO v_username
        FROM credentials_tbl
        WHERE email = i_email;
        IF v_exists = 1 THEN
            UPDATE verification_tbl
            SET issuedAt   = SYSTIMESTAMP,
                modifiedBy = v_username
            WHERE email = i_email
            RETURNING verificationToken INTO o_verificationToken;
        ELSE
            INSERT INTO verification_tbl(email, modifiedBy)
            VALUES (i_email, v_username)
            RETURNING verificationToken INTO o_verificationToken;
        END IF;
        utility_pkg.audit(i_email, 'VERIFICATION REQUESTED', 'Verification code was successfully requested');
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(SQLCODE, v_errorMessage, 'auth_pkg (GET VERIFICATION CODE): ' || i_email,
                                      v_response);
            o_response := 'verification unsuccessful';
    END getVerification;

    -- Verify email
    PROCEDURE verifyEmail(
        i_email IN VARCHAR2,
        i_verificationToken IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_username     VARCHAR2(100);
    BEGIN
        SELECT username
        INTO v_username
        FROM credentials_tbl a
                 JOIN verification_tbl m ON a.email = m.email
        WHERE a.email = i_email
          AND m.verificationToken = i_verificationToken
          AND m.usedFlag = 'N'
          AND m.expiresAt >= SYSTIMESTAMP;
        UPDATE credentials_tbl
        SET emailVerified = 'Y',
            accountStatus = 'Active',
            modifiedBy    = v_username
        WHERE email = i_email;
        utility_pkg.audit(i_email, 'EMAIL VERIFIED', 'User verified email successfully');
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(SQLCODE, v_errorMessage, 'auth_pkg (CONFIRM EMAIL): ' || i_email, v_response);
            o_response := 'invalid or expired verification code';
    END verifyEmail;

    -- Get multifactor token
    PROCEDURE getMultifactor(
        i_email IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        o_multifactorToken OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_username     VARCHAR2(100);
        v_exists       NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_exists
        FROM multifactor_tbl
        WHERE email = i_email;
        SELECT username
        INTO v_username
        FROM credentials_tbl
        WHERE email = i_email;
        IF v_exists = 1 THEN
            UPDATE multifactor_tbl
            SET inetAddr   = i_inet,
                deviceInfo = i_device,
                modifiedBy = v_username
            WHERE email = i_email
            RETURNING multifactorToken INTO o_multifactorToken;
        ELSE
            INSERT INTO multifactor_tbl(email, inetAddr, deviceInfo, modifiedBy)
            VALUES (i_email, i_inet, i_device, v_username)
            RETURNING multifactorToken INTO o_multifactorToken;
        END IF;
        utility_pkg.audit(i_email, 'MULTIFACTOR REQUEST', 'Multifactor token was successfully requested');
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(SQLCODE, v_errorMessage, 'auth_pkg (GET MFA): ' || i_email, v_response);
            o_response := 'MFA unsuccessful';
    END getMultifactor;

    -- Verify multifactor
    PROCEDURE verifyMultifactor(
        i_email IN VARCHAR2,
        i_multifactorToken IN VARCHAR2,
        i_inetAddr IN VARCHAR2,
        i_deviceInfo IN VARCHAR2,
        o_securityToken OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_username     VARCHAR2(100);
    BEGIN
        SELECT username
        INTO v_username
        FROM credentials_tbl a
                 JOIN multifactor_tbl m ON a.email = m.email
        WHERE a.email = i_email
          AND m.multifactorToken = i_multifactorToken;
        UPDATE multifactor_tbl
        SET multifactorStatus = 'Y',
            inetAddr          = i_inetAddr,
            deviceInfo        = i_deviceInfo,
            modifiedBy        = v_username
        WHERE email = i_email;
        UPDATE credentials_tbl
        SET lastLogin  = SYSTIMESTAMP,
            modifiedBy = v_username
        WHERE email = i_email
        RETURNING securityToken INTO o_securityToken;
        utility_pkg.audit(i_email, 'CONFIRM MULTIFACTOR', 'User successfully confirmed MFA');
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(SQLCODE, v_errorMessage, 'auth_pkg (CONFIRM MULTIFACTOR): ' || i_email,
                                      v_response);
            o_response := 'invalid or expired multifactor token';
    END verifyMultifactor;

    -- user login
    PROCEDURE login(
        i_email IN VARCHAR2,
        i_password IN VARCHAR2,
        i_inet IN VARCHAR2,
        i_device IN VARCHAR2,
        o_multifactorToken OUT VARCHAR2,
        o_username OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_verify       VARCHAR2(20);
        v_password     VARCHAR2(400);
        v_status       VARCHAR2(50);
    BEGIN
        SELECT username, password, emailVerified, accountStatus
        INTO o_username, v_password, v_verify, v_status
        FROM credentials_tbl
        WHERE email = i_email;
        IF v_status != 'Active' THEN
            utility_pkg.audit(i_email, 'FAILED LOGIN', 'Account locked');
            o_response := 'account locked';
        ELSIF enc_dec.decrypt(utl_raw.cast_to_varchar2(utl_encode.base64_decode(v_password))) != i_password THEN
            UPDATE credentials_tbl
            SET failedLogin = NVL(failedLogin, 0) + 1,
                modifiedBy  = o_username
            WHERE email = i_email;
            utility_pkg.audit(i_email, 'FAILED LOGIN', 'Failed password');
            o_response := 'invalid credentials';
        ELSE
            UPDATE credentials_tbl
            SET activeFlag  = 'Y',
                failedLogin = 0,
                modifiedBy  = o_username
            WHERE email = i_email;
            getMultifactor(i_email, i_inet, i_device, o_multifactorToken, o_response);
            utility_pkg.audit(i_email, 'MFA ISSUED', 'MFA code issued (login step)');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(SQLCODE, v_errorMessage, 'auth_pkg (RESET PASSWORD): ' || i_email, v_response);
            o_response := 'invalid credentials';
    END login;

    -- Forgot Password
    PROCEDURE forgotPassword(
        i_email IN VARCHAR2,
        o_verificationCode OUT VARCHAR2,
        o_username OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_count        NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM credentials_tbl WHERE email = i_email;
        IF v_count = 1 THEN
            UPDATE credentials_tbl
            SET accountStatus = 'Locked'
            WHERE email = i_email
            RETURNING username INTO o_username;
            -- Generate and return authentication token
            getVerification(i_email, o_verificationCode, o_response);
            -- insert records for audit purpose
            utility_pkg.audit(i_email, 'FORGOT PASSWORD', 'Verification code issued for forget password');
            o_response := 'success';
        ELSE
            o_response := 'invalid email';
        END IF;
    EXCEPTION
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

    -- Reset Password
    PROCEDURE resetPassword(
        i_email IN VARCHAR2,
        i_verificationToken IN VARCHAR2,
        i_password IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_username     VARCHAR2(100);
        v_count        NUMBER;
    BEGIN
        -- Fetch authentication details and status
        SELECT username, COUNT(*) INTO v_username, v_count FROM credentials_tbl WHERE email = i_email GROUP BY username;
        IF v_count = 1 THEN
            UPDATE verification_tbl
            SET usedFlag   = 'Y',
                modifiedBy = v_username
            WHERE email = i_email
              AND verificationToken = i_verificationToken;
            UPDATE credentials_tbl
            SET password      = utl_encode.base64_encode(utl_raw.cast_to_raw(enc_dec.encrypt(i_password))),
                modifiedBy    = v_username,
                accountStatus = 'Active'
            WHERE email = i_email;
            -- insert records for audit purpose
            utility_pkg.audit(i_email, 'PASSWORD RESET', 'Password reset via verification code');
            o_response := 'success';
        ELSE
            o_response := 'invalid credentials';
        END IF;
    EXCEPTION
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

    -- Logout
    PROCEDURE logout(
        i_email IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_username     VARCHAR2(100);
    BEGIN
        SELECT username INTO v_username FROM credentials_tbl WHERE email = i_email AND activeFlag = 'Y';
        UPDATE credentials_tbl
        SET activeFlag = 'N',
            modifiedBy = v_username
        WHERE email = i_email
          AND activeFlag = 'Y';
        -- insert records for audit purpose
        utility_pkg.audit(i_email, 'LOGOUT', 'User logout successfully');
        o_response := 'success';
    EXCEPTION
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
    END logout;

END auth_pkg;
/

PROMPT "Creating Package Header"
--------------------------------------------------------------
-- PACKAGE: Creating account header package
--------------------------------------------------------------
-- Create Header Package
CREATE OR REPLACE PACKAGE account_pkg
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
    Name: account_pkg
    Program Type: Package Specification
    Purpose: ADD/FIND/UPDATE/DELETE entity
    =================================================================================
    HISTORY
    =================================================================================
    | DATE 		| Owner 	| Activity
    =================================================================================
    | 28-OCT-25	| eomisore 	| Created initial script.|
    =================================================================================
    | 28-OCT-25	| eomisore 	| Add extra feature such as delete, update.|
    =================================================================================
    */
    -- Create user account also known as signup
    PROCEDURE createAccount(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_password IN VARCHAR2,
        o_securityToken OUT VARCHAR2,
        o_verificationToken OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Delete user account
    PROCEDURE deleteAccount(
        i_email IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Update account password and username
    PROCEDURE updateAccount(
        i_email IN VARCHAR2,
        i_username IN VARCHAR2,
        i_oldpassword IN VARCHAR2,
        i_newpassword IN VARCHAR2,
        o_securityToken OUT VARCHAR2,
        o_response OUT VARCHAR2);

END account_pkg;
/

PROMPT "Creating Package Body"
--------------------------------------------------------------
-- PACKAGE: Creating authentication body package
--------------------------------------------------------------
-- Create Body Package
CREATE OR REPLACE PACKAGE BODY account_pkg
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
    -- Create user account also known as signup
    PROCEDURE createAccount(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_password IN VARCHAR2,
        o_securityToken OUT VARCHAR2,
        o_verificationToken OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_encodedPwd   VARCHAR2(400);
    BEGIN
        v_encodedPwd := UTL_ENCODE.BASE64_ENCODE(UTL_RAW.CAST_TO_RAW(enc_dec.encrypt(i_password)));
        utility_pkg.encoderDecoder('ENCODE',
                                   'username:' || i_username || ',email:' || i_email || ',password:' || i_password,
                                   o_securityToken);
        INSERT INTO credentials_tbl(username, email, password, securityToken, modifiedBy)
        VALUES (i_username, i_email, v_encodedPwd, o_securityToken, i_username);
        auth_pkg.getVerification(i_email, o_verificationToken, v_response);
        -- insert records for audit purpose
        utility_pkg.audit(i_email, 'EMAIL VERIFICATION ISSUED', 'Verification code issued');
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'account_pkg (CREATE ACCOUNT): ' || i_email,
                    o_response => v_response
            );
            o_securityToken := '';
            o_verificationToken := '';
            o_response := 'create account unsuccessful';
    END createAccount;

    -- Delete Account
    PROCEDURE deleteAccount(
        i_email IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        DELETE
        FROM credentials_tbl
        WHERE email = i_email;
        -- insert records for audit purpose
        utility_pkg.audit(i_email, 'DELETE ACCOUNT', 'Successfully delete user Account');
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'account_pkg (DELETE ACCOUNT): ' || i_email,
                    o_response => v_response
            );
            o_response := 'delete account unsuccessful';
    END deleteAccount;

    -- Update account password and username
    PROCEDURE updateAccount(
        i_email IN VARCHAR2,
        i_username IN VARCHAR2,
        i_oldpassword IN VARCHAR2,
        i_newpassword IN VARCHAR2,
        o_securityToken OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_encodedPwd   VARCHAR2(400);
    BEGIN
        v_encodedPwd := UTL_ENCODE.BASE64_ENCODE(UTL_RAW.CAST_TO_RAW(enc_dec.encrypt(i_newpassword)));
        utility_pkg.encoderDecoder('ENCODE',
                                   'username:' || i_username || ',email:' || i_email || ',password:' || i_newpassword,
                                   o_securityToken);
        UPDATE credentials_tbl
        SET username      = i_username,
            password      = v_encodedPwd,
            securityToken = o_securityToken,
            modifiedBy    = i_username
        WHERE email = i_email
          AND enc_dec.decrypt(utl_raw.cast_to_varchar2(utl_encode.base64_decode(password))) = i_oldpassword;
        -- insert records for audit purpose
        utility_pkg.audit(i_email, 'UPDATE ACCOUNT', 'Successfully update user Account');
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'account_pkg (UPDATE ACCOUNT): ' || i_email,
                    o_response => v_response
            );
            o_securityToken := '';
            o_response := 'invalid credentials';
    END updateAccount;

END account_pkg;
/

PROMPT "Creating Package Header"
-------------------------------------------
-- PACKAGE: Creating profile header package
-------------------------------------------
-- Create Header Package
CREATE OR REPLACE PACKAGE profile_pkg
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
    Name: profile_pkg
    Program Type: Package Specification
    Purpose: ADD/FIND/UPDATE/DELETE entity
    =================================================================================
    HISTORY
    =================================================================================
    | DATE 		| Owner 	| Activity
    =================================================================================
    | 10-SEP-25	| eomisore 	| Created initial script.|
    =================================================================================
    | 28-OCT-25	| eomisore 	| Add extra feature such as delete, update.|
    =================================================================================
    */
    -- Find details from the address table
    PROCEDURE getAddress(
        i_email IN VARCHAR2,
        o_addressList OUT SYS_REFCURSOR);

    -- Find details from the contact table
    PROCEDURE getContact(
        i_email IN VARCHAR2,
        o_contactList OUT SYS_REFCURSOR);

    -- Find details from the constellation table
    PROCEDURE getHoroscope(
        i_email IN VARCHAR2,
        o_astrologyList OUT SYS_REFCURSOR);

    -- Find details from the image table
    PROCEDURE getImage(
        i_email IN VARCHAR2,
        o_avatarList OUT SYS_REFCURSOR);

    -- Find details from the person table
    PROCEDURE getPerson(
        i_email IN VARCHAR2,
        o_personList OUT SYS_REFCURSOR);

    -- Find details from the contact table
    PROCEDURE getProfile(
        i_email IN VARCHAR2,
        o_profileList OUT SYS_REFCURSOR);

    -- Find details user details
    PROCEDURE getSilhouette(
        i_email IN VARCHAR2,
        o_personList OUT SYS_REFCURSOR,
        o_avatarList OUT SYS_REFCURSOR,
        o_addressList OUT SYS_REFCURSOR,
        o_contactList OUT SYS_REFCURSOR,
        o_profileList OUT SYS_REFCURSOR,
        o_astrologyList OUT SYS_REFCURSOR);

    -- Delete the address record
    PROCEDURE removeAddress(
        i_email IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Delete the contact record
    PROCEDURE removeContact(
        i_email IN VARCHAR2,
        i_channel IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Delete the image record
    PROCEDURE removeImage(
        i_email IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Delete the person record
    PROCEDURE removePerson(
        i_email IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Delete the profile record
    PROCEDURE removeProfile(
        i_email IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Save the address record
    PROCEDURE saveAddress(
        i_email IN VARCHAR2,
        i_firstline IN VARCHAR2,
        i_secondline IN VARCHAR2,
        i_thirdline IN VARCHAR2,
        i_city IN VARCHAR2,
        i_postcode IN VARCHAR2,
        i_country IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Save the contact record
    PROCEDURE saveContact(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_channel IN VARCHAR2,
        i_address IN VARCHAR2,
        i_consent IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Update constellation table
    PROCEDURE saveHoroscope(
        i_zodiacSign IN VARCHAR2,
        i_currentDay IN VARCHAR2,
        i_narrative IN VARCHAR2,
        i_modifiedBy IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Create or Update Identity
    PROCEDURE saveImage(
        i_email IN VARCHAR2,
        i_avatar IN BLOB,
        o_response OUT VARCHAR2);

    -- Save the Person record
    PROCEDURE savePerson(
        i_email IN VARCHAR2,
        i_title IN VARCHAR2,
        i_firstName IN VARCHAR2,
        i_middleName IN VARCHAR2,
        i_lastName IN VARCHAR2,
        i_gender IN VARCHAR2,
        i_birthday IN DATE,
        o_response OUT VARCHAR2);

    -- Create or Update Profile
    PROCEDURE saveProfile(
        i_email IN VARCHAR2,
        i_maritalStatus IN VARCHAR2,
        i_height IN VARCHAR2,
        i_weight IN VARCHAR2,
        i_ethnicity IN VARCHAR2,
        i_religion IN VARCHAR2,
        i_eyeColour IN VARCHAR2,
        i_phenotype IN VARCHAR2,
        i_genotype IN VARCHAR2,
        o_response OUT VARCHAR2);

END profile_pkg;
/

PROMPT "Creating Package Body"
--------------------------------------------------------------
-- PACKAGE: Creating authentication body package
--------------------------------------------------------------
-- Create Body Package
CREATE OR REPLACE PACKAGE BODY profile_pkg
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
    Name: profile_pkg
    Program Type: Package Specification
    Purpose: ADD/FIND/UPDATE/DELETE entity
    =================================================================================
    HISTORY
    =================================================================================
    | DATE 		| Owner 	| Activity
    =================================================================================
    | 10-SEP-25	| eomisore 	| Created initial script.|
    =================================================================================
    | 12-OCT-25	| eomisore 	| Add extra feature such as delete, update.|
    =================================================================================
    */
    -- Find details from the address table
    PROCEDURE getAddress(
        i_email IN VARCHAR2,
        o_addressList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        OPEN o_addressList FOR
            SELECT *
            FROM address_tbl
            WHERE email = i_email;
        -- insert records for audit purpose
        utility_pkg.audit(i_email, 'ADDRESS REQUEST', 'Address was successfully requested');
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (GETADDRESS): ' || i_email,
                    o_response => v_response
            );
    END getAddress;

    -- Find details from the contact table
    PROCEDURE getContact(
        i_email IN VARCHAR2,
        o_contactList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        OPEN o_contactList FOR
            SELECT *
            FROM contact_tbl
            WHERE email = i_email;
        -- insert records for audit purpose
        utility_pkg.audit(i_email, 'CONTACT REQUEST', 'Contact was successfully requested');
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (GETCONTACT): ' || i_email,
                    o_response => v_response
            );
    END getContact;

    -- Find details from the constellation table
    PROCEDURE getHoroscope(
        i_email IN VARCHAR2,
        o_astrologyList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_zodiacSign   VARCHAR2(100);
    BEGIN
        SELECT zodiacSign
        INTO v_zodiacSign
        FROM person_tbl
        WHERE email = i_email;
        OPEN o_astrologyList FOR
            SELECT *
            FROM horoscope_tbl
            WHERE zodiacSign = v_zodiacSign;
        -- insert records for audit purpose
        utility_pkg.audit(i_email, 'HOROSCOPE REQUEST', 'Horoscope was successfully requested');
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (GETHOROSCOPE): ' || i_email,
                    o_response => v_response
            );
    END getHoroscope;

    -- Find details from the image table
    PROCEDURE getImage(
        i_email IN VARCHAR2,
        o_avatarList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        OPEN o_avatarList FOR
            SELECT *
            FROM images_tbl
            WHERE email = i_email;
        -- insert records for audit purpose
        utility_pkg.audit(i_email, 'IMAGE REQUEST', 'Image was successfully requested');
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (GETIMAGE): ' || i_email,
                    o_response => v_response
            );
    END getImage;

    -- Find details from the person table
    PROCEDURE getPerson(
        i_email IN VARCHAR2,
        o_personList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        OPEN o_personList FOR
            SELECT *
            FROM person_tbl
            WHERE email = i_email;
        -- insert records for audit purpose
        utility_pkg.audit(i_email, 'PERSON REQUEST', 'Person record was successfully requested');
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (GETPERSON): ' || i_email,
                    o_response => v_response
            );
    END getPerson;

    -- Find details from the contact table
    PROCEDURE getProfile(
        i_email IN VARCHAR2,
        o_profileList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        OPEN o_profileList FOR
            SELECT *
            FROM profile_tbl
            WHERE email = i_email;
        -- insert records for audit purpose
        utility_pkg.audit(i_email, 'PROFILE REQUEST', 'Profile was successfully requested');
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (GETPROFILE): ' || i_email,
                    o_response => v_response
            );
    END getProfile;

    -- Find details user details
    PROCEDURE getSilhouette(
        i_email IN VARCHAR2,
        o_personList OUT SYS_REFCURSOR,
        o_avatarList OUT SYS_REFCURSOR,
        o_addressList OUT SYS_REFCURSOR,
        o_contactList OUT SYS_REFCURSOR,
        o_profileList OUT SYS_REFCURSOR,
        o_astrologyList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_zodiacSign   VARCHAR2(100);
    BEGIN
        -- Person
        OPEN o_personList FOR SELECT * FROM person_tbl WHERE email = i_email;
        -- Avatar
        OPEN o_avatarList FOR SELECT * FROM images_tbl WHERE email = i_email;
        -- Address
        OPEN o_addressList FOR SELECT * FROM address_tbl WHERE email = i_email;
        -- Contact (multiple rows possible)
        OPEN o_contactList FOR SELECT * FROM contact_tbl WHERE email = i_email;
        -- Profile
        OPEN o_profileList FOR SELECT * FROM profile_tbl WHERE email = i_email;
        -- Horoscope (first find zodiac sign)
        SELECT zodiacSign INTO v_zodiacSign FROM person_tbl WHERE email = i_email;
        OPEN o_astrologyList FOR SELECT * FROM horoscope_tbl WHERE zodiacSign = v_zodiacSign;
        -- insert records for audit purpose
        utility_pkg.audit(i_email, 'SILHOUETTE REQUEST', 'Silhouette was successfully requested');
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice=> 'profile_pkg (GETSILHOUETTE): ' || i_email,
                    o_response => v_response
            );
    END getSilhouette;

    -- Delete the address record
    PROCEDURE removeAddress(
        i_email IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_count        NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM address_tbl WHERE email = i_email;
        IF v_count = 1 THEN
            DELETE FROM address_tbl WHERE email = i_email;
            -- insert records for audit purpose
            utility_pkg.audit(i_email, 'DELETE ADDRESS', 'Address was successfully removed');
            o_response := 'success';
        ELSE
            o_response := 'invalid credentials';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (DELETE ADDRESS): ' || i_email,
                    o_response => v_response
            );
    END removeAddress;

    -- Delete the contact record
    PROCEDURE removeContact(
        i_email IN VARCHAR2,
        i_channel IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_count        NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM contact_tbl WHERE email = i_email AND channel = i_channel;
        IF v_count = 1 THEN
            DELETE FROM contact_tbl WHERE email = i_email AND channel = i_channel;
            -- insert records for audit purpose
            utility_pkg.audit(i_email, 'DELETE CONTACT', 'Contact was successfully removed');
            o_response := 'success';
        ELSE
            o_response := 'invalid credentials';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (DELETE CONTACT): ' || i_email,
                    o_response => v_response
            );
    END removeContact;

    -- Delete the image record
    PROCEDURE removeImage(
        i_email IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_count        NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM images_tbl WHERE email = i_email;
        IF v_count = 1 THEN
            DELETE FROM images_tbl WHERE email = i_email;
            -- insert records for audit purpose
            utility_pkg.audit(i_email, 'DELETE IMAGE', 'Image was successfully removed');
            o_response := 'success';
        ELSE
            o_response := 'invalid credentials';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (DELETE IMAGE): ' || i_email,
                    o_response => v_response
            );
    END removeImage;

    -- Delete the person record
    PROCEDURE removePerson(
        i_email IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_count        NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM person_tbl WHERE email = i_email;
        IF v_count = 1 THEN
            DELETE FROM person_tbl WHERE email = i_email;
            -- insert records for audit purpose
            utility_pkg.audit(i_email, 'DELETE PERSON', 'Person was successfully removed');
            o_response := 'success';
        ELSE
            o_response := 'invalid credentials';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (DELETE PERSON): ' || i_email,
                    o_response => v_response
            );
    END removePerson;

    -- Delete the profile record
    PROCEDURE removeProfile(
        i_email IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_count        NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM profile_tbl WHERE email = i_email;
        IF v_count = 1 THEN
            DELETE FROM profile_tbl WHERE email = i_email;
            -- insert records for audit purpose
            utility_pkg.audit(i_email, 'DELETE PROFILE', 'Profile was successfully removed');
            o_response := 'success';
        ELSE
            o_response := 'invalid credentials';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (DELETE PROFILE): ' || i_email,
                    o_response => v_response
            );
    END removeProfile;

    -- Save or update the address record
    PROCEDURE saveAddress(
        i_email IN VARCHAR2,
        i_firstline IN VARCHAR2,
        i_secondline IN VARCHAR2,
        i_thirdline IN VARCHAR2,
        i_city IN VARCHAR2,
        i_postcode IN VARCHAR2,
        i_country IN VARCHAR2,
        o_response OUT VARCHAR2
    )
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_username     VARCHAR2(100);
    BEGIN
        -- Retrieve username associated with the email
        SELECT a.username
        INTO v_username
        FROM credentials_tbl a
        WHERE a.email = i_email;
        -- Merge address record (update if exists, insert if not)
        MERGE INTO address_tbl tgt
        USING (SELECT i_email AS email FROM dual) src
        ON (tgt.email = src.email)
        WHEN MATCHED THEN
            UPDATE
            SET tgt.firstline  = i_firstline,
                tgt.secondline = i_secondline,
                tgt.thirdline  = i_thirdline,
                tgt.city       = i_city,
                tgt.postcode   = i_postcode,
                tgt.country    = i_country,
                tgt.modifiedBy = v_username
        WHEN NOT MATCHED THEN
            INSERT (email, firstline, secondline, thirdline, city, postcode, country, modifiedBy)
            VALUES (i_email, i_firstline, i_secondline, i_thirdline, i_city, i_postcode, i_country, v_username);
        -- Audit the save operation
        utility_pkg.audit(i_email, 'ADDRESS SAVED', 'Address was successfully saved');
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (SAVE ADDRESS): ' || i_email,
                    o_response => v_response
            );
            o_response := 'address unsuccessful';
    END saveAddress;

    PROCEDURE saveContact(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_channel IN VARCHAR2,
        i_address IN VARCHAR2,
        i_consent IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
    BEGIN
        MERGE INTO contact_tbl tgt
        USING (SELECT i_email AS email, i_channel AS channel FROM dual) src
        ON (tgt.email = src.email AND tgt.channel = src.channel)
        WHEN MATCHED THEN
            UPDATE
            SET address    = i_address,
                consent    = i_consent,
                modifiedBy = i_username
        WHEN NOT MATCHED THEN
            INSERT (email, channel, address, consent, modifiedBy)
            VALUES (i_email, i_channel, i_address, i_consent, i_username);
        utility_pkg.audit(i_email, 'CONTACT SAVED', 'Contact was successfully saved');
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(SQLCODE, v_errorMessage, 'profile_pkg (SAVE CONTACT): ' || i_email, o_response);
            o_response := 'contact unsuccessful';
    END saveContact;

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
        UPDATE horoscope_tbl
        SET zodiacSign = i_zodiacSign,
            currentDay = i_currentDay,
            narrative  = i_narrative,
            modifiedBy = i_modifiedBy
        WHERE zodiacSign = i_zodiacSign;
        IF SQL%NOTFOUND THEN
            INSERT INTO horoscope_tbl(zodiacSign, currentDay, narrative, modifiedBy)
            VALUES (i_zodiacSign, i_currentDay, i_narrative, i_modifiedBy);
        END IF;
        o_response := 'Success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (SAVE HOROSCOPE): ' || i_zodiacSign,
                    o_response => v_response
            );
            o_response := 'horoscope unsuccessful';
    END saveHoroscope;

    PROCEDURE saveImage(
        i_email IN VARCHAR2,
        i_avatar IN BLOB,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_username     VARCHAR2(100);
    BEGIN
        SELECT username
        INTO v_username
        FROM credentials_tbl
        WHERE email = i_email;
        MERGE INTO images_tbl tgt
        USING (SELECT i_email AS email FROM dual) src
        ON (tgt.email = src.email)
        WHEN MATCHED THEN
            UPDATE
            SET avatar     = i_avatar,
                modifiedBy = v_username
        WHEN NOT MATCHED THEN
            INSERT (email, avatar, modifiedBy)
            VALUES (i_email, i_avatar, v_username);
        utility_pkg.audit(i_email, 'IMAGE SAVED', 'Image was successfully saved');
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(SQLCODE, v_errorMessage, 'profile_pkg (SAVE IMAGE): ' || i_email, o_response);
            o_response := 'images unsuccessful';
    END saveImage;

    PROCEDURE savePerson(
        i_email IN VARCHAR2,
        i_title IN VARCHAR2,
        i_firstName IN VARCHAR2,
        i_middleName IN VARCHAR2,
        i_lastName IN VARCHAR2,
        i_gender IN VARCHAR2,
        i_birthday IN DATE,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_username     VARCHAR2(100);
    BEGIN
        SELECT username
        INTO v_username
        FROM credentials_tbl
        WHERE email = i_email;
        MERGE INTO person_tbl tgt
        USING (SELECT i_email AS email FROM dual) src
        ON (tgt.email = src.email)
        WHEN MATCHED THEN
            UPDATE
            SET title      = i_title,
                firstName  = i_firstName,
                middleName = i_middleName,
                lastName   = i_lastName,
                gender     = i_gender,
                birthday   = i_birthday,
                modifiedBy = v_username
        WHEN NOT MATCHED THEN
            INSERT (email, title, firstName, middleName, lastName, gender, birthday, modifiedBy)
            VALUES (i_email, i_title, i_firstName, i_middleName, i_lastName, i_gender, i_birthday, v_username);
        utility_pkg.audit(i_email, 'PERSON SAVED', 'Person record was successfully saved');
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(SQLCODE, v_errorMessage, 'profile_pkg (SAVE PERSON): ' || i_email, o_response);
            o_response := 'person unsuccessful';
    END savePerson;

    PROCEDURE saveProfile(
        i_email IN VARCHAR2,
        i_maritalStatus IN VARCHAR2,
        i_height IN VARCHAR2,
        i_weight IN VARCHAR2,
        i_ethnicity IN VARCHAR2,
        i_religion IN VARCHAR2,
        i_eyeColour IN VARCHAR2,
        i_phenotype IN VARCHAR2,
        i_genotype IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_username     VARCHAR2(100);
    BEGIN
        SELECT username
        INTO v_username
        FROM credentials_tbl
        WHERE email = i_email;
        MERGE INTO profile_tbl tgt
        USING (SELECT i_email AS email FROM dual) src
        ON (tgt.email = src.email)
        WHEN MATCHED THEN
            UPDATE
            SET maritalStatus = i_maritalStatus,
                height        = i_height,
                weight        = i_weight,
                ethnicity     = i_ethnicity,
                religion      = i_religion,
                eyeColour     = i_eyeColour,
                phenotype     = i_phenotype,
                genotype      = i_genotype,
                modifiedBy    = v_username
        WHEN NOT MATCHED THEN
            INSERT (email, maritalStatus, height, weight, ethnicity, religion, eyeColour, phenotype, genotype,
                    modifiedBy)
            VALUES (i_email, i_maritalStatus, i_height, i_weight, i_ethnicity, i_religion, i_eyeColour, i_phenotype,
                    i_genotype, v_username);
        utility_pkg.audit(i_email, 'PROFILE SAVED', 'Profile was successfully saved');
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(SQLCODE, v_errorMessage, 'profile_pkg (SAVE PROFILE): ' || i_email, o_response);
            o_response := 'profile unsuccessful';
    END saveProfile;

END profile_pkg;
/

SHOW ERRORS
/

PROMPT "End of creating Account Schema"