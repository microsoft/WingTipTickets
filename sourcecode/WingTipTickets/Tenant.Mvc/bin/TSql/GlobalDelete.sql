If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Scalar_Function' And Name = 'fnGetStoreVersionMajorGlobal')
    Drop FUNCTION [__ShardManagement].[fnGetStoreVersionMajorGlobal]
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spAddShardingSchemaInfoGlobal')
    Drop Procedure [__ShardManagement].spAddShardingSchemaInfoGlobal;
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spAddShardMapGlobal')
    Drop Procedure [__ShardManagement].spAddShardMapGlobal;
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spAttachShardGlobal')
    Drop Procedure [__ShardManagement].spAttachShardGlobal;
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spBulkOperationShardMappingsGlobalBegin')
    Drop Procedure [__ShardManagement].spBulkOperationShardMappingsGlobalBegin;
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spBulkOperationShardMappingsGlobalEnd')
    Drop Procedure [__ShardManagement].spBulkOperationShardMappingsGlobalEnd;
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spBulkOperationShardsGlobalBegin')
    Drop Procedure [__ShardManagement].spBulkOperationShardsGlobalBegin;
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spBulkOperationShardsGlobalEnd')
    Drop Procedure [__ShardManagement].spBulkOperationShardsGlobalEnd;
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spDetachShardGlobal')
    Drop Procedure [__ShardManagement].spDetachShardGlobal;
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spFindAndUpdateOperationLogEntryByIdGlobal')
    Drop Procedure [__ShardManagement].spFindAndUpdateOperationLogEntryByIdGlobal;
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spFindShardByLocationGlobal')
	Drop Procedure [__ShardManagement].spFindShardByLocationGlobal
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spFindShardingSchemaInfoByNameGlobal')
	Drop Procedure [__ShardManagement].spFindShardingSchemaInfoByNameGlobal
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spFindShardMapByNameGlobal')
	Drop Procedure [__ShardManagement].spFindShardMapByNameGlobal
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spFindShardMappingByIdGlobal')
	Drop Procedure [__ShardManagement].spFindShardMappingByIdGlobal
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spFindShardMappingByKeyGlobal')
	Drop Procedure [__ShardManagement].spFindShardMappingByKeyGlobal
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spGetAllDistinctShardLocationsGlobal')
	Drop Procedure [__ShardManagement].spGetAllDistinctShardLocationsGlobal
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spGetAllShardingSchemaInfosGlobal')
	Drop Procedure [__ShardManagement].spGetAllShardingSchemaInfosGlobal
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spGetAllShardMappingsGlobal')
	Drop Procedure [__ShardManagement].spGetAllShardMappingsGlobal
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spGetAllShardMapsGlobal')
	Drop Procedure [__ShardManagement].spGetAllShardMapsGlobal
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spGetAllShardsGlobal')
	Drop Procedure [__ShardManagement].spGetAllShardsGlobal
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spGetOperationLogEntryGlobalHelper')
	Drop Procedure [__ShardManagement].spGetOperationLogEntryGlobalHelper
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spGetStoreVersionGlobalHelper')
	Drop Procedure [__ShardManagement].spGetStoreVersionGlobalHelper
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spLockOrUnlockShardMappingsGlobal')
	Drop Procedure [__ShardManagement].spLockOrUnlockShardMappingsGlobal
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spRemoveShardingSchemaInfoGlobal')
	Drop Procedure [__ShardManagement].spRemoveShardingSchemaInfoGlobal
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spRemoveShardMapGlobal')
	Drop Procedure [__ShardManagement].spRemoveShardMapGlobal
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spReplaceShardMappingsGlobal')
	Drop Procedure [__ShardManagement].spReplaceShardMappingsGlobal
If Exists (Select * From sys.objects Where Type_Desc = 'Sql_Stored_Procedure' And Name = 'spUpdateShardingSchemaInfoGlobal')
	Drop Procedure [__ShardManagement].spUpdateShardingSchemaInfoGlobal
If EXISTS (Select * From sys.objects Where Object_Id = Object_Id(N'[__ShardManagement].[OperationsLogGlobal]') And Type In (N'U'))
	Drop Table [__ShardManagement].[OperationsLogGlobal]
If EXISTS (Select * From sys.objects Where Object_Id = Object_Id(N'[__ShardManagement].[ShardedDatabaseSchemaInfosGlobal]') And Type In (N'U'))
	Drop Table [__ShardManagement].[ShardedDatabaseSchemaInfosGlobal]
If EXISTS (Select * From sys.objects Where Object_Id = Object_Id(N'[__ShardManagement].[ShardMapManagerGlobal]') And Type In (N'U'))
	Drop Table [__ShardManagement].[ShardMapManagerGlobal]
If EXISTS (Select * From sys.objects Where Object_Id = Object_Id(N'[__ShardManagement].[ShardMappingsGlobal]') And Type In (N'U'))
	Drop Table [__ShardManagement].[ShardMappingsGlobal]
If EXISTS (Select * From sys.objects Where Object_Id = Object_Id(N'[__ShardManagement].[ShardsGlobal]') And Type In (N'U'))
	Drop Table [__ShardManagement].[ShardsGlobal]
If EXISTS (Select * From sys.objects Where Object_Id = Object_Id(N'[__ShardManagement].[ShardMapsGlobal]') And Type In (N'U'))
	Drop Table [__ShardManagement].[ShardMapsGlobal]