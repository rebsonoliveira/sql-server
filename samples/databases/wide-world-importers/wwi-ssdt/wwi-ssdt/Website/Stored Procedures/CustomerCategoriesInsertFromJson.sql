


CREATE PROCEDURE [Website].[CustomerCategoriesInsertFromJson](@CustomerCategoriesJson NVARCHAR(MAX), @UserID int)
WITH EXECUTE AS OWNER
AS BEGIN
	INSERT INTO Sales.CustomerCategories(CustomerCategoryName,LastEditedBy)
			OUTPUT  INSERTED.CustomerCategoryID
			SELECT CustomerCategoryName,@UserID
			FROM OPENJSON(@CustomerCategoriesJson)
				WITH (CustomerCategoryName nvarchar(50))
END