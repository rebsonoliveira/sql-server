using Belgrade.SqlClient;
using Microsoft.AspNetCore.Mvc;
using System.Collections;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;

// For more information on enabling Web API for empty projects, visit http://go.microsoft.com/fwlink/?LinkID=397860

namespace Catalog.Controllers
{
    [Route("api/[controller]")]
    public class PeopleController : Controller
    {
        IQueryPipe sqlQuery = null;

        public PeopleController(IQueryPipe sqlQueryService)
        {
            this.sqlQuery = sqlQueryService;
        }

        // GET api/Company
        [HttpGet]
        public async Task Get(int draw, int start, int length)
        {
            Hashtable search = new Hashtable();

            int i = 0;
            bool more = true;
            while (more)
            {
                if(Request.Query[$"columns[{i}][search][value]"].Count != 0)
                {
                    search.Add(
                        Request.Query[$"columns[{i}][data]"][0].ToString(),
                        Request.Query[$"columns[{i}][search][value]"][0].ToString());
                    i++;
                } else
                {
                    more = false;
                }
            }

            string orderCol;
            switch (Request.Query["order[0][column]"])
            {
                case "0": orderCol = "name"; break;
                case "1": orderCol = "surname"; break;
                case "2": orderCol = "address"; break;
                case "3": orderCol = "town"; break;
                default: orderCol = "name"; break;
            }

            var orderDir = Request.Query["order[0][dir]"]=="asc"?"asc":"desc";

            var sql = this.GetSearchQuery(search, orderCol, orderDir, start, length);

            var header = System.Text.Encoding.UTF8.GetBytes( @"{
    ""draw"":"+ draw + @",
    ""recordsTotal"": "+ (start+length+1) + @",
    ""recordsFiltered"": " + (start + length + 1) + @",
    ""data"":");
            await Response.Body.WriteAsync(header,0,header.Length);

            await sqlQuery.Stream(sql, Response.Body, "[]");

            await Response.Body.WriteAsync(System.Text.Encoding.UTF8.GetBytes("}"),0,1);
        }

        class SearchEntry
        {
            public string Column;
            public string Data;
            public override string ToString()
            {
                return Column + " LIKE @" + Column;
            }
        }

        private SqlCommand GetSearchQuery(Hashtable search, string orderCol, string orderDir, int start, int length)
        {
            SqlCommand res = new SqlCommand();
            string sql = "select name, surname, address, town from people";
            IList<SearchEntry> l = new List<SearchEntry>(search.Count);
            foreach (DictionaryEntry entry in search)
            {
                if (!string.IsNullOrEmpty(entry.Value.ToString()))
                {
                    l.Add(new SearchEntry { Column = entry.Key.ToString(),
                        Data = entry.Value.ToString()
                    });
                    res.Parameters.AddWithValue(entry.Key.ToString(), "%" + entry.Value.ToString() + "%");
                }
            }

            if (l.Count > 0) { 
                var predicate = string.Join(" and ", l as IEnumerable<SearchEntry>);
                sql += " where " + predicate;
            }
            if (!string.IsNullOrEmpty(orderCol))
            {
                sql += " order by " + orderCol + " " + orderDir;
            }
            else
            {
                sql += " order by name ";
            }
            sql += string.Format(" OFFSET {0} ROWS FETCH NEXT {1} ROWS ONLY ", start, length);

            res.CommandText = sql + " for json path";

            return res;
        }
        
        // GET api/Company
        [HttpGet("Load")]
        public async Task Load()
        {
            await sqlQuery.Stream("select name, surname, address, town from people for json path, root('data')", Response.Body, @"{""data"":[]");
        }

    }
}