IF OBJECT_ID('sqlt.DQC_DISTINCT_COLUMN_COUNT') IS NOT NULL
BEGIN
	DROP PROCEDURE  sqlt.DQC_DISTINCT_COLUMN_COUNT
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Martand Singh
-- Facebook: https://www.facebook.com/Codemakerz
-- Github: https://github.com/martandsingh
-- Create date: 14-Apr-2022
-- Description:	It will return distinct count for each column of the given table.
-- =============================================

CREATE PROCEDURE sqlt.DQC_DISTINCT_COLUMN_COUNT
  @table_name VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @DQC_TYPE VARCHAR(100) = 'DQC_DISTINCT_COLUMN_COUNT'

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
	@DISTINCT_COUNT BIGINT,
	@MESSAGE VARCHAR(500)

	SELECT 
	CAST('' AS VARCHAR(10)) AS DISTINCTCOUNT
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
		COUNT(DISTINCT('+@column_name+')) DISTINCTCOUNT
		FROM '+@schema_name+'.'+@table_name)

		SET @DISTINCT_COUNT = (SELECT DISTINCTCOUNT FROM #tempFinal)
		SET @MESSAGE = 'Ditinct count for '+@table_name+'.'+@column_name + ' is '+ CAST(@DISTINCT_COUNT AS VARCHAR(10));
		
		INSERT INTO sqlt.assertlog
		([object_name], column_name, column_type,assert_type ,actual_value  ,error,[message]  )
		VALUES
		(QUOTENAME(@schema_name+'.'+@table_name), @column_name, @datatype, @DQC_TYPE, CAST(@DISTINCT_COUNT AS BIGINT), NULL, @MESSAGE  )

		TRUNCATE TABLE #tempFinal
		SET @FLAG = @FLAG + 1
	END

	
END
GO
