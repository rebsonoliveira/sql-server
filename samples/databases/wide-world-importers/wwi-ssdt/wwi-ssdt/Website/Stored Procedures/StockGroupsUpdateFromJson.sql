CREATE PROCEDURE [Website].[StockGroupsUpdateFromJson](@StockGroupsJson NVARCHAR(MAX), @StockGroupID int,@UserID int)
WITH EXECUTE AS OWNER
AS BEGIN
	UPDATE Warehouse.StockGroups SET
		StockGroupName = json.StockGroupName,
		LastEditedBy = @UserID
	FROM OPENJSON (@StockGroupsJson)
		WITH (StockGroupName nvarchar(50)) as json
	WHERE 
		Warehouse.StockGroups.StockGroupID = @StockGroupID

END