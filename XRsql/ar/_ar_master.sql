exec sp_rename ar_master, ar_master_old;
exec sp_rename ar_master_last, ar_master_last_old;
exec sp_rename ar_master_log, ar_master_log_old;
exec sp_rename ar_master_till, ar_master_till_old;
exec sp_rename har_master, har_master_old;

if exists(select * from sysobjects where name = "ar_master" and type="U")
	drop table ar_master;
create table ar_master
(
	accnt			char(10)			not null,						/* �ʺ�:����(�����ɼ�˵����)  */
	haccnt		char(7)			default '' 	not null,		/* ���͵�����  */
	bdate			datetime			not null,						/* ��ס�����Ӫҵ����=business date */
	sta			char(1)			not null,						/* �ʺ�״̬(��˵����˵����) */
	osta			char(1)			default ''	not null,		/* ����ǰ���ʺ�״̬ */
	ressta		char(1)			default ''	not null,		/* ����ʱ�����״̬,�����������ʲ��ָ���ԭ״̬ */
	sta_tm		char(1)			default '' 	not null,		/* �ʺ�״̬(������) */
	arr			datetime			not null,						/* ��������=arrival */
	dep			datetime			not null,						/* �������=departure */
	resdep		datetime			null,								/* ����ʱ������뿪����,������������ */
	oarr			datetime			null,
	odep			datetime			null,

	rmposted		char(1)			default 'F' 	not null,	/* ����ס�����Ƿ��������, ��master.rmposted��ͬ
																				��ǰ��¥�Ÿĵ�extra�ĵڶ�λ */
	class			char(1)			default '' 	not null,		/* ��� */
	rmpoststa	char(1)			default '' 	not null,		/* �����ֶ�:������ʱ�� */									---
	artag1		char(5)			default '' 	not null,		/* ��� */
	artag2		char(5)			default '' 	not null,		/* �ȼ� */
	address1	   varchar(60)		default ''		not null,	/* סַ */
	address2	   varchar(60)		default ''		not null,	/* סַ */
	address3	   varchar(60)		default ''		not null,	/* סַ */
	address4	   varchar(60)		default ''		not null,	/* סַ */

	paycode		char(6)			default ''	not null,		/* ���㷽ʽ */
	cycle			char(5)			default '' 	not null,		/* �������ڴ��� */
	limit			money				default 0 	not null,		/* �޶�(������) */
	credcode		varchar(20)		default ''	not null,		/* ���ÿ����� */
	credman		varchar(20)		null,
	credunit		varchar(40)		null,
	applname		varchar(30)		null,								/* ������/ί���� */
	applicant	varchar(60)		default ''	not null,		/* ��λ/ί�е�λ */
	phone			varchar(16) 	null,								/* ��ϵ�绰�� */
	fax			varchar(16) 	null,								/* fax */
	email			varchar(30)		null,								/* email */

	extra			char(30)			default ''	not null,		/* ������Ϣ: 1-�����˻� 2-¥�� 3-AR Status 4-���� 5-���ܷ��� 
																				6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money				default 0		not null,
	credit 		money				default 0		not null,
	charge0		money				default 0		not null,
	credit0 		money				default 0		not null,
	accredit		money				default 0		not null,	/* ���� */
	disputed		money				default 0		not null,	/* ������ */
	invoice		money				default 0 not null,			/* �ѿ���Ʊ�Ľ�� */

	lastnumb		integer			default 0		not null,	/* account��number������ */
	lastinumb	integer			default 0		not null,	/* account��inumber������ */

	srqs			varchar(30)		default ''	not null,		/* ����Ҫ�� */
	master		char(10)			default ''	not null, 		/* ���� */
	pcrec			char(10)			default ''	not null, 		/* ���� */
	pcrec_pkg	char(10)			default ''	not null, 		/* ���� */
	ref			varchar(255)	default ''	null, 			/* comment */
	saleid		varchar(10)		default ''	not null,		/* ����Ա */

	resby			char(10)			default ''	not null,		/* Ԥ��Ա��Ϣ */
	restime		datetime			null,			
	depby			char(10)			default ''	not null,		/* �˷�Ա��Ϣ */
	deptime		datetime			null,			
	cby			char(10)			not null,						/* �����޸�����Ϣ */
	changed		datetime			not null,
-- 
	chargeby			char(10)			default ''	not null,	/* ���һ��������Ϣ */
	chargetime		datetime			null,
	creditby			char(10)			default ''	not null,	/* ���һ�θ�����Ϣ */
	credittime		datetime			null,
	invoiceby		char(10)			default ''	not null,	/* ���һ�ν��㿪Ʊ��Ϣ */
	invoicetime		datetime			null,
	statementby		char(10)			default ''	not null,	/* ���һ�ζ��˵���Ϣ */
	statementtime	datetime			null,
	reminderby		char(10)			default ''	not null,	/* ���һ�δ��˵���Ϣ */
	remindertime	datetime			null,
	remindertext	varchar(30)		default ''	not null,
-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,

	logmark		integer			default 0 			not null
)
exec sp_primarykey ar_master,accnt
create unique index  ar_master on ar_master(accnt)
;
//insert ar_master
//	select accnt, haccnt, bdate, sta, osta, ressta, sta_tm, arr, dep, resdep, oarr, odep,
//	hall = 'A', class, tag0, artag1, artag2, address1='', address2='', address3='', address4='', paycode, cycle = '', limit,
//	credcode, credman, credunit, applname, applicant, phone, fax, email, extra,
//	charge, credit, charge0 = 0, credit0 = 0, accredit, disputed = 0, invoice = 0,
//	lastnumb, lastinumb, srqs, master, pcrec, pcrec_pkg, ref, saleid,
//	resby, restime, depby, deptime, cby, changed,
//	chargeby = '', chargetime = null, creditby = '', credittime = null, invoiceby = '', invoicetime = null, statementby = '', statementtime = null,
//	exp_m1, exp_m2, exp_dt1, exp_dt2, exp_s1, exp_s2, exp_s3, logmark
//	from master where class = 'A';

if exists(select * from sysobjects where name = "har_master" and type="U")
	drop table har_master;
create table har_master
(
	accnt			char(10)			not null,						/* �ʺ�:����(�����ɼ�˵����)  */
	haccnt		char(7)			default '' 	not null,		/* ���͵�����  */
	bdate			datetime			not null,						/* ��ס�����Ӫҵ����=business date */
	sta			char(1)			not null,						/* �ʺ�״̬(��˵����˵����) */
	osta			char(1)			default ''	not null,		/* ����ǰ���ʺ�״̬ */
	ressta		char(1)			default ''	not null,		/* ����ʱ�����״̬,�����������ʲ��ָ���ԭ״̬ */
	sta_tm		char(1)			default '' 	not null,		/* �ʺ�״̬(������) */
	arr			datetime			not null,						/* ��������=arrival */
	dep			datetime			not null,						/* �������=departure */
	resdep		datetime			null,								/* ����ʱ������뿪����,������������ */
	oarr			datetime			null,
	odep			datetime			null,

	rmposted		char(1)			default 'F' 	not null,	/* ����ס�����Ƿ��������, ��master.rmposted��ͬ
																				��ǰ��¥�Ÿĵ�extra�ĵڶ�λ */
	class			char(1)			default '' 	not null,		/* ��� */
	rmpoststa	char(1)			default '' 	not null,		/* �����ֶ�:������ʱ�� */									---
	artag1		char(5)			default '' 	not null,		/* ��� */
	artag2		char(5)			default '' 	not null,		/* �ȼ� */
	address1	   varchar(60)		default ''		not null,	/* סַ */
	address2	   varchar(60)		default ''		not null,	/* סַ */
	address3	   varchar(60)		default ''		not null,	/* סַ */
	address4	   varchar(60)		default ''		not null,	/* סַ */

	paycode		char(6)			default ''	not null,		/* ���㷽ʽ */
	cycle			char(5)			default '' 	not null,		/* �������ڴ��� */
	limit			money				default 0 	not null,		/* �޶�(������) */
	credcode		varchar(20)		default ''	not null,		/* ���ÿ����� */
	credman		varchar(20)		null,
	credunit		varchar(40)		null,
	applname		varchar(30)		null,								/* ������/ί���� */
	applicant	varchar(60)		default ''	not null,		/* ��λ/ί�е�λ */
	phone			varchar(16) 	null,								/* ��ϵ�绰�� */
	fax			varchar(16) 	null,								/* fax */
	email			varchar(30)		null,								/* email */

	extra			char(30)			default ''	not null,		/* ������Ϣ: 1-�����˻� 2-¥�� 3-AR Status 4-���� 5-���ܷ��� 
																				6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money				default 0		not null,
	credit 		money				default 0		not null,
	charge0		money				default 0		not null,
	credit0 		money				default 0		not null,
	accredit		money				default 0		not null,	/* ���� */
	disputed		money				default 0		not null,	/* ������ */
	invoice		money				default 0 not null,			/* �ѿ���Ʊ�Ľ�� */

	lastnumb		integer			default 0		not null,	/* account��number������ */
	lastinumb	integer			default 0		not null,	/* account��inumber������ */

	srqs			varchar(30)		default ''	not null,		/* ����Ҫ�� */
	master		char(10)			default ''	not null, 		/* ���� */
	pcrec			char(10)			default ''	not null, 		/* ���� */
	pcrec_pkg	char(10)			default ''	not null, 		/* ���� */
	ref			varchar(255)	default ''	null, 			/* comment */
	saleid		varchar(10)		default ''	not null,		/* ����Ա */

	resby			char(10)			default ''	not null,		/* Ԥ��Ա��Ϣ */
	restime		datetime			null,			
	depby			char(10)			default ''	not null,		/* �˷�Ա��Ϣ */
	deptime		datetime			null,			
	cby			char(10)			not null,						/* �����޸�����Ϣ */
	changed		datetime			not null,
-- 
	chargeby			char(10)			default ''	not null,	/* ���һ��������Ϣ */
	chargetime		datetime			null,
	creditby			char(10)			default ''	not null,	/* ���һ�θ�����Ϣ */
	credittime		datetime			null,
	invoiceby		char(10)			default ''	not null,	/* ���һ�ν��㿪Ʊ��Ϣ */
	invoicetime		datetime			null,
	statementby		char(10)			default ''	not null,	/* ���һ�ζ��˵���Ϣ */
	statementtime	datetime			null,
	reminderby		char(10)			default ''	not null,	/* ���һ�δ��˵���Ϣ */
	remindertime	datetime			null,
	remindertext	varchar(30)		default ''	not null,
-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,

	logmark		integer			default 0 			not null
)
exec sp_primarykey har_master,accnt
create unique index  har_master on har_master(accnt)
;

if exists(select * from sysobjects where name = "ar_master_till" and type="U")
	drop table ar_master_till;
create table ar_master_till
(
	accnt			char(10)			not null,						/* �ʺ�:����(�����ɼ�˵����)  */
	haccnt		char(7)			default '' 	not null,		/* ���͵�����  */
	bdate			datetime			not null,						/* ��ס�����Ӫҵ����=business date */
	sta			char(1)			not null,						/* �ʺ�״̬(��˵����˵����) */
	osta			char(1)			default ''	not null,		/* ����ǰ���ʺ�״̬ */
	ressta		char(1)			default ''	not null,		/* ����ʱ�����״̬,�����������ʲ��ָ���ԭ״̬ */
	sta_tm		char(1)			default '' 	not null,		/* �ʺ�״̬(������) */
	arr			datetime			not null,						/* ��������=arrival */
	dep			datetime			not null,						/* �������=departure */
	resdep		datetime			null,								/* ����ʱ������뿪����,������������ */
	oarr			datetime			null,
	odep			datetime			null,

	rmposted		char(1)			default 'F' 	not null,	/* ����ס�����Ƿ��������, ��master.rmposted��ͬ
																				��ǰ��¥�Ÿĵ�extra�ĵڶ�λ */
	class			char(1)			default '' 	not null,		/* ��� */
	rmpoststa	char(1)			default '' 	not null,		/* �����ֶ�:������ʱ�� */									---
	artag1		char(5)			default '' 	not null,		/* ��� */
	artag2		char(5)			default '' 	not null,		/* �ȼ� */
	address1	   varchar(60)		default ''		not null,	/* סַ */
	address2	   varchar(60)		default ''		not null,	/* סַ */
	address3	   varchar(60)		default ''		not null,	/* סַ */
	address4	   varchar(60)		default ''		not null,	/* סַ */

	paycode		char(6)			default ''	not null,		/* ���㷽ʽ */
	cycle			char(5)			default '' 	not null,		/* �������ڴ��� */
	limit			money				default 0 	not null,		/* �޶�(������) */
	credcode		varchar(20)		default ''	not null,		/* ���ÿ����� */
	credman		varchar(20)		null,
	credunit		varchar(40)		null,
	applname		varchar(30)		null,								/* ������/ί���� */
	applicant	varchar(60)		default ''	not null,		/* ��λ/ί�е�λ */
	phone			varchar(16) 	null,								/* ��ϵ�绰�� */
	fax			varchar(16) 	null,								/* fax */
	email			varchar(30)		null,								/* email */

	extra			char(30)			default ''	not null,		/* ������Ϣ: 1-�����˻� 2-¥�� 3-AR Status 4-���� 5-���ܷ��� 
																				6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money				default 0		not null,
	credit 		money				default 0		not null,
	charge0		money				default 0		not null,
	credit0 		money				default 0		not null,
	accredit		money				default 0		not null,	/* ���� */
	disputed		money				default 0		not null,	/* ������ */
	invoice		money				default 0 not null,			/* �ѿ���Ʊ�Ľ�� */

	lastnumb		integer			default 0		not null,	/* account��number������ */
	lastinumb	integer			default 0		not null,	/* account��inumber������ */

	srqs			varchar(30)		default ''	not null,		/* ����Ҫ�� */
	master		char(10)			default ''	not null, 		/* ���� */
	pcrec			char(10)			default ''	not null, 		/* ���� */
	pcrec_pkg	char(10)			default ''	not null, 		/* ���� */
	ref			varchar(255)	default ''	null, 			/* comment */
	saleid		varchar(10)		default ''	not null,		/* ����Ա */

	resby			char(10)			default ''	not null,		/* Ԥ��Ա��Ϣ */
	restime		datetime			null,			
	depby			char(10)			default ''	not null,		/* �˷�Ա��Ϣ */
	deptime		datetime			null,			
	cby			char(10)			not null,						/* �����޸�����Ϣ */
	changed		datetime			not null,
-- 
	chargeby			char(10)			default ''	not null,	/* ���һ��������Ϣ */
	chargetime		datetime			null,
	creditby			char(10)			default ''	not null,	/* ���һ�θ�����Ϣ */
	credittime		datetime			null,
	invoiceby		char(10)			default ''	not null,	/* ���һ�ν��㿪Ʊ��Ϣ */
	invoicetime		datetime			null,
	statementby		char(10)			default ''	not null,	/* ���һ�ζ��˵���Ϣ */
	statementtime	datetime			null,
	reminderby		char(10)			default ''	not null,	/* ���һ�δ��˵���Ϣ */
	remindertime	datetime			null,
	remindertext	varchar(30)		default ''	not null,
-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,

	logmark		integer			default 0 			not null
)
exec sp_primarykey ar_master_till,accnt
create unique index  ar_master_till on ar_master_till(accnt)
;

if exists(select * from sysobjects where name = "ar_master_last" and type="U")
	drop table ar_master_last;
create table ar_master_last
(
	accnt			char(10)			not null,						/* �ʺ�:����(�����ɼ�˵����)  */
	haccnt		char(7)			default '' 	not null,		/* ���͵�����  */
	bdate			datetime			not null,						/* ��ס�����Ӫҵ����=business date */
	sta			char(1)			not null,						/* �ʺ�״̬(��˵����˵����) */
	osta			char(1)			default ''	not null,		/* ����ǰ���ʺ�״̬ */
	ressta		char(1)			default ''	not null,		/* ����ʱ�����״̬,�����������ʲ��ָ���ԭ״̬ */
	sta_tm		char(1)			default '' 	not null,		/* �ʺ�״̬(������) */
	arr			datetime			not null,						/* ��������=arrival */
	dep			datetime			not null,						/* �������=departure */
	resdep		datetime			null,								/* ����ʱ������뿪����,������������ */
	oarr			datetime			null,
	odep			datetime			null,

	rmposted		char(1)			default 'F' 	not null,	/* ����ס�����Ƿ��������, ��master.rmposted��ͬ
																				��ǰ��¥�Ÿĵ�extra�ĵڶ�λ */
	class			char(1)			default '' 	not null,		/* ��� */
	rmpoststa	char(1)			default '' 	not null,		/* �����ֶ�:������ʱ�� */									---
	artag1		char(5)			default '' 	not null,		/* ��� */
	artag2		char(5)			default '' 	not null,		/* �ȼ� */
	address1	   varchar(60)		default ''		not null,	/* סַ */
	address2	   varchar(60)		default ''		not null,	/* סַ */
	address3	   varchar(60)		default ''		not null,	/* סַ */
	address4	   varchar(60)		default ''		not null,	/* סַ */

	paycode		char(6)			default ''	not null,		/* ���㷽ʽ */
	cycle			char(5)			default '' 	not null,		/* �������ڴ��� */
	limit			money				default 0 	not null,		/* �޶�(������) */
	credcode		varchar(20)		default ''	not null,		/* ���ÿ����� */
	credman		varchar(20)		null,
	credunit		varchar(40)		null,
	applname		varchar(30)		null,								/* ������/ί���� */
	applicant	varchar(60)		default ''	not null,		/* ��λ/ί�е�λ */
	phone			varchar(16) 	null,								/* ��ϵ�绰�� */
	fax			varchar(16) 	null,								/* fax */
	email			varchar(30)		null,								/* email */

	extra			char(30)			default ''	not null,		/* ������Ϣ: 1-�����˻� 2-¥�� 3-AR Status 4-���� 5-���ܷ��� 
																				6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money				default 0		not null,
	credit 		money				default 0		not null,
	charge0		money				default 0		not null,
	credit0 		money				default 0		not null,
	accredit		money				default 0		not null,	/* ���� */
	disputed		money				default 0		not null,	/* ������ */
	invoice		money				default 0 not null,			/* �ѿ���Ʊ�Ľ�� */

	lastnumb		integer			default 0		not null,	/* account��number������ */
	lastinumb	integer			default 0		not null,	/* account��inumber������ */

	srqs			varchar(30)		default ''	not null,		/* ����Ҫ�� */
	master		char(10)			default ''	not null, 		/* ���� */
	pcrec			char(10)			default ''	not null, 		/* ���� */
	pcrec_pkg	char(10)			default ''	not null, 		/* ���� */
	ref			varchar(255)	default ''	null, 			/* comment */
	saleid		varchar(10)		default ''	not null,		/* ����Ա */

	resby			char(10)			default ''	not null,		/* Ԥ��Ա��Ϣ */
	restime		datetime			null,			
	depby			char(10)			default ''	not null,		/* �˷�Ա��Ϣ */
	deptime		datetime			null,			
	cby			char(10)			not null,						/* �����޸�����Ϣ */
	changed		datetime			not null,
-- 
	chargeby			char(10)			default ''	not null,	/* ���һ��������Ϣ */
	chargetime		datetime			null,
	creditby			char(10)			default ''	not null,	/* ���һ�θ�����Ϣ */
	credittime		datetime			null,
	invoiceby		char(10)			default ''	not null,	/* ���һ�ν��㿪Ʊ��Ϣ */
	invoicetime		datetime			null,
	statementby		char(10)			default ''	not null,	/* ���һ�ζ��˵���Ϣ */
	statementtime	datetime			null,
	reminderby		char(10)			default ''	not null,	/* ���һ�δ��˵���Ϣ */
	remindertime	datetime			null,
	remindertext	varchar(30)		default ''	not null,
-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,

	logmark		integer			default 0 			not null
)
exec sp_primarykey ar_master_last,accnt
create unique index  ar_master_last on ar_master_last(accnt)
;

if exists(select * from sysobjects where name = "ar_master_log" and type="U")
	drop table ar_master_log;
create table ar_master_log
(
	accnt			char(10)			not null,						/* �ʺ�:����(�����ɼ�˵����)  */
	haccnt		char(7)			default '' 	not null,		/* ���͵�����  */
	bdate			datetime			not null,						/* ��ס�����Ӫҵ����=business date */
	sta			char(1)			not null,						/* �ʺ�״̬(��˵����˵����) */
	osta			char(1)			default ''	not null,		/* ����ǰ���ʺ�״̬ */
	ressta		char(1)			default ''	not null,		/* ����ʱ�����״̬,�����������ʲ��ָ���ԭ״̬ */
	sta_tm		char(1)			default '' 	not null,		/* �ʺ�״̬(������) */
	arr			datetime			not null,						/* ��������=arrival */
	dep			datetime			not null,						/* �������=departure */
	resdep		datetime			null,								/* ����ʱ������뿪����,������������ */
	oarr			datetime			null,
	odep			datetime			null,

	rmposted		char(1)			default 'F' 	not null,	/* ����ס�����Ƿ��������, ��master.rmposted��ͬ
																				��ǰ��¥�Ÿĵ�extra�ĵڶ�λ */
	class			char(1)			default '' 	not null,		/* ��� */
	rmpoststa	char(1)			default '' 	not null,		/* �����ֶ�:������ʱ�� */									---
	artag1		char(5)			default '' 	not null,		/* ��� */
	artag2		char(5)			default '' 	not null,		/* �ȼ� */
	address1	   varchar(60)		default ''		not null,	/* סַ */
	address2	   varchar(60)		default ''		not null,	/* סַ */
	address3	   varchar(60)		default ''		not null,	/* סַ */
	address4	   varchar(60)		default ''		not null,	/* סַ */

	paycode		char(6)			default ''	not null,		/* ���㷽ʽ */
	cycle			char(5)			default '' 	not null,		/* �������ڴ��� */
	limit			money				default 0 	not null,		/* �޶�(������) */
	credcode		varchar(20)		default ''	not null,		/* ���ÿ����� */
	credman		varchar(20)		null,
	credunit		varchar(40)		null,
	applname		varchar(30)		null,								/* ������/ί���� */
	applicant	varchar(60)		default ''	not null,		/* ��λ/ί�е�λ */
	phone			varchar(16) 	null,								/* ��ϵ�绰�� */
	fax			varchar(16) 	null,								/* fax */
	email			varchar(30)		null,								/* email */

	extra			char(30)			default ''	not null,		/* ������Ϣ: 1-�����˻� 2-¥�� 3-AR Status 4-���� 5-���ܷ��� 
																				6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money				default 0		not null,
	credit 		money				default 0		not null,
	charge0		money				default 0		not null,
	credit0 		money				default 0		not null,
	accredit		money				default 0		not null,	/* ���� */
	disputed		money				default 0		not null,	/* ������ */
	invoice		money				default 0 not null,			/* �ѿ���Ʊ�Ľ�� */

	lastnumb		integer			default 0		not null,	/* account��number������ */
	lastinumb	integer			default 0		not null,	/* account��inumber������ */

	srqs			varchar(30)		default ''	not null,		/* ����Ҫ�� */
	master		char(10)			default ''	not null, 		/* ���� */
	pcrec			char(10)			default ''	not null, 		/* ���� */
	pcrec_pkg	char(10)			default ''	not null, 		/* ���� */
	ref			varchar(255)	default ''	null, 			/* comment */
	saleid		varchar(10)		default ''	not null,		/* ����Ա */

	resby			char(10)			default ''	not null,		/* Ԥ��Ա��Ϣ */
	restime		datetime			null,			
	depby			char(10)			default ''	not null,		/* �˷�Ա��Ϣ */
	deptime		datetime			null,			
	cby			char(10)			not null,						/* �����޸�����Ϣ */
	changed		datetime			not null,
-- 
	chargeby			char(10)			default ''	not null,	/* ���һ��������Ϣ */
	chargetime		datetime			null,
	creditby			char(10)			default ''	not null,	/* ���һ�θ�����Ϣ */
	credittime		datetime			null,
	invoiceby		char(10)			default ''	not null,	/* ���һ�ν��㿪Ʊ��Ϣ */
	invoicetime		datetime			null,
	statementby		char(10)			default ''	not null,	/* ���һ�ζ��˵���Ϣ */
	statementtime	datetime			null,
	reminderby		char(10)			default ''	not null,	/* ���һ�δ��˵���Ϣ */
	remindertime	datetime			null,
	remindertext	varchar(30)		default ''	not null,
-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,

	logmark		integer			default 0 			not null
)
exec sp_primarykey ar_master_log,accnt,logmark
create unique index  ar_master_log on ar_master_log(accnt,logmark)
;

if exists(select * from sysobjects where name = "ar_master_del" and type="U")
	drop table ar_master_del;
create table ar_master_del
(
	accnt			char(10)			not null,						/* �ʺ�:����(�����ɼ�˵����)  */
	haccnt		char(7)			default '' 	not null,		/* ���͵�����  */
	bdate			datetime			not null,						/* ��ס�����Ӫҵ����=business date */
	sta			char(1)			not null,						/* �ʺ�״̬(��˵����˵����) */
	osta			char(1)			default ''	not null,		/* ����ǰ���ʺ�״̬ */
	ressta		char(1)			default ''	not null,		/* ����ʱ�����״̬,�����������ʲ��ָ���ԭ״̬ */
	sta_tm		char(1)			default '' 	not null,		/* �ʺ�״̬(������) */
	arr			datetime			not null,						/* ��������=arrival */
	dep			datetime			not null,						/* �������=departure */
	resdep		datetime			null,								/* ����ʱ������뿪����,������������ */
	oarr			datetime			null,
	odep			datetime			null,

	rmposted		char(1)			default 'F' 	not null,	/* ����ס�����Ƿ��������, ��master.rmposted��ͬ
																				��ǰ��¥�Ÿĵ�extra�ĵڶ�λ */
	class			char(1)			default '' 	not null,		/* ��� */
	rmpoststa	char(1)			default '' 	not null,		/* �����ֶ�:������ʱ�� */									---
	artag1		char(5)			default '' 	not null,		/* ��� */
	artag2		char(5)			default '' 	not null,		/* �ȼ� */
	address1	   varchar(60)		default ''		not null,	/* סַ */
	address2	   varchar(60)		default ''		not null,	/* סַ */
	address3	   varchar(60)		default ''		not null,	/* סַ */
	address4	   varchar(60)		default ''		not null,	/* סַ */

	paycode		char(6)			default ''	not null,		/* ���㷽ʽ */
	cycle			char(5)			default '' 	not null,		/* �������ڴ��� */
	limit			money				default 0 	not null,		/* �޶�(������) */
	credcode		varchar(20)		default ''	not null,		/* ���ÿ����� */
	credman		varchar(20)		null,
	credunit		varchar(40)		null,
	applname		varchar(30)		null,								/* ������/ί���� */
	applicant	varchar(60)		default ''	not null,		/* ��λ/ί�е�λ */
	phone			varchar(16) 	null,								/* ��ϵ�绰�� */
	fax			varchar(16) 	null,								/* fax */
	email			varchar(30)		null,								/* email */

	extra			char(30)			default ''	not null,		/* ������Ϣ: 1-�����˻� 2-¥�� 3-AR Status 4-���� 5-���ܷ��� 
																				6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money				default 0		not null,
	credit 		money				default 0		not null,
	charge0		money				default 0		not null,
	credit0 		money				default 0		not null,
	accredit		money				default 0		not null,	/* ���� */
	disputed		money				default 0		not null,	/* ������ */
	invoice		money				default 0 not null,			/* �ѿ���Ʊ�Ľ�� */

	lastnumb		integer			default 0		not null,	/* account��number������ */
	lastinumb	integer			default 0		not null,	/* account��inumber������ */

	srqs			varchar(30)		default ''	not null,		/* ����Ҫ�� */
	master		char(10)			default ''	not null, 		/* ���� */
	pcrec			char(10)			default ''	not null, 		/* ���� */
	pcrec_pkg	char(10)			default ''	not null, 		/* ���� */
	ref			varchar(255)	default ''	null, 			/* comment */
	saleid		varchar(10)		default ''	not null,		/* ����Ա */

	resby			char(10)			default ''	not null,		/* Ԥ��Ա��Ϣ */
	restime		datetime			null,			
	depby			char(10)			default ''	not null,		/* �˷�Ա��Ϣ */
	deptime		datetime			null,			
	cby			char(10)			not null,						/* �����޸�����Ϣ */
	changed		datetime			not null,
-- 
	chargeby			char(10)			default ''	not null,	/* ���һ��������Ϣ */
	chargetime		datetime			null,
	creditby			char(10)			default ''	not null,	/* ���һ�θ�����Ϣ */
	credittime		datetime			null,
	invoiceby		char(10)			default ''	not null,	/* ���һ�ν��㿪Ʊ��Ϣ */
	invoicetime		datetime			null,
	statementby		char(10)			default ''	not null,	/* ���һ�ζ��˵���Ϣ */
	statementtime	datetime			null,
	reminderby		char(10)			default ''	not null,	/* ���һ�δ��˵���Ϣ */
	remindertime	datetime			null,
	remindertext	varchar(30)		default ''	not null,
-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,

	logmark		integer			default 0 			not null
)
exec sp_primarykey ar_master_del,accnt
create unique index  ar_master_del on ar_master_del(accnt)
;



insert ar_master
	select accnt, haccnt, bdate, sta, osta, ressta, sta_tm, arr, dep, resdep, oarr, odep,
	rmposted = 'F', class, rmpoststa = '0', artag1, artag2, address1, address2, address3, address4, paycode, cycle, limit,
	credcode, credman, credunit, applname, applicant, phone, fax, email, extra,
	charge, credit, charge0, credit0, accredit, disputed, invoice,
	lastnumb, lastinumb, srqs, master, pcrec, pcrec_pkg, ref, saleid,
	resby, restime, depby, deptime, cby, changed,
	chargeby, chargetime, creditby, credittime, invoiceby, invoicetime, statementby, statementtime, '', null, '',
	exp_m1, exp_m2, exp_dt1, exp_dt2, exp_s1, exp_s2, exp_s3, logmark
	from ar_master_old;
insert har_master
	select accnt, haccnt, bdate, sta, osta, ressta, sta_tm, arr, dep, resdep, oarr, odep,
	rmposted = 'F', class, rmpoststa = '0', artag1, artag2, address1, address2, address3, address4, paycode, cycle, limit,
	credcode, credman, credunit, applname, applicant, phone, fax, email, extra,
	charge, credit, charge0, credit0, accredit, disputed, invoice,
	lastnumb, lastinumb, srqs, master, pcrec, pcrec_pkg, ref, saleid,
	resby, restime, depby, deptime, cby, changed,
	chargeby, chargetime, creditby, credittime, invoiceby, invoicetime, statementby, statementtime, '', null, '',
	exp_m1, exp_m2, exp_dt1, exp_dt2, exp_s1, exp_s2, exp_s3, logmark
	from har_master_old;
insert ar_master_last
	select accnt, haccnt, bdate, sta, osta, ressta, sta_tm, arr, dep, resdep, oarr, odep,
	rmposted = 'F', class, rmpoststa = '0', artag1, artag2, address1, address2, address3, address4, paycode, cycle, limit,
	credcode, credman, credunit, applname, applicant, phone, fax, email, extra,
	charge, credit, charge0, credit0, accredit, disputed, invoice,
	lastnumb, lastinumb, srqs, master, pcrec, pcrec_pkg, ref, saleid,
	resby, restime, depby, deptime, cby, changed,
	chargeby, chargetime, creditby, credittime, invoiceby, invoicetime, statementby, statementtime, '', null, '',
	exp_m1, exp_m2, exp_dt1, exp_dt2, exp_s1, exp_s2, exp_s3, logmark
	from ar_master_last_old;
insert ar_master_log
	select accnt, haccnt, bdate, sta, osta, ressta, sta_tm, arr, dep, resdep, oarr, odep,
	rmposted = 'F', class, rmpoststa = '0', artag1, artag2, address1, address2, address3, address4, paycode, cycle, limit,
	credcode, credman, credunit, applname, applicant, phone, fax, email, extra,
	charge, credit, charge0, credit0, accredit, disputed, invoice,
	lastnumb, lastinumb, srqs, master, pcrec, pcrec_pkg, ref, saleid,
	resby, restime, depby, deptime, cby, changed,
	chargeby, chargetime, creditby, credittime, invoiceby, invoicetime, statementby, statementtime, '', null, '',
	exp_m1, exp_m2, exp_dt1, exp_dt2, exp_s1, exp_s2, exp_s3, logmark
	from ar_master_log_old;
insert ar_master_till
	select accnt, haccnt, bdate, sta, osta, ressta, sta_tm, arr, dep, resdep, oarr, odep,
	rmposted = 'F', class, rmpoststa = '0', artag1, artag2, address1, address2, address3, address4, paycode, cycle, limit,
	credcode, credman, credunit, applname, applicant, phone, fax, email, extra,
	charge, credit, charge0, credit0, accredit, disputed, invoice,
	lastnumb, lastinumb, srqs, master, pcrec, pcrec_pkg, ref, saleid,
	resby, restime, depby, deptime, cby, changed,
	chargeby, chargetime, creditby, credittime, invoiceby, invoicetime, statementby, statementtime, '', null, '',
	exp_m1, exp_m2, exp_dt1, exp_dt2, exp_s1, exp_s2, exp_s3, logmark
	from ar_master_till_old;

drop table ar_master_old;
drop table ar_master_last_old;
drop table ar_master_log_old;
drop table ar_master_till_old;
drop table har_master_old;
