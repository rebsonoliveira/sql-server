CREATE PROCEDURE [Website].[StockGroupsDelete](@StockGroupID int)
WITH EXECUTE AS OWNER
AS BEGIN
	DELETE Warehouse.StockGroups
	WHERE StockGroupID = @StockGroupID
END