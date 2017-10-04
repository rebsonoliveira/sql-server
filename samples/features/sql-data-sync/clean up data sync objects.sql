--We want to drop all user table start with datasync and contains _dss
select * from sys.tables as st join sys.schemas as ss on ss.schema_id = st.schema_id 
where ss.name = 'DataSync' and st.name like '%_dss%' and st.name like '%<tablename>%

--generate the script to drop data sync tables
select 'Drop table [DataSync].['+ st.name+ '];' from sys.tables as st join sys.schemas as ss on ss.schema_id = st.schema_id 
where ss.name = 'DataSync' and st.name like '%_dss%' and st.name like '%<tablename>%

-- list data sync store procedures
select * from sys.procedures as sp join sys.schemas as ss on ss.schema_id = sp.schema_id 
where ss.name = 'DataSync' and sp.name like '%_dss_%'  and sp.name like '%<tablename>%

--- generate the script to drop data sync store procedures
select 'Drop procedure [DataSync].['+ sp.name+ '];' from sys.procedures as sp join sys.schemas as ss on ss.schema_id = sp.schema_id 
where ss.name = 'DataSync' and sp.name like '%_dss_%' and sp.name like '%<tablename>%

-- list triggers for data sync
select * from sys.triggers as st
where st.name like '%_dss%' and st.name like '%trigger' and st.name like '%<tablename>%

--delete datasync triggers if there is any
select 'Drop trigger ['+st.name+']' from sys.triggers as st
where st.name like '%_dss%' and st.name like '%trigger' and st.name like '%<tablename>%


-- list user-define for data sync

select * from sys.types as st join 
sys.schemas as ss on st.schema_id = ss.schema_id 
where ss.name = 'DataSync' and st.name like '%_dss_%' and st.name like '%<tablename>%

--- generate script for dropping data sync-related  udtt
select 'Drop Type  [DataSync].['+ st.name+ '];' 
from sys.types as st join 
sys.schemas as ss on st.schema_id = ss.schema_id 
where ss.name = 'DataSync' and st.name like '%_dss_%' and st.name like '%<tablename>%

