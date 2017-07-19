using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Routing;

namespace Sheridan.BGPStatusTracking
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {
            // Web API routes
            config.MapHttpAttributeRoutes();
            config.Routes.MapHttpRoute(
                     name: "API Default",
                     routeTemplate: "api/{controller}/{id}",
                     defaults: new { id = RouteParameter.Optional }
                 );

            //// Web API configuration and services           
            //config.Routes.MapHttpRoute("DefaultApiWithActionAndId", "Api/{controller}/{action}/{id}",
            //    new { id = RouteParameter.Optional }, new { id = @"\d+" });
         
            //config.Routes.MapHttpRoute("DefaultApiWithDefaultActionGetAndId", "Api/{controller}/{id}", 
            //    new { action = "Get", id = RouteParameter.Optional }, new { httpMethod = new HttpMethodConstraint(HttpMethod.Get), id = @"\d+" });

            ////config.Routes.MapHttpRoute("DefaultApiWithDefaultActionPostAndId", "Api/{controller}/{id}",
            ////    new { action = "Post", id = RouteParameter.Optional }, new { httpMethod = new HttpMethodConstraint(HttpMethod.Get), id = @"\d+" });

            //config.Routes.MapHttpRoute("DefaultApiWithActionNoId", "Api/{controller}/{action}");       
     
            //config.Routes.MapHttpRoute("DefaultApiDefaultActionGetNoId", "Api/{controller}", 
            //    new { action = "Get" }, new { httpMethod = new HttpMethodConstraint(HttpMethod.Get) });

            ////config.Routes.MapHttpRoute("DefaultApiDefaultActionPostNoId", "Api/{controller}",
            ////    new { action = "Post" }, new { httpMethod = new HttpMethodConstraint(HttpMethod.Post) });
           
        }
    }
}
