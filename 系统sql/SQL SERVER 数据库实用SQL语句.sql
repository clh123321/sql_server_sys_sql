
1.按姓氏笔画排序:
Select * From TableName Order By CustomerName Collate Chinese_PRC_Stroke_ci_as

例句
Select * From Business
Select * From Business Order By [Name] Collate Chinese_PRC_Stroke_ci_as 

2.分页SQL语句

select * from(select (row_number() OVER (ORDER BY tab.ID Desc)) as rownum,tab.* from 表名 As tab) As t where rownum between 起始位置 And 结束位置

3.获取当前数据库中的所有用户表
select * from sysobjects where xtype='U' and category=0

4.获取某一个表的所有字段
select name from syscolumns where id=object_id('eCommerce')

5.查看与某一个表相关的视图、存储过程、函数
select a.* from sysobjects a, syscomments b where a.id = b.id and b.text like '%表名%'

6.查看当前数据库中所有存储过程
select name as 存储过程名称 from sysobjects where xtype='P'

7.查询用户创建的所有数据库
select * from master..sysdatabases D where sid not in(select sid from master..syslogins where name='sa')
或者
select dbid, name AS DB_NAME from master..sysdatabases where sid <> 0x01

8.查询某一个表的字段和数据类型
select column_name,data_type from information_schema.columns
where table_name = '表名'

9.使用事务
在使用一些对数据库表的临时的SQL语句操作时，可以采用SQL SERVER事务处理，防止对数据操作后发现误操作问题
开始事务
Begin tran
Insert Into TableName Values(…)
SQL语句操作不正常，则回滚事务。
回滚事务
Rollback tran
SQL语句操作正常，则提交事务，数据提交至数据库。
提交事务
Commit tran
10. 按全文匹配方式查询
字段名 LIKE N'%[^a-zA-Z0-9]China[^a-zA-Z0-9]%'
OR 字段名 LIKE N'%[^a-zA-Z0-9]China'
OR 字段名 LIKE N'China[^a-zA-Z0-9]%'
OR 字段名 LIKE N'China

11.计算执行SQL语句查询时间
declare @d datetime
set @d=getdate()
select * from SYS_ColumnProperties select [语句执行花费时间(毫秒)]=datediff(ms,@d,getdate())

12. 说明：几个高级查询运算词
A： UNION 运算符
UNION 运算符通过组合其他两个结果表（例如 TABLE1 和 TABLE2）并消去表中任何重复行而派生出一个结果表。当 ALL 随 UNION 一起使用时（即 UNION ALL），不消除重复行。两种情况下，派生表的每一行不是来自 TABLE1 就是来自 TABLE2。
B： EXCEPT 运算符
EXCEPT 运算符通过包括所有在 TABLE1 中但不在 TABLE2 中的行并消除所有重复行而派生出一个结果表。当 ALL 随 EXCEPT 一起使用时 (EXCEPT ALL)，不消除重复行。
C： INTERSECT 运算符
INTERSECT 运算符通过只包括 TABLE1 和 TABLE2 中都有的行并消除所有重复行而派生出一个结果表。当 ALL 随 INTERSECT 一起使用时 (INTERSECT ALL)，不消除重复行。

