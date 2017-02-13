-- 查看SQL阻塞信息
with tmp as (
    select * from master..sysprocesses t where t.blocked != 0
    union all
    select b.* from master..sysprocesses b
        join tmp t on b.spid = t.blocked 
)
select t.spid, t.blocked, t.status, t.waittype, t.lastwaittype, t.waitresource, t.waittime
    , DB_NAME(t.dbid) DbName, t.login_time, t.loginame, t.program_name, dc.text
from (select spid from tmp group by spid) s
    join master..sysprocesses t on s.spid = t.spid
    cross apply master.sys.dm_exec_sql_text(t.sql_handle) dc



-- 查看所有会话的状态、等待类型及当前正在执行SQL脚本
select    t.spid, t.blocked, t.status, t.waittype, t.lastwaittype, t.waitresource, t.waittime
    , DB_NAME(t.dbid) DbName, t.login_time, t.loginame, t.program_name, dc.text
from    master..sysprocesses t
    cross apply master.sys.dm_exec_sql_text(t.sql_handle) dc
where    t.spid > 50