-- Changing the global name of a database
-- Global name always in upper case
exec rdsadmin.rdsadmin_util.rename_global_name(p_new_global_name => 'new_global_name');
select * from global_name;

-- Creating and sizing tablespaces
-- default value: /rdsdbdata/db
select value from v$parameter where name = 'db_create_file_dest';
-- default value: BIGFILE
select property_value from database_properties where property_name = 'DEFAULT_TBS_TYPE';

-- create tablespace users2, default is bigfile
CREATE TABLESPACE users2 DATAFILE SIZE 1G AUTOEXTEND ON MAXSIZE 10G;
CREATE TEMPORARY TABLESPACE temp01;
ALTER TABLESPACE users2 RESIZE 200M;
-- works only if users2 created as smallfile tablespace
ALTER TABLESPACE users2 ADD DATAFILE SIZE 100000M AUTOEXTEND ON NEXT 250m MAXSIZE UNLIMITED;

-- Setting the default (temporary) tablespace
EXEC rdsadmin.rdsadmin_util.alter_default_tablespace(tablespace_name => 'users2');
EXEC rdsadmin.rdsadmin_util.alter_default_temp_tablespace(tablespace_name => 'temp01');


-- Checkpointing a database
EXEC rdsadmin.rdsadmin_util.checkpoint;

-- Enable/disable distributed recovery
EXEC rdsadmin.rdsadmin_util.enable_distr_recovery;
EXEC rdsadmin.rdsadmin_util.disable_distr_recovery;

-- Setting the database time zone
/*
The database time zone is relevant only for TIMESTAMP WITH LOCAL TIME ZONE columns. 
Oracle Corporation recommends that you set the database time zone to UTC (0:00) 
to avoid data conversion and improve performance when data is transferred among databases. 
This is especially important for distributed databases, replication, and exporting and importing.
*/
-- default is '+00:00'
select property_value from database_properties where property_name='DBTIMEZONE';

-- The following example changes the time zone to UTC plus three hours.
EXEC rdsadmin.rdsadmin_util.alter_db_time_zone(p_new_tz => '+8:00');
-- The following example changes the time zone to the Africa/Algiers time zone.
EXEC rdsadmin.rdsadmin_util.alter_db_time_zone(p_new_tz => 'Asia/Singapore');

-- reboot your DB instance for the change to take effect
select property_value from database_properties where property_name='DBTIMEZONE';

-- these values take from time zone of the operating system on which the database server resides
select systimestamp from dual;
select sysdate from dual;

-- these values take from session time zone information, can be set/verifed using below 2 SQL
-- alter session set time_zone='+4:00';
-- select sessiontimezone from dual
select current_timestamp from dual;
select current_date from dual;

-- DBTIMEZONE is the (internal) time zone of TIMESTAMP WITH LOCAL TIME values
-- below values take effect from it
select systimestamp at time zone dbtimezone from dual;


-- Generating an AWR report
-- get snap_id
select snap_id, startup_time, begin_interval_time,end_interval_time 
from dba_hist_snapshot order by snap_id desc;
-- genertate the AWR report
exec rdsadmin.rdsadmin_diagnostic_util.awr_report(7,8,'TEXT');
exec rdsadmin.rdsadmin_diagnostic_util.awr_report(7,8,'HTML');
-- create and store AWR in non-default directory
exec rdsadmin.rdsadmin_diagnostic_util.awr_report(63,65,'HTML','AWR_RPT_DUMP');

-- Download the AWR reports using console (Logs & events -> filter by awrrpt)

-- Generating an ADDM report
exec rdsadmin.rdsadmin_diagnostic_util.addm_report(2,3);
-- Download the ADDM reports using console (Logs & events -> filter by addmrpt)

-- Generating an ASH report

BEGIN
    rdsadmin.rdsadmin_diagnostic_util.ash_report(
        begin_time     =>     SYSDATE-14/1440,
        end_time       =>     SYSDATE,
        report_type    =>     'TEXT');
END;
/

BEGIN
    rdsadmin.rdsadmin_diagnostic_util.ash_report(
        begin_time     =>    TO_DATE('2021-05-04 03:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        end_time       =>    TO_DATE('2021-05-04 03:45:00', 'YYYY-MM-DD HH24:MI:SS'),
        report_type    =>    'html',
        dump_directory =>    'BDUMP');
END;
/

-- Download the ADDM reports using console (Logs & events -> filter by ashrpt)


-- Enabling auditing for the SYS.AUD$ table (12.1+)
select * from dba_obj_audit_opts where owner='SYS' and object_name='AUD$';
-- default is by access, "p_by_access => false" switch to by session
exec rdsadmin.rdsadmin_master_util.audit_all_sys_aud_table;
exec rdsadmin.rdsadmin_master_util.audit_all_sys_aud_table(p_by_access => true);
-- disable audit
exec rdsadmin.rdsadmin_master_util.noaudit_all_sys_aud_table;

-- Cleaning up interrupted online index builds
declare
  is_clean boolean;
begin
  is_clean := rdsadmin.rdsadmin_dbms_repair.online_index_clean(
    object_id     => 1234567890, -- the object ID for the index
    wait_for_lock => rdsadmin.rdsadmin_dbms_repair.lock_nowait
  );
end;
 /                  
    

-- Skipping corrupt blocks
   
- rdsadmin.rdsadmin_dbms_repair.create_repair_table
- rdsadmin.rdsadmin_dbms_repair.create_orphan_keys_table
- rdsadmin.rdsadmin_dbms_repair.drop_repair_table
- rdsadmin.rdsadmin_dbms_repair.drop_orphan_keys_table
- rdsadmin.rdsadmin_dbms_repair.purge_repair_table
- rdsadmin.rdsadmin_dbms_repair.purge_orphan_keys_table
- rdsadmin.rdsadmin_dbms_repair.check_object
- rdsadmin.rdsadmin_dbms_repair.dump_orphan_keys
- rdsadmin.rdsadmin_dbms_repair.fix_corrupt_blocks
- rdsadmin.rdsadmin_dbms_repair.rebuild_freelists
- rdsadmin.rdsadmin_dbms_repair.segment_fix_status
- rdsadmin.rdsadmin_dbms_repair.skip_corrupt_blocks  

-- Resizing the temporary tablespace in a read replica
exec rdsadmin.rdsadmin_util.resize_temp_tablespace('TEMP','4G');
exec rdsadmin.rdsadmin_util.resize_temp_tablespace('TEMP','4096000000');
-- based on tempfile ID
exec rdsadmin.rdsadmin_util.resize_tempfile(1,'2M');

-- Purging the recycle bin
-- purge for current user
purge recyclebin;
-- purge entire recyclebin
exec rdsadmin.rdsadmin_util.purge_dba_recyclebin;
