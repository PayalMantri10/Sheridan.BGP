using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(Sheridan.BGPStatusTracking.Startup))]
namespace Sheridan.BGPStatusTracking
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
