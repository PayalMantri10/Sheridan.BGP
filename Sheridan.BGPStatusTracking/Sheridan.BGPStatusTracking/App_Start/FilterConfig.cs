using System.Web;
using System.Web.Mvc;

namespace Sheridan.BGPStatusTracking
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
        }
    }
}
