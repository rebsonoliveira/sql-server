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

CREATE   procedure [dbo].[initialize]
as begin

DBCC FREEPROCCACHE;
ALTER DATABASE current SET QUERY_STORE CLEAR ALL;
ALTER DATABASE current SET AUTOMATIC_TUNING ( FORCE_LAST_GOOD_PLAN = OFF);

end
GO

CREATE   procedure [dbo].[report] (@packagetypeid int)
as begin

select avg([UnitPrice]*[Quantity])
from Sales.OrderLines
where PackageTypeID = @packagetypeid

end
GO


CREATE   procedure [dbo].[regression]
as begin

DBCC FREEPROCCACHE;
begin
       declare @packagetypeid int = 1;
       exec report @packagetypeid
end

end
GO

CREATE   procedure [dbo].[auto_tuning_on]
as begin

ALTER DATABASE current SET AUTOMATIC_TUNING ( FORCE_LAST_GOOD_PLAN = ON);
DBCC FREEPROCCACHE;
ALTER DATABASE current SET QUERY_STORE CLEAR ALL;

end
GO


CREATE   procedure [dbo].[auto_tuning_off]
as begin

ALTER DATABASE current SET AUTOMATIC_TUNING ( FORCE_LAST_GOOD_PLAN = OFF);
DBCC FREEPROCCACHE;
ALTER DATABASE current SET QUERY_STORE CLEAR ALL;

end
GO