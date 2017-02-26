// 用户安全控制表
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
//用户安全控制系统参数
if not exists(select * from sysoption where catalog = "hotel" and item = "usersecurity" ) 
	insert into sysoption(catalog,item,value,def,remark,remark1,addby,addtime,usermod,lic) 
		select 'hotel','usersecurity','T,3,0,0,T,0','T,3,0,0,T,0',
		'用户安全控制系统参数(T|F),可以为空,最小长度(0|n),复杂度(0|1),有效期(0,n),是否必须修改(T|F),重试次数(0|n)','','zhj','2009-4-21 15:34:00','T',''
;

