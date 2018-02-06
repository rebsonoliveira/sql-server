CREATE PROCEDURE [Website].[StockGroupsInsertFromJson](@StockGroupsJson NVARCHAR(MAX), @UserID int)
WITH EXECUTE AS OWNER
AS BEGIN
	INSERT INTO Warehouse.StockGroups(StockGroupName,LastEditedBy)
			OUTPUT  INSERTED.StockGroupID
			SELECT StockGroupName,@UserID
			FROM OPENJSON(@StockGroupsJson)
				WITH (StockGroupName nvarchar(50))
END