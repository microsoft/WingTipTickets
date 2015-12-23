using Microsoft.Azure.SqlDatabase.ElasticScale.Query;
using Microsoft.Azure.SqlDatabase.ElasticScale.ShardManagement;
using Microsoft.Azure.SqlDatabase.ElasticScale.ShardManagement.Recovery;
using Microsoft.Practices.EnterpriseLibrary.TransientFaultHandling;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Threading;

namespace WingTipTickets
{
    public class HorizontalShard
    {
        #region Private Variables
        string connectionString = string.Empty, shardConnectionString = string.Empty, mapManagerName = string.Empty;
        public ShardMapManager ShardMapManager = null;
        ListShardMap<long> lsm = null;
        #endregion Private Variables

        #region Shard Map Manager Loading and Creation
        public HorizontalShard(string _mapManagerServer, string _userID, string _password, string _mapManagerName, string _secondaryDR)
        {
            connectionString = string.Format("Data Source={0};Initial Catalog={3};Integrated Security=False;User ID={1};Password={2};Encrypt=True", 
                                _mapManagerServer, _userID, _password, _mapManagerName);
            shardConnectionString = string.Format("Integrated Security=False;User ID={0};Password={1};Encrypt=True", _userID, _password);
            mapManagerName = _mapManagerName;

            if (!ShardMapManagerFactory.TryGetSqlShardMapManager(connectionString, ShardMapManagerLoadPolicy.Lazy, out ShardMapManager))
                ShardMapManager = null;
        }
        private bool CreateShardMapManager()
        {
            try
            {
                ShardMapManager = ShardMapManagerFactory.CreateSqlShardMapManager(connectionString);
                return true;
            }
            catch { ShardMapManager = null; return false; }
        }
        #endregion Shard Map Manager Loading and Creation

        #region Populate Shards
        public void PopulateShardListMap(List<Tuple<long, string>> ListMappings = null, bool SkipValidation = false)
        {
            // if map manager exists, refresh content, else create shard map, then add content
            if (ShardMapManager != null || CreateShardMapManager())
            {
                if (!SkipValidation) WingtipTicketApp.ValidateShardMap();
                RefreshShardListMap(ListMappings);
            }
        }
        private bool RefreshShardListMap(List<Tuple<long, string>> ListMappings = null)
        {
            try
            {
                string shardServer1 = WingtipTicketApp.Config.PrimaryDatabaseServer;
                string shardServer2 = WingtipTicketApp.Config.ShardDatabaseServer;
                string ticketsDbName = WingtipTicketApp.Config.TicketsDbName;
                Shard shard1 = null, shard2 = null;
                PointMapping<long> lmpg;

                // check if shard map manager exists and if not, create it (Idempotent / tolerant of re-execute) 
                if (!ShardMapManager.TryGetListShardMap(mapManagerName, out lsm))
                    lsm = ShardMapManager.CreateListShardMap<long>(mapManagerName);

                try
                {
                    // check if shard exists and if not, create it (Idempotent / tolerant of re-execute) 
                    if (!lsm.TryGetShard(new ShardLocation(shardServer1, ticketsDbName), out shard1))
                        shard1 = lsm.CreateShard(new ShardLocation(shardServer1, ticketsDbName));
                }
                catch // sometimes, it may throw an error stating that a concurrent user recently changed some settings.
                      //This is a retry logic to cover this scenario.
                {
                    Thread.Sleep(500);
                    // check if shard map manager exists and if not, create it (Idempotent / tolerant of re-execute) 
                    if (!ShardMapManager.TryGetListShardMap(mapManagerName, out lsm))
                        lsm = ShardMapManager.CreateListShardMap<long>(mapManagerName);
                    // check if shard exists and if not, create it (Idempotent / tolerant of re-execute) 
                    if (!lsm.TryGetShard(new ShardLocation(shardServer1, ticketsDbName), out shard1))
                        shard1 = lsm.CreateShard(new ShardLocation(shardServer1, ticketsDbName));
                }
                if (!lsm.TryGetShard(new ShardLocation(shardServer2, ticketsDbName), out shard2))
                    shard2 = lsm.CreateShard(new ShardLocation(shardServer2, ticketsDbName));

                // Check if mapping exists and if not, create it (Idempotent / tolerant of re-execute)
                
                if (ListMappings != null)
                    foreach (Tuple<long, string> mapping in ListMappings)
                        if (!lsm.TryGetMappingForKey(mapping.Item1, out lmpg))
                        {
                            if (mapping.Item2 == shardServer1)
                                lsm.CreatePointMapping(new PointMappingCreationInfo<long>(mapping.Item1, shard1, MappingStatus.Online));
                            else if (mapping.Item2 == shardServer2)
                                lsm.CreatePointMapping(new PointMappingCreationInfo<long>(mapping.Item1, shard2, MappingStatus.Online));
                        }
                return true;
                
            }
            catch { return false; }
        }
        #endregion Populate Shards

        #region Delete Shards
        public bool DeleteShardListMap()
        {
            try
            {
                if (ShardMapManager == null) return false;
                Shard tempShard = null;
                PointMapping<long> tempMapping = null;

                if (ShardMapManager.TryGetListShardMap(mapManagerName, out lsm))
                {
                    foreach (Shard shard in lsm.GetShards())
                    {
                        // delete all mappings
                        var allMappings = lsm.GetMappings(shard);
                        for (int i = 0; i < allMappings.Count; i++)
                        {
                            lsm.MarkMappingOffline(allMappings[i]);
                            if (lsm.TryGetMappingForKey(allMappings[i].Value, out tempMapping))
                                lsm.DeleteMapping(tempMapping);
                        }
                        // delete shard
                        if (lsm.TryGetShard(shard.Location, out tempShard))
                            lsm.DeleteShard(tempShard);
                    }
                }
                // clear shard map manager
                if (ShardMapManager.TryGetListShardMap(mapManagerName, out lsm))
                    ShardMapManager.DeleteShardMap(lsm);

                return true;
            }
            catch { return false; }
        }
        #endregion Delete Shards

        #region Queries
        public DataSet DataDependentRouteQuery(string commandText, long key)
        {
            DataSet _ds = new DataSet();
            try
            {
                RetryPolicy.DefaultExponential.ExecuteAction(() =>
                {
                    using (SqlCommand cmd = lsm.GetMappingForKey(key).Shard.OpenConnection(shardConnectionString, ConnectionOptions.Validate).CreateCommand())
                    {
                        cmd.CommandText = commandText;
                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                            { sda.Fill(_ds); }
                    }
                });
            }
            catch { _ds = null; }
            return _ds;
        }
        public DataSet MultiShardQuery(string commandText)
        {
            DataSet _ds = new DataSet();
            try
            {
                RetryPolicy.DefaultExponential.ExecuteAction(() =>
                {
                    using (MultiShardCommand cmd = new MultiShardConnection(lsm.GetShards(), shardConnectionString).CreateCommand())
                    {
                        cmd.CommandText = commandText;
                        cmd.CommandType = CommandType.Text;
                        cmd.ExecutionOptions = MultiShardExecutionOptions.None;
                        //04/23/2015 by Mark Berman - switched to Partial results versus CompleteResults as timeout exception was being thrown
                        cmd.ExecutionPolicy = MultiShardExecutionPolicy.PartialResults;
                        using (MultiShardDataReader sdr = cmd.ExecuteReader())
                        {
                            if (sdr.Read())
                            {
                                // the multi-shard query does not return a dataset or datarow.
                                // we have to manually re-create a table structure, then fill it with data.
                                object[] sqlValues = new object[sdr.FieldCount];
                                sdr.GetSqlValues(sqlValues);
                                DataTable dtValues = new DataTable();
                                foreach (var column in sqlValues)
                                    dtValues.Columns.Add(new DataColumn { DataType = column.GetType() });
                                _ds.Tables.Add(dtValues);
                                _ds.Tables[0].Rows.Add(sqlValues);
                                while (sdr.Read())
                                {
                                    sdr.GetSqlValues(sqlValues);
                                    _ds.Tables[0].Rows.Add(sqlValues);
                                }
                            }
                        }
                    }
                });
            }
            catch { _ds = null; }
            return _ds;
        }
        #endregion Queries
    }
}