--���ִ�мƻ���

DBCC FreeProcCache

--��ѯ��������SQL��
SELECT 
cp.usecounts as 'ʹ�ô���' ,
cp.cacheobjtype as '��������',
cp.objtype as '��������',
st.text as 'TSQL',
qp.query_plan as 'ִ�мƻ�',
cp.size_in_bytes as 'ִ�мƻ�ռ�ÿռ�(byte)'
FROM
sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_sql_text(plan_handle) st
cross apply sys.dm_exec_query_plan(plan_handle) qp

ORDER BY cp.usecounts DESC


