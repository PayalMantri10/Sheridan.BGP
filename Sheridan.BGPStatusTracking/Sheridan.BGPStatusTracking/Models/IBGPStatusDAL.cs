using Sheridan.SMART.Common.DataTransferObjects;
using Sheridan.SMART;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Sheridan.SMART.DataAccess.BGPStatus
{
    public interface IBGPStatusDAL
    {
      List<BGPRunStatus> GetBGPStatus(int? bgpKey, DateTime? start, DateTime? end, int? pageindex, int? size = 50);
        void PostBGPRunStatus(BGPRunStatus run, SMARTUserDTO user);
        List<BGPRunKey> GetBGPKey(string bGPName, int? pageSize);
        BGPRunStatus GetBGPRunDetails(int? BGPKey, DateTime? start, DateTime? end, int? pageIndex, int? pageSize = 50, string interval="Daily");
    }
}
