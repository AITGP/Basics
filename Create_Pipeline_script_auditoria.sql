DROP TYPE BMS_AUDITORIA_TAB;
DROP TYPE BMS_AUDITORIA_ROW;

CREATE TYPE BMS_AUDITORIA_ROW AS OBJECT (
  REGISTRO          NUMBER,
  SECUENCIA			NUMBER,
  TABLA			    VARCHAR2(100),
  TIPO			    VARCHAR2(10),
  FECCRE			TIMESTAMP,
  USRCRE			VARCHAR2(100),
  TERCRE			VARCHAR2(100),
  PRIMARY_KEY		VARCHAR2(100),
  PRIMARY_KEY_VAL	VARCHAR2(100),
  COLUMNA			VARCHAR2(100),
  COLUMNA_NOMBRE	VARCHAR2(100),
  DESCRIPCION		VARCHAR2(1000),
  VALOR_ANTERIOR	VARCHAR2(100),
  VALOR_NUEVO		VARCHAR2(100)
);

CREATE TYPE BMS_AUDITORIA_TAB IS TABLE OF BMS_AUDITORIA_ROW;


CREATE OR REPLACE FUNCTION BMS_GET_AUDITORIA_FC(Gv_Tabla IN VARCHAR2) RETURN BMS_AUDITORIA_TAB PIPELINED AS
	CURSOR C_AUDITORIA IS
		SELECT a.USUARIO, a.REGISTRO, a.TABLA, decode(a.TIPO,'I','Insertar','A','Actualizar','E','Eliminar') TIPO, 
			   a.FECCRE, a.USRCRE, a.TERCRE, a.PRIMARY_KEY, b.SECUENCIA, b.DATOS
		FROM ECOOPAUDITORIA.AU_AUDITORIAENC a
		INNER JOIN ECOOPAUDITORIA.AU_AUDITORIADET b ON  a.REGISTRO = b.REGISTRO
		Where a.REGISTRO > 0
		AND b.SECUENCIA > 0
		AND tabla = Gv_Tabla;
	   
	v_pk			varchar2(100);
	v_pkval 		varchar2(100);
	v_cant_cambios	NUMBER;
	v_campo			varchar2(100);
	v_valor_ant		varchar2(100);
	v_valor_new		varchar2(100);
	v_cadena		varchar2(30000);
    v_label         varchar2(100);
    v_descri        varchar2(1000);

	PROCEDURE PD_BUSCA_LABEL (P_Schema varchar2, P_Tabla varchar2, P_Campo varchar2, P_Label OUT varchar2, P_Help_Text OUT varchar2) is
	BEGIN
		SELECT LABEL, HELP_TEXT
            INTO P_Label, P_Help_Text
        FROM APEX_UI_DEFAULTS_COLUMNS
        WHERE TABLE_NAME = P_Tabla
        AND SCHEMA = P_Schema
        AND UPPER(COLUMN_NAME) = UPPER(P_Campo);
    EXCEPTION WHEN NO_DATA_FOUND THEN
        P_Label     := NULL;
        P_Help_Text := NULL;
	END PD_BUSCA_LABEL;
BEGIN
  FOR i IN C_AUDITORIA LOOP
    v_pk 	:= substr(i.PRIMARY_KEY,1,instr(i.PRIMARY_KEY,'=')-1);
    v_pkval := substr(i.PRIMARY_KEY,instr(i.PRIMARY_KEY,'=')+1, instr(i.PRIMARY_KEY,';')-instr(i.PRIMARY_KEY,'=')-1); --se busca por el =
   
    v_cant_cambios	:= round((length(i.DATOS) - length(replace(i.DATOS,'|*',null)))/2,0);--se divide entre 2 porque esta comparando por 2 caracteres
    v_cadena	:= 	i.DATOS;
   		FOR j IN 1..v_cant_cambios LOOP
   			v_campo		:= substr(v_cadena,instr(v_cadena,'|*')+2, instr(v_cadena,'*|')-2-instr(v_cadena,'|*'));
   			v_valor_ant := substr(v_cadena,instr(v_cadena,'|+')+2, instr(v_cadena,'+|')-2-instr(v_cadena,'|+'));
   			v_valor_new := substr(v_cadena,instr(v_cadena,'|-')+2, instr(v_cadena,'-|')-2-instr(v_cadena,'|-'));
            PD_BUSCA_LABEL (i.USUARIO, i.TABLA, v_campo, v_label, v_descri);
            
		    PIPE ROW(BMS_AUDITORIA_ROW(i.REGISTRO, i.SECUENCIA, i.TABLA, i.TIPO, i.FECCRE, i.USRCRE,i.TERCRE,v_pk, v_pkval, v_campo,v_label,v_descri, v_valor_ant,v_valor_new));
									   --REGISTRO,SECUENCIA,TABLA,TIPO,FECCRE,USRCRE,TERCRE,PRIMARY_KEY,PRIMARY_KEY_VAL,COLUMNA,LABEL, DESCRIPCION, VALOR_ANTERIOR,VALOR_NUEVO
			v_cadena := substr(v_cadena,instr(v_cadena,'+|')+1);--corta desde el ultimo actualizado
		END LOOP;
  END LOOP;
  RETURN;
END BMS_GET_AUDITORIA_FC;


--SELECT * FROM BMS_GET_AUDITORIA_FC('AHORROS');
--SELECT * FROM TABLE(BMS_GET_AUDITORIA_FC('AHORROS'));


CREATE OR REPLACE VIEW BMS_AUDITORIA_DETALLADA AS 
	SELECT REGISTRO,SECUENCIA,'PRESTAMOS' AS SERVICIO,TABLA,TIPO,FECCRE,USRCRE,TERCRE,PRIMARY_KEY,PRIMARY_KEY_VAL,COLUMNA,COLUMNA_NOMBRE,DESCRIPCION,VALOR_ANTERIOR,VALOR_NUEVO
	FROM BMS_GET_AUDITORIA_FC('PRESTAMOS')
	UNION ALL
	SELECT REGISTRO,SECUENCIA,'PRE_GARANTIAS_TB' AS SERVICIO,TABLA,TIPO,FECCRE,USRCRE,TERCRE,PRIMARY_KEY,PRIMARY_KEY_VAL,COLUMNA,COLUMNA_NOMBRE,DESCRIPCION,VALOR_ANTERIOR,VALOR_NUEVO
	FROM BMS_GET_AUDITORIA_FC('PRE_GARANTIAS_TB')
	UNION ALL
	SELECT REGISTRO,SECUENCIA,'AHORROS' AS SERVICIO,TABLA,TIPO,FECCRE,USRCRE,TERCRE,PRIMARY_KEY,PRIMARY_KEY_VAL,COLUMNA,COLUMNA_NOMBRE,DESCRIPCION,VALOR_ANTERIOR,VALOR_NUEVO
	FROM BMS_GET_AUDITORIA_FC('AHORROS')
	UNION ALL
	SELECT REGISTRO,SECUENCIA,'AHORROS' AS SERVICIO,TABLA,TIPO,FECCRE,USRCRE,TERCRE,PRIMARY_KEY,PRIMARY_KEY_VAL,COLUMNA,COLUMNA_NOMBRE,DESCRIPCION,VALOR_ANTERIOR,VALOR_NUEVO
	FROM BMS_GET_AUDITORIA_FC('CUENTASDUENNOS')
	UNION ALL
	SELECT REGISTRO,SECUENCIA,'APORTACIONES' AS SERVICIO,TABLA,TIPO,FECCRE,USRCRE,TERCRE,PRIMARY_KEY,PRIMARY_KEY_VAL,COLUMNA,COLUMNA_NOMBRE,DESCRIPCION,VALOR_ANTERIOR,VALOR_NUEVO
	FROM BMS_GET_AUDITORIA_FC('APORTACIONES')
	UNION ALL
	SELECT REGISTRO,SECUENCIA,'CAJAS' AS SERVICIO,TABLA,TIPO,FECCRE,USRCRE,TERCRE,PRIMARY_KEY,PRIMARY_KEY_VAL,COLUMNA,COLUMNA_NOMBRE,DESCRIPCION,VALOR_ANTERIOR,VALOR_NUEVO
	FROM BMS_GET_AUDITORIA_FC('CAJASORDENES');


--SELECT * FROM BMS_AUDITORIA_DETALLADA;
