create function f_int2bin(@i int)
returns varchar(31)
as
begin
    declare @s varchar(31);
    set @s=''
    while (@i>0)
        select @s=cast(@i%2 as varchar)+@s, @i=@i/2
    return(@s)
end

--µ÷ÓÃ
select dbo.f_int2bin(200)
