CREATE PROCEDURE Website.PurchaseOrdersUpdateFromJson(@PurchaseOrders NVARCHAR(MAX), @PurchaseOrderID int, @UserID int)
WITH EXECUTE AS OWNER
AS BEGIN	UPDATE Purchasing.PurchaseOrders SET
				SupplierID = ISNULL(json.SupplierID,Purchasing.PurchaseOrders.SupplierID),
				OrderDate = ISNULL(json.OrderDate,Purchasing.PurchaseOrders.OrderDate),
				DeliveryMethodID = ISNULL(json.DeliveryMethodID,Purchasing.PurchaseOrders.DeliveryMethodID),
				ContactPersonID = ISNULL(json.ContactPersonID,Purchasing.PurchaseOrders.ContactPersonID),
				ExpectedDeliveryDate = ISNULL(json.ExpectedDeliveryDate,Purchasing.PurchaseOrders.ExpectedDeliveryDate),
				SupplierReference = ISNULL(json.SupplierReference,Purchasing.PurchaseOrders.SupplierReference),
				IsOrderFinalized = ISNULL(json.IsOrderFinalized,Purchasing.PurchaseOrders.IsOrderFinalized)
			FROM OPENJSON(@PurchaseOrders)
				WITH (
					SupplierID int,
					OrderDate date,
					DeliveryMethodID int,
					ContactPersonID int,
					ExpectedDeliveryDate date,
					SupplierReference nvarchar(20),
					IsOrderFinalized bit) as json
			WHERE 
				Purchasing.PurchaseOrders.PurchaseOrderID = @PurchaseOrderID

END