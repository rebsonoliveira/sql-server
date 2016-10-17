using Belgrade.SqlClient;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

// For more information on enabling Web API for empty projects, visit http://go.microsoft.com/fwlink/?LinkID=397860

namespace ProductCatalog.Controllers
{
    [Route("api/[controller]")]
    public class CompanyController : Controller
    {
        IQueryPipe sqlQuery = null;

        public CompanyController(IQueryPipe sqlQueryService)
        {
            this.sqlQuery = sqlQueryService;
        }

        // GET api/Company
        [HttpGet]
        public async Task Get()
        {
            await sqlQuery.Stream("select CompanyID as [value], Name as [text] from Company FOR JSON PATH", Response.Body);
        }

        [HttpGet("login")]
        public void Login(string id)
        {
            try
            {
                if(id=="0")
                    ControllerContext.HttpContext.Session.Remove("CompanyID");
                else
                    ControllerContext.HttpContext.Session.SetString("CompanyID", id);
                Response.Redirect("/index.html");
            } catch (Exception ex)
            {
                Response.WriteAsync(ex.Message);
            }
        }
    }
}