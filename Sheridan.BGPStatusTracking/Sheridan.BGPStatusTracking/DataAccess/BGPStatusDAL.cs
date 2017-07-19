using Sheridan.SMART.DataAccess;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using Sheridan.SMART.Common.DataTransferObjects;
using System.Data;
using Sheridan.SMART;
using Sheridan.BGPStatusTracking.Business;

namespace Sheridan.SMART.DataAccess.BGPStatus
{
    public class BGPStatusDAL : IBGPStatusDAL
    {
        public List<BGPRunStatus> GetBGPStatus(int? bgpKey, DateTime? start, DateTime? end, int? pageindex, int? size = 50)
        {
            try
            {
                SqlParameter[] arrSqlParam = new SqlParameter[5];
                arrSqlParam[0] = new SqlParameter("@BGPKey", bgpKey);
                arrSqlParam[1] = new SqlParameter("@RunStartDate", start);
                arrSqlParam[2] = new SqlParameter("@RunEndDate", end);
                arrSqlParam[3] = new SqlParameter("@PageIndex", pageindex);
                arrSqlParam[4] = new SqlParameter("@PageSize", size);
                SqlHelper sqlHelper = new SqlHelper(SqlHelper.ConnectionType.SMART);

                List<BGPRunStatus> lst = new List<BGPRunStatus>();

                DataSet dsBGPStatus = sqlHelper.ExecuteDataSet("usp_GetBGPStatus", arrSqlParam);

                if (dsBGPStatus != null && dsBGPStatus.Tables.Count > 0)
                {
                    lst = (from row in dsBGPStatus.Tables[0].AsEnumerable()
                           select new BGPRunStatus
                           {
                               BGPKey = SqlHelper.HandleInt(row["BGPKey"]),
                               BGPName = SqlHelper.HandleString(row["BGPName"]),
                               RunStartDate = SqlHelper.HandleDateTime(row["RunStartDate"]).Value,
                               RunEndDate = SqlHelper.HandleDateTime(row["RunEndDate"]).Value,
                               Status = SqlHelper.HandleString(row["BGPStatus"]),
                               NoOfEncountersProcessed = SqlHelper.HandleInt(row["NoOfEncountersProcessed"]),
                               NoOfEncountersSucceded = SqlHelper.HandleInt(row["NoOfEncountersSucceded"]),
                               FailedEncounters = SqlHelper.HandleString(row["FailedEncounters"]),
                               RunDescription = SqlHelper.HandleString(row["RunDescription"])

                           }).ToList<BGPRunStatus>();
                }
                return lst;
               // return new List<BGPRunStatus>(lst);
            }
            catch (Exception ex)
            {
            }
            return null;
        }


        public List<BGPRunKey> GetBGPKey(String BGPName, int? size = 50)
        {
            try
            {
                SqlParameter[] arrSqlParam = new SqlParameter[2];
                arrSqlParam[0] = new SqlParameter("@BGPName", BGPName);
                arrSqlParam[1] = new SqlParameter("@PageSize", size);
                SqlHelper sqlHelper = new SqlHelper(SqlHelper.ConnectionType.SMART);

                List<BGPRunKey> Lst=new List<BGPRunKey>();

                DataSet dsBGPStatus = sqlHelper.ExecuteDataSet("usp_GetBGPStatusKeys", arrSqlParam);

                if (dsBGPStatus != null && dsBGPStatus.Tables.Count > 0)
                {
                    Lst = (from row in dsBGPStatus.Tables[0].AsEnumerable()
                           select new BGPRunKey
                           {
                               BGPKey = SqlHelper.HandleInt(row["BGPKey"]),
                               BGPName = SqlHelper.HandleString(row["BGPName"])
                           }).ToList<BGPRunKey>();
                }
                return Lst;

                // return new List<BGPRunStatus>(lst);
            }


            catch (Exception ex)
            {
            }
            return null;
        }

            
        public void PostBGPRunStatus(BGPRunStatus run, SMARTUserDTO user)
        {
            try
            {
                SqlParameter[] arrSqlParam = new SqlParameter[9];
                
                arrSqlParam[0] = new SqlParameter("@BGPKey", run.BGPKey);
                arrSqlParam[1] = new SqlParameter("@RunStartDate", run.RunStartDate);
                arrSqlParam[2] = new SqlParameter("@RunEndDate", run.RunEndDate);
                arrSqlParam[3] = new SqlParameter("@BGPStatus", run.Status);
                arrSqlParam[4] = new SqlParameter("@NoOfEncountersProcessed", run.NoOfEncountersProcessed);
                arrSqlParam[5] = new SqlParameter("@NoOfEncountersSucceded", run.NoOfEncountersSucceded);
                arrSqlParam[6] = new SqlParameter("@FailedEncounters", run.FailedEncounters);
                arrSqlParam[7] = new SqlParameter("@RunDescription", run.RunDescription);
                arrSqlParam[8] = new SqlParameter("@UpdatedByUsername", user.UserName);

                SqlHelper sqlHelper = new SqlHelper();

                sqlHelper.ExecuteNonQuery("usp_InsertBGPRun", arrSqlParam);
            }
            catch (Exception ex)
            {
            }
        }

        public List<BGP_GroupList> GetBGPGroup(int ? size=50)
        {

            try
            {
               // SqlParameter arrSqlParam[] = new SqlParameter[1];
                SqlParameter PageSize = new SqlParameter("@PageSize", size);
                SqlHelper sqlHelper = new SqlHelper(SqlHelper.ConnectionType.SMART);

                List<BGP_GroupList> Lst = new List<BGP_GroupList>();

                DataSet dsBGPStatus = sqlHelper.ExecuteDataSet("GetBGPGroup");

                if (dsBGPStatus != null && dsBGPStatus.Tables.Count > 0)
                {
                    Lst = (from row in dsBGPStatus.Tables[0].AsEnumerable()
                           select new BGP_GroupList
                           {
                               BGPName = SqlHelper.HandleString(row["BGPName"]),
                               GroupName = SqlHelper.HandleString(row["Group"])
                           }).ToList<BGP_GroupList>();
                }
                return Lst;
            }
            catch (Exception e)
            {

            }
            return null;
        }

      public BGPRunStatus GetBGPRunDetails(int? BGPKey, DateTime? start, DateTime? end,int? pageIndex, int? pageSize=50, string Interval="Daily")
        {
            try
            {
                SqlParameter[] arrSqlParam = new SqlParameter[6];
                arrSqlParam[0] = new SqlParameter("@interval", Interval);
                arrSqlParam[1]= new SqlParameter("@BGPKey", BGPKey);
                arrSqlParam[2] = new SqlParameter("@RunStartDate",start);
                arrSqlParam[3] = new SqlParameter("@RunEndDate", end);
                arrSqlParam[4] = new SqlParameter("@PageIndex", pageIndex);
                arrSqlParam[5] = new SqlParameter("@PageSize", pageSize);
                
                SqlParameter PageSize = new SqlParameter("@PageSize", pageSize);

                SqlHelper sqlHelper = new SqlHelper(SqlHelper.ConnectionType.SMART);

              
                List<BGPRunStatus> Lst = new List<BGPRunStatus>();

                DataSet dsBGPStatus = sqlHelper.ExecuteDataSet("usp_GetBGPRunningStatusForTime", arrSqlParam);

                if (dsBGPStatus != null && dsBGPStatus.Tables.Count > 0)
                {
                    Lst = (from row in dsBGPStatus.Tables[0].AsEnumerable()
                           select new BGPRunStatus
                           {
                               BGPKey = SqlHelper.HandleInt(row["BGPKey"]),
                               NoOfEncountersProcessed = SqlHelper.HandleInt(row["NoOfEncountersProcessed"]),
                               NoOfEncountersSucceded = SqlHelper.HandleInt(row["NoOfEncountersSucceded"]),
                           }).ToList<BGPRunStatus>();
                }
                BGPRunStatus BGPdetails;
                if (Lst.Count != 0)
                    BGPdetails = Lst[0];
                else
                {
                    return null;
                }
                  // BGPdetails = new BGPRunStatus() { BGPKey = (int)BGPKey, NoOfEncountersProcessed = 0, NoOfEncountersSucceded = 0, RunEndDate = DateTime.Now };
                return BGPdetails;
            }
            catch (Exception e)
            {

            }
            return null;
        }
    }
    }
