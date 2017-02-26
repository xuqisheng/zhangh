
-- Ԥ�����ÿ���ϸ 

-- ���ü�¼��� 
//insert basecode values ('accredit_tag', '0', 'Ԥ��', '', 'T', 'F', 10, '');
//insert basecode values ('accredit_tag', '5', '����', '', 'T', 'F', 20, '');
//insert basecode values ('accredit_tag', '9', '����', '', 'T', 'F', 30, '');

-- ���ü�¼ 
if exists(select * from sysobjects where type ="U" and name = "accredit")
	drop table accredit
;
create table accredit
(
	accnt			char(12)		not null,								-- �ʺ� 
	number		integer		default 1 not null,					-- ��� 
	pccode		char(5)		not null,								-- ���ÿ����� 
	cardno		char(20)		not null,								-- ���� ���� AR�ʻ� 
	expiry_date	datetime		not null,								-- ���ÿ���Ч�� 
	foliono		char(10)		default '' not null,					-- ˮ���� 
	creditno		char(10)		default '' not null,					-- ��Ȩ�� 
	quantity		money			default 0 not null,					-- ���-���
	amount		money			default 0 not null,					-- ���-Ԥ�� 
	amtuse		money			default 0 not null,					-- ���-ʹ�� 
	tag			char(1)		default '0' not null,				-- ״̬:0.δ�� 5.ȡ�� 9.ʹ�� = basecode(accredit_tag) 
	empno1		char(10)		not null,								-- �ռ����� 
	bdate1		datetime		not null,								-- �ռ�Ӫҵ���� 
	shift1		char(1)		not null,								-- �ռ���� 
	log_date1	datetime		default getdate() not null,		-- �ռ�ʱ�� 
	empno2		char(10)		null,										-- ʹ�ù��� 
	bdate2		datetime		null,										-- ʹ��Ӫҵ���� 
	shift2		char(1)		null,										-- ʹ�ð�� 
	log_date2	datetime		null,										-- ʹ��ʱ�� 
	partout		integer		default 1 not null,					-- ���ֽ���ת��ʱ�� 
	billno		char(10)		default '' not null,					-- ʹ�ø����ÿ����ʵ��� 
	cby			char(10)		default '' not null,
	changed		datetime		default getdate() not null,		
	logmark		int			default 0	not null,
	hotelid     char(10) NULL,
   sendout     char(1) NULL 
)
exec sp_primarykey accredit, accnt, number
create unique index index1 on accredit(accnt, number)
;

-- ���ü�¼ 
if exists(select * from sysobjects where type ="U" and name = "accredit_log")
	drop table accredit_log
;
create table accredit_log
(
	accnt			char(12)		not null,								-- �ʺ� 
	number		integer		default 1 not null,					-- ��� 
	pccode		char(5)		not null,								-- ���ÿ����� 
	cardno		char(20)		not null,								-- ���� ���� AR�ʻ� 
	expiry_date	datetime		not null,								-- ���ÿ���Ч�� 
	foliono		char(10)		default '' not null,					-- ˮ���� 
	creditno		char(10)		default '' not null,					-- ��Ȩ�� 
	quantity		money			default 0 not null,					-- ���-���
	amount		money			default 0 not null,					-- ���-Ԥ�� 
	amtuse		money			default 0 not null,					-- ���-ʹ�� 
	tag			char(1)		default '0' not null,				-- ״̬:0.δ�� 5.ȡ�� 9.ʹ�� = basecode(accredit_tag) 
	empno1		char(10)		not null,								-- �ռ����� 
	bdate1		datetime		not null,								-- �ռ�Ӫҵ���� 
	shift1		char(1)		not null,								-- �ռ���� 
	log_date1	datetime		default getdate() not null,		-- �ռ�ʱ�� 
	empno2		char(10)		null,										-- ʹ�ù��� 
	bdate2		datetime		null,										-- ʹ��Ӫҵ���� 
	shift2		char(1)		null,										-- ʹ�ð�� 
	log_date2	datetime		null,										-- ʹ��ʱ�� 
	partout		integer		default 1 not null,					-- ���ֽ���ת��ʱ�� 
	billno		char(10)		default '' not null,					-- ʹ�ø����ÿ����ʵ��� 
	cby			char(10)		default '' not null,
	changed		datetime		default getdate() not null,		
	logmark		int			default 0	not null,
	hotelid     char(10) NULL,
   sendout     char(1) NULL 
)
exec sp_primarykey accredit_log, accnt, number, logmark
create unique index index1 on accredit_log(accnt, number, logmark)
;

