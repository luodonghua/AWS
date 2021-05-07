
/*
-- Common parameters for RMAN procedures
p_directory_name:         The name of the directory to contain the backup files.
p_label:                  A unique string that is included in the backup file names.
p_compress:               Specify TRUE to enable BASIC backup compression. (No Advanced Compression Option required)
p_include_archive_logs:   Specify TRUE to include archived redo logs in the backup. (default is False)
p_include_controlfile:    Specify TRUE to include the control file in the backup. (default is False)
p_optimize:               Specify TRUE to enable backup optimization, if archived redo logs are included, to reduce backup size. (default is True)
p_parallel:               Number of channels. (default is 1)
p_rman_to_dbms_output     When TRUE, the RMAN output is sent to the DBMS_OUTPUT plus a file in the BDUMP directory. (Default is False)
p_section_size_mb         The section size in megabytes (MB).
p_validation_type         Specify 'PHYSICAL+LOGICAL' to check for logical inconsistencies in addition to physical corruption. (Default is PHYSICAL)
*/

/* 
In the backend, these procedure triggers RMAN commands similar as below:
RUN_RMAN_CMD: /rdsdbbin/oracle/bin/rman TARGET / 
			LOG /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/rds-rman-validate-DATAFILE-2021-05-07.01-18-56.035585000.txt 
			@/rdsdbdata/tmp/rds-rman-validate-DATAFILE-2021-05-07.01-18-56.035585000.input 
To check the logfiles for these validate rman commands, use below query: 
*/
select * from table(rdsadmin.rds_file_util.listdir('BDUMP')) where filename like '%rds-rman-validate%';
select * from table(rdsadmin.rds_file_util.listdir('BDUMP')) order by mtime desc;
select text from table(rdsadmin.rds_file_util.read_text_file('BDUMP','rds-rman-validate-DATAFILE-2021-05-07.01-18-56.035585000.txt'));


-- Validating DB instance files
--  Validates the DB instance using the default values for the parameters.
exec rdsadmin.rdsadmin_rman_util.validate_database;
-- Validate dataabase with customized parameters 
set serveroutput on
begin
    rdsadmin.rdsadmin_rman_util.validate_database(
        p_validation_type     => 'PHYSICAL+LOGICAL', 
        p_parallel            => 4,  
        p_section_size_mb     => 10,
        p_rman_to_dbms_output => TRUE);
end;
/

-- Validating a tablespace
set serveroutput on
begin
    rdsadmin.rdsadmin_rman_util.validate_tablespace(
        p_validation_type     => 'PHYSICAL+LOGICAL', 
        p_parallel            => 4,  
        p_section_size_mb     => 10,
        p_rman_to_dbms_output => TRUE,
        p_tablespace_name     => 'USERS');
end;
/

-- Validating a control file
set serveroutput on
begin
    rdsadmin.rdsadmin_rman_util.validate_current_controlfile(
        p_validation_type     => 'PHYSICAL+LOGICAL', 
        p_rman_to_dbms_output => TRUE);
end;
/

-- Validating a SPFILE
set serveroutput on
begin
    rdsadmin.rdsadmin_rman_util.validate_spfile(
        p_validation_type     => 'PHYSICAL+LOGICAL', 
        p_rman_to_dbms_output => TRUE);
end;
/

-- Validating a data file
/* get the file_id or file_name from below query, both can be used as p_datafile
-- select file_id, file_name from dba_data_files;
-- select file#,name from v$datafile;
*/

set serveroutput on
begin
    rdsadmin.rdsadmin_rman_util.validate_datafile(
        p_validation_type     => 'PHYSICAL+LOGICAL', 
        p_parallel            => 4,  
        p_section_size_mb     => 10,
        p_rman_to_dbms_output => TRUE,
        p_datafile            => '/rdsdbdata/db/ORCL_A/datafile/o1_mf_users_j43s2nl4_.dbf',  
        p_from_block          => NULL,
        p_to_block            => NULL);
end;
/

-- Enabling and disabling block change tracking
select status, filename from v$block_change_tracking;
EXEC rdsadmin.rdsadmin_rman_util.enable_block_change_tracking;
EXEC rdsadmin.rdsadmin_rman_util.disable_block_change_tracking;

-- Crosschecking archived redo logs
-- The following example marks archived redo log records in the control file as expired, but does not delete the records.
begin
    rdsadmin.rdsadmin_rman_util.crosscheck_archivelog(
        p_delete_expired      => FALSE,  
        p_rman_to_dbms_output => FALSE);
end;
/
-- The following example deletes expired archived redo log records from the control file.
begin
    rdsadmin.rdsadmin_rman_util.crosscheck_archivelog(
        p_delete_expired      => TRUE,  
        p_rman_to_dbms_output => FALSE);
end;
/

-- Backing up all archived redo logs
-- ORA-20001: archivelog retention hours must be at least 1, 
-- may be set with rdsadmin.rdsadmin_util.set_configuration('archivelog retention hours', HOURS) followed by a COMMIT.
-- If you include archived redo logs in the backup, set retention to one hour or greater using the 
-- rdsadmin.rdsadmin_util.set_configuration procedure. 
-- Also, call the rdsadmin.rdsadmin_rman_util.crosscheck_archivelog procedure immediately before running the backup. Otherwise, 
-- the backup might fail due to missing archived redo log files that have been deleted by Amazon RDS management procedures.

BEGIN
    rdsadmin.rdsadmin_rman_util.backup_archivelog_all(
        p_owner               => 'SYS', 
        p_directory_name      => 'RMAN',
        p_parallel            => 4,  
        p_rman_to_dbms_output => FALSE);
END;
/
   
-- Backing up an archived redo log from a date range
BEGIN
    rdsadmin.rdsadmin_rman_util.backup_archivelog_date(
        p_owner               => 'SYS', 
        p_directory_name      => 'RMAN',
        p_from_date           => '03/01/2019 00:00:00',
        p_to_date             => '03/02/2019 00:00:00',
        p_parallel            => 4,  
        p_rman_to_dbms_output => FALSE);
END;
/

-- Backing up an archived redo log from an SCN range
BEGIN
    rdsadmin.rdsadmin_rman_util.backup_archivelog_scn(
        p_owner               => 'SYS', 
        p_directory_name      => 'RMAN',
        p_from_scn            => 1533835,
        p_to_scn              => 1892447,
        p_parallel            => 4,  
        p_rman_to_dbms_output => FALSE);
END;
/

-- Backing up an archived redo log from a sequence number range
BEGIN
    rdsadmin.rdsadmin_rman_util.backup_archivelog_sequence(
        p_owner               => 'SYS', 
        p_directory_name      => 'RMAN',
        p_from_sequence       => 122,
        p_to_sequence         => 125,
        p_parallel            => 4,  
        p_rman_to_dbms_output => FALSE);
END;
/ 

-- Performing a full database backup
/*
exec rdsadmin.rdsadmin_util.set_configuration('archivelog retention hours', 1);
commit;
*/
BEGIN
    rdsadmin.rdsadmin_rman_util.backup_database_full(
        p_owner               => 'SYS', 
        p_directory_name      => 'RMAN',
        p_parallel            => 4,  
        p_section_size_mb     => 10,
        p_rman_to_dbms_output => FALSE);
END;
/

-- list RMAN backup files
select * from table(rdsadmin.rds_file_util.listdir('RMAN')) order by mtime desc;
-- Check RMAN Backup logs
select * from table(rdsadmin.rds_file_util.listdir('BDUMP')) order by mtime desc;
select text from table(rdsadmin.rds_file_util.read_text_file('BDUMP','rds-rman-backup-database-2021-05-07.01-37-56.161968000.txt'));
/*  
Following RMAN codes executed for the backup_database_full procedure
RMAN> CONFIGURE CONTROLFILE AUTOBACKUP ON;
2> CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/rdsdbdata/userdirs/01/BACKUP-2021-05-07-01-37-56-%F';
3> CONFIGURE BACKUP OPTIMIZATION ON;
4> RUN {
5>   ALLOCATE CHANNEL d1 DEVICE TYPE DISK  FORMAT '/rdsdbdata/userdirs/01/BACKUP-2021-05-07-01-37-56-backup-%T-%U';
6>   ALLOCATE CHANNEL d2 DEVICE TYPE DISK  FORMAT '/rdsdbdata/userdirs/01/BACKUP-2021-05-07-01-37-56-backup-%T-%U';
7>   ALLOCATE CHANNEL d3 DEVICE TYPE DISK  FORMAT '/rdsdbdata/userdirs/01/BACKUP-2021-05-07-01-37-56-backup-%T-%U';
8>   ALLOCATE CHANNEL d4 DEVICE TYPE DISK  FORMAT '/rdsdbdata/userdirs/01/BACKUP-2021-05-07-01-37-56-backup-%T-%U';
9> CROSSCHECK ARCHIVELOG ALL;
10> BACKUP DATABASE SECTION SIZE 10M;
11>  RELEASE CHANNEL d1;
12>  RELEASE CHANNEL d2;
13>  RELEASE CHANNEL d3;
14>  RELEASE CHANNEL d4;
15> }
*/


-- Performing an incremental database backup
BEGIN
    rdsadmin.rdsadmin_rman_util.backup_database_incremental(
        p_owner               => 'SYS', 
        p_directory_name      => 'MYDIRECTORY',
        p_level               => 1,
        p_parallel            => 4,  
        p_section_size_mb     => 10,
        p_rman_to_dbms_output => FALSE);
END;
/

-- Performing a tablespace backup
BEGIN
    rdsadmin.rdsadmin_rman_util.backup_tablespace(
        p_owner               => 'SYS', 
        p_directory_name      => 'MYDIRECTORY',
        p_tablespace_name     => MYTABLESPACE,
        p_parallel            => 4,  
        p_section_size_mb     => 10,
        p_rman_to_dbms_output => FALSE);
END;
/   


-- Upload to S3 Buckets
SELECT rdsadmin.rdsadmin_s3_tasks.upload_to_s3(
      p_bucket_name    =>  'donghua-bucket1', 
      p_prefix         =>  '', 
      p_s3_prefix      =>  'rman/', 
      p_directory_name =>  'RMAN') AS TASK_ID 
 FROM DUAL;    
-- You can view the result by displaying the task's output file. (1620357578149-52 is the task id)
SELECT text FROM table(rdsadmin.rds_file_util.read_text_file('BDUMP','dbtask-1620357578149-52.log'));         

-- AWS CLI Command to download to another machine and remove from S3
-- aws s3 cp s3://donghua-bucket1/rman . --recursive
-- aws s3 rm s3://donghua-bucket1/rman  --recursive 

-- To remove Backup files in RMAN directory on RDS server
declare
    cursor c1 is select filename from table(rdsadmin.rds_file_util.listdir('RMAN')) where filename like 'BACKUP-%' order by mtime desc;
begin
    for f in c1 loop
        dbms_output.put_line(f.filename);
        utl_file.fremove('RMAN',f.filename);
    end loop;
end;
/

