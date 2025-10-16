PROMPT "Creating Error Vault Schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      errorvault.sql                                                  *
 * Created:   07/09/2025, 23:54                                               *
 * Modified:  07/09/2025, 23:54                                               *
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
---------------------------------------------------------
-- TABLES creating the required tables for authentication
---------------------------------------------------------
-- Create the main error table
CREATE TABLE errorVault_tbl
(
    errorId            NUMBER GENERATED ALWAYS AS IDENTITY,
    errorReference     VARCHAR2(100 BYTE),
    errorTime          TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    errorCode          VARCHAR2(32 BYTE),
    errorMessage       VARCHAR2(4000 BYTE),
    errorService       VARCHAR2(2000 BYTE)
);

PROMPT "Commenting Tables"
-- Comment on tables
COMMENT ON COLUMN errorVault_tbl.errorId IS 'This is the unique primary identifier';
COMMENT ON TABLE errorVault_tbl IS 'Profile information for logging exceptions that occurs. An error log is a record of critical errors that are encountered by the application, operating system or server while in operation. Some of the common entries in an error log include table corruption and configuration corruption. Error logs in many cases serve as extremely useful tools for troubleshooting and managing systems, servers and even networks';
COMMENT ON COLUMN errorVault_tbl.errorReference IS 'The unique error transaction code';
COMMENT ON COLUMN errorVault_tbl.errorTime IS 'This will be time at which the exception occurs ';
COMMENT ON COLUMN errorVault_tbl.errorCode IS 'This will be the error code. Code of the failure';
COMMENT ON COLUMN errorVault_tbl.errorMessage IS 'This will be message about the exception. Capture the reason for the failure';
COMMENT ON COLUMN errorVault_tbl.errorService IS 'Name of the Service where error occurred';

PROMPT "Setting Primary keys"
-- Setting Primary Key
ALTER TABLE errorVault_tbl ADD CONSTRAINT err_pk PRIMARY KEY (errorId);

-- Index to help fetch recent alerts fast
CREATE INDEX errorVault_tbl_idx ON errorVault_tbl (errorTime DESC);

PROMPT "Creating triggers"
-- Creating Triggers
CREATE OR REPLACE TRIGGER errorVault_trg
    BEFORE INSERT
    ON errorVault_tbl
    FOR EACH ROW
BEGIN
    SELECT 'ERR|' || dbms_random.String('X', 6) INTO :NEW.errorReference FROM dual;
END;
/

PROMPT "Enabling Triggers"
-- Enable Triggers
ALTER TRIGGER errorVault_trg ENABLE;

PROMPT "Creating errorVault Header Package"

-- Create Packages
CREATE OR REPLACE PACKAGE errorVault_pkg
AS
    /* Header Package
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
Name: errorVault_pkg
Program Type: Package Specification
Purpose: ADD/FIND/UPDATE entity
=================================================================================
HISTORY
=================================================================================
| DATE 		| Owner 	| Activity
=================================================================================
| 07-SEP-25	| eomisore 	| Created initial script.|
=================================================================================
| 11-OCT-25	| eomisore 	| Add extra feature such as delete, update.|
=================================================================================
*/
    -- Log new error
    PROCEDURE storeError(
        i_faultcode IN errorVault_tbl.errorCode%TYPE,
        i_faultmessage IN errorVault_tbl.errorMessage%TYPE,
        i_faultservice IN errorVault_tbl.errorService%TYPE,
        o_response OUT VARCHAR2);

    -- Get top errors
    PROCEDURE getErrors(
        i_records IN NUMBER,
        o_errorList OUT SYS_REFCURSOR);

END errorVault_pkg;
/

PROMPT "Creating errorVault Body Package"

-- Create Packages
CREATE OR REPLACE PACKAGE BODY errorVault_pkg
AS
    /* Body Package
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
Name: errorVault_pkg
Program Type: Package Specification
Purpose: ADD/FIND/UPDATE entity
=================================================================================
HISTORY
=================================================================================
| DATE 		| Owner 	| Activity
=================================================================================
| 07-SEP-25	| eomisore 	| Created initial script.|
=================================================================================
| 11-OCT-25	| eomisore 	| Add extra feature such as delete, update.|
=================================================================================
*/
    -- Log new error
    PROCEDURE storeError(
        i_faultcode IN errorVault_tbl.errorCode%TYPE,
        i_faultmessage IN errorVault_tbl.errorMessage%TYPE,
        i_faultservice IN errorVault_tbl.errorService%TYPE,
        o_response OUT VARCHAR2)
    AS
    BEGIN
        INSERT INTO errorVault_tbl (errorCode, errorMessage, errorService)
        VALUES (i_faultcode, i_faultmessage, i_faultservice)
        RETURNING errorReference INTO o_response;
    EXCEPTION
        WHEN OTHERS THEN ROLLBACK;
        o_response := 'ERROR CODE: ' || SQLCODE || 'ERROR DETAILS: ' || SUBSTR(SQLERRM, 1, 2000);
    END storeError;

    -- Get top errors
    PROCEDURE getErrors(
        i_records IN NUMBER,
        o_errorList OUT SYS_REFCURSOR)
    AS
    BEGIN
        OPEN o_errorList FOR
            SELECT errorId, errorReference, errorTime, errorCode, errorMessage, errorService
            FROM errorVault_tbl
            ORDER BY errorTime DESC
                FETCH FIRST i_records ROWS ONLY;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'Error fetching top records: ' || SQLERRM);
    END getErrors;

END errorVault_pkg;
/

ALTER PACKAGE errorVault_pkg COMPILE PACKAGE;
ALTER PACKAGE errorVault_pkg COMPILE BODY;

SHOW ERRORS
/

PROMPT "End of Creating Error Vault Schema"