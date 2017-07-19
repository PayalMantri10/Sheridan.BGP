using Newtonsoft.Json;
using Sheridan.SMART.Business.BGPStatus;
using Sheridan.SMART.Common.DataTransferObjects;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web.Http;
using System.Web.Script.Serialization;

namespace Sheridan.BGPStatusTracking.Controllers
{

    public class BGPStatusController
    {
        IBGPStatusBC bc = new BGPStatusBC();

        // GET api/bgpstatus
        public string Get(string BGPName, string startDate = "", string endDate = "")
        {
            DateTime StartDate = new DateTime(1754, 1, 1);
            DateTime EndDate = DateTime.Now;
            if (startDate != "")
                StartDate = Convert.ToDateTime(startDate, new DateTimeFormatInfo { FullDateTimePattern = "MM-dd-yyyy" });
            if (endDate != "")
                EndDate = Convert.ToDateTime(endDate,new DateTimeFormatInfo { FullDateTimePattern = "MM-dd-yyyy" });
            BGPRunStatusInput input = new BGPRunStatusInput { BGPName=BGPName, RunEndDate = EndDate, RunStartDate = StartDate };
            List<BGPRunStatus> list = bc.GetBGPRunStatus(input);
            return BGPRunStatusListToJson(list);
        }

        public String GetList()
        {
            DateTime StartDate = new DateTime(1754, 1, 1);
            DateTime EndDate = DateTime.Now;
          
            BGPRunStatusInput input = new BGPRunStatusInput { RunEndDate = EndDate, RunStartDate = StartDate };
            List<BGPRunStatus> list = bc.GetBGPRunStatusforall(input);
            var json = BGPRunStatusListToJsonGoogle(list);
            var s = new JavaScriptSerializer();
            var sb = new StringBuilder();
            s.Serialize(list, sb);
            string aabc = sb.ToString();
            return aabc;

        }


        // GET api/bgpstatis? Browser = abc ? id = 0
        public string Get( string Browser, string BGPName, String startDate="", String endDate="")
        {
            DateTime StartDate = new DateTime(1754, 1, 1);
            DateTime EndDate = DateTime.Now;
            if (startDate!= "")
                StartDate = Convert.ToDateTime(startDate, new DateTimeFormatInfo { FullDateTimePattern = "MM-dd-yyyy" });
            if(endDate!="")
            EndDate = Convert.ToDateTime(endDate, new DateTimeFormatInfo { FullDateTimePattern = "MM-dd-yyyy" });
            BGPRunStatusInput input = new BGPRunStatusInput {BGPName=BGPName,RunEndDate=EndDate, RunStartDate=StartDate};
            List<BGPRunStatus> list = bc.GetBGPRunStatus(input);
            var json = BGPRunStatusListToJsonGoogle(list);
            return json;

        }


        // GET api/bgpstatus/5
        public string Get( int id)
        {
            BGPRunStatusInput input = new BGPRunStatusInput() { BGPKey = id };
            List<BGPRunStatus> list = bc.GetBGPStatusList(input);
            var json = BGPRunStatusListToJson(list);
            return json;
            //return BGPRunStatusListToJsonGoogle(list);
        }

        // POST api/bgpstatus
        public void Post([FromBody]string value)
        {
          
        }

        // PUT api/bgpstatus/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/bgpstatus/5
        public void Delete(int id)
        {
        }

       
        private static string BGPRunStatusListToJson(List<BGPRunStatus> list)
        {
            string[] DataString = new string[3];
            DataString[0] += "[";
            DataString[1] += "[";
            DataString[2] += "[";
            foreach (var r in list.OrderByDescending(p => p.RunEndDate).Take(10).Reverse())
            {
                DataString[0] += "{\"label\":\"" + r.RunEndDate.ToString("HH:mm:ss") + "\"},";
                DataString[1] += "{\"value\":" + r.NoOfEncountersProcessed + "},";
                DataString[2] += "{\"value\":" + r.NoOfEncountersSucceded + "},";
            }
            DataString[0] = DataString[0].Remove(DataString[0].Length - 1)+"]";
            DataString[1] = DataString[1].Remove(DataString[1].Length - 1) + "]";
            DataString[2] = DataString[2].Remove(DataString[2].Length - 1)+"]";

            string JsonObj= "{\"Category\":" + DataString[0] + ",\"dataset1\":" + DataString[1] + ",\"dataset2\":" + DataString[2]+"}";
      
            return JsonObj ;

        }

        public static string BGPRunStatusListComparisonIE8(List<BGPRunStatus> list)
        {
            string[] DataString = new string[3];
              DataString[0] += "[";
            DataString[1] += "[";
            DataString[2] += "[";
            foreach (var r in list.OrderByDescending(p => p.RunEndDate).Take(10).Reverse())
            {
                  DataString[0] += "{\"label\":\"" + r.BGPName + "\"},";
                DataString[1] += "{\"value\":" + r.NoOfEncountersProcessed + "},";
                DataString[2] += "{\"value\":" + r.NoOfEncountersSucceded + "},";
            }
            DataString[0] = DataString[0].Remove(DataString[0].Length - 1) + "]";
            DataString[1] = DataString[1].Remove(DataString[1].Length - 1) + "]";
            DataString[2] = DataString[2].Remove(DataString[2].Length - 1) + "]";

            string JsonObj = "{\"Category\":" + DataString[0] + ",\"dataset1\":" + DataString[1] + ",\"dataset2\":" + DataString[2] + "}";

            return JsonObj;

        }

        public class category
        {
            public string label { get; set; }
        } 
        public class ValueIE8
        {
            public object value { get; set; }
        }


       public static string BGPRunStatusListToJsonGoogle(List<BGPRunStatus> list)
        {
            Graph graph = new Graph();
            ColumnType[] columns = new ColumnType[3];

            ColumnType colType = new ColumnType() { id = "", label = "Run", type = "string" };
            columns[0] = colType;

            colType = new ColumnType() { id = "", label = "Processed", type = "number" };
            columns[1] = colType;

            colType = new ColumnType() { id = "", label = "Succeeded", type = "number" };
            columns[2] = colType;
     
            var s = new JavaScriptSerializer();
            var sb = new StringBuilder();
            s.Serialize(columns, sb);
            string abc = "[";

            abc += sb.ToString();
           //l List<Row> rowsList = new List<Row>();
            foreach (var r in list.OrderByDescending(p => p.RunEndDate).Take(10).Reverse())
            {
               abc += ",";
                List<string> dataList = new List<string>();
                dataList.Add(r.RunEndDate.ToString());
                dataList.Add(r.NoOfEncountersProcessed.ToString());
                dataList.Add(r.NoOfEncountersSucceded.ToString());
                var sw = new StringBuilder();
                s.Serialize(dataList, sw);
                abc += sw.ToString();
                //abc += "[\"" + r.RunEndDate + "\"," + r.NoOfEncountersProcessed + "," + r.NoOfEncountersSucceded + "],";
                /*  List<Value> values = new List<Value>();
                  values.Add(new Value { v = r.RunEndDate.ToString(), f = null });
                  values.Add(new Value { v = r.NoOfEncountersProcessed.ToString(), f = null });
                  values.Add(new Value { v = r.NoOfEncountersSucceded.ToString(), f = null });
                  rowsList.Add(new Row() { c = values.ToArray<Value>() });*/
            }

            abc += "]";
            /*  graph.cols = columns;
              graph.rows = rowsList.ToArray<Row>();

            var sw = new StringBuilder();
            s.Serialize(graph, sw);
            var json = sw.ToString();
            return json;*/
            return abc;
        }

        //get running status for comparison table
        public static string BGPRunStatusListComparison(List<BGPRunStatus> list)
        {
            Graph graph = new Graph();
            ColumnType[] columns = new ColumnType[3];

            ColumnType colType = new ColumnType() { id = "", label = "Run", type = "string" };
            columns[0] = colType;

            colType = new ColumnType() { id = "", label = "Processed", type = "number" };
            columns[1] = colType;

            colType = new ColumnType() { id = "", label = "Succeded", type = "number" };
            columns[2] = colType;

            List<Row> rowsList = new List<Row>();
            foreach (var r in list.OrderByDescending(p => p.RunEndDate).Take(10).Reverse())
            {

                List<Value> values = new List<Value>();
                values.Add(new Value { v = r.BGPName, f = null });
                values.Add(new Value { v = r.NoOfEncountersProcessed.ToString(), f = null });
                values.Add(new Value { v = r.NoOfEncountersSucceded.ToString(), f = null });
                rowsList.Add(new Row() { c = values.ToArray<Value>() });
            }

            graph.cols = columns;
            graph.rows = rowsList.ToArray<Row>();
            //graph.p = new Dictionary<string, string>()
            string json;
       
            //var s = new JsonSerializer();
            var s = new JavaScriptSerializer();

            var sw = new StringBuilder();
            s.Serialize(graph, sw);
            
            json = sw.ToString();
            s.Serialize(columns, sw);
            var text = sw.ToString();
            //  var abc=s.Deserialize(json, typeof(object));
            return json;
        }
        public class Graph
        {
            public ColumnType[] cols { get; set; }
            public Row[] rows { get; set; }
       
        }

        public class ColumnType
        {
            public string id { get; set; }
            public string label { get; set; }
            public string type { get; set; }
        }

        public class Row
        {
            public Value[] c { get; set; }
        }

        public class Value
        {
            public object v { get; set; } // value
            public string f { get; set; } // format

         
        }
    }
}
