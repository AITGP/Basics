CREATE OR REPLACE EDITIONABLE FUNCTION clob_to_diff_html(p_diff CLOB) RETURN CLOB IS
    v_html   CLOB := '<div class="diff-container">';
    v_line   VARCHAR2(4000);
    v_pos    PLS_INTEGER := 1;
    v_len    PLS_INTEGER := DBMS_LOB.GETLENGTH(p_diff);
    v_chunk  VARCHAR2(4000);
    v_newline_pos PLS_INTEGER;
BEGIN
    WHILE v_pos <= v_len LOOP
        -- obtener línea hasta 4000 caracteres
        v_chunk := DBMS_LOB.SUBSTR(p_diff, 4000, v_pos);

        -- buscar fin de línea
        v_newline_pos := INSTR(v_chunk, CHR(10));
        IF v_newline_pos > 0 THEN
            v_line := SUBSTR(v_chunk, 1, v_newline_pos - 1);
            v_pos := v_pos + v_newline_pos;
        ELSE
            v_line := v_chunk;
            v_pos := v_pos + LENGTH(v_chunk);
        END IF;

        -- colorear según el primer carácter
        IF v_line LIKE '+%' THEN
            v_html := v_html || '<span class="added">' || v_line || '</span><br>';
        ELSIF v_line LIKE '-%' THEN
            v_html := v_html || '<span class="removed">' || v_line || '</span><br>';
        ELSE
            v_html := v_html || '<span class="context">' || v_line || '</span><br>';
        END IF;
    END LOOP;

    v_html := v_html || '</div>';
    RETURN v_html;
END;
/

