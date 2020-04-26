 SELECT NAME AS APPLICATION_ID, TYPE as APPLICATION_NAME, LINE AS PAGE_ID, substr(text,1,20) as lugar FROM DBA_SOURCE where UPPER(DBA_SOURCE.text) like '%INVPARAMETROS%' AND OWNER = 'ECOOPDESA'
  UNION
  select to_char(APPLICATION_ID), APPLICATION_NAME, PAGE_ID, REGION_NAME as lugar from APEX_050000.apex_application_page_ir where   upper(sql_query) like '%INVPARAMETROS%'
  UNION 
  select to_char(APPLICATION_ID), APPLICATION_NAME, PAGE_ID,PROCESS_NAME AS LUGAR from APEX_050000.apex_application_page_proc where  upper(process_source) like '%INVPARAMETROS%'; 
  
  
  select * from APEX_050000.apex_application_LOVS where  upper(LIST_OF_VALUES_QUERY) like '%MORPARAMETROS%'

 
 select * from APEX_050000.apex_application_lists where  upper(list_query) like '%INVPARAMETROS%'; 