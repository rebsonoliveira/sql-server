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
    public static class Suppliers
    {
        [FunctionName("Suppliers")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req, ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            try
            {
                TableSpec suppliers = new TableSpec("WebApi", "Suppliers", "SupplierID,SupplierName,SupplierCategoryName,PrimaryContact,AlternateContact,PhoneNumber,FaxNumber,WebsiteURL,SupplierReference,DeliveryLocation,BankAccountName,BankAccountBranch,BankAccountCode,BankAccountNumber,BankInternationalCode,PostalAddressLine1,PostalAddressLine2,PostalPostalCode,PaymentDays,SupplierCategoryID");
                return await req.OData(suppliers).GetResult(Environment.GetEnvironmentVariable("SqlDb"));
            }
            catch (Exception ex)
            {
                log.LogError($"C# Http trigger function exception: {ex.Message}");
                return new StatusCodeResult(500);
            }
        }
    }
}
