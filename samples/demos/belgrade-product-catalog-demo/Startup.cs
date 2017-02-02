using Belgrade.SqlClient;
using Belgrade.SqlClient.SqlDb;
using Belgrade.SqlClient.SqlDb.Rls;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System;
using System.Data.SqlClient;
using System.Linq;

namespace ProductCatalog
{
    public class Startup
    {
        public Startup(IHostingEnvironment env)
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(env.ContentRootPath)
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
                .AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true)
                .AddEnvironmentVariables();
            Configuration = builder.Build();
        }

        public IConfigurationRoot Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            //string ConnString = Configuration.GetConnectionString("BelgradeDemo");
            string ConnString = Configuration["ConnectionStrings:BelgradeDemo"];
            
            // Adding data access services/components.
            services.AddTransient<IQueryPipe>(
                sp =>
                {
                    return new QueryPipeSessionContextAdapter(
                        new QueryPipe(new SqlConnection(ConnString)),
                        "CompanyID",
                        () => GetCompanyIdFromSession(sp));
                });

            services.AddTransient<ICommand>(
                sp =>
                {
                    return new CommandSessionContextAdapter(
                        new Command(new SqlConnection(ConnString)),
                        "CompanyID",
                        () => GetCompanyIdFromSession(sp));
                });

            // Add framework services.
            services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();
            services.AddSession();
            services.AddMvc();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env, ILoggerFactory loggerFactory)
        {
            loggerFactory.AddConsole(Configuration.GetSection("Logging"));
            loggerFactory.AddDebug();

            app.UseSession();
            app.UseMvc();
            app.UseStaticFiles();
        }

        /// <summary>
        /// Utility method that takes CompanyID from HttpSession.
        /// You need to add: services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();
        /// </summary>
        /// <param name="serviceProvider">IServiceProvider interface.</param>
        /// <returns>Session value</returns>
        private static string GetCompanyIdFromSession(IServiceProvider serviceProvider)
        {
            var session = serviceProvider.GetServices<IHttpContextAccessor>().First().HttpContext.Session;
            return session.GetString("CompanyID") ?? "-1";
        }
    }
}
