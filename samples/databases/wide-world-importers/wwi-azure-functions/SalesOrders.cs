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
    public static class SalesOrders
    {
        [FunctionName("SalesOrders")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req, ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            try
            {
                TableSpec tableSpec = new TableSpec(schema: "WebApi", name: "SalesOrders", columnList: "OrderID,OrderDate,CustomerPurchaseOrderNumber,ExpectedDeliveryDate,PickingCompletedWhen,CustomerID,CustomerName,PhoneNumber,FaxNumber,WebsiteURL,DeliveryLocation,SalesPerson,SalesPersonPhone,SalesPersonEmail");
                return await req.OData(tableSpec).GetResult(Environment.GetEnvironmentVariable("SqlDb"));
            }
            catch (Exception ex)
            {
                log.LogError($"C# Http trigger function exception: {ex.Message}");
                return new StatusCodeResult(500);
            }
        }
    }
}
