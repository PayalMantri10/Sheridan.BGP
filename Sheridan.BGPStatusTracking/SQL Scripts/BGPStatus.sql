/* ------------------------------------------------------------------------ 
        TABLES
   ------------------------------------------------------------------------ */

CREATE TABLE [dbo].[BGPStatus_BGP]
(
    BGPKey int Identity(1,1) NOT NULL,
	BGPName varchar(100) NOT NULL,
	CreateDate DateTime NOT NULL,
	LastUpdateDate DateTime NOT NULL,
	UpdatedByUsername varchar(50) NOT NULL,
	RecordTimeStamp timestamp NOT NULL
    
) 


ALTER TABLE [dbo].[BGPStatus_BGP] WITH NOCHECK ADD 
    CONSTRAINT [PK_BGPStatus_BGP] PRIMARY KEY CLUSTERED ([BGPKey]) ON [PRIMARY] 
GO

CREATE TABLE [dbo].[BGPStatus_BGPRun]
(
    BGPRunKey int Identity(1,1) NOT NULL,
	BGPKey int NOT NULL,
	RunStartDate DateTime NOT NULL,
	RunEndDate DateTime NOT NULL,
	BGPStatus varchar(20) NULL,
	NoOfEncountersProcessed int NOT NULL, 
	NoOfEncountersSucceded int NOT NULL,
	FailedEncounters varchar(max) NULL,
	RunDescription varchar(max) NULL,	
	CreateDate DateTime NOT NULL,
	LastUpdateDate DateTime NOT NULL,
	UpdatedByUsername varchar(50) NOT NULL,
	RecordTimeStamp timestamp NOT NULL 
    
) 


ALTER TABLE [dbo].[BGPStatus_BGPRun] WITH NOCHECK ADD 
    CONSTRAINT [PK_BGPStatus_BGPRun] PRIMARY KEY CLUSTERED ([BGPRunKey]) ON [PRIMARY] 
GO

ALTER TABLE [dbo].[BGPStatus_BGPRun] WITH NOCHECK ADD
CONSTRAINT [FK_BGPStatus_BGPRun_To_BGP] FOREIGN KEY (BGPKey)
REFERENCES [dbo].[BGPStatus_BGP](BGPKey)

CREATE NONCLUSTERED INDEX [IX_BGPRUN_BGP_Start_End] ON [dbo].[BGPStatus_BGPRun] 
(
    BGPKey,
	RunStartDate,
	RunEndDate
) 
ON [PRIMARY]
GO

/* ------------------------------------------------------------------------ 
        STORED PROCEDURES                                                      
   ------------------------------------------------------------------------ */

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[usp_GetBGPStatus]
(
	@BGPKey INT = NULL,
	@RunStartDate DateTime = NULL, --included
	@RunEndDate DateTime = NULL, --included
    @PageIndex INT = NULL, -- 0 based
    @PageSize INT = NULL  
)
AS 

    SET NOCOUNT ON

	IF(@PageSize=NULL)
		SET @PageSize=50;

	SELECT 
	   b.BGPKey
	  ,[BGPName]
      ,[RunStartDate]
      ,[RunEndDate]
      ,[BGPStatus]
      ,[NoOfEncountersProcessed]
      ,[NoOfEncountersSucceded]
      ,[FailedEncounters]
      ,[RunDescription]
      
	FROM		
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY BGPRunKey ) AS RowNum, *
			FROM   [BGPStatus_BGPRun]
			WHERE   ((@BGPKey IS NULL) OR (BGPKey=@BGPKey))
			AND ((@RunStartDate IS NULL) OR (RunStartDate>=@RunStartDate))
			AND ((@RunEndDate IS NULL) OR (@RunEndDate<=@RunEndDate))
		) AS RowConstrainedResult
	 INNER JOIN [BGPStatus_BGP] as b on b.BGPKey=RowConstrainedResult.BGPKey
	WHERE (
	(@PageIndex IS NULL) OR   
	((RowNum >= @PageIndex*@PageSize) AND (RowNum < (@PageIndex+1)*@PageSize))
	)
	ORDER BY RowNum;

GO


SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[usp_InsertBGPRun]
(
	 @BGPKey int
	,@RunStartDate datetime
	,@RunEndDate datetime
	,@BGPStatus varchar(20) = NULL
	,@NoOfEncountersProcessed int
	,@NoOfEncountersSucceded int
	,@FailedEncounters varchar(max) =NULL
	,@RunDescription varchar(max) =NULL	
	,@UpdatedByUsername varchar(50)
)
AS

SET NOCOUNT ON
    
INSERT INTO [dbo].[BGPStatus_BGPRun]
	(
		[BGPKey]
		,[RunStartDate]
		,[RunEndDate]
		,[BGPStatus]
		,[NoOfEncountersProcessed]
		,[NoOfEncountersSucceded]
		,[FailedEncounters]
		,[RunDescription]
		,[CreateDate]
		,[LastUpdateDate]		
		,[UpdatedByUsername]
	)
	VALUES
	(
		@BGPKey
		,@RunStartDate
		,@RunEndDate
		,@BGPStatus
		,@NoOfEncountersProcessed
		,@NoOfEncountersSucceded
		,@FailedEncounters		
		,@RunDescription
		,GetDate()
		,GetDate()
		,@UpdatedByUsername
	)

GO

-------Data--------

USE [SMART]
GO

INSERT INTO [dbo].[BGPStatus_BGP]
           ([BGPName]
           ,[CreateDate]
           ,[LastUpdateDate]
           ,[UpdatedByUsername])
     VALUES
           ('CodeRyteInterfaceProcessor'
           ,GetDate()
           ,GetDate()
           ,'admin')
GO


INSERT INTO [dbo].[BGPStatus_BGP]
           ([BGPName]
           ,[CreateDate]
           ,[LastUpdateDate]
           ,[UpdatedByUsername])
     VALUES
           ('SMARTCodeRyteReconciliation'
           ,GetDate()
           ,GetDate()
           ,'admin')
GO


INSERT INTO [dbo].[BGPStatus_BGP]
           ([BGPName]
           ,[CreateDate]
           ,[LastUpdateDate]
           ,[UpdatedByUsername])
     VALUES
           ('RadiologyReportBatches'
           ,GetDate()
           ,GetDate()
           ,'admin')
GO

INSERT INTO [dbo].[BGPStatus_BGPRun]
           ([BGPKey]
           ,[RunStartDate]
           ,[RunEndDate]
           ,[BGPStatus]
           ,[NoOfEncountersProcessed]
           ,[NoOfEncountersSucceded]
           ,[FailedEncounters]
           ,[RunDescription]
           ,[CreateDate]
           ,[LastUpdateDate]
           ,[UpdatedByUsername])
     VALUES
           (2
           ,GETDATE()
           ,GETDATE()
           ,null
           ,6
           ,4
           ,'123456,123457'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'SMARTCodeRyteReconciliation')

Go

INSERT INTO [dbo].[BGPStatus_BGPRun]
           ([BGPKey]
           ,[RunStartDate]
           ,[RunEndDate]
           ,[BGPStatus]
           ,[NoOfEncountersProcessed]
           ,[NoOfEncountersSucceded]
           ,[FailedEncounters]
           ,[RunDescription]
           ,[CreateDate]
           ,[LastUpdateDate]
           ,[UpdatedByUsername])
     VALUES
           (2
           ,GETDATE()
           ,GETDATE()
           ,null
           ,6
           ,6
           ,null
           ,null
           ,GETDATE()
           ,GETDATE()
           ,'SMARTCodeRyteReconciliation')
GO

