/*
	查询窗口的打印(F9)语法
*/
if  exists(select * from sysobjects where name = "genput_f9" and type ="U")
	drop table genput_f9
;
create table genput_f9
(
	modu_id				char(2)			not null,						/*模块号*/
	window_name			char(50)			not null,						/*窗口名称*/
	window_option		char(15)			default '' not null,			/*选项*/
	window_title		char(50)			not null,						/*窗口标题*/
	remark				varchar(255)	null,								/*说明*/
	syntax_original	text,													/*原始genput语法*/
	syntax_custom		text,													/*自定义genput语法*/
	empno					char(10)			not null,						/*操作员*/
	date					datetime			default getdate()	not null	/*输入时间*/
)
exec sp_primarykey genput_f9, modu_id, window_name, window_option
create unique index index1 on genput_f9(modu_id, window_name, window_option)
;
