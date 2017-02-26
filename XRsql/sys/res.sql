// --------------------------------------------------------------------------
//		basecode:		priority, mstcls, mststa, waitlist, turnaway, channel, worldcode, rmreason, vip, secret, 
//							rescancel, sex, race, occupation, idcode, visaid, visaunit, 
//							rjcode, up_reason, artag1, artag2, lastname 
//
//		table:			reqcode, restype, countrycode, mktcode, srccode, prvcode, greeting
//							
//
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
//  basecode : lastname  -- �й� ��
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='lastname')
	delete basecode_cat where cat='lastname';
insert basecode_cat select 'lastname', '�й���', 'Chinese Last Name', 1;
delete basecode where cat='lastname';
insert basecode(cat,code,descript,descript1) values('lastname', '���', '���', '���_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '�Ϲ�', '�Ϲ�', '�Ϲ�_eng');
insert basecode(cat,code,descript,descript1) values('lastname', 'ŷ��', 'ŷ��', 'ŷ��_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '����', '����', '����_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '˾��', '˾��', '˾��_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '˾ͽ', '˾ͽ', '˾ͽ_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '��ľ', '��ľ', '��ľ_eng');
insert basecode(cat,code,descript,descript1) values('lastname', 'Ľ��', 'Ľ��', 'Ľ��_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '�ĺ�', '�ĺ�', '�ĺ�_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '����', '����', '����_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '����', '����', '����_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '����', '����', '����_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '�Ϲ�', '�Ϲ�', '�Ϲ�_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '����', '����', '����_eng');
insert basecode(cat,code,descript,descript1) values('lastname', 'ξ��', 'ξ��', 'ξ��_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '����', '����', '����_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '����', '����', '����_eng');
// insert basecode(cat,code,descript,descript1) values('lastname', '', '', '_eng');


// --------------------------------------------------------------------------
//  basecode : artag1  -- ar accnt tag1
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='artag1')
	delete basecode_cat where cat='artag1';
insert basecode_cat select 'artag1', 'ar �������1', 'ar Master Class1', 1;
delete basecode where cat='artag1';
insert basecode(cat,code,descript,descript1,sequence) values('artag1', '1', '����', '����_eng', 10);
insert basecode(cat,code,descript,descript1,sequence) values('artag1', '2', '����', '����_eng', 20);
insert basecode(cat,code,descript,descript1,sequence) values('artag1', '3', '��˾', '��˾_eng', 30);
insert basecode(cat,code,descript,descript1,sequence) values('artag1', '4', '������', '������_eng', 40);
insert basecode(cat,code,descript,descript1,sequence) values('artag1', '5', '�����', '�����_eng', 50);
insert basecode(cat,code,descript,descript1,sequence) values('artag1', '6', '����', '����_eng', 60);


// --------------------------------------------------------------------------
//  basecode : artag2  -- ar accnt tag2
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='artag2')
	delete basecode_cat where cat='artag2';
insert basecode_cat select 'artag2', 'ar �������2', 'ar Master Class2', 1;
delete basecode where cat='artag2';
insert basecode(cat,code,descript,descript1,sequence) values('artag2', '1', '��ͨ������', '��ͨ������_eng', 10);
insert basecode(cat,code,descript,descript1,sequence) values('artag2', '2', '���޶� �ɣÿ���', '���޶� �ɣÿ���_eng', 20);
insert basecode(cat,code,descript,descript1,sequence) values('artag2', '3', '���޶� �ɣÿ���', '���޶� �ɣÿ���_eng', 30);



// --------------------------------------------------------------------------
//  basecode : priority  -- ���ȼ�
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='priority')
	delete basecode_cat where cat='priority';
insert basecode_cat select 'priority', '���ȼ�', 'Priority', 1;
delete basecode where cat='priority';
insert basecode(cat,code,descript,descript1,sequence,sys) values('priority', '0', '��', '��_eng', 10,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('priority', '1', '��', '��_eng', 20,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('priority', '2', '��', '��_eng', 30,'T');



// --------------------------------------------------------------------------
//  basecode : mstcls  -- master class
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='mstcls')
	delete basecode_cat where cat='mstcls';
insert basecode_cat select 'mstcls', '�������', 'Master Class', 1;
delete basecode where cat='mstcls';
insert basecode(cat,code,descript,descript1,sequence,sys) values('mstcls', 'F', '����', '����_eng', 10,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mstcls', 'G', '����', '����_eng', 20,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mstcls', 'M', '����', '����_eng', 30,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mstcls', 'C', '������', '������_eng', 40,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mstcls', 'A', 'Ӧ����', 'Ӧ����_eng', 50,'T');


// --------------------------------------------------------------------------
//  basecode : mststa  -- master ����״̬
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='mststa')
	delete basecode_cat where cat='mststa';
insert basecode_cat select 'mststa', '����״̬', 'Master Status', 1;
delete basecode where cat='mststa';
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'I', '��ס', '', 100,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'R', 'һ��Ԥ��', '', 101,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'W', 'Waitlist', '', 102,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'O', '�������', '', 104,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'D', '���ս���', '', 106,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'X', 'Ԥ��ȡ��', '', 108,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'S', '��ʱ����', '', 109,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'N', 'Ԥ��δ��', '', 110,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'E', '���ʿ���', '', 500,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'L', 'ת��', '', 911,'T');


// --------------------------------------------------------------------------
//  basecode : waitlist  -- �Ⱥ�Ԥ��
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='waitlist')
	delete basecode_cat where cat='waitlist';
insert basecode_cat select 'waitlist', '�Ⱥ�Ԥ��', 'waitlist', 3;
delete basecode where cat='waitlist';
insert basecode(cat,code,descript,descript1) select 'waitlist', 'FUL', '����', 'Fully Booked';
insert basecode(cat,code,descript,descript1) select 'waitlist', 'OVL', '����Ԥ��', 'Over Booked';
insert basecode(cat,code,descript,descript1) select 'waitlist', 'RAT', '�޿��÷�����', 'Rate code not available';
insert basecode(cat,code,descript,descript1) select 'waitlist', 'TYP', '�޿��÷���', 'Room Type not available';


// --------------------------------------------------------------------------
//  basecode : turnaway
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='turnaway')
	delete basecode_cat where cat='turnaway';
insert basecode_cat select 'turnaway', 'TurnAway', 'turnaway', 1;
delete basecode where cat='turnaway';
insert basecode(cat,code,descript,descript1) select 'turnaway', 'A', '����', 'Fully Booked';
insert basecode(cat,code,descript,descript1) select 'turnaway', 'B', '����Ԥ��', 'Over Booked';
insert basecode(cat,code,descript,descript1) select 'turnaway', 'C', '�޿��÷�����', 'Rate code not available';
insert basecode(cat,code,descript,descript1) select 'turnaway', 'D', '�޿��÷���', 'Room Type not available';
insert basecode(cat,code,descript,descript1) select 'turnaway', 'H', '���۹���', 'Rate Too High';
insert basecode(cat,code,descript,descript1) select 'turnaway', 'Z', 'û���ṩ����', 'No Reasons';



// --------------------------------------------------------------------------
//  basecode : channel  -- Ԥ������
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='channel')
	delete basecode_cat where cat='channel';
insert basecode_cat select 'channel', 'Ԥ������', 'Reservation Channel', 3;
delete basecode where cat='channel';
insert basecode(cat,code,descript,descript1) select 'channel', 'WKI', 'ֱ������', 'Walk In';
insert basecode(cat,code,descript,descript1) select 'channel', 'TEL', '�绰', 'Telephone';
insert basecode(cat,code,descript,descript1) select 'channel', 'FAX', '����', 'Fax';
insert basecode(cat,code,descript,descript1) select 'channel', 'EML', '����', 'E-mail';
insert basecode(cat,code,descript,descript1) select 'channel', 'WWW', '������', 'Website';
insert basecode(cat,code,descript,descript1) select 'channel', 'OTH', '����', 'Other';


// --------------------------------------------------------------------------
//  basecode : worldcode  -- �����������
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='worldcode')
	delete basecode_cat where cat='worldcode';
insert basecode_cat select 'worldcode', '�����������', 'World Region', 3;
delete basecode where cat='worldcode';
insert basecode(cat,code,descript,descript1) select 'worldcode', 'NAM', '������', 'North America';
insert basecode(cat,code,descript,descript1) select 'worldcode', 'SAM', '������', 'South America';
insert basecode(cat,code,descript,descript1) select 'worldcode', 'ASI', '����', 'Asia';
insert basecode(cat,code,descript,descript1) select 'worldcode', 'AFR', '����', 'Africa';
insert basecode(cat,code,descript,descript1) select 'worldcode', 'EUR', 'ŷ��', 'Europe';
insert basecode(cat,code,descript,descript1) select 'worldcode', 'RES', '����', 'Rest of World';


// --------------------------------------------------------------------------
//  basecode : rmreason  -- ��������
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='rmreason')
	delete basecode_cat where cat='rmreason';
insert basecode_cat select 'rmreason', '��������', 'Change Room Reason', 1;

delete basecode where cat='rmreason';
insert basecode(cat,code,descript,descript1) select 'rmreason', '1', 'ԭ��ά��', 'Old Room Error';
insert basecode(cat,code,descript,descript1) select 'rmreason', '2', '����Ҫ��', 'Guest Request';
insert basecode(cat,code,descript,descript1) select 'rmreason', '3', '������', 'Share Room';
insert basecode(cat,code,descript,descript1) select 'rmreason', '4', '����Ҫ��', 'Hotel Request';
insert basecode(cat,code,descript,descript1) select 'rmreason', '5', '�������', 'Input Error';


// --------------------------------------------------------------------------
//  basecode : up_reason  -- �ͷ���������
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='up_reason')
	delete basecode_cat where cat='up_reason';
insert basecode_cat select 'up_reason', '�ͷ���������', 'up_reason', 3;
delete basecode where cat='up_reason';
insert basecode(cat,code,descript,descript1) select 'up_reason', 'UPG', 'ǿ������', 'Forced Upgrade';
insert basecode(cat,code,descript,descript1) select 'up_reason', 'BUS', '��ҵ��ϵ', 'Business Relations';
insert basecode(cat,code,descript,descript1) select 'up_reason', 'CON', '��Լ', 'Per Contract';
insert basecode(cat,code,descript,descript1) select 'up_reason', 'COU', '��������', 'Courtesy Upgrade';
insert basecode(cat,code,descript,descript1) select 'up_reason', 'GST', '���ͱ�Թ', 'Guest Complaint';
insert basecode(cat,code,descript,descript1) select 'up_reason', 'GPD', '����֧��', 'Guest paying Difference';


// --------------------------------------------------------------------------
//  basecode : vip  -- ���
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='vip')
	delete basecode_cat where cat='vip';
insert basecode_cat select 'vip', '���', 'VIP', 1;

delete basecode where cat='vip';
insert basecode(cat,code,descript,descript1) select 'vip', '0', '��ͨ����', 'normal guest';
insert basecode(cat,code,descript,descript1) select 'vip', '1', 'VIP - 1', 'VIP - 1';
insert basecode(cat,code,descript,descript1) select 'vip', '2', 'VIP - 2', 'VIP - 2';
insert basecode(cat,code,descript,descript1) select 'vip', '3', 'VIP - 3', 'VIP - 3';
insert basecode(cat,code,descript,descript1) select 'vip', '4', 'VIP - 4', 'VIP - 4';


// --------------------------------------------------------------------------
//  basecode : secret  -- ����
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='secret')
	delete basecode_cat where cat='secret';
insert basecode_cat select 'secret', '����', 'Secret', 1;

delete basecode where cat='secret';
insert basecode(cat,code,descript,descript1) select 'secret', '0', '������', 'normal guest';
insert basecode(cat,code,descript,descript1) select 'secret', '1', '���� - 1', 'secret - 1';
insert basecode(cat,code,descript,descript1) select 'secret', '2', '���� - 2', 'secret - 2';
insert basecode(cat,code,descript,descript1) select 'secret', '3', '���� - 3', 'secret - 3';


// --------------------------------------------------------------------------
//  basecode : rescancel  -- ȡ��Ԥ�� - fidelio ��ɢ�ͺ��������ɷֿ��ˣ�����ϲ�
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='rescancel')
	delete basecode_cat where cat='rescancel';
insert basecode_cat select 'rescancel', 'ȡ��Ԥ��', 'Reservation Cancel Reason', 2;

delete basecode where cat='rescancel';
insert basecode(cat,code,descript,descript1) select 'rescancel', '1', '�ظ�Ԥ��', 'Double reservation';
insert basecode(cat,code,descript,descript1) select 'rescancel', '2', '��������6��', '6 p.m release';
insert basecode(cat,code,descript,descript1) select 'rescancel', '3', '�ƻ�����', 'Plans changed';
insert basecode(cat,code,descript,descript1) select 'rescancel', '4', '����', 'Weather';
insert basecode(cat,code,descript,descript1) select 'rescancel', '5', '����ȡ��', 'Convention cancelled';
insert basecode(cat,code,descript,descript1) select 'rescancel', '6', '����', 'Illness';
insert basecode(cat,code,descript,descript1) select 'rescancel', '7', '����ȡ��', 'Allocation no longer required';
insert basecode(cat,code,descript,descript1) select 'rescancel', '8', '���䲻��', 'Pickup insufficent block cancelled';
insert basecode(cat,code,descript,descript1) select 'rescancel', '9', '�������ܽ���', 'Offer not acceptable';
insert basecode(cat,code,descript,descript1) select 'rescancel', '10', 'Option not taken up', 'Option not taken up';
insert basecode(cat,code,descript,descript1) select 'rescancel', '11', 'û��ԭ��', 'Without reason';


// --------------------------------------------------------------------------
//  basecode : sex  -- �Ա�
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='sex')
	delete basecode_cat where cat='sex';
insert basecode_cat select 'sex', '�Ա�', 'sex', 1;

delete basecode where cat='sex';
insert basecode(cat,code,descript,descript1,sys,sequence) select 'sex', '?', 'δ֪', 'Unknown', 'T', 1;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'sex', 'M', '����', 'Male', 'T', 2;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'sex', 'F', 'Ů��', 'Female', 'T', 3;


// --------------------------------------------------------------------
//	Reservation reqcode : ����Ҫ������  -- fidelio ���л��պͼƼ۷��������
// --------------------------------------------------------------------
//exec sp_rename reqcode, a_reqcode; 
if exists(select * from sysobjects where name = "reqcode" and type = 'U')
	drop table reqcode;
create table reqcode
(
	code			char(3)						not null,
	descript    varchar(20)					not null,
	descript1   varchar(30)	default ''	not null,
	sequence		int			default 0	not null,
	flag1			char(10)		default ''	not null,	-- ��ǹ̶���Ҫ������ӻ����ͻ��ȣ�����Ӧ��  
	flag2			char(10)		default ''	not null,	-- Ԥ��
	flag3			char(20)		default ''	not null,	-- Ԥ��
	flag4			char(30)		default ''	not null,	-- Ԥ��
	rate1			money		default 0	not null,		-- �۸�1
	rate2			money		default 0	not null,		-- �۸�2
	n1				int		default 0	not null,		-- Ԥ�� 		
	n2				int		default 0	not null,		-- Ԥ�� 		
	retu			char(1)	default 'F' not null,		-- �Ƿ�Ҫ�ջ� 
	halt			char(1) 	default 'F' not null,
	cby			char(10) default 'FOX' not null,
	changed		datetime	default getdate() not null 
)
exec sp_primarykey reqcode,code
create unique index index1 on reqcode(code)
;
//insert reqcode select *, '', '', '', '',0,0,0,0,'F','F','',getdate() from a_reqcode; 
//select * from reqcode; 
//
//insert reqcode(code,descript,descript1) select 'LV','������','Lake View Room';
//insert reqcode(code,descript,descript1) select 'NS','���̷�','Non-Smoking Room';
//insert reqcode(code,descript,descript1) select 'SM','���̷�','Smoking Room';
//insert reqcode(code,descript,descript1) select 'RU','�ͷ���ɡ','Room Umbrella';
//insert reqcode(code,descript,descript1) select 'HF','��¥��','High Floor';
//insert reqcode(code,descript,descript1) select 'FAX','�����','Fax Machine';
//insert reqcode(code,descript,descript1) select 'WC','����','Wheelchair';
//insert reqcode(code,descript,descript1) select 'LO','���˷�','Late Check-out Requested';
//insert reqcode(code,descript,descript1) select 'LIM','�����γ�','Limo Requested';


// --------------------------------------------------------------------
//	Reservation restype : Ԥ������  -- �ϰ汾 resmode
// --------------------------------------------------------------------
if exists(select * from sysobjects where name = "restype")
   drop table restype;
create table restype
(
	code		   char(3)						not null,
	descript    varchar(16)					not null,
	descript1   varchar(20)	default ''	not null,
	definite		char(1)		default 'F'	not null,	// �Ƿ�ȷ��Ԥ�� definite or tentative
	req_arr		char(1)		default 'F'	not null,	// �Ƿ�ȷ�ϵִ�ʱ�� mandatory arr. time
	req_card		char(1)		default 'F'	not null,	// ���ÿ�
	req_credit	char(1)		default 'F'	not null,	// Ѻ��
	scope			char(10)		default 'FGM'	not null,	// Fɢ�� G���� M���� 
	flag1			char(10)		default ''	not null,
	flag2			char(10)		default ''	not null,
	flag3			char(20)		default ''	not null,
	grp			char(10)		default ''	not null,
	halt			char(1)		default 'F'	not null,	
	sequence		int			default 0	not null,
	cby			char(10) default 'FOX' not null,
	changed		datetime	default getdate() not null 
)
exec sp_primarykey restype,code
create unique index index1 on restype(code)
;
//insert restype(code,descript,descript1,definite,mat) select '0', '��סԤ��', 'Checked In','T','F'
//insert restype(code,descript,descript1,definite,mat) select '1', '������6��', '6 P.M.','T','F'
//insert restype(code,descript,descript1,definite,mat) select '2', 'Gtd. Credit Card', 'Gtd. Credit Card','T','F'
//insert restype(code,descript,descript1,definite,mat) select '3', 'Gtd. Company', 'Gtd. Company','T','F'
//insert restype(code,descript,descript1,definite,mat) select '4', 'Gtd. Voucher', 'Gtd. Voucher','T','F'
//insert restype(code,descript,descript1,definite,mat) select '5', 'Block Definite', 'Block Definite','T','F'
//insert restype(code,descript,descript1,definite,mat) select '6', 'Block Tentative', 'Block Tentative','F','F'
//insert restype(code,descript,descript1,definite,mat) select '7', 'Group Pickup', 'Group Pickup','T','F'
//insert restype(code,descript,descript1,definite,mat) select '8', 'Deposit Requested', 'Deposit Requested','T','F'
//;


// ------------------------------------------------------------------------------
//	Reservation countrycode : ����
// ------------------------------------------------------------------------------
// exec sp_rename countrycode, a_countrycode;
if exists(select * from sysobjects where name = "countrycode")
   drop table countrycode;
create table countrycode
(
   code			char(3)							not null,
   descript 	varchar(30)						not null,
   descript1 	varchar(40)	default ''		not null,
   helpcode  	varchar(20) default '' 		not null,  	/* ������*/
   short			char(3)		default ''		not null,	/* ��д */
   iso			char(3)		default ''		not null,	/* ISO Code */
   addfmt		char(1)		default ''		not null,	/* �ŷ��ַ���� */
	worldcode	char(3)  	default '' 		not null,
	lang			char(1)		default 'E'		not null,		/* ���� */
	sequence		int			default 0		not null
)
exec sp_primarykey countrycode,code
create unique index index1 on countrycode(code)
create index index2 on countrycode(helpcode)
create index index3 on countrycode(short)
;
//insert countrycode (code,descript,helpcode,short,worldcode)
//	select code,descript,hlpcode,short,isnull(worldcode,''),'E' from a_countrycode;



// --------------------------------------------------------------------------
//  basecode : race  -- ����
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='race')
	delete basecode_cat where cat='race';
insert basecode_cat select 'race', '����', 'race', 2;
delete basecode where cat='race';
insert basecode(cat,code,descript,descript1) 
	select 'race', code, descript, hlpcode from racecode;


// --------------------------------------------------------------------------
//  basecode : occupation  -- ְҵ
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='occupation')
	delete basecode_cat where cat='occupation';
insert basecode_cat select 'occupation', 'ְҵ', 'occupation', 2;
delete basecode where cat='occupation';
insert basecode(cat,code,descript,descript1) 
	select 'occupation', code, descript, '' from jobcode;



// --------------------------------------------------------------------------
//  basecode : idcode  -- ֤��
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='idcode')
	delete basecode_cat where cat='idcode';
insert basecode_cat select 'idcode', '֤��', 'idcode', 3;
delete basecode where cat='idcode';
insert basecode(cat,code,descript,descript1) 
	select 'idcode', code, descript, '' from idcode;


// --------------------------------------------------------------------------
//  basecode : visaid  -- ǩ֤���
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='visaid')
	delete basecode_cat where cat='visaid';
insert basecode_cat select 'visaid', 'ǩ֤���', 'visaid', 3;
delete basecode where cat='visaid';
insert basecode(cat,code,descript,descript1) 
	select 'visaid', code, descript, '' from asscode;



// --------------------------------------------------------------------------
//  basecode : visaunit  -- ǩ֤����
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='visaunit')
	delete basecode_cat where cat='visaunit';
insert basecode_cat select 'visaunit', 'ǩ֤����', 'visaunit', 4;
delete basecode where cat='visaunit';
insert basecode(cat,code,descript,descript1) 
	select 'visaunit', code, descript, '' from assunit;



// --------------------------------------------------------------------------
//  basecode : rjcode  -- �뾳�ڰ�
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='rjcode')
	delete basecode_cat where cat='rjcode';
insert basecode_cat select 'rjcode', '�뾳�ڰ�', 'rjcode', 3;
delete basecode where cat='rjcode';
insert basecode(cat,code,descript,descript1) 
	select 'rjcode', code, descript, '' from rjcode;



// ------------------------------------------------------------------------------
//	Reservation prvcode : ʡ
// ------------------------------------------------------------------------------
//exec sp_rename prvcode, a_prvcode;
if exists(select * from sysobjects where name = "prvcode")
	drop table prvcode;
create table prvcode
(
	country		char(3)						not null,
	code			char(3)						not null,
	descript    varchar(20)					not null,
	descript1   varchar(30)	default ''	not null,
   short			char(3)		default ''	not null,	// ��д
	s_zip			char(6)		default ''	not null,	// ��������
	e_zip			char(6)		default ''	not null,
	sequence		int			default 0	not null
);
exec sp_primarykey prvcode,code
create unique index index1 on prvcode(code)
create index index2 on prvcode(short)
create index index3 on prvcode(s_zip)
create index index4 on prvcode(e_zip)
;
//insert prvcode (country,code,descript,descript1,short)
//	select 'CHN',number,descript,edescript,code from a_prvcode;


// ------------------------------------------------------------------------------
//	Reservation cntcode : ��������
// ------------------------------------------------------------------------------
//exec sp_rename cntcode, a_cntcode;
if exists(select * from sysobjects where name = "cntcode")
	drop table cntcode;
create table cntcode
(
	country		char(3)						not null,
	prv			char(3)						not null,
	code			char(6)						not null,
	descript    varchar(40)					not null,
	descript1   varchar(50)	default ''	not null,
	s_zip			char(6)		default ''	not null,	// ��������
	e_zip			char(6)		default ''	not null,
   helpcode		varchar(10)	default ''	not null
);
exec sp_primarykey cntcode,code
create unique index index1 on cntcode(code)
create index index2 on cntcode(descript)
create index index3 on cntcode(helpcode)
;
//insert cntcode (country,prv,code,descript,descript1,helpcode)
//	select 'CHN',substring(code,1,2),code,descript,'',helpcode from a_cntcode;


// ------------------------------------------------------------------------------
//	Reservation srccode : ��Դ
// ------------------------------------------------------------------------------
//exec sp_rename srccode, a_srccode;
if exists(select * from sysobjects where name = "srccode")
   drop table srccode;
create table srccode
(
	code			char(3)						not null,
	descript    char(20)						not null,
	descript1   varchar(30)	default ''	not null,
	grp			varchar(16)	default ''	not null,
	sequence		int		default 0		not null,
	halt			char(1)		default 'F'	not null,	
	cby			char(10) default 'FOX' not null,
	changed		datetime	default getdate() not null 
)
exec sp_primarykey srccode,code
create unique index index1 on srccode(code)
;
//insert srccode(code,descript,descript1,grp) select 'LOC','���ع�˾','Local company','COMPANY'
//insert srccode(code,descript,descript1,grp) select 'NAC','���ڹ�˾','National company','COMPANY'
//insert srccode(code,descript,descript1,grp) select 'INC','���⹫˾','Internet. company','COMPANY'
//insert srccode(code,descript,descript1,grp) select 'LOA','����������','Local agent','AGENT'
//insert srccode(code,descript,descript1,grp) select 'NAA','����������','National agent','AGENT'
//insert srccode(code,descript,descript1,grp) select 'INA','����������','Internet agent','AGENT'
//insert srccode(code,descript,descript1,grp) select 'RES','Ԥ��ϵͳ','Reservation system','MISCELLANEOUS'
//insert srccode(code,descript,descript1,grp) select 'IND','ɢ��','Individual','MISCELLANEOUS'
//insert srccode(code,descript,descript1,grp) select 'A/R','Ӧ�տͻ�','Accounts receivable','ACCOUNT'
//insert srccode(code,descript,descript1,grp) select 'RSO','��������','Regional sales office','MISCELLANEOUS'
//insert srccode(code,descript,descript1,grp) select 'SHO','չ��','Showcase','MISCELLANEOUS'
//insert srccode(code,descript,descript1,grp) select 'RBU','��ͷ��','Repeat business','MISCELLANEOUS'
//insert srccode(code,descript,descript1,grp) select 'WLK','ֱ������','Walk in','MISCELLANEOUS'
//;
--************************
--srccode insert 
--************************
if exists (select * from sysobjects where name = 't_gds_srccode_insert' and type = 'TR')
   drop trigger t_gds_srccode_insert;
create trigger t_gds_srccode_insert
   on srccode
   for insert as
begin
declare	@code		varchar(3),
			@grp		varchar(16),
			@des		varchar(20),
			@des1		varchar(30)

select @code=code, @grp=grp, @des=descript, @des1=descript1 from inserted
if @@rowcount = 0 
   rollback trigger with raiserror 20000 "���Ӵ������HRY_MARK"

-----------------------------
-- ����
-----------------------------
if rtrim(@des) is null or  rtrim(@des1) is null 
   rollback trigger with raiserror 20000 "����������HRY_MARK"
if charindex("'", @des)>0 or charindex('"', @des)>0 or charindex("'", @des1)>0 or charindex('"', @des1)>0
   rollback trigger with raiserror 20000 "�������ֹʹ��Ӣ������HRY_MARK"
end
;


--************************
--srccode update
--************************
if exists (select * from sysobjects where name = 't_gds_srccode_update' and type = 'TR')
   drop trigger t_gds_srccode_update;
create trigger t_gds_srccode_update
   on srccode
   for update as
begin
declare	
			@code		varchar(3),	@code0	varchar(3),
			@grp		varchar(16),	@grp0		varchar(16),
			@des		varchar(20),
			@des1		varchar(30)

select @code=code, @grp=grp, @des=descript, @des1=descript1 from inserted
select @code0=code, @grp0=grp from deleted

-----------------------------
-- ����
-----------------------------
if rtrim(@des) is null or  rtrim(@des1) is null 
   rollback trigger with raiserror 20000 "����������HRY_MARK"
if charindex("'", @des)>0 or charindex('"', @des)>0 or charindex("'", @des1)>0 or charindex('"', @des1)>0
   rollback trigger with raiserror 20000 "�������ֹʹ��Ӣ������HRY_MARK"
end
;




// ------------------------------------------------------------------------------
//	Reservation mktcode : �г���
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "mktcode")
   drop table mktcode;
create table mktcode
(
	code			char(3)						not null,
	descript    char(20)						not null,
	descript1   varchar(30)	default ''	not null,
	grp			varchar(16)	default ''	not null,
	jierep		char(8)		default ''	not null,
	flag			char(3)		default ''	not null, -- LON, HSE, COM 
	sequence		int		default 0		not null,
	halt			char(1) 	default 'F' not null,
	cby			char(10) default 'FOX' not null,
	changed		datetime	default getdate() not null 
)
exec sp_primarykey mktcode,code
create unique index index1 on mktcode(code)
;
--************************
--mktcode insert 
--************************
if exists (select * from sysobjects where name = 't_gds_mktcode_insert' and type = 'TR')
   drop trigger t_gds_mktcode_insert;
create trigger t_gds_mktcode_insert
   on mktcode
   for insert as
begin
declare	@code		varchar(3),
			@grp		varchar(16),
			@des		varchar(20),
			@des1		varchar(30)

select @code=code, @grp=grp, @des=descript, @des1=descript1 from inserted
if @@rowcount = 0 
   rollback trigger with raiserror 20000 "���Ӵ������HRY_MARK"

-----------------------------
-- ����
-----------------------------
if rtrim(@des) is null or  rtrim(@des1) is null 
   rollback trigger with raiserror 20000 "����������HRY_MARK"
if charindex("'", @des)>0 or charindex('"', @des)>0 or charindex("'", @des1)>0 or charindex('"', @des1)>0
   rollback trigger with raiserror 20000 "�������ֹʹ��Ӣ������HRY_MARK"
end
;


--************************
--mktcode update
--************************
if exists (select * from sysobjects where name = 't_gds_mktcode_update' and type = 'TR')
   drop trigger t_gds_mktcode_update;
create trigger t_gds_mktcode_update
   on mktcode
   for update as
begin
declare	
			@code		varchar(3),	@code0	varchar(3),
			@grp		varchar(16),	@grp0		varchar(16),
			@des		varchar(20),
			@des1		varchar(30)

select @code=code, @grp=grp, @des=descript, @des1=descript1 from inserted
select @code0=code, @grp0=grp from deleted

-----------------------------
-- ����
-----------------------------
if rtrim(@des) is null or  rtrim(@des1) is null 
   rollback trigger with raiserror 20000 "����������HRY_MARK"
if charindex("'", @des)>0 or charindex('"', @des)>0 or charindex("'", @des1)>0 or charindex('"', @des1)>0
   rollback trigger with raiserror 20000 "�������ֹʹ��Ӣ������HRY_MARK"
end
;




// ------------------------------------------------------------------------------
//	greeting : �ƺ�
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "greeting")
   drop table greeting;
create table greeting
(
	code			char(3)						not null,
	short    	varchar(50)	default ''	not null,
	long   		varchar(50)	default ''	not null,
	lang			char(3)		default ''	not null,
	sequence		int		default 0		not null,
	sex			char(3)	default ''		null
)
exec sp_primarykey greeting,code,lang
create unique index index1 on greeting(code,lang)
;