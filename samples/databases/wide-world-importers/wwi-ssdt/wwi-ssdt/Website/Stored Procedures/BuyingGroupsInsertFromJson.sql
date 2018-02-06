CREATE PROCEDURE [Website].[BuyingGroupsInsertFromJson](@BuyingGroupsJson NVARCHAR(MAX), @UserID int)
WITH EXECUTE AS OWNER
AS BEGIN
	INSERT INTO Sales.BuyingGroups(BuyingGroupName,LastEditedBy)
			OUTPUT  INSERTED.BuyingGroupID
			SELECT BuyingGroupName,@UserID
			FROM OPENJSON(@BuyingGroupsJson)
				WITH (BuyingGroupName nvarchar(50))
END