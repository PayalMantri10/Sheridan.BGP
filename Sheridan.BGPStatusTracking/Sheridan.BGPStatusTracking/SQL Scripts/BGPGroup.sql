
CREATE TABLE [dbo].[BGP_Group]
(
    
    [GroupKey] INT NOT NULL,
    [Group]       VARCHAR(50) DEFAULT('ROOT') NOT NULL
) 
ON [PRIMARY] 

GO

ALTER TABLE [dbo].[BGP_Group] WITH NOCHECK ADD 
    CONSTRAINT [PK_BGP_GROUP] PRIMARY KEY NONCLUSTERED ([GroupKey]) ON [PRIMARY] 
GO


INSERT INTO BGP_Group
Values(2,'Radiology'),
      (1,'Root')
GO


INSERT INTO BGP_Group
Values(3,'Emergengy Medicine'),
      (4,'Critical Care')
GO

Create PROCEDURE [dbo].[GetBGPGroup]
(@PageSize INT =NULL)
As 
SET NOCOUNT ON
IF (@PageSize=NULL)
   SET @PageSize=50;
Select [BGPName], [Group] FROM [dbo].[BGP_Group] , [dbo].[BGPStatus_BGP] where [BGP_Group].GroupKey=[BGPStatus_BGP].GroupKey

GO


