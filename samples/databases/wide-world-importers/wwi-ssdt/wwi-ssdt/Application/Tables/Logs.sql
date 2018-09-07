CREATE TABLE [Application].[Logs](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Message] [nvarchar](max) NULL,
	[Level] [nvarchar](128) NULL,
	[TimeStamp] [datetime] NOT NULL,
	[LogEvent] [nvarchar](max) NULL,
	INDEX cci CLUSTERED COLUMNSTORE
)
GO


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'CLUSTERED COLUMNSTORE INDEX that compress application log.', @level0type = N'SCHEMA', @level0name = N'Application', @level1type = N'TABLE', @level1name = N'Logs', @level2type = N'INDEX', @level2name = N'cci';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Application logs that are stored in database', @level0type = N'SCHEMA', @level0name = N'Application', @level1type = N'TABLE', @level1name = N'Logs';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Numeric ID of a log entry', @level0type = N'SCHEMA', @level0name = N'Application', @level1type = N'TABLE', @level1name = N'Logs', @level2type = N'COLUMN', @level2name = N'Id';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Logged message', @level0type = N'SCHEMA', @level0name = N'Application', @level1type = N'TABLE', @level1name = N'Logs', @level2type = N'COLUMN', @level2name = N'Message';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Severity of the log entry', @level0type = N'SCHEMA', @level0name = N'Application', @level1type = N'TABLE', @level1name = N'Logs', @level2type = N'COLUMN', @level2name = N'Level';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Time when the record is logged', @level0type = N'SCHEMA', @level0name = N'Application', @level1type = N'TABLE', @level1name = N'Logs', @level2type = N'COLUMN', @level2name = N'TimeStamp';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Details about the logged event', @level0type = N'SCHEMA', @level0name = N'Application', @level1type = N'TABLE', @level1name = N'Logs', @level2type = N'COLUMN', @level2name = N'LogEvent';

