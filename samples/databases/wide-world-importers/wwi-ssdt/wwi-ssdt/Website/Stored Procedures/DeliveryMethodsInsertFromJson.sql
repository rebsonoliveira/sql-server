CREATE PROCEDURE [Website].[DeliveryMethodsInsertFromJson](@DeliveryMethodsJson NVARCHAR(MAX), @UserID int)
WITH EXECUTE AS OWNER
AS BEGIN
	INSERT INTO Application.DeliveryMethods(DeliveryMethodName,LastEditedBy)
			OUTPUT  INSERTED.DeliveryMethodID
			SELECT DeliveryMethodName,@UserID
			FROM OPENJSON(@DeliveryMethodsJson)
				WITH (DeliveryMethodName nvarchar(50))
END