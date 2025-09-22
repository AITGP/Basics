---VARIAS REGIONES
---COMMITS ---INTERACTIVE REGION
select COMMIT_ID,
       AUTHOR,
        MESSAGE,
       COMMIT_DATE,
 '' AS LINK
  from GIT_COMMITS
  WHERE trunc(TO_DATE(COMMIT_DATE,'DD-MM-YYYY HH:MIAM')) BETWEEN TO_DATE(:P47_DESDE,'DD/MM/YYYY') AND TO_DATE(:P47_HASTA,'DD/MM/YYYY') OR (:P47_DESDE IS NULL AND :P47_HASTA IS NULL)
 order by COMMIT_DATE DESC;

--FILES --INTEREACTIVE REGION
select COMMIT_ID,
       decode(STATUS,'D','ELIMINAR ARCHIVO','M','MODIFICAR ARCHIVO','A','AGREGAR ARCHIVO','OTROS') STATUS,
       FILENAME, '' VISUALIZAR
  from GIT_FILES
 where commit_id = :P47_COMMIT;

--DIFFS --PLSQL DYNAMIC CONTENT
DECLARE
    v_diff_html CLOB;
BEGIN
    FOR rec IN (SELECT diff_text FROM git_diffs
        where commit_id = :P47_COMMIT AND FILENAME = :P47_FILE
                ORDER BY rowid) LOOP
        v_diff_html := clob_to_diff_html(rec.diff_text);
        -- imprimimos el HTML directamente
        htp.prn(v_diff_html);
    END LOOP;
END;
