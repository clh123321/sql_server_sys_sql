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

--ԭ������ڼ���OPTION(RECOMPILE)�����ѯ��ʾ֮�󣬲�����SQL��ִ�мƻ����棬û����ִ�мƻ����棬Ҳ��û��������
select COUNT(1) from [TABLE] where CreateDate>'2016-6-1' and CreateDate<'2016-6-9' OPTION(RECOMPILE)