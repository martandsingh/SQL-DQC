IF OBJECT_ID('sqlt.DQC_MAX_MIN_LENGTH') IS NOT NULL
BEGIN
	DROP PROCEDURE  sqlt.DQC_MAX_MIN_LENGTH
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Martand Singh
-- Facebook: https://www.facebook.com/Codemakerz
-- Github: https://github.com/martandsingh
-- Description:	This will return Max & Min length of string type column.
-- =============================================
CREATE PROCEDURE [sqlt].[DQC_MAX_MIN_LENGTH]
  @table_name VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @DQC_TYPE VARCHAR(100) = 'DQC_MAX_MIN_LENGTH'

	IF OBJECT_ID('tempdb.dbo.#tempDetails') IS NOT NULL
	BEGIN
		DROP TABLE #tempDetails;
	END

	IF OBJECT_ID('tempdb.dbo.#tempFinal') IS NOT NULL
	BEGIN
		DROP TABLE #tempFinal;
	END

	SELECT * INTO #tempDetails
	FROM sqlt.VW_TABLE_DETAILS T
	WHERE  T.TableName = @table_name

	DECLARE @FLAG INT =1,
	@column_name VARCHAR(100),
	@schema_name VARCHAR(50),
	@datatype VARCHAR(50),
	@MAX_VALUE INT,
	@MIN_VALUE INT,
	@MESSAGE VARCHAR(500)

	SELECT 
	CAST('' AS VARCHAR(10)) AS MAX_LENGTH,
	CAST('' AS VARCHAR(10)) AS MIN_LENGTH
	INTO #tempFinal

	TRUNCATE TABLE #tempFinal

	WHILE @FLAG <= (SELECT MAX(ID) FROM #tempDetails)
	BEGIN
		SELECT
		@column_name = ColumnName,
		@datatype = DataType,
		@schema_name = SchemaName
		FROM #tempDetails 
		WHERE ID = @FLAG
		
		
		EXEC('
		INSERT INTO #tempFinal
		SELECT
		CASE WHEN '''+@datatype+''' IN (''varchar'', ''nvarchar'', ''nchar'', ''char'')  THEN MAX(LEN('+@column_name+')) ELSE NULL END AS MAX_LENGTH,
		CASE WHEN '''+@datatype+''' IN (''varchar'', ''nvarchar'', ''nchar'', ''char'')  THEN MIN(LEN('+@column_name+')) ELSE NULL END AS MIN_LENGTH
		FROM '+@schema_name+'.'+@table_name)

		SET @MAX_VALUE = (SELECT MAX_LENGTH FROM #tempFinal)
		SET @MIN_VALUE = (SELECT MIN_LENGTH FROM #tempFinal)
		
		INSERT INTO sqlt.assertlog
		([object_name], column_name, column_type,assert_type ,actual_value  ,error,[message]  )
		VALUES
		(QUOTENAME(@schema_name+'.'+@table_name), @column_name, @datatype, 'DQC_MAX_LENGTH', CAST(@MAX_VALUE AS INT), NULL
		, 'MAX LENGTH OF '+@schema_name+'.'+@table_name+'.'+@column_name+' is '+CAST(@MAX_VALUE AS VARCHAR(10))  ),
		(QUOTENAME(@schema_name+'.'+@table_name), @column_name, @datatype, 'DQC_MIN_LENGTH', CAST(@MIN_VALUE AS INT), NULL
		, 'MIN LENGTH OF '+@schema_name+'.'+@table_name+'.'+@column_name+' is '+CAST(@MIN_VALUE AS VARCHAR(10)))


		TRUNCATE TABLE #tempFinal
		SET @FLAG = @FLAG + 1
	END

	
END
GO