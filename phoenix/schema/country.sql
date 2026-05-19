PROMPT "Creating Country Schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      country.sql                                                     *
 * Created:   02/02/2026, 20:15                                               *
 * Modified:  02/02/2026, 20:15                                               *
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

PROMPT "Setting Constraints"

-- Setting Unique Key
ALTER TABLE country_tbl
    ADD CONSTRAINT alpha_unq UNIQUE (alpha2);

PROMPT "Creating Triggers"

CREATE OR REPLACE TRIGGER country_trg
    BEFORE INSERT OR UPDATE
    ON country_tbl
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
        errorVault_pkg.storeError(
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
ALTER TRIGGER country_trg ENABLE;

--------------------------------------------------------------
-- PACKAGE: Creating Nationality header package
--------------------------------------------------------------
-- Create Header Package
CREATE OR REPLACE PACKAGE nationality_pkg
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
    Name: nationality_pkg
    Program Type: Package Specification
    Purpose: ADD/FIND/UPDATE/DELETE entity
    =================================================================================
    HISTORY
    =================================================================================
    | DATE 		| Owner 	| Activity
    =================================================================================
    | 02-FEB-26	| eomisore 	| Created initial script.|
    =================================================================================
    */
-- Find details from the country table
    PROCEDURE getCountry(
        i_countryCode IN VARCHAR2,
        o_countryList OUT SYS_REFCURSOR);

END nationality_pkg;
/

PROMPT "Creating Package Body"
--------------------------------------------------------------
-- PACKAGE: Creating Nationality body package
--------------------------------------------------------------
-- Create Body Package
CREATE OR REPLACE PACKAGE BODY nationality_pkg
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
    Name: nationality_pkg
    Program Type: Package Specification
    Purpose: ADD/FIND/UPDATE/DELETE entity
    =================================================================================
    HISTORY
    =================================================================================
    | DATE 		| Owner 	| Activity
    =================================================================================
    | 02-FEB-26	| eomisore 	| Created initial script.|
    =================================================================================
    */
-- Find details from the country table
    PROCEDURE getCountry(
        i_countryCode IN VARCHAR2,
        o_countryList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        OPEN o_countryList FOR
            SELECT *
            FROM country_tbl
            WHERE alpha2 = i_countryCode;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'nationality_pkg (GET COUNTRY): ' || i_countryCode,
                    o_response => v_response
            );
    END getCountry;

END nationality_pkg;
/

PROMPT "Compiling Country Package"

ALTER PACKAGE nationality_pkg COMPILE PACKAGE;
ALTER PACKAGE nationality_pkg COMPILE BODY;
/

PROMPT "Inserting Initial Records"
--------------------------------------------------------------
-- Insert initial records
--------------------------------------------------------------

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('AF', 'AFG', 'Afghanistan', 'Southern Asia', 'Asia', '+93', 'AFN', 'Afghan afghani', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('AX', 'ALA', 'Åland Islands', 'Northern Europe', 'Europe', '+358', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('AL', 'ALB', 'Albania', 'Southern Europe', 'Europe', '+355', 'ALL', 'Albanian lek', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('DZ', 'DZA', 'Algeria', 'Northern Africa', 'Africa', '+213', 'DZD', 'Algerian dinar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('AS', 'ASM', 'American Samoa', 'Polynesia', 'Oceania', '+1-684', 'USD', 'United States dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('AD', 'AND', 'Andorra', 'Southern Europe', 'Europe', '+376', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('AO', 'AGO', 'Angola', 'Middle Africa', 'Africa', '+244', 'AOA', 'Angolan kwanza', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('AI', 'AIA', 'Anguilla', 'Caribbean', 'North America', '+1-264', 'XCD', 'East Caribbean dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('AQ', 'ATA', 'Antarctica', 'Antarctica', 'Antarctica', NULL, NULL, NULL, NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('AG', 'ATG', 'Antigua and Barbuda', 'Caribbean', 'North America', '+1-268', 'XCD', 'East Caribbean dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('AR', 'ARG', 'Argentina', 'South America', 'South America', '+54', 'ARS', 'Argentine peso', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('AM', 'ARM', 'Armenia', 'Western Asia', 'Asia', '+374', 'AMD', 'Armenian dram', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('AW', 'ABW', 'Aruba', 'Caribbean', 'North America', '+297', 'AWG', 'Aruban florin', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('AU', 'AUS', 'Australia', 'Australia and New Zealand', 'Oceania', '+61', 'AUD', 'Australian dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('AT', 'AUT', 'Austria', 'Western Europe', 'Europe', '+43', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('AZ', 'AZE', 'Azerbaijan', 'Western Asia', 'Asia', '+994', 'AZN', 'Azerbaijani manat', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BS', 'BHS', 'Bahamas', 'Caribbean', 'North America', '+1-242', 'BSD', 'Bahamian dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BH', 'BHR', 'Bahrain', 'Western Asia', 'Asia', '+973', 'BHD', 'Bahraini dinar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BD', 'BGD', 'Bangladesh', 'Southern Asia', 'Asia', '+880', 'BDT', 'Bangladeshi taka', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BB', 'BRB', 'Barbados', 'Caribbean', 'North America', '+1-246', 'BBD', 'Barbados dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BY', 'BLR', 'Belarus', 'Eastern Europe', 'Europe', '+375', 'BYN', 'Belarusian ruble', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BE', 'BEL', 'Belgium', 'Western Europe', 'Europe', '+32', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BZ', 'BLZ', 'Belize', 'Central America', 'North America', '+501', 'BZD', 'Belize dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BJ', 'BEN', 'Benin', 'Western Africa', 'Africa', '+229', 'XOF', 'West African CFA franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BM', 'BMU', 'Bermuda', 'Northern America', 'North America', '+1-441', 'BMD', 'Bermudian dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BT', 'BTN', 'Bhutan', 'Southern Asia', 'Asia', '+975', 'BTN', 'Bhutanese ngultrum', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BO', 'BOL', 'Bolivia', 'South America', 'South America', '+591', 'BOB', 'Boliviano', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BQ', 'BES', 'Bonaire, Sint Eustatius and Saba', 'Caribbean', 'North America', '+599', 'USD', 'United States dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BA', 'BIH', 'Bosnia and Herzegovina', 'Southern Europe', 'Europe', '+387', 'BAM', 'Convertible mark', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BW', 'BWA', 'Botswana', 'Southern Africa', 'Africa', '+267', 'BWP', 'Botswana pula', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BV', 'BVT', 'Bouvet Island', 'Subantarctic', 'Antarctica', NULL, 'NOK', 'Norwegian krone', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BR', 'BRA', 'Brazil', 'South America', 'South America', '+55', 'BRL', 'Brazilian real', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('IO', 'IOT', 'British Indian Ocean Territory', 'Indian Ocean', 'Asia', '+246', 'USD', 'United States dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('VG', 'VGB', 'British Virgin Islands', 'Caribbean', 'North America', '+1-284', 'USD', 'United States dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BN', 'BRN', 'Brunei Darussalam', 'South-Eastern Asia', 'Asia', '+673', 'BND', 'Brunei dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BG', 'BGR', 'Bulgaria', 'Eastern Europe', 'Europe', '+359', 'BGN', 'Bulgarian lev', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BF', 'BFA', 'Burkina Faso', 'Western Africa', 'Africa', '+226', 'XOF', 'West African CFA franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BI', 'BDI', 'Burundi', 'Eastern Africa', 'Africa', '+257', 'BIF', 'Burundian franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('KH', 'KHM', 'Cambodia', 'South-Eastern Asia', 'Asia', '+855', 'KHR', 'Cambodian riel', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CM', 'CMR', 'Cameroon', 'Middle Africa', 'Africa', '+237', 'XAF', 'Central African CFA franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CA', 'CAN', 'Canada', 'Northern America', 'North America', '+1', 'CAD', 'Canadian dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CV', 'CPV', 'Cabo Verde', 'Western Africa', 'Africa', '+238', 'CVE', 'Cape Verde escudo', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('KY', 'CYM', 'Cayman Islands', 'Caribbean', 'North America', '+1-345', 'KYD', 'Cayman Islands dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CF', 'CAF', 'Central African Republic', 'Middle Africa', 'Africa', '+236', 'XAF', 'Central African CFA franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('TD', 'TCD', 'Chad', 'Middle Africa', 'Africa', '+235', 'XAF', 'Central African CFA franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CL', 'CHL', 'Chile', 'South America', 'South America', '+56', 'CLP', 'Chilean peso', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CN', 'CHN', 'China', 'Eastern Asia', 'Asia', '+86', 'CNY', 'Chinese yuan', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CX', 'CXR', 'Christmas Island', 'Australia and New Zealand', 'Oceania', '+61', 'AUD', 'Australian dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CC', 'CCK', 'Cocos (Keeling) Islands', 'Australia and New Zealand', 'Oceania', '+61', 'AUD', 'Australian dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CO', 'COL', 'Colombia', 'South America', 'South America', '+57', 'COP', 'Colombian peso', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('KM', 'COM', 'Comoros', 'Eastern Africa', 'Africa', '+269', 'KMF', 'Comorian franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CG', 'COG', 'Congo', 'Middle Africa', 'Africa', '+242', 'XAF', 'Central African CFA franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CD', 'COD', 'Congo, Democratic Republic of the', 'Middle Africa', 'Africa', '+243', 'CDF', 'Congolese franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CK', 'COK', 'Cook Islands', 'Polynesia', 'Oceania', '+682', 'NZD', 'New Zealand dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CR', 'CRI', 'Costa Rica', 'Central America', 'North America', '+506', 'CRC', 'Costa Rican colón', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CI', 'CIV', 'Côte d''Ivoire', 'Western Africa', 'Africa', '+225', 'XOF', 'West African CFA franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('HR', 'HRV', 'Croatia', 'Southern Europe', 'Europe', '+385', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CU', 'CUB', 'Cuba', 'Caribbean', 'North America', '+53', 'CUP', 'Cuban peso', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CW', 'CUW', 'Curaçao', 'Caribbean', 'North America', '+599', 'ANG', 'Netherlands Antillean guilder', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CY', 'CYP', 'Cyprus', 'Western Asia', 'Asia', '+357', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CZ', 'CZE', 'Czechia', 'Eastern Europe', 'Europe', '+420', 'CZK', 'Czech koruna', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('DK', 'DNK', 'Denmark', 'Northern Europe', 'Europe', '+45', 'DKK', 'Danish krone', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('DJ', 'DJI', 'Djibouti', 'Eastern Africa', 'Africa', '+253', 'DJF', 'Djiboutian franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('DM', 'DMA', 'Dominica', 'Caribbean', 'North America', '+1-767', 'XCD', 'East Caribbean dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('DO', 'DOM', 'Dominican Republic', 'Caribbean', 'North America', '+1-809', 'DOP', 'Dominican peso', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('EC', 'ECU', 'Ecuador', 'South America', 'South America', '+593', 'USD', 'United States dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('EG', 'EGY', 'Egypt', 'Northern Africa', 'Africa', '+20', 'EGP', 'Egyptian pound', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SV', 'SLV', 'El Salvador', 'Central America', 'North America', '+503', 'USD', 'United States dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GQ', 'GNQ', 'Equatorial Guinea', 'Middle Africa', 'Africa', '+240', 'XAF', 'Central African CFA franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('ER', 'ERI', 'Eritrea', 'Eastern Africa', 'Africa', '+291', 'ERN', 'Eritrean nakfa', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('EE', 'EST', 'Estonia', 'Northern Europe', 'Europe', '+372', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SZ', 'SWZ', 'Eswatini', 'Southern Africa', 'Africa', '+268', 'SZL', 'Eswatini lilangeni', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('ET', 'ETH', 'Ethiopia', 'Eastern Africa', 'Africa', '+251', 'ETB', 'Ethiopian birr', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('FK', 'FLK', 'Falkland Islands', 'South America', 'South America', '+500', 'FKP', 'Falkland Islands pound', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('FO', 'FRO', 'Faroe Islands', 'Northern Europe', 'Europe', '+298', 'DKK', 'Danish krone', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('FJ', 'FJI', 'Fiji', 'Melanesia', 'Oceania', '+679', 'FJD', 'Fijian dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('FI', 'FIN', 'Finland', 'Northern Europe', 'Europe', '+358', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('FR', 'FRA', 'France', 'Western Europe', 'Europe', '+33', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GF', 'GUF', 'French Guiana', 'South America', 'South America', '+594', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('PF', 'PYF', 'French Polynesia', 'Polynesia', 'Oceania', '+689', 'XPF', 'CFP franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('TF', 'ATF', 'French Southern Territories', 'Antarctica', 'Antarctica', '+262', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GA', 'GAB', 'Gabon', 'Middle Africa', 'Africa', '+241', 'XAF', 'Central African CFA franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GM', 'GMB', 'Gambia', 'Western Africa', 'Africa', '+220', 'GMD', 'Gambian dalasi', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GE', 'GEO', 'Georgia', 'Western Asia', 'Asia', '+995', 'GEL', 'Georgian lari', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('DE', 'DEU', 'Germany', 'Western Europe', 'Europe', '+49', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GH', 'GHA', 'Ghana', 'Western Africa', 'Africa', '+233', 'GHS', 'Ghanaian cedi', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GI', 'GIB', 'Gibraltar', 'Southern Europe', 'Europe', '+350', 'GIP', 'Gibraltar pound', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GR', 'GRC', 'Greece', 'Southern Europe', 'Europe', '+30', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GL', 'GRL', 'Greenland', 'Northern America', 'North America', '+299', 'DKK', 'Danish krone', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GD', 'GRD', 'Grenada', 'Caribbean', 'North America', '+1-473', 'XCD', 'East Caribbean dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GP', 'GLP', 'Guadeloupe', 'Caribbean', 'North America', '+590', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GU', 'GUM', 'Guam', 'Micronesia', 'Oceania', '+1-671', 'USD', 'United States dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GT', 'GTM', 'Guatemala', 'Central America', 'North America', '+502', 'GTQ', 'Guatemalan quetzal', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GG', 'GGY', 'Guernsey', 'Northern Europe', 'Europe', '+44', 'GGP', 'Guernsey pound', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GN', 'GIN', 'Guinea', 'Western Africa', 'Africa', '+224', 'GNF', 'Guinean franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GW', 'GNB', 'Guinea-Bissau', 'Western Africa', 'Africa', '+245', 'XOF', 'West African CFA franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GY', 'GUY', 'Guyana', 'South America', 'South America', '+592', 'GYD', 'Guyanese dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('HT', 'HTI', 'Haiti', 'Caribbean', 'North America', '+509', 'HTG', 'Haitian gourde', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('HM', 'HMD', 'Heard Island and McDonald Islands', 'Antarctica', 'Antarctica', NULL, 'AUD', 'Australian dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('VA', 'VAT', 'Holy See', 'Southern Europe', 'Europe', '+379', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('HN', 'HND', 'Honduras', 'Central America', 'North America', '+504', 'HNL', 'Honduran lempira', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('HK', 'HKG', 'Hong Kong SAR', 'Eastern Asia', 'Asia', '+852', 'HKD', 'Hong Kong dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('HU', 'HUN', 'Hungary', 'Eastern Europe', 'Europe', '+36', 'HUF', 'Hungarian forint', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('IS', 'ISL', 'Iceland', 'Northern Europe', 'Europe', '+354', 'ISK', 'Icelandic króna', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('IN', 'IND', 'India', 'Southern Asia', 'Asia', '+91', 'INR', 'Indian rupee', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('ID', 'IDN', 'Indonesia', 'South-Eastern Asia', 'Asia', '+62', 'IDR', 'Indonesian rupiah', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('IR', 'IRN', 'Iran', 'Southern Asia', 'Asia', '+98', 'IRR', 'Iranian rial', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('IQ', 'IRQ', 'Iraq', 'Western Asia', 'Asia', '+964', 'IQD', 'Iraqi dinar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('IE', 'IRL', 'Ireland', 'Northern Europe', 'Europe', '+353', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('IM', 'IMN', 'Isle of Man', 'Northern Europe', 'Europe', '+44', 'IMP', 'Manx pound', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('IL', 'ISR', 'Israel', 'Western Asia', 'Asia', '+972', 'ILS', 'Israeli new shekel', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('IT', 'ITA', 'Italy', 'Southern Europe', 'Europe', '+39', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('JM', 'JAM', 'Jamaica', 'Caribbean', 'North America', '+1-876', 'JMD', 'Jamaican dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('JP', 'JPN', 'Japan', 'Eastern Asia', 'Asia', '+81', 'JPY', 'Japanese yen', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('JE', 'JEY', 'Jersey', 'Northern Europe', 'Europe', '+44', 'JEP', 'Jersey pound', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('JO', 'JOR', 'Jordan', 'Western Asia', 'Asia', '+962', 'JOD', 'Jordanian dinar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('KZ', 'KAZ', 'Kazakhstan', 'Central Asia', 'Asia', '+7', 'KZT', 'Kazakhstani tenge', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('KE', 'KEN', 'Kenya', 'Eastern Africa', 'Africa', '+254', 'KES', 'Kenyan shilling', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('KI', 'KIR', 'Kiribati', 'Micronesia', 'Oceania', '+686', 'AUD', 'Australian dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('KP', 'PRK', 'Korea (North)', 'Eastern Asia', 'Asia', '+850', 'KPW', 'North Korean won', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('KR', 'KOR', 'Korea (South)', 'Eastern Asia', 'Asia', '+82', 'KRW', 'South Korean won', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('KW', 'KWT', 'Kuwait', 'Western Asia', 'Asia', '+965', 'KWD', 'Kuwaiti dinar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('KG', 'KGZ', 'Kyrgyzstan', 'Central Asia', 'Asia', '+996', 'KGS', 'Kyrgyzstani som', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('LA', 'LAO', 'Laos', 'South-Eastern Asia', 'Asia', '+856', 'LAK', 'Lao kip', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('LV', 'LVA', 'Latvia', 'Northern Europe', 'Europe', '+371', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('LB', 'LBN', 'Lebanon', 'Western Asia', 'Asia', '+961', 'LBP', 'Lebanese pound', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('LS', 'LSO', 'Lesotho', 'Southern Africa', 'Africa', '+266', 'LSL', 'Lesotho loti', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('LR', 'LBR', 'Liberia', 'Western Africa', 'Africa', '+231', 'LRD', 'Liberian dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('LY', 'LBY', 'Libya', 'Northern Africa', 'Africa', '+218', 'LYD', 'Libyan dinar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('LI', 'LIE', 'Liechtenstein', 'Western Europe', 'Europe', '+423', 'CHF', 'Swiss franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('LT', 'LTU', 'Lithuania', 'Northern Europe', 'Europe', '+370', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('LU', 'LUX', 'Luxembourg', 'Western Europe', 'Europe', '+352', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MO', 'MAC', 'Macao SAR', 'Eastern Asia', 'Asia', '+853', 'MOP', 'Macanese pataca', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MG', 'MDG', 'Madagascar', 'Eastern Africa', 'Africa', '+261', 'MGA', 'Malagasy ariary', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MW', 'MWI', 'Malawi', 'Eastern Africa', 'Africa', '+265', 'MWK', 'Malawian kwacha', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MY', 'MYS', 'Malaysia', 'South-Eastern Asia', 'Asia', '+60', 'MYR', 'Malaysian ringgit', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MV', 'MDV', 'Maldives', 'Southern Asia', 'Asia', '+960', 'MVR', 'Maldivian rufiyaa', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('ML', 'MLI', 'Mali', 'Western Africa', 'Africa', '+223', 'XOF', 'West African CFA franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MT', 'MLT', 'Malta', 'Southern Europe', 'Europe', '+356', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MH', 'MHL', 'Marshall Islands', 'Micronesia', 'Oceania', '+692', 'USD', 'United States dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MQ', 'MTQ', 'Martinique', 'Caribbean', 'North America', '+596', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MR', 'MRT', 'Mauritania', 'Western Africa', 'Africa', '+222', 'MRU', 'Mauritanian ouguiya', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MU', 'MUS', 'Mauritius', 'Eastern Africa', 'Africa', '+230', 'MUR', 'Mauritian rupee', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('YT', 'MYT', 'Mayotte', 'Eastern Africa', 'Africa', '+262', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MX', 'MEX', 'Mexico', 'Northern America', 'North America', '+52', 'MXN', 'Mexican peso', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('FM', 'FSM', 'Micronesia', 'Micronesia', 'Oceania', '+691', 'USD', 'United States dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MD', 'MDA', 'Moldova', 'Eastern Europe', 'Europe', '+373', 'MDL', 'Moldovan leu', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MC', 'MCO', 'Monaco', 'Western Europe', 'Europe', '+377', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MN', 'MNG', 'Mongolia', 'Eastern Asia', 'Asia', '+976', 'MNT', 'Mongolian tögrög', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('ME', 'MNE', 'Montenegro', 'Southern Europe', 'Europe', '+382', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MS', 'MSR', 'Montserrat', 'Caribbean', 'North America', '+1-664', 'XCD', 'East Caribbean dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MA', 'MAR', 'Morocco', 'Northern Africa', 'Africa', '+212', 'MAD', 'Moroccan dirham', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MZ', 'MOZ', 'Mozambique', 'Eastern Africa', 'Africa', '+258', 'MZN', 'Mozambican metical', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MM', 'MMR', 'Myanmar', 'South-Eastern Asia', 'Asia', '+95', 'MMK', 'Myanmar kyat', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('NA', 'NAM', 'Namibia', 'Southern Africa', 'Africa', '+264', 'NAD', 'Namibian dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('NR', 'NRU', 'Nauru', 'Micronesia', 'Oceania', '+674', 'AUD', 'Australian dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('NP', 'NPL', 'Nepal', 'Southern Asia', 'Asia', '+977', 'NPR', 'Nepalese rupee', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('NL', 'NLD', 'Netherlands', 'Western Europe', 'Europe', '+31', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('NC', 'NCL', 'New Caledonia', 'Melanesia', 'Oceania', '+687', 'XPF', 'CFP franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('NZ', 'NZL', 'New Zealand', 'Australia and New Zealand', 'Oceania', '+64', 'NZD', 'New Zealand dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('NI', 'NIC', 'Nicaragua', 'Central America', 'North America', '+505', 'NIO', 'Nicaraguan córdoba', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('NE', 'NER', 'Niger', 'Western Africa', 'Africa', '+227', 'XOF', 'West African CFA franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('NG', 'NGA', 'Nigeria', 'Western Africa', 'Africa', '+234', 'NGN', 'Nigerian naira', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('NU', 'NIU', 'Niue', 'Polynesia', 'Oceania', '+683', 'NZD', 'New Zealand dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('NF', 'NFK', 'Norfolk Island', 'Australia and New Zealand', 'Oceania', '+672', 'AUD', 'Australian dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MP', 'MNP', 'Northern Mariana Islands', 'Micronesia', 'Oceania', '+1-670', 'USD', 'United States dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('NO', 'NOR', 'Norway', 'Northern Europe', 'Europe', '+47', 'NOK', 'Norwegian krone', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('OM', 'OMN', 'Oman', 'Western Asia', 'Asia', '+968', 'OMR', 'Omani rial', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('PK', 'PAK', 'Pakistan', 'Southern Asia', 'Asia', '+92', 'PKR', 'Pakistani rupee', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('PW', 'PLW', 'Palau', 'Micronesia', 'Oceania', '+680', 'USD', 'United States dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('PS', 'PSE', 'Palestine', 'Western Asia', 'Asia', '+970', 'ILS', 'Israeli new shekel', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('PA', 'PAN', 'Panama', 'Central America', 'North America', '+507', 'PAB', 'Panamanian balboa', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('PG', 'PNG', 'Papua New Guinea', 'Melanesia', 'Oceania', '+675', 'PGK', 'Papua New Guinean kina', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('PY', 'PRY', 'Paraguay', 'South America', 'South America', '+595', 'PYG', 'Paraguayan guaraní', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('PE', 'PER', 'Peru', 'South America', 'South America', '+51', 'PEN', 'Peruvian sol', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('PH', 'PHL', 'Philippines', 'South-Eastern Asia', 'Asia', '+63', 'PHP', 'Philippine peso', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('PN', 'PCN', 'Pitcairn Islands', 'Polynesia', 'Oceania', '+64', 'NZD', 'New Zealand dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('PL', 'POL', 'Poland', 'Eastern Europe', 'Europe', '+48', 'PLN', 'Polish złoty', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('PT', 'PRT', 'Portugal', 'Southern Europe', 'Europe', '+351', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('QA', 'QAT', 'Qatar', 'Western Asia', 'Asia', '+974', 'QAR', 'Qatari riyal', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('RO', 'ROU', 'Romania', 'Eastern Europe', 'Europe', '+40', 'RON', 'Romanian leu', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('RU', 'RUS', 'Russia', 'Eastern Europe', 'Europe', '+7', 'RUB', 'Russian ruble', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('RW', 'RWA', 'Rwanda', 'Eastern Africa', 'Africa', '+250', 'RWF', 'Rwandan franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('RE', 'REU', 'Réunion', 'Eastern Africa', 'Africa', '+262', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('BL', 'BLM', 'Saint Barthélemy', 'Caribbean', 'North America', '+590', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SH', 'SHN', 'Saint Helena', 'Western Africa', 'Africa', '+290', 'SHP', 'Saint Helena pound', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('KN', 'KNA', 'Saint Kitts and Nevis', 'Caribbean', 'North America', '+1-869', 'XCD', 'East Caribbean dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('LC', 'LCA', 'Saint Lucia', 'Caribbean', 'North America', '+1-758', 'XCD', 'East Caribbean dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('MF', 'MAF', 'Saint Martin', 'Caribbean', 'North America', '+590', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('PM', 'SPM', 'Saint Pierre and Miquelon', 'Northern America', 'North America', '+508', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('VC', 'VCT', 'Saint Vincent and the Grenadines', 'Caribbean', 'North America', '+1-784', 'XCD', 'East Caribbean dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('WS', 'WSM', 'Samoa', 'Polynesia', 'Oceania', '+685', 'WST', 'Samoan tala', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SM', 'SMR', 'San Marino', 'Southern Europe', 'Europe', '+378', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('ST', 'STP', 'São Tomé and Príncipe', 'Middle Africa', 'Africa', '+239', 'STN', 'São Tomé and Príncipe dobra', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SA', 'SAU', 'Saudi Arabia', 'Western Asia', 'Asia', '+966', 'SAR', 'Saudi riyal', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SN', 'SEN', 'Senegal', 'Western Africa', 'Africa', '+221', 'XOF', 'West African CFA franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('RS', 'SRB', 'Serbia', 'Southern Europe', 'Europe', '+381', 'RSD', 'Serbian dinar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SC', 'SYC', 'Seychelles', 'Eastern Africa', 'Africa', '+248', 'SCR', 'Seychellois rupee', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SL', 'SLE', 'Sierra Leone', 'Western Africa', 'Africa', '+232', 'SLE', 'Sierra Leonean leone', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SG', 'SGP', 'Singapore', 'South-Eastern Asia', 'Asia', '+65', 'SGD', 'Singapore dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SX', 'SXM', 'Sint Maarten', 'Caribbean', 'North America', '+1-721', 'ANG', 'Netherlands Antillean guilder', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SK', 'SVK', 'Slovakia', 'Eastern Europe', 'Europe', '+421', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SI', 'SVN', 'Slovenia', 'Southern Europe', 'Europe', '+386', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SB', 'SLB', 'Solomon Islands', 'Melanesia', 'Oceania', '+677', 'SBD', 'Solomon Islands dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SO', 'SOM', 'Somalia', 'Eastern Africa', 'Africa', '+252', 'SOS', 'Somali shilling', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('ZA', 'ZAF', 'South Africa', 'Southern Africa', 'Africa', '+27', 'ZAR', 'South African rand', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GS', 'SGS', 'South Georgia and the South Sandwich Islands', 'Antarctica', 'Antarctica', '+500', 'GBP', 'Pound sterling', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SS', 'SSD', 'South Sudan', 'Eastern Africa', 'Africa', '+211', 'SSP', 'South Sudanese pound', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('ES', 'ESP', 'Spain', 'Southern Europe', 'Europe', '+34', 'EUR', 'Euro', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('LK', 'LKA', 'Sri Lanka', 'Southern Asia', 'Asia', '+94', 'LKR', 'Sri Lankan rupee', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SD', 'SDN', 'Sudan', 'Northern Africa', 'Africa', '+249', 'SDG', 'Sudanese pound', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SR', 'SUR', 'Suriname', 'South America', 'South America', '+597', 'SRD', 'Surinamese dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SJ', 'SJM', 'Svalbard and Jan Mayen', 'Northern Europe', 'Europe', '+47', 'NOK', 'Norwegian krone', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SE', 'SWE', 'Sweden', 'Northern Europe', 'Europe', '+46', 'SEK', 'Swedish krona', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('CH', 'CHE', 'Switzerland', 'Western Europe', 'Europe', '+41', 'CHF', 'Swiss franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('SY', 'SYR', 'Syria', 'Western Asia', 'Asia', '+963', 'SYP', 'Syrian pound', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('TW', 'TWN', 'Taiwan', 'Eastern Asia', 'Asia', '+886', 'TWD', 'New Taiwan dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('TJ', 'TJK', 'Tajikistan', 'Central Asia', 'Asia', '+992', 'TJS', 'Tajikistani somoni', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('TZ', 'TZA', 'Tanzania', 'Eastern Africa', 'Africa', '+255', 'TZS', 'Tanzanian shilling', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('TH', 'THA', 'Thailand', 'South-Eastern Asia', 'Asia', '+66', 'THB', 'Thai baht', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('TG', 'TGO', 'Togo', 'Western Africa', 'Africa', '+228', 'XOF', 'West African CFA franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('TK', 'TKL', 'Tokelau', 'Polynesia', 'Oceania', '+690', 'NZD', 'New Zealand dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('TO', 'TON', 'Tonga', 'Polynesia', 'Oceania', '+676', 'TOP', 'Tongan paʻanga', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('TT', 'TTO', 'Trinidad and Tobago', 'Caribbean', 'North America', '+1-868', 'TTD', 'Trinidad and Tobago dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('TN', 'TUN', 'Tunisia', 'Northern Africa', 'Africa', '+216', 'TND', 'Tunisian dinar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('TR', 'TUR', 'Türkiye', 'Western Asia', 'Asia', '+90', 'TRY', 'Turkish lira', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('TM', 'TKM', 'Turkmenistan', 'Central Asia', 'Asia', '+993', 'TMT', 'Turkmenistan manat', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('TC', 'TCA', 'Turks and Caicos Islands', 'Caribbean', 'North America', '+1-649', 'USD', 'United States dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('TV', 'TUV', 'Tuvalu', 'Polynesia', 'Oceania', '+688', 'AUD', 'Australian dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('UG', 'UGA', 'Uganda', 'Eastern Africa', 'Africa', '+256', 'UGX', 'Ugandan shilling', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('UA', 'UKR', 'Ukraine', 'Eastern Europe', 'Europe', '+380', 'UAH', 'Ukrainian hryvnia', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('AE', 'ARE', 'United Arab Emirates', 'Western Asia', 'Asia', '+971', 'AED', 'UAE dirham', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('GB', 'GBR', 'United Kingdom', 'Northern Europe', 'Europe', '+44', 'GBP', 'Pound sterling', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('US', 'USA', 'United States', 'Northern America', 'North America', '+1', 'USD', 'United States dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('UM', 'UMI', 'United States Minor Outlying Islands', 'Oceania', 'Oceania', '+1', 'USD', 'United States dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('UY', 'URY', 'Uruguay', 'South America', 'South America', '+598', 'UYU', 'Uruguayan peso', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('UZ', 'UZB', 'Uzbekistan', 'Central Asia', 'Asia', '+998', 'UZS', 'Uzbekistani som', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('VU', 'VUT', 'Vanuatu', 'Melanesia', 'Oceania', '+678', 'VUV', 'Vanuatu vatu', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('VE', 'VEN', 'Venezuela', 'South America', 'South America', '+58', 'VES', 'Venezuelan bolívar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('VN', 'VNM', 'Vietnam', 'South-Eastern Asia', 'Asia', '+84', 'VND', 'Vietnamese đồng', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('VI', 'VIR', 'Virgin Islands (U.S.)', 'Caribbean', 'North America', '+1-340', 'USD', 'United States dollar', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('WF', 'WLF', 'Wallis and Futuna', 'Polynesia', 'Oceania', '+681', 'XPF', 'CFP franc', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('EH', 'ESH', 'Western Sahara', 'Northern Africa', 'Africa', '+212', 'MAD', 'Moroccan dirham', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('YE', 'YEM', 'Yemen', 'Western Asia', 'Asia', '+967', 'YER', 'Yemeni rial', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('ZM', 'ZMB', 'Zambia', 'Eastern Africa', 'Africa', '+260', 'ZMW', 'Zambian kwacha', NULL, NULL);

INSERT INTO country_tbl (alpha2, alpha3, country, region, continent, dialPrefix, currencyCode, currencyName, modifiedBy, modifiedDate)
VALUES ('ZW', 'ZWE', 'Zimbabwe', 'Eastern Africa', 'Africa', '+263', 'ZWL', 'Zimbabwean dollar', NULL, NULL);

SHOW ERRORS
/

PROMPT "End of Country Schema."