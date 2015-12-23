-- ======================================================================================================
-- DROP NON SYSTEM STORED PROCEDURES
-- ======================================================================================================

DECLARE @name VARCHAR(128)
DECLARE @SQL VARCHAR(254)

SELECT @name = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] = 'P' AND category = 0 ORDER BY [name])

WHILE @name is not null
BEGIN
    SELECT @SQL = 'DROP PROCEDURE [dbo].[' + RTRIM(@name) +']'
    EXEC (@SQL)
    PRINT 'Dropped Procedure: ' + @name
    SELECT @name = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] = 'P' AND category = 0 AND [name] > @name ORDER BY [name])
END
GO

-- ======================================================================================================
-- DROP ALL VIEWS
-- ======================================================================================================

DECLARE @name VARCHAR(128)
DECLARE @SQL VARCHAR(254)

SELECT @name = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] = 'V' AND category = 0 ORDER BY [name])

WHILE @name IS NOT NULL
BEGIN
    SELECT @SQL = 'DROP VIEW [dbo].[' + RTRIM(@name) +']'
    EXEC (@SQL)
    PRINT 'Dropped View: ' + @name
    SELECT @name = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] = 'V' AND category = 0 AND [name] > @name ORDER BY [name])
END
GO

-- ======================================================================================================
-- DROP ALL FUNCTIONS
-- ======================================================================================================

DECLARE @name VARCHAR(128)
DECLARE @SQL VARCHAR(254)

SELECT @name = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] IN (N'FN', N'IF', N'TF', N'FS', N'FT') AND category = 0 ORDER BY [name])

WHILE @name IS NOT NULL
BEGIN
    SELECT @SQL = 'DROP FUNCTION [dbo].[' + RTRIM(@name) +']'
    EXEC (@SQL)
    PRINT 'Dropped Function: ' + @name
    SELECT @name = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] IN (N'FN', N'IF', N'TF', N'FS', N'FT') AND category = 0 AND [name] > @name ORDER BY [name])
END
GO

-- ======================================================================================================
-- DROP ALL FOREIGN KEY CONSTRAINTS
-- ======================================================================================================

DECLARE @name VARCHAR(128)
DECLARE @constraint VARCHAR(254)
DECLARE @SQL VARCHAR(254)

SELECT @name = (SELECT TOP 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'FOREIGN KEY' ORDER BY TABLE_NAME)

WHILE @name is not null
BEGIN
    SELECT @constraint = (SELECT TOP 1 CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'FOREIGN KEY' AND TABLE_NAME = @name ORDER BY CONSTRAINT_NAME)
    WHILE @constraint IS NOT NULL
    BEGIN
        SELECT @SQL = 'ALTER TABLE [dbo].[' + RTRIM(@name) +'] DROP CONSTRAINT [' + RTRIM(@constraint) +']'
        EXEC (@SQL)
        PRINT 'Dropped FK Constraint: ' + @constraint + ' on ' + @name
        SELECT @constraint = (SELECT TOP 1 CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'FOREIGN KEY' AND CONSTRAINT_NAME <> @constraint AND TABLE_NAME = @name ORDER BY CONSTRAINT_NAME)
    END
SELECT @name = (SELECT TOP 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'FOREIGN KEY' ORDER BY TABLE_NAME)
END
GO

-- ======================================================================================================
-- DROP ALL PRIMARY KEY CONSTRAINTS
-- ======================================================================================================

DECLARE @name VARCHAR(128)
DECLARE @constraint VARCHAR(254)
DECLARE @SQL VARCHAR(254)

SELECT @name = (SELECT TOP 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' ORDER BY TABLE_NAME)

WHILE @name IS NOT NULL
BEGIN
    SELECT @constraint = (SELECT TOP 1 CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' AND TABLE_NAME = @name ORDER BY CONSTRAINT_NAME)
    WHILE @constraint is not null
    BEGIN
        SELECT @SQL = 'ALTER TABLE [dbo].[' + RTRIM(@name) +'] DROP CONSTRAINT [' + RTRIM(@constraint)+']'
        EXEC (@SQL)
        PRINT 'Dropped PK Constraint: ' + @constraint + ' on ' + @name
        SELECT @constraint = (SELECT TOP 1 CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' AND CONSTRAINT_NAME <> @constraint AND TABLE_NAME = @name ORDER BY CONSTRAINT_NAME)
    END
SELECT @name = (SELECT TOP 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' ORDER BY TABLE_NAME)
END
GO

-- ======================================================================================================
-- DROP ALL TABLES
-- ======================================================================================================

DECLARE @name VARCHAR(128)
DECLARE @SQL VARCHAR(254)

SELECT @name = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] = 'U' AND category = 0 ORDER BY [name])

WHILE @name IS NOT NULL
BEGIN
    SELECT @SQL = 'DROP TABLE [dbo].[' + RTRIM(@name) +']'
    EXEC (@SQL)
    PRINT 'Dropped Table: ' + @name
    SELECT @name = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] = 'U' AND category = 0 AND [name] > @name ORDER BY [name])
END
GO

-- ======================================================================================================
-- SP_DELETE_TENANT STORED PROCEDURE
-- ======================================================================================================

CREATE PROCEDURE [dbo].[Sp_Delete_Tenant]
	@Username varchar(150)
AS
BEGIN
	BEGIN TRANSACTION DeleteTenant

	BEGIN TRY
		DECLARE @UserAccountId int
		SELECT  @UserAccountId = UserAccountId
		FROM	UserAccount
		WHERE	Username = @Username

		DELETE FROM Tenant
		WHERE UserAccountId = @UserAccountId
		
		DELETE FROM CreditCard
		WHERE UserAccountId = @UserAccountId

		DELETE FROM UserAccount
		WHERE UserAccountId = @UserAccountId

		COMMIT TRANSACTION DeleteTenant
	END TRY

	BEGIN CATCH
	  ROLLBACK TRANSACTION DeleteTenant
	END CATCH
END
GO

-- ======================================================================================================
-- SP_FETCH_PROVISIONINGPIPELINETASKS STORED PROCEDURE
-- ======================================================================================================

CREATE PROCEDURE [dbo].[Sp_Fetch_ProvisioningPipelineTasks]
	@ProvisioningOptionId int
AS
BEGIN
	SELECT		P.[ProvisioningPipelineId],
				P.[Position],
				P.[SequenceNo],
				P.[GroupNo],
				T.[Description] AS 'TaskDescription',
				T.[Code] AS 'TaskCode',
				P.[WaitForCompletion]
	FROM		ProvisioningPipelineTasks P
	JOIN		ProvisioningTask T ON P.ProvisioningTaskId = T.ProvisioningTaskId
	WHERE		ProvisioningOptionId = @ProvisioningOptionId
	ORDER BY	P.SequenceNo
END
GO

-- ======================================================================================================
-- SP_FETCH_TENANT_BYID STORED PROCEDURE
-- ======================================================================================================

CREATE PROCEDURE [dbo].[Sp_Fetch_Tenant_ById]
	@TenantId int
AS
BEGIN
	SELECT		T.[TenantId],
				T.[UserAccountId],
				T.[ThemeId],
				H.[Description] AS 'Theme',
				H.[Code] AS 'ThemeCode',
				T.[ProvisioningOptionId],
				T.[AzureServicesProvisioned],
				O.[Description] AS 'ProvisioningOption',
				O.[Code] AS 'ProvisioningOptionCode',
				T.[SiteName],
				T.[DataCenter],
				T.[OrganizationId],
				T.[SubscriptionId],
				A.[Username]
	FROM		[Tenant] T
	LEFT JOIN	[ProvisioningOption] O ON T.ProvisioningOptionId = O.ProvisioningOptionId
	LEFT JOIN	[Theme] H ON T.ThemeId = H.ThemeId
	LEFT JOIN	[UserAccount] A ON T.UserAccountId = A.UserAccountId
	WHERE		T.TenantId = @TenantId
END
GO

-- ======================================================================================================
-- SP_FETCH_TENANTS_BYUSERNAME STORED PROCEDURE
-- ======================================================================================================

CREATE PROCEDURE [dbo].[Sp_Fetch_Tenants_ByUsername]
	@Username varchar(150)
AS
BEGIN
	SELECT		T.[TenantId],
				T.[UserAccountId],
				T.[ThemeId],
				H.[Description] AS 'Theme',
				H.[Code] AS 'ThemeCode',
				T.[ProvisioningOptionId],
				T.[AzureServicesProvisioned],
				O.[Description] AS 'ProvisioningOption',
				O.[Code] AS 'ProvisioningOptionCode',
				T.[SiteName],
				T.[DataCenter],
				T.[OrganizationId],
				T.[SubscriptionId]
	FROM		[Tenant] T
	LEFT JOIN	[ProvisioningOption] O ON T.ProvisioningOptionId = O.ProvisioningOptionId
	LEFT JOIN	[Theme] H ON T.ThemeId = H.ThemeId
	LEFT JOIN	[UserAccount] A ON T.UserAccountId = A.UserAccountId
	WHERE		A.Username = @Username
END
GO

-- ======================================================================================================
-- SP_FETCH_TENANTS STORED PROCEDURE
-- ======================================================================================================

CREATE PROCEDURE [dbo].[Sp_Fetch_Tenants]
AS
BEGIN
	SELECT	T.[TenantId],
			T.[UserAccountId],
			T.[ThemeId],
			H.[Description] AS 'Theme',
			T.[ProvisioningOptionId],
			T.[AzureServicesProvisioned],
			O.[Description] AS 'ProvisioningOption',
			O.[Code] as 'ProvisioningOptionCode',
			T.[SiteName],
			T.[DataCenter],
			A.[Username]
	FROM	[Tenant] T
	JOIN	[UserAccount] A ON T.UserAccountId = A.UserAccountId
	JOIN	[ProvisioningOption] O ON T.ProvisioningOptionId = O.ProvisioningOptionId
	JOIN	[Theme] H ON T.ThemeId = H.ThemeId
END
GO

-- ======================================================================================================
-- SP_UPSERT_USERACCOUNT STORED PROCEDURE
-- ======================================================================================================

CREATE PROCEDURE [dbo].[Sp_Fetch_UserAccount]
	@Username varchar(150)
AS
BEGIN
	SELECT	[UserAccountId],
			[Firstname],
			[lastname],
			[Username],
			[Password],
			[CachedData],
			[UpdateDate]
	FROM	UserAccount
	WHERE	Username = @Username
END
GO

-- ======================================================================================================
-- SP_INSERT_CREDITCARD STORED PROCEDURE
-- ======================================================================================================

CREATE PROCEDURE [dbo].[Sp_Insert_CreditCard]
	@UserAccountId int,
	@CardNumber varchar(20),
	@ExpirationDate varchar(20),
	@CardVerificationValue varchar(3)
AS
BEGIN
	INSERT INTO CreditCard
	(
		[UserAccountId], 
		[CardNumber], 
		[ExpirationDate], 
		[CardVerificationValue]
	)
	VALUES
	(
		@UserAccountId,
		@CardNumber,
		@ExpirationDate,
		@CardVerificationValue
	)

	SELECT SCOPE_IDENTITY() AS RecordId
END
GO

-- ======================================================================================================
-- SP_INSERT_TENANT STORED PROCEDURE
-- ======================================================================================================

CREATE PROCEDURE [dbo].[Sp_Insert_Tenant]
	@UserAccountId int,
	@ProvisioningOptionId int,
	@ThemeId int,
	@SiteName varchar(100),
	@DataCenter varchar(150),
	@OrganizationId varchar(50),
	@SubscriptionId varchar(50)
AS
BEGIN
	INSERT INTO Tenant 
	(
		[UserAccountId],
		[ProvisioningOptionId],
		[ThemeId],
		[SiteName],
		[DataCenter],
		[AzureServicesProvisioned],
		[OrganizationId],
		[SubscriptionId]
	)
	VALUES
	(
		@UserAccountId,
		@ProvisioningOptionId,
		@ThemeId,
		@SiteName,
		@DataCenter,
		0,
		@OrganizationId,
		@SubscriptionId
	)

	SELECT SCOPE_IDENTITY() AS RecordId
END
GO

-- ======================================================================================================
-- SP_INSERT_USERACCOUNT STORED PROCEDURE
-- ======================================================================================================

CREATE PROCEDURE [dbo].[Sp_Insert_UserAccount]
	@FirstName varchar(150),
	@LastName varchar(150),
	@UserName varchar(150),
	@CachedData varbinary(Max),
	@UpdateDate datetime
AS
BEGIN
	INSERT INTO UserAccount
	(
		[Firstname],
		[Lastname],
		[Username],
		[CachedData], 
		[UpdateDate]
	)
	VALUES
	(
		@FirstName,
		@LastName,
		@Username,
		@CachedData,
		@UpdateDate
	)

	SELECT SCOPE_IDENTITY() AS RecordId
END
GO

-- ======================================================================================================
-- SP_UPSERT_AZURESERVICESPROVISIONED STORED PROCEDURE
-- ======================================================================================================

CREATE PROCEDURE [dbo].[Sp_Update_Tenant_AzureServicesProvisioned]
	@TenantId int,
	@AzureServicesProvisioned bit
AS
BEGIN
	UPDATE Tenant 
	SET	AzureServicesProvisioned = @AzureServicesProvisioned
	WHERE TenantId = @TenantId
END
GO

-- ======================================================================================================
-- SP_UPDATE_USERACCOUNT STORED PROCEDURE
-- ======================================================================================================

CREATE PROCEDURE [dbo].[Sp_Update_UserAccount]
	@Username varchar(150),
	@Firstname varchar(150),
	@Lastname varchar(150)
AS
BEGIN
	UPDATE	UserAccount
	SET		Firstname = @Firstname,
			Lastname = @Lastname
	WHERE	Username = @Username
END
GO

-- ======================================================================================================
-- SP_UPDATE_USERACCOUNT_CACHEDATA STORED PROCEDURE
-- ======================================================================================================

CREATE PROCEDURE [dbo].[Sp_Update_UserAccount_CacheData]
	@Username varchar(150),
	@CachedData varbinary(Max),
	@UpdateDate datetime
AS
BEGIN
	UPDATE	UserAccount
	SET		CachedData = @CachedData,
			UpdateDate = @UpdateDate
	WHERE	Username = @Username
END
GO

-- ======================================================================================================
-- CREDIT CARD TABLE
-- ======================================================================================================

CREATE TABLE [dbo].[CreditCard]
		(
	[CreditCardId] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[UserAccountId] [int] NULL,
	[CardNumber] [varchar](20) NULL,
	[ExpirationDate] [varchar](20) NULL,
	[CardVerificationValue] [varchar](3) NULL,
)
GO

-- ======================================================================================================
-- LOCATION TABLE
-- ======================================================================================================

CREATE TABLE [dbo].[Location]
(
	[LocationId] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Description] [varchar](100) NULL,
	[Code] [varchar](20) NULL,
)
GO

-- ======================================================================================================
-- PROVISIONING OPTION TABLE
-- ======================================================================================================

CREATE TABLE [dbo].[ProvisioningOption]
(
	[ProvisioningOptionId] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Description] [varchar](100) NULL,
	[Code] [varchar](10) NULL,
)
GO

-- ======================================================================================================
-- PROVISIONING PIPELINE TASKS TABLE
-- ======================================================================================================

CREATE TABLE [dbo].[ProvisioningPipelineTasks]
(
	[ProvisioningPipelineId] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[ProvisioningOptionId] [int] NULL,
	[ProvisioningTaskId] [int] NULL,
	[Position] [varchar](20) NOT NULL,
	[SequenceNo] [int] NOT NULL,
	[GroupNo] [int] NULL,
	[WaitForCompletion] [bit] NULL,
)
GO

-- ======================================================================================================
-- PROVISIONING TASK TABLE
-- ======================================================================================================

CREATE TABLE [dbo].[ProvisioningTask]
(
	[ProvisioningTaskId] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Description] [varchar](100) NULL,
	[Code] [varchar](30) NULL,
)
GO

-- ======================================================================================================
-- TENANT TABLE
-- ======================================================================================================

CREATE TABLE [dbo].[Tenant]
(
	[TenantId] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[UserAccountId] [int] NULL,
	[ThemeId] [int] NULL,
	[ProvisioningOptionId] [int] NULL,
	[DataCenter] [varchar](150) NULL,
	[AzureServicesProvisioned] [bit] NOT NULL,
	[SiteName] [varchar](100) NULL,
	[OrganizationId] [varchar](50) NULL,
	[SubscriptionId] [varchar](50) NULL,
)
GO

-- ======================================================================================================
-- THEME TABLE
-- ======================================================================================================

CREATE TABLE [dbo].[Theme]
(
	[ThemeId] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Description] [varchar](100) NULL,
	[Code] [varchar](10) NULL,
	[SiteName] [varchar](200) NULL,
)
GO

-- ======================================================================================================
-- USER ACCOUNT TABLE
-- ======================================================================================================

CREATE TABLE [dbo].[UserAccount]
(
	[UserAccountId] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Firstname] [varchar](150) NULL,
	[Lastname] [varchar](150) NULL,
	[Username] [varchar](150) NULL,
	[Password] [varchar](20) NULL,
	[CachedData] [varbinary](max) NULL,
	[UpdateDate] [datetime] NULL,
)
GO
