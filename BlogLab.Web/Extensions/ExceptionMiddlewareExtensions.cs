using BlogLab.Models.Exception;
using Microsoft.AspNetCore.Diagnostics;
using System.Net;

namespace BlogLab.Web.Extensions
{
    public static class ExceptionMiddlewareExtensions
    {
        public static void ConfigureExceptionHandler(this IApplicationBuilder app)
        {
            app.UseExceptionHandler(appError =>
            {
                appError.Run(async context =>
                {
                    context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                    context.Response.ContentType = "application/json";
                    var contextFeature = context.Features.Get<IExceptionHandlerFeature>();
                    if (contextFeature != null)
                    {
                        //In production version you would log exception in your database
                        await context.Response.WriteAsync(new ApiException()
                        {
                            StatusCode = context.Response.StatusCode,
                            Message = "Internal Server Error",
                            // StackTrace = contextFeature.Error.StackTrace -- Exemple that we could add elements to the class if needed
                        }.ToString()); // To string method of ApiException class returns a JSON object see method override
                    }
                });
            });
        }
    }
}
