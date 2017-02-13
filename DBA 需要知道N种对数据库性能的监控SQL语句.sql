--DBA ��Ҫ֪��N�ֶ����ݿ����ܵļ��SQL���

-- IO�����SQL�ڲ�����
--�����DMV��ѯ��������鵱ǰ���еĵȴ��ۻ�ֵ��
Select  wait_type, 
        waiting_tasks_count, 
        wait_time_ms
from     sys.dm_os_wait_stats  
where    wait_type like 'PAGEIOLATCH%'  
order by wait_type

--����ͨ����������Ĳ�ѯ�õ�ÿ���ļ�����Ϣ���˽��ĸ��ļ�����Ҫ����(num_of_reads/ num_of_bytes_read)��
--�ĸ�����Ҫ��д(num_of_writes/ num_of_bytes_written)���ĸ��ļ��Ķ�д����Ҫ�ȴ�(io_stall_read_ms/ io_stall_write_ms/ io_stall)��
select db.name as database_name, f.fileid as file_id,
f.filename as file_name,
i.num_of_reads, i.num_of_bytes_read, i.io_stall_read_ms, 
i.num_of_writes, i.num_of_bytes_written, i.io_stall_write_ms, 
i.io_stall, i.size_on_disk_bytes
from sys.databases db inner join
sys.sysaltfiles f on db.database_id = f.dbid
inner join sys.dm_io_virtual_file_stats(NULL, NULL) i 
on i.database_id = f.dbid and i.file_id = f.fileid

--SQLOS����������㷨
--SQL 2005��SQL 2008�и���̬������ͼsys.dm_os_schedulers�����Է�ӳ��ǰÿ��scheduler��״̬��
SELECT
    scheduler_id,
    cpu_id,
    parent_node_id,
    current_tasks_count,
    runnable_tasks_count,
    current_workers_count,
    active_workers_count,
    work_queue_count
  FROM sys.dm_os_schedulers;

-- SQL CPU 100%����
--ʹ��DMV������SQL Server���������ۼ�ʹ��CPU��Դ������䡣������������Ϳ����г�ǰ50����
select 
    highest_cpu_queries.*,q.dbid, 
    q.objectid, q.number, q.encrypted, q.[text]
from 
    (select top 50 qs.*
    from sys.dm_exec_query_stats qs
    order by qs.total_worker_time desc) as highest_cpu_queries
    cross apply sys.dm_exec_sql_text(plan_handle) as q
order by highest_cpu_queries.total_worker_time desc
go

--����Ҳ�����ҵ�������ر���Ĵ洢���̡�
select top 25 sql_text.text, sql_handle, plan_generation_num,  execution_count,
    dbid,  objectid 
from sys.dm_exec_query_stats a
    cross apply sys.dm_exec_sql_text(sql_handle) as sql_text
where plan_generation_num >1
order by plan_generation_num desc
go
-- ����������е�100�����
SELECT TOP 100
        cp.cacheobjtype
        ,cp.usecounts
        ,cp.size_in_bytes  
        ,qs.statement_start_offset
        ,qs.statement_end_offset
        ,qt.dbid
        ,qt.objectid
        ,SUBSTRING(qt.text,qs.statement_start_offset/2, 
            (case when qs.statement_end_offset = -1 
            then len(convert(nvarchar(max), qt.text)) * 2 
            else qs.statement_end_offset end -qs.statement_start_offset)/2) 
        as statement
FROM sys.dm_exec_query_stats qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) as qt
inner join sys.dm_exec_cached_plans as cp on qs.plan_handle=cp.plan_handle
where cp.plan_handle=qs.plan_handle
and cp.usecounts>4
ORDER BY [dbid],[Usecounts] DESC

-- ����������޸ĵ�100������
-- ͨ�����ǵ�Database_id, object_id, index_id��partition_number
-- �����ҵ��������ĸ����ݿ��ϵ��ĸ�����
SELECT top 100 * 
FROM sys.dm_db_index_operational_stats(NULL, NULL, NULL, NULL)
order by leaf_insert_count+leaf_delete_count+leaf_update_count desc
GO


-- ������IO��Ŀ����50������Լ����ǵ�ִ�мƻ�
select top 50 
    (total_logical_reads/execution_count) as avg_logical_reads,
    (total_logical_writes/execution_count) as avg_logical_writes,
    (total_physical_reads/execution_count) as avg_phys_reads,
     Execution_count, 
    statement_start_offset as stmt_start_offset, statement_end_offset as stmt_end_offset,
substring(sql_text.text, (statement_start_offset/2), 
case 
when (statement_end_offset -statement_start_offset)/2 <=0 then 64000
else (statement_end_offset -statement_start_offset)/2
end) as exec_statement,  
sql_text.text,
plan_text.*
from sys.dm_exec_query_stats  
cross apply sys.dm_exec_sql_text(sql_handle) as sql_text
cross apply sys.dm_exec_query_plan(plan_handle) as plan_text
order by 
 (total_logical_reads + total_logical_writes) /Execution_count Desc
go

-- CPU
-- ����signal waitռ��waitʱ��İٷֱ�
select convert(numeric(5,4),sum(signal_wait_time_ms)/sum(wait_time_ms)) 
from Sys.dm_os_wait_stats

--���ܼ�������SQLServer:SQL Statistics�����м��������������Լ�������µ�ִ�мƻ������ʡ����㷽���ǣ�
--Initial Compilations = SQL Compilations/sec �C SQL Re-Compilations/sec
--ִ�мƻ�������= (Batch requests/sec �C Initial Compilations/sec) / Batch requests/sec


-- ����'Cxpacket'ռ��waitʱ��İٷֱ�
declare @Cxpacket bigint
declare @Sumwaits bigint
select @Cxpacket = wait_time_ms
from Sys.dm_os_wait_stats
where wait_type = 'Cxpacket'
select @Sumwaits = sum(wait_time_ms)
from Sys.dm_os_wait_stats
select convert(numeric(5,4),@Cxpacket/@Sumwaits)

-- ������
-- ��ѯ��ǰ���ݿ��������û������Row lock�Ϸ���������Ƶ��
declare @dbid int
select @dbid = db_id()
Select dbid=database_id, objectname=object_name(s.object_id)
, indexname=i.name, i.index_id    --, partition_number
, row_lock_count, row_lock_wait_count
, [block %]=cast (100.0 * row_lock_wait_count / (1 + row_lock_count) as numeric(15,2))
, row_lock_wait_in_ms
, [avg row lock waits in ms]=cast (1.0 * row_lock_wait_in_ms / (1 + row_lock_wait_count) as numeric(15,2))
from sys.dm_db_index_operational_stats (@dbid, NULL, NULL, NULL) s,     sys.indexes i
where objectproperty(s.object_id,'IsUserTable') = 1
and i.object_id = s.object_id
and i.index_id = s.index_id
order by row_lock_wait_count desc

-- ���ص�ǰ���ݿ�������Ƭ�ʴ���25%������
-- ���б�����ɨ��ܶ�����ҳ��
-- ������ϵͳ���رȽϸ�ʱ����
declare @dbid int
select @dbid = db_id()
SELECT * FROM sys.dm_db_index_physical_stats (@dbid, NULL, NULL, NULL, NULL)
where avg_fragmentation_in_percent>25
order by avg_fragmentation_in_percent desc
GO

-- ��ǰ���ݿ����ȱ�ٵ�����
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
---����δʹ�ù�������
SELECT TOP 1000
o.name AS ����
, i.name AS ������
, i.index_id AS ����id
, dm_ius.user_seeks AS ��������
, dm_ius.user_scans AS ɨ�����
, dm_ius.user_lookups AS ���Ҵ���
, dm_ius.user_updates AS ���´���
, p.TableRows as ������
, 'DROP INDEX ' + QUOTENAME(i.name)
+ ' ON ' + QUOTENAME(s.name) + '.' + QUOTENAME(OBJECT_NAME(dm_ius.OBJECT_ID)) AS 'ɾ�����'
FROM sys.dm_db_index_usage_stats dm_ius
INNER JOIN sys.indexes i ON i.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = i.OBJECT_ID
INNER JOIN sys.objects o ON dm_ius.OBJECT_ID = o.OBJECT_ID
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
INNER JOIN (SELECT SUM(p.rows) TableRows, p.index_id, p.OBJECT_ID
FROM sys.partitions p GROUP BY p.index_id, p.OBJECT_ID) p
ON p.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = p.OBJECT_ID
WHERE OBJECTPROPERTY(dm_ius.OBJECT_ID,'IsUserTable') = 1
AND dm_ius.database_id = DB_ID()
AND i.type_desc = 'nonclustered'
AND i.is_primary_key = 0
AND i.is_unique_constraint = 0
and o.name='t_goods'   --����ʵ���޸ı���
ORDER BY (dm_ius.user_seeks + dm_ius.user_scans + dm_ius.user_lookups) ASC

/*
user_updates�ܴ󣬶�����user_seeks��user_scans���ٻ��߾���0���Ǿ�˵��������һֱ�ڸ��£�
���Ǵ�������ʹ�ã������������޸ģ�û��Ϊ��ѯ�ṩ�κΰ������Ϳ��Կ���ɾ����
*/
--�õ�����ִ��ʱ�������ǰ10 �Ĵ洢���̵�ִ����Ϣ��

SELECT TOP 10 a.object_id, a.database_id, OBJECT_NAME(object_id, database_id) 'proc name',

a.cached_time, a.last_execution_time, a.total_elapsed_time, a.total_elapsed_time/a.execution_count AS [avg_elapsed_time],

a.execution_count,

a.total_physical_reads/a.execution_count avg_physical_reads,

a.total_logical_writes,

a.total_logical_writes/ a.execution_count  avg_logical_reads,

a.last_elapsed_time,

a.total_elapsed_time / a.execution_count   avg_elapsed_time,

b.text,c.query_plan 

FROM sys.dm_exec_procedure_stats AS a

CROSS APPLY sys.dm_exec_sql_text(a.sql_handle)  b

CROSS APPLY sys.dm_exec_query_plan(a.plan_handle) c

ORDER BY [total_worker_time] DESC;

--100��io��ȡ�����������
SELECT TOP 100 SUBSTRING(qt.text, (qs.statement_start_offset/2)+1, 
 
  ((CASE qs.statement_end_offset

  WHEN -1 THEN DATALENGTH(qt.text)

  ELSE qs.statement_end_offset

  END - qs.statement_start_offset)/2)+1), 

  qs.execution_count, 

  qs.total_logical_reads, qs.last_logical_reads,

  qs.min_logical_reads, qs.max_logical_reads,

  qs.total_elapsed_time, qs.last_elapsed_time,

  qs.min_elapsed_time, qs.max_elapsed_time,

  qs.last_execution_time,

  qp.query_plan
 
FROM sys.dm_exec_query_stats qs
 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
 
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
 
WHERE qt.encrypted=0
 
ORDER BY qs.total_logical_reads DESC


-----ͨ��sys.dm_exec_procedure_stats�õ��洢���̵�ִ����Ϣ--ת

SELECT TOP 10 a.object_id, a.database_id, OBJECT_NAME(object_id, database_id) 'proc name',

a.cached_time, a.last_execution_time, a.total_elapsed_time, a.total_elapsed_time/a.execution_count AS [avg_elapsed_time],

a.execution_count,

a.total_physical_reads/a.execution_count avg_physical_reads,

a.total_logical_writes,

a.total_logical_writes/ a.execution_count  avg_logical_reads,

a.last_elapsed_time,

a.total_elapsed_time / a.execution_count   avg_elapsed_time,

b.text,c.query_plan

FROM sys.dm_exec_procedure_stats AS a

CROSS APPLY sys.dm_exec_sql_text(a.sql_handle)  b

CROSS APPLY sys.dm_exec_query_plan(a.plan_handle) c

ORDER BY [total_worker_time] DESC;

GO