PROMPT "Creating Identification Schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      identification.sql                                              *
 * Created:   20/01/2026, 21:00                                               *
 * Modified:  20/01/2026, 21:01                                               *
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

PROMPT "Creating Package Header"
--------------------------------------------------------------
-- PACKAGE: Creating identification header package
--------------------------------------------------------------
-- Create Header Package
CREATE OR REPLACE PACKAGE identification_pkg
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
    Name: identification_pkg
    Program Type: Package Specification
    Purpose: ADD/FIND/UPDATE/DELETE entity
    =================================================================================
    HISTORY
    =================================================================================
    | DATE 		| Owner 	| Activity
    =================================================================================
    | 20-JAN-26	| eomisore 	| Created initial script.|
    =================================================================================
    */
-- Find details from the address table
    PROCEDURE getAddress(
        i_username IN VARCHAR2,
        o_addressList OUT SYS_REFCURSOR);

    -- Find details from the contact table
    PROCEDURE getContact(
        i_username IN VARCHAR2,
        o_contactList OUT SYS_REFCURSOR);

    -- Find details from the image table
    PROCEDURE getImage(
        i_username IN VARCHAR2,
        o_avatarList OUT SYS_REFCURSOR);

    -- Find details from the person table
    PROCEDURE getPerson(
        i_username IN VARCHAR2,
        o_personList OUT SYS_REFCURSOR);

    -- Delete the address record
    PROCEDURE removeAddress(
        i_username IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Delete the contact record
    PROCEDURE removeContact(
        i_username IN VARCHAR2,
        i_channel IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Delete the image record
    PROCEDURE removeImage(
        i_username IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Delete the person record
    PROCEDURE removePerson(
        i_username IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Save the address record
    PROCEDURE saveAddress(
        i_username IN VARCHAR2,
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
        i_channel IN VARCHAR2,
        i_address IN VARCHAR2,
        i_consent IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Create or Update Identity
    PROCEDURE saveImage(
        i_username IN VARCHAR2,
        i_avatar IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Save the Person record
    PROCEDURE savePerson(
        i_username IN VARCHAR2,
        i_title IN VARCHAR2,
        i_firstName IN VARCHAR2,
        i_middleName IN VARCHAR2,
        i_lastName IN VARCHAR2,
        i_gender IN VARCHAR2,
        i_birthday IN DATE,
        o_response OUT VARCHAR2);

    -- Count filled columns
    PROCEDURE metrics(
        i_username   IN  VARCHAR2,
        o_response   OUT VARCHAR2);

END identification_pkg;
/

PROMPT "Creating Package Body"
--------------------------------------------------------------
-- PACKAGE: Creating authentication body package
--------------------------------------------------------------
-- Create Body Package
CREATE OR REPLACE PACKAGE BODY identification_pkg
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
    Name: identification_pkg
    Program Type: Package Specification
    Purpose: ADD/FIND/UPDATE/DELETE entity
    =================================================================================
    HISTORY
    =================================================================================
    | DATE 		| Owner 	| Activity
    =================================================================================
    | 20-JAN-26	| eomisore 	| Created initial script.|
    =================================================================================
    */
    -- Find details from the address table
    PROCEDURE getAddress(
        i_username IN VARCHAR2,
        o_addressList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        OPEN o_addressList FOR
            SELECT *
            FROM address_tbl
            WHERE username = i_username;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'identification_pkg (GETADDRESS): ' || i_username,
                    o_response => v_response
            );
    END getAddress;

    -- Find details from the contact table
    PROCEDURE getContact(
        i_username IN VARCHAR2,
        o_contactList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        OPEN o_contactList FOR
            SELECT *
            FROM contact_tbl
            WHERE username = i_username;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'identification_pkg (GETCONTACT): ' || i_username,
                    o_response => v_response
            );
    END getContact;

    -- Find details from the image table
    PROCEDURE getImage(
        i_username IN VARCHAR2,
        o_avatarList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        OPEN o_avatarList FOR
            SELECT *
            FROM images_tbl
            WHERE username = i_username;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'identification_pkg (GETIMAGE): ' || i_username,
                    o_response => v_response
            );
    END getImage;

    -- Find details from the person table
    PROCEDURE getPerson(
        i_username IN VARCHAR2,
        o_personList OUT SYS_REFCURSOR)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        OPEN o_personList FOR
            SELECT *
            FROM person_tbl
            WHERE username = i_username;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'identification_pkg (GETPERSON): ' || i_username,
                    o_response => v_response
            );
    END getPerson;

    -- Delete the address record
    PROCEDURE removeAddress(
        i_username IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_count        NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM address_tbl WHERE username = i_username;
        IF v_count = 1 THEN
            DELETE FROM address_tbl WHERE username = i_username;
            o_response := 'success';
        ELSE
            o_response := 'unsuccessful';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'identification_pkg (DELETE ADDRESS): ' || i_username,
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END removeAddress;

    -- Delete the contact record
    PROCEDURE removeContact(
        i_username IN VARCHAR2,
        i_channel IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_count        NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM contact_tbl WHERE username = i_username AND channel = i_channel;
        IF v_count = 1 THEN
            DELETE FROM contact_tbl WHERE username = i_username AND channel = i_channel;
            o_response := 'success';
        ELSE
            o_response := 'unsuccessful';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'identification_pkg (DELETE CONTACT): ' || i_username,
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END removeContact;

    -- Delete the image record
    PROCEDURE removeImage(
        i_username IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_count        NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM images_tbl WHERE username = i_username;
        IF v_count = 1 THEN
            DELETE FROM images_tbl WHERE username = i_username;
            o_response := 'success';
        ELSE
            o_response := 'unsuccessful';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'identification_pkg (DELETE IMAGE): ' || i_username,
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END removeImage;

    -- Delete the person record
    PROCEDURE removePerson(
        i_username IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_count        NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM person_tbl WHERE username = i_username;
        IF v_count = 1 THEN
            DELETE FROM person_tbl WHERE username = i_username;
            o_response := 'success';
        ELSE
            o_response := 'unsuccessful';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'identification_pkg (DELETE PERSON): ' || i_username,
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END removePerson;

    -- Save or update the address record
    PROCEDURE saveAddress(
        i_username IN VARCHAR2,
        i_firstline IN VARCHAR2,
        i_secondline IN VARCHAR2,
        i_thirdline IN VARCHAR2,
        i_city IN VARCHAR2,
        i_postcode IN VARCHAR2,
        i_country IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        UPDATE address_tbl
        SET firstline  = i_firstline,
            secondline = i_secondline,
            thirdline  = i_thirdline,
            city       = i_city,
            postcode   = i_postcode,
            country    = i_country,
            modifiedBy = i_username
        WHERE username = i_username;
        IF SQL%NOTFOUND THEN
            INSERT INTO address_tbl(username, firstline, secondline, thirdline, city, postcode, country, modifiedBy)
            VALUES (i_username, i_firstline, i_secondline, i_thirdline, i_city, i_postcode, i_country, i_username);
        END IF;
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'identification_pkg (SAVE ADDRESS): ' || i_username,
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END saveAddress;

    PROCEDURE saveContact(
        i_username IN VARCHAR2,
        i_channel IN VARCHAR2,
        i_address IN VARCHAR2,
        i_consent IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        UPDATE contact_tbl
        SET address = i_address,
            consent = i_consent,
            modifiedBy = i_username
        WHERE username = i_username
          AND channel = i_channel;
        IF SQL%NOTFOUND THEN
            INSERT INTO contact_tbl(username, channel, address, consent, modifiedBy)
            VALUES (i_username, i_channel, i_address, i_consent, i_username);
        END IF;
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'identification_pkg (SAVE CONTACT): ' || i_username,
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END saveContact;

    PROCEDURE saveImage(
        i_username IN VARCHAR2,
        i_avatar VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        UPDATE images_tbl
        SET avatar = i_avatar,
            modifiedBy = i_username
        WHERE username = i_username;
        IF SQL%NOTFOUND THEN
            INSERT INTO images_tbl(username, avatar, modifiedBy)
            VALUES (i_username, i_avatar, i_username);
        END IF;
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'identification_pkg (SAVE IMAGE): ' || i_username,
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END saveImage;

    PROCEDURE savePerson(
        i_username IN VARCHAR2,
        i_title IN VARCHAR2,
        i_firstName IN VARCHAR2,
        i_middleName IN VARCHAR2,
        i_lastName IN VARCHAR2,
        i_gender IN VARCHAR2,
        i_birthday IN DATE,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        UPDATE person_tbl
        SET title      = i_title,
            firstName  = i_firstName,
            middleName = i_middleName,
            lastName   = i_lastName,
            gender     = i_gender,
            birthday   = i_birthday,
            modifiedBy = i_username
        WHERE username = i_username;
        IF SQL%NOTFOUND THEN
            INSERT INTO person_tbl(username, title, firstName, middleName, lastName, gender, birthday, modifiedBy)
            VALUES (i_username, i_title, i_firstName, i_middleName, i_lastName, i_gender, i_birthday, i_username);
        END IF;
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'identification_pkg (SAVE PERSON): ' || i_username,
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END savePerson;

    -- Count filled columns
    PROCEDURE metrics(
        i_username   IN  VARCHAR2,
        o_response   OUT VARCHAR2)
    AS
        v_person_count      NUMBER := 0;
        v_address_count     NUMBER := 0;
        v_images_count      NUMBER := 0;
        v_contact_count     NUMBER := 0;
        v_total_fields      NUMBER := 0;
        v_total_filled      NUMBER := 0;
        v_percentage        NUMBER := 0;
        v_errorMessage      VARCHAR2(4000);
        v_response          VARCHAR2(100);
    BEGIN
        ------------------------------------------------------------------
        -- PERSON_TBL (8 fields)
        ------------------------------------------------------------------
        BEGIN
            SELECT
                CASE WHEN title       IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN firstName   IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN middleName  IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN lastName    IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN zodiacSign  IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN gender      IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN birthday    IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN age         IS NOT NULL THEN 1 ELSE 0 END
            INTO v_person_count
            FROM person_tbl
            WHERE username = i_username;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_person_count := 0;
        END;
        ------------------------------------------------------------------
        -- ADDRESS_TBL (6 fields)
        ------------------------------------------------------------------
        BEGIN
            SELECT
                CASE WHEN firstline  IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN secondline IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN thirdline  IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN city       IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN postcode   IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN country    IS NOT NULL THEN 1 ELSE 0 END
            INTO v_address_count
            FROM address_tbl
            WHERE username = i_username;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_address_count := 0;
        END;
        ------------------------------------------------------------------
        -- IMAGES_TBL (1 field)
        ------------------------------------------------------------------
        BEGIN
            SELECT
                CASE WHEN avatar IS NOT NULL THEN 1 ELSE 0 END
            INTO v_images_count
            FROM images_tbl
            WHERE username = i_username;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_images_count := 0;
        END;
        ------------------------------------------------------------------
        -- CONTACT_TBL (7 logical fields = 7 channels)
        -- Count how many distinct channels exist for this user.
        ------------------------------------------------------------------
        SELECT COUNT(DISTINCT channel)
        INTO v_contact_count
        FROM contact_tbl
        WHERE username = i_username
          AND channel IN ('Phone', 'Email', 'X', 'Facebook', 'LinkedIn', 'Snapchat', 'Website');

        IF v_contact_count IS NULL THEN
            v_contact_count := 0;
        END IF;
        ------------------------------------------------------------------
        -- TOTAL FIELDS AND PERCENTAGE
        ------------------------------------------------------------------
        v_total_fields := 8  -- person_tbl
            + 6  -- address_tbl
            + 1  -- images_tbl
            + 7; -- contact channels

        v_total_filled :=
                v_person_count
                    + v_address_count
                    + v_images_count
                    + v_contact_count;

        IF v_total_fields > 0 THEN
            v_percentage := (v_total_filled / v_total_fields) * 100;
        ELSE
            v_percentage := 0;
        END IF;
        ------------------------------------------------------------------
        -- OUTPUT STRING
        ------------------------------------------------------------------
        o_response := 'Profile completion: ' || TO_CHAR(ROUND(v_percentage, 2)) || '%';
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'identification_pkg (METRICS): ' || i_username,
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END metrics;

END identification_pkg;
/

SHOW ERRORS
/

PROMPT "End of creating Identification Schema"