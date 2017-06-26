--Begin Index(����) �����Ż������ Sql 

-- ���ص�ǰ���ݿ�������Ƭ�ʴ���25%������
-- ���б�����ɨ��ܶ�����ҳ��
-- ������ϵͳ���رȽϸ�ʱ����
-- ������ϵͳ���رȽϸ�ʱ����
declare @dbid int
select @dbid = db_id()
SELECT o.name as tablename,s.* FROM sys.dm_db_index_physical_stats (@dbid, NULL, NULL, NULL, NULL) s,sys.objects o
where avg_fragmentation_in_percent>25 and o.object_id =s.object_id
order by avg_fragmentation_in_percent desc
GO

-- ��ǰ���ݿ����ȱ�ٵ�����
-- �ǳ����õ� Sql ���
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

-- �Զ��ؽ���������֯����
-- �ȽϺ��ã����ã��ر��Ƕ������� DB
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


-- �鿴��ǰ���ݿ�������ʹ����
-- �ǳ�������
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
--�ֶ�˵��
SELECT 
	OBJECT_NAME(a.object_id)	AS [�����ͼ����],
	b.name						AS [��������], 
	b.type_desc					AS [��������],
	a.user_seeks				AS [�������Ҵ���],
	a.user_updates				AS [�������´���],
	a.user_scans				AS [����ɨ�����],
	a.user_lookups				AS [������ǩ���Ҵ���],	
	a.last_user_seek			AS [�ϴβ���ʱ��],
	a.last_user_scan			AS [�ϴ�ɨ��ʱ��],
	a.last_user_lookup			AS [�ϴ���ǩ���ҵ�ʱ��],
	a.last_user_update			AS [�ϴ��޸�������ʱ��]
FROM sys.dm_db_index_usage_stats AS a -- ����ʹ��ͳ��
INNER JOIN sys.indexes AS b  -- ������Ϣ
ON a.[OBJECT_ID] = b.[OBJECT_ID] and a.index_id = b.index_id
INNER JOIN sys.objects AS c -- ������Ϣ
ON a.[OBJECT_ID] = c.[OBJECT_ID] AND c.[type] IN('V','U')-- �����ͼ
WHERE a.database_id = DB_ID() AND a.index_id > 0 -- DB_ID()Ϊ��ǰ��
ORDER BY [�����ͼ����],[��������];


-- ָ���������ʹ�����
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

--End Index �����Ż������ Sql