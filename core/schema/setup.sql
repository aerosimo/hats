PROMPT "Start initialising users and schemas."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance HATS initial setup functionality.      	  *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      setup.sql                                                       *
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

-----------------------------------------------
--  Connect as ADMIN and run the blow script --
-----------------------------------------------
PROMPT "Runing User Creation script"
-- Create user
CREATE USER Phoenix IDENTIFIED BY "YK8h1464c9MA#F7s$V99";

PROMPT "Runing Cryptography Creation script"
-- Create package
CREATE OR REPLACE PACKAGE ENC_DEC AS
    FUNCTION ENCRYPT (P_PLAINTEXT VARCHAR2) RETURN RAW DETERMINISTIC;
    FUNCTION DECRYPT (P_ENCRYPTEDTEXT RAW) RETURN VARCHAR2 DETERMINISTIC;
END;
/

CREATE OR REPLACE PACKAGE BODY ENC_DEC AS
    ENCRYPTION_TYPE    PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_DES
        + DBMS_CRYPTO.CHAIN_CBC
        + DBMS_CRYPTO.PAD_PKCS5;
    ENCRYPTION_KEY     RAW (32) := UTL_RAW.CAST_TO_RAW('MYENCRYPTIONKEY');
    FUNCTION ENCRYPT (P_PLAINTEXT VARCHAR2) RETURN RAW DETERMINISTIC
        IS
        ENCRYPTED_RAW      RAW (2000);
    BEGIN
        ENCRYPTED_RAW := DBMS_CRYPTO.ENCRYPT
            (
                SRC => UTL_RAW.CAST_TO_RAW (P_PLAINTEXT),
                TYP => ENCRYPTION_TYPE,
                KEY => ENCRYPTION_KEY
            );
        RETURN ENCRYPTED_RAW;
    END ENCRYPT;
    FUNCTION DECRYPT (P_ENCRYPTEDTEXT RAW) RETURN VARCHAR2 DETERMINISTIC
        IS
        DECRYPTED_RAW      RAW (2000);
    BEGIN
        DECRYPTED_RAW := DBMS_CRYPTO.DECRYPT
            (
                SRC => P_ENCRYPTEDTEXT,
                TYP => ENCRYPTION_TYPE,
                KEY => ENCRYPTION_KEY
            );
        RETURN (UTL_RAW.CAST_TO_VARCHAR2 (DECRYPTED_RAW));
    END DECRYPT;
END;
/

PROMPT "Runing User Creation script"

GRANT CONNECT TO Phoenix;
GRANT CONSOLE_DEVELOPER TO Phoenix;
GRANT DWROLE TO Phoenix;
GRANT GRAPH_DEVELOPER TO Phoenix;
GRANT OML_DEVELOPER TO Phoenix;
GRANT CREATE VIEW TO Phoenix;
GRANT CREATE SESSION TO Phoenix;
GRANT EXECUTE ON ADMIN.ENC_DEC TO Phoenix;
GRANT CONNECT, RESOURCE, CREATE ANY DIRECTORY TO Phoenix;
GRANT SELECT_CATALOG_ROLE TO Phoenix;
GRANT RESOURCE TO Phoenix;
GRANT EXECUTE ON DBMS_AQ TO Phoenix;
GRANT EXECUTE ON DBMS_AQADM TO Phoenix;
GRANT EXECUTE ON DBMS_FLASHBACK TO Phoenix;
EXECUTE DBMS_AQADM.GRANT_SYSTEM_PRIVILEGE('ENQUEUE_ANY', 'Phoenix', TRUE);
EXECUTE DBMS_AQADM.GRANT_SYSTEM_PRIVILEGE('DEQUEUE_ANY', 'Phoenix', TRUE);
GRANT AQ_ADMINISTRATOR_ROLE TO Phoenix;
GRANT EXECUTE ON DBMS_LOCK TO Phoenix;
GRANT EXECUTE ON DBMS_CRYPTO TO Phoenix;
GRANT EXECUTE ON SYS.DBMS_AQIN TO Phoenix;
GRANT EXECUTE ON SYS.DBMS_AQJMS TO Phoenix;
GRANT AQ_ADMINISTRATOR_ROLE TO Phoenix;
GRANT AQ_USER_ROLE TO Phoenix;
GRANT EXECUTE ON UTL_HTTP TO Phoenix;
GRANT EXECUTE ON UTL_INADDR TO Phoenix;
ALTER USER Phoenix DEFAULT ROLE CONSOLE_DEVELOPER,DWROLE,GRAPH_DEVELOPER,OML_DEVELOPER;

-- REST ENABLE
BEGIN
    ORDS_ADMIN.ENABLE_SCHEMA(
        p_enabled => TRUE,
        p_schema => 'Phoenix',
        p_url_mapping_type => 'BASE_PATH',
        p_url_mapping_pattern => 'phoenix',
        p_auto_rest_auth=> TRUE
    );
    -- ENABLE DATA SHARING
    C##ADP$SERVICE.DBMS_SHARE.ENABLE_SCHEMA(
            SCHEMA_NAME => 'Phoenix',
            ENABLED => TRUE
    );
    commit;
END;
/

-- ENABLE GRAPH
ALTER USER Phoenix GRANT CONNECT THROUGH GRAPH$PROXY_USER;

-- ENABLE OML
ALTER USER Phoenix GRANT CONNECT THROUGH OML$PROXY;

-- QUOTA
ALTER USER Phoenix QUOTA UNLIMITED ON DATA;

show errors
/

PROMPT "End initialising users and schemas."