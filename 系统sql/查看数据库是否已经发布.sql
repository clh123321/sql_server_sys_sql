    USE master  
    go  
    SELECT  name ,  
            CASE is_published  
              WHEN 0 THEN 'δ����'  
              ELSE '�ѷ���'  
            END '�Ƿ񷢲�' ,  
            CASE is_subscribed  
              WHEN 0 THEN 'δ����'  
              ELSE '�Ѷ���'  
            END N'�Ƿ���'  
    FROM    sys.databases  

    WHERE   name = 'AdventureWorks2008R2'  