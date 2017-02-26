/* ���ȯ������ϸ */

if exists(select * from sysobjects where name = "breakfast")
	drop table breakfast;

create table breakfast(
	date			datetime		not null,					/* Ӫҵ���� */
	posted		char(1)		default 'F'	not null,	/* ��־ */
	lf				money			default 0 	not null,	/* ����Ԥ��ɢ�� */
	lg		  		money			default 0 	not null,	/* ����Ԥ������ */
	lm		  		money			default 0 	not null,	/* ����Ԥ����� */
	ll				money			default 0 	not null,	/* ����Ԥ�᳤ס */
	cf				money			default 0 	not null,	/* ����ʵ��ɢ�� */
	cg		  		money			default 0 	not null,	/* ����ʵ������ */
	cm		  		money			default 0 	not null,	/* ����ʵ�ջ��� */
	cl				money			default 0 	not null,	/* ����ʵ�ճ�ס */
	tf				money			default 0 	not null,	/* ����Ԥ��ɢ�� */
	tg		  		money			default 0 	not null,	/* ����Ԥ������ */
	tm		  		money			default 0 	not null,	/* ����Ԥ����� */
	tl				money			default 0 	not null,	/* ����Ԥ�᳤ס */
)
exec sp_primarykey breakfast, date
create unique index index1 on breakfast(date)
;