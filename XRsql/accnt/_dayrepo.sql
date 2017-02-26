/* �ͷ�Ӫҵ(�����)�ձ��� for HZDS */

if exists (select * from sysobjects where name ='dayrepo' and type ='U')
	drop table dayrepo;
create table dayrepo
(
	bdate			datetime	not null, 
	class			char(1)	not null, 
	pccode		char(5)	default '' not null, 
	servcode		char(1)	default '' not null, 
	descript		char(16)	default '' not null, 
	last			money		default 0 not null,			/* ����ֹ��Ƿ */
	ddeb			money		default 0 not null,			/* ���շ���Ӧ�� */
	ddis			money		default 0 not null,			/* ���շ����Ż� */
	dcre			money		default 0 not null,			/* �����ջ� */
	dlos			money		default 0 not null,			/* ���շ������� */
	till			money		default 0 not null			/* ����ֹ��Ƿ */
)
exec sp_primarykey dayrepo, bdate, class, pccode, servcode
create unique index index1 on dayrepo(bdate, class, pccode, servcode)
;

if exists (select * from sysobjects where name ='ydayrepo' and type ='U')
	drop table ydayrepo;
create table ydayrepo
(
	bdate			datetime	not null, 
	class			char(1)	not null, 
	pccode		char(5)	default '' not null, 
	servcode		char(1)	default '' not null, 
	descript		char(16)	default '' not null, 
	last			money		default 0 not null,			/* ����ֹ��Ƿ */
	ddeb			money		default 0 not null,			/* ���շ���Ӧ�� */
	ddis			money		default 0 not null,			/* ���շ����Ż� */
	dcre			money		default 0 not null,			/* �����ջ� */
	dlos			money		default 0 not null,			/* ���շ������� */
	till			money		default 0 not null			/* ����ֹ��Ƿ */
)
exec sp_primarykey ydayrepo, bdate, class, pccode, servcode
create unique index index1 on ydayrepo(bdate, class, pccode, servcode)
;
