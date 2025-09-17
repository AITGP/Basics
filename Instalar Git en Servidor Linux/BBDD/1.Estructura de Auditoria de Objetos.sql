drop TRIGGER bmscore.trg_log_obj_changes;
drop table  bmsaudi.obj_changes_log;

CREATE TABLE bmsaudi.obj_changes_log (
   obj_owner      VARCHAR2(128),
   obj_name       VARCHAR2(128),
   obj_type       VARCHAR2(30),
   ddl_event      VARCHAR2(30),
   executed_by    VARCHAR2(30),
   host_machine   VARCHAR2(64),
   ip_address     VARCHAR2(64),
   os_user        VARCHAR2(64),
   module         VARCHAR2(64),
   sql_text       CLOB,
   modified_date  DATE
);

grant select, insert on bmsaudi.obj_changes_log to bmscore;


CREATE OR REPLACE TRIGGER bmscore.trg_log_obj_changes
AFTER CREATE OR ALTER OR DROP ON SCHEMA
DECLARE
    sql_text   DBMS_STANDARD.ora_name_list_t;
    n   PLS_INTEGER;
    v_stmt clob;
BEGIN
    n := ora_sql_txt(sql_text);
 
FOR i IN 1..n LOOP
    v_stmt := v_stmt || sql_text(i);
END LOOP;

   INSERT INTO bmsaudi.obj_changes_log (
      obj_owner,
      obj_name,
      obj_type,
      ddl_event,
      executed_by,
      host_machine,
      ip_address,
      os_user,
      module,
      sql_text,
      modified_date
   )
   VALUES (
      ora_dict_obj_owner,
      ora_dict_obj_name,
      ora_dict_obj_type,
      ora_sysevent,
      sys_context('USERENV','SESSION_USER'),
      sys_context('USERENV','HOST'),
      sys_context('USERENV','IP_ADDRESS'),
      sys_context('USERENV','OS_USER'),
      sys_context('USERENV','MODULE'),
      v_stmt,--v_sql,
      SYSDATE
   );
END;
/
