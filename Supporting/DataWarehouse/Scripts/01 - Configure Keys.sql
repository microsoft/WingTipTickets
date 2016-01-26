-- ================================================================
-- Creating master key
-- ================================================================

CREATE MASTER KEY

-- ================================================================
-- Check for existing database-scoped credentials.
-- ================================================================

SELECT * FROM sys.database_credentials

-- ================================================================
-- Create the database scoped credential
-- ================================================================

--CREATE DATABASE SCOPED CREDENTIAL ASB_WTTCredential WITH IDENTITY = 'wttdatacampdwwestus', SECRET = 'rzJSwj4pSgxZAQV9bq3oCWmQmho3ZI0zm6lA6PdIdbWVDk36IgvTVBsC6exoMiu9cEBXDxLVeNtkNQfJnVutlQ==';

-- ================================================================
-- Drop the database scoped credential
-- ================================================================

-- DROP DATABASE SCOPED CREDENTIAL ASB_WTTCredential;

-- ================================================================
-- Creating external data source (Azure Blob Storage)
-- ================================================================

-- CREATE EXTERNAL DATA SOURCE ignitenz_azure_storage
-- WITH (
    -- TYPE = HADOOP
  -- , LOCATION ='wasbs://datawarehouse@mgrjulieandtheplantes.blob.core.windows.net/'
  -- , CREDENTIAL = ASB_WTTCredential
-- );

-- -- ================================================================
-- -- Creating external file format (tab delimited text file)
-- -- ================================================================

-- CREATE EXTERNAL FILE FORMAT tab_delimited_text_file
-- WITH (
    -- FORMAT_TYPE = DELIMITEDTEXT
  -- , FORMAT_OPTIONS (
        -- FIELD_TERMINATOR ='\t'
      -- , USE_TYPE_DEFAULT = TRUE
    -- )
-- );

-- -- ================================================================
-- -- Creating external file format (gzip tab delimited text file)
-- -- ================================================================

-- CREATE EXTERNAL FILE FORMAT gzip_tab_delimited_text_file
-- WITH (
    -- FORMAT_TYPE = DELIMITEDTEXT
  -- , DATA_COMPRESSION = 'org.apache.hadoop.io.compress.GzipCodec'
  -- , FORMAT_OPTIONS (
        -- FIELD_TERMINATOR ='\t'
      -- , USE_TYPE_DEFAULT = TRUE
    -- )
-- );
