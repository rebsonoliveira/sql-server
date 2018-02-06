CREATE PROCEDURE [Website].[BuyingGroupsUpdateFromJson](@BuyingGroupsJson NVARCHAR(MAX), @BuyingGroupID int,@UserID int)
WITH EXECUTE AS OWNER
AS BEGIN
	UPDATE Sales.BuyingGroups SET
		BuyingGroupName = json.BuyingGroupName,
		LastEditedBy = @UserID
	FROM OPENJSON (@BuyingGroupsJson)
		WITH (BuyingGroupName nvarchar(50)) as json
	WHERE 
		Sales.BuyingGroups.BuyingGroupID = @BuyingGroupID

END