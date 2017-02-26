// profile_diary�����
if exists(select * from sysobjects where type ="U" and name = "profile_diary")
   drop table profile_diary;

create table profile_diary
(
	no						char(7)			not null,						/*  */
	date					datetime			not null,						/* ���� */
	item					char(3)			not null,						/* ��Ŀ */
	ref					char(255)		null,								/* ��ע */
	tag					char(1)			default '' not null,			/* ��־ */
	cby					char(10)			not null,						/* �û� */
	changed				datetime			not null							/* ���� */
);
exec sp_primarykey profile_diary, no, date
create unique index index1 on profile_diary(no, date)
;
insert profile_diary select '2000337','2000/12/11', '100', '2000/12/11 -- 2000/12/15��ס���Ƶ�1608���䣬�ϼ�����1206.5Ԫ', '', 'HRY', '2000/12/15 11:34:23'
insert profile_diary select '2000337','2001/02/22', '100', '2001/02/22 -- 2001/02/23��ס���Ƶ�1709���䣬�ϼ�����435.8Ԫ', '', 'HRY', '2001/02/23 10:31:12'
insert profile_diary select '2000337','2002/01/20', '200', '���۲���Ң�绰�ݷ�', '', 'HRY', '2002/01/21 12:00:00'
insert profile_diary select '2000337','2002/09/16', '110', '�ͻ���绰��ѯ�����ڼ�ķ���, ���ܴ����м��ϸ�20%', '', 'HRY', '2002/09/16 12:00:00'
insert profile_diary select '2000337','2003/05/20', '100', '2003/05/20 -- 2003/05/22��ס���Ƶ�1709���䣬�ϼ�����688Ԫ', '', 'HRY', '2003/05/20 09:13:31'
;

