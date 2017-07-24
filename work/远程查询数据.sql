exec sp_addlinkedserver '169', '', 'SQLOLEDB', '192.168.0.169\sql2008'
exec sp_addlinkedsrvlogin '169', 'false',null, 'sa', 'sa' 


--select * from [169].数据库名.dbo.表名 

--以后不再使用时删除链接服务器
exec sp_dropserver 'ITSV ', 'droplogins' 



--http://www.jb51.net/article/32278.htm
--http://www.cnblogs.com/kingsony/p/4013552.html