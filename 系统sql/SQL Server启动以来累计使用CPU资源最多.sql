--使用DMV来分析SQL Server启动以来累计使用CPU资源最多的语句。例如下面的语句就可以列出前50名。

select 

    c.last_execution_time,c.execution_count,c.total_logical_reads,c.total_logical_writes,c.total_elapsed_time,c.last_elapsed_time, 

    q.[text]

from 

    (select top 50 qs.*

    from sys.dm_exec_query_stats qs

    order by qs.total_worker_time desc) as c

    cross apply sys.dm_exec_sql_text(plan_handle) as q

order by c.total_worker_time desc

go





--我们也可以找到最经常做重编译的存储过程。

select TOP 25 sql_text.text, sql_handle, plan_generation_num,  execution_count,

    dbid,  objectid 

from sys.dm_exec_query_stats a

    cross apply sys.dm_exec_sql_text(sql_handle) as sql_text

where plan_generation_num > 1

order by plan_generation_num desc

go