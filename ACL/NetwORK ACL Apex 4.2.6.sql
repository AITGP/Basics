/*
Enable Network Services in Oracle Database 11g
==========================================
-- Sending outbound mail in Oracle Application Express.
-- Users can call methods from the APEX_MAIL package, but issues arise when sending outbound email.
-- Using Web services in Oracle Application Express.
-- PDF report printing.
This example assumes you connected to the database where Oracle Application Express is installed as SYS specifying the SYSDBA role.
=======================================================================================================
1. Granting Connect Privileges
========================
*/
DECLARE
  ACL_PATH  VARCHAR2(4000);
BEGIN
  -- Look for the ACL currently assigned to '*' and give APEX_040200
  -- the "connect" privilege if APEX_040200 does not have the privilege yet.
 
  SELECT ACL INTO ACL_PATH FROM DBA_NETWORK_ACLS
   WHERE HOST = '*' AND LOWER_PORT IS NULL AND UPPER_PORT IS NULL;
 
  IF DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE(ACL_PATH, 'APEX_040200',
     'connect') IS NULL THEN
      DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(ACL_PATH,
     'APEX_040200', TRUE, 'connect');
  END IF;
 
EXCEPTION
  -- When no ACL has been assigned to '*'.
  WHEN NO_DATA_FOUND THEN
  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL('power_users.xml',
    'ACL that lets power users to connect to everywhere',
    'APEX_040200', TRUE, 'connect');
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL('power_users.xml','*');
END;
/
COMMIT;
/*
========================================
EJEMPLO DE CONNECT PRIVILEGES ---> LOCALHOST
========================================
The following example demonstrates how to provide less privileged access to local network resources.
This example is used to enable access to servers on the local host only, such as email and report servers.
================================================================================
*/
DECLARE
  ACL_PATH  VARCHAR2(4000);
BEGIN
  -- Look for the ACL currently assigned to 'localhost' and give APEX_040200
  -- the "connect" privilege if APEX_040200 does not have the privilege yet.
  SELECT ACL INTO ACL_PATH FROM DBA_NETWORK_ACLS
   WHERE HOST = 'localhost' AND LOWER_PORT IS NULL AND UPPER_PORT IS NULL;
   
  IF DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE(ACL_PATH, 'APEX_040200',
     'connect') IS NULL THEN
      DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(ACL_PATH,
     'APEX_040200', TRUE, 'connect');
  END IF;
  
EXCEPTION
  -- When no ACL has been assigned to 'localhost'.
  WHEN NO_DATA_FOUND THEN
  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL('local-access-users.xml',
    'ACL that lets users to connect to localhost',
    'APEX_040200', TRUE, 'connect');
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL('local-access-users.xml','localhost');
END;
/
COMMIT;

/*
=================================
Troubleshooting an Invalid ACL Error
=================================
If you receive an ORA-44416: Invalid ACL error after running the previous script, use the following query to identify the invalid ACL:
REM Show the dangling references to dropped users in the ACL that is assigned
REM to '*'.
=====================================================================================================
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

--REM commit the changes.

COMMIT;

--Once the ACL has been fixed, you must run the first script in this section to apply the ACL to the APEX_040200 user. See "Granting Connect Privileges".








