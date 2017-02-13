--数据库系统的登陆名 其中包含登陆名,所属服务器角色，和SID(创建时自动生成的id，用脚本创建时也可以指定ID)。
SELECT * FROM master.sys.server_principals

--下层各个数据库中，还需创建数据库的用户，并和“登陆名”进行映射。该关系存放在mydb.sys.database_principals，其中包括用户名,和SID。  而业务数据库mydb中，各个对象的权限情况（如表,存储过程,视图等）, 存放在mydb.sys.database_permissions
SELECT * FROM sys.database_principals
