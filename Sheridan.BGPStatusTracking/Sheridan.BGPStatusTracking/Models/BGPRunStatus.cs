using Sheridan.SMART;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;

namespace Sheridan.SMART.Common.DataTransferObjects
{
    [Serializable]
    //[DataContract]work;

    public class BGPRunStatus
    {
        //[DataMember]
        public  object Key { get; set; }

        //[DataMember]
        public int BGPKey {get;set;}

        //[DataMember]
        public string BGPName { get; set; }

        //[DataMember]
		public DateTime RunStartDate{get;set;}

        //[DataMember]
		public DateTime RunEndDate{get;set;}

        //[DataMember]
		public string Status{get;set;}

        //[DataMember]
		public int NoOfEncountersProcessed{get;set;}

        //[DataMember]
		public int NoOfEncountersSucceded{get;set;}

        //[DataMember]
		public string FailedEncounters{get;set;}

        //[DataMember]
		public string RunDescription{get;set;}        
    }

    [Serializable]
    //[DataContract]
    public class BGPRunStatusInput  
    {
     //   [DataMember]
        public  object Key { get; set; }
        public string BGPName { get; set; }

        public int? BGPKey { get; set; }
       
        public DateTime? RunStartDate { get; set; }
        
        public DateTime? RunEndDate { get; set; }

        public int? PageIndex { get; set; }

        public int? PageSize { get; set; }
    }
    public class BGPRunKey
    {
        public string BGPName { get; set; }
        public int BGPKey { get; set; }
    }
       
}
