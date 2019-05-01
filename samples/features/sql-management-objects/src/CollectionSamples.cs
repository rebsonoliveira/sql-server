
using System.Diagnostics;
using Microsoft.SqlServer.Management.Smo;

namespace Microsoft.SqlServer.SmoSamples
{
    using System;
    using System.Collections.Generic;
    using System.Text;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using NUnit.Framework;
    using Assert = NUnit.Framework.Assert;

    [TestClass]
    public class CollectionSamples
    {
        public VisualStudio.TestTools.UnitTesting.TestContext TestContext { get; set; }

        [TestMethod]
        public void Collection_iteration_is_faster_with_SetDefaultInitFields()
        {
            using (var connectionMetrics = ConnectionMetrics.SetupMeasuredConnection(TestContext, 50))
            {
                var server = new Management.Smo.Server(connectionMetrics.ServerConnection);
                var database = server.Databases[TestContext.GetTestDatabaseName()];
                connectionMetrics.Reset();
                foreach (Table table in database.Tables)
                {
                    Trace.TraceInformation(
                        $"Unoptimized table Name: {table.Name}\tSchema:{table.Schema}\tFileGroup:{table.FileGroup}");
                }

                var unoptimizedMetrics = (connectionMetrics.QueryCount, connectionMetrics.BytesSent, connectionMetrics.BytesRead, connectionMetrics.ConnectionCount);
                Trace.TraceInformation(string.Join($"{Environment.NewLine}\t", new[]
                {
                    "Unoptimized metrics:",
                    $"QueryCount:{unoptimizedMetrics.QueryCount}", $"ConnectionCount:{unoptimizedMetrics.ConnectionCount}",
                    $"BytesSent:{unoptimizedMetrics.BytesSent}", $"BytesRead:{unoptimizedMetrics.BytesRead}"
                }));
                
                connectionMetrics.Reset();
                server.SetDefaultInitFields(typeof(Table), "Name", "Schema", "FileGroup");
                database.Tables.Refresh();
                foreach (Table table in database.Tables)
                {
                    Trace.TraceInformation(
                        $"Optimized table Name: {table.Name}\tSchema:{table.Schema}\tFileGroup:{table.FileGroup}");
                }

                var optimizedMetrics = (connectionMetrics.QueryCount, connectionMetrics.BytesSent, connectionMetrics.BytesRead, connectionMetrics.ConnectionCount);
                Trace.TraceInformation(string.Join($"{Environment.NewLine}\t", new[]
                {
                    "Optimized Metrics:",
                    $"QueryCount:{optimizedMetrics.QueryCount}", $"ConnectionCount:{optimizedMetrics.ConnectionCount}",
                    $"BytesSent:{optimizedMetrics.BytesSent}", $"BytesRead:{optimizedMetrics.BytesRead}"
                }));
                Assert.That(optimizedMetrics.BytesRead, Is.LessThan(unoptimizedMetrics.BytesRead), "BytesRead");
                Assert.That(optimizedMetrics.BytesSent, Is.LessThan(unoptimizedMetrics.BytesSent), "BytesSent");
                Assert.That(optimizedMetrics.ConnectionCount, Is.AtMost(unoptimizedMetrics.ConnectionCount), "ConnectionCount");
                Assert.That(optimizedMetrics.QueryCount, Is.LessThan(unoptimizedMetrics.QueryCount), "QueryCount");
            }
        }
    }
}
