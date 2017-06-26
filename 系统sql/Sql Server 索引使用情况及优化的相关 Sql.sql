--Begin Index(索引) 分析优化的相关 Sql 

-- 返回当前数据库所有碎片率大于25%的索引
-- 运行本语句会扫描很多数据页面
-- 避免在系统负载比较高时运行
-- 避免在系统负载比较高时运行
declare @dbid int
select @dbid = db_id()
SELECT o.name as tablename,s.* FROM sys.dm_db_index_physical_stats (@dbid, NULL, NULL, NULL, NULL) s,sys.objects o
where avg_fragmentation_in_percent>25 and o.object_id =s.object_id
order by avg_fragmentation_in_percent desc
GO

-- 当前数据库可能缺少的索引
-- 非常好用的 Sql 语句
select d.*
        , s.avg_total_user_cost
        , s.avg_user_impact
        , s.last_user_seek
        ,s.unique_compiles
from sys.dm_db_missing_index_group_stats s
        ,sys.dm_db_missing_index_groups g
        ,sys.dm_db_missing_index_details d
where s.group_handle = g.index_group_handle
and d.index_handle = g.index_handle
order by s.avg_user_impact desc
go

-- 自动重建或重新组织索引
-- 比较好用，慎用，特别是对于在线 DB
-- Ensure a USE <databasename> statement has been executed first.
SET NOCOUNT ON;
DECLARE @objectid int;
DECLARE @indexid int;
DECLARE @partitioncount bigint;
DECLARE @schemaname nvarchar(130); 
DECLARE @objectname nvarchar(130); 
DECLARE @indexname nvarchar(130); 
DECLARE @partitionnum bigint;
DECLARE @partitions bigint;
DECLARE @frag float;
DECLARE @command nvarchar(4000); 
-- Conditionally select tables and indexes from the sys.dm_db_index_physical_stats function 
-- and convert object and index IDs to names.
SELECT
    object_id AS objectid,
    index_id AS indexid,
    partition_number AS partitionnum,
    avg_fragmentation_in_percent AS frag
INTO #work_to_do
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, 'LIMITED')
WHERE avg_fragmentation_in_percent > 10.0 AND index_id > 0;

-- Declare the cursor for the list of partitions to be processed.
DECLARE partitions CURSOR FOR SELECT * FROM #work_to_do;

-- Open the cursor.
OPEN partitions;

-- Loop through the partitions.
WHILE (1=1)
    BEGIN;
        FETCH NEXT
           FROM partitions
           INTO @objectid, @indexid, @partitionnum, @frag;
        IF @@FETCH_STATUS < 0 BREAK;
        SELECT @objectname = QUOTENAME(o.name), @schemaname = QUOTENAME(s.name)
        FROM sys.objects AS o
        JOIN sys.schemas as s ON s.schema_id = o.schema_id
        WHERE o.object_id = @objectid;
        SELECT @indexname = QUOTENAME(name)
        FROM sys.indexes
        WHERE  object_id = @objectid AND index_id = @indexid;
        SELECT @partitioncount = count (*)
        FROM sys.partitions
        WHERE object_id = @objectid AND index_id = @indexid;

-- 30 is an arbitrary decision point at which to switch between reorganizing and rebuilding.
        IF @frag < 30.0
            SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REORGANIZE';
        IF @frag >= 30.0
            SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REBUILD';
        IF @partitioncount > 1
            SET @command = @command + N' PARTITION=' + CAST(@partitionnum AS nvarchar(10));
        EXEC (@command);
        PRINT N'Executed: ' + @command;
    END;

-- Close and deallocate the cursor.
CLOSE partitions;
DEALLOCATE partitions;

-- Drop the temporary table.
DROP TABLE #work_to_do;
GO


-- 查看当前数据库索引的使用率
-- 非常的有用
SELECT
object_name(object_id) as table_name,
(
select name
from sys.indexes
where object_id = stats.object_id and index_id = stats.index_id
) as index_name,
*
FROM sys.dm_db_index_usage_stats as stats
WHERE database_id = DB_ID()
order by table_name
--字段说明
SELECT 
	OBJECT_NAME(a.object_id)	AS [表或视图名称],
	b.name						AS [索引名称], 
	b.type_desc					AS [索引类型],
	a.user_seeks				AS [索引查找次数],
	a.user_updates				AS [索引更新次数],
	a.user_scans				AS [索引扫描次数],
	a.user_lookups				AS [索引书签查找次数],	
	a.last_user_seek			AS [上次查找时间],
	a.last_user_scan			AS [上次扫描时间],
	a.last_user_lookup			AS [上次书签查找的时间],
	a.last_user_update			AS [上次修改索引的时间]
FROM sys.dm_db_index_usage_stats AS a -- 索引使用统计
INNER JOIN sys.indexes AS b  -- 索引信息
ON a.[OBJECT_ID] = b.[OBJECT_ID] and a.index_id = b.index_id
INNER JOIN sys.objects AS c -- 对象信息
ON a.[OBJECT_ID] = c.[OBJECT_ID] AND c.[type] IN('V','U')-- 表或视图
WHERE a.database_id = DB_ID() AND a.index_id > 0 -- DB_ID()为当前库
ORDER BY [表或视图名称],[索引类型];


-- 指定表的索引使用情况
declare @table as nvarchar(100)
set @table = 't_name';

SELECT
(
  select name
  from sys.indexes
  where object_id = stats.object_id and index_id = stats.index_id
) as index_name,
*
FROM sys.dm_db_index_usage_stats as stats
where object_id = object_id(@table)
order by user_seeks, user_scans, user_lookups asc

--End Index 分析优化的相关 Sql