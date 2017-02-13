    SELECT  creation_time  N'������ʱ��'  
      
            ,last_execution_time  N'�ϴ�ִ��ʱ��'  
      
            ,total_physical_reads N'�����ȡ�ܴ���'  
      
            ,total_logical_reads/execution_count N'ÿ���߼�������'  
      
            ,total_logical_reads  N'�߼���ȡ�ܴ���'  
      
            ,total_logical_writes N'�߼�д���ܴ���'  
      
            , execution_count  N'ִ�д���'  
      
            , total_worker_time/1000 N'���õ�CPU��ʱ��ms'  
      
            , total_elapsed_time/1000  N'�ܻ���ʱ��ms'  
      
            , (total_elapsed_time / execution_count)/1000  N'ƽ��ʱ��ms'  
      
            ,SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,  
      
             ((CASE statement_end_offset   
      
              WHEN -1 THEN DATALENGTH(st.text)  
      
              ELSE qs.statement_end_offset END   
      
                - qs.statement_start_offset)/2) + 1) N'ִ�����'  
      
    FROM sys.dm_exec_query_stats AS qs  
      
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st  
      
    where SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,  
      
             ((CASE statement_end_offset   
      
              WHEN -1 THEN DATALENGTH(st.text)  
      
              ELSE qs.statement_end_offset END   
      
                - qs.statement_start_offset)/2) + 1) not like '%fetch%'  
      
    ORDER BY   execution_count DESC;  