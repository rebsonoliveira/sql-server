DROP INDEX IF EXISTS [NCCX_Sales_OrderLines] ON [Sales].[OrderLines]

/****** Object:  Index [NCCX_Sales_OrderLines]    Script Date: 4/20/2017 11:27:27 AM ******/
CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCX_Sales_OrderLines] ON [Sales].[OrderLines]
(
	[OrderID],
	[StockItemID],
	[Description],
	[Quantity],
	[UnitPrice],
	[PickedQuantity],
	[PackageTypeID] -- adding package type id for demo purpose
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [USERDATA]
GO

CREATE OR ALTER PROCEDURE [dbo].[initialize]
as begin

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
ALTER DATABASE current SET QUERY_STORE CLEAR ALL;
ALTER DATABASE current SET AUTOMATIC_TUNING ( FORCE_LAST_GOOD_PLAN = OFF);

end
GO


CREATE OR ALTER PROCEDURE [dbo].[report] (@packagetypeid int)
as begin

select avg([UnitPrice]*[Quantity])
from Sales.OrderLines
where PackageTypeID = @packagetypeid

end
GO


CREATE OR ALTER PROCEDURE [dbo].[regression]
as begin

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
begin
       declare @packagetypeid int = 1;
       exec report @packagetypeid;
end

end
GO

CREATE OR ALTER PROCEDURE [dbo].[auto_tuning_on]
as begin

ALTER DATABASE current SET AUTOMATIC_TUNING ( FORCE_LAST_GOOD_PLAN = ON);
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
ALTER DATABASE current SET QUERY_STORE CLEAR ALL;

end
GO


CREATE OR ALTER PROCEDURE [dbo].[auto_tuning_off]
as begin

ALTER DATABASE current SET AUTOMATIC_TUNING ( FORCE_LAST_GOOD_PLAN = OFF);
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
ALTER DATABASE current SET QUERY_STORE CLEAR ALL;

end
GO

CREATE EVENT SESSION [APC - plans that are not corrected] ON SERVER

ADD EVENT qds.automatic_tuning_plan_regression_detection_check_completed(
WHERE ((([is_regression_detected]=(1))
  AND ([is_regression_corrected]=(0)))
  AND ([option_id]=(1))))
ADD TARGET package0.event_file(SET filename=N'plans_that_are_not_corrected')
WITH (STARTUP_STATE=ON);
GO

ALTER EVENT SESSION [APC - plans that are not corrected] ON SERVER STATE = start;