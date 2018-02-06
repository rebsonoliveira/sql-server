CREATE PROCEDURE [Website].[PackageTypesInsertFromJson](@PackageTypesJson NVARCHAR(MAX), @UserID int)
WITH EXECUTE AS OWNER
AS BEGIN
	INSERT INTO Warehouse.PackageTypes(PackageTypeName,LastEditedBy)
			OUTPUT  INSERTED.PackageTypeID
			SELECT PackageTypeName,@UserID
			FROM OPENJSON(@PackageTypesJson)
				WITH (PackageTypeName nvarchar(50))
END