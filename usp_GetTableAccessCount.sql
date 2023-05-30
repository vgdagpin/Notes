CREATE PROCEDURE dbo.usp_GetTableAccessCount ( @createSnapshot BIT )
AS
BEGIN
	IF OBJECT_ID ( 'tempdb..##TableAccessCount' ) IS NULL
		CREATE TABLE ##TableAccessCount ( RunNo INT NOT NULL, TableName NVARCHAR(255) NOT NULL, AccessCount INT NOT NULL )



	DECLARE @lastId INT

	SELECT @lastId =  ISNULL ( MAX ( tac.RunNo ), 0 ) FROM ##TableAccessCount  tac

	IF @createSnapshot = 1
	BEGIN
		INSERT INTO ##TableAccessCount ( RunNo, TableName, AccessCount )
		SELECT	@lastId + 1 [RunNo]
			  , t.table_name
			  , SUM ( t.total_accesses ) [total_accesses]
		FROM	(	SELECT	SCHEMA_NAME ( o.schema_id ) + '.' + OBJECT_NAME ( i.object_id ) AS table_name
						  , i.user_seeks + i.user_scans + i.user_lookups AS total_accesses
					FROM	sys.dm_db_index_usage_stats i
						INNER JOIN sys.objects o
							ON i.object_id = o.object_id
					WHERE  i.database_id = DB_ID ()
					  AND  o.type = 'U' ) t
		WHERE	t.table_name NOT IN ( 'adm.tbl_MigrationHistory' )
		GROUP BY t.table_name
	END
	ELSE
	BEGIN
		SELECT	t2.table_name [TableName]
			  , t2.total_accesses - ISNULL ( tac.AccessCount, 0 ) [TotalNewAccess]
		FROM	(	SELECT	t.table_name
						  , SUM ( t.total_accesses ) [total_accesses]
					FROM	(	SELECT	SCHEMA_NAME ( o.schema_id ) + '.' + OBJECT_NAME ( i.object_id ) AS table_name
									  , i.user_seeks + i.user_scans + i.user_lookups AS total_accesses
								FROM	sys.dm_db_index_usage_stats i
									INNER JOIN sys.objects o
										ON i.object_id = o.object_id
								WHERE	i.database_id = DB_ID ()
								  AND	o.type = 'U' ) t
					GROUP BY t.table_name ) t2
			LEFT JOIN ##TableAccessCount tac
				ON	tac.RunNo = @lastId
			   AND	t2.table_name = tac.TableName
		WHERE (	  tac.RunNo IS NULL OR tac.AccessCount !=  t2.total_accesses )
		  AND	t2.table_name NOT IN ( 'adm.tbl_MigrationHistory' )
	END
END
GO
