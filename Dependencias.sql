--ORACLE DATABASE
--SEARCH ALL THE DEPENDENCES THAT HAVE A TABLE
--PARAMETERS
--MY_TABLE: TABLE YOU ARE SEARCHING THE DEPENDENCIES.
select * 
from
    all_constraints 
where
    r_constraint_name in
    (select       constraint_name
    from
       all_constraints
    where
       table_name=:MY_TABLE);
