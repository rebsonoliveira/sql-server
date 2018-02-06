
CREATE PROCEDURE [Website].[PackageTypesDelete](@PackageTypeID int)
WITH EXECUTE AS OWNER
AS BEGIN
	DELETE Warehouse.PackageTypes
	WHERE PackageTypeID = @PackageTypeID
END