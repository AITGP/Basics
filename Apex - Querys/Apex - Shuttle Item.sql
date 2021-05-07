---PROCESO PARA DESCOMPONER UN ITEM TIPO SHUTTLE A VARIOS REGISTROS
declare
    tab apex_application_global.vc_arr2;
begin
    tab := apex_util.string_to_table (:P88_INVITADOS);
    DELETE EBA_REUNIONES_DETALLE
    WHERE red_reunionid = :P88_REU_ID;
    for i in 1..tab.count loop
        insert into EBA_REUNIONES_DETALLE (red_reunionid, red_username)
        values (:P88_REU_ID,tab(i));
    end loop;
end;


--PROCESO PARA TRANSFORMAR VARIOS REGISTROS A UN ITEM TIPO SHUTTLE
DECLARE
   v_tab apex_application_global.vc_arr2;
   i    number := 1;
begin
   for r in (select RED_USERNAME
                from EBA_REUNIONES_DETALLE
                WHERE RED_REUNIONID = :P88_REU_ID) loop
      v_tab(i) := r.RED_USERNAME;
      i := i + 1;
   end loop;

   return apex_util.table_to_string(v_tab,':');
end;