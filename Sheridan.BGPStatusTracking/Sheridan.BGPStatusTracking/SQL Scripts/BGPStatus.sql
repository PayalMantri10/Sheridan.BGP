
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

ALTER TABLE [dbo].[BGPStatus_BGP] WITH NOCHECK ADD GroupKey INT not NUll constraint [DEFAULT_GROUP] DEFAULT (1)

ALTER TABLE [dbo].[BGPStatus_BGP] WITH NOCHECK ADD
CONSTRAINT [FK_BGPStatus_BGP_To_BGPGroup] FOREIGN KEY (GroupKey)
REFERENCES [dbo].[BGP_Group](GroupKey)

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


CREATE PROCEDURE [dbo].[usp_GetBGPStatusKeys]
(
  @BGPName Varchar(100) =NULL,
  @PageSize INT =NULL
)
AS
 SET NOCOUNT ON

	IF(@PageSize=NULL)
		SET @PageSize=50;

		SELECT DISTINCT
		[BGPName],
		[BGPKey]
		FROM 
		[dbo].[BGPStatus_BGP]
		WHERE
		((@BGPName IS NULL) OR (BGPName=@BGPName))

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


CREATE PROCEDURE [dbo].[usp_GetBGPRunningStatusForTime]
(
	@interval Varchar(50) = NULL,
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

declare @StartDate datetime
declare @EndDate datetime
set @EndDate = getdate()
if(@interval='Monthly')
set @StartDate = dateadd(month,-1,@EndDate)
else if(@interval='Daily')
set @StartDate = dateadd(day,-1,@EndDate)
else if(@interval='Yearly')
set @StartDate=dateadd(year,-1,@EndDate)

	SELECT 
	   b.BGPKey
	  ,sum([NoOfEncountersProcessed]) as NoOfEncountersProcessed
      ,Sum([NoOfEncountersSucceded]) as NoOfEncountersSucceded
      
      
	FROM
			
		(
		
			SELECT ROW_NUMBER() OVER ( ORDER BY BGPRunKey ) AS RowNum, *
			FROM   [BGPStatus_BGPRun]
			WHERE   ((@BGPKey IS NULL) OR (BGPKey=@BGPKey))
			AND ( (RunStartDate>=@StartDate))
			AND ((@RunEndDate IS NULL) OR (@RunEndDate<=@EndDate))
		) AS RowConstrainedResult
	 INNER JOIN [BGPStatus_BGP] as b on b.BGPKey=RowConstrainedResult.BGPKey
	WHERE (
	(@PageIndex IS NULL) OR   
	((RowNum >= @PageIndex*@PageSize) AND (RowNum < (@PageIndex+1)*@PageSize))
	) 
	GROUP BY b.BGPKey
GO
-------Data--------

USE [SMART1]
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
           (3
           ,GETDATE()
           ,GETDATE()
           ,null
           ,14
           ,10
           ,'123456,123457'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'SMARTCodeRyteReconciliation')


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
           (3
           ,GETDATE()
           ,GETDATE()
           ,null
           ,14
           ,10
           ,'123456,123457'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'SMARTCodeRyteReconciliation')


		   INSERT INTO [dbo].[BGPStatus_BGP]
           ([BGPName]
           ,[CreateDate]
           ,[LastUpdateDate]
           ,[UpdatedByUsername]
		   ,[GroupKey])
     VALUES
           ('ICUMonitoring'
           ,'2-28-2016'
           ,'1-12-2017 22:13'
           ,'admin'
	       ,4  )
GO


		   INSERT INTO [dbo].[BGPStatus_BGP]
           ([BGPName]
           ,[CreateDate]
           ,[LastUpdateDate]
           ,[UpdatedByUsername]
		   ,[GroupKey])
     VALUES
           ('LeanProcess'
           ,'3-2-2015'
           ,'6-12-2016 1:12:28'
           ,'admin'
		   , 4)
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
           (1
           ,GETDATE()
           ,GETDATE()
           ,null
           ,8
           ,6
           ,null
           ,null
           ,GETDATE()
           ,GETDATE()
           ,'SMARTCodeRyteReconciliation')
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
           (1
           ,GETDATE()
           ,GETDATE()
           ,null
           ,9
           ,8
           ,null
           ,null
           ,GETDATE()
           ,GETDATE()
           ,'SMARTCodeRyteReconciliation')
GO


		   INSERT INTO [dbo].[BGPStatus_BGP]
           ([BGPName]
           ,[CreateDate]
           ,[LastUpdateDate]
           ,[UpdatedByUsername]
		   ,[GroupKey])
     VALUES
           ('ScannerBGP'
           ,'5-10-2016'
           ,'2-12-2017 12:24:28'
           ,'admin'
		   , 2)
GO


		   INSERT INTO [dbo].[BGPStatus_BGP]
           ([BGPName]
           ,[CreateDate]
           ,[LastUpdateDate]
           ,[UpdatedByUsername]
		   ,[GroupKey])
     VALUES
           ('Service'
           ,'6-18-2016'
           ,getdate()
           ,'admin'
		   , 1)
GO


		   INSERT INTO [dbo].[BGPStatus_BGP]
           ([BGPName]
           ,[CreateDate]
           ,[LastUpdateDate]
           ,[UpdatedByUsername]
		   ,[GroupKey])
     VALUES
           ('LBBSReports'
           ,'12-23-2016 15:07'
           ,'2-21-2017 17:56:23'
           ,'admin'
		   , 3)
GO


		   INSERT INTO [dbo].[BGPStatus_BGP]
           ([BGPName]
           ,[CreateDate]
           ,[LastUpdateDate]
           ,[UpdatedByUsername]
		   ,[GroupKey])
     VALUES
           ('DoorToDoorService'
           ,'1-2-2015 12:18:09'
           ,'2-14-2017 20:56:38'
           ,'admin'
		   , 3)
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
           (5
           ,'1-8-2017 3:30:33'
           ,'1-22-2017 12:43:21'
           ,null
           ,26
           ,17
           ,'2322,2322'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'admin')

		   
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
           (5
           ,'1-2-2017 13:32'
           ,'1-8-2017 10:53:21'
           ,null
           ,10
           ,6
           ,''
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'ICUMonitoring')

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
           (6
           ,'1-12-2016 12:29:03'
           ,'2-12-2016 1:14:09'
           ,null
           ,14
           ,7
           ,'236,236'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'RadiologyReportBatches')

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
           (8
           ,'4-12-2016 8:10:54'
           ,'2-23-2017 21:9:32'
           ,null
           ,19
           ,10
           ,'31346,31346'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'RadiologyReportBatches')

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
           (8
           ,'7-13-2016 9:28:53'
           ,'8-11-2016 18:29:31'
           ,null
           ,10
           ,7
           ,'21346,21346'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'ScannerBGP')

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
           (9
           ,'12-10-2016 13:20:33'
           ,'2-11-2017 19:32:11'
           ,null
           ,23
           ,14
           ,'23346,21346'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'admin')

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
           (5
           ,'3-16-2016 14:26:38'
           ,'11-11-2016 18:09:18'
           ,'SUCCESS'
           ,19
           ,14
           ,'31346,31346'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'CodeRyteInterfaceProcessor')

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
           (10
           ,'12-27-2016 3:19:54'
           ,'2-9-2017 4:16:24'
           ,'failed'
           ,25
           ,8
           ,'3146,3146'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'Service')

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
           (10
           ,'12-31-2016 2:49:44'
           ,'2-5-2017 19:36:14'
           ,'success'
           ,25
           ,19
           ,'32146,32146'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'ICUMonitoring')

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
           (9
           ,'12-23-2016 6:29:32'
           ,'1-5-2017 10:21:17'
           ,'failed'
           ,23
           ,12
           ,'132146,132146'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'Service')

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
           (9
           ,'12-27-2016 3:19:54'
           ,'2-9-2017 4:16:24'
           ,'failed'
           ,25
           ,8
           ,'3146,3146'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'Service')

		   
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
           (5
           ,'4-27-2016 23:19:54'
           ,'2-1-2017 19:11:24'
           ,'success'
           ,25
           ,8
           ,'3146,3146'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'DoorToDoorSevice')

		   
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
           (6
           ,'12-24-2015 8:19:54'
           ,'10-31-2016 06:45:29'
           ,'success'
           ,25
           ,8
           ,'32146,32146'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'Service')

		   
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
           (1
           ,Getdate()
           ,getdate()
           ,null
           ,19
           ,3
           ,'21346,21346'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'ScannerBGP')

		   
		   
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
           (3
           ,Getdate()
           ,getdate()
           ,null
           ,25
           ,18
           ,'21346,21346'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'admin')

		   
		   
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
           (5
           ,Getdate()
           ,getdate()
           ,null
           ,28
           ,9
           ,'221346,212346'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'Service')

		   
		   
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
           (6
           ,Getdate()
           ,getdate()
           ,null
           ,9
           ,9
           ,'121346,21346'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'ScannerBGP')



 exec [usp_GetBGPRunningStatusForTime] Monthly

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
           (4
           ,'2-29-2016 14:30'
           ,'12-29-2016 1:32:29'
           ,null
           ,19
           ,18
           ,'121346,21346'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'ScannerBGP')

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
           (4
		              ,'3-31-2016 12:9'
           ,'1-29-2017 12:33:09'
           ,null
           ,13
           ,12
           ,'11346,1346'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'admin')

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
           (7
           ,'7-25-2016 11:40:09'
           ,'2-27-2017 12:22:31'
           ,null
           ,12
           ,10
           ,'11346,346'
           ,''
           ,GETDATE()
           ,GETDATE()
           ,'ICUMonitoring')