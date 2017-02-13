--1.       Buffer Pool���ڴ���Ҫ�����Ǹ����ݿ�ռ�ˣ�  
SELECT count(*)*8  as cached_pages_kb,CASE database_id     
        WHEN 32767 THEN 'ResourceDb'     
        ELSE db_name(database_id)     
        END AS Database_name     
FROM sys.dm_os_buffer_descriptors     
GROUP BY db_name(database_id) ,database_id     
ORDER BY cached_pages_kb DESC;  

--2.       �پ���һ�㣬��ǰ���ݿ���ĸ����������ռ��Pool����ռ����?  
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

--3.       Buffer Pool����������޸Ĺ���ҳ������С������Ƚ����ף� 
SELECT count(*)*8  as cached_pages_kb,     
       convert(varchar(5),convert(decimal(5,2),(100-1.0*(select count(*) from sys.dm_os_buffer_descriptors b where b.database_id=a.database_id and is_modified=0)/count(*)*100.0)))+'%' modified_percentage     
        ,CASE database_id     
        WHEN 32767 THEN 'ResourceDb'     
        ELSE db_name(database_id)     
        END AS Database_name     
FROM sys.dm_os_buffer_descriptors a     
GROUP BY db_name(database_id) ,database_id     
ORDER BY cached_pages_kb DESC;  


--DB�к�ʱ�� �洢���� ��ִ����ϸ���

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

--DB�к�ʱ�� �洢���� ��ִ����ϸ���
select creation_time '����ʱ��',
  last_execution_time '�ϴ�ִ��ʱ��',
  total_physical_reads '�����ȡ�ܴ���',
  total_logical_reads/execution_count 'ÿ���߼�������',
  total_logical_reads '�߼�������',
  total_logical_writes '�߼�д����',
  execution_count 'ִ���ܴ���',
  total_worker_time/1000 'ռ��CPU��ʱ��(����)',
  total_elapsed_time/1000 '�ܻ���ʱ��(����)',
  (execution_count/total_elapsed_time)/1000 'ƽ��ִ��ʱ��(����)',
  substring(st.text,(qs.statement_start_offset/2)+1,((case qs.statement_end_offset when -1 then datalength(st.text) else qs.statement_end_offset end -qs.statement_start_offset)/2)+1) 'ִ�е�SQL���',
  getdate() 'ִ���ռ�ʱ��'
   from sys.dm_exec_query_stats as qs 
cross apply sys.dm_exec_sql_text(qs.sql_handle)as st
where substring(st.text,(qs.statement_start_offset/2)+1,((case qs.statement_end_offset when -1 then datalength(st.text) else qs.statement_end_offset end -qs.statement_start_offset)/2)+1)
not like '%FETCH%'
ORDER BY total_elapsed_time/execution_count desc