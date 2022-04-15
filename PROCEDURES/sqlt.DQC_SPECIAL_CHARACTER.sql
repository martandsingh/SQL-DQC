IF OBJECT_ID('sqlt.DQC_SPECIAL_CHARACTER') IS NOT NULL
BEGIN
	DROP PROCEDURE  sqlt.DQC_SPECIAL_CHARACTER
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Martand Singh
-- Facebook: https://www.facebook.com/Codemakerz
-- Github: https://github.com/martandsingh
-- Description:	This will return special count of the rows with special chracter in it. You can change regex param as per your need.
-- =============================================
CREATE PROCEDURE sqlt.DQC_SPECIAL_CHARACTER
  @table_name VARCHAR(100),
  @regex VARCHAR(100) = '%[^a-zA-Z0-9 ]%'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @DQC_TYPE VARCHAR(100) = 'DQC_SPECIAL_CHARACTERS_COUNT'

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
	@datatype VARCHAR(50),
	@SpecialCount BIGINT,
	@MESSAGE VARCHAR(500),
	@schema_name VARCHAR(50)

	SELECT 
	CAST('' AS VARCHAR(10)) AS SpecialCharacters
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
		CASE WHEN '''+@datatype+''' IN (''nvarchar'',''varchar'',''nchar'',''char'')
                      THEN SUM(CASE WHEN '+@column_name+' LIKE '''+@regex+''' THEN 1 ELSE 0 END)
                      ELSE NULL END SpecialCharacters
		FROM '+@schema_name+'.'+@table_name)

		SET @SpecialCount = (SELECT SpecialCharacters FROM #tempFinal)
		SET @MESSAGE = 'Special character count for '+@table_name+'.'+@column_name + ' is '+ CAST(@SpecialCount AS VARCHAR(10));
		
		INSERT INTO sqlt.assertlog
		([object_name], column_name, column_type,assert_type ,actual_value  ,error,[message]  )
		VALUES
		(QUOTENAME(@schema_name+'.'+@table_name), @column_name, @datatype, @DQC_TYPE, CAST(@SpecialCount AS BIGINT), NULL, @MESSAGE  )

		TRUNCATE TABLE #tempFinal
		SET @FLAG = @FLAG + 1
	END

	
END
GO
