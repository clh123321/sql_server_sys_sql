
1.�����ϱʻ�����:
Select * From TableName Order By CustomerName Collate Chinese_PRC_Stroke_ci_as

����
Select * From Business
Select * From Business Order By [Name] Collate Chinese_PRC_Stroke_ci_as 

2.��ҳSQL���

select * from(select (row_number() OVER (ORDER BY tab.ID Desc)) as rownum,tab.* from ���� As tab) As t where rownum between ��ʼλ�� And ����λ��

3.��ȡ��ǰ���ݿ��е������û���
select * from sysobjects where xtype='U' and category=0

4.��ȡĳһ����������ֶ�
select name from syscolumns where id=object_id('eCommerce')

5.�鿴��ĳһ������ص���ͼ���洢���̡�����
select a.* from sysobjects a, syscomments b where a.id = b.id and b.text like '%����%'

6.�鿴��ǰ���ݿ������д洢����
select name as �洢�������� from sysobjects where xtype='P'

7.��ѯ�û��������������ݿ�
select * from master..sysdatabases D where sid not in(select sid from master..syslogins where name='sa')
����
select dbid, name AS DB_NAME from master..sysdatabases where sid <> 0x01

8.��ѯĳһ������ֶκ���������
select column_name,data_type from information_schema.columns
where table_name = '����'

9.ʹ������
��ʹ��һЩ�����ݿ�����ʱ��SQL������ʱ�����Բ���SQL SERVER��������ֹ�����ݲ����������������
��ʼ����
Begin tran
Insert Into TableName Values(��)
SQL����������������ع�����
�ع�����
Rollback tran
SQL���������������ύ���������ύ�����ݿ⡣
�ύ����
Commit tran
10. ��ȫ��ƥ�䷽ʽ��ѯ
�ֶ��� LIKE N'%[^a-zA-Z0-9]China[^a-zA-Z0-9]%'
OR �ֶ��� LIKE N'%[^a-zA-Z0-9]China'
OR �ֶ��� LIKE N'China[^a-zA-Z0-9]%'
OR �ֶ��� LIKE N'China

11.����ִ��SQL����ѯʱ��
declare @d datetime
set @d=getdate()
select * from SYS_ColumnProperties select [���ִ�л���ʱ��(����)]=datediff(ms,@d,getdate())

12. ˵���������߼���ѯ�����
A�� UNION �����
UNION �����ͨ���������������������� TABLE1 �� TABLE2������ȥ�����κ��ظ��ж�������һ��������� ALL �� UNION һ��ʹ��ʱ���� UNION ALL�����������ظ��С���������£��������ÿһ�в������� TABLE1 �������� TABLE2��
B�� EXCEPT �����
EXCEPT �����ͨ������������ TABLE1 �е����� TABLE2 �е��в����������ظ��ж�������һ��������� ALL �� EXCEPT һ��ʹ��ʱ (EXCEPT ALL)���������ظ��С�
C�� INTERSECT �����
INTERSECT �����ͨ��ֻ���� TABLE1 �� TABLE2 �ж��е��в����������ظ��ж�������һ��������� ALL �� INTERSECT һ��ʹ��ʱ (INTERSECT ALL)���������ظ��С�

