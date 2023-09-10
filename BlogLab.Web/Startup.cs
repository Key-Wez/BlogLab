using BlogLab.Models.Settings;

namespace BlogLab.Web
{
    public class Startup
    {

        public IConfiguration Configuration { get; }
        public Startup(IConfiguration config)
        {
            Configuration = config;
        }

        public void ConfigureServices(IServiceCollection services)
        {
            services.Configure<CloudinaryOptions>(Configuration.GetSection("CloudinaryOptions"));

        }


    }
}
