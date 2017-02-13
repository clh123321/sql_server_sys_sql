/*基础数据：年初日期，全年有多少天*/
WITH    x0
          AS ( SELECT   CONVERT(DATE, '2015-01-01') AS yearbegin ,
                        CONVERT(DATE, '2015-12-31') AS yearend ,
                        DATEDIFF(DAY, '2015-01-01', '2015-12-31') AS dayscount
             ),/*枚举全年的所有日期*/
        x1
          AS ( SELECT   DATEADD(DAY, number, yearbegin) AS ndate
               FROM     x0 ,
                        master.dbo.spt_values spt
               WHERE    spt.type = 'P'
                        AND spt.number >= 0
                        AND spt.number <= dayscount
             ),/*罗列全年日期对应的月份，第几周，星期几，本月第几天*/
        x2
          AS ( SELECT   ndate ,
                        DATEPART(month, ndate) AS nmonth ,
                        DATEPART(week, ndate) AS nweek ,
                        DATEPART(weekday, ndate) AS nweekday ,
                        DATEPART(day, ndate) AS nday
               FROM     x1
             ),/*按月份、所在周分组，生成全年日历*/
        x3
          AS ( SELECT   nmonth ,
                        nweek ,
                        ISNULL(CAST(MAX(CASE nweekday
                                          WHEN 1 THEN nday
                                        END) AS VARCHAR(2)), '') AS 日 ,
                        ISNULL(CAST(MAX(CASE nweekday
                                          WHEN 2 THEN nday
                                        END) AS VARCHAR(2)), '') AS 一 ,
                        ISNULL(CAST(MAX(CASE nweekday
                                          WHEN 3 THEN nday
                                        END) AS VARCHAR(2)), '') AS 二 ,
                        ISNULL(CAST(MAX(CASE nweekday
                                          WHEN 4 THEN nday
                                        END) AS VARCHAR(2)), '') AS 三 ,
                        ISNULL(CAST(MAX(CASE nweekday
                                          WHEN 5 THEN nday
                                        END) AS VARCHAR(2)), '') AS 四 ,
                        ISNULL(CAST(MAX(CASE nweekday
                                          WHEN 6 THEN nday
                                        END) AS VARCHAR(2)), '') AS 五 ,
                        ISNULL(CAST(MAX(CASE nweekday
                                          WHEN 7 THEN nday
                                        END) AS VARCHAR(2)), '') AS 六
               FROM     x2
               GROUP BY nmonth ,
                        nweek
             )/*将月份相同的值只在第一行显示*/
    SELECT  REPLACE(CASE WHEN ROW_NUMBER() OVER ( PARTITION BY nmonth ORDER BY nweek ) = 1
                         THEN nmonth
                         ELSE -1
                    END, -1, '') AS 月份 ,
            日 ,
            一 ,
            二 ,
            三 ,
            四 ,
            五 ,
            六
    FROM    x3