If Exists (Select * From sys.objects Where  type_desc = 'Sql_Scalar_Function' And Name = 'fnGetStoreVersionMajorLocal')
	Drop FUNCTION [__ShardManagement].[fnGetStoreVersionMajorLocal]
If Exists (Select * From sys.objects Where  type_desc = 'Sql_Stored_Procedure' And Name = 'spAddShardLocal')
	Drop Procedure [__ShardManagement].[spAddShardLocal]
If Exists (Select * From sys.objects Where  type_desc = 'Sql_Stored_Procedure' And Name = 'spBulkOperationShardMappingsLocal')
	Drop Procedure [__ShardManagement].[spBulkOperationShardMappingsLocal]
If Exists (Select * From sys.objects Where  type_desc = 'Sql_Stored_Procedure' And Name = 'spFindShardMappingByKeyLocal')
	Drop Procedure [__ShardManagement].[spFindShardMappingByKeyLocal]
If Exists (Select * From sys.objects Where  type_desc = 'Sql_Stored_Procedure' And Name = 'spGetAllShardMappingsLocal')
	Drop Procedure [__ShardManagement].[spGetAllShardMappingsLocal]
If Exists (Select * From sys.objects Where  type_desc = 'Sql_Stored_Procedure' And Name = 'spGetAllShardsLocal')
	Drop Procedure [__ShardManagement].[spGetAllShardsLocal]
If Exists (Select * From sys.objects Where  type_desc = 'Sql_Stored_Procedure' And Name = 'spGetStoreVersionLocalHelper')
	Drop Procedure [__ShardManagement].[spGetStoreVersionLocalHelper]
If Exists (Select * From sys.objects Where  type_desc = 'Sql_Stored_Procedure' And Name = 'spKillSessionsForShardMappingLocal')
	Drop Procedure [__ShardManagement].[spKillSessionsForShardMappingLocal]
If Exists (Select * From sys.objects Where  type_desc = 'Sql_Stored_Procedure' And Name = 'spRemoveShardLocal')
	Drop Procedure [__ShardManagement].[spRemoveShardLocal]
If Exists (Select * From sys.objects Where  type_desc = 'Sql_Stored_Procedure' And Name = 'spUpdateShardLocal')
	Drop Procedure [__ShardManagement].[spUpdateShardLocal]
If Exists (Select * From sys.objects Where  type_desc = 'Sql_Stored_Procedure' And Name = 'spValidateShardLocal')
	Drop Procedure [__ShardManagement].[spValidateShardLocal]
If Exists (Select * From sys.objects Where  type_desc = 'Sql_Stored_Procedure' And Name = 'spValidateShardMappingLocal')
	Drop Procedure [__ShardManagement].[spValidateShardMappingLocal]
If Exists (Select * From sys.objects Where Object_Id = Object_Id(N'[__ShardManagement].[ShardMapManagerLocal]') And Type In (N'U'))
	Drop Table [__ShardManagement].[ShardMapManagerLocal]
If Exists (Select * From sys.objects Where Object_Id = Object_Id(N'[__ShardManagement].[ShardMappingsLocal]') And Type In (N'U'))
	Drop Table [__ShardManagement].[ShardMappingsLocal]
If Exists (Select * From sys.objects Where Object_Id = Object_Id(N'[__ShardManagement].[ShardsLocal]') And Type In (N'U'))
	Drop Table [__ShardManagement].[ShardsLocal]
If Exists (Select * From sys.objects Where Object_Id = Object_Id(N'[__ShardManagement].[ShardMapsLocal]') And Type In (N'U'))
	Drop Table [__ShardManagement].[ShardMapsLocal]