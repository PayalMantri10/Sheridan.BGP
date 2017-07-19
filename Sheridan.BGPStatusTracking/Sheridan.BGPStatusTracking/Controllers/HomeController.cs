using Sheridan.BGPStatusTracking.Business;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Sheridan.BGPStatusTracking.Controllers
{
    public class HomeController : Controller
    {
        BGPStatusController bc = new BGPStatusController();
        BGPKeyController BGPkey = new BGPKeyController();
        BGP_GroupBC groupbc = new BGP_GroupBC();
        public ActionResult Index()
        {
            return View();
        }
        public ActionResult About()
        {
            return View();
        }
        public ActionResult Contact()
        {
            return View();
        }

        [HttpGet]
        public string GetBGPRunStatus(string Browser, string BGPName, string startDate = "", String EndDate = "")
        {
              var json = bc.Get(Browser, BGPName, startDate, EndDate);
            return json;
        }

        [HttpGet]
        public string GetBGP()
        {
            var json = bc.GetList();
            return json;
        }
        [HttpGet]
        public string Getlist()
        {
            var json = BGPkey.Get();
            return json;
        }

        [HttpGet]
        public string GetBGPStatusIE8(string BGPName, string startDate = "", String EndDate = "")
        {
            var json = bc.Get(BGPName,startDate, EndDate);
            return json;
        }

        [HttpGet]
        public string GetBGPGroupList()
        {
            var json=groupbc.GetBGPGroup(); 
            return json;
        }
        [HttpGet]
        public string GetDataforComparisonTable(String BGPList,string Interval, string Browser)
        {
          
            var json = groupbc.GetDataforComaprisonTable(BGPList, Interval, Browser);
            return json;
        }


    }
}