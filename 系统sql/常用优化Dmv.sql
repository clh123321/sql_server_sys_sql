--1.       Buffer Pool的内存主要是由那个数据库占了？  
SELECT count(*)*8  as cached_pages_kb,CASE database_id     
        WHEN 32767 THEN 'ResourceDb'     
        ELSE db_name(database_id)     
        END AS Database_name     
FROM sys.dm_os_buffer_descriptors     
GROUP BY db_name(database_id) ,database_id     
ORDER BY cached_pages_kb DESC;  

--2.       再具体一点，当前数据库的哪个表或者索引占用Pool缓冲空间最多?  
SELECT count(*)*8 AS cached_pages_kb     
    ,obj.name ,obj.index_id,b.type_desc,b.name     
FROM sys.dm_os_buffer_descriptors AS bd     
    INNER JOIN     
(     
        SELECT object_name(object_id) AS name     
            ,index_id ,allocation_unit_id,object_id     
        FROM sys.allocation_units AS au     
            INNER JOIN sys.partitions AS p     
                ON au.container_id = p.hobt_id     
                    AND(au.type = 1 OR au.type = 3)     
        UNION ALL     
        SELECT object_name(object_id) AS name       
            ,index_id, allocation_unit_id,object_id     
        FROM sys.allocation_units AS au     
            INNER JOIN sys.partitions AS p     
                ON au.container_id = p.partition_id     
                    AND au.type = 2     
    ) AS obj     
        ON bd.allocation_unit_id = obj.allocation_unit_id     
        LEFT JOIN sys.indexes b on b.object_id = obj.object_id AND b.index_id = obj.index_id     
WHERE database_id = db_id()   
GROUP BY obj.name, obj.index_id ,b.name,b.type_desc     
ORDER BY cached_pages_kb DESC;

--3.       Buffer Pool缓冲池里面修改过的页总数大小。这个比较容易： 
SELECT count(*)*8  as cached_pages_kb,     
       convert(varchar(5),convert(decimal(5,2),(100-1.0*(select count(*) from sys.dm_os_buffer_descriptors b where b.database_id=a.database_id and is_modified=0)/count(*)*100.0)))+'%' modified_percentage     
        ,CASE database_id     
        WHEN 32767 THEN 'ResourceDb'     
        ELSE db_name(database_id)     
        END AS Database_name     
FROM sys.dm_os_buffer_descriptors a     
GROUP BY db_name(database_id) ,database_id     
ORDER BY cached_pages_kb DESC;  


--DB中耗时的 存储过程 及执行详细情况

SELECT  a.object_id, a.database_id, OBJECT_NAME(object_id, database_id) 'proc name',
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

--DB中耗时的 存储过程 及执行详细情况
select creation_time '编译时间',
  last_execution_time '上次执行时间',
  total_physical_reads '物理读取总次数',
  total_logical_reads/execution_count '每次逻辑读次数',
  total_logical_reads '逻辑读次数',
  total_logical_writes '逻辑写次数',
  execution_count '执行总次数',
  total_worker_time/1000 '占用CPU总时间(毫秒)',
  total_elapsed_time/1000 '总花费时间(毫秒)',
  (execution_count/total_elapsed_time)/1000 '平均执行时间(毫秒)',
  substring(st.text,(qs.statement_start_offset/2)+1,((case qs.statement_end_offset when -1 then datalength(st.text) else qs.statement_end_offset end -qs.statement_start_offset)/2)+1) '执行的SQL语句',
  getdate() '执行收集时间'
   from sys.dm_exec_query_stats as qs 
cross apply sys.dm_exec_sql_text(qs.sql_handle)as st
where substring(st.text,(qs.statement_start_offset/2)+1,((case qs.statement_end_offset when -1 then datalength(st.text) else qs.statement_end_offset end -qs.statement_start_offset)/2)+1)
not like '%FETCH%'
ORDER BY total_elapsed_time/execution_count desc