--DBA 需要知道N种对数据库性能的监控SQL语句

-- IO问题的SQL内部分析
--下面的DMV查询可以来检查当前所有的等待累积值。
Select  wait_type, 
        waiting_tasks_count, 
        wait_time_ms
from     sys.dm_os_wait_stats  
where    wait_type like 'PAGEIOLATCH%'  
order by wait_type

--可以通过运行下面的查询得到每个文件的信息，了解哪个文件经常要做读(num_of_reads/ num_of_bytes_read)，
--哪个经常要做写(num_of_writes/ num_of_bytes_written)，哪个文件的读写经常要等待(io_stall_read_ms/ io_stall_write_ms/ io_stall)。
select db.name as database_name, f.fileid as file_id,
f.filename as file_name,
i.num_of_reads, i.num_of_bytes_read, i.io_stall_read_ms, 
i.num_of_writes, i.num_of_bytes_written, i.io_stall_write_ms, 
i.io_stall, i.size_on_disk_bytes
from sys.databases db inner join
sys.sysaltfiles f on db.database_id = f.dbid
inner join sys.dm_io_virtual_file_stats(NULL, NULL) i 
on i.database_id = f.dbid and i.file_id = f.fileid

--SQLOS的任务调度算法
--SQL 2005和SQL 2008有个动态管理视图sys.dm_os_schedulers，可以反映当前每个scheduler的状态。
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

-- SQL CPU 100%问题
--使用DMV来分析SQL Server启动以来累计使用CPU资源最多的语句。例如下面的语句就可以列出前50名。
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

--我们也可以找到最经常做重编译的存储过程。
select top 25 sql_text.text, sql_handle, plan_generation_num,  execution_count,
    dbid,  objectid 
from sys.dm_exec_query_stats a
    cross apply sys.dm_exec_sql_text(sql_handle) as sql_text
where plan_generation_num >1
order by plan_generation_num desc
go
-- 返回最经常运行的100条语句
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

-- 返回最经常被修改的100个索引
-- 通过它们的Database_id, object_id, index_id和partition_number
-- 可以找到它们是哪个数据库上的哪个索引
SELECT top 100 * 
FROM sys.dm_db_index_operational_stats(NULL, NULL, NULL, NULL)
order by leaf_insert_count+leaf_delete_count+leaf_update_count desc
GO


-- 返回做IO数目最多的50条语句以及它们的执行计划
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
-- 计算signal wait占整wait时间的百分比
select convert(numeric(5,4),sum(signal_wait_time_ms)/sum(wait_time_ms)) 
from Sys.dm_os_wait_stats

--性能计数对象SQLServer:SQL Statistics下面有几个计数器，可以计算出大致的执行计划重用率。计算方法是：
--Initial Compilations = SQL Compilations/sec – SQL Re-Compilations/sec
--执行计划重用率= (Batch requests/sec – Initial Compilations/sec) / Batch requests/sec


-- 计算'Cxpacket'占整wait时间的百分比
declare @Cxpacket bigint
declare @Sumwaits bigint
select @Cxpacket = wait_time_ms
from Sys.dm_os_wait_stats
where wait_type = 'Cxpacket'
select @Sumwaits = sum(wait_time_ms)
from Sys.dm_os_wait_stats
select convert(numeric(5,4),@Cxpacket/@Sumwaits)

-- 阻塞：
-- 查询当前数据库上所有用户表格在Row lock上发生阻塞的频率
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

-- 返回当前数据库所有碎片率大于25%的索引
-- 运行本语句会扫描很多数据页面
-- 避免在系统负载比较高时运行
declare @dbid int
select @dbid = db_id()
SELECT * FROM sys.dm_db_index_physical_stats (@dbid, NULL, NULL, NULL, NULL)
where avg_fragmentation_in_percent>25
order by avg_fragmentation_in_percent desc
GO

-- 当前数据库可能缺少的索引
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
---查找未使用过的索引
SELECT TOP 1000
o.name AS 表名
, i.name AS 索引名
, i.index_id AS 索引id
, dm_ius.user_seeks AS 搜索次数
, dm_ius.user_scans AS 扫描次数
, dm_ius.user_lookups AS 查找次数
, dm_ius.user_updates AS 更新次数
, p.TableRows as 表行数
, 'DROP INDEX ' + QUOTENAME(i.name)
+ ' ON ' + QUOTENAME(s.name) + '.' + QUOTENAME(OBJECT_NAME(dm_ius.OBJECT_ID)) AS '删除语句'
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
and o.name='t_goods'   --根据实际修改表名
ORDER BY (dm_ius.user_seeks + dm_ius.user_scans + dm_ius.user_lookups) ASC

/*
user_updates很大，而发现user_seeks和user_scans很少或者就是0，那就说明该索引一直在更新，
但是从来不被使用，仅仅创建和修改，没有为查询提供任何帮助，就可以考虑删除了
*/
--得到按照执行时间排序的前10 的存储过程的执行信息：

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

--100个io读取开销最大的语句
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


-----通过sys.dm_exec_procedure_stats得到存储过程的执行信息--转

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