using Belgrade.SqlClient;
using Microsoft.AspNetCore.Mvc;
using SqlServerRestApi;
using System;
using System.Text;
using System.Threading.Tasks;

// For more information on enabling Web API for empty projects, visit http://go.microsoft.com/fwlink/?LinkID=397860
namespace Register.Controllers
{
    [Route("api/[controller]")]
    public class ODataController : Controller
    {
        IQueryPipe pipe = null;
        TableSpec tableSpec = new TableSpec("dbo", "People")
            .AddColumn("id", "int", isKeyColumn: true)
            .AddColumn("name","nvarchar")
            .AddColumn("surname","nvarchar")
            .AddColumn("address", "nvarchar")
            .AddColumn("town", "nvarchar");


        public string ODataMetadataUrl
        {
            get
            {
                return this.Request.Scheme + "://" + this.Request.Host + "/api/odata";
            }
        }

        public ODataController(IQueryPipe sqlQueryService)
        {
            this.pipe = sqlQueryService;
        }

        [Produces("application/json; odata.metadata=minimal")]
        [HttpGet]
        public string Get()
        {
            try
            {
                return ODataHandler.GetRootMetadataJsonV4(ODataMetadataUrl, new TableSpec[] { tableSpec });
            } catch (Exception ex)
            {
                return ex.Message;
            }
        }


        [Produces("application/xml")]
        [HttpGet("$metadata")]
        public string Metadata()
        {
            try { 
            return ODataHandler.GetMetadataXmlV4(new TableSpec[] { tableSpec }, "Demo.Models");
            } catch (Exception ex)
            {
                return ex.Message;
            }
        }

        // GET api/odata/People
        [HttpGet("People")]
        public async Task People()
        {
            await this
                .ODataHandler(tableSpec, this.pipe, ODataHandler.Metadata.MINIMAL)
                .OnError(ex => Response.Body.Write(Encoding.UTF8.GetBytes(ex.Message), 0, (ex.Message).Length))
                .Get();
        }

        // GET api/odata/People/$count
        [HttpGet("People/$count")]
        public Task PeopleCount()
        {
            return this.People();
        }

        /// <summary>
        /// Endpoint that exposes People information using OData protocol.
        /// </summary>
        /// <returns>OData response.</returns>
        // GET api/OData/People
        [HttpGet("Product")]
        public async Task OData()
        {
            Response.ContentType = "application/json;odata.metadata=minimal;odata=minimalmetadata";
            //var body = Encoding.UTF8.GetBytes(@"{""@odata.context"":""http://localhost:59934/api/odata/$metadata#Product"",""value"":[{""id"":1,""name"":""Test""}]}");

            //await Response.Body.WriteAsync(body, 0, body.Length);

            await this
                    .ODataHandler(tableSpec, pipe)
                    .Get();
        }



        /// <summary>
        /// Method that process server-side processing JQuery DataTables HTTP request
        /// and returns data that should be shown.
        /// </summary>
        /// <returns></returns>
        // GET api/People
        //[HttpGet]
        public string GetOld()
        {
            //Response.ContentType = "application/json;odata=minimalmetadata;streaming=true;charset=utf-8";

            //return "{\"odata.metadata\":\"http://services.odata.org/V3/Northwind/Northwind.svc/$metadata\",\"value\":[{\"name\":\"People\",\"url\":\"People\"}]}";
            //Response.ContentType = "application/json;odata=nometadata;streaming=true;charset=utf-8";
            //return  "{\"odata.metadata\":\"http://services.odata.org/V3/Northwind/Northwind.svc/$metadata\",\"value\":[{\"name\":\"People\",\"url\":\"People\"}]}";
            
            // radi:
            //Response.ContentType = "application/xml;charset=utf-8";
            //return @"<?xml version=""1.0"" encoding=""utf-8""?><service xml:base=""http://services.odata.org/V3/Northwind/Northwind.svc/"" xmlns=""http://www.w3.org/2007/app"" xmlns:atom=""http://www.w3.org/2005/Atom""><workspace><atom:title>Default</atom:title><collection href=""Categories""><atom:title>Categories</atom:title></collection><collection href=""CustomerDemographics""><atom:title>CustomerDemographics</atom:title></collection><collection href=""Customers""><atom:title>Customers</atom:title></collection><collection href=""Employees""><atom:title>Employees</atom:title></collection><collection href=""Order_Details""><atom:title>Order_Details</atom:title></collection><collection href=""Orders""><atom:title>Orders</atom:title></collection><collection href=""Products""><atom:title>Products</atom:title></collection><collection href=""Regions""><atom:title>Regions</atom:title></collection><collection href=""Shippers""><atom:title>Shippers</atom:title></collection><collection href=""Suppliers""><atom:title>Suppliers</atom:title></collection><collection href=""Territories""><atom:title>Territories</atom:title></collection><collection href=""Alphabetical_list_of_products""><atom:title>Alphabetical_list_of_products</atom:title></collection><collection href=""Category_Sales_for_1997""><atom:title>Category_Sales_for_1997</atom:title></collection><collection href=""Current_Product_Lists""><atom:title>Current_Product_Lists</atom:title></collection><collection href=""Customer_and_Suppliers_by_Cities""><atom:title>Customer_and_Suppliers_by_Cities</atom:title></collection><collection href=""Invoices""><atom:title>Invoices</atom:title></collection><collection href=""Order_Details_Extendeds""><atom:title>Order_Details_Extendeds</atom:title></collection><collection href=""Order_Subtotals""><atom:title>Order_Subtotals</atom:title></collection><collection href=""Orders_Qries""><atom:title>Orders_Qries</atom:title></collection><collection href=""Product_Sales_for_1997""><atom:title>Product_Sales_for_1997</atom:title></collection><collection href=""Products_Above_Average_Prices""><atom:title>Products_Above_Average_Prices</atom:title></collection><collection href=""Products_by_Categories""><atom:title>Products_by_Categories</atom:title></collection><collection href=""Sales_by_Categories""><atom:title>Sales_by_Categories</atom:title></collection><collection href=""Sales_Totals_by_Amounts""><atom:title>Sales_Totals_by_Amounts</atom:title></collection><collection href=""Summary_of_Sales_by_Quarters""><atom:title>Summary_of_Sales_by_Quarters</atom:title></collection><collection href=""Summary_of_Sales_by_Years""><atom:title>Summary_of_Sales_by_Years</atom:title></collection></workspace></service>";

            Response.ContentType = "application/xml;charset=utf-8";
            return @"<?xml version=""1.0"" encoding=""utf-8""?><service xml:base=""http://localhost:59934/api/odata"" xmlns=""http://www.w3.org/2007/app"" xmlns:atom=""http://www.w3.org/2005/Atom""><workspace><atom:title>Default</atom:title><collection href=""Product""><atom:title>Product</atom:title></collection></workspace></service>";
        }

        //[HttpGet("$metadata")]
        //public string Metadata1()
        //{
        //    Response.ContentType = "application/xml;charset=utf-8";
            
        //    return ODataMetaData(this.tableSpec, "Models", "Product");
            
        //}


        [HttpGet("$metadata2")]
        public string Metadata2()
        {
            //Response.ContentType = "application/json;odata=minimalmetadata;streaming=true;charset=utf-8";

            //return "{\"odata.metadata\":\"http://services.odata.org/V3/Northwind/Northwind.svc/$metadata\",\"value\":[{\"name\":\"People\",\"url\":\"People\"}]}";
            //Response.ContentType = "application/json;odata=minimalmetadata;streaming=true;charset=utf-8";
            //return "{\"odata.metadata\":\"http://services.odata.org/V3/Northwind/Northwind.svc/$metadata\",\"value\":[{\"name\":\"Categories\",\"url\":\"Categories\"}]}";
            Response.ContentType = "application/xml;charset=utf-8";

            //var wc = new System.Net.WebRequest();

            
            return @"<?xml version=""1.0"" encoding=""utf-8""?>
            <edmx:Edmx Version=""4.0"" xmlns:edmx=""http://docs.oasis-open.org/odata/ns/edmx"">
              <edmx:DataServices>
                <Schema Namespace=""Models"" xmlns=""http://docs.oasis-open.org/odata/ns/edm"">
                  <EntityType Name=""Product"">
                    <Key>
                        <PropertyRef Name=""id""/>
                    </Key>
                    <Property Name=""id"" Type=""Edm.Int32""/>
                    <Property Name=""name"" Type=""Edm.String"" />
                  </EntityType>
                </Schema>
                <Schema Namespace=""ODataDemo"" xmlns=""http://docs.oasis-open.org/odata/ns/edm"">
                    <EntityContainer Name=""DefaultContainer"">
                        <EntitySet Name=""Product"" EntityType=""Models.Product"" />
                    </EntityContainer>
                </Schema>
              </edmx:DataServices>
            </edmx:Edmx>";
        }


        private string SqlTypeToDemType(string sqlType)
        {
            switch (sqlType)
            {
                case "bigint": return "Edm.Int64";
                case "binary": return "Edm.Byte[]";
                case "bit": return "Edm.Boolean";
                case "char": return "Edm.String";
                case "date": return "Edm.DateTime";
                case "datetime": return "Edm.DateTime";
                case "datetime2": return "Edm.DateTime";
                case "datetimeoffset": return "Edm.DateTimeOffset";
                case "decimal": return "Edm.Decimal";
                case "float": return "Edm.Double";
                case "image": return "Edm.Byte[]";
                case "int": return "Edm.Int32";
                case "money": return "Edm.Decimal";
                case "nchar": return "Edm.String";
                case "ntext": return "Edm.String";
                case "numeric": return "Edm.Decimal";
                case "nvarchar": return "Edm.String";
                case "real": return "Edm.Single";
                case "rowversion": return "Edm.Byte[]";
                case "smalldatetime": return "Edm.DateTime";
                case "smallint": return "Edm.Int16";
                case "smallmoney": return "Edm.Decimal";
                case "sql_variant": return "Edm.Object";
                case "text": return "Edm.String";
                case "time": return "Edm.TimeSpan";
                case "timestamp": return "Edm.Byte[]";
                case "tinyint": return "Edm.Byte";
                case "uniqueidentifier": return "Edm.Guid";
                case "varbinary": return "Edm.Byte[]";
                case "varchar": return "Edm.String";
                case "xml": return "Edm.Xml";
                default: throw new ArgumentException("Unsupported type", "sqlType");
            }
        }

        private string ODataMetaData(TableSpec spec, string Namespace, string EntityName)
        {
            var metadata = new StringBuilder();
            metadata
                .AppendFormat(@"<?xml version=""1.0"" encoding=""utf-8""?>
            <edmx:Edmx Version=""4.0"" xmlns:edmx=""http://docs.oasis-open.org/odata/ns/edmx"">
              <edmx:DataServices>
                <Schema Namespace=""{0}"" xmlns=""http://docs.oasis-open.org/odata/ns/edm"">", Namespace)
                .AppendFormat(@"<EntityType Name=""{0}"">", EntityName);
            for(int i = 0; i< spec.columns.Count; i++)
            {
                if(i == 0)
                    metadata.AppendFormat(@"<Key><PropertyRef Name=""{0}""/></Key>", spec.columns[0]);
                metadata.AppendFormat(@"<Property Name=""{0}"" Type=""{1}""/>", spec.columns[i], "Edm.Int32");
            }

            metadata
                .AppendFormat(@"</EntityType>")
                //.Append("</Schema>")
                //.AppendFormat(@"<Schema Namespace=""{0}"" xmlns=""http://docs.oasis-open.org/odata/ns/edm"">")
                .AppendFormat(@"
                    <EntityContainer Name=""{0}"">
                        <EntitySet Name=""{1}"" EntityType=""{2}"" />
                    </EntityContainer>
                </Schema>", "DefaultContainer", EntityName, "Models.Product")
                .AppendFormat(@"
                </edmx:DataServices>
            </edmx:Edmx>");

            return metadata.ToString();
        }
    }
}