--FECHA EN PL/SQL EN FORMATO DE MES EN ESPANOL
TO_CHAR(SYSDATE,'DD/Month/YYYY','NLS_DATE_LANGUAGE = Spanish')
--HTML PARA AGREGAR IMAGENES DE SHARED COMPONENTS EN LOS REPORTES
<img src="#WORKSPACE_IMAGES#print-icon.png"></img>

--javasctipt para ejecutar un PL/SQL desde un reporte
--#REFERENCIA_ID# Primary Key del reporte
javascript:$.event.trigger('CUSTOM_JAVASCRIPT','#REFERENCIA_ID#');


--dynamic action
--Custom Event: CUSTOM_JAVASCRIPT
--Selection Type: Javascript Expression
--Javascript Expression:  document

--True Actions
--Action: Set VALUE
--Settings
--Set Type: Javascript Expression
--Javascript Expression: this.data
--Affected Elements
--Selection Type: Item
--Items: P1_REF_ID --ITEM QUE RECIBE EL PARAMETRO DEL REPORTE

--True Actions
--Ya se puede ejecutar un PL/SQL con el item cargado con el PK de la tabla :P1_REF_ID
------------------------------------------------------------

--TERMINAL DESDE APEX
OWA_UTIL.GET_CGI_ENV('REMOTE_ADDR')
------------------------------------------------------------

--MOSTRAR MENSAJE DE ERROR DESDE APEX
apex_error.add_error (
    p_message          => 'This custom account is not active!',
    p_display_location => apex_error.c_inline_in_notification );

------------------------------------------------------------
---SELECT PARA CONDICIONAR UNA COLUMNA PARA QUE SE MUESTRE O NO EN EL REPORTE (CLASICO/INTERACTIVO)
SELECT 
case when COLUMN_NAME = 'SI' then
	'hidden_link'
end CSS_TYPE
FROM DUAL
--CSS INLINE
--CSS QUE OCULTA UN REFISTRO 
<style type="text/css">
  .hidden_link { display: none; }
</style>
