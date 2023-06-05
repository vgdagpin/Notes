CREATE OR ALTER PROCEDURE dbo.usp_SnapshotTableAccess
AS
BEGIN
	IF OBJECT_ID ( 'dbo.tbl_TableAccessCount' ) IS NULL
		CREATE TABLE dbo.tbl_TableAccessCount ( RunNo INT NOT NULL, TableName NVARCHAR(255) NOT NULL, AccessCount INT NOT NULL )

	DECLARE @lastId INT

	SELECT	@lastId = ISNULL ( MAX ( tac.RunNo ), 0 )
	FROM	dbo.tbl_TableAccessCount tac

	DELETE FROM	 dbo.tbl_TableAccessCount

	INSERT INTO dbo.tbl_TableAccessCount ( RunNo, TableName, AccessCount )
	SELECT	@lastId + 1 RunNo
		  , t.table_name
		  , SUM ( t.total_accesses ) total_accesses
	FROM	(	SELECT	SCHEMA_NAME ( o.schema_id ) + '.' + OBJECT_NAME ( i.object_id ) AS table_name
					  , i.user_seeks + i.user_scans + i.user_lookups AS total_accesses
				FROM	sys.dm_db_index_usage_stats i
					INNER JOIN sys.objects o
						ON i.object_id = o.object_id
				WHERE  i.database_id = DB_ID ()
				  AND  o.type = 'U' ) t
	WHERE	t.table_name NOT IN ( 'dbo.tbl_TableAccessCount' )
	GROUP BY t.table_name
END
GO

CREATE OR ALTER FUNCTION dbo.ufn_GetTableAccessCount ()
RETURNS @result TABLE ( TableName VARCHAR(255) NOT NULL, TotalNewAccess INT NOT NULL )
AS
BEGIN
	DECLARE @lastId INT

	SELECT	@lastId = ISNULL ( MAX ( tac.RunNo ), 0 )
	FROM	dbo.tbl_TableAccessCount tac

	INSERT INTO @result
	SELECT	t2.table_name TableName
		  , t2.total_accesses - ISNULL ( tac.AccessCount, 0 ) TotalNewAccess
	FROM	(	SELECT	t.table_name
					  , SUM ( t.total_accesses ) total_accesses
				FROM	(	SELECT	SCHEMA_NAME ( o.schema_id ) + '.' + OBJECT_NAME ( i.object_id ) AS table_name
								  , i.user_seeks + i.user_scans + i.user_lookups AS total_accesses
							FROM	sys.dm_db_index_usage_stats i
								INNER JOIN sys.objects o
									ON i.object_id = o.object_id
							WHERE	i.database_id = DB_ID ()
							  AND	o.type = 'U' ) t
				GROUP BY t.table_name ) t2
		LEFT JOIN dbo.tbl_TableAccessCount tac
			ON	tac.RunNo = @lastId
		   AND	t2.table_name = tac.TableName
	WHERE (	  tac.RunNo IS NULL OR tac.AccessCount !=  t2.total_accesses )
	  AND	t2.table_name NOT IN ( 'dbo.tbl_TableAccessCount' )

	RETURN
END
GO
