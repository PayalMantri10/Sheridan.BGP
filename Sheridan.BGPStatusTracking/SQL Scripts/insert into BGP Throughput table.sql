USE [SMART]
GO

DECLARE @RC int
DECLARE @BGPKey int =1
DECLARE @RunStartDate datetime =GetDate()
DECLARE @RunEndDate datetime =GetDate()
DECLARE @BGPStatus varchar(20) ='Success'
DECLARE @NoOfEncountersProcessed int =53
DECLARE @NoOfEncountersSucceded int =21
DECLARE @FailedEncounters varchar(max)=''
DECLARE @RunDescription varchar(max)=''
DECLARE @UpdatedByUsername varchar(50)='admin'

-- TODO: Set parameter values here.

EXECUTE @RC = [dbo].[usp_InsertBGPRun] 
   @BGPKey
  ,@RunStartDate
  ,@RunEndDate
  ,@BGPStatus
  ,@NoOfEncountersProcessed
  ,@NoOfEncountersSucceded
  ,@FailedEncounters
  ,@RunDescription
  ,@UpdatedByUsername
GO


