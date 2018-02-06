CREATE PROCEDURE Website.SuppliersDelete(@SupplierID int)
WITH EXECUTE AS OWNER
AS BEGIN
	DELETE Purchasing.Suppliers
	WHERE SupplierID = @SupplierID;
END