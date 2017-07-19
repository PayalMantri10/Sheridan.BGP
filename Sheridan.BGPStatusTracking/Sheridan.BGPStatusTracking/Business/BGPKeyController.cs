using Sheridan.SMART.Business.BGPStatus;
using Sheridan.SMART.Common.DataTransferObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Script.Serialization;

namespace Sheridan.BGPStatusTracking.Controllers
{
    public class BGPKeyController 
    {
        IBGPStatusBC bc = new BGPStatusBC();
        public string Get( string startDate = "", string endDate = "")
        {

            DateTime StartDate = new DateTime(1754, 1, 1);
            DateTime EndDate = DateTime.Now;
            if (startDate != "")
                StartDate = Convert.ToDateTime(startDate);
            if (endDate != "")
                EndDate = Convert.ToDateTime(endDate);
            BGPRunStatusInput input = new BGPRunStatusInput { RunStartDate = StartDate, RunEndDate = EndDate };
            List<BGPRunStatus> list = bc.GetBGPStatusList(input);
            var json = BGPRunStatusListToKeyList(list);
            return json;

        }

        private static string BGPRunStatusListToKeyList(List<BGPRunStatus> list)
        {
            string DataString;
            List<string> BGPKeyList = new List<string>();
            foreach(var r in list)
            {
                BGPKeyList.Add(r.BGPName);
            }
            BGPKeyList = BGPKeyList.Distinct().ToList();

            DataString= "[";

            foreach (var r in BGPKeyList.OrderByDescending(p=>p).Reverse())
            {
                DataString += "{\"label\":\"" + r + "\"},";
            }

            JavaScriptSerializer j = new JavaScriptSerializer();
            DataString = DataString.Remove(DataString.Length - 1) + "]";

            return DataString;

        }
       

        public class category
        {
            public int label { get; set; }
        }

    }
}