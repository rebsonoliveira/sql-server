using Microsoft.SqlServer.Server;
using System;
using System.Data.SqlTypes;
using System.Net;

/// <summary>
/// Provides CURL-like functionalities in T-SQL code.
/// </summary>
public partial class Curl
{
    [SqlFunction]
    [return: SqlFacet(MaxSize = -1)]
    public static SqlChars Get(SqlChars H, SqlChars url)
    {
        var client = new WebClient();
        if (!H.IsNull)
        {
            var header = H.ToSqlString().Value;
            if (!string.IsNullOrWhiteSpace(header))
                client.Headers.Add(header);
        }
        return new SqlChars(
                client.DownloadString(
                    Uri.EscapeUriString(url.ToSqlString().Value)
                    ).ToCharArray());   
    }

    [SqlProcedure]
    public static void Post(SqlChars H, SqlChars d, SqlChars url)
    {
        var client = new WebClient();
        if (!H.IsNull)
        {
            var header = H.ToSqlString().Value;
            if (!string.IsNullOrWhiteSpace(header))
                client.Headers.Add(header);
        }
        if(d.IsNull)
            throw new ArgumentException("You must specify data that will be sent to the endpoint", "@d");
        var response =
                client.UploadString(
                    Uri.EscapeUriString(url.ToSqlString().Value),
                    d.ToSqlString().Value
                    );
        SqlContext.Pipe.Send(response);
    }
};