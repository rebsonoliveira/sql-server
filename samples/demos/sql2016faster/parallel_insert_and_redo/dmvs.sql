select r.session_id, r.status, r.command, r.wait_type, r.wait_resource, r.wait_time 
from sys.dm_exec_requests r
join sys.dm_exec_sessions e
on e.session_id = r.session_id
and e.is_user_process = 1
go
select wt.* from sys.dm_os_waiting_tasks wt
join sys.dm_exec_sessions e
on e.session_id = wt.session_id
and e.is_user_process = 1
go
