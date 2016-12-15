namespace IOTSoundReaderEmulator.Helpers
{
    public static class Helper
    {
        #region - Public Methods -

        public static string BuildConnectionString(string databaseServer, string database, string username, string password, bool runningInDev)
        {
            var server = databaseServer.Split('.');

            if (runningInDev)
            {
                return $"Server={server[0]};Database={database};User ID={username};Password={password};Connection Timeout=30;";
            }

            return $"Server=tcp:{databaseServer + CloudConfiguration.UnsecuredDatabaseUrl},1433;Database={database};User ID={username}@{server[0]};Password={password};Trusted_Connection=False;Encrypt=True;Connection Timeout=30;";
        }

        #endregion
    }
}
