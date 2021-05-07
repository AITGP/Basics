/*4.8 Enabling Network Services in Oracle Database 11g or Later

4.8.2 Granting Connect Privileges Prior to Oracle Database 12c
================================================
The following example demonstrates how to grant connect privileges to any host for the APEX_050100 database user.
This example assumes you connected to the database where Oracle Application Express is installed as SYS specifying the SYSDBA role.
=======================================================================================================
*/
DECLARE
  ACL_PATH  VARCHAR2(4000);
BEGIN
  -- Look for the ACL currently assigned to '*' and give APEX_050100
  -- the "connect" privilege if APEX_050100 does not have the privilege yet.
 
  SELECT ACL INTO ACL_PATH FROM DBA_NETWORK_ACLS
   WHERE HOST = '*' AND LOWER_PORT IS NULL AND UPPER_PORT IS NULL;
 
  IF DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE(ACL_PATH, 'APEX_050100',
     'connect') IS NULL THEN
      DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(ACL_PATH,
     'APEX_050100', TRUE, 'connect');
  END IF;
 
EXCEPTION
  -- When no ACL has been assigned to '*'.
  WHEN NO_DATA_FOUND THEN
  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL('power_users.xml',
    'ACL that lets power users to connect to everywhere',
    'APEX_050100', TRUE, 'connect');
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL('power_users.xml','*');
END;
/
COMMIT;
/*
===============================================================================
The following example demonstrates how to provide less privileged access to local network resources. 
This example enables access to servers on the local host only, such as email and report servers.
===============================================================================
*/
DECLARE
  ACL_PATH  VARCHAR2(4000);
BEGIN
  -- Look for the ACL currently assigned to 'localhost' and give APEX_050100
  -- the "connect" privilege if APEX_050100 does not have the privilege yet.
  SELECT ACL INTO ACL_PATH FROM DBA_NETWORK_ACLS
   WHERE HOST = 'localhost' AND LOWER_PORT IS NULL AND UPPER_PORT IS NULL;
   
  IF DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE(ACL_PATH, 'APEX_050100',
     'connect') IS NULL THEN
      DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(ACL_PATH,
     'APEX_050100', TRUE, 'connect');
  END IF;
  
EXCEPTION
  -- When no ACL has been assigned to 'localhost'.
  WHEN NO_DATA_FOUND THEN
  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL('local-access-users.xml',
    'ACL that lets users to connect to localhost',
    'APEX_050100', TRUE, 'connect');
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL('local-access-users.xml','localhost');
END;
/
COMMIT;

  /*
============================================ 
4.8.3 Granting Connect Privileges in Oracle Database 12c
============================================
Procedures CREATE_ACL, ASSIGN_ACL, ADD_PRIVILEGE and CHECK_PRIVILEGE in DBMS_NETWORK_ACL_ADMIN are deprecated in Oracle Database 12c.
Oracle recommends using APPEND_HOST_ACE instead. The following example demonstrates how to grant connect privileges to any host for the APEX_050100 database user.
This example assumes you connected to the database where Oracle Application Express is installed as SYS specifying the SYSDBA role.
========================================================================================================
*/
BEGIN
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
        host => '*',
        ace => xs$ace_type(privilege_list => xs$name_list('connect'),
                           principal_name => 'APEX_050100',
                           principal_type => xs_acl.ptype_db));
END;
/
/*
===============================================================================
The following example demonstrates how to provide less privileged access to local network resources. 
This example enables access to servers on the local host only, such as email and report servers.
===============================================================================
*/
BEGIN
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
        host => 'localhost',
        ace => xs$ace_type(privilege_list => xs$name_list('connect'),
                           principal_name => 'APEX_050100',
                           principal_type => xs_acl.ptype_db));
END;
/

  /*
=================================
4.8.4 Troubleshooting an Invalid ACL Error
=================================
If you receive an ORA-44416: Invalid ACL error after running the previous script, use the following query to identify the invalid ACL:
REM Show the dangling references to dropped users in the ACL that is assigned
REM to '*'.
====================================================================================================
*/
SELECT ACL, PRINCIPAL
  FROM DBA_NETWORK_ACLS NACL, XDS_ACE ACE
 WHERE HOST = '*' AND LOWER_PORT IS NULL AND UPPER_PORT IS NULL AND
       NACL.ACLID = ACE.ACLID AND
       NOT EXISTS (SELECT NULL FROM ALL_USERS WHERE USERNAME = PRINCIPAL);
/*
==================================
Next, run the following code to fix the ACL:
==================================
*/
DECLARE
  ACL_ID   RAW(16);
  CNT      NUMBER;
BEGIN
  -- Look for the object ID of the ACL currently assigned to '*'
  SELECT ACLID INTO ACL_ID FROM DBA_NETWORK_ACLS
   WHERE HOST = '*' AND LOWER_PORT IS NULL AND UPPER_PORT IS NULL;

  -- If just some users referenced in the ACL are invalid, remove just those
  -- users in the ACL. Otherwise, drop the ACL completely.
  SELECT COUNT(PRINCIPAL) INTO CNT FROM XDS_ACE
   WHERE ACLID = ACL_ID AND
         EXISTS (SELECT NULL FROM ALL_USERS WHERE USERNAME = PRINCIPAL);

  IF (CNT > 0) THEN

    FOR R IN (SELECT PRINCIPAL FROM XDS_ACE
               WHERE ACLID = ACL_ID AND
                     NOT EXISTS (SELECT NULL FROM ALL_USERS
                                  WHERE USERNAME = PRINCIPAL)) LOOP
      UPDATE XDB.XDB$ACL
         SET OBJECT_VALUE =
               DELETEXML(OBJECT_VALUE,
                         '/ACL/ACE[PRINCIPAL="'||R.PRINCIPAL||'"]')
       WHERE OBJECT_ID = ACL_ID;
    END LOOP;

  ELSE
    DELETE FROM XDB.XDB$ACL WHERE OBJECT_ID = ACL_ID;
  END IF;

END;
/

REM commit the changes.

COMMIT;
/*
========================================================================================
Once the ACL has been fixed, you must run the first script in this section to apply the ACL to the APEX_050100 user. 
See "Granting Connect Privileges Prior to Oracle Database 12c."
========================================================================================
*/