declare @db_name sysname = 'master'

begin
declare @result NVARCHAR(MAX);
set @result = (select compatibility_level, recovery_model_desc, snapshot_isolation_state_desc, is_read_committed_snapshot_on, 
					is_auto_update_stats_on, is_auto_update_stats_async_on, delayed_durability_desc,
					is_encrypted, is_auto_create_stats_incremental_on, is_arithabort_on, is_ansi_warnings_on, is_parameterization_forced
from sys.databases
where name = @db_name 
for xml raw('db'), elements);
set @result += (select compatibility_level, snapshot_isolation_state_desc, is_read_committed_snapshot_on, 
					is_auto_update_stats_on, is_auto_update_stats_async_on, delayed_durability_desc,
					is_encrypted, is_auto_create_stats_incremental_on, is_arithabort_on, is_ansi_warnings_on, is_parameterization_forced,
					number_of_files = (select count(*) from master.sys.master_files where database_id = db_id('tempdb'))
from sys.databases
where name = 'tempdb' 
for xml raw('tempdb'), elements);
set @result += (
select name = CONCAT('DB-CONFIG:',name), value
from sys.database_scoped_configurations
for xml raw, elements );
declare @tf table (TraceFlag smallint, status bit,global bit, session bit) 
insert into @tf execute('DBCC TRACESTATUS(-1)');
set @result += (
select name=CONCAT('TF:',TraceFlag), value=status from @tf
where global=1 and session=0
for xml raw, elements
);
set @result += (
select name = CONCAT('CONFIG:',name), value from sys.configurations
where name in ('cost threshold for parallelism','cursor threshold','fill factor (%)'
,'index create memory (KB)','lightweight pooling'
,'locks','max degree of parallelism','max full-text crawl range','max text repl size (B)'
,'max worker threads','min memory per query (KB)','nested triggers'
,'network packet size (B)','optimize for ad hoc workloads'
,'priority boost','query governor cost limit','query wait (s)','recovery interval (min)'
,'set working set size','user connections')
for xml raw, elements
);
select cast(@result as xml);
end;

