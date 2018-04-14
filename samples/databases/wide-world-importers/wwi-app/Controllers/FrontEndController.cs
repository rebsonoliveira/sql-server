using Belgrade.SqlClient;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Data;
using System.Security.Claims;
using System.Threading.Tasks;

namespace wwi_app.Controllers
{
    public class FrontEndController : Controller
    {
        private readonly ICommand queryService;
        private readonly ILogger _logger;

        public FrontEndController(ICommand queryService, ILogger<FrontEndController> logger)
        {
            this.queryService = queryService;
            this._logger = logger;
        }

        [ResponseCache(Duration = 60)]
        public IActionResult Index() { return View(); }

        [ResponseCache(Duration = 60)]
        public IActionResult Offers() { return View(); }

        [ResponseCache(Duration = 60)]
        public IActionResult Contact() { return View(); }

        [Authorize]
        public IActionResult BuyingGroups() { return View(); }

        [Authorize]
        public IActionResult Cities() { return View(); }

        [Authorize]
        public IActionResult Colors() { return View(); }

        [Authorize]
        public IActionResult Countries() { return View(); }

        [Authorize]
        public IActionResult CustomerCategories() { return View(); }

        [Authorize]
        public IActionResult Customers() { return View(); }

        [Authorize]
        public IActionResult CustomerTransactions() { return View(); }

        [Authorize]
        public IActionResult Dashboard() { return View(); }

        [Authorize]
        public IActionResult Deals() { return View(); }

        [Authorize]
        public IActionResult DeliveryMethods() { return View(); }

        [Authorize]
        public IActionResult Invoices() { return View(); }

        [Authorize]
        public IActionResult PackageTypes() { return View(); }

        [Authorize]
        public IActionResult PaymentMethods() { return View(); }

        [Authorize]
        public IActionResult PurchaseOrders() { return View(); }

        [Authorize]
        public IActionResult SalesOrders() { return View(); }

        [Authorize]
        public IActionResult StateProvinces() { return View(); }

        [Authorize]
        public IActionResult StockGroups() { return View(); }

        [Authorize]
        public IActionResult StockItems() { return View(); }

        [Authorize]
        public IActionResult SupplierCategories() { return View(); }

        [Authorize]
        public IActionResult Suppliers() { return View(); }

        [Authorize]
        public IActionResult SupplierTransactions() { return View(); }

        [Authorize]
        public IActionResult TransactionTypes() { return View(); }
        
        public async Task<IActionResult> Login(string username, string password)
        {
            if(string.IsNullOrEmpty(username))
            {
                return Redirect("~/Index");
            }

            bool isValidUser = false;
            var claims = new List<Claim>() { new Claim(ClaimTypes.Email, username) };

            await queryService
                .Sql("EXEC WebApi.Login @LogonName, @Password")
                .Param("LogonName", DbType.String, username, 256)
                .Param("Password", DbType.String, password, 256)
                .OnError(e => _logger.LogError(e, "Cannot login user:" + username))
                .Map(r => {
                    isValidUser = true;
                    claims.Add(new Claim(ClaimTypes.Sid, Convert.ToString(r["PersonID"])));
                    claims.Add(new Claim(ClaimTypes.Name, Convert.ToString(r["PreferredName"])));
                    if (Convert.ToBoolean(r["IsSalesperson"]))
                        claims.Add(new Claim(ClaimTypes.Role, "Salesperson"));
                    if (Convert.ToBoolean(r["IsEmployee"]))
                        claims.Add(new Claim(ClaimTypes.Role, "Employee"));
                    if (r["Territory"] != null)
                        claims.Add(new Claim("Territory", r["Territory"].ToString()));
                }
            );

            if (isValidUser)
            {
                var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
                await HttpContext.SignInAsync(new ClaimsPrincipal(claimsIdentity));
                return Redirect("~/Dashboard");
            } else
            {
                _logger.LogWarning("Cannot login user: " + username);
            }
            return Redirect("~/Index");
        }

        public async Task<IActionResult> SignOut()
        {
            await HttpContext.SignOutAsync();
            return Redirect("~/Index");
        }

        public async Task Search(string name, string tag, double? minPrice, double? maxPrice, int? stockItemGroup, int top)
        {
            await queryService
                .Sql("EXEC WebApi.SearchForStockItems @Name, @Tag, @MinPrice, @MaxPrice, @StockGroupID, @MaximumRowsToReturn")
                .Param("Name", DbType.String, name, 100)
                .Param("Tag", DbType.String, tag, 100)
                .Param("MinPrice", DbType.Decimal, minPrice)
                .Param("MaxPrice", DbType.Decimal, maxPrice)
                .Param("StockGroupID", DbType.Int32, stockItemGroup)
                .Param("MaximumRowsToReturn", DbType.Int32, 20)
                .Stream(Response.Body, "{\"value\":[]}");
        }
    }
}
