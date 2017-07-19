using Newtonsoft.Json;
using Sheridan.SMART.Business.BGPStatus;
using Sheridan.SMART.Common.DataTransferObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web.Http;
using System.Web.Script.Serialization;

namespace Sheridan.BGPStatusTracking.Controllers
{   

    public class BGPStatusController : ApiController
    {
        IBGPStatusBC bc = new BGPStatusBC();

        // GET api/bgpstatus
        public string Get()
        {
            BGPRunStatusInput input=new BGPRunStatusInput();
            List<BGPRunStatus> list = bc.GetBGPStatusList(input);
            string json = BGPRunStatusListToJson(list);           
            return json;       
        }

        // GET api/bgpstatus/5
        public string Get(int id)
        {
            BGPRunStatusInput input=new BGPRunStatusInput(){ BGPKey=id};
            List<BGPRunStatus> list = bc.GetBGPStatusList(input);
            string json = BGPRunStatusListToJson(list);    
            return json; 
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
            Graph graph = new Graph();
            ColumnType[] columns = new ColumnType[3];

            ColumnType colType = new ColumnType() { id = "", label = "Run", type = "string" };
            columns[0] = colType;

            colType = new ColumnType() { id = "", label = "Processed", type = "number" };
            columns[1] = colType;

            colType = new ColumnType() { id = "", label = "Succeded", type = "number" };
            columns[2] = colType;

            List<Row> rowsList = new List<Row>();
            foreach (var r in list.OrderByDescending(p=>p.RunEndDate).Take(10).Reverse())
            {
                List<Value> values = new List<Value>();
                values.Add(new Value { v = r.RunEndDate.ToShortTimeString(), f = null });
                values.Add(new Value { v = r.NoOfEncountersProcessed.ToString(), f = null });
                values.Add(new Value { v = r.NoOfEncountersSucceded.ToString(), f = null });
                rowsList.Add(new Row() { c = values.ToArray<Value>() });
            }

            graph.cols = columns;
            graph.rows = rowsList.ToArray<Row>();
            //graph.p = new Dictionary<string, string>();

            string json;
            //var s = new JsonSerializer();
            var s = new JavaScriptSerializer();

            var sw = new StringBuilder();
            s.Serialize(graph, sw);
            json = sw.ToString();
            return json;
        }
    }

    public class Graph
    {
        public ColumnType[] cols { get; set; }
        public Row[] rows { get; set; }
        // public Dictionary<string, string> p { get; set; }
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
