// �û���ȫ���Ʊ�
if exists(select * from sysobjects where name = "sys_empno_ctrl")
	drop table sys_empno_ctrl
;
create table sys_empno_ctrl 
(
    empno    		char(10)  not null,
    pwddate 		datetime  null,
	 pwdcby      	char(10)  null,
    trylocked   	char(1)   null, 
	 trydate	   	datetime  null 
)
;
exec sp_primarykey 'sys_empno_ctrl', empno
;
create unique nonclustered index index1 on sys_empno_ctrl(empno)
;
//�û���ȫ����ϵͳ����
if not exists(select * from sysoption where catalog = "hotel" and item = "usersecurity" ) 
	insert into sysoption(catalog,item,value,def,remark,remark1,addby,addtime,usermod,lic) 
		select 'hotel','usersecurity','T,3,0,0,T,0','T,3,0,0,T,0',
		'�û���ȫ����ϵͳ����(T|F),����Ϊ��,��С����(0|n),���Ӷ�(0|1),��Ч��(0,n),�Ƿ�����޸�(T|F),���Դ���(0|n)','','zhj','2009-4-21 15:34:00','T',''
;

