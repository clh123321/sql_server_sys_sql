SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
create function [dbo].[SPLIT](@SourceSql varchar(8000),@StrSeprate varchar(10))
returns @temp table(Item varchar(100))
as 
begin
declare @i int
set @SourceSql=rtrim(ltrim(@SourceSql))
set @i=charindex(@StrSeprate,@SourceSql)
while @i>=1
begin
insert @temp values(left(@SourceSql,@i-1))
set @SourceSql=substring(@SourceSql,@i+1,len(@SourceSql)-@i)
set @i=charindex(@StrSeprate,@SourceSql)
end
if @SourceSql<>''
insert @temp values(@SourceSql)
return 
end
GO


SELECT * from [dbo].[SPLIT]('a,2,c',',')