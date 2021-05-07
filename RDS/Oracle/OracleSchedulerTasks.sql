-- Setting the time zone for Oracle Scheduler jobs
select value from dba_scheduler_global_attribute where attribute_name='DEFAULT_TIMEZONE';


begin
  dbms_scheduler.set_scheduler_attribute(
    attribute => 'default_timezone',
    value => 'Asia/Singapore'
  );
end;
/

-- Disable/Enable SYS-owned Oracle Scheduler jobs
-- The following example disables/enables the SYS.CLEANUP_ONLINE_IND_BUILD Oracle Scheduler job
begin
   rdsadmin.rdsadmin_dbms_scheduler.disable('SYS.CLEANUP_ONLINE_IND_BUILD');
end;
/           

begin
   rdsadmin.rdsadmin_dbms_scheduler.enable('SYS.CLEANUP_ONLINE_IND_BUILD');
end;
/

-- Modifying the repeat interval for jobs of CALENDAR type
begin
     rdsadmin.rdsadmin_dbms_scheduler.set_attribute(
          name      => 'SYS.CLEANUP_ONLINE_IND_BUILD', 
          attribute => 'repeat_interval', 
          value     => 'freq=daily;byday=FRI,SAT;byhour=20;byminute=0;bysecond=0');
end;
/

-- Modifying the repeat interval for jobs of NAMED type
begin
     dbms_scheduler.create_schedule (
          schedule_name   => 'rds_master_user.new_schedule',
          start_date      => SYSTIMESTAMP,
          repeat_interval => 'freq=daily;byday=MON,TUE,WED,THU,FRI;byhour=0;byminute=0;bysecond=0',
          end_date        => NULL,
          comments        => 'Repeats daily forever');
end;
/
 
begin
     rdsadmin.rdsadmin_dbms_scheduler.set_attribute (
          name      => 'SYS.BSLN_MAINTAIN_STATS_JOB', 
          attribute => 'schedule_name',
          value     => 'rds_master_user.new_schedule');
end;
/