-- Listing incidents

var task_id VARCHAR2(80);
exec :task_id := rdsadmin.rdsadmin_adrci_util.list_adrci_incidents;
select :task_id from DUAL;
select * from TABLE(rdsadmin.rds_file_util.read_text_file('BDUMP', 'dbtask-'||:task_id||'.log'));

-- List specific incident (53523 as example)
var task_id VARCHAR2(80);
exec :task_id := rdsadmin.rdsadmin_adrci_util.list_adrci_incidents(incident_id=>53523);
select :task_id from DUAL;
select * from TABLE(rdsadmin.rds_file_util.read_text_file('BDUMP', 'dbtask-'||:task_id||'.log'));

-- List problems
var task_id VARCHAR2(80);
exec :task_id := rdsadmin.rdsadmin_adrci_util.list_adrci_problems;
select :task_id from DUAL;
select * from TABLE(rdsadmin.rds_file_util.read_text_file('BDUMP', 'dbtask-'||:task_id||'.log'));

-- List specific problem (3 as example)
var task_id VARCHAR2(80);
exec :task_id := rdsadmin.rdsadmin_adrci_util.list_adrci_problems(problem_id=>3);
select :task_id from DUAL;
select * from TABLE(rdsadmin.rds_file_util.read_text_file('BDUMP', 'dbtask-'||:task_id||'.log'));


-- Creating incident packages
var task_id VARCHAR2(80);
exec :task_id := rdsadmin.rdsadmin_adrci_util.create_adrci_package(incident_id=>53523);
select :task_id from DUAL;
select * from TABLE(rdsadmin.rds_file_util.read_text_file('BDUMP', 'dbtask-'||:task_id||'.log'));
exec :task_id := rdsadmin.rdsadmin_adrci_util.create_adrci_package(problem_id=>3);
select * from TABLE(rdsadmin.rds_file_util.read_text_file('BDUMP', 'dbtask-'||:task_id||'.log'));

-- Showing trace files
var task_id VARCHAR2(80);
exec :task_id := rdsadmin.rdsadmin_adrci_util.show_adrci_tracefile;
select :task_id from DUAL;
select * from TABLE(rdsadmin.rds_file_util.read_text_file('BDUMP', 'dbtask-'||:task_id||'.log')) where text like '%/alert_%';
exec :task_id := rdsadmin.rdsadmin_adrci_util.show_adrci_tracefile('diag/rdbms/orcl_a/ORCL/trace/alert_ORCL.log');
SELECT * FROM TABLE(rdsadmin.rds_file_util.read_text_file('BDUMP', 'dbtask-'||:task_id||'.log')) WHERE ROWNUM <= 10;
