CREATE OR REPLACE DIRECTORY EXPORT_SQL AS '/backup/git_respaldo/repositorio_sql'; -- AUDITORIA DE OBJETOS
GRANT READ, WRITE ON DIRECTORY EXPORT_SQL TO TU_USUARIO;    --USUARIO DE AUDITORIA

/*

CREATE OR REPLACE DIRECTORY 
BMS_EXP_SQL_PKS AS 
'/backup/git_respaldo/repositorio_sql/BMSCORE/PAQUETES/';
CREATE OR REPLACE DIRECTORY 
BMS_EXP_SQL_PKB AS 
'/backup/git_respaldo/repositorio_sql/BMSCORE/PAQUETES_BODY/';
CREATE OR REPLACE DIRECTORY 
BMS_EXP_SQL_PRD AS 
'/backup/git_respaldo/repositorio_sql/BMSCORE/PROCEDURES/';
CREATE OR REPLACE DIRECTORY 
BMS_EXP_SQL_FUN AS 
'/backup/git_respaldo/repositorio_sql/BMSCORE/FUNCTIONS/';
CREATE OR REPLACE DIRECTORY 
BMS_EXP_SQL_VIE AS 
'/backup/git_respaldo/repositorio_sql/BMSCORE/VIEWS/';
CREATE OR REPLACE DIRECTORY 
BMS_EXP_SQL_TRG AS 
'/backup/git_respaldo/repositorio_sql/BMSCORE/TRIGGERS/';
CREATE OR REPLACE DIRECTORY 
BMS_EXP_SQL_OTR AS 
'/backup/git_respaldo/repositorio_sql/BMSCORE/OTROS/';

GRANT READ, WRITE ON DIRECTORY BMS_EXP_SQL_PKS TO BMSAUDI;
GRANT READ, WRITE ON DIRECTORY BMS_EXP_SQL_PKB TO BMSAUDI;
GRANT READ, WRITE ON DIRECTORY BMS_EXP_SQL_PRD TO BMSAUDI;
GRANT READ, WRITE ON DIRECTORY BMS_EXP_SQL_FUN TO BMSAUDI;
GRANT READ, WRITE ON DIRECTORY BMS_EXP_SQL_VIE TO BMSAUDI;
GRANT READ, WRITE ON DIRECTORY BMS_EXP_SQL_TRG TO BMSAUDI;
GRANT READ, WRITE ON DIRECTORY BMS_EXP_SQL_OTR TO BMSAUDI;


*/


GRANT SELECT ON  sys.all_source TO TU_USUARIO;
GRANT SELECT ON SYS.DBA_SOURCE TO TU_USUARIO;

CREATE OR REPLACE PROCEDURE BMSAUDI.BMS_OBJETOS_BBD_SQL AS
    CURSOR c_objetos IS
        SELECT owner, name, type
        FROM all_source
        WHERE owner IN ( 'TU ESQUEMA')
        AND TYPE NOT IN ('TYPE','JAVA SOURCE') 
        GROUP BY owner, name, type
        ORDER BY type, name;

    l_file   UTL_FILE.file_type;
    l_line   VARCHAR2(32767);
    l_dir    VARCHAR2(200);
    l_fname  VARCHAR2(200);
BEGIN
    FOR r IN c_objetos LOOP
        -- Elegir carpeta según el tipo
        l_dir :=
            CASE r.type
                WHEN 'PACKAGE'        THEN 'PAQUETES'
                WHEN 'PACKAGE BODY'   THEN 'PAQUETES_BODY'
                WHEN 'PROCEDURE'      THEN 'PROCEDURES'
                WHEN 'FUNCTION'       THEN 'FUNCTIONS'
                WHEN 'VIEW'           THEN 'VIEWS'
                WHEN 'TRIGGER'        THEN 'TRIGGERS'
                ELSE 'OTROS'
            END;

        -- Nombre de archivo
        l_fname := r.name || '.sql';

        -- Abrir archivo en la subcarpeta (ejemplo: /opt/oracle/repositorio_sql/PAQUETES/NOMBRE.sql)
        l_file := UTL_FILE.fopen('EXPORT_SQL', l_dir || '/' || l_fname, 'w', 32767);

        -- Escribir encabezado
        UTL_FILE.put_line(l_file, '-- Export de ' || r.type || ' ' || r.name);
        UTL_FILE.put_line(l_file, 'CREATE OR REPLACE ');

        -- Escribir el contenido del objeto
        FOR src IN (
            SELECT text
            FROM all_source
            WHERE owner = r.owner
              AND name  = r.name
              AND type  = r.type
            ORDER BY line
        ) LOOP
            UTL_FILE.put_line(l_file, src.text);
        END LOOP;

        -- Cerrar archivo
        UTL_FILE.fclose(l_file);
        COMMIT;
    END LOOP;
END;
/
