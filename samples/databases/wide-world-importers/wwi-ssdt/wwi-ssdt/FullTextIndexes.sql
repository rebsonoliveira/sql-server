CREATE FULLTEXT INDEX ON [Warehouse].[StockItems]
    ([CustomFields] LANGUAGE 1033, [Tags] LANGUAGE 1033, [SearchDetails] LANGUAGE 1033)
    KEY INDEX [PK_Warehouse_StockItems]
    ON [FTCatalog];


GO
CREATE FULLTEXT INDEX ON [Sales].[Customers]
    ([CustomerName] LANGUAGE 1033)
    KEY INDEX [PK_Sales_Customers]
    ON [FTCatalog];


GO
CREATE FULLTEXT INDEX ON [Purchasing].[Suppliers]
    ([SupplierName] LANGUAGE 1033)
    KEY INDEX [PK_Purchasing_Suppliers]
    ON [FTCatalog];


GO
CREATE FULLTEXT INDEX ON [Application].[People]
    ([SearchName] LANGUAGE 1033, [CustomFields] LANGUAGE 1033, [OtherLanguages] LANGUAGE 1033)
    KEY INDEX [PK_Application_People]
    ON [FTCatalog];

