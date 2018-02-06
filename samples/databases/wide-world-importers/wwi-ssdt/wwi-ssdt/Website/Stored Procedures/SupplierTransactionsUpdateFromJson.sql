CREATE PROCEDURE Website.SupplierTransactionsUpdateFromJson(@SupplierTransactions NVARCHAR(MAX), @SupplierTransactionID int, @UserID int)
WITH EXECUTE AS OWNER
AS BEGIN	UPDATE Purchasing.SupplierTransactions SET
				SupplierID = ISNULL(json.SupplierID,Purchasing.SupplierTransactions.SupplierID),
				TransactionTypeID = ISNULL(json.TransactionTypeID,Purchasing.SupplierTransactions.TransactionTypeID),
				PurchaseOrderID = ISNULL(json.PurchaseOrderID,Purchasing.SupplierTransactions.PurchaseOrderID),
				PaymentMethodID = ISNULL(json.PaymentMethodID,Purchasing.SupplierTransactions.PaymentMethodID),
				SupplierInvoiceNumber = ISNULL(json.SupplierInvoiceNumber,Purchasing.SupplierTransactions.SupplierInvoiceNumber),
				TransactionDate = ISNULL(json.TransactionDate,Purchasing.SupplierTransactions.TransactionDate),
				AmountExcludingTax = ISNULL(json.AmountExcludingTax,Purchasing.SupplierTransactions.AmountExcludingTax),
				TaxAmount = ISNULL(json.TaxAmount,Purchasing.SupplierTransactions.TaxAmount),
				TransactionAmount = ISNULL(json.TransactionAmount,Purchasing.SupplierTransactions.TransactionAmount),
				OutstandingBalance = ISNULL(json.OutstandingBalance,Purchasing.SupplierTransactions.OutstandingBalance),
				FinalizationDate = ISNULL(json.FinalizationDate,Purchasing.SupplierTransactions.FinalizationDate),
				LastEditedBy = @UserID
			FROM OPENJSON(@SupplierTransactions)
				WITH (
					SupplierID int,
					TransactionTypeID int,
					PurchaseOrderID int,
					PaymentMethodID int,
					SupplierInvoiceNumber nvarchar(20),
					TransactionDate date,
					AmountExcludingTax decimal(18,2),
					TaxAmount decimal(18,2),
					TransactionAmount decimal(18,2),
					OutstandingBalance decimal(18,2),
					FinalizationDate date) as json
			WHERE 
				Purchasing.SupplierTransactions.SupplierTransactionID = @SupplierTransactionID

END