/*
	��ѯ���ڵĴ�ӡ(F9)�﷨
*/
if  exists(select * from sysobjects where name = "genput_f9" and type ="U")
	drop table genput_f9
;
create table genput_f9
(
	modu_id				char(2)			not null,						/*ģ���*/
	window_name			char(50)			not null,						/*��������*/
	window_option		char(15)			default '' not null,			/*ѡ��*/
	window_title		char(50)			not null,						/*���ڱ���*/
	remark				varchar(255)	null,								/*˵��*/
	syntax_original	text,													/*ԭʼgenput�﷨*/
	syntax_custom		text,													/*�Զ���genput�﷨*/
	empno					char(10)			not null,						/*����Ա*/
	date					datetime			default getdate()	not null	/*����ʱ��*/
)
exec sp_primarykey genput_f9, modu_id, window_name, window_option
create unique index index1 on genput_f9(modu_id, window_name, window_option)
;
