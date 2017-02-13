    USE master  
    go  
    SELECT  name ,  
            CASE is_published  
              WHEN 0 THEN '未发布'  
              ELSE '已发布'  
            END '是否发布' ,  
            CASE is_subscribed  
              WHEN 0 THEN '未订阅'  
              ELSE '已订阅'  
            END N'是否订阅'  
    FROM    sys.databases  

    WHERE   name = 'AdventureWorks2008R2'  