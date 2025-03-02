/******************************************************************************
 * This piece of work is to enhance hats project functionality.          	  *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      errorhospital.sql                                               *
 * Created:   26/10/2024, 21:19                                               *
 * Modified:  26/10/2024, 21:20                                               *
 *                                                                            *
 * Copyright (c)  2024.  Aerosimo Ltd                                         *
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

PROMPT "Creating ErrorHospital Schema."
SET SERVEROUTPUT ON;
SET DEFINE OFF;

PROMPT "Creating Tables"
-- Create Tables
CREATE TABLE ErrorHospital_tbl
(
    errorRef     VARCHAR2(100 byte),
    errorTime    TIMESTAMP,
    errorCode    VARCHAR2(32 byte),
    errorMessage VARCHAR2(4000 byte),
    errorService VARCHAR2(2000 byte)
);

PROMPT "Commenting Tables"
-- Comment on tables

COMMENT ON TABLE ErrorHospital_tbl IS 'Profile information for logging exceptions that occurs. An error log is a record of critical errors that are encountered by the application, operating system or server while in operation. Some of the common entries in an error log include table corruption and configuration corruption. Error logs in many cases serve as extremely useful tools for troubleshooting and managing systems, servers and even networks';
COMMENT ON COLUMN ErrorHospital_tbl.errorRef IS 'The unique error transaction code';
COMMENT ON COLUMN ErrorHospital_tbl.errorTime IS 'This will be time at which the exception occurs ';
COMMENT ON COLUMN ErrorHospital_tbl.errorCode IS 'This will be the error code. Code of the failure';
COMMENT ON COLUMN ErrorHospital_tbl.errorMessage IS 'This will be message about the exception. Capture the reason for the failure';
COMMENT ON COLUMN ErrorHospital_tbl.errorService IS 'Name of the Service where error occurred';

PROMPT "Setting Primary keys"
-- Setting Primary Key
ALTER TABLE ErrorHospital_tbl ADD CONSTRAINT err_pk PRIMARY KEY (errorRef);

PROMPT "Creating triggers"
-- Creating Triggers
CREATE OR REPLACE TRIGGER ErrorHospital_trg
    BEFORE INSERT
    ON ErrorHospital_tbl
    FOR EACH ROW
BEGIN
    SELECT SYSTIMESTAMP INTO :NEW.errorTime FROM dual;
    SELECT 'ERR|' || dbms_random.String('X', 26) INTO :NEW.errorRef FROM dual;
END;
/

PROMPT "Enabling Triggers"
-- Enable Triggers
    ALTER TRIGGER ErrorHospital_trg ENABLE;

PROMPT "Creating User ErrorHospital Header Package"

-- Create Packages
CREATE OR REPLACE PACKAGE ErrorHospital_pkg
AS
    /* $Header: ErrorHospital_pkg. 1.0.0 26-OCT-24 21:28 Package
=================================================================================
  Copyright (c) 2024 Aerosimo

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
Name: ErrorHospital_pkg
Program Type: Package Specification
Purpose: ADD/FIND/UPDATE/DELETE entity
=================================================================================
HISTORY
=================================================================================
| DATE 		| Owner 	| Activity
=================================================================================
| 26-OCT-24	| eomisore 	| Created initial script.|
=================================================================================
*/
    -- Log new error
    PROCEDURE ErrorCollector(
        i_faultcode IN ErrorHospital_tbl.errorCode%TYPE,
        i_faultmessage IN ErrorHospital_tbl.errorMessage%TYPE,
        i_faultservice IN ErrorHospital_tbl.errorService%TYPE,
        o_response OUT VARCHAR2);

    -- Get top errors
    PROCEDURE GetTopErrors(
        i_records IN NUMBER,
        o_errorList OUT SYS_REFCURSOR);

END ErrorHospital_pkg;
/

PROMPT "Creating User ErrorHospital Body Package"

-- Create Packages
CREATE OR REPLACE PACKAGE BODY ErrorHospital_pkg
AS
    /* $Body: ErrorHospital_pkg. 1.0.0 26-OCT-24 21:35 Package
=================================================================================
  Copyright (c) 2024 Aerosimo

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
Name: ErrorHarbour_pkg
Program Type: Package Specification
Purpose: ADD/FIND/UPDATE/DELETE entity
=================================================================================
HISTORY
=================================================================================
| DATE 		| Owner 	| Activity
=================================================================================
| 26-OCT-24	| eomisore 	| Created initial script.|
=================================================================================
*/
    -- Log new error
    PROCEDURE ErrorCollector(
        i_faultcode IN ErrorHospital_tbl.errorCode%TYPE,
        i_faultmessage IN ErrorHospital_tbl.errorMessage%TYPE,
        i_faultservice IN ErrorHospital_tbl.errorService%TYPE,
        o_response OUT VARCHAR2)
    AS
    BEGIN
        INSERT INTO ErrorHospital_tbl (errorCode, errorMessage, errorService)
        VALUES (i_faultcode, i_faultmessage, i_faultservice)
        RETURNING errorRef INTO o_response;
    EXCEPTION
        WHEN OTHERS THEN ROLLBACK;
        o_response := 'ERROR CODE: ' || SQLCODE || 'ERROR DETAILS: ' || SUBSTR(SQLERRM, 1, 2000);
    END ErrorCollector;

    -- Get top errors
    PROCEDURE GetTopErrors(
        i_records IN NUMBER,
        o_errorList OUT SYS_REFCURSOR)
    AS
    BEGIN
        OPEN o_errorList FOR
            SELECT errorRef, errorTime, errorCode, errorMessage, errorService
            FROM ErrorHospital_tbl
            ORDER BY errorTime DESC
                FETCH FIRST i_records ROWS ONLY;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'Error fetching top records: ' || SQLERRM);
    END GetTopErrors;

END ErrorHospital_pkg;
/

ALTER PACKAGE ErrorHospital_pkg COMPILE PACKAGE;
ALTER PACKAGE ErrorHospital_pkg COMPILE BODY;

SHOW ERRORS
/

PROMPT "End of Creating ErrorHospital Schema"