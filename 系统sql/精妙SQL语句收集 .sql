

һ������

1��˵�����������ݿ�
CREATE DATABASE database-name
2��˵����ɾ�����ݿ�
drop database dbname
3��˵��������sql server
--- ���� �������ݵ� device
USE master
EXEC sp_addumpdevice 'disk', 'testBack', 'c:/mssql7backup/MyNwind_1.dat'
--- ��ʼ ����
BACKUP DATABASE pubs TO testBack
4��˵���������±�
create table tabname(col1 type1 [not null] [primary key],col2 type2 [not null],..)
�������еı����±�
A��create table tab_new like tab_old (ʹ�þɱ����±�)
B��create table tab_new as select col1,col2�� from tab_old definition only
5��˵����ɾ���±�
drop table tabname
6��˵��������һ����
Alter table tabname add column col type
ע�������Ӻ󽫲���ɾ����DB2���м��Ϻ���������Ҳ���ܸı䣬Ψһ�ܸı��������varchar���͵ĳ��ȡ�
7��˵������������� Alter table tabname add primary key(col)
˵����ɾ�������� Alter table tabname drop primary key(col)
8��˵��������������create [unique] index idxname on tabname(col��.)
ɾ��������drop index idxname
ע�������ǲ��ɸ��ĵģ�����ı���ɾ�����½���
9��˵����������ͼ��create view viewname as select statement
ɾ����ͼ��drop view viewname
10��˵���������򵥵Ļ�����sql���
ѡ��select * from table1 where ��Χ
���룺insert into table1(field1,field2) values(value1,value2)
ɾ����delete from table1 where ��Χ
���£�update table1 set field1=value1 where ��Χ
���ң�select * from table1 where field1 like ��%value1%�� ---like���﷨�ܾ��������!
����select * from table1 order by field1,field2 [desc]
������select count as totalcount from table1
��ͣ�select sum(field1) as sumvalue from table1
ƽ����select avg(field1) as avgvalue from table1
���select max(field1) as maxvalue from table1
��С��select min(field1) as minvalue from table1
11��˵���������߼���ѯ�����
A�� UNION �����
UNION �����ͨ���������������������� TABLE1 �� TABLE2������ȥ�����κ��ظ��ж�������һ��������� ALL �� UNION һ��ʹ��ʱ���� UNION ALL�����������ظ��С���������£��������ÿһ�в������� TABLE1 �������� TABLE2��
B�� EXCEPT �����
EXCEPT �����ͨ������������ TABLE1 �е����� TABLE2 �е��в����������ظ��ж�������һ��������� ALL �� EXCEPT һ��ʹ��ʱ (EXCEPT ALL)���������ظ��С�
C�� INTERSECT �����
INTERSECT �����ͨ��ֻ���� TABLE1 �� TABLE2 �ж��е��в����������ظ��ж�������һ��������� ALL �� INTERSECT һ��ʹ��ʱ (INTERSECT ALL)���������ظ��С�
ע��ʹ������ʵļ�����ѯ����б�����һ�µġ�
12��˵����ʹ��������
A��left outer join��
�������ӣ������ӣ�����������������ӱ��ƥ���У�Ҳ���������ӱ�������С�
SQL: select a.a, a.b, a.c, b.c, b.d, b.f from a LEFT OUT JOIN b ON a.a = b.c
B��right outer join:
��������(������)��������Ȱ������ӱ��ƥ�������У�Ҳ���������ӱ�������С�
C��full outer join��
ȫ�����ӣ����������������ӱ��ƥ���У��������������ӱ��е����м�¼��

��������

1��˵�������Ʊ�(ֻ���ƽṹ,Դ������a �±�����b) (Access����)
��һ��select * into b from a where 1<>1
������select top 0 * into b from a2��˵����������(��������,Դ������a Ŀ�������b) (Access����)
insert into b(a, b, c) select d,e,f from b;
3��˵���������ݿ�֮���Ŀ���(��������ʹ�þ���·��) (Access����)
insert into b(a, b, c) select d,e,f from b in ���������ݿ⡯ where ����
���ӣ�..from b in '"&Server.MapPath(".")&"/data.mdb" &"' where..
4��˵�����Ӳ�ѯ(����1��a ����2��b)
select a,b,c from a where a IN (select d from b ) ����: select a,b,c from a where a IN (1,2,3)
5��˵������ʾ���¡��ύ�˺����ظ�ʱ��
select a.title,a.username,b.adddate from table a,(select max(adddate) adddate from table where table.title=a.title) b
6��˵���������Ӳ�ѯ(����1��a ����2��b)
select a.a, a.b, a.c, b.c, b.d, b.f from a LEFT OUT JOIN b ON a.a = b.c
7��˵����������ͼ��ѯ(����1��a )
select * from (SELECT a,b,c FROM a) T where t.a > 1;
8��˵����between���÷�,between���Ʋ�ѯ���ݷ�Χʱ�����˱߽�ֵ,not between������
select * from table1 where time between time1 and time2
select a,b,c, from table1 where a not between ��ֵ1 and ��ֵ2
9��˵����in ��ʹ�÷���
select * from table1 where a [not] in (��ֵ1��,��ֵ2��,��ֵ4��,��ֵ6��)
10��˵�������Ź�����ɾ���������Ѿ��ڸ�����û�е���Ϣ
delete from table1 where not exists ( select * from table2 where table1.field1=table2.field1 )
11��˵�����ı��������⣺
select * from a left inner join b on a.a=b.b right inner join c on a.a=c.c inner join d on a.a=d.d where .....
12��˵�����ճ̰�����ǰ���������
SQL: select * from �ճ̰��� where datediff('minute',f��ʼʱ��,getdate())>5
13��˵����һ��sql ���㶨���ݿ��ҳ
select top 10 b.* from (select top 20 �����ֶ�,�����ֶ� from ���� order by �����ֶ� desc) a,���� b where b.�����ֶ� = a.�����ֶ� order by a.�����ֶ�
14��˵����ǰ10����¼
select top 10 * form table1 where ��Χ
15��˵����ѡ����ÿһ��bֵ��ͬ�������ж�Ӧ��a���ļ�¼��������Ϣ(�����������÷�����������̳ÿ�����а�,ÿ��������Ʒ����,����Ŀ�ɼ�����,�ȵ�.)
select a,b,c from tablename ta where a=(select max(a) from tablename tb where tb.b=ta.b)
16��˵�������������� TableA �е����� TableB��TableC �е��в����������ظ��ж�������һ�������
(select a from tableA ) except (select a from tableB) except (select a from tableC)
17��˵�������ȡ��10������
select top 10 * from tablename order by newid()
18��˵�������ѡ���¼
select newid()
19��˵����ɾ���ظ���¼
Delete from tablename where id not in (select max(id) from tablename group by col1,col2,...)
20��˵�����г����ݿ������еı���
select name from sysobjects where type='U'
21��˵�����г���������е�
select name from syscolumns where id=object_id('TableName')
22��˵������ʾtype��vender��pcs�ֶΣ���type�ֶ����У�case���Է����ʵ�ֶ���ѡ������select �е�case��
select type,sum(case vender when 'A' then pcs else 0 end),sum(case vender when 'C' then pcs else 0 end),sum(case vender when 'B' then pcs else 0 end) FROM tablename group by type
��ʾ�����
type vender pcs
���� A 1
���� A 1
���� B 2
���� A 2
�ֻ� B 3
�ֻ� C 3
23��˵������ʼ����table1
TRUNCATE TABLE table1
24��˵����ѡ���10��15�ļ�¼
select top 5 * from (select top 15 * from table order by id asc) table_���� order by id desc

��������

1��1=1��1=2��ʹ�ã���SQL������ʱ�õĽ϶�

��where 1=1�� �Ǳ�ʾѡ��ȫ��   ��where 1=2��ȫ����ѡ��
�磺
if @strWhere !=''
begin
set @strSQL = 'select count(*) as Total from [' + @tblName + '] where ' +@strWhere
end
else
begin
set @strSQL = 'select count(*) as Total from [' + @tblName + ']'
end

���ǿ���ֱ��д��
set @strSQL = 'select count(*) as Total from [' + @tblName + '] where 1=1 ���� '+@strWhere

2���������ݿ�
--�ؽ�����
DBCC REINDEX
DBCC INDEXDEFRAG
--�������ݺ���־
DBCC SHRINKDB
DBCC SHRINKFILE

3��ѹ�����ݿ�
dbcc shrinkdatabase(dbname)

4��ת�����ݿ�����û����Ѵ����û�Ȩ��
exec sp_change_users_login 'update_one','newname','oldname'
go
5����鱸�ݼ�
RESTORE VERIFYONLY from disk='E:/dvbbs.bak'
6���޸����ݿ�
ALTER DATABASE [dvbbs] SET SINGLE_USER
GO
DBCC CHECKDB('dvbbs',repair_allow_data_loss) WITH TABLOCK
GO
ALTER DATABASE [dvbbs] SET MULTI_USER
GO

7����־���
SET NOCOUNT ON
DECLARE @LogicalFileName sysname,
        @MaxMinutes INT,
        @NewSize INT

USE     tablename             -- Ҫ���������ݿ���
SELECT  @LogicalFileName = 'tablename_log',  -- ��־�ļ���
@MaxMinutes = 10,               -- Limit on time allowed to wrap log.
        @NewSize = 1                  -- �����趨����־�ļ��Ĵ�С(M)
-- Setup / initialize
DECLARE @OriginalSize int
SELECT @OriginalSize = size
  FROM sysfiles
  WHERE name = @LogicalFileName
SELECT 'Original Size of ' + db_name() + ' LOG is ' +
        CONVERT(VARCHAR(30),@OriginalSize) + ' 8K pages or ' +
        CONVERT(VARCHAR(30),(@OriginalSize*8/1024)) + 'MB'
  FROM sysfiles
  WHERE name = @LogicalFileName
CREATE TABLE DummyTrans
  (DummyColumn char (8000) not null)

DECLARE @Counter   INT,
        @StartTime DATETIME,
        @TruncLog  VARCHAR(255)
SELECT  @StartTime = GETDATE(),
        @TruncLog = 'BACKUP LOG ' + db_name() + ' WITH TRUNCATE_ONLY'
DBCC SHRINKFILE (@LogicalFileName, @NewSize)
EXEC (@TruncLog)
-- Wrap the log if necessary.
WHILE     @MaxMinutes > DATEDIFF (mi, @StartTime, GETDATE()) -- time has not expired
      AND @OriginalSize = (SELECT size FROM sysfiles WHERE name = @LogicalFileName)  
      AND (@OriginalSize * 8 /1024) > @NewSize  
  BEGIN -- Outer loop.
    SELECT @Counter = 0
    WHILE  ((@Counter < @OriginalSize / 16) AND (@Counter < 50000))
      BEGIN -- update
        INSERT DummyTrans VALUES ('Fill Log')  
        DELETE DummyTrans
        SELECT @Counter = @Counter + 1
      END  
    EXEC (@TruncLog)  
  END  
SELECT 'Final Size of ' + db_name() + ' LOG is ' +
        CONVERT(VARCHAR(30),size) + ' 8K pages or ' +
        CONVERT(VARCHAR(30),(size*8/1024)) + 'MB'
  FROM sysfiles
  WHERE name = @LogicalFileName
DROP TABLE DummyTrans
SET NOCOUNT OFF

8��˵��������ĳ����
exec sp_changeobjectowner 'tablename','dbo'

9���洢����ȫ����

CREATE PROCEDURE dbo.User_ChangeObjectOwnerBatch
@OldOwner as NVARCHAR(128),
@NewOwner as NVARCHAR(128)
AS
DECLARE @Name   as NVARCHAR(128)
DECLARE @Owner  as NVARCHAR(128)
DECLARE @OwnerName  as NVARCHAR(128)
DECLARE curObject CURSOR FOR
select 'Name'   = name,
  'Owner'   = user_name(uid)
from sysobjects
where user_name(uid)=@OldOwner
order by name
OPEN  curObject
FETCH NEXT FROM curObject INTO @Name, @Owner
WHILE(@@FETCH_STATUS=0)
BEGIN    
if @Owner=@OldOwner
begin
  set @OwnerName = @OldOwner + '.' + rtrim(@Name)
  exec sp_changeobjectowner @OwnerName, @NewOwner
end
-- select @name,@NewOwner,@OldOwner
FETCH NEXT FROM curObject INTO @Name, @Owner
END
close curObject
deallocate curObject
GO

10��SQL SERVER��ֱ��ѭ��д������
declare @i int
set @i=1
while @i<30
begin
   insert into test (userid) values(@i)
   set @i=@i+1
end 