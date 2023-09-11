using BlogLab.Identity;
using BlogLab.Models.Account;
using BlogLab.Models.Settings;
using BlogLab.Repository;
using BlogLab.Services;
using BlogLab.Web.Extensions;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Text;

namespace BlogLab.Web
{
    public class Startup
    {
        #region Constructor
        public IConfiguration Configuration { get; }
        public Startup(IConfiguration config)
        {
            JwtSecurityTokenHandler.DefaultInboundClaimTypeMap.Clear();
            Configuration = config;
        }
        #endregion

        #region Configure Services
        public void ConfigureServices(IServiceCollection services)
        {
            services.Configure<CloudinaryOptions>(Configuration.GetSection("CloudinaryOptions"));
            
            services.AddScoped<ITokenService,TokenService>();
            services.AddScoped<IPhotoService, PhotoService>();

            services.AddScoped<IBlogRepository, BlogRepository>();
            services.AddScoped<IBlogCommentRepository, BlogCommentRepository>();
            services.AddScoped<IAccountRepository, AccountRepository>();
            services.AddScoped<IPhotoRepository, PhotoRepository>();

            services.AddIdentityCore<ApplicationUserIdentity>(opt =>
            {
                opt.Password.RequireNonAlphanumeric = false;

            })
                .AddUserStore<UserStore>()
                .AddDefaultTokenProviders()
                .AddSignInManager<SignInManager<ApplicationUserIdentity>>();
            
            services.AddControllers();
            services.AddCors();

            services.AddAuthentication(options => 
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme= JwtBearerDefaults.AuthenticationScheme;
            })
                .AddJwtBearer
                (
                    options =>
                    {
                        options.RequireHttpsMetadata = false;
                        options.SaveToken = true;
                        options.TokenValidationParameters = new TokenValidationParameters
                        {
                            ValidateIssuer = true,
                            ValidateAudience = true,
                            ValidateLifetime = true,
                            ValidateIssuerSigningKey = true,
                            ValidIssuer = Configuration["Jwt:Issuer"],
                            ValidAudience = Configuration["Jwt:Issuer"],
                            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Configuration["Jwt:Key"])),
                            ClockSkew = TimeSpan.Zero
                        };
                    }
                );
            /*
             3 ways to add services
                services.AddScoped<IPhotoService, PhotoService>(); same whithin a request but different at other request
                services.AddTransient<ITokenService, TokenService>(); object are always different
                services.AddSingleton<ITokenService, TokenService>(); same for every object and every request
            rules of thumb AddScoped 
            When ever we use ITokenService that would come to our startup class
             */
        }

        #endregion

        #region Configure / midleware
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            app.ConfigureExceptionHandler();

            app.UseRouting();

            if (env.IsDevelopment())
            {
                app.UseCors(options => options.AllowAnyHeader().AllowAnyMethod().AllowAnyOrigin() );
            }
            else
            {
                app.UseCors();
            }

            app.UseAuthentication();
            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });

        }

        #endregion


    }
}
