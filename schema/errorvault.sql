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
CREATE TABLE error_vault_tbl
(
    error_id            NUMBER GENERATED ALWAYS AS IDENTITY,
    error_reference     VARCHAR2(100 BYTE),
    error_time          TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    error_code          VARCHAR2(32 BYTE),
    error_message       VARCHAR2(4000 BYTE),
    error_service       VARCHAR2(2000 BYTE)
);

CREATE TABLE alert_log_tbl (
    log_id       NUMBER GENERATED ALWAYS AS IDENTITY,
    log_time     TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    log_level    VARCHAR2(20) NOT NULL,
    log_logger   VARCHAR2(200) NOT NULL,
    log_message  CLOB NOT NULL
);

PROMPT "Commenting Tables"
-- Comment on tables
COMMENT ON COLUMN error_vault_tbl.error_id IS 'This is the unique primary identifier';
COMMENT ON TABLE error_vault_tbl IS 'Profile information for logging exceptions that occurs. An error log is a record of critical errors that are encountered by the application, operating system or server while in operation. Some of the common entries in an error log include table corruption and configuration corruption. Error logs in many cases serve as extremely useful tools for troubleshooting and managing systems, servers and even networks';
COMMENT ON COLUMN error_vault_tbl.error_reference IS 'The unique error transaction code';
COMMENT ON COLUMN error_vault_tbl.error_time IS 'This will be time at which the exception occurs ';
COMMENT ON COLUMN error_vault_tbl.error_code IS 'This will be the error code. Code of the failure';
COMMENT ON COLUMN error_vault_tbl.error_message IS 'This will be message about the exception. Capture the reason for the failure';
COMMENT ON COLUMN error_vault_tbl.error_service IS 'Name of the Service where error occurred';

COMMENT ON COLUMN alert_log_tbl.log_id IS 'This is the unique primary identifier';
COMMENT ON TABLE alert_log_tbl IS 'logging exceptions that occurs.';
COMMENT ON COLUMN alert_log_tbl.log_time IS 'timestamp of when the log happened';
COMMENT ON COLUMN alert_log_tbl.log_level IS 'level such as (INFO, WARN, ERROR, etc.)';
COMMENT ON COLUMN alert_log_tbl.log_logger IS 'logger (class/package origin)';
COMMENT ON COLUMN alert_log_tbl.log_message IS 'message (the actual log message)';

PROMPT "Setting Primary keys"
-- Setting Primary Key
ALTER TABLE error_vault_tbl ADD CONSTRAINT err_pk PRIMARY KEY (error_id);
ALTER TABLE alert_log_tbl ADD CONSTRAINT log_pk PRIMARY KEY (log_id);

-- Index to help fetch recent alerts fast
CREATE INDEX error_vault_tbl_idx ON error_vault_tbl (error_time DESC);
CREATE INDEX alert_log_tbl_idx ON alert_log_tbl (log_time DESC);

PROMPT "Creating triggers"
-- Creating Triggers
CREATE OR REPLACE TRIGGER error_vault_trg
    BEFORE INSERT
    ON error_vault_tbl
    FOR EACH ROW
BEGIN
    SELECT 'ERR|' || dbms_random.String('X', 6) INTO :NEW.error_reference FROM dual;
END;
/

PROMPT "Enabling Triggers"
-- Enable Triggers
ALTER TRIGGER error_vault_trg ENABLE;

PROMPT "Creating alert_log Header Package"

-- Create Packages
CREATE OR REPLACE PACKAGE alert_log_pkg
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
Name: alert_log_pkg
Program Type: Package Specification
Purpose: ADD/FIND/UPDATE entity
=================================================================================
HISTORY
=================================================================================
| DATE 		| Owner 	| Activity
=================================================================================
| 24-SEP-25	| eomisore 	| Created initial script.|
=================================================================================
*/
    -- Get top alerts
    PROCEDURE get_alerts(
        i_records IN NUMBER,
        o_alertList OUT SYS_REFCURSOR);

END alert_log_pkg;
/

PROMPT "Creating alert_log Body Package"

-- Create Packages
CREATE OR REPLACE PACKAGE BODY alert_log_pkg
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
Name: alert_log_pkg
Program Type: Package Specification
Purpose: ADD/FIND/UPDATE entity
=================================================================================
HISTORY
=================================================================================
| DATE 		| Owner 	| Activity
=================================================================================
| 24-SEP-25	| eomisore 	| Created initial script.|
=================================================================================
*/

    -- Get top errors
    PROCEDURE get_alerts(
        i_records IN NUMBER,
        o_alertList OUT SYS_REFCURSOR)
    AS
    BEGIN
        OPEN o_alertList FOR
            SELECT log_id, log_time, log_level, log_logger, log_message
            FROM alert_log_tbl
            ORDER BY log_time DESC
                FETCH FIRST i_records ROWS ONLY;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'Error fetching top records: ' || SQLERRM);
    END get_alerts;

END alert_log_pkg;
/

PROMPT "Creating error_vault Header Package"

-- Create Packages
CREATE OR REPLACE PACKAGE error_vault_pkg
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
Name: error_vault_pkg
Program Type: Package Specification
Purpose: ADD/FIND/UPDATE entity
=================================================================================
HISTORY
=================================================================================
| DATE 		| Owner 	| Activity
=================================================================================
| 07-SEP-25	| eomisore 	| Created initial script.|
=================================================================================
*/
    -- Log new error
    PROCEDURE store_error(
        i_faultcode IN error_vault_tbl.error_code%TYPE,
        i_faultmessage IN error_vault_tbl.error_message%TYPE,
        i_faultservice IN error_vault_tbl.error_service%TYPE,
        o_response OUT VARCHAR2);

    -- Get top errors
    PROCEDURE get_errors(
        i_records IN NUMBER,
        o_errorList OUT SYS_REFCURSOR);

END error_vault_pkg;
/

PROMPT "Creating User error_vault Body Package"

-- Create Packages
CREATE OR REPLACE PACKAGE BODY error_vault_pkg
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
Name: error_vault_pkg
Program Type: Package Specification
Purpose: ADD/FIND/UPDATE entity
=================================================================================
HISTORY
=================================================================================
| DATE 		| Owner 	| Activity
=================================================================================
| 07-SEP-25	| eomisore 	| Created initial script.|
=================================================================================
*/
    -- Log new error
    PROCEDURE store_error(
        i_faultcode IN error_vault_tbl.error_code%TYPE,
        i_faultmessage IN error_vault_tbl.error_message%TYPE,
        i_faultservice IN error_vault_tbl.error_service%TYPE,
        o_response OUT VARCHAR2)
    AS
    BEGIN
        INSERT INTO error_vault_tbl (error_code, error_message, error_service)
        VALUES (i_faultcode, i_faultmessage, i_faultservice)
        RETURNING error_reference INTO o_response;
    EXCEPTION
        WHEN OTHERS THEN ROLLBACK;
        o_response := 'ERROR CODE: ' || SQLCODE || 'ERROR DETAILS: ' || SUBSTR(SQLERRM, 1, 2000);
    END store_error;

    -- Get top errors
    PROCEDURE get_errors(
        i_records IN NUMBER,
        o_errorList OUT SYS_REFCURSOR)
    AS
    BEGIN
        OPEN o_errorList FOR
            SELECT error_id, error_reference, error_time, error_code, error_message, error_service
            FROM error_vault_tbl
            ORDER BY error_time DESC
                FETCH FIRST i_records ROWS ONLY;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'Error fetching top records: ' || SQLERRM);
    END get_errors;

END error_vault_pkg;
/

ALTER PACKAGE alert_log_pkg COMPILE PACKAGE;
ALTER PACKAGE alert_log_pkg COMPILE BODY;
ALTER PACKAGE error_vault_pkg COMPILE PACKAGE;
ALTER PACKAGE error_vault_pkg COMPILE BODY;

SHOW ERRORS
/

PROMPT "End of Creating error_vault Schema"