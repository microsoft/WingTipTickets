SET ANSI_PADDING OFF
GO

SET IDENTITY_INSERT [dbo].[Location] ON
GO

INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (1, N'North Central US', N'North Central US')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (2, N'North Europe', N'North Europe')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (3, N'West Europe', N'West Europe')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (4, N'East US', N'East US')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (5, N'East Asia', N'East Asia')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (6, N'Southeast Asia', N'Southeast Asia')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (7, N'West US', N'West US')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (8, N'Central US', N'Central US')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (9, N'Japan West', N'Japan West')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (10, N'Japan East', N'Japan East')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (11, N'South Central US', N'South Central US')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (12, N'East US 2', N'East US 2')
INSERT [dbo].[Location] ([LocationId], [Description], [Code]) VALUES (13, N'Brazil South', N'Brazil South')
GO

SET IDENTITY_INSERT [dbo].[Location] OFF
GO
SET IDENTITY_INSERT [dbo].[ProvisioningOption] ON 
GO

INSERT [dbo].[ProvisioningOption] ([ProvisioningOptionId], [Description], [Code]) VALUES (1, N'Standard (Day 1)', N'S1')
INSERT [dbo].[ProvisioningOption] ([ProvisioningOptionId], [Description], [Code]) VALUES (2, N'Standard (Day 2)', N'S2')
INSERT [dbo].[ProvisioningOption] ([ProvisioningOptionId], [Description], [Code]) VALUES (3, N'Hidden', N'H')
GO

SET IDENTITY_INSERT [dbo].[ProvisioningOption] OFF
GO
SET IDENTITY_INSERT [dbo].[ProvisioningPipelineTasks] ON 
GO

-- DAY 1 PIPELINE
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (1,  1, 1,  N'',          1,  1,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (2,  1, 2,  N'',          2,  2,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (3,  1, 3,  N'primary',   4,  3,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (4,  1, 3,  N'secondary', 5,  4,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (5,  1, 5,  N'primary',   6,  4,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (6,  1, 6,  N'primary',   7,  5,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (7,  1, 13, N'',          3,  3,  0)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (8,  1, 11, N'primary',   12, 6,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (9,  1, 7,  N'primary',   8,  4,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (10, 1, 8,  N'primary',   10, 5,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (11, 1, 9,  N'primary',   13, 7,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (12, 1, 7,  N'secondary', 9,  4,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (13, 1, 8,  N'secondary', 11, 5,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (14, 1, 9,  N'secondary', 14, 7,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (15, 1, 10, N'',          15, 7,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (16, 1, 12, N'primary',   16, 8,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (17, 1, 12, N'secondary', 17, 8,  1)
GO

-- DAY 2 PIPELINE
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (18, 2, 1,  N'',          1,  1,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (20, 2, 18, N'',          2,  2,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (21, 2, 16, N'primary',   3,  3,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (22, 2, 5,  N'primary',   4,  4,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (23, 2, 6,  N'primary',   5,  5,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (24, 2, 7,  N'primary',   6,  3,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (25, 2, 8,  N'primary',   7,  4,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (26, 2, 17, N'primary',   8,  5,  1)
INSERT [dbo].[ProvisioningPipelineTasks] ([ProvisioningPipelineId], [ProvisioningOptionId], [ProvisioningTaskId], [Position], [SequenceNo], [GroupNo], [WaitForCompletion]) VALUES (27, 2, 15, N'',			 9,  6,  1)
GO

SET IDENTITY_INSERT [dbo].[ProvisioningPipelineTasks] OFF
GO
SET IDENTITY_INSERT [dbo].[ProvisioningTask] ON 
GO

-- SHARED
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (1, N'Resource Group', N'Shared_ResourceGroup')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (2, N'Storage Account', N'Day1_StorageAccount')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (3, N'Database', N'Day1_SqlServer')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (5, N'Database Schema', N'Shared_SqlServerSchema')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (6, N'Database Population', N'Shared_SqlServerPopulate')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (7, N'Website Hosting Plan', N'Shared_WebHostingPlan')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (8, N'Website', N'Shared_Website')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (9, N'Website Deployment', N'Day1_WebsiteDeployment')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (10, N'Traffic Manager', N'Shared_TrafficManager')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (11, N'Search Service', N'Shared_SearchService')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (12, N'Auditing', N'Shared_SqlAuditing')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (13, N'DocumentDb', N'Shared_DocumentDb')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (15, N'Data Factory', N'Day2_DataFactory')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (16, N'Database', N'Day2_SqlServer')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (17, N'Website Deployment', N'Day2_WebsiteDeployment')
INSERT [dbo].[ProvisioningTask] ([ProvisioningTaskId], [Description], [Code]) VALUES (18, N'Storage Account', N'Day2_StorageAccount')
GO

SET IDENTITY_INSERT [dbo].[ProvisioningTask] OFF
GO
SET IDENTITY_INSERT [dbo].[Theme] ON 
GO

INSERT [dbo].[Theme] ([ThemeId], [Description], [Code], [SiteName]) VALUES (1, N'Classical', N'S', N'WallaWallaSymphony')
INSERT [dbo].[Theme] ([ThemeId], [Description], [Code], [SiteName]) VALUES (2, N'Pop', N'P', N'JulieAndThePlantes')
INSERT [dbo].[Theme] ([ThemeId], [Description], [Code], [SiteName]) VALUES (3, N'Rock', N'R', N'TheArchieBoyleBand')
GO

SET IDENTITY_INSERT [dbo].[Theme] OFF
GO
