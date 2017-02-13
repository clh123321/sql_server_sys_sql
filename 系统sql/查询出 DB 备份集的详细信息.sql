


SELECT TOP 1000 [backup_set_id],a.[media_set_id],[expiration_date],[name],[user_name],[software_major_version],[backup_start_date],[backup_finish_date],[type],[compatibility_level],       [backup_size],[database_name] ,[server_name], [is_password_protected],[recovery_model],[is_damaged] ,[begins_log_chain],[compressed_backup_size], b.physical_device_name    

FROM [msdb].[dbo].[backupset] a,[msdb].[dbo].[backupmediafamily] b  

where a.media_set_id=b.media_set_id  order by backup_set_id desc


