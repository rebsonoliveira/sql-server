using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using MsSql.RestApi;
using System;
using System.Threading.Tasks;

namespace wwi_azure_functions
{
    public static class StockItems
    {
        [FunctionName("StockItems")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req, ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            try
            {
                TableSpec stockitems = new TableSpec("WebApi", "StockItems", "StockItemID,StockItemName,SupplierName,SupplierReference,ColorName,OuterPackage,UnitPackage,Brand,Size,LeadTimeDays,QuantityPerOuter,IsChillerStock,Barcode,TaxRate,UnitPrice,RecommendedRetailPrice,TypicalWeightPerUnit,MarketingComments,InternalComments,CustomFields,QuantityOnHand,BinLocation,LastStocktakeQuantity,LastCostPrice,ReorderLevel,TargetStockLevel,SupplierID,ColorID,UnitPackageID,OuterPackageID");
                return await req.OData(stockitems).GetResult(Environment.GetEnvironmentVariable("SqlDb"));
            }
            catch (Exception ex)
            {
                log.LogError($"C# Http trigger function exception: {ex.Message}");
                return new StatusCodeResult(500);
            }
        }
    }
}
