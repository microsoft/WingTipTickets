-- ================================================================
-- Creating master key
-- ================================================================

IF (NOT EXISTS(SELECT * FROM sys.symmetric_keys WHERE name LIKE '%MS_DatabaseMasterKey%'))
BEGIN
	CREATE MASTER KEY;
END

-- ================================================================
-- Create a database scoped credential
-- ================================================================

IF (NOT EXISTS(SELECT * FROM sys.database_credentials WHERE Name = 'ASB_WTTCredential'))
BEGIN
	CREATE DATABASE SCOPED CREDENTIAL ASB_WTTCredential 
	WITH IDENTITY = 'wttdatacampdwwestus', SECRET = 'aAmHC7LQYx9Sz3f/wvUb0HW31+HqGC9at6FjqSy+O5TBy7j9Gn9LUO1L12sdoup8L4OBjOhpIQt1fCJ7rMoOyw=='
END;

-- ================================================================
-- Drop a database scoped credential
-- ================================================================

-- DROP DATABASE SCOPED CREDENTIAL ASB_WTTCredential;

-- ================================================================
-- Creating external data source (Azure Blob Storage)
-- ================================================================

IF (NOT EXISTS(SELECT * FROM sys.external_data_sources WHERE Name = 'wttdatacampwestus'))
BEGIN
	CREATE EXTERNAL DATA SOURCE wttdatacampwestus
	WITH (
		TYPE = HADOOP,
		LOCATION ='wasbs://wttdatacampdw@wttdatacampwestus.blob.core.windows.net',
		CREDENTIAL = ASB_WTTCredential
	)
END;

-- ================================================================
-- Creating external file format (tab delimited text file)
-- ================================================================

IF (NOT EXISTS(SELECT * FROM sys.external_file_formats WHERE Name = 'tab_delimited_text_file'))
BEGIN
	CREATE EXTERNAL FILE FORMAT tab_delimited_text_file
	WITH (
		FORMAT_TYPE = DELIMITEDTEXT,
		FORMAT_OPTIONS (
			FIELD_TERMINATOR ='\t',
			USE_TYPE_DEFAULT = TRUE
		)
	)
END;

-- ================================================================
-- Creating external file format (gzip tab delimited text file)
-- ================================================================

IF (NOT EXISTS(SELECT * FROM sys.external_file_formats WHERE Name = 'gzip_tab_delimited_text_file'))
BEGIN
	CREATE EXTERNAL FILE FORMAT gzip_tab_delimited_text_file
	WITH (
		FORMAT_TYPE = DELIMITEDTEXT,
		DATA_COMPRESSION = 'org.apache.hadoop.io.compress.GzipCodec',
		FORMAT_OPTIONS (
			FIELD_TERMINATOR ='\t',
			USE_TYPE_DEFAULT = TRUE
		)
	)
END;