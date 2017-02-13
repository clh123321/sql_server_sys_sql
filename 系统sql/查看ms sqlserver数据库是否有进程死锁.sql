if object_id('dbo.sp_sivan_who_lock') is not null
	drop proc dbo.sp_sivan_who_lock
GO

CREATE  procedure dbo.sp_sivan_who_lock
as
begin
declare @spid int,@bl int,
        @intTransactionCountOnEntry  int,
        @intRowcount    int,
        @intCountProperties   int,
        @intCounter    int
 create table #tmp_lock_who (id int identity(1,1),spid smallint,bl smallint)
 
 IF @@ERROR<>0 RETURN @@ERROR
 
 insert into #tmp_lock_who(spid,bl) select  0 ,blocked
   from (select * from master..sysprocesses where  blocked>0 ) a
   where not exists(select * from (select * from master..sysprocesses where  blocked>0 ) b
   where a.blocked=spid)
   union select spid,blocked from master..sysprocesses where  blocked>0

 IF @@ERROR<>0 RETURN @@ERROR
 
-- �ҵ���ʱ��ļ�¼��
 select  @intCountProperties = Count(*),@intCounter = 1
 from #tmp_lock_who
 
 IF @@ERROR<>0 RETURN @@ERROR
 
 if @intCountProperties=0
  select '����û��������������Ϣ' as message

-- ѭ����ʼ
while @intCounter <= @intCountProperties
begin
-- ȡ��һ����¼
  select  @spid = spid,@bl = bl
  from #tmp_lock_who where id = @intCounter
 begin
  if @spid =0
    select '�������ݿ���������: '+ CAST(@bl AS VARCHAR(10)) + '���̺�,��ִ�е�SQL�﷨����'
 else
    select '���̺�SPID��'+ CAST(@spid AS VARCHAR(10))+ '��' + '���̺�SPID��'+ CAST(@bl AS VARCHAR(10)) +'����,�䵱ǰ����ִ�е�SQL�﷨����'
 DBCC INPUTBUFFER (@bl )
 end

-- ѭ��ָ������
 set @intCounter = @intCounter + 1
end


drop table #tmp_lock_who

return 0
end


GO