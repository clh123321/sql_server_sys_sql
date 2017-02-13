select top 150 a.run_date,a.run_time, b.name,step_id,step_name,a.message,a.run_status,a.run_duration
                                from msdb.dbo.sysjobhistory a ,msdb.dbo.sysjobs b
                                where a.job_id=b.job_id and name not in('job_exclude') and a.step_id>0
                                order by run_date desc