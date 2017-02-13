    SELECT  creation_time  N'语句编译时间'  
      
            ,last_execution_time  N'上次执行时间'  
      
            ,total_physical_reads N'物理读取总次数'  
      
            ,total_logical_reads/execution_count N'每次逻辑读次数'  
      
            ,total_logical_reads  N'逻辑读取总次数'  
      
            ,total_logical_writes N'逻辑写入总次数'  
      
            , execution_count  N'执行次数'  
      
            , total_worker_time/1000 N'所用的CPU总时间ms'  
      
            , total_elapsed_time/1000  N'总花费时间ms'  
      
            , (total_elapsed_time / execution_count)/1000  N'平均时间ms'  
      
            ,SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,  
      
             ((CASE statement_end_offset   
      
              WHEN -1 THEN DATALENGTH(st.text)  
      
              ELSE qs.statement_end_offset END   
      
                - qs.statement_start_offset)/2) + 1) N'执行语句'  
      
    FROM sys.dm_exec_query_stats AS qs  
      
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st  
      
    where SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,  
      
             ((CASE statement_end_offset   
      
              WHEN -1 THEN DATALENGTH(st.text)  
      
              ELSE qs.statement_end_offset END   
      
                - qs.statement_start_offset)/2) + 1) not like '%fetch%'  
      
    ORDER BY   execution_count DESC;  