PROMPT "Creating Authentication Schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      authentication.sql                                              *
 * Created:   20/01/2026, 20:34                                               *
 * Modified:  20/01/2026, 20:35                                               *
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
-- PACKAGE: Creating authentication header package
--------------------------------------------------------------
-- Create Header Package
CREATE OR REPLACE PACKAGE authentication_pkg
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
    Name: auth_pkg
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
    -- Get Verification Code
    PROCEDURE getVerification(
        i_username IN VARCHAR2,
        o_verificationToken OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Create user account also known as signup
    PROCEDURE registerUser(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_password IN VARCHAR2,
        o_verificationToken OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Verify email
    PROCEDURE verifyEmail(
        i_verificationToken IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- issue authentication key
    PROCEDURE issueAuthKey(
        i_username IN VARCHAR2,
        o_authKey  OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- user login
    PROCEDURE userLogin(
        i_username IN VARCHAR2,
        i_password IN VARCHAR2,
        o_email OUT VARCHAR2,
        o_authKey OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Validate user authentication token
    PROCEDURE validateAuthKey(
        i_authKey IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- user logout
    PROCEDURE userLogout(
        i_authKey IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Delete user account
    PROCEDURE deleteUserAccount(
        i_username IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Update account password and username
    PROCEDURE updateUserAccount(
        i_username IN VARCHAR2,
        i_oldpassword IN VARCHAR2,
        i_newpassword IN VARCHAR2,
        o_response OUT VARCHAR2);

    -- Forgot Password
    PROCEDURE forgotPassword(
        i_email IN VARCHAR2,
        o_verificationToken OUT VARCHAR2,
        o_username OUT VARCHAR2,
        o_response OUT VARCHAR2);

    -- Reset Password
    PROCEDURE resetPassword(
        i_verificationToken IN VARCHAR2,
        i_password IN VARCHAR2,
        o_response OUT VARCHAR2);

END authentication_pkg;
/

PROMPT "Creating Package Body"
--------------------------------------------------------------
-- PACKAGE: Creating authentication body package
--------------------------------------------------------------
-- Create Body Package
CREATE OR REPLACE PACKAGE BODY authentication_pkg
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
    Name: auth_pkg
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
    -- Get Verification Code
    PROCEDURE getVerification(
        i_username IN VARCHAR2,
        o_verificationToken OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_exists       NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_exists
        FROM verification_tbl
        WHERE username = i_username;
        IF v_exists = 1 THEN
            UPDATE verification_tbl
            SET issuedAt   = SYSTIMESTAMP,
                modifiedBy = i_username
            WHERE username = i_username
            RETURNING verificationToken INTO o_verificationToken;
        ELSE
            INSERT INTO verification_tbl(username, modifiedBy)
            VALUES (i_username, i_username)
            RETURNING verificationToken INTO o_verificationToken;
        END IF;
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'authentication_pkg (GET VERIFICATION CODE): ' || i_username,
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END getVerification;

    -- Create user account also known as signup
    PROCEDURE registerUser(
        i_username IN VARCHAR2,
        i_email IN VARCHAR2,
        i_password IN VARCHAR2,
        o_verificationToken OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_encodedPwd    VARCHAR2(400);
        v_count         NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM credentials_tbl
        WHERE email = i_email;
        IF v_count = 1 THEN
            o_verificationToken := 'email already exist';
            o_response := 'unsuccessful';
        ELSIF LENGTH(i_password) < 8 THEN
            o_verificationToken := 'invalid password';
            o_response := 'unsuccessful';
        ELSE
            v_encodedPwd := UTL_ENCODE.BASE64_ENCODE(admin.enc_dec.encrypt(i_password));
            INSERT INTO credentials_tbl(username, email, password, modifiedBy)
            VALUES (i_username, i_email, v_encodedPwd, i_username);
            getVerification(i_username,o_verificationToken,v_response);
            o_response := 'success';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'authentication_pkg (CREATE ACCOUNT): ' || i_username,
                    o_response => v_response
            );
            o_verificationToken := 'internal server error';
            o_response := 'unsuccessful';
    END registerUser;

    -- Verify email
    PROCEDURE verifyEmail(
        i_verificationToken IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
        v_username     VARCHAR2(100);
        v_count        NUMBER;
    BEGIN
        SELECT COUNT(*),username INTO v_count, v_username FROM verification_tbl
        WHERE verificationToken = i_verificationToken GROUP BY username;
        IF v_count = 1 THEN
            UPDATE credentials_tbl
            SET emailVerified = 'Y',
                accountStatus = 'Active',
                modifiedBy = v_username
            WHERE username = v_username;
            UPDATE verification_tbl
            SET usedFlag = 'Y',
                modifiedBy = v_username
            WHERE username = v_username
              AND verificationToken = i_verificationToken;
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
                    i_faultservice => 'authentication_pkg (CONFIRM EMAIL): ' || v_username,
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END verifyEmail;

    -- issue authentication key
    PROCEDURE issueAuthKey(
        i_username IN VARCHAR2,
        o_authKey  OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_seed          VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_raw_input     RAW(2000);
        v_raw_hash      RAW(32);
    BEGIN
        -- 1. Build a unique seed (username + timestamp + random string)
        v_seed := i_username
            || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF3')
            || DBMS_RANDOM.STRING('A', 20);
        -- 2. Convert seed to RAW safely (always specify UTF8)
        v_raw_input := UTL_I18N.STRING_TO_RAW(v_seed, 'AL32UTF8');
        -- 3. Generate SHA256 hash
        v_raw_hash := DBMS_CRYPTO.HASH(v_raw_input, DBMS_CRYPTO.HASH_SH256);
        -- 4. Convert RAW to hex string (safe to store as VARCHAR2(64))
        o_authKey := LOWER(RAWTOHEX(v_raw_hash));
        -- 5. Insert into table
        INSERT INTO credence_tbl (username, authKey, issuedAt, expiresAt, activeFlag)
        VALUES (i_username, o_authKey, SYSTIMESTAMP, SYSTIMESTAMP + INTERVAL '2' HOUR, 'Y');
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'authentication_pkg (ISSUE AUTH KEY): ' || i_username,
                    o_response => v_response
            );
            o_response := 'error';
    END issueAuthKey;

    -- user login
    PROCEDURE userLogin(
        i_username IN VARCHAR2,
        i_password IN VARCHAR2,
        o_email OUT VARCHAR2,
        o_authKey OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_storedPwd     VARCHAR2(400);
        v_decodedPwd    VARCHAR2(400);
        v_failed        NUMBER;
    BEGIN
        -- fetch user
        SELECT password, email INTO v_storedPwd, o_email
        FROM credentials_tbl WHERE username = i_username AND accountStatus = 'Active';
        -- decode password
        v_decodedPwd := admin.enc_dec.decrypt(UTL_ENCODE.BASE64_DECODE(v_storedPwd));
        -- check password
        IF v_decodedPwd = i_password THEN
            -- reset failed login
            UPDATE credentials_tbl
            SET failedLogin = 0, lastLogin = SYSTIMESTAMP
            WHERE username = i_username;
            -- generate authKey
            issueAuthKey(i_username, o_authKey, o_response);
            o_response := 'success';
        ELSE
            -- increment failed login
            UPDATE credentials_tbl
            SET failedLogin = failedLogin + 1
            WHERE username = i_username;
            SELECT failedLogin INTO v_failed
            FROM credentials_tbl WHERE username = i_username;
            IF v_failed >= 3 THEN
                UPDATE credentials_tbl
                SET accountStatus = 'Locked'
                WHERE username = i_username;
            END IF;
            o_response := 'invalid credentials';
            o_authKey := NULL;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'authentication_pkg (USER LOGIN): ' || i_username,
                    o_response => v_response
            );
            o_response := 'invalid credentials';
            o_authKey := NULL;
    END userLogin;

    -- Validate user authentication token
    PROCEDURE validateAuthKey(
        i_authKey IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_count     NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM credence_tbl
        WHERE authKey = i_authKey
          AND expiresAt > SYSTIMESTAMP
          AND activeFlag = 'Y';
        o_response := CASE WHEN v_count > 0 THEN 'valid' ELSE 'invalid' END;
    END validateAuthKey;

    -- Logout
    PROCEDURE userLogout(
        i_authKey IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        UPDATE credence_tbl
        SET activeFlag = 'N'
        WHERE authKey = i_authKey;
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'authentication_pkg (USER LOGOUT): ',
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END userLogout;

    -- Delete user account
    PROCEDURE deleteUserAccount(
        i_username IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        DELETE
        FROM credentials_tbl
        WHERE username = i_username;
        o_response := 'success';
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'authentication_pkg (DELETE ACCOUNT): ' || i_username,
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END deleteUserAccount;

    -- Update account password and username
    PROCEDURE updateUserAccount(
        i_username IN VARCHAR2,
        i_oldpassword IN VARCHAR2,
        i_newpassword IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_encodedPwd    VARCHAR2(400);
        v_response      VARCHAR2(100);
    BEGIN
        IF i_username IS NULL THEN
            o_response := 'username is mandatory and cannot be empty';
        ELSIF i_oldpassword IS NULL THEN
            o_response := 'password is mandatory and cannot be empty';
        ELSIF i_newpassword IS NULL OR LENGTH(i_newpassword) < 8 THEN
            o_response := 'password is mandatory and must be at least 8 characters long';
        ELSE
            v_encodedPwd := UTL_ENCODE.BASE64_ENCODE(admin.enc_dec.encrypt(i_newpassword));
            UPDATE credentials_tbl
            SET password = v_encodedPwd,
                modifiedBy = i_username
            WHERE admin.enc_dec.decrypt(UTL_ENCODE.BASE64_DECODE(password)) = i_oldpassword
            AND username = i_username;
            o_response := 'success';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'authentication_pkg (UPDATE ACCOUNT): ' || i_username,
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END updateUserAccount;

    -- Forgot Password
    PROCEDURE forgotPassword(
        i_email IN VARCHAR2,
        o_verificationToken OUT VARCHAR2,
        o_username OUT VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
        v_count         NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM credentials_tbl WHERE email = i_email;
        IF v_count = 1 THEN
            UPDATE credentials_tbl
            SET accountStatus = 'Locked'
            WHERE email = i_email
            RETURNING username INTO o_username;
            UPDATE credence_tbl
            SET activeFlag = 'N'
            WHERE username = o_username;
            -- Generate and return authentication token
            getVerification(o_username, o_verificationToken, o_response);
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
                    i_faultservice => 'authentication_pkg (FORGET PASSWORD): ' || i_email,
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END forgotPassword;

    -- Reset Password
    PROCEDURE resetPassword(
        i_verificationToken IN VARCHAR2,
        i_password IN VARCHAR2,
        o_response OUT VARCHAR2)
    AS
        v_errorMessage  VARCHAR2(4000);
        v_username      VARCHAR2(100);
        v_encodedPwd    VARCHAR2(100);
        v_response      VARCHAR2(100);
        v_count         NUMBER;
    BEGIN
        -- Fetch authentication details and status
        SELECT username, COUNT(*) INTO v_username, v_count FROM verification_tbl WHERE verificationToken = i_verificationToken GROUP BY username;
        IF v_count = 1 THEN
            UPDATE verification_tbl SET usedFlag = 'Y', modifiedBy = v_username WHERE verificationToken = i_verificationToken;
            v_encodedPwd := UTL_ENCODE.BASE64_ENCODE(admin.enc_dec.encrypt(i_password));
            UPDATE credentials_tbl SET password = v_encodedPwd, modifiedBy = v_username, accountStatus = 'Active' WHERE username = v_username;
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
                    i_faultservice => 'authentication_pkg (RESET PASSWORD) ',
                    o_response => v_response
            );
            o_response := 'unsuccessful';
    END resetPassword;

END authentication_pkg;
/

SHOW ERRORS
/

PROMPT "End of creating Authentication Schema"