PROMPT "Creating Account schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      account.sql                                                     *
 * Created:   13/10/2025, 10:58                                               *
 * Modified:  13/10/2025, 10:58                                               *
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

PROMPT "Creating Package Header"
--------------------------------------------------------------
-- PACKAGE: Creating authentication header package
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

    -- Delete Account
    PROCEDURE deleteAccount(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Update account password and username
    PROCEDURE updateAccount(
        i_email IN VARCHAR2,
        i_username IN VARCHAR2,
        i_oldpassword IN VARCHAR2,
        i_newpassword IN VARCHAR2,
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

    -- Delete Account
    PROCEDURE deleteAccount(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        DELETE FROM authentication_tbl
        WHERE email = i_email;
        -- insert records for audit purpose
        auth_pkg.audit(i_username,i_email, 'DELETE ACCOUNT', 'Successfully delete user Account', i_username);
        o_response := 'success';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (DELETE ACCOUNT): ' || i_email,
                    o_response => v_response
            );
            o_response := 'delete account unsuccessful';
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (DELETE ACCOUNT): ' || i_email,
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
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE authentication_tbl
        SET username = i_username, password = utl_encode.base64_encode(utl_raw.cast_to_raw(enc_dec.encrypt(i_newpassword))), modifiedBy = i_username
        WHERE email = i_email AND enc_dec.decrypt(utl_raw.cast_to_varchar2(utl_encode.base64_decode(password))) = i_oldpassword;
        UPDATE address_tbl SET username = i_username, modifiedBy = i_username WHERE email = i_email;
        UPDATE contact_tbl SET username = i_username, modifiedBy = i_username WHERE email = i_email;
        UPDATE images_tbl SET username = i_username, modifiedBy = i_username WHERE email = i_email;
        UPDATE person_tbl SET username = i_username, modifiedBy = i_username WHERE email = i_email;
        UPDATE profile_tbl SET username = i_username, modifiedBy = i_username WHERE email = i_email;
        UPDATE verification_tbl SET username = i_username, modifiedBy = i_username WHERE email = i_email;
        UPDATE jwt_tbl SET username = i_username, accountStatus = 'Active', modifiedBy = i_username WHERE email = i_email;
        -- insert records for audit purpose
        auth_pkg.audit(i_username,i_email, 'UPDATE ACCOUNT', 'Successfully update user Account', i_username);
        o_response := 'success';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (UPDATE ACCOUNT): ' || i_email,
                    o_response => v_response
            );
            o_response := 'invalid credentials';
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'auth_pkg (UPDATE ACCOUNT): ' || i_email,
                    o_response => v_response
            );
            o_response := 'invalid credentials';
    END updateAccount;

END account_pkg;
/

SHOW ERRORS
/

PROMPT "End of creating Account Schema"