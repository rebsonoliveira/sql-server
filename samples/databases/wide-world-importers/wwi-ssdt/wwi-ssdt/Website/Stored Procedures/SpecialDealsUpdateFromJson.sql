CREATE PROCEDURE Website.[SpecialDealsUpdateFromJson](@Deals NVARCHAR(MAX), @DealID int, @UserID int)
WITH EXECUTE AS OWNER
AS BEGIN	UPDATE Sales.SpecialDeals SET
				StockItemID = ISNULL(json.StockItemID,Sales.SpecialDeals.StockItemID),
				CustomerID = ISNULL(json.CustomerID,Sales.SpecialDeals.CustomerID),
				BuyingGroupID = ISNULL(json.BuyingGroupID,Sales.SpecialDeals.BuyingGroupID),
				CustomerCategoryID = ISNULL(json.CustomerCategoryID,Sales.SpecialDeals.CustomerCategoryID),
				StockGroupID = ISNULL(json.StockGroupID,Sales.SpecialDeals.StockGroupID),
				DealDescription = ISNULL(json.DealDescription,Sales.SpecialDeals.DealDescription),
				StartDate = ISNULL(json.StartDate,Sales.SpecialDeals.StartDate),
				EndDate = ISNULL(json.EndDate,Sales.SpecialDeals.EndDate),
				DiscountAmount = ISNULL(json.DiscountAmount,Sales.SpecialDeals.DiscountAmount),
				DiscountPercentage = ISNULL(json.DiscountPercentage,Sales.SpecialDeals.DiscountPercentage),
				UnitPrice = ISNULL(json.UnitPrice,Sales.SpecialDeals.UnitPrice),
				LastEditedBy = @UserID
			FROM OPENJSON(@Deals)
				WITH (
					StockItemID int,
					CustomerID int,
					BuyingGroupID int,
					CustomerCategoryID int,
					StockGroupID int,
					DealDescription nvarchar(30),
					StartDate date,
					EndDate date,
					DiscountAmount decimal(18,2),
					DiscountPercentage decimal(18,3),
					UnitPrice decimal(18,2)) as json
			WHERE 
				Sales.SpecialDeals.SpecialDealID = @DealID

END