


CREATE PROCEDURE [Website].[DeliveryMethodsDelete](@DeliveryMethodID int)
WITH EXECUTE AS OWNER
AS BEGIN
	DELETE Application.DeliveryMethods
	WHERE DeliveryMethodID = @DeliveryMethodID
END