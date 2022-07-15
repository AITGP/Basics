---REGION: PL/SQL DYNAMIC CONTENT
-- SHOW PDF FILES IN A REGION IN ORACLE APEX
DECLARE
   v_blob    BLOB := empty_blob(); --Blob to store the file content
   l_step    number := 22500;      --Steps in bytes to print the file content
BEGIN
--Validate if the Item is not null
if (:P90_ID is not null) then
  --Get the blob content of the file. (this could be a function instead)
    select FILE_BLOB
    into v_blob
    from EBA_INTRACK_FILES --- TABLE WITH THE BLOB COLUMN
    where ID = :P90_ID; -- ID
     
 -- Open temporary lob
    DBMS_LOB.OPEN(v_blob, DBMS_LOB.LOB_READONLY);
 
  --Write  the code to display the PDF
    htp.p( '<embed src="data:application/pdf;base64,' );
  --Loop through the blob content
     for i in 0 .. trunc((dbms_lob.getlength(v_blob) - 1 )/l_step) loop
       --Get a substring of the blob, encode it to Base64 and cast from RAW to varchar
        htp.p( utl_raw.cast_to_varchar2(utl_encode.base64_encode(dbms_lob.substr(v_blob, l_step, i * l_step + 1))));
    end loop;
  --Close the HTML tag and add some properties
    htp.p('"width="100%" height="650"  >');
 
 -- Close lob objects
    DBMS_LOB.CLOSE(v_blob);
end if;
 
EXCEPTION WHEN OTHERS THEN
    htp.p('There was an error displaying the PDF file, Sorry');
END;