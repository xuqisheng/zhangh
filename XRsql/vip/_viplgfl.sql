if exists(select * from sysobjects where type ="U" and name = "viplgfl")
   drop table viplgfl;
create table viplgfl
(
	no				char(20)		not null,							-- ����
	modu_id		char(2)		not null,							-- ģ���
	accnt			char(10)		default '' not null,				-- �˺�
	date			datetime		not null,							-- Ӫҵ����
	i_days		money			default 0 not null,				-- ������
	charge		money			default 0 not null,				-- ������
	credit		money			default 0 not null,				-- ��ֵ��
	credit_db	money			default 0 not null,				-- ʹ�ô�ֵ����Ľ��
	credit_m5	money			default 0 not null,				-- ʹ�÷ǻ��ַ�ʽ(��ENT,DSC,PTS��)����Ľ��,��Ӧvippoint.m5
	vippoint_c	money			default 0 not null,				-- �������֣���Ӧvippoint.credit
	vippoint_d	money			default 0 not null,				-- ʹ�û��֣���Ӧvippoint.charge
	type			char(1)		default 'R' not null				-- ʹ�ù�����ķ�ʽ : R.ס��,P.�ò�,B.��������,D.����
)
;
exec   sp_primarykey viplgfl, no, modu_id, accnt, date
create unique index index1 on viplgfl(no, modu_id, accnt, date)
;
