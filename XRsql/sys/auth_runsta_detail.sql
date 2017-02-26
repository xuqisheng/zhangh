drop TABLE dbo.auth_runsta_detail ;
CREATE TABLE dbo.auth_runsta_detail 
(
    pc_id     char(4)     NOT NULL,						//����pc_id
    act_date  datetime    NULL,							//���г���ʱ��
    run_date  datetime    NULL,							//��¼ϵͳʱ��
	 ext_date  datetime    NULL,							//�˳����߹���ϵͳʱ��
    status    char(1)     NOT NULL,						// "R","H","S",����,����,ͣ��
    empno     char(10)    DEFAULT ''	 NOT NULL,	//����
    name      char(20)    NULL,							//����
    appid     char(5)     DEFAULT ''	 NOT NULL,	// Ӧ�ñ�� ��ʽ��appid ��appid+interface_group+interface_id
    funcid    char(30)    NULL,
    errtag    char(1)     DEFAULT "F"	 NOT NULL,	
    host_id   varchar(10) NULL,							//����id	
    host_name varchar(30) NULL,							//������
	 db_name	  varchar(30) NULL,							//���ݿ���
    spid      int         NULL,							
    srvid     varchar(20) NULL,
    shift     char(1)     NULL							//���
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
    pc_id     char(4)     NOT NULL,						//����pc_id
    act_date  datetime    NULL,							//���г���ʱ��
    run_date  datetime    NULL,							//��¼ϵͳʱ��
	 ext_date  datetime    NULL,							//�˳����߹���ϵͳʱ��
    status    char(1)     NOT NULL,						// "R","H","S",����,����,ͣ��
    empno     char(10)    DEFAULT ''	 NOT NULL,	//����
    name      char(20)    NULL,							//����
    appid     char(5)     DEFAULT ''	 NOT NULL,	// Ӧ�ñ�� ��ʽ��appid ��appid+interface_group+interface_id
    funcid    char(30)    NULL,
    errtag    char(1)     DEFAULT "F"	 NOT NULL,	
    host_id   varchar(10) NULL,							//����id	
    host_name varchar(30) NULL,							//������
	 db_name	  varchar(30) NULL,							//���ݿ���
    spid      int         NULL,							
    srvid     varchar(20) NULL,
    shift     char(1)     NULL							//���
)
;
EXEC sp_primarykey 'dbo.auth_runsta_hdetail', pc_id,appid,host_name,run_date
;

CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.auth_runsta_hdetail(pc_id,appid,host_name,run_date,act_date)
;


