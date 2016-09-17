DROP EVENT SESSION [recoverytraces] ON SERVER
go
-- Note here that we create this as a startup event session
-- but don't start it. That is because since we created it for
-- startup it will be started when SQL Server starts (but before rcovery is run)
CREATE EVENT SESSION [recoverytraces] ON SERVER 
ADD EVENT sqlserver.database_recovery_progress_report,
ADD EVENT sqlserver.database_recovery_times,
ADD EVENT sqlserver.database_recovery_trace,
ADD EVENT sqlserver.recovery_catch_checkpoint,
ADD EVENT sqlserver.recovery_force_oldest_page,
ADD EVENT sqlserver.recovery_indirect_checkpoint,
ADD EVENT sqlserver.recovery_simple_log_truncate,
ADD EVENT sqlserver.recovery_skip_checkpoint,
ADD EVENT sqlserver.recovery_target_miss,
ADD EVENT sqlserver.recovery_target_reset
ADD TARGET package0.event_file(SET filename=N'C:\temp\recoverytraces.xel',max_file_size=(512),max_rollover_files=(10))
WITH (MAX_MEMORY=32768 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=PER_CPU,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO