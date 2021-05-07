-- Creating and dropping directories in the main data storage space

exec rdsadmin.rdsadmin_util.create_directory(p_directory_name => 'RMAN');
select directory_name, directory_path from dba_directories;
/*
Dropping a directory doesn't remove its contents. 
Because the rdsadmin.rdsadmin_util.create_directory procedure can reuse pathnames, 
files in dropped directories can appear in a newly created directory. 
Before you drop a directory, we recommend that you use UTL_FILE.FREMOVE to remove files from the directory. 
*/
exec rdsadmin.rdsadmin_util.drop_directory(p_directory_name => 'RMAN');
drop directory RMAN;

-- Listing files in a DB instance directory
select * from table(rdsadmin.rds_file_util.listdir(p_directory => 'RMAN'));

-- Reading files in a DB instance directory
declare
  fh sys.utl_file.file_type;
begin
  fh := utl_file.fopen(location=>'PRODUCT_DESCRIPTIONS', filename=>'rice.txt', open_mode=>'w');
  utl_file.put(file=>fh, buffer=>'AnyCompany brown rice, 15 lbs');
  utl_file.fclose(file=>fh);
end;
/
select * from table(rdsadmin.rds_file_util.read_text_file(p_directory => 'PRODUCT_DESCRIPTIONS', p_filename  => 'rice.txt'));

-- Accessing Opatch files
SELECT text
FROM   TABLE(rdsadmin.rds_file_util.read_text_file('BDUMP', 'lsinventory-19.0.0.0.ru-2021-01.rur-2021-01.r2.txt'));

-- Setting parameters for advisor tasks
BEGIN 
  rdsadmin.rdsadmin_util.advisor_task_set_parameter(
    p_task_name => 'SYS_AUTO_SPM_EVOLVE_TASK',
    p_parameter => 'ACCEPT_PLANS',
    p_value     => 'FALSE');
END;
/

BEGIN 
  rdsadmin.rdsadmin_util.advisor_task_set_parameter(
    p_task_name => 'AUTO_STATS_ADVISOR_TASK',
    p_parameter => 'EXECUTION_DAYS_TO_EXPIRE',
    p_value     => '10');
END;
/

-- Disable/Enable AUTO_STATS_ADVISOR_TASK
EXEC rdsadmin.rdsadmin_util.advisor_task_drop('AUTO_STATS_ADVISOR_TASK')
EXEC rdsadmin.rdsadmin_util.dbms_stats_init()


