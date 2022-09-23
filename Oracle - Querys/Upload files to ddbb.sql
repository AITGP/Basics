--------------------------------------------------------------------------------------------
DECLARE
  l_file      UTL_FILE.FILE_TYPE;
  l_buffer    RAW(32767);
  l_amount    BINARY_INTEGER := 32767;
  l_pos       INTEGER := 1;
  l_blob      BLOB;
  l_blob_len  INTEGER;
  sysid number;
  
  src_lob bfile;
  cursor imagenes is   
    select lpad(numid,8,'0')||'.jpg'  as imagenRol, numid from tabla_generales 
    where numid is not null;
BEGIN
    for i in imagenes loop
      begin


         src_lob := bfilename('FOTOS',i.imagenRol);

         insert into fotos ( photo, filename, mimetype, last_update_date, pht_id)
         values ( EMPTY_BLOB(), i.imagenRol, 'image/jpeg', sysdate, numid)
         RETURNING photo into l_blob;
    
         dbms_lob.open(src_lob, dbms_lob.LOB_READONLY);
         dbms_lob.LoadFromFile( l_blob,  src_lob, dbms_lob.getlength(src_lob) );
         dbms_lob.close(src_lob);
         commit;

         exception when others then
            null;
    end;
     end loop;
END;
