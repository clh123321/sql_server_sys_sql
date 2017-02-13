SELECT TOP 50 total_worker_time / execution_count AS 'ÿ��ִ��ռ��CPU(΢��)', execution_count AS 'ִ�д���', total_worker_time AS '�ܹ�ռ��CPU(΢��)', creation_time AS '����ʱ��', last_execution_time AS '���ִ��ʱ��'
	, min_worker_time AS '���ÿ��ռ��CPU', max_worker_time AS '���ÿ��ռ��cpu', total_physical_reads AS '�ܹ�io�����ȡ����', total_logical_reads AS '�ܹ��߼���ȡ����', total_logical_writes AS '�ܹ��߼�д����'
	, total_elapsed_time AS '��ɴ˼ƻ���ִ����ռ�õ���ʱ��(΢��)', (
		SELECT SUBSTRING(text, statement_start_offset / 2, (CASE WHEN statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(max), text)) * 2 ELSE statement_end_offset END - statement_start_offset) / 2)
		FROM sys.dm_exec_sql_text(sql_handle)
		) AS 'SQL����'
FROM sys.dm_exec_query_stats
ORDER BY 1 DESC