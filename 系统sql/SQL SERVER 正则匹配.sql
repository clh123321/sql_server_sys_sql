    --====================================  
    --����: Ӧ��ʵ��֮SQL SERVER ����ƥ��  
    --���ߣ�maco_wang  
    --ʱ�䣺2012-03-25  
    --˵����MS-SQL SERVER �е�����ƥ��  
    --====================================  
      
    /*  
    �����������Ϊ��  
    col  
    ----------  
    a b d c e  
    a a b c d  
    b b c d e  
    e u g h w  
    o a k d w  
      
    1)�õ�û���ظ���ĸ���У�����Ҫ�õ����½����  
    col  
    --------------  
    a b c d e  
    e u g h w  
    o p k n w  
      
    2)�õ�ͬʱ����a��d������a��d֮��ֻ��0����1����ĸ�ģ�����Ҫ�õ��Ľ��:  
    col  
    ----------  
    a b d c e  
    o a k d w  
      
    */  
      
    --��������  
    if object_id('[tb]') is not null drop table [tb]  
    create table [tb] (col varchar(10))  
    insert into [tb]  
    select 'a b d c e' union all  
    select 'a a b c d' union all  
    select 'b b c d e' union all  
    select 'e u g h w' union all  
    select 'o a k d w'   
      
    select * from [tb]  
      
    --��ʾ����SQL SERVER 2000�汾�������á�  
      
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
    --1)�õ�û���ظ���ĸ����  
    --����˼·�������ǰ��տո�ָ��ȥ��Ȼ��ϲ�������жϳ��ȣ��ԣ�  
      
    --������ͺܷ�����  
    select col from [tb] where dbo.RegexMatch('^.*?([a-z])[ ]\1.*?$',col)=0  
    /*  
    col  
    ----------  
    a b d c e  
    e u g h w  
    o a k d w  
    */  
      
    --2)�õ�ͬʱ����a��d������a��d֮����С�ڵ���һ����ĸ��  
      
    --����˼·  
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
    --������  
    select col from [tb] where dbo.RegexMatch('.*a[a-z ]{1,3}d.*',col)=1  
    /*  
    col  
    ----------  
    a b d c e  
    o a k d w  
    */  
    --���������д�����ǵľͲ�ȫ�����d��aǰ���أ�  
    --��ô����һ��  
    select col from [tb]   
    where dbo.RegexMatch('.*d[a-z ]{1,3}a.*|.*a[a-z ]{1,3}d.*',col)=1  
    /*  
    col  
    ----------  
    a b d c e  
    o a k d w  
    */  