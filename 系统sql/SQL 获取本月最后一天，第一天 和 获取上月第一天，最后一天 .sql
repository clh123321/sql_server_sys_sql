

SELECT CONVERT(datetime,CONVERT(char(8),GETDATE(),120)+'1')--这月的第一天
select dateadd(d,-day(getdate()),dateadd(m,1,getdate()))--这月的最后一天 
SELECT DATEADD(mm,DATEDIFF(mm,0,dateadd(month,-1,getdate())),0)--上月第一天
select dateadd(ms,-3,DATEADD(mm,DATEDIFF(mm,0,getdate()),0))--上月最后一天
select DATEADD(SS,-1,dateadd(day,1,CONVERT(varchar(15) , getdate(), 102 )))--获取当天的最后一刻