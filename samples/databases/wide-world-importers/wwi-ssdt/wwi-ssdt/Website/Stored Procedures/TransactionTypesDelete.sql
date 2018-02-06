CREATE PROCEDURE [Website].[TransactionTypesDelete](@TransactionTypeID int)
WITH EXECUTE AS OWNER
AS BEGIN
	DELETE Application.TransactionTypes
	WHERE TransactionTypeID = @TransactionTypeID
END