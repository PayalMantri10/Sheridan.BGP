using System;
using System.Collections.Generic;
using System.Linq;
using Sheridan.SMART.DataAccess.BGPStatus;
using Sheridan.SMART.Common.DataTransferObjects;

namespace Sheridan.SMART.Business.BGPStatus
{
    public class BGPStatusBC:IBGPStatusBC
    {
        //can be replaced later
        private IBGPStatusDAL dal = new BGPStatusDAL();

        /// <summary>
        /// 
        /// </summary>
        /// <param name="statusDal"></param>
        public BGPStatusBC(IBGPStatusDAL statusDal)
        {
            dal = statusDal;
        }

        public BGPStatusBC()
        {
            // TODO: Complete member initialization
            dal = new BGPStatusDAL();
        }

        public List<BGPRunStatus> GetBGPStatus(BGPRunStatusInput input,SMARTUserDTO user)
        {
            
            try
            {
                return dal.GetBGPStatus(input.BGPKey, input.RunStartDate, input.RunEndDate, input.PageIndex, input.PageSize);
            }
            catch (Exception ex)
            { 
            }
            return null;
        }

          public List<BGPRunKey> GetBGPKey(BGPRunStatusInput input, SMARTUserDTO user)
        {
            try
            {
                return dal.GetBGPKey(input.BGPName, input.PageSize);
            }
            catch(Exception ex)
            {

            }
            return null;
        }


        public BGPRunStatus GetBGPSum(BGPRunStatusInput input, SMARTUserDTO user,string Interval)
        {
            try
            {
                return dal.GetBGPRunDetails( input.BGPKey, input.RunStartDate, input.RunEndDate, input.PageIndex, input.PageSize, Interval);
            }
            catch (Exception ex)
            {

            }
            return null;
        }

        public BGPRunStatus GetRunStatusForEach(BGPRunStatusInput input, string Interval)
        {
            List<BGPRunKey> ListKey = new List<BGPRunKey>();
            ListKey = this.GetBGPKey(input, new SMARTUserDTO());
            if (ListKey.Count != 0)
            {
                input.BGPKey = ListKey[0].BGPKey;
            }
            else
            {
                return null;
            }
            return this.GetBGPSum(input, new SMARTUserDTO(), Interval);
        }

        public List<BGPRunStatus> GetBGPRunStatus(BGPRunStatusInput input)
        {
            List<BGPRunKey> ListKey = new List<BGPRunKey>();
            ListKey = this.GetBGPKey(input, new SMARTUserDTO());
            if (ListKey.Count !=0)
            {
                input.BGPKey = ListKey[0].BGPKey;
            }
            return this.GetBGPStatusList(input);
        }


        public List<BGPRunStatus> GetBGPRunStatusforall(BGPRunStatusInput input)
        {
            List<BGPRunKey> ListKey = new List<BGPRunKey>();
            ListKey = this.GetBGPKey(input, new SMARTUserDTO());
         
            return this.GetBGPStatusList(input);
        }

        public List<BGPRunStatus> GetBGPStatusList(BGPRunStatusInput input)
        {
           
            List<BGPRunStatus> list = new List<BGPRunStatus>();
              var bgpCollection=this.GetBGPStatus(input, new SMARTUserDTO());
            if(bgpCollection!=null)
                list = bgpCollection.ToList<BGPRunStatus>();
             return list;
        }

        public void PostBGPRunStatus(BGPRunStatus run, SMARTUserDTO user)
        {
            try
            {
                dal.PostBGPRunStatus(run, user);
            }
            catch(Exception ex) { 
            }
        }
    }
}