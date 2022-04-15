IF OBJECT_ID('sqlt.DQC_TOTAL_COUNT') IS NOT NULL
BEGIN
	DROP PROCEDURE  sqlt.DQC_TOTAL_COUNT
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Martand Singh
-- Facebook: https://www.facebook.com/Codemakerz
-- Github: https://github.com/martandsingh
-- Description:	It will return total row counts. Can contain duplicate values - Only for tables
-- =============================================
CREATE PROCEDURE sqlt.DQC_TOTAL_COUNT
	-- Add the parameters for the stored procedure here
	@table_name VARCHAR(100), 
	@predicted_value BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @DQC_TYPE VARCHAR(100) = 'DQC_TOTAL_COUNT',
	@TOTAL_COUNT BIGINT,
	@MESSAGE VARCHAR(500),
	@ISOK BIT = 0,
	@schema_name VARCHAR(50) 

	DECLARE @CountResults TABLE (CountReturned INT)
	SELECT @schema_name = SCHEMA_NAME(T.SCHEMA_ID) FROM sys.tables T WHERE T.name = @table_name

	INSERT INTO @CountResults
	EXEC ('SELECT COUNT(1) FROM '+@schema_name+'.'+@table_name)

	SET @TOTAL_COUNT = (SELECT CountReturned FROM @CountResults)
	IF @predicted_value = @TOTAL_COUNT
	BEGIN
		SET @MESSAGE = 'Success: Count matched successfully.' 
		SET @ISOK = 1
	END

	ELSE 
	BEGIN
		SET @MESSAGE =  @DQC_TYPE + ' failed: count mismatch. Actual Count = '+CAST(@TOTAL_COUNT AS VARCHAR(10))+', Predicted Count='+CAST(@predicted_value AS VARCHAR(10));
		SET @MESSAGE += '.Explore sqlt.assertlog table for more information.'
		RAISERROR (15600,-1,-1, @MESSAGE);  
	END

	INSERT INTO sqlt.assertlog
	([object_name],assert_type ,actual_value ,predicted_value ,error,[message] ,IsOk )
	VALUES
	(QUOTENAME(@schema_name+'.'+@table_name), @DQC_TYPE, @TOTAL_COUNT, @predicted_value, NULL, @MESSAGE, @ISOK  )

	SELECT @predicted_value AS 'Predicted Value', @TOTAL_COUNT AS 'Actual Value', CASE @ISOK WHEN 1 THEN 'True' ELSE 'False' END AS RESULT
END
GO
