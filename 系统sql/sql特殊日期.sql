--定义给定的一天
DECLARE @Date DATETIME = GETDATE();
  
SELECT @Date AS '目前时间'
,DATEADD(DD,-1,@Date) AS '前一天'
,DATEADD(DD,1,@Date) AS '后一天'
/*月计算*/
,DATEADD(MONTH,DATEDIFF(MONTH,0,@Date),0) AS '月初'--在SQL Server中0 代表1900-01-01,通过月运算，保证日恒久为1号
,DATEADD(DD,-1,DATEADD(MONTH,1+DATEDIFF(MONTH,0,@Date),0)) AS '月末(精确到天)'--找到下月初再扣减1天，建议使用DATEADD而不要直接“-1”
,DATEADD(SS,-1,DATEADD(MONTH,1+DATEDIFF(MONTH,0,@Date),0)) AS '月末(精确到datetime的小数位)'
,DATEADD(MONTH,DATEDIFF(MONTH,0,@Date)-1,0) AS '上月第一天'
,DATEADD(DAY,-1,DATEADD(DAY,1-DATEPART(DAY,@Date),@Date)) AS '上月最后一天'
,DATEADD(MONTH,DATEDIFF(MONTH,0,@Date)+1,0) AS '下月第一天'
,DATEADD(DAY,-1,DATEADD(MONTH,2,DATEADD(DAY,1-DATEPART(DAY,@Date),@Date)))  AS '下月最后一天'
/*周计算*/
,DATEADD(WEEKDAY,1-DATEPART(WEEKDAY,@Date),@Date) AS '本周第一天(周日)'--注意此处与@@datefirst的值有关
,DATEADD(WEEK,DATEDIFF(WEEK,-1,@Date),-1) AS '所在星期的星期日'--注意此处与@@datefirst的值有关
,DATEADD(DAY,2-DATEPART(WEEKDAY,@Date),@Date) AS '所在星期的第二天'--注意此处与@@datefirst的值有关,其他天数类推
,DATEADD(WEEK,-1,DATEADD(DAY,1-DATEPART(WEEKDAY,@Date),@Date)) AS '上个星期第一天(周日)'--注意此处与@@datefirst的值有关
,DATEADD(WEEK,1,DATEADD(DAY,1-DATEPART(WEEKDAY,@Date),@Date)) AS '下个星期第一天(星期日)'--注意此处与@@datefirst的值有关
,DATENAME(WEEKDAY,@Date) AS '本日是周几'
,DATEPART(WEEKDAY,@Date) AS '本日是周几'--返回值 1-星期日，2-星期一，3-星期二......7-星期六
/*年度计算*/
,DATEADD(YEAR,DATEDIFF(YEAR,0,@Date),0) AS '年初'
,DATEADD(YEAR,DATEDIFF(YEAR,-1,@Date),-1) AS '年末'
,DATEADD(YEAR,DATEDIFF(YEAR,-0,@Date)-1,0) AS '去年年初'
,DATEADD(YEAR,DATEDIFF(YEAR,-0,@Date),-1) AS '去年年末'
,DATEADD(YEAR,1+DATEDIFF(YEAR,0,@Date),0) AS '明年年初'
,DATEADD(YEAR,1+DATEDIFF(YEAR,-1,@Date),-1) AS '明年年末'
/*季度计算*/
,DATEADD(QUARTER,DATEDIFF(QUARTER,0,@Date),0) AS '本季季初'
,DATEADD(QUARTER,1+DATEDIFF(QUARTER,0,@Date),-1) AS '本季季末'
,DATEADD(QUARTER,DATEDIFF(QUARTER,0,@Date)-1,0) AS '上季季初'
,DATEADD(QUARTER,DATEDIFF(QUARTER,0,@Date),-1) AS '上季季末'
,DATEADD(QUARTER,1+DATEDIFF(QUARTER,0,@Date),0) AS '下季季初'
,DATEADD(QUARTER,2+DATEDIFF(QUARTER,0,@Date),-1) AS '下季季末'