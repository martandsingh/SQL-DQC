IF OBJECT_ID('sqlt.DQC_DB_LEVEL') IS NOT NULL
BEGIN
	DROP PROCEDURE  sqlt.DQC_DB_LEVEL;
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
CREATE PROCEDURE sqlt.DQC_DB_LEVEL
	-- Add the parameters for the stored procedure here
	@db_name VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF OBJECT_ID('tempdb.dbo.##tempTableList') IS NOT NULL
	BEGIN
		DROP TABLE dbo.#tempTableList;
	END
	EXEC (' USE '+@db_name+';')
	SELECT ROW_NUMBER() OVER(ORDER BY T.TABLENAME) AS ID, T.TABLENAME 
	INTO #tempTableList
	FROM
	(SELECT  DISTINCT TABLENAME 
	FROM sqlt.VW_TABLE_DETAILS) AS T

	DECLARE @FLAG INT = 1,
	@table_name VARCHAR(100)
	WHILE @FLAG <= (SELECT MAX(ID) FROM #tempTableList)
	BEGIN
		SELECT @table_name = TableName FROM #tempTableList WHERE ID=@FLAG
		print(@table_name)
		--EXEC sqlt.DQC_TOTAL_COUNT @table_name = @table_name, @predicted_value=4  -- predicted value, you should run separately as different table may have different count
		EXEC sqlt.DQC_MISSING_VALUES_COUNT @table_name = @table_name
		EXEC sqlt.DQC_SPECIAL_CHARACTER @table_name = @table_name
		EXEC sqlt.DQC_MAX_MIN_LENGTH @table_name = @table_name
		EXEC sqlt.DQC_MAX_MIN_VALUE @table_name = @table_name
		EXEC sqlt.DQC_DISTINCT_COLUMN_COUNT @table_name = @table_name
		SET @FLAG = @FLAG + 1
	END
	
   
END
GO
