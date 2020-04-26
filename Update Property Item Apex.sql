update APEX_050100.wwv_flow_step_items
set  attribute_08 = 'ENTERABLE_RESTRICTED'
where upper(display_as) = 'PLUGIN_COM_SKILLBUILDERS_SUPER_LOV'
and attribute_08 = 'NOT_ENTERABLE';