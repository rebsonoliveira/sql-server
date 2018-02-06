CREATE PROCEDURE [Website].[TransactionTypesUpdateFromJson](@TransactionTypesJson NVARCHAR(MAX), @TransactionTypeID int,@UserID int)
WITH EXECUTE AS OWNER
AS BEGIN
	UPDATE Application.TransactionTypes SET
		TransactionTypeName = json.TransactionTypeName,
		LastEditedBy = @UserID
	FROM OPENJSON (@TransactionTypesJson)
		WITH (TransactionTypeName nvarchar(50)) as json
	WHERE 
		Application.TransactionTypes.TransactionTypeID = @TransactionTypeID

END