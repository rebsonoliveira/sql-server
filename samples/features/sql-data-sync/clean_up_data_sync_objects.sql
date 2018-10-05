-- List Data Sync user tables
select * from sys.tables as st join sys.schemas as ss on ss.schema_id = st.schema_id 
where ss.name = 'DataSync' and st.name like '%_dss%' and st.name like '%<tablename>_dss%'

-- Generate the script to drop Data Sync tables
select 'Drop table [DataSync].['+ st.name+ '];' from sys.tables as st join sys.schemas as ss on ss.schema_id = st.schema_id 
where ss.name = 'DataSync' and st.name like '%_dss%' and st.name like '%<tablename>_dss%'

-- List Data Sync stored procedures
select * from sys.procedures as sp join sys.schemas as ss on ss.schema_id = sp.schema_id 
where ss.name = 'DataSync' and sp.name like '%_dss_%'  and sp.name like '%<tablename>_dss%'

--- Generate the script to drop Data Sync stored procedures
select 'Drop procedure [DataSync].['+ sp.name+ '];' from sys.procedures as sp join sys.schemas as ss on ss.schema_id = sp.schema_id 
where ss.name = 'DataSync' and sp.name like '%_dss_%' and sp.name like '%<tablename>_dss%'

-- List Data Sync triggers
select * from sys.triggers as st
where st.name like '%_dss%' and st.name like '%trigger' and st.name like '%<tablename>_dss%'

-- Generate the script to drop Data Sync triggers
select 'Drop trigger ['+st.name+']' from sys.triggers as st
where st.name like '%_dss%' and st.name like '%trigger' and st.name like '%<tablename>_dss%'

-- List Data Sync UDTs
select * from sys.types as st join 
sys.schemas as ss on st.schema_id = ss.schema_id 
where ss.name = 'DataSync' and st.name like '%_dss_%' and st.name like '%<tablename>_dss%'

-- Generate the script to drop Data Sync UDTs
select 'Drop Type  [DataSync].['+ st.name+ '];' 
from sys.types as st join 
sys.schemas as ss on st.schema_id = ss.schema_id 
where ss.name = 'DataSync' and st.name like '%_dss_%' and st.name like '%<tablename>_dss%'
