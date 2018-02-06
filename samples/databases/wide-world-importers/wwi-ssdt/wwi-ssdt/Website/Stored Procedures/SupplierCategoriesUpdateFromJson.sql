CREATE PROCEDURE [Website].[SupplierCategoriesUpdateFromJson](@SupplierCategoriesJson NVARCHAR(MAX), @SupplierCategoryID int, @UserID int)
WITH EXECUTE AS OWNER
AS BEGIN
	UPDATE Purchasing.SupplierCategories SET
		SupplierCategoryName = json.SupplierCategoryName,
		LastEditedBy = @UserID
	FROM OPENJSON (@SupplierCategoriesJson)
		WITH (SupplierCategoryName nvarchar(50)) as json
	WHERE 
		Purchasing.SupplierCategories.SupplierCategoryID = @SupplierCategoryID

END