--���������һ��
DECLARE @Date DATETIME = GETDATE();
  
SELECT @Date AS 'Ŀǰʱ��'
,DATEADD(DD,-1,@Date) AS 'ǰһ��'
,DATEADD(DD,1,@Date) AS '��һ��'
/*�¼���*/
,DATEADD(MONTH,DATEDIFF(MONTH,0,@Date),0) AS '�³�'--��SQL Server��0 ����1900-01-01,ͨ�������㣬��֤�պ��Ϊ1��
,DATEADD(DD,-1,DATEADD(MONTH,1+DATEDIFF(MONTH,0,@Date),0)) AS '��ĩ(��ȷ����)'--�ҵ����³��ٿۼ�1�죬����ʹ��DATEADD����Ҫֱ�ӡ�-1��
,DATEADD(SS,-1,DATEADD(MONTH,1+DATEDIFF(MONTH,0,@Date),0)) AS '��ĩ(��ȷ��datetime��С��λ)'
,DATEADD(MONTH,DATEDIFF(MONTH,0,@Date)-1,0) AS '���µ�һ��'
,DATEADD(DAY,-1,DATEADD(DAY,1-DATEPART(DAY,@Date),@Date)) AS '�������һ��'
,DATEADD(MONTH,DATEDIFF(MONTH,0,@Date)+1,0) AS '���µ�һ��'
,DATEADD(DAY,-1,DATEADD(MONTH,2,DATEADD(DAY,1-DATEPART(DAY,@Date),@Date)))  AS '�������һ��'
/*�ܼ���*/
,DATEADD(WEEKDAY,1-DATEPART(WEEKDAY,@Date),@Date) AS '���ܵ�һ��(����)'--ע��˴���@@datefirst��ֵ�й�
,DATEADD(WEEK,DATEDIFF(WEEK,-1,@Date),-1) AS '�������ڵ�������'--ע��˴���@@datefirst��ֵ�й�
,DATEADD(DAY,2-DATEPART(WEEKDAY,@Date),@Date) AS '�������ڵĵڶ���'--ע��˴���@@datefirst��ֵ�й�,������������
,DATEADD(WEEK,-1,DATEADD(DAY,1-DATEPART(WEEKDAY,@Date),@Date)) AS '�ϸ����ڵ�һ��(����)'--ע��˴���@@datefirst��ֵ�й�
,DATEADD(WEEK,1,DATEADD(DAY,1-DATEPART(WEEKDAY,@Date),@Date)) AS '�¸����ڵ�һ��(������)'--ע��˴���@@datefirst��ֵ�й�
,DATENAME(WEEKDAY,@Date) AS '�������ܼ�'
,DATEPART(WEEKDAY,@Date) AS '�������ܼ�'--����ֵ 1-�����գ�2-����һ��3-���ڶ�......7-������
/*��ȼ���*/
,DATEADD(YEAR,DATEDIFF(YEAR,0,@Date),0) AS '���'
,DATEADD(YEAR,DATEDIFF(YEAR,-1,@Date),-1) AS '��ĩ'
,DATEADD(YEAR,DATEDIFF(YEAR,-0,@Date)-1,0) AS 'ȥ�����'
,DATEADD(YEAR,DATEDIFF(YEAR,-0,@Date),-1) AS 'ȥ����ĩ'
,DATEADD(YEAR,1+DATEDIFF(YEAR,0,@Date),0) AS '�������'
,DATEADD(YEAR,1+DATEDIFF(YEAR,-1,@Date),-1) AS '������ĩ'
/*���ȼ���*/
,DATEADD(QUARTER,DATEDIFF(QUARTER,0,@Date),0) AS '��������'
,DATEADD(QUARTER,1+DATEDIFF(QUARTER,0,@Date),-1) AS '������ĩ'
,DATEADD(QUARTER,DATEDIFF(QUARTER,0,@Date)-1,0) AS '�ϼ�����'
,DATEADD(QUARTER,DATEDIFF(QUARTER,0,@Date),-1) AS '�ϼ���ĩ'
,DATEADD(QUARTER,1+DATEDIFF(QUARTER,0,@Date),0) AS '�¼�����'
,DATEADD(QUARTER,2+DATEDIFF(QUARTER,0,@Date),-1) AS '�¼���ĩ'