PROMPT "Creating Infraguard Schema"
SET SERVEROUTPUT ON;
SET DEFINE OFF;

/******************************************************************************
 * This piece of work is to enhance hats project functionality.               *
 *                                                                            *
 * Author:    eomisore                                                        *
 * File:      infraguard.sql                                                  *
 * Created:   05/04/2026, 22:07                                               *
 * Modified:  05/04/2026, 22:07                                               *
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
CREATE TABLE diskusage_tbl
(
    diskid          NUMBER GENERATED ALWAYS AS IDENTITY,
    total           NUMBER(10, 2),
    free            NUMBER(10, 2),
    usable          NUMBER(10, 2),
    modifiedBy      VARCHAR2(50 BYTE),
    modifiedDate    TIMESTAMP
);

CREATE TABLE memoryusage_tbl
(
    memoryid        NUMBER GENERATED ALWAYS AS IDENTITY,
    init            NUMBER(10, 2),
    used            NUMBER(10, 2),
    max             NUMBER(10, 2),
    committed       NUMBER(10, 2),
    modifiedBy      VARCHAR2(50 BYTE),
    modifiedDate    TIMESTAMP
);

CREATE TABLE cpuusage_tbl
(
    cpuid           NUMBER GENERATED ALWAYS AS IDENTITY,
    threadName      VARCHAR2(300 BYTE),
    state           VARCHAR2(50 BYTE),
    cpuTime         NUMBER,
    modifiedBy      VARCHAR2(50 BYTE),
    modifiedDate    TIMESTAMP
);

PROMPT "Commenting Tables"
---------------------------------------------------------------------
-- COMMENTS for clarity (shorter and clearer)
---------------------------------------------------------------------
COMMENT ON TABLE diskusage_tbl IS 'Hourly snapshots of server disk space metrics.';
COMMENT ON COLUMN diskusage_tbl.diskid IS 'Primary key for disk usage snapshot record.';
COMMENT ON COLUMN diskusage_tbl.total IS 'Total storage capacity of the disk (stored as GB).';
COMMENT ON COLUMN diskusage_tbl.free IS 'Amount of disk space currently unallocated.';
COMMENT ON COLUMN diskusage_tbl.usable IS 'Space available for use by the current user/process.';
COMMENT ON COLUMN diskusage_tbl.modifiedBy IS 'Audit column - indicates the system or user that recorded the metric.';
COMMENT ON COLUMN diskusage_tbl.modifiedDate IS 'Audit column - timestamp of the metric capture.';

COMMENT ON TABLE memoryusage_tbl IS 'Hourly snapshots of JVM/System memory allocation and usage.';
COMMENT ON COLUMN memoryusage_tbl.memoryid IS 'Primary key for memory usage snapshot record.';
COMMENT ON COLUMN memoryusage_tbl.init IS 'Initial amount of memory (GB) that the JVM requests from the OS.';
COMMENT ON COLUMN memoryusage_tbl.used IS 'Amount of memory currently occupied by the application.';
COMMENT ON COLUMN memoryusage_tbl.max IS 'The maximum amount of memory (GB) that can be used for memory management.';
COMMENT ON COLUMN memoryusage_tbl.committed IS 'Amount of memory guaranteed to be available for use by the JVM.';
COMMENT ON COLUMN memoryusage_tbl.modifiedBy IS 'Audit column - indicates the system or user that recorded the metric.';
COMMENT ON COLUMN memoryusage_tbl.modifiedDate IS 'Audit column - timestamp of the metric capture.';

COMMENT ON TABLE cpuusage_tbl IS 'Hourly detailed capture of individual CPU thread activity.';
COMMENT ON COLUMN cpuusage_tbl.cpuid IS 'Primary key for individual thread metric record.';
COMMENT ON COLUMN cpuusage_tbl.threadName IS 'The unique identifier/name of the execution thread.';
COMMENT ON COLUMN cpuusage_tbl.state IS 'Current execution state (e.g., RUNNABLE, WAITING, TIMED_WAITING).';
COMMENT ON COLUMN cpuusage_tbl.cpuTime IS 'Total CPU time consumed by the thread in nanoseconds.';
COMMENT ON COLUMN cpuusage_tbl.modifiedBy IS 'Audit column - indicates the system or user that recorded the metric.';
COMMENT ON COLUMN cpuusage_tbl.modifiedDate IS 'Audit column - timestamp of the metric capture.';

PROMPT "Setting Primary keys"
-- Setting Primary Key
ALTER TABLE diskusage_tbl ADD CONSTRAINT disk_pk PRIMARY KEY (diskid);
ALTER TABLE memoryusage_tbl ADD CONSTRAINT memory_pk PRIMARY KEY (memoryid);
ALTER TABLE cpuusage_tbl ADD CONSTRAINT cpu_pk PRIMARY KEY (cpuid);

-- Index to help fetch recent alerts fast
CREATE INDEX diskusage_tbl_idx ON diskusage_tbl (modifiedDate DESC);
CREATE INDEX memoryusage_tbl_idx ON memoryusage_tbl (modifiedDate DESC);
CREATE INDEX cpuusage_tbl_idx ON cpuusage_tbl (modifiedDate DESC);

PROMPT "Creating Triggers"
--------------------------------------------------------------
-- TRIGGERS: update modified_date & modified_by automatically
--------------------------------------------------------------
CREATE OR REPLACE TRIGGER diskusage_trg
    BEFORE INSERT OR UPDATE
    ON diskusage_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    IF :NEW.modifiedBy IS NULL THEN
        :NEW.modifiedBy := USER;
    END IF;
    IF :NEW.modifiedDate IS NULL THEN
        :NEW.modifiedDate := SYSTIMESTAMP;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'diskusage_trg',
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER memoryusage_trg
    BEFORE INSERT OR UPDATE
    ON memoryusage_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    IF :NEW.modifiedBy IS NULL THEN
        :NEW.modifiedBy := USER;
    END IF;
    IF :NEW.modifiedDate IS NULL THEN
        :NEW.modifiedDate := SYSTIMESTAMP;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'memoryusage_trg',
                o_response => v_response
        );
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER cpuusage_trg
    BEFORE INSERT OR UPDATE
    ON cpuusage_tbl
    FOR EACH ROW
DECLARE
    v_errorMessage VARCHAR2(4000);
    v_response     VARCHAR2(100);
BEGIN
    IF :NEW.modifiedBy IS NULL THEN
        :NEW.modifiedBy := USER;
    END IF;
    IF :NEW.modifiedDate IS NULL THEN
        :NEW.modifiedDate := SYSTIMESTAMP;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
        errorVault_pkg.storeError(
                i_faultcode => SQLCODE,
                i_faultmessage => v_errorMessage,
                i_faultservice => 'cpuusage_trg',
                o_response => v_response
        );
        RAISE;
END;
/

PROMPT "Enabling Triggers"

-- Enable Triggers
ALTER TRIGGER cpuusage_trg ENABLE;
ALTER TRIGGER diskusage_trg ENABLE;
ALTER TRIGGER memoryusage_trg ENABLE;

PROMPT "Creating Package Header"
--------------------------------------------------------------
-- PACKAGE: Creating infraguard header package
--------------------------------------------------------------
-- Create Header Package
CREATE OR REPLACE PACKAGE infraguard_pkg AS
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
    Name: infraguard_pkg
    Program Type: Package Specification
    Purpose: ADD/FIND/UPDATE/DELETE entity
    =================================================================================
    HISTORY
    =================================================================================
    | DATE 		| Owner 	| Activity
    =================================================================================
    | 05-APR-26	| eomisore 	| Created initial script.|
    =================================================================================
    */

    -- Procedure to log Disk Usage
    PROCEDURE logDiskUsage(
        p_total      IN diskusage_tbl.total%TYPE,
        p_free       IN diskusage_tbl.free%TYPE,
        p_usable     IN diskusage_tbl.usable%TYPE,
        p_modifiedBy IN diskusage_tbl.modifiedBy%TYPE DEFAULT NULL
    );

    -- Procedure to log Memory Usage
    PROCEDURE logMemoryUsage(
        p_init      IN memoryusage_tbl.init%TYPE,
        p_used      IN memoryusage_tbl.used%TYPE,
        p_max       IN memoryusage_tbl.max%TYPE,
        p_committed IN memoryusage_tbl.committed%TYPE,
        p_modifiedBy IN memoryusage_tbl.modifiedBy%TYPE DEFAULT NULL
    );

    -- Procedure to log CPU Thread Activity
    PROCEDURE logCpuUsage(
        p_threadName IN cpuusage_tbl.threadName%TYPE,
        p_state      IN cpuusage_tbl.state%TYPE,
        p_cpuTime    IN cpuusage_tbl.cpuTime%TYPE,
        p_modifiedBy IN cpuusage_tbl.modifiedBy%TYPE DEFAULT NULL
    );

    -- Get top disk metrics
    PROCEDURE getDiskMetrics(
        i_records IN NUMBER,
        o_diskList OUT SYS_REFCURSOR
    );

    -- Get top memory metrics
    PROCEDURE getMemoryMetrics(
        i_records IN NUMBER,
        o_memoryList OUT SYS_REFCURSOR
    );

    -- Get top cpu metrics
    PROCEDURE getCPUMetrics(
        i_records IN NUMBER,
        o_cpuList OUT SYS_REFCURSOR
    );

    -- New Purge Procedure
    PROCEDURE purgeOldMetrics(o_status OUT VARCHAR2);

END infraguard_pkg;
/

PROMPT "Creating Package Body"
--------------------------------------------------------------
-- PACKAGE: Creating infraguard body package
--------------------------------------------------------------
-- Create Body Package
CREATE OR REPLACE PACKAGE BODY infraguard_pkg AS
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
    Name: infraguard_pkg
    Program Type: Package Specification
    Purpose: ADD/FIND/UPDATE/DELETE entity
    =================================================================================
    HISTORY
    =================================================================================
    | DATE 		| Owner 	| Activity
    =================================================================================
    | 05-APR-26	| eomisore 	| Created initial script.|
    =================================================================================
    */

    -- Procedure to log Disk Usage
    PROCEDURE logDiskUsage(
        p_total IN diskusage_tbl.total%TYPE,
        p_free IN diskusage_tbl.free%TYPE,
        p_usable IN diskusage_tbl.usable%TYPE,
        p_modifiedBy IN diskusage_tbl.modifiedBy%TYPE DEFAULT NULL
    ) AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        INSERT INTO diskusage_tbl (total, free, usable, modifiedBy)
        VALUES (p_total, p_free, p_usable, p_modifiedBy);
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'infraguard_pkg (LOG DISK USAGE):',
                    o_response => v_response
            );
    END logDiskUsage;

    -- Procedure to log Memory Usage
    PROCEDURE logMemoryUsage(
        p_init IN memoryusage_tbl.init%TYPE,
        p_used IN memoryusage_tbl.used%TYPE,
        p_max IN memoryusage_tbl.max%TYPE,
        p_committed IN memoryusage_tbl.committed%TYPE,
        p_modifiedBy IN memoryusage_tbl.modifiedBy%TYPE DEFAULT NULL
    ) AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        INSERT INTO memoryusage_tbl (init, used, max, committed, modifiedBy)
        VALUES (p_init, p_used, p_max, p_committed, p_modifiedBy);
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'infraguard_pkg (LOG MEMORY USAGE):',
                    o_response => v_response
            );
    END logMemoryUsage;

    -- Procedure to log CPU Thread Activity
    PROCEDURE logCpuUsage(
        p_threadName IN cpuusage_tbl.threadName%TYPE,
        p_state IN cpuusage_tbl.state%TYPE,
        p_cpuTime IN cpuusage_tbl.cpuTime%TYPE,
        p_modifiedBy IN cpuusage_tbl.modifiedBy%TYPE DEFAULT NULL
    ) AS
        v_errorMessage VARCHAR2(4000);
        v_response     VARCHAR2(100);
    BEGIN
        INSERT INTO cpuusage_tbl (threadName, state, cpuTime, modifiedBy)
        VALUES (p_threadName, p_state, p_cpuTime, p_modifiedBy);
    EXCEPTION
        WHEN OTHERS THEN
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'infraguard_pkg (LOG CPU USAGE):',
                    o_response => v_response
            );
    END logCpuUsage;

    -- Get top disk metrics
    PROCEDURE getDiskMetrics(
        i_records IN NUMBER,
        o_diskList OUT SYS_REFCURSOR)
    AS
    BEGIN
        IF i_records IS NOT NULL THEN
            OPEN o_diskList FOR
                SELECT *
                FROM diskusage_tbl
                ORDER BY modifiedDate DESC
                    FETCH FIRST i_records ROWS ONLY;
        ELSE
            OPEN o_diskList FOR
                SELECT *
                FROM diskusage_tbl
                ORDER BY modifiedDate DESC;
        END IF;
    END getDiskMetrics;

    -- Get top memory metrics
    PROCEDURE getMemoryMetrics(
        i_records IN NUMBER,
        o_memoryList OUT SYS_REFCURSOR)
    AS
    BEGIN
        IF i_records IS NOT NULL THEN
            OPEN o_memoryList FOR
                SELECT *
                FROM memoryusage_tbl
                ORDER BY modifiedDate DESC
                    FETCH FIRST i_records ROWS ONLY;
        ELSE
            OPEN o_memoryList FOR
                SELECT *
                FROM memoryusage_tbl
                ORDER BY modifiedDate DESC;
        END IF;
    END getMemoryMetrics;

    -- Get top cpu metrics
    PROCEDURE getCPUMetrics(
        i_records IN NUMBER,
        o_cpuList OUT SYS_REFCURSOR)
    AS
    BEGIN
        IF i_records IS NOT NULL THEN
            OPEN o_cpuList FOR
                SELECT *
                FROM cpuusage_tbl
                WHERE threadName = 'main'
                ORDER BY modifiedDate DESC
                    FETCH FIRST i_records ROWS ONLY;
        ELSE
            OPEN o_cpuList FOR
                SELECT *
                FROM cpuusage_tbl
                WHERE threadName = 'main'
                ORDER BY modifiedDate DESC;
        END IF;
    END getCPUMetrics;

    PROCEDURE purgeOldMetrics(o_status OUT VARCHAR2) AS
        v_diskCount     NUMBER;
        v_memCount      NUMBER;
        v_cpuCount      NUMBER;
        v_errorMessage  VARCHAR2(4000);
        v_response      VARCHAR2(100);
    BEGIN
        DELETE FROM diskusage_tbl   WHERE modifiedDate < SYSTIMESTAMP - INTERVAL '12' HOUR;
        v_diskCount := SQL%ROWCOUNT;
        DELETE FROM memoryusage_tbl WHERE modifiedDate < SYSTIMESTAMP - INTERVAL '12' HOUR;
        v_memCount := SQL%ROWCOUNT;
        DELETE FROM cpuusage_tbl    WHERE modifiedDate < SYSTIMESTAMP - INTERVAL '12' HOUR;
        v_cpuCount := SQL%ROWCOUNT;
        COMMIT;
        o_status := 'Purge Success: Disk(' || v_diskCount || '), Mem(' || v_memCount || '), CPU(' || v_cpuCount || ')';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            v_errorMessage := SUBSTR(SQLERRM, 1, 4000);
            errorVault_pkg.storeError(
                    i_faultcode => SQLCODE,
                    i_faultmessage => v_errorMessage,
                    i_faultservice => 'infraguard_pkg (LOG CPU USAGE):',
                    o_response => v_response
            );
            o_status := 'Purge Failed: ' || SQLERRM;
    END purgeOldMetrics;

END infraguard_pkg;
/

SHOW ERRORS
/

PROMPT "End of creating Infraguard Schema"