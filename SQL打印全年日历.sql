/*�������ݣ�������ڣ�ȫ���ж�����*/
WITH    x0
          AS ( SELECT   CONVERT(DATE, '2015-01-01') AS yearbegin ,
                        CONVERT(DATE, '2015-12-31') AS yearend ,
                        DATEDIFF(DAY, '2015-01-01', '2015-12-31') AS dayscount
             ),/*ö��ȫ�����������*/
        x1
          AS ( SELECT   DATEADD(DAY, number, yearbegin) AS ndate
               FROM     x0 ,
                        master.dbo.spt_values spt
               WHERE    spt.type = 'P'
                        AND spt.number >= 0
                        AND spt.number <= dayscount
             ),/*����ȫ�����ڶ�Ӧ���·ݣ��ڼ��ܣ����ڼ������µڼ���*/
        x2
          AS ( SELECT   ndate ,
                        DATEPART(month, ndate) AS nmonth ,
                        DATEPART(week, ndate) AS nweek ,
                        DATEPART(weekday, ndate) AS nweekday ,
                        DATEPART(day, ndate) AS nday
               FROM     x1
             ),/*���·ݡ������ܷ��飬����ȫ������*/
        x3
          AS ( SELECT   nmonth ,
                        nweek ,
                        ISNULL(CAST(MAX(CASE nweekday
                                          WHEN 1 THEN nday
                                        END) AS VARCHAR(2)), '') AS �� ,
                        ISNULL(CAST(MAX(CASE nweekday
                                          WHEN 2 THEN nday
                                        END) AS VARCHAR(2)), '') AS һ ,
                        ISNULL(CAST(MAX(CASE nweekday
                                          WHEN 3 THEN nday
                                        END) AS VARCHAR(2)), '') AS �� ,
                        ISNULL(CAST(MAX(CASE nweekday
                                          WHEN 4 THEN nday
                                        END) AS VARCHAR(2)), '') AS �� ,
                        ISNULL(CAST(MAX(CASE nweekday
                                          WHEN 5 THEN nday
                                        END) AS VARCHAR(2)), '') AS �� ,
                        ISNULL(CAST(MAX(CASE nweekday
                                          WHEN 6 THEN nday
                                        END) AS VARCHAR(2)), '') AS �� ,
                        ISNULL(CAST(MAX(CASE nweekday
                                          WHEN 7 THEN nday
                                        END) AS VARCHAR(2)), '') AS ��
               FROM     x2
               GROUP BY nmonth ,
                        nweek
             )/*���·���ͬ��ֵֻ�ڵ�һ����ʾ*/
    SELECT  REPLACE(CASE WHEN ROW_NUMBER() OVER ( PARTITION BY nmonth ORDER BY nweek ) = 1
                         THEN nmonth
                         ELSE -1
                    END, -1, '') AS �·� ,
            �� ,
            һ ,
            �� ,
            �� ,
            �� ,
            �� ,
            ��
    FROM    x3