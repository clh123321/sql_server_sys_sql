							--首先判断临时是否存在
							IF object_id('tempdb..#tempTable') is not null 
							Begin
									DROP TABLE  #tempTable
							END
  
							--填充临时表                     
							SELECT ROW_NUMBER() over(ORDER by [CreateTime])  AS tcount ,[QRID],[OpenId],CONVERT(VARCHAR(100),[CreateTime], 23) AS CreateTime,[Status] 
							INTO #tempTable
							FROM [CustomLog]
							WHERE [CreateTime]  >  '2015-08-31 00:00:00.000' AND  [CreateTime]  <  '2015-09-01 00:00:00.000'

							--插入数据
							SELECT CreateTime,[QRID], SUM(CASE WHEN Status=1 THEN 1 ELSE 0 END ) num1,SUM(CASE WHEN Status=0 THEN 1 ELSE 0 END ) num2,GETDATE() AS nowTime
							FROM #tempTable
								WHERE [tcount] IN 
								(SELECT MAX(tcount) FROM #tempTable
									GROUP BY [OpenId],[Status],[QRID]
								) 
								GROUP BY CreateTime,[QRID]

							--删除临时表
							IF object_id('tempdb..#tempTable') is not null 
							Begin
									DROP TABLE  #tempTable
							END
                            