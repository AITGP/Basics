select * 
from
    all_constraints 
where
    r_constraint_name in
    (select       constraint_name
    from
       all_constraints
    where
       table_name='MYTAB') 
