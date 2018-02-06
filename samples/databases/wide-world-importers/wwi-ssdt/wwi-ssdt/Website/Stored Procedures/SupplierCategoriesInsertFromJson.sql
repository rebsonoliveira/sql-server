CREATE PROCEDURE [Website].[SupplierCategoriesInsertFromJson](@SupplierCategoriesJson NVARCHAR(MAX), @UserID int)
WITH EXECUTE AS OWNER
AS BEGIN
	INSERT INTO Purchasing.SupplierCategories(SupplierCategoryName,LastEditedBy)
			OUTPUT  INSERTED.SupplierCategoryID
			SELECT SupplierCategoryName,@UserID
			FROM OPENJSON(@SupplierCategoriesJson)
				WITH (SupplierCategoryName nvarchar(50))
END