CREATE PROCEDURE [Website].[DeliveryMethodsUpdateFromJson](@DeliveryMethodsJson NVARCHAR(MAX), @DeliveryMethodID int,@UserID int)
WITH EXECUTE AS OWNER
AS BEGIN
	UPDATE Application.DeliveryMethods SET
		DeliveryMethodName = json.DeliveryMethodName,
		LastEditedBy = @UserID
	FROM OPENJSON (@DeliveryMethodsJson)
		WITH (DeliveryMethodName nvarchar(50)) as json
	WHERE 
		Application.DeliveryMethods.DeliveryMethodID = @DeliveryMethodID

END