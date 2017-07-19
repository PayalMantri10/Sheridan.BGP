using Sheridan.SMART.Common.DataTransferObjects;
using Sheridan.SMART.DataAccess.BGPStatus;
using Sheridan.SMART;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Sheridan.SMART.Business.BGPStatus
{
    public interface IBGPStatusBC
    {
        List<BGPRunStatus> GetBGPStatus(BGPRunStatusInput input,SMARTUserDTO user);

        List<BGPRunStatus> GetBGPStatusList(BGPRunStatusInput input);

        void PostBGPRunStatus(BGPRunStatus run, SMARTUserDTO user);
        List<BGPRunStatus> GetBGPRunStatus(BGPRunStatusInput input);
        List<BGPRunStatus> GetBGPRunStatusforall(BGPRunStatusInput input);
    }
}
