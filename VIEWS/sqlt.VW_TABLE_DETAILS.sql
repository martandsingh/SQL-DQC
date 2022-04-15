
CREATE OR ALTER VIEW sqlt.VW_TABLE_DETAILS AS
	SELECT 
	ROW_NUMBER() OVER(PARTITION BY T.name ORDER BY T.name) AS ID, 
	T.name AS TableName, C.name AS ColumnName, TY.name AS DataType,  SCHEMA_NAME(T.schema_id) AS SchemaName
	FROM 
	sys.tables T INNER JOIN sys.columns C
	ON T.object_id = C.object_id
	INNER JOIN sys.types TY 
	ON TY.system_type_id = C.system_type_id
	WHERE
	TY.name NOT IN ('geography','varbinary','binary','text', 'ntext', 'image', 'hierarchyid', 'xml', 'sql_variant')


GO