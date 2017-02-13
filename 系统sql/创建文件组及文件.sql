
---创建数据库
create database DBTest 
on  primary  -- 默认就属于primary文件组,可省略
(
/*--数据文件的具体描述--*/
    name='stuDB_data',  -- 主数据文件的逻辑名称
    filename='D:\stuDB_data.mdf', -- 主数据文件的物理名称
    size=5mb, --主数据文件的初始大小
    maxsize=100mb, -- 主数据文件增长的最大值
    filegrowth=15%--主数据文件的增长率
)
log on
(
	/*--日志文件的具体描述,各参数含义同上--*/
    name='stuDB_log',
    filename='D:\stuDB_log.ldf',
    size=2mb,
    filegrowth=1mb
)




--添加文件组
ALTER DATABASE DBTest ADD FILEGROUP DBTest_2015

--添加文件
ALTER DATABASE DBTest
ADD FILE(
NAME=N'DBTest_2015',
FILENAME='E:\DBTest_2015.NDF',
SIZE=3MB,
MAXSIZE=100MB,
FILEGROWTH=5MB
)TO FILEGROUP DBTest_2015

--删除文件组
ALTER DATABASE DBTest REMOVE FILE DBTest_2015 --REMOVE

--修改文件
USE master;
GO
ALTER DATABASE DBTest
MODIFY FILE
(NAME = DBTest_2015,
SIZE = 20MB);
GO

--移动文件
USE master;
GO
ALTER DATABASE DBTest
MODIFY FILE
(
NAME = DBTest_2015,
FILENAME = N'c:\t1dat2.ndf'
);


