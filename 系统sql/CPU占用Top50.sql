SELECT TOP 50 total_worker_time / execution_count AS '每次执行占用CPU(微秒)', execution_count AS '执行次数', total_worker_time AS '总共占用CPU(微秒)', creation_time AS '创建时间', last_execution_time AS '最后执行时间'
	, min_worker_time AS '最低每次占用CPU', max_worker_time AS '最高每次占用cpu', total_physical_reads AS '总共io物理读取次数', total_logical_reads AS '总共逻辑读取次数', total_logical_writes AS '总共逻辑写次数'
	, total_elapsed_time AS '完成此计划的执行所占用的总时间(微秒)', (
		SELECT SUBSTRING(text, statement_start_offset / 2, (CASE WHEN statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(max), text)) * 2 ELSE statement_end_offset END - statement_start_offset) / 2)
		FROM sys.dm_exec_sql_text(sql_handle)
		) AS 'SQL内容'
FROM sys.dm_exec_query_stats
ORDER BY 1 DESC