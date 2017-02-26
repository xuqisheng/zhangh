drop TABLE dbo.auth_runsta_detail ;
CREATE TABLE dbo.auth_runsta_detail 
(
    pc_id     char(4)     NOT NULL,						//机器pc_id
    act_date  datetime    NULL,							//运行程序时间
    run_date  datetime    NULL,							//登录系统时间
	 ext_date  datetime    NULL,							//退出或者挂起系统时间
    status    char(1)     NOT NULL,						// "R","H","S",运行,挂起,停机
    empno     char(10)    DEFAULT ''	 NOT NULL,	//工号
    name      char(20)    NULL,							//姓名
    appid     char(5)     DEFAULT ''	 NOT NULL,	// 应用编号 格式：appid 或appid+interface_group+interface_id
    funcid    char(30)    NULL,
    errtag    char(1)     DEFAULT "F"	 NOT NULL,	
    host_id   varchar(10) NULL,							//机器id	
    host_name varchar(30) NULL,							//机器名
	 db_name	  varchar(30) NULL,							//数据库名
    spid      int         NULL,							
    srvid     varchar(20) NULL,
    shift     char(1)     NULL							//班别
)
;
EXEC sp_primarykey 'dbo.auth_runsta_detail', pc_id,appid,host_name,run_date
;

CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.auth_runsta_detail(pc_id,appid,host_name,run_date,act_date)
;


drop TABLE dbo.auth_runsta_hdetail ;
CREATE TABLE dbo.auth_runsta_hdetail 
(
    pc_id     char(4)     NOT NULL,						//机器pc_id
    act_date  datetime    NULL,							//运行程序时间
    run_date  datetime    NULL,							//登录系统时间
	 ext_date  datetime    NULL,							//退出或者挂起系统时间
    status    char(1)     NOT NULL,						// "R","H","S",运行,挂起,停机
    empno     char(10)    DEFAULT ''	 NOT NULL,	//工号
    name      char(20)    NULL,							//姓名
    appid     char(5)     DEFAULT ''	 NOT NULL,	// 应用编号 格式：appid 或appid+interface_group+interface_id
    funcid    char(30)    NULL,
    errtag    char(1)     DEFAULT "F"	 NOT NULL,	
    host_id   varchar(10) NULL,							//机器id	
    host_name varchar(30) NULL,							//机器名
	 db_name	  varchar(30) NULL,							//数据库名
    spid      int         NULL,							
    srvid     varchar(20) NULL,
    shift     char(1)     NULL							//班别
)
;
EXEC sp_primarykey 'dbo.auth_runsta_hdetail', pc_id,appid,host_name,run_date
;

CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.auth_runsta_hdetail(pc_id,appid,host_name,run_date,act_date)
;


