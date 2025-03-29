PROMPT "Creating Identity Schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      identity.sql                                                    *
 * Created:   02/03/2025, 19:11                                               *
 * Modified:  15/03/2025, 15:59                                               *
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

CREATE TABLE images_tbl
(
    accountid    VARCHAR2(20 BYTE),
    avatar       VARCHAR2(100 BYTE),
    modifiedBy   VARCHAR2(50 BYTE),
    modifiedDate TIMESTAMP
);

CREATE TABLE person_tbl
(
    accountid    VARCHAR2(20 BYTE),
    title        VARCHAR2(50 BYTE),
    firstName    VARCHAR2(100 BYTE),
    middleName   VARCHAR2(100 BYTE),
    lastName     VARCHAR2(100 BYTE),
    zodiac       VARCHAR2(30 BYTE),
    gender       VARCHAR2(30 BYTE),
    birthday     DATE,
    age          VARCHAR2(10 BYTE),
    modifiedBy   VARCHAR2(50 BYTE),
    modifiedDate TIMESTAMP
);

CREATE TABLE address_tbl
(
    accountid    VARCHAR2(20 BYTE),
    firstline    VARCHAR2(100 BYTE),
    secondline   VARCHAR2(100 BYTE),
    thirdline    VARCHAR2(100 BYTE),
    city         VARCHAR2(100 BYTE),
    postcode     VARCHAR2(20 BYTE),
    country      VARCHAR2(100 BYTE),
    modifiedBy   VARCHAR2(50 BYTE),
    modifiedDate TIMESTAMP
);

CREATE TABLE contact_tbl
(
    accountid    VARCHAR2(20 BYTE),
    channel      VARCHAR2(40 BYTE),
    address      VARCHAR2(100 BYTE),
    consent      VARCHAR2(10 BYTE),
    modifiedBy   VARCHAR2(50 BYTE),
    modifiedDate TIMESTAMP
);

PROMPT "Commenting Tables"

-- Comment on tables
COMMENT ON COLUMN images_tbl.accountid IS 'The account identifier for an image';
COMMENT ON COLUMN images_tbl.avatar IS 'This is user avatar image';
COMMENT ON COLUMN images_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN images_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE images_tbl IS 'A user image which is a visual representation of the user is stored here.';

COMMENT ON COLUMN person_tbl.title IS 'This is the title of a given contact (Mr., Ms., Dr., Rev., etc.)';
COMMENT ON COLUMN person_tbl.firstName IS 'This is contact''s first name.';
COMMENT ON COLUMN person_tbl.middleName IS 'This is contact''s middle name.';
COMMENT ON COLUMN person_tbl.lastName IS 'This is contact''s last name.';
COMMENT ON COLUMN person_tbl.gender IS 'This is contact''s Gender.';
COMMENT ON COLUMN person_tbl.birthday IS 'This is contact''s date of birth.';
COMMENT ON COLUMN person_tbl.age IS 'This is contact''s Age.';
COMMENT ON COLUMN person_tbl.zodiac IS 'The Zodiac is an area of the sky that extends approximately 8° north or south of the ecliptic, the apparent path of the Sun across the celestial sphere over the course of the year.';
COMMENT ON COLUMN person_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN person_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE person_tbl IS 'Profile information for a person.';

COMMENT ON COLUMN address_tbl.accountid IS 'The account identifier for a Contact';
COMMENT ON COLUMN address_tbl.firstline IS 'This is the first line of the Address';
COMMENT ON COLUMN address_tbl.secondline IS 'This is the second line of the Address';
COMMENT ON COLUMN address_tbl.thirdline IS 'This is the third line of the Address.';
COMMENT ON COLUMN address_tbl.city IS 'The city in which the Address is located.';
COMMENT ON COLUMN address_tbl.postcode IS 'The postal code/zipcode of the Address.';
COMMENT ON COLUMN address_tbl.country IS 'The country of the Address.';
COMMENT ON COLUMN address_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN address_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE address_tbl IS 'Physical Address Information.';

COMMENT ON COLUMN contact_tbl.accountid IS 'The account identifier for a Contact.';
COMMENT ON COLUMN contact_tbl.channel IS 'This will list of available ways of contact. e.g Phone, email, twitter, facebook etc';
COMMENT ON COLUMN contact_tbl.address IS 'This will be the actual contact Address i.e someone@somewhere.com';
COMMENT ON COLUMN contact_tbl.consent IS 'This is an indicator to say if the medium is a prefer mode of contact or not';
COMMENT ON COLUMN contact_tbl.modifiedBy IS 'Audit column - indicates who made last update.';
COMMENT ON COLUMN contact_tbl.modifiedDate IS 'Audit column - date of last update.';
COMMENT ON TABLE contact_tbl IS 'Profile information for list of contacts';

PROMPT "Setting Constraints"

-- Setting Foreign Key
ALTER TABLE images_tbl
    ADD CONSTRAINT images_fk FOREIGN KEY (accountid) REFERENCES account_tbl (accountid) ON DELETE CASCADE;
ALTER TABLE person_tbl
    ADD CONSTRAINT person_fk FOREIGN KEY (accountid) REFERENCES account_tbl (accountid) ON DELETE CASCADE;
ALTER TABLE address_tbl
    ADD CONSTRAINT address_fk FOREIGN KEY (accountid) REFERENCES account_tbl (accountid) ON DELETE CASCADE;
ALTER TABLE contact_tbl
    ADD CONSTRAINT contact_fk FOREIGN KEY (accountid) REFERENCES account_tbl (accountid) ON DELETE CASCADE;

-- Setting Check Constraint
ALTER TABLE address_tbl
    ADD CONSTRAINT addcou_chk CHECK (country IN ('AF', 'AX', 'AL', 'DZ', 'AS', 'AD', 'AO', 'AI',
                                                 'AQ', 'AG', 'AR', 'AM', 'AW', 'AU', 'AT', 'AZ',
                                                 'BS', 'BH', 'BD', 'BB', 'BY', 'BE', 'BZ', 'BJ',
                                                 'BM', 'BT', 'BO', 'BA', 'BW', 'BV', 'BR', 'IO',
                                                 'BN', 'BG', 'BF', 'BI', 'KH', 'CM', 'CA', 'CV',
                                                 'KY', 'CF', 'TD', 'CL', 'CN', 'CX', 'CC', 'CO',
                                                 'KM', 'CG', 'CD', 'CK', 'CR', 'CI', 'HR', 'CU',
                                                 'CY', 'CZ', 'DK', 'DJ', 'DM', 'DO', 'EC', 'EG',
                                                 'SV', 'GQ', 'ER', 'EE', 'ET', 'FK', 'FO', 'FJ',
                                                 'FI', 'FR', 'GF', 'PF', 'TF', 'GA', 'GM', 'GE',
                                                 'DE', 'GH', 'GI', 'GR', 'GL', 'GD', 'GP', 'GU',
                                                 'GT', 'GG', 'GN', 'GW', 'GY', 'HT', 'HM', 'VA',
                                                 'HN', 'HK', 'HU', 'IS', 'IN', 'ID', 'IR', 'IQ',
                                                 'IE', 'IM', 'IL', 'IT', 'JM', 'JP', 'JE', 'JO',
                                                 'KZ', 'KE', 'KI', 'KP', 'KR', 'KW', 'KG', 'LA',
                                                 'LV', 'LB', 'LS', 'LR', 'LY', 'LI', 'LT', 'LU',
                                                 'MO', 'MK', 'MG', 'MW', 'MY', 'MV', 'ML', 'MT',
                                                 'MH', 'MQ', 'MR', 'MU', 'YT', 'MX', 'FM', 'MD',
                                                 'MC', 'MN', 'MS', 'MA', 'MZ', 'MM', 'NA', 'NR',
                                                 'NP', 'NL', 'AN', 'NC', 'NZ', 'NI', 'NE', 'NG',
                                                 'NU', 'NF', 'MP', 'NO', 'OM', 'PK', 'PW', 'PS',
                                                 'PA', 'PG', 'PY', 'PE', 'PH', 'PN', 'PL', 'PT',
                                                 'PR', 'QA', 'RE', 'RO', 'RU', 'RW', 'SH', 'KN',
                                                 'LC', 'PM', 'VC', 'WS', 'SM', 'ST', 'SA', 'SN',
                                                 'CS', 'SC', 'SL', 'SG', 'SK', 'SI', 'SB', 'SO',
                                                 'ZA', 'GS', 'ES', 'LK', 'SD', 'SR', 'SJ', 'SZ',
                                                 'SE', 'CH', 'SY', 'TW', 'TJ', 'TZ', 'TH', 'TL',
                                                 'TG', 'TK', 'TO', 'TT', 'TN', 'TR', 'TM', 'TC',
                                                 'TV', 'UG', 'UA', 'AE', 'GB', 'US', 'UM', 'UY',
                                                 'UZ', 'VU', 'VE', 'VN', 'VG', 'VI', 'WF', 'EH',
                                                 'YE', 'ZM', 'ZW')) ENABLE;
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
ALTER TABLE person_tbl
    ADD CONSTRAINT pergen_chk CHECK (gender IN ('Male', 'Female')) ENABLE;
ALTER TABLE contact_tbl
    ADD CONSTRAINT channel_chk CHECK (channel IN ('Phone', 'Email', 'Fax', 'Twitter', 'Facebook',
                                                  'LinkedIn', 'Snapchat', 'Website')) ENABLE;
ALTER TABLE contact_tbl
    ADD CONSTRAINT consent_chk CHECK (consent IN ('YES', 'NO')) ENABLE;

-- Create an account history table
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

PROMPT "Creating Triggers"

-- Creating Triggers
CREATE OR REPLACE TRIGGER syncaccount_trg
    AFTER INSERT
    ON account_tbl
    FOR EACH ROW
DECLARE
    v_error_message VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    -- Get unique account ID from accounts and ensure required fields are populated
    INSERT INTO person_tbl (accountid, modifiedBy) VALUES (:NEW.accountid, 'Account Trigger');
    INSERT INTO address_tbl (accountid, modifiedBy) VALUES (:NEW.accountid, 'Account Trigger');
    INSERT INTO images_tbl (accountid, modifiedBy) VALUES (:NEW.accountid, 'Account Trigger');
    INSERT INTO contact_tbl (accountid, modifiedBy) VALUES (:NEW.accountid, 'Account Trigger');

EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'syncaccount_trg for identity: ' || :NEW.accountid,
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER images_trg
    BEFORE INSERT
    ON images_tbl
    FOR EACH ROW
DECLARE
    v_error_message VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    -- Ensure required fields are populated
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
                i_faultservice => 'images_trg (INSERT): ' || :NEW.accountid,
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
    INSERT INTO images_history_tbl(accountid, avatar, modifiedBy, modifiedDate, modifiedReason)
    VALUES (:OLD.accountid, :OLD.avatar, :OLD.modifiedBy, :OLD.modifiedDate, v_modified_reason);
EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'images_trg (UPDATE/DELETE): ' || :NEW.accountid,
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
    v_error_message VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    IF :NEW.modifiedBy IS NULL THEN SELECT USER INTO :NEW.modifiedBy FROM DUAL; END IF;
    IF :NEW.modifiedDate IS NULL THEN SELECT SYSTIMESTAMP INTO :NEW.modifiedDate FROM DUAL; END IF;
    IF INSERTING THEN
        -- Ensure required fields are populated
        IF :NEW.accountid IS NULL THEN
            RAISE_APPLICATION_ERROR(-20004, 'Account Identifier is Mandatory and cannot be empty.');
        END IF;
        IF :NEW.birthday IS NOT NULL THEN
            IF (:NEW.birthday > SYSDATE) THEN
                RAISE_APPLICATION_ERROR(-20011, 'Date Of Birth Cannot Be In The Future');
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
            INTO :NEW.zodiac
            FROM DUAL;
        END IF;
    ELSIF UPDATING THEN
        -- Ensure required fields are populated
        IF :NEW.accountid IS NULL AND :OLD.accountid IS NOT NULL THEN
            SELECT :OLD.accountid INTO :NEW.accountid FROM DUAL;
        END IF;
        IF :NEW.gender IS NULL AND :OLD.gender IS NOT NULL THEN SELECT :OLD.gender INTO :NEW.gender FROM DUAL; END IF;
        IF :NEW.birthday IS NOT NULL THEN
            IF (:NEW.birthday > SYSDATE) THEN
                RAISE_APPLICATION_ERROR(-20011, 'Date Of Birth Cannot Be In The Future');
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
            INTO :NEW.zodiac
            FROM DUAL;
        END IF;
    END IF;


EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'person_trg (INSERT): ' || :NEW.accountid,
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
    INSERT INTO person_history_tbl(accountid, title, firstName, middleName, lastName, zodiac, gender, birthday, age,
                                   modifiedBy, modifiedDate, modifiedReason)
    VALUES (:OLD.accountid, :OLD.title, :OLD.firstName, :OLD.middleName, :OLD.lastName, :OLD.zodiac,
            :OLD.gender, :OLD.birthday, :OLD.age, :OLD.modifiedBy, :OLD.modifiedDate,
            v_modified_reason);
EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'person_trg (UPDATE/DELETE): ' || :NEW.accountid,
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
    v_error_message VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    -- Ensure required fields are populated
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
                i_faultservice => 'address_trg (INSERT): ' || :NEW.accountid,
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
    INSERT INTO address_history_tbl(accountid, firstline, secondline, thirdline, city, postcode, country, modifiedBy,
                                    modifiedDate, modifiedReason)
    VALUES (:OLD.accountid, :OLD.firstline, :OLD.secondline, :OLD.thirdline, :OLD.city, :OLD.postcode, :OLD.country,
            :OLD.modifiedBy, :OLD.modifiedDate, v_modified_reason);
EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'address_trg (UPDATE/DELETE): ' || :NEW.accountid,
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
    v_error_message VARCHAR2(4000);
    v_response      VARCHAR2(100);
BEGIN
    -- Ensure required fields are populated
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
                i_faultservice => 'contact_trg (INSERT): ' || :NEW.accountid,
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
    INSERT INTO contact_history_tbl(accountid, channel, address, consent, modifiedBy, modifiedDate, modifiedReason)
    VALUES (:OLD.accountid, :OLD.channel, :OLD.address, :OLD.consent, :OLD.modifiedBy, :OLD.modifiedDate,
            v_modified_reason);
EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'contact_trg (UPDATE/DELETE): ' || :NEW.accountid,
                o_response => v_response
        );
        RAISE;
END;
/

PROMPT "Enabling Triggers"

-- Enable Triggers
ALTER TRIGGER syncaccount_trg ENABLE;
ALTER TRIGGER person_trg ENABLE;
ALTER TRIGGER person_audit_trg ENABLE;
ALTER TRIGGER address_trg ENABLE;
ALTER TRIGGER address_audit_trg ENABLE;
ALTER TRIGGER contact_trg ENABLE;
ALTER TRIGGER contact_audit_trg ENABLE;
ALTER TRIGGER images_trg ENABLE;
ALTER TRIGGER images_audit_trg ENABLE;


PROMPT "Creating Identity Header Package"

-- Create Packages
CREATE OR REPLACE PACKAGE identity_pkg
AS
    /* $Header: identity_pkg. 1.0.0 15-Mar-25 15:59 Package
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
Name: identity_pkg
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
    -- Create or Update Identity
    PROCEDURE SaveImage(
        i_accountid IN images_tbl.accountid%TYPE,
        i_avatar IN images_tbl.avatar%TYPE,
        i_modifiedBy IN images_tbl.modifiedBy%TYPE,
        o_response OUT VARCHAR2);

    PROCEDURE SavePerson(
        i_accountid IN person_tbl.accountid%TYPE,
        i_title IN person_tbl.title%TYPE,
        i_firstName IN person_tbl.firstName%TYPE,
        i_middleName IN person_tbl.middleName%TYPE,
        i_lastName IN person_tbl.lastName%TYPE,
        i_gender IN person_tbl.gender%TYPE,
        i_birthday IN person_tbl.birthday%TYPE,
        i_modifiedBy IN person_tbl.modifiedBy%TYPE,
        o_response OUT VARCHAR2);

    PROCEDURE SaveAddress(
        i_accountid IN address_tbl.accountid%TYPE,
        i_firstline IN address_tbl.firstline%TYPE,
        i_secondline IN address_tbl.secondline%TYPE,
        i_thirdline IN address_tbl.thirdline%TYPE,
        i_city IN address_tbl.city%TYPE,
        i_postcode IN address_tbl.postcode%TYPE,
        i_country IN address_tbl.country%TYPE,
        i_modifiedBy IN address_tbl.modifiedBy%TYPE,
        o_response OUT VARCHAR2);

    PROCEDURE SaveContact(
        i_accountid IN contact_tbl.accountid%TYPE,
        i_channel IN contact_tbl.channel%TYPE,
        i_address IN contact_tbl.address%TYPE,
        i_consent IN contact_tbl.consent%TYPE,
        i_modifiedBy IN contact_tbl.modifiedBy%TYPE,
        o_response OUT VARCHAR2);

END identity_pkg;
/

PROMPT "Creating Identity Body Package"

-- Create Packages
CREATE OR REPLACE PACKAGE BODY identity_pkg
AS
    /* $Body: identity_pkg. 1.0.0 15-Mar-25 15:59 Package
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
Name: identity_pkg
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
    -- Create or Update Identity
    PROCEDURE SaveImage(
        i_accountid IN images_tbl.accountid%TYPE,
        i_avatar IN images_tbl.avatar%TYPE,
        i_modifiedBy IN images_tbl.modifiedBy%TYPE,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE images_tbl
        SET accountid  = i_accountid,
            avatar     = i_avatar,
            modifiedBy = i_modifiedBy
        WHERE accountid = i_accountid
        RETURNING accountid INTO o_response;
        IF SQL%NOTFOUND THEN
            INSERT INTO images_tbl(accountid, avatar, modifiedBy)
            VALUES (i_accountid, i_avatar, i_modifiedBy)
            RETURNING accountid INTO o_response;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN ROLLBACK;
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'identity_pkg.SaveImage: ' || i_accountid,
                o_response => v_response
        );
        o_response := SQLCODE || SUBSTR(SQLERRM, 1, 2000);
    END SaveImage;

    PROCEDURE SavePerson(
        i_accountid IN person_tbl.accountid%TYPE,
        i_title IN person_tbl.title%TYPE,
        i_firstName IN person_tbl.firstName%TYPE,
        i_middleName IN person_tbl.middleName%TYPE,
        i_lastName IN person_tbl.lastName%TYPE,
        i_gender IN person_tbl.gender%TYPE,
        i_birthday IN person_tbl.birthday%TYPE,
        i_modifiedBy IN person_tbl.modifiedBy%TYPE,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE person_tbl
        SET accountid  = i_accountid,
            title      = i_title,
            firstName  = i_firstName,
            middleName = i_middleName,
            lastName   = i_lastName,
            gender     = i_gender,
            birthday   = i_birthday,
            modifiedBy = i_modifiedBy
        WHERE accountid = i_accountid
        RETURNING accountid INTO o_response;
        IF SQL%NOTFOUND THEN
            INSERT INTO person_tbl(accountid, title, firstName, middleName, lastName, gender, birthday, modifiedBy)
            VALUES (i_accountid, i_title, i_firstName, i_middleName, i_lastName, i_gender, i_birthday, i_modifiedBy)
            RETURNING accountid INTO o_response;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN ROLLBACK;
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'identity_pkg.SavePerson: ' || i_accountid,
                o_response => v_response
        );
        o_response := SQLCODE || SUBSTR(SQLERRM, 1, 2000);
    END SavePerson;

    PROCEDURE SaveAddress(
        i_accountid IN address_tbl.accountid%TYPE,
        i_firstline IN address_tbl.firstline%TYPE,
        i_secondline IN address_tbl.secondline%TYPE,
        i_thirdline IN address_tbl.thirdline%TYPE,
        i_city IN address_tbl.city%TYPE,
        i_postcode IN address_tbl.postcode%TYPE,
        i_country IN address_tbl.country%TYPE,
        i_modifiedBy IN address_tbl.modifiedBy%TYPE,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE address_tbl
        SET accountid  = i_accountid,
            firstline  = i_firstline,
            secondline = i_secondline,
            thirdline  = i_thirdline,
            city       = i_city,
            postcode   = i_postcode,
            country    = i_country,
            modifiedBy = i_modifiedBy
        WHERE accountid = i_accountid
        RETURNING accountid INTO o_response;
        IF SQL%NOTFOUND THEN
            INSERT INTO address_tbl(accountid, firstline, secondline, thirdline, city, postcode, country, modifiedBy)
            VALUES (i_accountid, i_firstline, i_secondline, i_thirdline, i_city, i_postcode, i_country, i_modifiedBy)
            RETURNING accountid INTO o_response;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN ROLLBACK;
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'identity_pkg.SaveAddress: ' || i_accountid,
                o_response => v_response
        );
        o_response := SQLCODE || SUBSTR(SQLERRM, 1, 2000);
    END SaveAddress;

    PROCEDURE SaveContact(
        i_accountid IN contact_tbl.accountid%TYPE,
        i_channel IN contact_tbl.channel%TYPE,
        i_address IN contact_tbl.address%TYPE,
        i_consent IN contact_tbl.consent%TYPE,
        i_modifiedBy IN contact_tbl.modifiedBy%TYPE,
        o_response OUT VARCHAR2)
    AS
        v_error_message VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE contact_tbl
        SET accountid  = i_accountid,
            channel    = i_channel,
            address    = i_address,
            consent    = i_consent,
            modifiedBy = i_modifiedBy
        WHERE accountid = i_accountid
        RETURNING accountid INTO o_response;
        IF SQL%NOTFOUND THEN
            INSERT INTO contact_tbl(accountid, channel, address, consent, modifiedBy)
            VALUES (i_accountid, i_channel, i_address, i_consent, i_modifiedBy)
            RETURNING accountid INTO o_response;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN ROLLBACK;
        v_error_message := SUBSTR(SQLERRM, 1, 4000);
        ErrorHospital_pkg.ErrorCollector(
                i_faultcode => SQLCODE,
                i_faultmessage => v_error_message,
                i_faultservice => 'identity_pkg.SaveContact: ' || i_accountid,
                o_response => v_response
        );
        o_response := SQLCODE || SUBSTR(SQLERRM, 1, 2000);
    END SaveContact;

END identity_pkg;
/

PROMPT "Compiling Identity Package"

ALTER PACKAGE identity_pkg COMPILE PACKAGE;
ALTER PACKAGE identity_pkg COMPILE BODY;
/

SHOW ERRORS
/

PROMPT "End of creating Identity Schema"