using Microsoft.AspNetCore.Mvc;
using ProductCatalog.Models;
using System;
using System.Linq;

namespace ProductCatalog.Controllers
{
    public class ProductCatalogController : Controller
    {
        private ProductCatalogContext _context;

        public ProductCatalogController (ProductCatalogContext context)
        {
            _context = context;
        }

        [HttpGet]
        public IActionResult Index()
        {
            ViewData["page"] = "index";
            return View(_context.Products.AsEnumerable());
        }

        // POST api/ProductCatalog/Add
        public IActionResult Add(Product p)
        {
            try
            {
                _context.Products.Add(p);
                _context.SaveChanges();
                return Redirect("/ProductCatalog/Index");
            } catch (Exception)
            {
                return Redirect("/ProductCatalog/Index");
            }
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