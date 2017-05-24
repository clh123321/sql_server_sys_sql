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

--原因就在于加上OPTION(RECOMPILE)这个查询提示之后，不缓存SQL的执行计划缓存，没有了执行计划缓存，也就没得重用了
select COUNT(1) from [TABLE] where CreateDate>'2016-6-1' and CreateDate<'2016-6-9' OPTION(RECOMPILE)