-- Setting force logging
exec rdsadmin.rdsadmin_util.force_logging(p_enable => true);

-- Setting supplemental logging

/* Minimal supplemental logging logs the minimal amount of information needed for 
LogMiner to identify, group, and merge the redo operations associated with DML changes. 
It ensures that LogMiner (and any product building on LogMiner technology) has 
sufficient information to support chained rows and various storage arrangements, 
such as cluster tables and index-organized tables. 
To enable minimal supplemental logging, execute the following SQL statement:
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
*/
-- The following example enables minimal supplemental logging.
begin
    rdsadmin.rdsadmin_util.alter_supplemental_logging(
        p_action => 'ADD');
end;
/

/*
p_action: 'ADD' to add supplemental logging, 'DROP' to drop supplemental logging.
p_type: The type of supplemental logging. Valid values are 'ALL', 'FOREIGN KEY', 'PRIMARY KEY', 'UNIQUE', or PROCEDURAL.

  ALL: when a row is updated, all columns of that row (except for LOBs, LONGS, and ADTs) are placed in the redo log file.

  FOREIGN KEY: place all columns of a row's foreign key in the redo log file if any column belonging to the foreign key is modified

  PRIMARY KEY: database to place all columns of a row's primary key in the redo log file 
  			   whenever a row containing a primary key is updated (even if no value in the primary key has changed).
  			   If a table does not have a primary key, but has one or more non-null unique index key constraints or index keys, 
  			   then one of the unique index keys is chosen for logging as a means of uniquely identifying the row being updated.
  			   If the table has neither a primary key nor a non-null unique index key, then all columns 
  			   except LONG and LOB are supplementally logged; this is equivalent to specifying ALL supplemental logging

  UNIQUE: place all columns of a row's composite unique key or bitmap index in the redo log file 
  		  if any column belonging to the composite unique key or bitmap index is modified	
 
  PROCEDURAL: Procedural supplemental logging must be enabled for rolling upgrades and Oracle GoldenGate to 
              support replication of AQ queue tables, hierarchy-enabled tables, and tables with SDO_TOPO_GEOMETRY or SDO_GEORASTER columns
 */

-- The following example enables supplemental logging for all fixed-length maximum size columns.
begin
    rdsadmin.rdsadmin_util.alter_supplemental_logging(
        p_action => 'ADD',
        p_type   => 'ALL');
end;
/

-- To check currently supplemental logging enabled status
select name,
supplemental_log_data_min,        
supplemental_log_data_all,      -- ALL
supplemental_log_data_fk,       -- FOREIGN KEY
supplemental_log_data_pk,       -- PRIMARY KEY
supplemental_log_data_ui,       -- UNIQUE
supplemental_log_data_pl,       -- PROCEDURAL
supplemental_log_data_sr       -- Indicates whether the database is enabled for subset database replication
from v$database;

select minimal, all_column, foreign_key, primary_key, unique_index, procedural, subset_rep
from dba_supplemental_logging;


-- Switching online log files
exec rdsadmin.rdsadmin_util.switch_logfile;

-- Check current online logs
-- default is 4 online redolog groups, each with 128MB size and 1 file per group.
select group#, sequence#,  bytes/1024/1024 MBbyte from v$log order by group#;
select group#,member from v$logfile order by group#;

-- Adding online redo logs
-- The size of the log file. You can specify the size in kilobytes (K), megabytes (M), or gigabytes (G).
exec rdsadmin.rdsadmin_util.add_logfile(p_size => '100M');

-- Dropping online redo logs
exec rdsadmin.rdsadmin_util.drop_logfile(grp => 3);


-- Retaining archived redo logs
-- The following example shows the log retention time. (default is 0 hour)
set serveroutput on
exec rdsadmin.rdsadmin_util.show_configuration;
-- The following example retains 24 hours of redo logs.
begin
    rdsadmin.rdsadmin_util.set_configuration(
        name  => 'archivelog retention hours',
        value => '24');
end;
/
commit;

-- Accessing transaction logs
-- access your online and archived redo log files for mining with external tools such as 
-- GoldenGate, Attunity, Informatica, and others. 
-- If you want to access your online and archived redo log files, 
-- you must first create directory objects that provide read-only access to the physical file paths.
exec rdsadmin.rdsadmin_master_util.create_archivelog_dir;
exec rdsadmin.rdsadmin_master_util.create_onlinelog_dir;

exec rdsadmin.rdsadmin_master_util.drop_archivelog_dir;
exec rdsadmin.rdsadmin_master_util.drop_onlinelog_dir;
-- The following code grants and revokes the DROP ANY DIRECTORY privilege.
exec rdsadmin.rdsadmin_master_util.grant_drop_any_directory;
exec rdsadmin.rdsadmin_master_util.revoke_drop_any_directory;
