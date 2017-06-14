CREATE TABLE [dbo].[SampleVersion]
(
	MajorSampleVersion INT NOT NULL,
	MinorSampleVersion INT NOT NULL,
	MinSQLServerBuild NVARCHAR(25) NOT NULL,
	[RowCount] INT NOT NULL DEFAULT (1),
	CONSTRAINT uq_SampleVersion_RowCount UNIQUE ([RowCount]),
	CONSTRAINT chk_SampleVersion_cardinality 
	  CHECK ([RowCount]= 1)
)

