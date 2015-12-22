using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using TenantProvisioning.Core.Helpers;

namespace TenantProvisioning.Core.Repositories
{
    class BaseRepository
    {
        #region - Fields -

        private readonly SqlConnection _connection;

        #endregion

        #region - Constructors -

        public BaseRepository()
        {
            _connection = new SqlConnection(Settings.ConnectionString);
        }

        #endregion

        #region - Private Methods -

        private SqlCommand CreateCommand(string commandText, CommandType commandType, List<SqlParameter> parameters = null)
        {
            // Build up the Command
            var command = new SqlCommand()
            {
                CommandText = commandText,
                CommandType = commandType,
                Connection = _connection
            };

            if (parameters != null)
            {
                command.Parameters.AddRange(parameters.ToArray());
            }

            return command;
        }

        #endregion

        #region - Protected Methods -

        protected DataSet FetchAllData(string tableName)
        {
            var dataset = new DataSet();

            try
            {
                // Open connection
                _connection.Open();

                // Build up the Sql
                var sql = string.Format("SELECT * FROM {0}", tableName);

                // Build up the Command
                var command = CreateCommand(sql, CommandType.Text);

                // ProvisionComponent the Command
                var adapter = new SqlDataAdapter(command);

                adapter.Fill(dataset);
            }
            finally
            {
                // Close connection
                _connection.Close();
            }

            return dataset;
        }

        protected DataSet FetchFilteredData(string procedureName, List<SqlParameter> parameters)
        {
            var dataset = new DataSet();

            try
            {
                // Open connection
                _connection.Open();

                // Build up the Command
                var command = CreateCommand(procedureName, CommandType.StoredProcedure, parameters);

                // ProvisionComponent the Command
                var adapter = new SqlDataAdapter(command);

                adapter.Fill(dataset);

            }
            finally
            {
                // Close connection
                _connection.Close();
            }

            return dataset;
        }

        protected int InsertData(string procedureName, List<SqlParameter> parameters)
        {
            var recordId = -1;

            try
            {
                // Open connection
                _connection.Open();

                // Build up the Command
                var command = CreateCommand(procedureName, CommandType.StoredProcedure, parameters);

                // ProvisionComponent the Command
                var response = command.ExecuteScalar();
                if (response != null)
                {
                    recordId = Convert.ToInt32(response);
                }
            }
            finally
            {
                // Close connection
                _connection.Close();
            }

            return recordId;
        }

        protected int UpdateData(string procedureName, List<SqlParameter> parameters)
        {
            var rowsAffected = -1;

            try
            {
                // Open connection
                _connection.Open();

                // Build up the Command
                var command = CreateCommand(procedureName, CommandType.StoredProcedure, parameters);

                // ProvisionComponent the Command
                rowsAffected = command.ExecuteNonQuery();
            }
            finally
            {
                // Close connection
                _connection.Close();
            }

            return rowsAffected;
        }

        protected SqlParameter CreateParameter(string parameterName, SqlDbType dbType, object value)
        {
            var parameter = new SqlParameter(parameterName, dbType)
            {
                Value = value
            };

            return parameter;
        }

        protected DataTable GetFirstDataSetTable(DataSet dataset)
        {
            return dataset.Tables.Count > 0
                ? dataset.Tables[0]
                : null;
        }

        protected TDataType Cast<TDataType>(object value, TDataType nullValue)
        {
            return value.ToString().Equals(string.Empty)
                ? nullValue
                : (TDataType)value;
        }

        protected TDataType Cast<TDataType>(object value)
        {
            return Cast(value, default(TDataType));
        }

        #endregion
    }
}
