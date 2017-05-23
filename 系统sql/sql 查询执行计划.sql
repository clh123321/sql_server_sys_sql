--清空执行计划：

DBCC FreeProcCache

--查询上面结果的SQL：
SELECT 
cp.usecounts as '使用次数' ,
cp.cacheobjtype as '缓存类型',
cp.objtype as '对象类型',
st.text as 'TSQL',
qp.query_plan as '执行计划',
cp.size_in_bytes as '执行计划占用空间(byte)'
FROM
sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_sql_text(plan_handle) st
cross apply sys.dm_exec_query_plan(plan_handle) qp

ORDER BY cp.usecounts DESC


