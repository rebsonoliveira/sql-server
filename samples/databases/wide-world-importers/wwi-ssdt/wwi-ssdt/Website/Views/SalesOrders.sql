
CREATE   VIEW Website.SalesOrders
AS
SELECT	o.OrderID, o.OrderDate, OrderNumber = o.CustomerPurchaseOrderNumber, o.ExpectedDeliveryDate,
		o.PickingCompletedWhen,	o.DeliveryInstructions,
		o.CustomerID, c.CustomerName, c.PhoneNumber, c.FaxNumber, c.WebsiteURL, 
        c.DeliveryAddressLine1, c.DeliveryAddressLine2, c.DeliveryPostalCode, c.DeliveryLocation,
		SalesPerson = sp.FullName, SalesPersonPhone = sp.PhoneNumber, SalesPersonEmail = sp.EmailAddress
FROM	Sales.Orders o
		INNER JOIN Sales.Customers c
			ON o.CustomerID = c.CustomerID
		INNER JOIN Application.People sp
			ON o.SalespersonPersonID = sp.PersonID

