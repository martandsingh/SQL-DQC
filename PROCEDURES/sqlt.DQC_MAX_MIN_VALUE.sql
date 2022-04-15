IF OBJECT_ID('sqlt.DQC_MAX_MIN_VALUE') IS NOT NULL
BEGIN
	DROP PROCEDURE  sqlt.DQC_MAX_MIN_VALUE
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Martand Singh
-- Facebook: https://www.facebook.com/Codemakerz
-- Github: https://github.com/martandsingh
-- Description:	This will return Max & Min value of numeric type columns.
-- =============================================
CREATE PROCEDURE sqlt.DQC_MAX_MIN_VALUE
  @table_name VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @DQC_TYPE VARCHAR(100) = 'DQC_MAX_MIN_VALUE'

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
	@MAX_VALUE VARCHAR(100),
	@MIN_VALUE VARCHAR(100),
	@MESSAGE VARCHAR(500)

	SELECT 
	CAST('' AS VARCHAR(100)) AS MAX_VAL,
	CAST('' AS VARCHAR(100)) AS MIN_VAL
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
		CASE WHEN '''+@datatype+''' IN (''int'', ''bigint'', ''money'', ''float'', ''decimal'', ''smallint'', ''tinyint'', ''datetime'', ''date'')  THEN MAX('+@column_name+') ELSE NULL END AS MAX_VAL,
		CASE WHEN '''+@datatype+''' IN (''int'', ''bigint'', ''money'', ''float'', ''decimal'', ''smallint'', ''tinyint'', ''datetime'', ''date'')  THEN MIN('+@column_name+') ELSE NULL END AS MIN_VAL
		FROM '+@schema_name+'.'+@table_name)

		SET @MAX_VALUE = (SELECT MAX_VAL FROM #tempFinal)
		SET @MIN_VALUE = (SELECT MIN_VAL FROM #tempFinal)
		
		INSERT INTO sqlt.assertlog
		([object_name], column_name, column_type,assert_type ,actual_value  ,error,[message]  )
		VALUES
		(QUOTENAME(@schema_name+'.'+@table_name), @column_name, @datatype, 'DQC_MAX_VALUE', CAST(@MAX_VALUE AS VARCHAR(100)), NULL
		, 'MAX VALUE OF '+@schema_name+'.'+@table_name+'.'+@column_name+' is '+CAST(@MAX_VALUE AS VARCHAR(100))  ),
		(QUOTENAME(@schema_name+'.'+@table_name), @column_name, @datatype, 'DQC_MIN_VALUE', CAST(@MIN_VALUE AS VARCHAR(100)), NULL
		, 'MIN VALUE OF '+@schema_name+'.'+@table_name+'.'+@column_name+' is '+CAST(@MIN_VALUE AS VARCHAR(100)))


		TRUNCATE TABLE #tempFinal
		SET @FLAG = @FLAG + 1
	END

	
END
GO
