
---�������ݿ�
create database DBTest 
on  primary  -- Ĭ�Ͼ�����primary�ļ���,��ʡ��
(
/*--�����ļ��ľ�������--*/
    name='stuDB_data',  -- �������ļ����߼�����
    filename='D:\stuDB_data.mdf', -- �������ļ�����������
    size=5mb, --�������ļ��ĳ�ʼ��С
    maxsize=100mb, -- �������ļ����������ֵ
    filegrowth=15%--�������ļ���������
)
log on
(
	/*--��־�ļ��ľ�������,����������ͬ��--*/
    name='stuDB_log',
    filename='D:\stuDB_log.ldf',
    size=2mb,
    filegrowth=1mb
)




--����ļ���
ALTER DATABASE DBTest ADD FILEGROUP DBTest_2015

--����ļ�
ALTER DATABASE DBTest
ADD FILE(
NAME=N'DBTest_2015',
FILENAME='E:\DBTest_2015.NDF',
SIZE=3MB,
MAXSIZE=100MB,
FILEGROWTH=5MB
)TO FILEGROUP DBTest_2015

--ɾ���ļ���
ALTER DATABASE DBTest REMOVE FILE DBTest_2015 --REMOVE

--�޸��ļ�
USE master;
GO
ALTER DATABASE DBTest
MODIFY FILE
(NAME = DBTest_2015,
SIZE = 20MB);
GO

--�ƶ��ļ�
USE master;
GO
ALTER DATABASE DBTest
MODIFY FILE
(
NAME = DBTest_2015,
FILENAME = N'c:\t1dat2.ndf'
);


