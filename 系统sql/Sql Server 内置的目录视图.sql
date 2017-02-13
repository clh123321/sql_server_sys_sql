select a.name,a.[type],b.[definition] 
from sys.all_objects a,sys.sql_modules b 
where a.is_ms_shipped=0 and a.object_id = b.object_id and a.[type] in ('P','V','AF') 
order by a.[name] asc