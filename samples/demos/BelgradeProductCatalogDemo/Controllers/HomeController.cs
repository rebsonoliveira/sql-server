using Microsoft.AspNetCore.Mvc;
using System;

namespace ProductCatalog.Controllers
{
    public class HomeController : Controller
    {
        [HttpGet]
        public IActionResult Index()
        {
            ViewData["page"] = "index";
            return View();
        }

        public IActionResult Report1()
        {
            ViewData["page"] = "report1";
            return View();
        }

        public IActionResult Report2()
        {
            ViewData["page"] = "report2";
            return View();
        }
    }
}