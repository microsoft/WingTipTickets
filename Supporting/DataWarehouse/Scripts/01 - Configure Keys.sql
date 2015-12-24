-- ================================================================
-- Creating master key
-- ================================================================

CREATE MASTER KEY;

-- ================================================================
-- Check for existing database-scoped credentials.
-- ================================================================

SELECT * FROM sys.database_credentials;

-- ================================================================
-- Create a database scoped credential
-- ================================================================

CREATE DATABASE SCOPED CREDENTIAL ASB_MGRJULIEANDTHEPLANTES WITH IDENTITY = 'datawarehouse', SECRET = '/LhNxwWro4QWfoSUcJuhgwcvWwqv2ENNphPjm8sk59YlK0RE+4uPCjNcnW5LEsFV4Ao/N2Byc49s/YGTk2Im6w==';

-- ================================================================
-- Drop a database scoped credential
-- ================================================================

-- DROP DATABASE SCOPED CREDENTIAL ASB_MGRJULIEANDTHEPLANTES;

-- ================================================================
-- Creating external data source (Azure Blob Storage)
-- ================================================================

CREATE EXTERNAL DATA SOURCE ignitenz_azure_storage
WITH (
    TYPE = HADOOP
  , LOCATION ='wasbs://datawarehouse@mgrjulieandtheplantes.blob.core.windows.net/'
  , CREDENTIAL = ASB_MGRJULIEANDTHEPLANTES
);

-- ================================================================
-- Creating external file format (tab delimited text file)
-- ================================================================

CREATE EXTERNAL FILE FORMAT tab_delimited_text_file
WITH (
    FORMAT_TYPE = DELIMITEDTEXT
  , FORMAT_OPTIONS (
        FIELD_TERMINATOR ='\t'
      , USE_TYPE_DEFAULT = TRUE
    )
);

-- ================================================================
-- Creating external file format (gzip tab delimited text file)
-- ================================================================

CREATE EXTERNAL FILE FORMAT gzip_tab_delimited_text_file
WITH (
    FORMAT_TYPE = DELIMITEDTEXT
  , DATA_COMPRESSION = 'org.apache.hadoop.io.compress.GzipCodec'
  , FORMAT_OPTIONS (
        FIELD_TERMINATOR ='\t'
      , USE_TYPE_DEFAULT = TRUE
    )
);
