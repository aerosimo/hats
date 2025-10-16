PROMPT "Creating profile schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      profile.sql                                                     *
 * Created:   10/09/2025, 19:10                                               *
 * Modified:  10/09/2025, 19:11                                               *
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
-- TABLES creating the required tables for profile
---------------------------------------------------------

CREATE TABLE images_tbl
(
    username        VARCHAR2(200 BYTE) NOT NULL,
    email           VARCHAR2(200 BYTE),
    avatar          BLOB,
    modifiedBy      VARCHAR2(100 BYTE),
    modifiedDate    TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

CREATE TABLE person_tbl
(
    username        VARCHAR2(200 BYTE) NOT NULL,
    email           VARCHAR2(200 BYTE),
    title           VARCHAR2(50 BYTE),
    firstName       VARCHAR2(100 BYTE),
    middleName      VARCHAR2(100 BYTE),
    lastName        VARCHAR2(100 BYTE),
    zodiacSign      VARCHAR2(20 BYTE),
    gender          VARCHAR2(30 BYTE),
    birthday        DATE,
    age             VARCHAR2(10 BYTE),
    modifiedBy      VARCHAR2(100 BYTE),
    modifiedDate    TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

CREATE TABLE address_tbl
(
    username        VARCHAR2(200 BYTE) NOT NULL,
    email           VARCHAR2(200 BYTE),
    firstline       VARCHAR2(100 BYTE),
    secondline      VARCHAR2(100 BYTE),
    thirdline       VARCHAR2(100 BYTE),
    city            VARCHAR2(100 BYTE),
    postcode        VARCHAR2(20 BYTE),
    country         VARCHAR2(100 BYTE),
    modifiedBy      VARCHAR2(100 BYTE),
    modifiedDate    TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

CREATE TABLE contact_tbl
(
    username        VARCHAR2(200 BYTE) NOT NULL,
    email           VARCHAR2(200 BYTE),
    channel         VARCHAR2(40 BYTE),
    address         VARCHAR2(100 BYTE),
    consent         VARCHAR2(10 BYTE) DEFAULT 'YES',
    modifiedBy      VARCHAR2(100 BYTE),
    modifiedDate    TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

CREATE TABLE profile_tbl
(
    username        VARCHAR2(200 BYTE) NOT NULL,
    email           VARCHAR2(200 BYTE),
    maritalStatus   VARCHAR2(50 BYTE),
    height          VARCHAR2(20 BYTE),
    weight          VARCHAR2(20 BYTE),
    ethnicity       VARCHAR2(50 BYTE),
    religion        VARCHAR2(50 BYTE),
    eyeColour       VARCHAR2(20 BYTE),
    phenotype       VARCHAR2(50 BYTE),
    genotype        VARCHAR2(50 BYTE),
    disability      VARCHAR2(50 BYTE),
    modifiedBy      VARCHAR2(100 BYTE),
    modifiedDate    TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

CREATE TABLE horoscope_tbl
(
    zodiacSign      VARCHAR2(20 BYTE),
    currentDay      VARCHAR2(50 BYTE),
    narrative       VARCHAR2(4000 BYTE),
    modifiedBy      VARCHAR2(100 BYTE),
    modifiedDate    TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

PROMPT "Setting Constraints"
------------------------------------------------------------
-- CONSTRAINTS / CHECKS creating the constraints and checks
------------------------------------------------------------

-- Setting Unique Key
ALTER TABLE horoscope_tbl ADD CONSTRAINT zodiacSign_unq UNIQUE (zodiacSign);
ALTER TABLE profile_tbl ADD CONSTRAINT profile_unq UNIQUE (email);

-- Setting Foreign Key
ALTER TABLE images_tbl ADD CONSTRAINT images_fk FOREIGN KEY (email) REFERENCES authentication_tbl (email) ON DELETE CASCADE;
ALTER TABLE person_tbl ADD CONSTRAINT person_fk FOREIGN KEY (email) REFERENCES authentication_tbl (email) ON DELETE CASCADE;
ALTER TABLE address_tbl ADD CONSTRAINT address_fk FOREIGN KEY (email) REFERENCES authentication_tbl (email) ON DELETE CASCADE;
ALTER TABLE contact_tbl ADD CONSTRAINT contact_fk FOREIGN KEY (email) REFERENCES authentication_tbl (email) ON DELETE CASCADE;
ALTER TABLE profile_tbl ADD CONSTRAINT profile_fk FOREIGN KEY (email) REFERENCES authentication_tbl (email) ON DELETE CASCADE;
ALTER TABLE person_tbl ADD CONSTRAINT zodiac_fk FOREIGN KEY (zodiacSign) REFERENCES horoscope_tbl (zodiacSign);

-- Setting Check Constraint
ALTER TABLE person_tbl
    ADD CONSTRAINT pertit_chk CHECK (title IN ('Mr', 'Mrs', 'Miss', 'Dr', 'Ms', 'Professor',
                                               'Reverend', 'Lady', 'Sir', 'Capt', 'Major',
                                               'Hon', 'Judge', 'Lord', 'Dame', 'Rear Admiral',
                                               'Herr', 'Monsieur', 'Vice Admiral', 'Frau',
                                               'Admiral', 'Commodore', 'Alhaji', 'Alhaja',
                                               'Alderman', 'Ambassador', 'Baron', 'Baroness',
                                               'Brigadier', 'Cardinal', 'Chief', 'Colonel',
                                               'Commander', 'Commissioner', 'Congressman',
                                               'Conseiller', 'Consul', 'Corporal', 'Councillor',
                                               'Countess', 'Prince', 'Princess', 'Datuk',
                                               'Deacon', 'Deaconess', 'Dean', 'Eng', 'Lieutient',
                                               'Officer', 'Governor', 'General', 'Her Highness',
                                               'Her Majesty', 'His Highness', 'His Holiness',
                                               'His Majesty', 'Justice', 'Madame', 'Mademoiselle',
                                               'Master', 'Pastor', 'President', 'Rabbi', 'Senator',
                                               'Sergeant', 'Sheikh', 'Sheikha', 'Sultan',
                                               'Viscount', 'Viscountess')) ENABLE;
ALTER TABLE person_tbl ADD CONSTRAINT pergen_chk CHECK (gender IN ('Male', 'Female')) ENABLE;
ALTER TABLE contact_tbl ADD CONSTRAINT channel_chk CHECK (channel IN ('Phone', 'Email', 'Fax', 'Twitter', 'Facebook', 'LinkedIn', 'Snapchat', 'Website')) ENABLE;
ALTER TABLE contact_tbl ADD CONSTRAINT consent_chk CHECK (consent IN ('YES', 'NO')) ENABLE;
ALTER TABLE profile_tbl ADD CONSTRAINT maritalStatus_Chk CHECK (maritalStatus IN ('Separated', 'Widowed', 'Single', 'Married', 'Lone', 'Live-in', 'Estranged', 'EngAged', 'Divorced', 'De Facto', 'Common Law')) ENABLE;
ALTER TABLE profile_tbl ADD CONSTRAINT genotype_Chk CHECK (genotype IN ('AA', 'AS', 'SS', 'AC')) ENABLE;
ALTER TABLE profile_tbl ADD CONSTRAINT phenotype_Chk CHECK (phenotype IN ('A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-')) ENABLE;
ALTER TABLE profile_tbl ADD CONSTRAINT religion_Chk CHECK (religion IN ('Christianity', 'Islam', 'Atheist', 'Hinduism', 'Buddhism', 'Sikhism', 'Judaism')) ENABLE;
ALTER TABLE profile_tbl ADD CONSTRAINT disability_Chk CHECK (disability IN ('Spina Bifida', 'Spinal Cord Injury',
                                                        'Amputation', 'Diabetes',
                                                        'Chronic Fatigue Syndrome', 'Carpal Tunnel',
                                                        'Arthritis', 'Learning Disability',
                                                        'Traumatic Brain Injury', 'AD/HD', 'Depression',
                                                        'Bipolar Disorder', 'Schizophrenia',
                                                        'Eating Disorder', 'Anxiety',
                                                        'Post Traumatic Stress Disorder', 'Blindness',
                                                        'Deafness', 'Visual Impairment',
                                                        'Hard Of Hearing', 'None')) ENABLE;
ALTER TABLE profile_tbl ADD CONSTRAINT eyeColour_Chk CHECK (eyeColour IN ('Amber', 'Blue', 'Brown', 'Grey', 'Green','Hazel', 'Red', 'Violet')) ENABLE;
ALTER TABLE profile_tbl ADD CONSTRAINT ethnicity_Chk CHECK (ethnicity IN ('Indian', 'Pakistani', 'Bangladeshi',
                                                      'Caribbean', 'African', 'Chinese', 'Arab',
                                                      'British', 'Irish',
                                                      'Any other White background',
                                                      'Any other mixed background',
                                                      'White and Asian', 'White and Black African',
                                                      'White and Black Caribbean',
                                                      'Any other Asian background',
                                                      'Any other Black background',
                                                      'Any other ethnic group')) ENABLE;
ALTER TABLE horoscope_tbl ADD CONSTRAINT zodiacSign_chk CHECK (zodiacSign IN ('Aries', 'Taurus', 'Gemini','Cancer', 'Leo', 'Virgo','Libra', 'Scorpio', 'Sagittarius','Capricorn', 'Aquarius', 'Pisces')) ENABLE;

-- Create history tables
CREATE TABLE person_history_tbl AS SELECT * FROM person_tbl WHERE 1 = 0;
CREATE TABLE address_history_tbl AS SELECT * FROM address_tbl WHERE 1 = 0;
CREATE TABLE images_history_tbl AS SELECT * FROM images_tbl WHERE 1 = 0;
CREATE TABLE contact_history_tbl AS SELECT * FROM contact_tbl WHERE 1 = 0;
CREATE TABLE profile_history_tbl AS SELECT * FROM profile_tbl WHERE 1 = 0;
CREATE TABLE horoscope_history_tbl AS SELECT * FROM horoscope_tbl WHERE 1 = 0;

ALTER TABLE person_history_tbl ADD modifiedReason VARCHAR2(200);
ALTER TABLE person_history_tbl ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE address_history_tbl ADD modifiedReason VARCHAR2(200);
ALTER TABLE address_history_tbl ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE images_history_tbl ADD modifiedReason VARCHAR2(200);
ALTER TABLE images_history_tbl ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE contact_history_tbl ADD modifiedReason VARCHAR2(200);
ALTER TABLE contact_history_tbl ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE profile_history_tbl ADD modifiedReason VARCHAR2(200);
ALTER TABLE profile_history_tbl ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;
ALTER TABLE horoscope_history_tbl ADD modifiedReason VARCHAR2(200);
ALTER TABLE horoscope_history_tbl ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;

PROMPT "Commenting Tables"
---------------------------------------------------------------------
-- COMMENTS for clarity (shorter and clearer)
---------------------------------------------------------------------
COMMENT ON COLUMN images_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN images_tbl.email IS 'The account identifier for an image';
COMMENT ON COLUMN images_tbl.avatar IS 'This is user avatar image';
COMMENT ON COLUMN images_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN images_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE images_tbl IS 'A user image which is a visual representation of the user is stored here.';

COMMENT ON COLUMN images_history_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN images_history_tbl.email IS 'The account identifier for an image';
COMMENT ON COLUMN images_history_tbl.avatar IS 'This is user avatar image';
COMMENT ON COLUMN images_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN images_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN images_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN images_history_tbl.archivedDate IS 'Audit column - date of it was archived.';
COMMENT ON TABLE images_history_tbl IS 'A user image which is a visual representation of the user is stored here.';

COMMENT ON COLUMN person_tbl.username IS 'This is contact username this could be an alias';
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

COMMENT ON COLUMN person_history_tbl.username IS 'This is contact username this could be an alias';
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

COMMENT ON COLUMN address_tbl.username IS 'This is contact username this could be an alias';
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

COMMENT ON COLUMN address_history_tbl.username IS 'This is contact username this could be an alias';
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

COMMENT ON COLUMN contact_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN contact_tbl.email IS 'The account identifier for a Contact.';
COMMENT ON COLUMN contact_tbl.channel IS 'This will list of available ways of contact. e.g Phone, email, twitter, facebook etc';
COMMENT ON COLUMN contact_tbl.address IS 'This will be the actual contact Address i.e someone@somewhere.com';
COMMENT ON COLUMN contact_tbl.consent IS 'This is an indicator to say if the medium is a prefer mode of contact or not';
COMMENT ON COLUMN contact_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN contact_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE contact_tbl IS 'Profile information for list of contacts';

COMMENT ON COLUMN contact_history_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN contact_history_tbl.email IS 'The account identifier for a Contact.';
COMMENT ON COLUMN contact_history_tbl.channel IS 'This will list of available ways of contact. e.g Phone, email, twitter, facebook etc';
COMMENT ON COLUMN contact_history_tbl.address IS 'This will be the actual contact Address i.e someone@somewhere.com';
COMMENT ON COLUMN contact_history_tbl.consent IS 'This is an indicator to say if the medium is a prefer mode of contact or not';
COMMENT ON COLUMN contact_history_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN contact_history_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON COLUMN contact_history_tbl.modifiedReason IS 'Audit column - indicates the DML operations.';
COMMENT ON COLUMN contact_history_tbl.archivedDate IS 'Audit column - date of it was archived.';
COMMENT ON TABLE contact_history_tbl IS 'Profile information for list of contacts';

COMMENT ON COLUMN profile_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN profile_tbl.email IS 'The account identifier for profile';
COMMENT ON COLUMN profile_tbl.maritalStatus IS 'This is contact''s marital status.';
COMMENT ON COLUMN profile_tbl.height IS 'The measurement of someone or something from head to foot or from base to top. ';
COMMENT ON COLUMN profile_tbl.weight IS 'This is the Weight of a person is usually taken to be the force on the person due to gravity.';
COMMENT ON COLUMN profile_tbl.ethnicity IS 'This is the fact or state of belonging to a social group that has a common national or cultural tradition.';
COMMENT ON COLUMN profile_tbl.religion IS 'The belief in and worship of a superhuman controlling power, especially a personal God or gods.';
COMMENT ON COLUMN profile_tbl.eyeColour IS 'This is a polygenic phenotypic character determined by two distinct factors: pigmentation of the eye and the scattering of light by the turbid medium in the stroma of the iris';
COMMENT ON COLUMN profile_tbl.phenotype IS 'This is a classification of blood based on the presence and absence of antibodies and inherited antigenic substances on the surface of red blood cells.';
COMMENT ON COLUMN profile_tbl.disability IS 'This is indicate if the person is disable or not';
COMMENT ON COLUMN profile_tbl.genotype IS 'This is the genetic constitution of an individual organism.';
COMMENT ON COLUMN profile_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN profile_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE profile_tbl IS 'Profile information for a Contact.';

COMMENT ON COLUMN profile_history_tbl.username IS 'This is contact username this could be an alias';
COMMENT ON COLUMN profile_history_tbl.email IS 'The account identifier for profile';
COMMENT ON COLUMN profile_history_tbl.maritalStatus IS 'This is contact''s marital status.';
COMMENT ON COLUMN profile_history_tbl.height IS 'The measurement of someone or something from head to foot or from base to top. ';
COMMENT ON COLUMN profile_history_tbl.weight IS 'This is the Weight of a person is usually taken to be the force on the person due to gravity.';
COMMENT ON COLUMN profile_history_tbl.ethnicity IS 'This is the fact or state of belonging to a social group that has a common national or cultural tradition.';
COMMENT ON COLUMN profile_history_tbl.religion IS 'The belief in and worship of a superhuman controlling power, especially a personal God or gods.';
COMMENT ON COLUMN profile_history_tbl.eyeColour IS 'This is a polygenic phenotypic character determined by two distinct factors: pigmentation of the eye and the scattering of light by the turbid medium in the stroma of the iris';
COMMENT ON COLUMN profile_history_tbl.phenotype IS 'This is a classification of blood based on the presence and absence of antibodies and inherited antigenic substances on the surface of red blood cells.';
COMMENT ON COLUMN profile_history_tbl.disability IS 'This is indicate if the person is disable or not';
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

CREATE OR REPLACE TRIGGER images_trg
    BEFORE INSERT OR UPDATE
    ON images_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage  VARCHAR2(4000);
    v_response      VARCHAR2(100);
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
        IF :NEW.avatar IS NULL THEN SELECT :OLD.avatar INTO :NEW.avatar FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
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
    v_errorMessage    VARCHAR2(4000);
    v_response        VARCHAR2(100);
    v_modifiedReason  VARCHAR2(10);
BEGIN
    -- Determine whether the action is an update or delete
    IF UPDATING THEN
        v_modifiedReason := 'Updated';
        -- Log the update or delete in the history table
        INSERT INTO images_history_tbl(username, email, avatar, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.email, :OLD.avatar, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO images_history_tbl(username, email, avatar, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.email, :OLD.avatar, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
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
    v_errorMessage  VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'Username is mandatory and cannot be empty.');
        END IF;
        IF :NEW.email IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Email is mandatory and cannot be empty.');
        END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
        -- Ensure required fields are populated
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
    ELSIF UPDATING THEN
        -- Ensure required fields are populated;
        IF :NEW.username IS NULL THEN SELECT :OLD.username INTO :NEW.username FROM DUAL; END IF;
        IF :NEW.email IS NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
        IF :NEW.email IS NULL AND :OLD.email IS NOT NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        IF :NEW.title IS NULL AND :OLD.title IS NOT NULL THEN SELECT :OLD.title INTO :NEW.title FROM DUAL; END IF;
        IF :NEW.firstName IS NULL AND :OLD.firstName IS NOT NULL THEN SELECT :OLD.firstName INTO :NEW.firstName FROM DUAL; END IF;
        IF :NEW.middleName IS NULL AND :OLD.middleName IS NOT NULL THEN SELECT :OLD.middleName INTO :NEW.middleName FROM DUAL; END IF;
        IF :NEW.lastName IS NULL AND :OLD.lastName IS NOT NULL THEN SELECT :OLD.lastName INTO :NEW.lastName FROM DUAL; END IF;
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
    v_errorMessage    VARCHAR2(4000);
    v_response        VARCHAR2(100);
    v_modifiedReason  VARCHAR2(10);
BEGIN
    -- Determine whether the action is an update or delete
    IF UPDATING THEN
        v_modifiedReason := 'Updated';
        -- Log the update or delete in the history table
        INSERT INTO person_history_tbl(username, email, title, firstName, middleName, lastName, zodiacSign, gender, birthday, age, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username,:OLD.email, :OLD.title, :OLD.firstName, :OLD.middleName, :OLD.lastName, :OLD.zodiacSign, :OLD.gender, :OLD.birthday, :OLD.age, :OLD.modifiedBy, :OLD.modifiedDate,v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO person_history_tbl(username, email, title, firstName, middleName, lastName, zodiacSign, gender, birthday, age, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.email, :OLD.title, :OLD.firstName, :OLD.middleName, :OLD.lastName, :OLD.zodiacSign, :OLD.gender, :OLD.birthday, :OLD.age, :OLD.modifiedBy, :OLD.modifiedDate,v_modifiedReason);
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
    v_errorMessage  VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    -- Determine the action
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN RAISE_APPLICATION_ERROR(-20002, 'Username is mandatory and cannot be empty.'); END IF;
        IF :NEW.email IS NULL THEN RAISE_APPLICATION_ERROR(-20003, 'Email is mandatory and cannot be empty.'); END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN SELECT :OLD.username INTO :NEW.username FROM DUAL; END IF;
        IF :NEW.email IS NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        IF :NEW.firstline IS NULL THEN SELECT :OLD.firstline INTO :NEW.firstline FROM DUAL; END IF;
        IF :NEW.secondline IS NULL THEN SELECT :OLD.secondline INTO :NEW.secondline FROM DUAL; END IF;
        IF :NEW.thirdline IS NULL THEN SELECT :OLD.thirdline INTO :NEW.thirdline FROM DUAL; END IF;
        IF :NEW.city IS NULL THEN SELECT :OLD.city INTO :NEW.city FROM DUAL; END IF;
        IF :NEW.postcode IS NULL THEN SELECT :OLD.postcode INTO :NEW.postcode FROM DUAL; END IF;
        IF :NEW.country IS NULL THEN SELECT :OLD.country INTO :NEW.country FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
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
    v_errorMessage    VARCHAR2(4000);
    v_response        VARCHAR2(100);
    v_modifiedReason  VARCHAR2(10);
BEGIN
    -- Determine whether the action is an update or delete
    IF UPDATING THEN
        v_modifiedReason := 'Updated';
        -- Log the update or delete in the history table
        INSERT INTO address_history_tbl(username,email, firstline, secondline, thirdline, city, postcode, country, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.email, :OLD.firstline, :OLD.secondline, :OLD.thirdline, :OLD.city, :OLD.postcode, :OLD.country, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO address_history_tbl(username,email, firstline, secondline, thirdline, city, postcode, country, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.email, :OLD.firstline, :OLD.secondline, :OLD.thirdline, :OLD.city, :OLD.postcode, :OLD.country, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
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
    v_response      VARCHAR2(100);
BEGIN
    -- Determine the action
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN RAISE_APPLICATION_ERROR(-20002, 'Username is mandatory and cannot be empty.'); END IF;
        IF :NEW.email IS NULL THEN RAISE_APPLICATION_ERROR(-20003, 'Email is mandatory and cannot be empty.'); END IF;
        IF :NEW.consent IS NULL THEN SELECT 'YES' INTO :NEW.consent FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN SELECT :OLD.username INTO :NEW.username FROM DUAL; END IF;
        IF :NEW.email IS NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        IF :NEW.channel IS NULL THEN SELECT :OLD.channel INTO :NEW.channel FROM DUAL; END IF;
        IF :NEW.address IS NULL THEN SELECT :OLD.address INTO :NEW.address FROM DUAL; END IF;
        IF :NEW.consent IS NULL THEN SELECT :OLD.consent INTO :NEW.consent FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
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
    v_response        VARCHAR2(100);
    v_modifiedReason VARCHAR2(10);
BEGIN
    -- Determine whether the action is an update or delete
    IF UPDATING THEN
        v_modifiedReason := 'Updated';
        -- Log the update or delete in the history table
        INSERT INTO contact_history_tbl(username, email, channel, address, consent, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.email, :OLD.channel, :OLD.address, :OLD.consent, :OLD.modifiedBy, :OLD.modifiedDate,v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO contact_history_tbl(username, email, channel, address, consent, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.email, :OLD.channel, :OLD.address, :OLD.consent, :OLD.modifiedBy, :OLD.modifiedDate,v_modifiedReason);
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
    v_errorMessage  VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    -- Determine the action
    IF INSERTING THEN
        IF :NEW.username IS NULL THEN RAISE_APPLICATION_ERROR(-20002, 'Username is mandatory and cannot be empty.'); END IF;
        IF :NEW.email IS NULL THEN RAISE_APPLICATION_ERROR(-20003, 'Email is mandatory and cannot be empty.'); END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
    ELSIF UPDATING THEN
        IF :NEW.username IS NULL THEN SELECT :OLD.username INTO :NEW.username FROM DUAL; END IF;
        IF :NEW.email IS NULL THEN SELECT :OLD.email INTO :NEW.email FROM DUAL; END IF;
        IF :NEW.maritalStatus IS NULL THEN SELECT :OLD.maritalStatus INTO :NEW.maritalStatus FROM DUAL; END IF;
        IF :NEW.height IS NULL THEN SELECT :OLD.height INTO :NEW.height FROM DUAL; END IF;
        IF :NEW.weight IS NULL THEN SELECT :OLD.weight INTO :NEW.weight FROM DUAL; END IF;
        IF :NEW.ethnicity IS NULL THEN SELECT :OLD.ethnicity INTO :NEW.ethnicity FROM DUAL; END IF;
        IF :NEW.religion IS NULL THEN SELECT :OLD.religion INTO :NEW.religion FROM DUAL; END IF;
        IF :NEW.eyeColour IS NULL THEN SELECT :OLD.eyeColour INTO :NEW.eyeColour FROM DUAL; END IF;
        IF :NEW.phenotype IS NULL THEN SELECT :OLD.phenotype INTO :NEW.phenotype FROM DUAL; END IF;
        IF :NEW.genotype IS NULL THEN SELECT :OLD.genotype INTO :NEW.genotype FROM DUAL; END IF;
        IF :NEW.disability IS NULL THEN SELECT :OLD.disability INTO :NEW.disability FROM DUAL; END IF;
        IF :NEW.modifiedBy IS NULL THEN SELECT :NEW.username INTO :NEW.modifiedBy FROM DUAL; END IF;
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
    v_errorMessage    VARCHAR2(4000);
    v_response        VARCHAR2(100);
    v_modifiedReason  VARCHAR2(10);
BEGIN
    -- Determine whether the action is an update or delete
    IF UPDATING THEN
        v_modifiedReason := 'Updated';
        -- Log the update or delete in the history table
        INSERT INTO profile_history_tbl(username, email, maritalStatus, height, weight, ethnicity, religion, eyeColour, phenotype, genotype, disability, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.email, :OLD.maritalStatus, :OLD.height, :OLD.weight, :OLD.ethnicity, :OLD.religion, :OLD.eyeColour, :OLD.phenotype, :OLD.genotype, :OLD.disability, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
    ELSIF DELETING THEN
        v_modifiedReason := 'Deleted';
        -- Log the update or delete in the history table
        INSERT INTO profile_history_tbl(username, email, maritalStatus, height, weight, ethnicity, religion, eyeColour, phenotype, genotype, disability, modifiedBy, modifiedDate, modifiedReason)
        VALUES (:OLD.username, :OLD.email, :OLD.maritalStatus, :OLD.height, :OLD.weight, :OLD.ethnicity, :OLD.religion, :OLD.eyeColour, :OLD.phenotype, :OLD.genotype, :OLD.disability, :OLD.modifiedBy, :OLD.modifiedDate, v_modifiedReason);
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
    v_response      VARCHAR2(100);
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
    v_response        VARCHAR2(100);
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
        INSERT INTO profile_tbl(username,email,modifiedBy) VALUES (:NEW.username,:NEW.email,'Authentication Trigger');
        INSERT INTO images_tbl(username,email,modifiedBy) VALUES (:NEW.username,:NEW.email,'Authentication Trigger');
        INSERT INTO person_tbl(username,email,modifiedBy) VALUES (:NEW.username,:NEW.email,'Authentication Trigger');
        INSERT INTO address_tbl(username,email,modifiedBy) VALUES (:NEW.username,:NEW.email,'Authentication Trigger');
        INSERT INTO contact_tbl(username,email,channel,address,consent,modifiedBy) VALUES (:NEW.username,:NEW.email,'Email',:NEW.email,'YES','Authentication Trigger');
        INSERT INTO jwt_tbl(username,email,password,accountStatus,modifiedBy) VALUES (:NEW.username,:NEW.email,:NEW.password,:NEW.accountStatus,'Authentication Trigger');
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
ALTER TRIGGER authentication_audit_trg ENABLE;

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
    | 12-OCT-25	| eomisore 	| Add extra feature such as delete, update.|
    =================================================================================
    */
    -- Find details from the address table
    PROCEDURE getAddress(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        o_addressList OUT SYS_REFCURSOR);

    -- Find details from the contact table
    PROCEDURE getContact(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        o_contactList OUT SYS_REFCURSOR);

    -- Find details from the constellation table
    PROCEDURE getHoroscope(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        o_astrologyList OUT SYS_REFCURSOR);

    -- Find details from the image table
    PROCEDURE getImage(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        o_avatarList OUT SYS_REFCURSOR);

    -- Find details from the person table
    PROCEDURE getPerson(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        o_personList OUT SYS_REFCURSOR);

    -- Find details from the contact table
    PROCEDURE getProfile(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        o_profileList OUT SYS_REFCURSOR);

    -- Find details user details
    PROCEDURE getSilhouette (
        i_email           IN  VARCHAR2,
        o_personList      OUT SYS_REFCURSOR,
        o_avatarList      OUT SYS_REFCURSOR,
        o_addressList     OUT SYS_REFCURSOR,
        o_contactList     OUT SYS_REFCURSOR,
        o_profileList     OUT SYS_REFCURSOR,
        o_astrologyList   OUT SYS_REFCURSOR);

    PROCEDURE saveAddress(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_firstline IN VARCHAR2,
        i_secondline IN VARCHAR2,
        i_thirdline IN VARCHAR2,
        i_city IN VARCHAR2,
        i_postcode IN VARCHAR2,
        i_country IN VARCHAR2,
        o_response OUT VARCHAR2);

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
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_avatar IN BLOB,
        o_response OUT VARCHAR2);

    PROCEDURE savePerson(
        i_username IN VARCHAR2,
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
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_maritalStatus IN VARCHAR2,
        i_height IN VARCHAR2,
        i_weight IN VARCHAR2,
        i_ethnicity IN VARCHAR2,
        i_religion IN VARCHAR2,
        i_eyeColour IN VARCHAR2,
        i_phenotype IN VARCHAR2,
        i_genotype IN VARCHAR2,
        i_disability IN VARCHAR2,
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
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        o_addressList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        OPEN o_addressList FOR
            SELECT *
            FROM address_tbl
            WHERE email = i_email;
        -- insert records for audit purpose
        auth_pkg.audit(i_username,i_email, 'ADDRESS REQUEST', 'Address was successfully requested',i_username);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (GETADDRESS): ' || i_email,
                    o_response => v_response
            );
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
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        o_contactList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        OPEN o_contactList FOR
            SELECT *
            FROM contact_tbl
            WHERE email = i_email;
        -- insert records for audit purpose
        auth_pkg.audit(i_username,i_email, 'CONTACT REQUEST', 'Contact was successfully requested',i_username);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (GETCONTACT): ' || i_email,
                    o_response => v_response
            );
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
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        o_astrologyList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_zodiacSign    VARCHAR2(100);
    BEGIN
        SELECT zodiacSign INTO v_zodiacSign
        FROM person_tbl
        WHERE email = i_email;
        OPEN o_astrologyList FOR
            SELECT *
            FROM horoscope_tbl
            WHERE zodiacSign = v_zodiacSign;
        -- insert records for audit purpose
        auth_pkg.audit(i_username,i_email, 'HOROSCOPE REQUEST', 'Horoscope was successfully requested',i_username);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (GETHOROSCOPE): ' || i_email,
                    o_response => v_response
            );
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
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        o_avatarList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        OPEN o_avatarList FOR
            SELECT *
            FROM images_tbl
            WHERE email = i_email;
        -- insert records for audit purpose
        auth_pkg.audit(i_username,i_email, 'IMAGE REQUEST', 'Image was successfully requested',i_username);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (GETIMAGE): ' || i_email,
                    o_response => v_response
            );
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
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        o_personList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        OPEN o_personList FOR
            SELECT *
            FROM person_tbl
            WHERE email = i_email;
        -- insert records for audit purpose
        auth_pkg.audit(i_username, i_email, 'PERSON REQUEST', 'Person record was successfully requested',i_username);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (GETPERSON): ' || i_email,
                    o_response => v_response
            );
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
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        o_profileList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        OPEN o_profileList FOR
            SELECT *
            FROM profile_tbl
            WHERE email = i_email;
        -- insert records for audit purpose
        auth_pkg.audit(i_username,i_email, 'PROFILE REQUEST', 'Profile was successfully requested',i_username);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (GETPROFILE): ' || i_email,
                    o_response => v_response
            );
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
    PROCEDURE getSilhouette (
        i_email           IN  VARCHAR2,
        o_personList      OUT SYS_REFCURSOR,
        o_avatarList      OUT SYS_REFCURSOR,
        o_addressList     OUT SYS_REFCURSOR,
        o_contactList     OUT SYS_REFCURSOR,
        o_profileList     OUT SYS_REFCURSOR,
        o_astrologyList   OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_zodiacSign    VARCHAR2(100);
        v_username    VARCHAR2(100);
    BEGIN
        SELECT username INTO v_username FROM authentication_tbl WHERE email = i_email;
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
        auth_pkg.audit(v_username, i_email, 'SILHOUETTE REQUEST', 'Silhouette was successfully requested',v_username);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode   => SQLCODE,
                    i_faultmessage=> v_errorMessage,
                    i_faultservice=> 'profile_pkg (GETSILHOUETTE): ' || i_email,
                    o_response    => v_response
            );
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice=> 'profile_pkg (GETSILHOUETTE): ' || i_email,
                    o_response => v_response
            );
    END getSilhouette;

    PROCEDURE saveAddress(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_firstline IN VARCHAR2,
        i_secondline IN VARCHAR2,
        i_thirdline IN VARCHAR2,
        i_city IN VARCHAR2,
        i_postcode IN VARCHAR2,
        i_country IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE address_tbl
        SET email  = i_email,
            firstline  = i_firstline,
            secondline = i_secondline,
            thirdline  = i_thirdline,
            city       = i_city,
            postcode   = i_postcode,
            country    = i_country,
            modifiedBy = i_username
        WHERE email = i_email;
        IF SQL%NOTFOUND THEN
            INSERT INTO address_tbl(username, email, firstline, secondline, thirdline, city, postcode, country, modifiedBy)
            VALUES (i_username,i_email, i_firstline, i_secondline, i_thirdline, i_city, i_postcode, i_country, i_username);
        END IF;
        -- insert records for audit purpose
        auth_pkg.audit(i_username,i_email, 'ADDRESS SAVED', 'Address was successfully saved', i_username);
        o_response := 'success';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (SAVE ADDRESS): ' || i_email,
                    o_response => v_response
            );
            o_response := 'address unsuccessful';
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
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE contact_tbl
        SET email  = i_email,
            channel    = i_channel,
            address    = i_address,
            consent    = i_consent,
            modifiedBy = i_username
        WHERE email = i_email
          AND channel = i_channel;
        IF SQL%NOTFOUND THEN
            INSERT INTO contact_tbl(username, email, channel, address, consent, modifiedBy)
            VALUES (i_username,i_email, i_channel, i_address, i_consent, i_username);
        END IF;
        -- insert records for audit purpose
        auth_pkg.audit(i_username,i_email, 'CONTACT SAVED', 'Contact was successfully saved', i_username);
        o_response := 'success';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (SAVE CONTACT): ' || i_email,
                    o_response => v_response
            );
            o_response := 'contact unsuccessful';
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (SAVE CONTACT): ' || i_email,
                    o_response => v_response
            );
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
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE horoscope_tbl
        SET zodiacSign     = i_zodiacSign,
            currentDay = i_currentDay,
            narrative  = i_narrative,
            modifiedBy = i_modifiedBy
        WHERE zodiacSign = i_zodiacSign;
        IF SQL%NOTFOUND THEN
            INSERT INTO horoscope_tbl(zodiacSign, currentDay, narrative, modifiedBy)
            VALUES (i_zodiacSign, i_currentDay, i_narrative, i_modifiedBy);
        END IF;
        -- insert records for audit purpose
        auth_pkg.audit(i_modifiedBy,i_zodiacSign, 'HOROSCOPE SAVED', 'Horoscope was successfully saved', i_modifiedBy);
        o_response := 'Success';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (SAVE HOROSCOPE): ' || i_zodiacSign,
                    o_response => v_response
            );
            o_response := 'horoscope unsuccessful';
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

    -- Create or Update Identity
    PROCEDURE saveImage(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_avatar IN BLOB,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE images_tbl
        SET avatar     = i_avatar,
            modifiedBy = i_username
        WHERE email = i_email;
        IF SQL%NOTFOUND THEN
            INSERT INTO images_tbl(username, email, avatar, modifiedBy)
            VALUES (i_username,i_email, i_avatar, i_username);
        END IF;
        -- insert records for audit purpose
        auth_pkg.audit(i_username, i_email, 'IMAGE SAVED', 'Image was successfully saved', i_username);
        o_response := 'success';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (SAVE IMAGE): ' || i_email,
                    o_response => v_response
            );
            o_response := 'images unsuccessful';
        WHEN OTHERS THEN
            ROLLBACK;
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'profile_pkg (SAVE IMAGE): ' || i_email,
                o_response => v_response
        );
            o_response := 'images unsuccessful';
    END saveImage;

    PROCEDURE savePerson(
        i_username IN VARCHAR2,
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
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE person_tbl
        SET email  = i_email,
            title      = i_title,
            firstName  = i_firstName,
            middleName = i_middleName,
            lastName   = i_lastName,
            gender     = i_gender,
            birthday   = i_birthday,
            modifiedBy = i_username
        WHERE email = i_email;
        IF SQL%NOTFOUND THEN
            INSERT INTO person_tbl(username, email, title, firstName, middleName, lastName, gender, birthday, modifiedBy)
            VALUES (i_username, i_email, i_title, i_firstName, i_middleName, i_lastName, i_gender, i_birthday, i_username);
        END IF;
        -- insert records for audit purpose
        auth_pkg.audit(i_username, i_email, 'PERSON SAVED', 'Person record was successfully saved', i_username);
        o_response := 'success';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (SAVE PERSON): ' || i_email,
                    o_response => v_response
            );
            o_response := 'person unsuccessful';
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'profile_pkg (SAVE PERSON): ' || i_email,
                o_response => v_response
            );
            o_response := 'person unsuccessful';
    END savePerson;

    -- Create or Update Profile
    PROCEDURE saveProfile(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_maritalStatus IN VARCHAR2,
        i_height IN VARCHAR2,
        i_weight IN VARCHAR2,
        i_ethnicity IN VARCHAR2,
        i_religion IN VARCHAR2,
        i_eyeColour IN VARCHAR2,
        i_phenotype IN VARCHAR2,
        i_genotype IN VARCHAR2,
        i_disability IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE profile_tbl
        SET email         = i_email,
            maritalStatus = i_maritalStatus,
            height        = i_height,
            weight        = i_weight,
            ethnicity     = i_ethnicity,
            religion      = i_religion,
            eyeColour     = i_eyeColour,
            phenotype     = i_phenotype,
            genotype      = i_genotype,
            disability    = i_disability,
            modifiedBy    = i_username
        WHERE email = i_email;
        IF SQL%NOTFOUND THEN
            INSERT INTO profile_tbl(username, email, maritalStatus, height, weight, ethnicity, religion, eyeColour, phenotype,
                                    genotype, disability, modifiedBy)
            VALUES (i_username,i_email, i_maritalStatus, i_height, i_weight, i_ethnicity, i_religion, i_eyeColour, i_phenotype,
                    i_genotype, i_disability, i_username);
        END IF;
        -- insert records for audit purpose
        auth_pkg.audit(i_username, i_email, 'PROFILE SAVED', 'Profile was successfully saved', i_username);
        o_response := 'success';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'profile_pkg (SAVE PROFILE): ' || i_email,
                    o_response => v_response
            );
            o_response := 'profile unsuccessful';
        WHEN OTHERS THEN
            ROLLBACK;
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'profile_pkg (SAVE PROFILE): ' || i_email,
                o_response => v_response
        );
            o_response := 'profile unsuccessful';
    END saveProfile;

END profile_pkg;
/

PROMPT "Compiling profile package"

ALTER PACKAGE profile_pkg COMPILE PACKAGE;
ALTER PACKAGE profile_pkg COMPILE BODY;
/

PROMPT "Inserting Initial Records"

-- Insert initial records

INSERT INTO horoscope_tbl (zodiacSign, currentDay, narrative)
VALUES ('Aries', 'Sep 17, 2025',
        'Do not spread the good news too quickly, Aries. As exciting as it is, nothing is confirmed yet. Keep the information under your hat until plane reservations have been made or you have the job offer in writing. Whatever the good news is, it is exactly what the doctor prescribed to give your self-confidence a boost.');
INSERT INTO horoscope_tbl (zodiacSign, currentDay, narrative)
VALUES ('Taurus', 'Sep 17, 2025',
        'If you receive a financial windfall, spend it wisely, Taurus. Your tendency might be to buy gifts or treat a crowd to a lavish night on the town. But where is the enduring value? Invested carefully, a small chunk of money can grow into a much larger one, which will give you many more options. Be prudent.');
INSERT INTO horoscope_tbl (zodiacSign, currentDay, narrative)
VALUES ('Gemini', 'Sep 17, 2025',
        'You are energetic and enthusiastic today, Gemini, and those around you respond favorably. It seems everyone wants to be in your orbit. Work at home and the office goes quickly and smoothly. Because you have so much energy, why not take on a new project? Normally this would send you over the edge, but today you feel you could take on anything. Go for it.');
INSERT INTO horoscope_tbl (zodiacSign, currentDay, narrative)
VALUES ('Cancer', 'Sep 17, 2025',
        'There is tension all around you, so you will be happiest spending as much time by yourself as possible, Cancer. If you must interact with people, keep your communication clear and concise. There is room for misunderstanding, which could result in a major blowup over a minor event. It simply is not worth the trouble being with people today. Seclusion is the only place where you will find peace.');
INSERT INTO horoscope_tbl (zodiacSign, currentDay, narrative)
VALUES ('Leo', 'Sep 17, 2025',
        'You are ready for a change, Leo, there is no doubt about it. As you grow older your interests broaden, and you are considering pursuing some of these new interests in earnest. Perhaps school beckons, or some adult education courses. You are ready to make a new place for yourself in the world. Go ahead and get started!');
INSERT INTO horoscope_tbl (zodiacSign, currentDay, narrative)
VALUES ('Virgo', 'Sep 17, 2025',
        'You have never looked better, Virgo. Your partner notices, too, and showers you with extra affection and perhaps even an unexpected gift. This should put a smile on your face! At work, you may be given responsibilities beyond your usual job. Take care to do this special assignment well. If you do, other advancements are likely to follow.');
INSERT INTO horoscope_tbl (zodiacSign, currentDay, narrative)
VALUES ('Libra', 'Sep 17, 2025',
        'Sometimes a little indulgence has value far beyond its price, Libra. A bubble bath in the middle of the day, a luxurious hour spent browsing in a bookstore, a special outfit you have wanted for a long time - these are a few of the ways you could perk up your spirits. Why not? You could use a boost.');
INSERT INTO horoscope_tbl (zodiacSign, currentDay, narrative)
VALUES ('Scorpio', 'Sep 17, 2025',
        'You feel as though you have turned a financial and professional corner, Scorpio. Recent accomplishments have you feeling energized and on top of the world! You exude confidence. It is a good feeling, is not it? Members of the opposite sex are especially attracted to you right now. And who could blame them? You are looking great!');
INSERT INTO horoscope_tbl (zodiacSign, currentDay, narrative)
VALUES ('Sagittarius', 'Sep 17, 2025',
        'Who knew you were so talented, Sagittarius? A creation done long ago suddenly takes on a life of its own. A short story written and submitted long ago is pulled from the bottom of the slush pile. Or a portrait you painted gets a second admiring look. Whatever the circumstances, you enjoy the recognition. Your work is not the only thing receiving admiring glances. Your partner appreciates you, too!');
INSERT INTO horoscope_tbl (zodiacSign, currentDay, narrative)
VALUES ('Capricorn', 'Sep 17, 2025',
        'Loving care is prescribed for someone in your family, Capricorn. Offer a bowl of soup and some tea, but beyond that try and stay out of the way. Sometimes uninterrupted quiet is the best cure of all. You could use a bit of this yourself. Why not curl up with a good book? Even if it is the middle of the day, draw the shades and pretend it is night.');
INSERT INTO horoscope_tbl (zodiacSign, currentDay, narrative)
VALUES ('Aquarius', 'Sep 17, 2025',
        'There is tension in the air, Aquarius, but there is little you can do about it. The harsh atmosphere is in stark contrast to the frivolity you felt over the last several days. It seems you received some good news. Perhaps you were finally recognized for your hard work? Do not brag about your accomplishments. It would only exacerbate the situation. Be patient. Avoid confrontation.');
INSERT INTO horoscope_tbl (zodiacSign, currentDay, narrative)
VALUES ('Pisces', 'Sep 17, 2025',
        'You might be in a financial jam right now, Pisces. The stress of the situation has you considering some radical solutions. Would it really benefit your family if you took a second job? Confide in a friend and see if he or she can help you find a more agreeable solution. Perhaps a relative could give you a low-interest loan.');

COMMIT;

SHOW ERRORS
/

PROMPT "End of creating profile schema"