CREATE PROCEDURE [Website].[PaymentMethodsInsertFromJson](@PaymentMethodsJson NVARCHAR(MAX), @UserID int)
WITH EXECUTE AS OWNER
AS BEGIN
	INSERT INTO Application.PaymentMethods(PaymentMethodName,LastEditedBy)
			OUTPUT  INSERTED.PaymentMethodID
			SELECT PaymentMethodName,@UserID
			FROM OPENJSON(@PaymentMethodsJson)
				WITH (PaymentMethodName nvarchar(50))
END