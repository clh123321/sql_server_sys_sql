    --====================================  
    --标题: 应用实例之SQL SERVER 正则匹配  
    --作者：maco_wang  
    --时间：2012-03-25  
    --说明：MS-SQL SERVER 中的正则匹配  
    --====================================  
      
    /*  
    假设测试数据为：  
    col  
    ----------  
    a b d c e  
    a a b c d  
    b b c d e  
    e u g h w  
    o a k d w  
      
    1)得到没有重复字母的行，即想要得到如下结果：  
    col  
    --------------  
    a b c d e  
    e u g h w  
    o p k n w  
      
    2)得到同时存在a和d，并且a和d之间只有0或是1个字母的，即想要得到的结果:  
    col  
    ----------  
    a b d c e  
    o a k d w  
      
    */  
      
    --测试数据  
    if object_id('[tb]') is not null drop table [tb]  
    create table [tb] (col varchar(10))  
    insert into [tb]  
    select 'a b d c e' union all  
    select 'a a b c d' union all  
    select 'b b c d e' union all  
    select 'e u g h w' union all  
    select 'o a k d w'   
      
    select * from [tb]  
      
    --本示例在SQL SERVER 2000版本即可适用。  
      
    go  
    create function dbo.RegexMatch  
    (  
        @pattern varchar(2000),  
        @matchstring varchar(8000)  
    )  
    returns int  
    as   
    begin  
        declare @objRegexExp int  
        declare @strErrorMessage varchar(255)  
        declare @hr int,@match bit  
        exec @hr= sp_OACreate 'VBScript.RegExp', @objRegexExp out  
        if @hr = 0   
            exec @hr= sp_OASetProperty @objRegexExp, 'Pattern', @pattern  
        if @hr = 0   
            exec @hr= sp_OASetProperty @objRegexExp, 'IgnoreCase', 1  
        if @hr = 0   
            exec @hr= sp_OAMethod @objRegexExp, 'Test', @match OUT, @matchstring  
        if @hr <>0   
        begin  
            return null  
        end  
        exec sp_OADestroy @objRegexExp  
        return @match  
    end  
      
    go  
    --1)得到没有重复字母的行  
    --正常思路，可能是按照空格分割后去重然后合并，最后判断长度（略）  
      
    --用正则就很方便了  
    select col from [tb] where dbo.RegexMatch('^.*?([a-z])[ ]\1.*?$',col)=0  
    /*  
    col  
    ----------  
    a b d c e  
    e u g h w  
    o a k d w  
    */  
      
    --2)得到同时存在a和d，并且a和d之间间隔小于等于一个字母的  
      
    --正常思路  
    select col from [tb]   
    where charindex('a',col)>0  
    and charindex('d',col)>0  
    and abs(charindex('a',col)-charindex('d',col))<5  
    /*  
    col  
    ----------  
    a b d c e  
    o a k d w  
    */  
    --正则处理  
    select col from [tb] where dbo.RegexMatch('.*a[a-z ]{1,3}d.*',col)=1  
    /*  
    col  
    ----------  
    a b d c e  
    o a k d w  
    */  
    --这里的正则写法考虑的就不全，如果d在a前面呢？  
    --那么修正一下  
    select col from [tb]   
    where dbo.RegexMatch('.*d[a-z ]{1,3}a.*|.*a[a-z ]{1,3}d.*',col)=1  
    /*  
    col  
    ----------  
    a b d c e  
    o a k d w  
    */  