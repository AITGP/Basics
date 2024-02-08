--FECHA EN PL/SQL EN FORMATO DE MES EN ESPANOL
TO_CHAR(SYSDATE,'DD/Month/YYYY','NLS_DATE_LANGUAGE = Spanish')
--HTML PARA AGREGAR IMAGENES DE SHARED COMPONENTS EN LOS REPORTES
<img src="#WORKSPACE_IMAGES#print-icon.png"></img>

--javasctipt para ejecutar un PL/SQL desde un reporte
--#REFERENCIA_ID# Primary Key del reporte
javascript:$.event.trigger('CUSTOM_JAVASCRIPT','#REFERENCIA_ID#');

--Custom Attributes =  
style="pointer-events: none;" 
--para bloquear listar de valores llamado por Dynamic actions

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

--HTML HEADER
--CSS QUE OCULTA UN REGISTRO 
<style type="text/css">
  .hidden_link { display: none; }
</style>

--EN LA COLUMNA QUE SE QUIERE OCULTAR 
--SI es un LINK
--Link Attributes
class="#CSS_TYPE#"

---------------------------------------------------------
--DYNAMIC ACTION PARA ABRIR UN MODAL PAGE 
--CREAR ITEM CON URL 
--P1_URL
--Source: PL/SQL Expression
apex_util.prepare_url('f?p=&APP_ID.:#PAGE_ID#:&SESSION.::&DEBUG.::#PAGE_ITEMS#:#PAGE_VALUES#:', p_triggering_element => '$(''#is-active'')')

--En el true action del dynamic action que va a abrir el modal 
--Execute Javascript Code
eval($('#P1_URL').val())


--Dynamic Action para prevenir que la pagina envie el error de re-submitted
--Dynamic action 
-- Before PAge Submit

--Action
--Javascript Code
$("body").append('<div class="ui-widget-overlay ui-front"/>');
apex.widget.waitPopup();