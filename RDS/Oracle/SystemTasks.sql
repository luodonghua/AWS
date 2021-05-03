-- Query session status
select sid, serial#, status, username, machine, program, sql_id from v$session where username is not null;

-- Disconnecting a session
begin
	rdsadmin.rdsadmin_util.disconnect(
		sid			=> 100,
		serial		=> 12222,
		method		=> 'IMMEDIATE'	-- Valid values are 'IMMEDIATE' or 'POST_TRANSACTION'
		);
end;
/


-- Terminating a session
begin
	rdsadmin.rdsadmin_util.kill(
		sid 		=> 100,
		serial		=> 12222,
		method 		=> 'IMMEDIATE' -- Use "PROCESS" to terminate process only if "IMMEDIATE" failed
		);
end;
/

-- Canceling a SQL statement in a session (18c+)
-- On the backend running "alter system cancel sql" statement with/without sql_id
begin
	rdsadmin.rdsadmin_util.cancel(
		sid 		=> 100,
		serial		=> 12222,
		sql_id		=> '0w506y3wj53wf'	-- SQL_ID can be null
		);
end;
/


-- Enabling and disabling restricted sessions

/* Verify that the database is currently unrestricted/allowed. */
SELECT LOGINS FROM V$INSTANCE;

/* Enable restricted sessions 
   LOGIN allowed only for grantee with "RESTRICTED SESSION" privilege
   DBA has been granted with this privilege by default
*/
exec rdsadmin.rdsadmin_util.restricted_session(p_enable => true);
 
/* Verify that the database is now restricted. */
SELECT LOGINS FROM V$INSTANCE;

/* Disable restricted sessions */
exec rdsadmin.rdsadmin_util.restricted_session(p_enable => false);
 

-- Flushing the shared pool
exec rdsadmin.rdsadmin_util.flush_shared_pool;

-- Flushing the buffer cache
exec rdsadmin.rdsadmin_util.flush_buffer_cache;

-- Grant/Revole SELECT or EXECUTE privileges to SYS objects
-- procedure grants only privileges that the master user has already been granted through a role or direct grant
begin
    rdsadmin.rdsadmin_util.grant_sys_object(
        p_obj_name     		=> 'V_$SESSION',
        p_grantee      		=> 'USER1',
        p_privilege    		=> 'SELECT',
        p_grant_option 		=> true	-- default is false, valid from 12.1.0.2+
      	);
end;
/
begin
    rdsadmin.rdsadmin_util.revoke_sys_object(
        p_obj_name  		=> 'V_$SESSION',
        p_revokee   		=> 'USER1',
        p_privilege 		=> 'SELECT'
      	);
end;
/

-- Creating custom functions to verify passwords
begin
    rdsadmin.rdsadmin_password_verify.create_verify_function(
        p_verify_function_name => 'CUSTOM_PASSWORD_FUNCTION', 
        p_min_length           => 12, 
        p_min_uppercase        => 2, 
        p_min_digits           => 1, 
        p_min_special          => 1,
        p_disallow_at_sign     => true
        );
end;
/

/*
SELECT TEXT FROM DBA_SOURCE WHERE OWNER = 'SYS' AND NAME = 'CUSTOM_PASSWORD_FUNCTION' ORDER BY LINE;
ALTER PROFILE DEFAULT LIMIT PASSWORD_VERIFY_FUNCTION CUSTOM_PASSWORD_FUNCTION;
SELECT * FROM DBA_PROFILES WHERE RESOURCE_NAME = 'PASSWORD' AND LIMIT = 'CUSTOM_PASSWORD_FUNCTION';
*/

-- The create_passthrough_verify_fcn procedure
-- Passthrough means the verification passed to RDSADMIN$LIMITED.CUSTOM_PASSWORD_FUNCTION
-- after bypass specific users managed by RDS or with RDS_MASTER_ROLE (admin/sys)

begin
    rdsadmin.rdsadmin_password_verify.create_passthrough_verify_fcn(
        p_verify_function_name => 'CUSTOM_PASSWORD_FUNCTION', 
        p_target_owner         => 'TEST_USER',
        p_target_function_name => 'PASSWORD_LOGIC_EXTRA_STRONG');
end;
/

-- Listing allowed system diagnostic events
SET SERVEROUTPUT ON
EXEC rdsadmin.rdsadmin_util.list_allowed_system_events;

-- Set/Unset system diagnostic events
-- Setting system event 942 with: alter system set events '942 errorstack (3)'
SET SERVEROUTPUT ON
EXEC rdsadmin.rdsadmin_util.set_system_event(942,3);
-- Setting system event 10442 with: alter system set events '10442 level 10'
EXEC rdsadmin.rdsadmin_util.set_system_event(10442,10);
-- Unsetting system event 942 with: alter system set events '942 off'
EXEC rdsadmin.rdsadmin_util.unset_system_event(942);
-- Unsetting system event 10442 with: alter system set events '10442 off'
EXEC rdsadmin.rdsadmin_util.unset_system_event(10442);


-- Listing system diagnostic events that are set
SET SERVEROUTPUT ON
EXEC rdsadmin.rdsadmin_util.list_set_system_events;
