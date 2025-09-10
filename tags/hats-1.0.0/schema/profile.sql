PROMPT "Creating Profile Schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      profile.sql                                                     *
 * Created:   02/03/2025, 19:16                                               *
 * Modified:  15/03/2025, 16:09                                               *
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

-- Create Tables
CREATE TABLE country_tbl
(
    alpha2       VARCHAR2(10 BYTE),
    alpha3       VARCHAR2(10 BYTE),
    country      VARCHAR2(100 BYTE),
    region       VARCHAR2(100 BYTE),
    continent    VARCHAR2(100 BYTE),
    dialPrefix   VARCHAR2(10 BYTE),
    currencyCode VARCHAR2(10 BYTE),
    currencyName VARCHAR2(100 BYTE),
    modifiedBy   VARCHAR2(50 BYTE),
    modifiedDate TIMESTAMP
);

CREATE TABLE profile_tbl
(
    accountid     VARCHAR2(20 BYTE),
    maritalStatus VARCHAR2(50 BYTE),
    height        VARCHAR2(20 BYTE),
    weight        VARCHAR2(20 BYTE),
    ethnicity     VARCHAR2(50 BYTE),
    religion      VARCHAR2(50 BYTE),
    eyeColour     VARCHAR2(20 BYTE),
    phenotype     VARCHAR2(50 BYTE),
    genotype      VARCHAR2(50 BYTE),
    disability    VARCHAR2(50 BYTE),
    modifiedBy    VARCHAR2(50 BYTE),
    modifiedDate  TIMESTAMP
);

CREATE TABLE horoscope_tbl
(
    zodiac       VARCHAR2(20 BYTE),
    currentDay   VARCHAR2(50 BYTE),
    narrative    VARCHAR2(4000 BYTE),
    modifiedBy   VARCHAR2(50 BYTE),
    modifiedDate TIMESTAMP
);

PROMPT "Commenting Tables"

-- Comment on tables
COMMENT ON COLUMN country_tbl.alpha2 IS 'This will list ISO 3166-1 alpha-2 codes, which are two-letter country codes';
COMMENT ON COLUMN country_tbl.alpha3 IS 'This will list ISO 3166-1 alpha-3 codes, which are three-letter country codes';
COMMENT ON COLUMN country_tbl.country IS 'This will list possible all known countries of the world';
COMMENT ON COLUMN country_tbl.region IS 'This will list possible all known regions or continent where the country is located';
COMMENT ON COLUMN country_tbl.continent IS 'This will list possible a country continent, which is any of several large landmasses';
COMMENT ON COLUMN country_tbl.dialPrefix IS 'This will list possible all known dial codes';
COMMENT ON COLUMN country_tbl.currencyCode IS 'This will list possible or known currency codes';
COMMENT ON COLUMN country_tbl.currencyName IS 'This will list possible or known currency description';
COMMENT ON COLUMN country_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN country_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE country_tbl IS 'Profile information for list of countries of the world.';

COMMENT ON COLUMN profile_tbl.accountid IS 'The account identifier for profile';
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

COMMENT ON TABLE horoscope_tbl IS 'Profile information for list of daily horoscope based on signs.';
COMMENT ON COLUMN horoscope_tbl.zodiac IS 'The zodiac is an area of the sky that extends approximately 8° north or south (as measured in celestial latitude) of the ecliptic, the apparent path of the Sun across the celestial sphere over the course of the year.';
COMMENT ON COLUMN horoscope_tbl.currentDay IS 'The current date means the date today or the date when something will happen.';
COMMENT ON COLUMN horoscope_tbl.narrative IS 'Your Zodiac sign, or star sign, reflects the position of the sun when you were born. With its strong influence on your personality, character, and emotions, your sign is a powerful tool for understanding yourself and your relationships and of course, your sign can show you the way to an incredible life.';
COMMENT ON COLUMN horoscope_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN horoscope_tbl.modifiedDate IS 'Audit column - date of last update.';

-- Create profile history table
CREATE TABLE profile_history_tbl AS
SELECT *
FROM profile_tbl
WHERE 1 = 0;
ALTER TABLE profile_history_tbl
    ADD modifiedReason VARCHAR2(200);
ALTER TABLE profile_history_tbl
    ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;

-- Create horoscope history table
CREATE TABLE horoscope_history_tbl AS
SELECT *
FROM horoscope_tbl
WHERE 1 = 0;
ALTER TABLE horoscope_history_tbl
    ADD modifiedReason VARCHAR2(200);
ALTER TABLE horoscope_history_tbl
    ADD archivedDate TIMESTAMP DEFAULT SYSTIMESTAMP;

PROMPT "Setting Constraints"

-- Setting Unique Key
ALTER TABLE country_tbl
    ADD CONSTRAINT alpha_unq UNIQUE (alpha2);
ALTER TABLE horoscope_tbl
    ADD CONSTRAINT zodiac_unq UNIQUE (zodiac);

-- Setting Foreign Key
ALTER TABLE profile_tbl
    ADD CONSTRAINT profile_fk FOREIGN KEY (accountid) REFERENCES account_tbl (accountid) ON DELETE CASCADE;
ALTER TABLE address_tbl
    ADD CONSTRAINT addcou_fk FOREIGN KEY (country) REFERENCES country_tbl (alpha2);
ALTER TABLE person_tbl
    ADD CONSTRAINT perzod_fk FOREIGN KEY (zodiac) REFERENCES horoscope_tbl (zodiac);

-- Setting Check Constraint
ALTER TABLE profile_tbl
    ADD CONSTRAINT maritalStatus_Chk CHECK (maritalStatus IN ('Separated', 'Widowed', 'Single',
                                                              'Married', 'Lone', 'Live-in',
                                                              'Estranged', 'EngAged', 'Divorced',
                                                              'De Facto', 'Common Law')) ENABLE;
ALTER TABLE profile_tbl
    ADD CONSTRAINT genotype_Chk CHECK (genotype IN ('AA', 'AS', 'SS', 'AC')) ENABLE;
ALTER TABLE profile_tbl
    ADD CONSTRAINT phenotype_Chk CHECK (phenotype IN ('A+', 'A-', 'B+', 'B-', 'O+', 'O-',
                                                      'AB+', 'AB-')) ENABLE;
ALTER TABLE profile_tbl
    ADD CONSTRAINT religion_Chk CHECK (religion IN ('Christianity', 'Islam', 'Atheist', 'Hinduism',
                                                    'Buddhism', 'Sikhism', 'Judaism')) ENABLE;
ALTER TABLE profile_tbl
    ADD CONSTRAINT disability_Chk CHECK (disability IN ('Spina Bifida', 'Spinal Cord Injury',
                                                        'Amputation', 'Diabetes',
                                                        'Chronic Fatigue Syndrome', 'Carpal Tunnel',
                                                        'Arthritis', 'Learning Disability',
                                                        'Traumatic Brain Injury', 'AD/HD', 'Depression',
                                                        'Bipolar Disorder', 'Schizophrenia',
                                                        'Eating Disorder', 'Anxiety',
                                                        'Post Traumatic Stress Disorder', 'Blindness',
                                                        'Deafness', 'Visual Impairment',
                                                        'Hard Of Hearing', 'None')) ENABLE;
ALTER TABLE profile_tbl
    ADD CONSTRAINT eyeColour_Chk CHECK (eyeColour IN ('Amber', 'Blue', 'Brown', 'Grey', 'Green',
                                                      'Hazel', 'Red', 'Violet')) ENABLE;
ALTER TABLE profile_tbl
    ADD CONSTRAINT ethnicity_Chk CHECK (ethnicity IN ('Indian', 'Pakistani', 'Bangladeshi',
                                                      'Caribbean', 'African', 'Chinese', 'Arab',
                                                      'British', 'Irish',
                                                      'Any other White background',
                                                      'Any other mixed background',
                                                      'White and Asian', 'White and Black African',
                                                      'White and Black Caribbean',
                                                      'Any other Asian background',
                                                      'Any other Black background',
                                                      'Any other ethnic group')) ENABLE;
ALTER TABLE horoscope_tbl
    ADD CONSTRAINT zodiac_chk CHECK (zodiac IN ('Aries', 'Taurus', 'Gemini',
                                                'Cancer', 'Leo', 'Virgo',
                                                'Libra', 'Scorpio', 'Sagittarius',
                                                'Capricorn', 'Aquarius', 'Pisces')) ENABLE;

PROMPT "Creating Triggers"

-- Creating Triggers
CREATE OR REPLACE TRIGGER profile_trg
    BEFORE INSERT
    ON profile_tbl
    FOR EACH ROW
DECLARE
    v_error_message VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    IF :NEW.accountid IS NULL THEN
        RAISE_APPLICATION_ERROR(-20004, 'Account Identifier is Mandatory and cannot be empty.');
    END IF;
    IF :NEW.modifiedDate IS NULL THEN SELECT SYSTIMESTAMP INTO :NEW.modifiedDate FROM DUAL; END IF;
    IF :NEW.modifiedBy IS NULL THEN SELECT USER INTO :NEW.modifiedBy FROM DUAL; END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'profile_trg (INSERT): ' || :NEW.accountid,
                o_response => v_response
        );
        RAISE;
END;
/

-- Creating Triggers
CREATE OR REPLACE TRIGGER profile_audit_trg
    AFTER UPDATE OR DELETE
    ON profile_tbl
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
    INSERT INTO profile_history_tbl(accountid, maritalStatus, height, weight, ethnicity, religion, eyeColour,
                                    phenotype, genotype, disability, modifiedBy, modifiedDate, modifiedReason)
    VALUES (:OLD.accountid, :OLD.maritalStatus, :OLD.height, :OLD.weight, :OLD.ethnicity, :OLD.religion, :OLD.eyeColour,
            :OLD.phenotype, :OLD.genotype, :OLD.disability, :OLD.modifiedBy, :OLD.modifiedDate, v_modified_reason);
EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'profile_trg (INSERT): ' || :NEW.accountid,
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
    v_error_message VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    IF :NEW.modifiedDate IS NULL THEN SELECT SYSTIMESTAMP INTO :NEW.modifiedDate FROM DUAL; END IF;
    IF :NEW.modifiedBy IS NULL THEN SELECT USER INTO :NEW.modifiedBy FROM DUAL; END IF;

EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'horoscope_trg for profile: ' || :NEW.zodiac,
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
    INSERT INTO horoscope_history_tbl(zodiac, currentDay, narrative, modifiedBy, modifiedDate, modifiedReason)
    VALUES (:OLD.zodiac, :OLD.currentDay, :OLD.narrative, :OLD.modifiedBy, :OLD.modifiedDate, v_modified_reason);
EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'horoscope_trg (INSERT): ' || :NEW.zodiac,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER country_trg
    BEFORE INSERT OR UPDATE
    ON country_tbl
    FOR EACH ROW
DECLARE
    v_error_message VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    IF :NEW.modifiedDate IS NULL THEN SELECT SYSTIMESTAMP INTO :NEW.modifiedDate FROM DUAL; END IF;
    IF :NEW.modifiedBy IS NULL THEN SELECT USER INTO :NEW.modifiedBy FROM DUAL; END IF;

EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'country_trg for profile: ' || :NEW.alpha2,
                o_response => v_response
        );
        RAISE;
END;
/

PROMPT "Enabling Triggers"

-- Enable Triggers
ALTER TRIGGER profile_trg ENABLE;
ALTER TRIGGER country_trg ENABLE;
ALTER TRIGGER horoscope_trg ENABLE;
ALTER TRIGGER horoscope_audit_trg ENABLE;
ALTER TRIGGER profile_audit_trg ENABLE;

PROMPT "Creating Profile Header Package"

-- Create Packages
CREATE OR REPLACE PACKAGE profile_pkg
AS
    /* $Header: profile_pkg. 1.0.0 15-Mar-25 16:09 Package
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
Name: profile_pkg
Program Type: Package Specification
Purpose: ADD/FIND/UPDATE/DELETE entity
=================================================================================
HISTORY
=================================================================================
| DATE 		| Owner 	| Activity
=================================================================================
| 02-Mar-25	| eomisore 	| Created initial script.|
=================================================================================
| 15-Mar-25	| eomisore 	| Add history log to tables.|
=================================================================================
*/
    -- Create or Update Profile
    PROCEDURE SaveProfile(
        i_accountid IN profile_tbl.accountid%TYPE,
        i_maritalStatus IN profile_tbl.maritalStatus%TYPE,
        i_height IN profile_tbl.height%TYPE,
        i_weight IN profile_tbl.weight%TYPE,
        i_ethnicity IN profile_tbl.ethnicity%TYPE,
        i_religion IN profile_tbl.religion%TYPE,
        i_eyeColour IN profile_tbl.eyeColour%TYPE,
        i_phenotype IN profile_tbl.phenotype%TYPE,
        i_genotype IN profile_tbl.genotype%TYPE,
        i_disability IN profile_tbl.disability%TYPE,
        i_modifiedBy IN profile_tbl.modifiedBy%TYPE,
        o_response OUT VARCHAR2);

    PROCEDURE GetCountry(
        i_countrycode IN country_tbl.alpha2%TYPE,
        o_countryList OUT SYS_REFCURSOR);

    -- Update constellation table
    PROCEDURE SaveHoroscope(
        i_zodiac IN horoscope_tbl.zodiac%TYPE,
        i_currentDay IN horoscope_tbl.currentDay%TYPE,
        i_narrative IN horoscope_tbl.narrative%TYPE,
        i_modifiedBy IN horoscope_tbl.modifiedBy%TYPE,
        o_response OUT VARCHAR2);

    -- Find details from the constellation table
    PROCEDURE GetHoroscope(
        i_zodiac IN horoscope_tbl.zodiac%TYPE,
        o_astrologyList OUT SYS_REFCURSOR);

END profile_pkg;
/

PROMPT "Creating Profile Body Package"

-- Create Packages
CREATE OR REPLACE PACKAGE BODY profile_pkg
AS
    /* $Body: profile_pkg. 1.0.0 15-Mar-25 16:09 Package
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
Name: profile_pkg
Program Type: Package Specification
Purpose: ADD/FIND/UPDATE/DELETE entity
=================================================================================
HISTORY
=================================================================================
| DATE 		| Owner 	| Activity
=================================================================================
| 02-Mar-25	| eomisore 	| Created initial script.|
=================================================================================
| 15-Mar-25	| eomisore 	| Add history log to tables.|
=================================================================================
*/
    -- Create or Update Profile
    PROCEDURE SaveProfile(
        i_accountid IN profile_tbl.accountid%TYPE,
        i_maritalStatus IN profile_tbl.maritalStatus%TYPE,
        i_height IN profile_tbl.height%TYPE,
        i_weight IN profile_tbl.weight%TYPE,
        i_ethnicity IN profile_tbl.ethnicity%TYPE,
        i_religion IN profile_tbl.religion%TYPE,
        i_eyeColour IN profile_tbl.eyeColour%TYPE,
        i_phenotype IN profile_tbl.phenotype%TYPE,
        i_genotype IN profile_tbl.genotype%TYPE,
        i_disability IN profile_tbl.disability%TYPE,
        i_modifiedBy IN profile_tbl.modifiedBy%TYPE,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE profile_tbl
        SET accountid     = i_accountid,
            maritalStatus = i_maritalStatus,
            height        = i_height,
            weight        = i_weight,
            ethnicity     = i_ethnicity,
            religion      = i_religion,
            eyeColour     = i_eyeColour,
            phenotype     = i_phenotype,
            genotype      = i_genotype,
            disability    = i_disability,
            modifiedBy    = i_modifiedBy
        WHERE accountid = i_accountid
        RETURNING accountid INTO o_response;
        IF SQL%NOTFOUND THEN
            INSERT INTO profile_tbl(accountid, maritalStatus, height, weight, ethnicity, religion, eyeColour, phenotype,
                                    genotype, disability, modifiedBy)
            VALUES (i_accountid, i_maritalStatus, i_height, i_weight, i_ethnicity, i_religion, i_eyeColour, i_phenotype,
                    i_genotype, i_disability, i_modifiedBy)
            RETURNING accountid INTO o_response;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN ROLLBACK;
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'profile_pkg.SaveProfile: ' || i_accountid,
                o_response => v_response
        );
        o_response := SQLCODE || SUBSTR(SQLERRM, 1, 2000);
    END SaveProfile;

    PROCEDURE GetCountry(
        i_countrycode IN country_tbl.alpha2%TYPE,
        o_countryList OUT SYS_REFCURSOR)
    AS
    BEGIN
        OPEN o_countryList FOR
            SELECT *
            FROM country_tbl
            WHERE alpha2 = i_countrycode;
    END GetCountry;

    -- Update constellation table
    PROCEDURE SaveHoroscope(
        i_zodiac IN horoscope_tbl.zodiac%TYPE,
        i_currentDay IN horoscope_tbl.currentDay%TYPE,
        i_narrative IN horoscope_tbl.narrative%TYPE,
        i_modifiedBy IN horoscope_tbl.modifiedBy%TYPE,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE horoscope_tbl
        SET zodiac     = i_zodiac,
            currentDay = i_currentDay,
            narrative  = i_narrative,
            modifiedBy = i_modifiedBy
        WHERE zodiac = i_zodiac;
        o_response := 'Success';
        IF SQL%NOTFOUND THEN
            INSERT INTO horoscope_tbl(zodiac, currentDay, narrative, modifiedBy)
            VALUES (i_zodiac, i_currentDay, i_narrative, i_modifiedBy);
            o_response := 'Success';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN ROLLBACK;
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'profile_pkg.SaveHoroscope: ' || i_zodiac,
                o_response => v_response
        );
        o_response := SQLCODE || SUBSTR(SQLERRM, 1, 2000);
    END SaveHoroscope;

    -- Find details from the constellation table
    PROCEDURE GetHoroscope(
        i_zodiac IN horoscope_tbl.zodiac%TYPE,
        o_astrologyList OUT SYS_REFCURSOR)
    AS
    BEGIN
        OPEN o_astrologyList FOR
            SELECT *
            FROM horoscope_tbl
            WHERE zodiac = i_zodiac;
    END GetHoroscope;

END profile_pkg;
/

PROMPT "Compiling Profile Package"

ALTER PACKAGE profile_pkg COMPILE PACKAGE;
ALTER PACKAGE profile_pkg COMPILE BODY;
/

PROMPT "Inserting Initial Records"

-- Insert initial records

INSERT INTO horoscope_tbl (zodiac, currentDay, narrative)
VALUES ('Aries', 'May 3, 2025',
        'Innovative art forms might seem especially appealing today, Aries. Stay out of gallery shops unless you''re prepared to take home a carload of merchandise. If you''re more into music, you might break the bank downloading tunes to your MP3 player. This could be a new phase in your artistic tastes or it could be a longstanding trend. Whichever it is, have fun!');
INSERT INTO horoscope_tbl (zodiac, currentDay, narrative)
VALUES ('Taurus', 'May 3, 2025',
        'Do you believe in ghosts? Some strange phone calls, emails, or other communications may come your way today, Taurus. One may come from someone who thinks you''re someone else. Phone calls may be hang-ups, wrong numbers, or phantom rings. If there''s a knock at the door, it may be the house settling and not a ghost, but it can still be rather unnerving. Try not to think about it.');
INSERT INTO horoscope_tbl (zodiac, currentDay, narrative)
VALUES ('Gemini', 'May 3, 2025',
        'An unexpected sum of money could come your way today, Gemini. It probably won''t be large, but it will be welcome nonetheless. Perhaps someone has owed you money for a long time and finally repays it. Or you might sell an item you''ve wanted to unload for a long time. Whatever it is, you might want to take a friend to dinner. Go for it and have fun!');
INSERT INTO horoscope_tbl (zodiac, currentDay, narrative)
VALUES ('Cancer', 'May 3, 2025',
        'Have you been exercising too rigorously lately, Cancer? If so, you might feel some little aches and pains. Stay off your feet for most of the day. When you exercise, concentrate on stretching. Spend some time soaking in a hot tub if you can. The old saying, "No pain, no gain" has pretty much been discredited! Yoga or tai chi could serve you as well as aerobics today. Stick with those!');
INSERT INTO horoscope_tbl (zodiac, currentDay, narrative)
VALUES ('Leo', 'May 3, 2025',
        'The feeling that someone is coming to visit you might be with you throughout the day, Leo. Your intuition is probably right, except for one thing - it''s probably more than one person! Some friends may have some good news that they want to share as soon as possible. Straighten up the house and pretend to be surprised when they come to the door. Have a great evening!');
INSERT INTO horoscope_tbl (zodiac, currentDay, narrative)
VALUES ('Virgo', 'May 3, 2025',
        'Are all of your friends into astrology, divine science, or spiritual matters, Virgo? It might seem like most of them are today, anyway. You may have many new friends in those fields. You have a lot to learn from all of them, and even more that you can learn together. A giant spurt of personal growth is right around the corner.');
INSERT INTO horoscope_tbl (zodiac, currentDay, narrative)
VALUES ('Libra', 'May 3, 2025',
        'A love partner may host a social event or meeting of some kind, Libra. It might be interesting to get acquainted with friends of your mate you haven''t yet met. Some of them are probably intelligent, interesting people in fascinating professions. One of them could recommend a few books that you will definitely want to read. Have fun. Don''t forget to thank your sweetheart!');
INSERT INTO horoscope_tbl (zodiac, currentDay, narrative)
VALUES ('Scorpio', 'May 3, 2025',
        'Are you contemplating a trip, Scorpio, perhaps to a place you''ve always dreamed of visiting? If you''re in doubt as to whether or not you can do it, work out your budget and you might be surprised. Invite a friend or romantic partner to accompany you. Such a trip could boost your personal growth like nothing you''ve ever tried before. Think about it!');
INSERT INTO horoscope_tbl (zodiac, currentDay, narrative)
VALUES ('Sagittarius', 'May 3, 2025',
        'Material values may pale beside spiritual ones today, Sagittarius. You might consider giving up the rat race and retreating to the wilderness. This would perhaps make a good vacation, but you probably aren''t ready to chuck it all just yet. Don''t be too hard on yourself if your enjoyment of worldly pleasures returns tomorrow. Changes like this come gradually, not overnight. Take it at your own pace.');
INSERT INTO horoscope_tbl (zodiac, currentDay, narrative)
VALUES ('Capricorn', 'May 3, 2025',
        'A current or potential romantic partner might seem like the most perfect, wonderful person in the world to you, Capricorn. Your romantic nature could get the better of you today. Don''t gaze at your partner all dewy eyed! Instead, try to maintain a certain distance to avoid appearing too needy. It was probably your self-sufficiency and inner power that attracted your lover in the first place.');
INSERT INTO horoscope_tbl (zodiac, currentDay, narrative)
VALUES ('Aquarius', 'May 3, 2025',
        'You might not be able to concentrate on your work today, Aquarius. Your head may be in the clouds and your eye for detail could fail you somewhat. Needless to say, this isn''t a good day to tackle new, difficult, or complicated tasks. Concentrate on routines that you can do without thinking. That way you will get through the day without making yourself crazy.');
INSERT INTO horoscope_tbl (zodiac, currentDay, narrative)
VALUES ('Pisces', 'May 3, 2025',
        'Are you an artist, writer, or musician, Pisces? If so, your work may take on a more symbolic or impressionistic tone. Today you''re probably more interested in conveying feelings and impressions than details. It might surprise you that you''re thinking along those lines. This urge may vanish tomorrow, so if you like today''s work, make the most of it. Try to remember how and why you''re doing it!');

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AF', 'AFG', 'Afghanistan', 'South-Central Asia', 'Asia', '+93', 'AFN', 'Afghan Afghani');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AX', 'ALA', 'Åland Islands', 'Northern Europe', 'Europe', '+358', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AL', 'ALB', 'Albania', 'Balkan Peninsula', 'Europe', '+355', 'ALL', 'Albanian lek');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('DZ', 'DZA', 'Algeria', 'Northern Africa', 'Africa', '+213', 'DZD', 'Algerian dinar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AS', 'ASM', 'American Samoa', 'Polynesia, Oceania', 'Pacific', '+1-684', 'USD', 'US dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AD', 'AND', 'Andorra', 'Southern Europe', 'Europe', '+376', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AO', 'AGO', 'Angola', 'Central Africa', 'Africa', '+244', 'AOA', 'Angolan kwanza');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AI', 'AIA', 'Anguilla', 'Leeward Islands, Caribbean', 'Caraibes', '+1-264', 'XCD', 'East Caribbean dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AQ', 'ATA', 'Antarctica', 'Antarctica', 'Antarctic', '+672', 'AQD', 'Antarctican dollars');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AG', 'ATG', 'Antigua and Barbuda', 'Leeward Islands, Caribbean', 'Caraibes', '+1-268', 'XCD',
        'East Caribbean dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AR', 'ARG', 'Argentina', 'Southern South America', 'South and Central America', '+54', 'ARS',
        'Argentine peso');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AM', 'ARM', 'Armenia', 'Western Asia', 'Europe', '+374', 'AMD', 'Armenian dram');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AW', 'ABW', 'Aruba', 'Leeward Islands, Caribbean', 'Caraibes', '+297', 'AWG', 'Aruban guilder');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AU', 'AUS', 'Australia', 'Australia/Oceania', 'Pacific', '+61', 'AUD', 'Australian dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AT', 'AUT', 'Austria', 'Western Europe', 'Europe', '+43', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AZ', 'AZE', 'Azerbaïdjan', 'Caucasus, Western Asia', 'East Europe', '+994', 'AZN', 'New Azerbaijani Manat');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BS', 'BHS', 'Bahamas', 'Caribbean', 'Caraibes', '+1-242', 'BSD', 'Bahamian dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BH', 'BHR', 'Kingdom of Bahrain', 'Arabian Peninsula, Middle East', 'Middle East', '+973', 'BHD',
        'Bahraini dinar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BD', 'BGD', 'Bangladesh', 'South-Central Asia', 'Asia', '+880', 'BDT', 'Bangladeshi taka');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BB', 'BRB', 'Barbados', 'Lesser Antilles, Caribbean', 'Caraibes', '+1-246', 'BBD', 'Barbados dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BY', 'BLR', 'Belarus', 'Eastern Europe', 'Europe', '+375', 'BYR', 'Belarusian ruble');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BE', 'BEL', 'Belgium', 'Western Europe', 'Europe', '+32', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BZ', 'BLZ', 'Belize', 'Central America', 'Caraibes', '+501', 'BZD', 'Belize dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BJ', 'BEN', 'Republic of Benin', 'West Africa', 'Africa', '+229', 'XOF', 'CFA Franc BCEAO');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BM', 'BMU', 'Bermuda', 'North America', 'Caraibes', '+1-441', 'BMD', 'Bermudian dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BT', 'BTN', 'Kingdom of Bhutan', 'South-Central Asia', 'Asia', '+975', 'BTN', 'Bhutanese ngultrum');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BO', 'BOL', 'Bolivia, Plurinational State of', 'Central South America', 'South and Central America', '+591',
        'BOB', 'Boliviano');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BQ', 'BES', 'Bonaire, Sint Eustatius and Saba', 'Caribbean Netherlands', 'Caraibes', '+599', 'USD',
        'United States Dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BA', 'BIH', 'Bosnia and Herzegovina', 'Southern Europe', 'Europe', '+387', 'BAM', 'Convertible mark');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BW', 'BWA', 'Botswana', 'Southern Africa', 'Africa', '+267', 'BWP', 'Botswana pula');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BV', 'BVT', 'Bouvet Island', 'Subantarctic Volcanic Island', 'Antarctica', '+47', 'NOK', 'Norwegian krone');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BR', 'BRA', 'Brazil', 'Central Eastern South America', 'South and Central America', '+55', 'BRL',
        'Brazilian real');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('IO', 'IOT', 'British Indian Ocean Territory', 'Indian Ocean', 'Asia', '+246', 'GBP', 'Pound sterling');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('VG', 'VGB', 'British Virgin Islands', 'British Overseas Territory', 'Caraibes', '+1', 'USD',
        'United States Dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BN', 'BRN', 'Negara Brunei Darussalam', 'Southeast Asia', 'Middle East', '+673', 'BND', 'Brunei dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BG', 'BGR', 'Bulgaria', 'Balkan, Eastern Europe', 'Europe', '+359', 'BGN', 'Bulgarian lev');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BF', 'BFA', 'Burkina Faso', 'West Africa', 'Africa', '+226', 'XOF', 'CFA Franc BCEAO');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BI', 'BDI', 'Burundi', 'Eastern Africa, African Great Lakes', 'Africa', '+257', 'BIF', 'Burundian franc');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('KH', 'KHM', 'Kingdom of Cambodia', 'South-East Asia', 'Asia', '+855', 'KHR', 'Cambodian riel');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CM', 'CMR', 'Cameroon', 'Central Africa', 'Africa', '+237', 'XAF', 'CFA Franc BEAC');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CA', 'CAN', 'Canada', 'North North America', 'North America', '+1', 'CAD', 'Canadian dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CV', 'CPV', 'Cape Verde', 'West Africa', 'Africa', '+238', 'CVE', 'Cape Verde escudo');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('KY', 'CYM', 'Cayman Islands', 'Greater Antilles, Caribbean', 'Caraibes', '+1-345', 'KYD',
        'Cayman Islands dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CF', 'CAF', 'Central African Republic', 'Central Africa', 'Africa', '+236', 'XAF', 'CFA Franc BEAC');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('TD', 'TCD', 'Chad', 'Central Africa', 'Africa', '+235', 'XAF', 'CFA Franc BEAC');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CL', 'CHL', 'Chile', 'Western South America', 'South and Central America', '+56', 'CLP', 'Chilean peso');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CN', 'CHN', 'China', 'Eastern Asia', 'Asia', '+86', 'CNY', 'Chinese yuan renminbi (RMB)');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CX', 'CXR', 'Christmas Island', 'Southeast Asia', 'Pacific', '+61', 'AUD', 'Australian dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CC', 'CCK', 'Cocos (Keeling) Islands', 'South-East Asia, Australia', 'Pacific', '+61', 'AUD',
        'Australian dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CO', 'COL', 'Colombia', 'North West South America', 'South and Central America', '+57', 'COP',
        'Colombian peso');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('KM', 'COM', 'Comoros', 'Eastern Africa', 'Africa', '+269', 'KMF', 'Comoro franc');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CG', 'COG', 'Congo (Brazzaville)', 'Central Africa', 'Africa', '+242', 'XAF', 'CFA Franc BEAC');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CK', 'COK', 'Cook Islands', 'Polynesia, Oceania', 'Pacific', '+682', 'NZD', 'New Zealand dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CR', 'CRI', 'Costa Rica', 'Central America', 'South and Central America', '+506', 'CRC', 'Costa Rican colon');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CI', 'CIV', 'Côte d''Ivoire', 'West Africa', 'Africa', '+255', 'XOF', 'CFA Franc BCEAO');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('HR', 'HRV', 'Croatia', 'Balkan Peninsula', 'East Europe', '+385', 'HRK', 'Croatian kuna');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CU', 'CUB', 'Cuba', 'Greater Antilles, Caribbean', 'Caraibes', '+53', 'CUC', 'Cuban convertible Peso');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CW', 'CUW', 'Curaçao', 'Greater Antilles, Caribbean', 'Caraibes', '+599', 'ANG',
        'Netherlands Antillean guilder');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CY', 'CYP', 'Cyprus', 'Mediterranean, Western Asia', 'Europe', '+357', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CZ', 'CZE', 'Czech Republic', 'Eastern Europe', 'Europe', '+420', 'CZK', 'Czech koruna');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CD', 'COD', 'Democratic Republic of the Congo', 'Central Africa', 'Africa', '+243', 'CDF', 'Congolese franc');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('DK', 'DNK', 'Denmark', 'Northern Europe', 'Europe', '+45', 'DKK', 'Danish krone');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('DJ', 'DJI', 'Republic of Djibouti', 'Eastern Africa', 'Africa', '+253', 'DJF', 'Djiboutian franc');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('DM', 'DMA', 'Dominica', 'Lesser Antilles, Caribbean', 'Caraibes', '+1-767', 'XCD', 'East Caribbean dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('DO', 'DOM', 'Dominican Republic', 'Greater Antilles, Caribbean', 'Caraibes', '+1-809', 'DOP',
        'Dominican peso');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('TL', 'TLS', 'Democratic Republic of Timor-Leste', 'South-East Asia', 'Asia', '+670', 'USD', 'US dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('EC', 'ECU', 'Ecuador', 'North West South America', 'South and Central America', '+593', 'USD', 'US dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('EG', 'EGY', 'Egypt', 'Africa, Middle East', 'Africa', '+20', 'EGP', 'Egyptian pound');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SV', 'SLV', 'El Salvador', 'Central America', 'South and Central America', '+503', 'SVC', 'Salvadoran colon');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GQ', 'GNQ', 'Equatorial Guinea', 'Central Africa', 'Africa', '+240', 'XOF', 'CFA Franc BCEAO');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('ER', 'ERI', 'Eritrea', 'Eastern Africa', 'Africa', '+291', 'ERN', 'Eritrean nakfa');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('EE', 'EST', 'Estonia', 'Northern Europe', 'Europe', '+372', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('ET', 'ETH', 'Ethiopia', 'Eastern Africa', 'Africa', '+251', 'ETB', 'Ethipian birr');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('FK', 'FLK', 'Falkland Islands (Malvinas)', 'Southern South America', 'Antarctica', '+500', 'FKP',
        'Falkland Islands pound');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('FO', 'FRO', 'Faroe Islands', 'Northern Europe', 'Europe', '+298', 'DKK', 'Danish krone');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('FJ', 'FJI', 'Fiji', 'Melanesia, Oceania', 'Pacific', '+679', 'FJD', 'Fiji dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('FI', 'FIN', 'Finland', 'Northern Europe', 'Europe', '+358', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('FR', 'FRA', 'France', 'Western Europe', 'Europe', '+33', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GF', 'GUF', 'French Guiana', 'Northern South America', 'South and Central America', '+594', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('PF', 'PYF', 'French Polynesia', 'Polynesia, Oceania', 'Pacific', '+689', 'XPF', 'French pacific franc');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('TF', 'ATF', 'French Southern Territories', 'Southern Indian Ocean', 'Antarctica', '+262', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GA', 'GAB', 'Gabon', 'Central Africa', 'Africa', '+241', 'XAF', 'CFA Franc BEAC');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GM', 'GMB', 'Gambia', 'West Africa', 'Africa', '+220', 'GMD', 'Gambian dalasi');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GE', 'GEO', 'Georgia', 'Caucasus', 'Europe', '+995', 'GEL', 'Georgian lari');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('DE', 'DEU', 'Germany', 'Western Europe', 'Europe', '+49', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GH', 'GHA', 'Ghana', 'West Africa', 'Africa', '+233', 'GHS', 'Ghanaian Cedi');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GI', 'GIB', 'Gibraltar', 'Southern Europe', 'Europe', '+350', 'GIP', 'Gibraltar pound');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GR', 'GRC', 'Greece', 'Southern Europe', 'Europe', '+30', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GL', 'GRL', 'Greenland', 'North America', 'North America', '+299', 'DKK', 'Danish krone');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GD', 'GRD', 'Grenada', 'Lesser Antilles, Caribbean', 'Caraibes', '+1-473', 'XCD', 'East Caribbean dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GP', 'GLP', 'Guadeloupe', 'Lesser Antilles, Caribbean', 'Caraibes', '+590', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GU', 'GUM', 'Guam', 'Micronesia, Oceania', 'Pacific', '+1-671', 'USD', 'US dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GT', 'GTM', 'Guatemala', 'Central America', 'South and Central America', '+502', 'GTQ', 'Guatemalan quetzal');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GG', 'GGY', 'Guernsey', 'Northern Europe', 'Europe', '+44', 'GGP', 'Guernsey Pound');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GN', 'GIN', 'Guinea', 'West Africa', 'Africa', '+224', 'GNF', 'Guinean franc');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GW', 'GNB', 'Guinea-Bissau', 'West Africa', 'Africa', '+245', 'XAF', 'CFA Franc BEAC');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GY', 'GUY', 'Guyana', 'North Eastern South America', 'South and Central America', '+592', 'GYD',
        'Guyanese dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('HT', 'HTI', 'Haiti', 'Greater Antilles, Caribbean', 'Caraibes', '+509', 'HTG', 'Haitian gourde');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('HM', 'HMD', 'Heard Island and McDonald Mcdonald Islands', 'Australia/Oceania', 'Pacific', '+672', 'AUD',
        'Australian dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('VA', 'VAT', 'Holy See (Vatican City State)', 'Southern Europe within Italy', 'Europe', '+379', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('HN', 'HND', 'Honduras', 'Central America', 'South and Central America', '+504', 'HNL', 'Honduran lempira');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('HK', 'HKG', 'Hong Kong', 'Eastern Asia', 'Asia', '+852', 'HKD', 'Hong Kong dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('HU', 'HUN', 'Hungary', 'Eastern Europe', 'Europe', '+36', 'HUF', 'Hungarian forint');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('IS', 'ISL', 'Iceland', 'Northern Europe', 'Europe', '+354', 'ISK', 'Icelandic króna');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('IN', 'IND', 'India', 'South-Central Asia', 'Asia', '+91', 'INR', 'Indian rupee');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('ID', 'IDN', 'Indonesia', 'Maritime South-East Asia', 'Asia', '+62', 'IDR', 'Indonesian rupiah');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('IR', 'IRN', 'Iran, Islamic Republic of', 'South-Central Asia', 'Middle East', '+98', 'IRR', 'Iranian rial');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('IQ', 'IRQ', 'Iraq', 'Middle East, Western Asia', 'Middle East', '+964', 'IQD', 'Iraqi dinar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('IE', 'IRL', 'Republic of Ireland', 'Northern Europe', 'Europe', '+353', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('IM', 'IMN', 'Isle of Man', 'Northern Europe', 'Europe', '+44', 'IMP', 'Manx pound');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('IL', 'ISR', 'Israel', 'Middle East, Western Asia', 'Middle East', '+972', 'ILS', 'Israeli new shekel');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('IT', 'ITA', 'Italy', 'Southern Europe', 'Europe', '+39', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('JM', 'JAM', 'Jamaica', 'Greater Antilles, Caribbean', 'Caraibes', '+1-876', 'JMD', 'Jamaican dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('JP', 'JPN', 'Japan', 'Eastern Asia', 'Asia', '+81', 'JPY', 'Japanese yen');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('JE', 'JEY', 'Jersey', 'Northern Europe', 'Europe', '+44', 'JEP', 'Jersey pound');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('JO', 'JOR', 'Jordan', 'Middle East, Western Asia', 'Middle East', '+962', 'JOD', 'Jordanian dinar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('KZ', 'KAZ', 'Kazakhstan', 'Central Asia', 'Asia', '+7', 'KZT', 'Kazakhstani tenge');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('KE', 'KEN', 'Kenya', 'Eastern Africa', 'Africa', '+254', 'KES', 'Kenyan shilling');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('KI', 'KIR', 'Kiribati', 'Micronesia, Oceania', 'Asia', '+686', 'AUD', 'Australian dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('KP', 'PRK', 'Korea, Democratic Peoples Republic of', 'Eastern Asia', 'Asia', '+850', 'KPW',
        'North Korean won');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('KR', 'KOR', 'Korea, Republic of', 'Eastern Asia', 'Asia', '+82', 'KPW', 'South Korean won');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('XK', 'KOS', 'Republic of Kosovo', 'Southern Europe', 'Europe', '+383', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('KW', 'KWT', 'Kuwait', 'Middle East, Western Asia', 'Middle East', '+965', 'KWD', 'Kuwaiti dinar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('KG', 'KGZ', 'Kyrgyzstan', 'Central Asia', 'Asia', '+996', 'KGS', 'Kyrgyzstani som');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('LA', 'LAO', 'Lao Peoples Democratic Republic', 'South-East Asia', 'Asia', '+856', 'LAK', 'Lao kip');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('LV', 'LVA', 'Latvia', 'Northern Europe', 'Europe', '+371', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('LB', 'LBN', 'Lebanon', 'Middle East, Western Asia', 'Middle East', '+961', 'LBP', 'Lebanese pound');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('LS', 'LSO', 'Lesotho', 'Southern Africa', 'Africa', '+266', 'LSL', 'Lesotho loti');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('LR', 'LBR', 'Liberia', 'West Africa', 'Africa', '+231', 'LRD', 'Liberian dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('LY', 'LBY', 'Libya', 'Northern Africa', 'Africa', '+218', 'LYD', 'Libyan dinar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('LI', 'LIE', 'Liechtenstein', 'Western Europe', 'Europe', '+423', 'CHF', 'Swiss franc');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('LT', 'LTU', 'Lithuania', 'Northern Europe', 'Europe', '+370', 'LTL', 'Lithuanian litas');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('LU', 'LUX', 'Luxembourg', 'Western Europe', 'Europe', '+352', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MO', 'MAC', 'Macao', 'Eastern Asia', 'Asia', '+853', 'MOP', 'Macanese pataca');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MK', 'MKD', 'Macedonia, the Former Yugoslav Republic of', 'Southern Europe', 'Europe', '+389', 'MKD',
        'Macedonian denar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MG', 'MDG', 'Madagascar', 'Eastern Africa', 'Africa', '+261', 'MGA', 'Malagasy ariayry');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MW', 'MWI', 'Malawi', 'Eastern Africa', 'Africa', '+265', 'MWK', 'Malawian kwacha');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MY', 'MYS', 'Malaysia', 'Southeast Asia', 'Asia', '+60', 'MYR', 'Malaysian ringgit');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MV', 'MDV', 'Maldives', 'South-Central Asia', 'Asia', '+960', 'MVR', 'Maldivian rufiyaa');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('ML', 'MLI', 'Mali', 'West Africa', 'Africa', '+223', 'XOF', 'CFA Franc BCEAO');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MT', 'MLT', 'Malta', 'Southern Europe', 'Europe', '+356', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MH', 'MHL', 'Marshall Islands', 'Micronesia, Oceania', 'Pacific', '+692', 'USD', 'United States dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MQ', 'MTQ', 'Martinique', 'Lesser Antilles, Caribbean', 'Caraibes', '+596', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MR', 'MRT', 'Mauritania', 'West Africa', 'Africa', '+222', 'MRO', 'Mauritanian ouguiya');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MU', 'MUS', 'Mauritius', 'Eastern Africa', 'Africa', '+230', 'MUR', 'Mauritian rupee');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('YT', 'MYT', 'Mayotte', 'Eastern Africa', 'Africa', '+93', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MX', 'MEX', 'Mexico', 'North America', 'South and Central America', '+52', 'MXN', 'Mexican peso');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('FM', 'FSM', 'Micronesia, Federated States of', 'Micronesia, Oceania', 'Pacific', '+691', 'USD',
        'United States Dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MD', 'MDA', 'Moldova, Republic of', 'Eastern Europe', 'Europe', '+373', 'MDL', 'Moldovan leu');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MC', 'MCO', 'Monaco', 'Southern Europe', 'Europe', '+377', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MN', 'MNG', 'Mongolia', 'Eastern Asia', 'Asia', '+976', 'MNT', 'Mongolian tugrik');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('ME', 'MNE', 'Montenegro', 'Southern Europe', 'Europe', '+382', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MS', 'MSR', 'Montserrat', 'Lesser Antilles, Caribbean', 'Caraibes', '+1-664', 'XCD', 'East Caribbean dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MA', 'MAR', 'Morocco', 'Northern Africa', 'Africa', '+212', 'MAD', 'Moroccan dirham');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MZ', 'MOZ', 'Mozambique', 'Eastern Africa', 'Africa', '+258', 'MZN', 'Mozambican metical');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MM', 'MMR', 'Myanmar', 'Southeast Asia', 'Asia', '+95', 'MMK', 'Myanma kyat');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('NA', 'NAM', 'Namibia', 'Southern Africa', 'Africa', '+264', 'NAD', 'Namibian dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('NR', 'NRU', 'Nauru', 'Micronesia, Oceania', 'Pacific', '+674', 'AUD', 'Australian dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('NP', 'NPL', 'Nepal', 'South-Central Asia', 'Asia', '+977', 'NPR', 'Nepalese rupee');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AN', 'ANT', 'Netherland Antilles', 'Caribbean', 'Caraibes', '+599', 'ANG', 'Netherlands Antillean guilder');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('NL', 'NLD', 'Netherlands', 'Western Europe', 'Occidental Europe', '+31', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('NC', 'NCL', 'New Caledonia', 'Melanesia, Oceania', 'Pacific', '+687', 'XPF', 'French pacific franc');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('NZ', 'NZL', 'New Zealand', 'Oceania, Australia', 'Pacific', '+64', 'NZD', 'New Zealand dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('NI', 'NIC', 'Nicaragua', 'Central America', 'South and Central America', '+505', 'NIO', 'Nicaraguan córdoba');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('NE', 'NER', 'Niger', 'West Africa', 'Africa', '+227', 'XOF', 'CFA Franc BCEAO');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('NG', 'NGA', 'Nigeria', 'West Africa', 'Africa', '+234', 'NGN', 'Nigerian Naira');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('NU', 'NIU', 'Niue', 'Polynesia, Oceania', 'Pacific', '+683', 'NZD', 'New Zealand dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('NF', 'NFK', 'Norfolk Island', 'South Pacific', 'Pacific', '+672', 'AUD', 'Australian dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MP', 'MNP', 'Northern Mariana Islands', 'Micronesia, Oceania', 'Pacific', '+1', 'USD', 'United States dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('NO', 'NOR', 'Norway', 'Northern Europe', 'Europe', '+47', 'NOK', 'Norwegian krone');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('OM', 'OMN', 'Oman', 'Middle East', 'Middle East', '+968', 'OMR', 'Omani rial');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('PK', 'PAK', 'Pakistan', 'South-Central Asia', 'Asia', '+92', 'PKR', 'Pakistani rupee');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('PW', 'PLW', 'Palau', 'Micronesia, Oceania', 'Pacific', '+680', 'USD', 'United States dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('PS', 'PSE', 'Palestine, State of', 'Middle East, Western Asia', 'Middle East', '+970', 'ILS',
        'Israeli new shekel');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('PA', 'PAN', 'Panama', 'Central America', 'Pacific', '+507', 'PAB', 'Panamanian balboa');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('PG', 'PNG', 'Papua New Guinea', 'Maritime Southeast Asia, Melanesia, Oceania', 'Asia', '+675', 'PGK',
        'Papua New Guinean kina');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('PY', 'PRY', 'Paraguay', 'Central South America', 'South and Central America', '+595', 'PYG',
        'Paraguayan guaraní');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('PE', 'PER', 'Peru', 'Western South America', 'South and Central America', '+51', 'PEN', 'Peruvian nuevo sol');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('PH', 'PHL', 'Philippines', 'Southeast Asia', 'Asia', '+63', 'PHP', 'Philippine peso');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('PN', 'PCN', 'Pitcairn', 'Polynesia, Oceania', 'Pacific', '+870', 'NZD', 'New Zealand dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('PL', 'POL', 'Poland', 'Eastern Europe', 'Europe', '+48', 'PLN', 'Polish zloty');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('PT', 'PRT', 'Portugal', 'Southern Europe', 'Europe', '+351', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('PR', 'PRI', 'Puerto Rico', 'Greater Antilles, Caribbean', 'Caraibes', '+1', 'USD', 'United States dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('QA', 'QAT', 'Qatar', 'Arabian Peninsula, Middle East', 'Middle East', '+974', 'QAR', 'Qatari riyal');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('RO', 'ROU', 'Romania', 'Eastern Europe', 'Europe', '+40', 'RON', 'Romanian new Leu');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('RU', 'RUS', 'Russian Federation', 'Eastern Europe', 'Europe', '+7', 'RUB', 'Russian ruble');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('RW', 'RWA', 'Rwanda', 'Eastern Africa', 'Africa', '+250', 'RWF', 'Rwandan franc');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('RE', 'REU', 'Reunion', 'Eastern Africa', 'Africa', '+262', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('BL', 'BLM', 'Saint Barthélemy', 'Caribbean island', 'North America', '+590', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SH', 'SHN', 'Saint Helena', 'British Overseas Territory', 'Africa', '+290', 'SHP', 'Saint Helena pound');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('KN', 'KNA', 'Saint Kitts and Nevis', 'Lesser Antilles, Caribbean', 'Caraibes', '+1-869', 'XCD',
        'East Caribbean dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('LC', 'LCA', 'Saint Lucia', 'Lesser Antilles, Caribbean', 'Caraibes', '+1-758', 'XCD', 'East Caribbean dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('MF', 'MAF', 'Collectivity of Saint Martin', 'Lesser Antilles, Caribbean', 'Caraibes', '+590', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('PM', 'SPM', 'Saint Pierre and Miquelon', 'Lesser Antilles, Caribbean', 'Caraibes', '+508', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('VC', 'VCT', 'Saint Vincent and the Grenadines', 'Lesser Antilles, Caribbean', 'Caraibes', '+1-784', 'XCD',
        'East Caribbean dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('WS', 'WSM', 'Samoa', 'Polynesia, Oceania', 'Pacific', '+685', 'WST', 'Samoan tala');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SM', 'SMR', 'San Marino', 'Southern Europe within Italy', 'Europe', '+378', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('ST', 'STP', 'Sao Tome and Principe', 'Central Africa', 'Africa', '+239', 'STD', 'São Tomé dobra');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SA', 'SAU', 'Saudi Arabia', 'Arabian Peninsula, Middle East', 'Middle East', '+966', 'SAR', 'Saudi riyal');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SN', 'SEN', 'Senegal', 'West Africa', 'Africa', '+221', 'XOF', 'CFA Franc BCEAO');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('RS', 'SRB', 'Serbia', 'Southern Europe', 'Europe', '+381', 'RSD', 'Serbian dinar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SC', 'SYC', 'Seychelles', 'Eastern Africa', 'Africa', '+248', 'SCR', 'Seychelles rupee');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SL', 'SLE', 'Sierra Leone', 'West Africa', 'Africa', '+232', 'SLL', 'Sierra Leonean leone');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SG', 'SGP', 'Singapore', 'Southeast Asia', 'Asia', '+65', 'SGD', 'Singapore dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SX', 'SXM', 'Sint Maarten (Dutch part)', 'Lesser Antilles, Caribbean', 'Caraibes', '+1-721', 'ANG',
        'Netherlands Antillean guilder');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SK', 'SVK', 'Slovakia', 'Eastern Europe', 'Europe', '+421', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SI', 'SVN', 'Slovenia', 'Southern Europe', 'Europe', '+386', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SB', 'SLB', 'Solomon Islands', 'Melanesia, Oceania', 'Pacific', '+677', 'SBD', 'Solomon Islands dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SO', 'SOM', 'Somalia', 'Eastern Africa', 'Africa', '+252', 'SOS', 'Somali shilling');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('ZA', 'ZAF', 'South Africa', 'Southern Africa', 'Africa', '+27', 'ZAR', 'South African rand');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GS', 'SGS', 'South Georgia and the South Sandwich Islands', 'Southern Atlantic', 'Antarctic', '+500', 'GBP',
        'Pound sterling');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SS', 'SSD', 'South Sudan', 'East-Central Africa', 'Africa', '+211', 'SDG', 'Sudanese pound');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('ES', 'ESP', 'Spain', 'Southern Europe', 'Europe', '+34', 'EUR', 'Euro');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('LK', 'LKA', 'Sri Lanka', 'South-Central Asia', 'Asia', '+94', 'LKR', 'Sri Lankan rupee');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SD', 'SDN', 'Sudan', 'Northern Africa', 'Africa', '+249', 'SDG', 'Sudanese pound');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SR', 'SUR', 'Suriname', 'North-Eastern South America', 'South and Central America', '+597', 'SRD',
        'Surinamese dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SJ', 'SJM', 'Svalbard and Jan Mayen', 'Northern Europe', 'Europe', '+47', 'NOK', 'Norwegian krone');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SZ', 'SWZ', 'Swaziland', 'Southern Africa', 'Africa', '+268', 'SZL', 'Swazi lilangeni');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SE', 'SWE', 'Sweden', 'Northern Europe', 'Europe', '+46', 'SEK', 'Swedish krona');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('CH', 'CHE', 'Switzerland', 'Western Europe', 'Europe', '+41', 'CHF', 'Swiss franc');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('SY', 'SYR', 'Syrian Arab Republic', 'Middle East, Western Asia', 'Middle East', '+963', 'SYP', 'Syrian pound');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('TW', 'TWN', 'Taiwan, Province of China', 'Eastern Asia', 'Asia', '+886', 'TWD', 'New Taiwan dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('TJ', 'TJK', 'Tajikistan', 'Central Asia', 'Asia', '+992', 'TJS', 'Tajikistani somoni');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('TZ', 'TZA', 'United Republic of Tanzania', 'Eastern Africa', 'Africa', '+255', 'TZS', 'Tanzanian shilling');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('TH', 'THA', 'Thailand', 'South-East Asia', 'Asia', '+66', 'THB', 'Thai baht');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('TG', 'TGO', 'Togo', 'West Africa', 'Africa', '+228', 'XOF', 'CFA Franc BCEAO');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('TK', 'TKL', 'Tokelau', 'Oceania/Australia', 'Pacific', '+690', 'NZD', 'New Zealand dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('TO', 'TON', 'Tonga', 'Polynesia, Oceania', 'Pacific', '+676', 'TOP', 'Tongan pa anga');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('TT', 'TTO', 'Trinidad and Tobago', 'Northern South America, Caribbean', 'Caraibes', '+1-868', 'TTD',
        'Trinidad dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('TN', 'TUN', 'Tunisia', 'Northern Africa', 'Africa', '+216', 'TND', 'Tunisian dinar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('TR', 'TUR', 'Turkey', 'Southeastern Europe, Western Asia', 'Europe', '+90', 'TRY', 'Turkish lira');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('TM', 'TKM', 'Turkmenistan', 'Central Asia', 'Asia', '+993', 'TMT', 'Turkmenistani new manat');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('TC', 'TCA', 'Turks and Caicos Islands', 'Caribbean, parts of the Bahamas island chain', 'Caraibes', '+1-649',
        'USD', 'US dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('TV', 'TUV', 'Tuvalu', 'Polynesia, Oceania', 'Pacific', '+688', 'AUD', 'Australian dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('UG', 'UGA', 'Uganda', 'Eastern Africa', 'Africa', '+256', 'UGX', 'Ugandan shilling');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('UA', 'UKR', 'Ukraine', 'Eastern Europe', 'Europe', '+380', 'UAH', 'Ukrainian hryvnia');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('AE', 'ARE', 'United Arab Emirates', 'Arabian Peninsula, Middle East', 'Middle East', '+971', 'AED',
        'UAE dirham');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('GB', 'GBR', 'United Kingdom', 'Northern Europe', 'Europe', '+44', 'GBP', 'Pound sterling');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('US', 'USA', 'United States', 'North America', 'North America', '+1', 'USD', 'US dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('UM', 'UMI', 'United States Minor Outlying Islands', 'North America', 'North America', '+1', 'USD',
        'US dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('UY', 'URY', 'Uruguay', 'Central East South America', 'South and Central America	', '+598', 'UYU',
        'Urugayan peso');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('UZ', 'UZB', 'Uzbekistan', 'Central Asia', 'Asia', '+998', 'UZS', 'Uzbekitan som');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('VU', 'VUT', 'Vanuatu', 'Melanesia, Oceania', 'Pacific', '+678', 'VUV', 'Vanuatu vatu');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('VE', 'VEN', 'Venezuela', 'Northern South America', 'South and Central America', '+58', 'VEF',
        'Venezualan bolivar fuerte');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('VN', 'VNM', 'Việt Nam', 'South-East Asia', 'Asia', '+84', 'VND', 'Vietnamese đồng');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('VI', 'VIR', 'US Virgin Islands', 'Lesser Antilles, Caribbean', 'Caraibes', '+1-340', 'USD', 'US dollar');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('WF', 'WLF', 'Wallis and Futuna', 'Polynesia, Oceania', 'Pacific', '+681', 'XPF', 'French pacific franc');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('EH', 'ESH', 'Western Sahara', 'Northern Africa', 'Africa', '+212', 'MAD', 'Moroccan dirham');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('YE', 'YEM', 'Yemen', 'Arabian Peninsula, Middle East', 'Middle East', '+967', 'YER', 'Yemeni rial');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('ZM', 'ZMB', 'Zambia', 'Eastern Africa', 'Africa', '+260', 'ZMW', 'Zambian kwacha');
INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName)
VALUES ('ZW', 'ZWE', 'Zimbabwe', 'Eastern Africa', 'Africa', '+263', 'USD', 'US dollar');

SHOW ERRORS
/

PROMPT "End of Profile Schema."