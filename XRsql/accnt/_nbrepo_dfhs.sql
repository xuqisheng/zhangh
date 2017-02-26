/* ÿ��Ӧ�տ��ձ� */
-----------------------------------------------
--Ϊ�˶���������ʱͳ��packages����Ҫ����Ҫ��ʷ���� changed by wz

if exists(select * from sysobjects where name = "nbrepo")
	drop table nbrepo;

create table nbrepo(
	bdate			datetime		,
	deptno		char(3)		not null,					/* ��� */
	deptname		char(24)		null,							/* ������������� */
	pccode		char(5)		not null,					/*  */
	descript		char(24)    null,							/* �������� */
	f_in			money			default 0 	not null,	/* ǰ̨ */
	b_in  		money			default 0 	not null,	/* ��̨ */	/*¼��,����*/
	f_out			money			default 0 	not null,	/* ǰ̨ */
	b_out			money			default 0 	not null,	/* ��̨ */	/*�˿�,����*/
	f_tran      money			default 0 	not null,	/* ǰ̨ */
	b_tran      money			default 0 	not null,	/* ��̨ */	/*ת��,����*/
)
exec sp_primarykey nbrepo,bdate
create unique index index1 on nbrepo(bdate,pccode)
;