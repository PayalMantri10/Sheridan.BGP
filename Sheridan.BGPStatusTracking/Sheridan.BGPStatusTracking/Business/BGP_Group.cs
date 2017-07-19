using Sheridan.BGPStatusTracking.Controllers;
using Sheridan.SMART.Business.BGPStatus;
using Sheridan.SMART.Common.DataTransferObjects;
using Sheridan.SMART.DataAccess.BGPStatus;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;

namespace Sheridan.BGPStatusTracking.Business
{
    public class BGP_GroupList
    {
        public string GroupName { get; set; }
            public string BGPName { get; set; }
    }

    public class BGPGroup
    {
        public string Group { get; set; }
        public string[] BGPs { get; set; }
    }

    public class BGP_GroupBC
    {
        BGPStatusDAL dal = new BGPStatusDAL();
        BGPStatusBC bc = new BGPStatusBC();
       
        public string GetBGPGroup()
        {
           
          
            List<BGP_GroupList> appList = dal.GetBGPGroup();
            Dictionary < string, List<string>> groupify = new Dictionary<string,List<string>>();


            foreach (var app in appList)
            {
               

                if (groupify.ContainsKey(app.GroupName))
                {
                    List<string> BGPs = groupify[app.GroupName];
                    string BGPName = app.BGPName;
                    BGPs.Add(BGPName);
                }
                else
                {
                    List<String> BGPs = new List<String>();
                    BGPs.Add(app.BGPName);
                    groupify.Add(app.GroupName, BGPs);
                }

            }

            List<BGPGroup> GroupList = new List<BGPGroup>();
            foreach (var group in groupify)
            {
                BGPGroup grp = new BGPGroup() { Group = group.Key, BGPs = group.Value.ToArray() };
                GroupList.Add(grp);
            }
            JavaScriptSerializer J = new JavaScriptSerializer();
            var jstring=J.Serialize(GroupList);

            return jstring;
        }

        public string GetDataforComaprisonTable(string BGPList,string Interval, string Browser )
        {
            var BGPNames = BGPList.Split(',');
            List<BGPRunStatus> BGPRunList = new List<BGPRunStatus>();
            foreach(var BGPName in BGPNames)
            {
                BGPRunStatusInput input = new BGPRunStatusInput { BGPName = BGPName };
                var BGPData = bc.GetRunStatusForEach(input, Interval);
                if (BGPData != null)
                {
                    BGPData.BGPName = BGPName;
                    BGPRunList.Add(BGPData);
                }
                
            }
            
            if (Browser.Equals("IE8"))
            {
                return BGPStatusController.BGPRunStatusListComparisonIE8(BGPRunList);
            }
            else
            {
             return  BGPStatusController.BGPRunStatusListComparison(BGPRunList);
            }
            
           
        }

    }
    }
