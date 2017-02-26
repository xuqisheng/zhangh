----------------------------------------------------------------
if not exists(select 1 from sysoption where catalog='reserve' and item='guest_card_calc')
	insert sysoption values ('reserve', 'guest_card_calc', 'FOX,POINT', '��Щguest_card����Ҫ������ֵġ�-- flag')

if not exists(select 1 from sysoption where catalog='vipcard' and item='exchange_rate')
	insert sysoption values ('vipcard', 'exchange_rate', '40', '���ֶһ��ʣ����ٷ���һ��Ǯ��');

-- ����ٲ���
--if not exists(select 1 from sysoption where catalog='vipcard' and item='no_match')
--	insert sysoption values ('vipcard', 'no_match', '^[^K]', '���Ź�����Ŀ�������');
delete sysoption where catalog='vipcard' and item='no_match';

if not exists(select 1 from sysoption where catalog='hotel' and item='hotelid')    -- value = crs --> center
	insert sysoption values ('hotel', 'hotelid', 'XR', '��Ա�Ƶ��');

if not exists(select 1 from sysoption where catalog='vipcard' and item='auto_no')
	insert sysoption values ('vipcard', 'auto_no', 'F', '�Զ������������?');

if not exists(select 1 from sysoption where catalog='vipcard' and item='issue_mode')
	insert sysoption(catalog,item,value,remark) values( 'vipcard','issue_mode','STATUS', 'Vipcard Issue mode = STATUS / SINGLE / POOL ');

if not exists(select 1 from sysoption where catalog='vipcard' and item='query_grp_def')
	insert sysoption(catalog,item,value,remark) values( 'vipcard','query_grp_def','f', '����ȱʡ�Ƿ�-���� ');

if not exists(select 1 from sysoption where catalog='vipcard' and item='lostcard_issue')
	insert sysoption(catalog,item,value,remark) values( 'vipcard','lostcard_issue','old', '��ʧ�����·�����������δ����أ�');
----------------------------------------------------------------



----------------------------------------------------------------


----------------------------------------------------------------
--	Table define 
--		vipcard, vipcard_log
--		vippoint, hvippoint
--		vipcard_type, 
--		vipptcode
--		vipdef1, vipdef2
--		vippack, vippack_def, vippack_set
--		datadown
--
----------------------------------------------------------------
--	vipcard -  ���ŵļ��й���
--		����:	�ۿۿ�	--->  ���Զ�ӦAR�˺�,�Ӷ��Ǽ��˿�
--						��λ��
--						���˿�
--				��ֵ��	
----------------------------------------------------------------
if exists(select * from sysobjects where name = "vipcard")
	drop table vipcard
;
create table vipcard
(
	no					char(20)								not null,	-- ����	
	sno				varchar(20)		default ''		not null,	-- ����(͹��),һ�����no. ������ϵͳ
	mno				char(20)			default ''		not null,	-- ������
	sta				char(1)			default 'I' 	not null,	-- ״̬=I-��Ч,X-����,L-��ʧ,M-��,O-ͣ��
	type				char(3)								not null,  	-- ���  table=vipcard_type
	class				char(3)								not null,  	-- ϵͳ���  basecode=vipcard_class
	src				char(3)								not null,  	-- ϵͳ���  basecode=vipcard_src
	center			char(1)			default 'F'		not null,

	name		   	varchar(50)	 						not null,	 	-- ��������

	code1				varchar(60)		default ''		not null, 		-- �����봮
	code2				varchar(30)		default ''		not null, 		-- �����봮 
	code3				varchar(30)		default ''		not null, 		-- ���� 
	code4				varchar(30)		default ''		not null, 		-- ���� 
	code5				varchar(30)		default ''		not null, 		-- ���� 

	araccnt1			char(10)			default ''		null,			-- AR�˺�(ǰ), ����Ǵ��ۿ���Ϊ��
	araccnt2			char(10)			default ''		null,			-- AR�˺�(��), ����Ǵ��ۿ���Ϊ��
	kno				char(7)			default ''		null,			-- ��������
	cno				char(7)			default ''		null,			-- ��λ��(��Ӧ guest)
	hno				char(7)			default ''		null,			-- �ֿ���(��Ӧ guest)

	arr				datetime								null,  		-- ��Ч����
	dep				datetime								null,			-- ��ֹ����
	password			varchar(10)		default '' 		not null, 	-- for gaoliang
	pwd_q				varchar(30)		default ''		null,			-- ������ʾ����
	pwd_a				varchar(30)		default ''		null,			--	������ʾ��
	crc				varchar(20)		default '' 		not null, 	-- ϵͳ���ɵ������
	extrainf			varchar(30)		default '' 		not null, 	-- for gaoliang
	postctrl			char(1)			default 'F' 	not null, 	-- ǩ������
	flag		   	varchar(40)	 	default ''		not null,	-- ���

	limit				money				default 0	 	not null, 	-- �޶�
	charge   		money       	DEFAULT 0	 	 NOT NULL,	-- ����
	credit   		money       	DEFAULT 0	 	 NOT NULL,
	lastnumb 		int         	DEFAULT 0	 	 NOT NULL,

	fv_date			datetime								null,				-- �״ε��� 
	fv_room			char(5)			default ''		not null,
	fv_rate			money				default 0		not null,
	lv_date			datetime								null,				-- �ϴε��� 
	lv_room			char(5)			default ''		not null,
	lv_rate			money				default 0		not null,

   i_times			integer			default 0 		not null,		-- ס����� 
   x_times			integer			default 0 		not null,		-- ȡ��Ԥ������ 
   n_times			integer			default 0 		not null,		-- Ӧ��δ������ 
   l_times			integer			default 0 		not null,		-- �������� 
   i_days			integer			default 0 		not null,		-- ס������ 

   fb_times1		integer			default 0 		not null,		-- �������� 
   en_times2		integer			default 0 		not null,		-- ���ִ��� 

   rm					money 			default 0 		not null, 		-- ��������
   fb					money 			default 0 		not null, 		-- ��������
   en					money 			default 0 		not null, 		-- ��������
   mt					money 			default 0 		not null, 		-- ��������
   ot					money 			default 0 		not null, 		-- ��������
   tl					money 			default 0 		not null, 		-- ������  

	hotelid			varchar(20)		default ''		not null,   -- Hotel ID.
	saleid		   varchar(50)	 	default ''		not null,	-- ����Ա
	resby				char(10)			default ''		not null,	-- ��������  
	reserved			datetime								null,	
	ciby				char(10)			default ''		not null,	-- ���й���  
	citime			datetime								null,	
	cby				char(10)			default ''		not null,	-- �޸Ĺ���  
	changed			datetime								null,			
	ref				varchar(255)						null,			-- ��ע
	exp_s1			varchar(20)							null,
	exp_s2			varchar(20)							null,
	exp_s3			varchar(20)							null,
	exp_s4			varchar(20)							null,
	exp_s5			varchar(20)							null,
	exp_s6			varchar(64)							null,
	exp_s7			varchar(64)							null,
	exp_s8			varchar(64)							null,
	exp_s9			varchar(64)							null,
	exp_s0			varchar(64)							null,
	exp_m1			money									null,
	exp_m2			money									null,
	exp_m3			money									null,
	exp_dt1			datetime								null,
	exp_dt2			datetime								null,
	exp_dt3			datetime								null,
	logmark			integer			default 0 		not null
)
exec sp_primarykey vipcard, no
create unique index index1 on vipcard(no)
create index index2 on vipcard(sno)
;

-----------------------------
--	vipcard_log
-----------------------------
if exists(select * from sysobjects where name = "vipcard_log")
	drop table vipcard_log;
create table vipcard_log
(
	no					char(20)								not null,	-- ����	
	sno				varchar(20)		default ''		not null,	-- ����(͹��),һ�����no. ������ϵͳ
	mno				char(20)			default ''		not null,	-- ������
	sta				char(1)			default 'I' 	not null,	-- ״̬=I-��Ч,X-����,L-��ʧ,M-��,O-ͣ��
	type				char(3)								not null,  	-- ���  table=vipcard_type
	class				char(3)								not null,  	-- ϵͳ���  basecode=vipcard_class
	src				char(3)								not null,  	-- ϵͳ���  basecode=vipcard_src
	center			char(1)			default 'F'		not null,

	name		   	varchar(50)	 						not null,	 	-- ��������

	code1				varchar(60)		default ''		not null, 		-- �����봮
	code2				varchar(30)		default ''		not null, 		-- �����봮 
	code3				varchar(30)		default ''		not null, 		-- ���� 
	code4				varchar(30)		default ''		not null, 		-- ���� 
	code5				varchar(30)		default ''		not null, 		-- ���� 

	araccnt1			char(10)			default ''		null,			-- AR�˺�(ǰ), ����Ǵ��ۿ���Ϊ��
	araccnt2			char(10)			default ''		null,			-- AR�˺�(��), ����Ǵ��ۿ���Ϊ��
	kno				char(7)			default ''		null,			-- ��������
	cno				char(7)			default ''		null,			-- ��λ��(��Ӧ guest)
	hno				char(7)			default ''		null,			-- �ֿ���(��Ӧ guest)

	arr				datetime								null,  		-- ��Ч����
	dep				datetime								null,			-- ��ֹ����
	password			varchar(10)		default '' 		not null, 	-- for gaoliang
	pwd_q				varchar(30)		default ''		null,			-- ������ʾ����
	pwd_a				varchar(30)		default ''		null,			--	������ʾ��
	crc				varchar(20)		default '' 		not null, 	-- ϵͳ���ɵ������
	extrainf			varchar(30)		default '' 		not null, 	-- for gaoliang
	postctrl			char(1)			default 'F' 	not null, 	-- ǩ������
	flag		   	varchar(40)	 	default ''		not null,	-- ���

	limit				money				default 0	 	not null, 	-- �޶�
	charge   		money       	DEFAULT 0	 	 NOT NULL,	-- ����
	credit   		money       	DEFAULT 0	 	 NOT NULL,
	lastnumb 		int         	DEFAULT 0	 	 NOT NULL,

	fv_date			datetime								null,				-- �״ε��� 
	fv_room			char(5)			default ''		not null,
	fv_rate			money				default 0		not null,
	lv_date			datetime								null,				-- �ϴε��� 
	lv_room			char(5)			default ''		not null,
	lv_rate			money				default 0		not null,

   i_times			integer			default 0 		not null,		-- ס����� 
   x_times			integer			default 0 		not null,		-- ȡ��Ԥ������ 
   n_times			integer			default 0 		not null,		-- Ӧ��δ������ 
   l_times			integer			default 0 		not null,		-- �������� 
   i_days			integer			default 0 		not null,		-- ס������ 

   fb_times1		integer			default 0 		not null,		-- �������� 
   en_times2		integer			default 0 		not null,		-- ���ִ��� 

   rm					money 			default 0 		not null, 		-- ��������
   fb					money 			default 0 		not null, 		-- ��������
   en					money 			default 0 		not null, 		-- ��������
   mt					money 			default 0 		not null, 		-- ��������
   ot					money 			default 0 		not null, 		-- ��������
   tl					money 			default 0 		not null, 		-- ������  

	hotelid			varchar(20)		default ''		not null,   -- Hotel ID.
	saleid		   varchar(50)	 	default ''		not null,	-- ����Ա
	resby				char(10)			default ''		not null,	-- ��������  
	reserved			datetime								null,	
	ciby				char(10)			default ''		not null,	-- ���й���  
	citime			datetime								null,	
	cby				char(10)			default ''		not null,	-- �޸Ĺ���  
	changed			datetime								null,			
	ref				varchar(255)						null,			-- ��ע
	exp_s1			varchar(20)							null,
	exp_s2			varchar(20)							null,
	exp_s3			varchar(20)							null,
	exp_s4			varchar(20)							null,
	exp_s5			varchar(20)							null,
	exp_s6			varchar(64)							null,
	exp_s7			varchar(64)							null,
	exp_s8			varchar(64)							null,
	exp_s9			varchar(64)							null,
	exp_s0			varchar(64)							null,
	exp_m1			money									null,
	exp_m2			money									null,
	exp_m3			money									null,
	exp_dt1			datetime								null,
	exp_dt2			datetime								null,
	exp_dt3			datetime								null,
	logmark			integer			default 0 		not null
)
exec sp_primarykey vipcard_log, no, logmark
create unique index index1 on vipcard_log(no, logmark)
;


// lgfl_des for vipcard 
delete lgfl_des where columnname like 'v_%';

insert lgfl_des(columnname,descript,descript1,tag) select 'v_sta','״̬','Status','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_sno','�Ա���','Hand No','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_class','���','Class','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_type','���1','Type','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_code1','������','Ratecode','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_code2','POSģʽ','POS Mode','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_araccnt1','AR�˺�','AR# 1','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_araccnt2','AR�˺�2','AR# 2','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_name','����','Name','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_cno','��λ','Comp.','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_hno','����','Profile','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_arr','����','Arr.','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_dep','�뿪','Dep.','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_password','����','Password','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_extrainf','������Ϣ','Extra','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_postctrl','ǩ������','Post Ctrl.','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_limit','�����޶�','LImit','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_ref','��ע','Remark','V';


if exists(select * from sysobjects where type ="U" and name = "vippoint")
   drop table vippoint;
create table vippoint
(
	no				char(20)		not null,							/* ���� */
	number		integer		not null,							/* �������к�,ÿ���˺ŷֱ��1��ʼ */
	log_date		datetime		default getdate() not null,	/* �������� */
	hotelid		varchar(20)	default '' not null,				/* ��Ա�Ƶ�� */
	bdate			datetime		not null,							/* Ӫҵ���� */
	expiry_date	datetime		default getdate() not null,	/* ������Ч�� */
	quantity		money			default 0 not null,				/* ���� */
	charge		money			default 0 not null,				/* �跽��,��¼�������� */
	credit		money			default 0 not null,				/* ������,��¼���˶��𼰽���� */
	balance		money			default 0 not null,				/* �¼��ֶ� */
	fo_modu_id	char(2)		not null,							/* ģ��� */
	fo_accnt		char(10)		default '' not null,				/* ���(ʹ��)���ֵ�ǰ̨�˺� */
	fo_number	integer		default 0 not null,				/* ʹ�û��ֵ�ǰ̨�˴� */		
	fo_billno	char(10)		default '' not null,				/* ʹ�û��ֵ�ǰ̨���ʵ��� */
	
	m1				money			default 0	not null,			// ���� / ���ѽ��
	m2				money			default 0	not null,			// �ͷ� / �ɱ����
	m3				money			default 0	not null,			// ���� / �һ�����
	m4				money			default 0	not null,
	m5				money			default 0	not null,
	m9				money			default 0	not null,
	calc			varchar(10)	default ''	not null,			/* ������� */

	shift			char(1)		not null,							/* ����Ա��� */
	empno			char(10)		not null,							/* ����Ա���� */
	tag			char(3)		null,									/* ��־ */

	ref			char(24)		default '' null,					/* ���ã��������� */
	ref1			char(10)		default '' null,					/* ���� */
	ref2			char(50)		default '' null,					/* ժҪ */

	empno0		char(10)						null,					/* ���ˣ����ţ� */
	date0			datetime						null,					/* ���ˣ�ʱ�䣩 */
	shift0		char(1)						null,					/* ���ˣ���ţ� */
	mode1			char(10)						null,					/* ������ */
	pnumber		integer		default 0 	null,					/* ͬһ�����ĺ������һ����inumber��ͬ */
	package		char(3)						null,					/* ���˱�־ */

	localok		char(1)		default 'T'	not null,
	sendout		char(1)		default 'F'	not null,

	exp_s1		varchar(20)	default ''	null,
	exp_s2		varchar(20)	default ''	null,
	exp_s3		varchar(20)	default ''	null,
	exp_dt1		datetime						null,
	exp_dt2		datetime						null

)
;
exec   sp_primarykey vippoint, no, number
create unique index index1 on vippoint(no, number)
create index index2 on vippoint(bdate)
;



if exists(select * from sysobjects where type ="U" and name = "hvippoint")
   drop table hvippoint;
create table hvippoint
(
	no				char(20)		not null,							/* ���� */
	number		integer		not null,							/* �������к�,ÿ���˺ŷֱ��1��ʼ */
	log_date		datetime		default getdate() not null,	/* �������� */
	hotelid		varchar(20)	default '' not null,				/* ��Ա�Ƶ�� */
	bdate			datetime		not null,							/* Ӫҵ���� */
	expiry_date	datetime		default getdate() not null,	/* ������Ч�� */
	quantity		money			default 0 not null,				/* ���� */
	charge		money			default 0 not null,				/* �跽��,��¼�������� */
	credit		money			default 0 not null,				/* ������,��¼���˶��𼰽���� */
	balance		money			default 0 not null,				/* �¼��ֶ� */
	fo_modu_id	char(2)		not null,							/* ģ��� */
	fo_accnt		char(10)		default '' not null,				/* ���(ʹ��)���ֵ�ǰ̨�˺� */
	fo_number	integer		default 0 not null,				/* ʹ�û��ֵ�ǰ̨�˴� */		
	fo_billno	char(10)		default '' not null,				/* ʹ�û��ֵ�ǰ̨���ʵ��� */
	
	m1				money			default 0	not null,
	m2				money			default 0	not null,
	m3				money			default 0	not null,
	m4				money			default 0	not null,
	m5				money			default 0	not null,
	m9				money			default 0	not null,
	calc			varchar(10)	default ''	not null,			/* ������� */

	shift			char(1)		not null,							/* ����Ա��� */
	empno			char(10)		not null,							/* ����Ա���� */
	tag			char(3)		null,									/* ��־ */

	ref			char(24)		default '' null,					/* ���ã��������� */
	ref1			char(10)		default '' null,					/* ���� */
	ref2			char(50)		default '' null,					/* ժҪ */

	empno0		char(10)						null,					/* ���ˣ����ţ� */
	date0			datetime						null,					/* ���ˣ�ʱ�䣩 */
	shift0		char(1)						null,					/* ���ˣ���ţ� */
	mode1			char(10)						null,					/* ������ */
	pnumber		integer		default 0 	null,					/* ͬһ�����ĺ������һ����inumber��ͬ */
	package		char(3)						null,					/* ���˱�־ */

	localok		char(1)		default 'T'	not null,
	sendout		char(1)		default 'F'	not null,

	exp_s1		varchar(20)	default ''	null,
	exp_s2		varchar(20)	default ''	null,
	exp_s3		varchar(20)	default ''	null,
	exp_dt1		datetime						null,
	exp_dt2		datetime						null

)
;
exec   sp_primarykey hvippoint, no, number
create unique index index1 on hvippoint(no, number)
create index index2 on hvippoint(bdate)
;


------------------------------------------------------
--	��������
------------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "vipcard_type")
   drop table vipcard_type;
create table vipcard_type
(
	code			char(3)			not null,					
	descript		varchar(50)	default ''	not null,
	descript1	varchar(50)	default '' not null,	
	calc			char(10)		default '' not null,	   -- vipptcode
	guestcard	char(10)		default '' not null,		 -- guest_card_type 
	mustread		char(1)		default 'F'	not null,
	center		char(1)		default 'F'	not null,
	halt      	char(1)     DEFAULT 'F' NOT NULL,		
	issmode		char(10)		DEFAULT 'STATUS' NOT NULL,    --  ����ģʽ STATUS / SINGLE / POOL 
	sequence		int			default 0 	not null
);
EXEC sp_primarykey 'vipcard_type', code;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON vipcard_type(code)
CREATE UNIQUE NONCLUSTERED INDEX index3 ON vipcard_type(guestcard)
CREATE UNIQUE NONCLUSTERED INDEX index2 ON vipcard_type(descript)
;
insert vipcard_type values( 'A', '��������Ա', 'Jinling Elite Membership', '0', 'JL1', 'T', 'F', 'F', 10);
insert vipcard_type values( 'B', '����𿨹����Ա', 'Jinling Gold Membership', '0', 'JL2', 'T', 'F', 'F', 20);
insert vipcard_type values( 'C', '���견�𿨹����Ա', 'Jinling Platinum Membership', '0', 'JL3', 'T', 'F', 'F', 30);


------------------------------------------------------
--	���ּ������
------------------------------------------------------
if object_id('vipptcode') is not null
	drop table vipptcode;
CREATE TABLE vipptcode 
(
    code      char(10)    NOT NULL,						// ��Ӷ����
    descript  varchar(60) NOT NULL,						// ��������
    descript1 varchar(60) NOT NULL,						// Ӣ������
    halt      char(1)     DEFAULT 'F' NOT NULL,		// ͣ�ñ�־    T ��ͣ��  F �� �� 
	sequence		int		default 0 	not null
);
EXEC sp_primarykey 'vipptcode', code;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON vipptcode(code)
CREATE UNIQUE NONCLUSTERED INDEX index2 ON vipptcode(descript)
;
insert vipptcode values('0', '��ͨ', 'Nomal', 'F', 100);
insert vipptcode values('1', '���', 'Vip', 'F', 200);

------------------------------------------------------
--	���ּ������ - items
------------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "vipdef1")
   drop table vipdef1;
create table vipdef1
(
	code			char(10)			not null,							/* ���ּ������ */
	pccode		varchar(5)		not null,							/* ������ */
	base			money				default 1 not null,				/* �� */
	step			money				default 1 not null,				/* ���� */
	rate			money				default 0 not null,				/* ���ѡ����ֵĻ����� */
	cby			char(10)			not null,							/* �û��� */
	changed		datetime			default getdate() not null,	/* �޸�ʱ�� */
)
;
exec   sp_primarykey vipdef1, code, pccode
create unique index index1 on vipdef1(code, pccode)
;

insert vipdef1(code,pccode,base,step,rate,cby,changed)
	select a.code, b.pccode, 1, 1, 1, 'FOX', getdate() 
		from vipptcode a, pccode b where b.pccode < '9';
update vipdef1 set rate=1.209 where code='0';
update vipdef1 set rate=1.451 where code='1';

------------------------------------------------------
--	���ּ��� ʱ�����
------------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "vipdef2")
   drop table vipdef2;
create table vipdef2
(
	type			char(1)			not null,							/* ���B:����;D:DATETYPE;U:�û��Զ��� */
	code			char(1)			not null,							/* ������ */
	descript		varchar(50)		null,									/* ���� */
	descript1	varchar(50)		null,									/* ���� */
	starting		datetime			null,									/* ��ʼ���� */
	ending		datetime			null,									/* �������� */
	rate			money				default 1 not null,				/* ���ѡ����ֵĻ����� */
	cby			char(10)			not null,							/* �û��� */
	changed		datetime			default getdate() not null,	/* �޸�ʱ�� */
)
;
exec   sp_primarykey vipdef2, type, code, starting, ending
create unique index index1 on vipdef2(type, code, starting, ending)
;
insert vipdef2 values('B', '', '����', 'Birthday', null, null, 1, 'FOX', getdate());
insert vipdef2 select 'D', code, descript, descript1, null, null, 1, 'FOX', getdate() from rmrate_factor;


--------------------------------------------------------------------------
-- ����� ���۴���
--------------------------------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "vippack")
   drop table vippack
;
create table vippack
(
	code			char(10)						not null,
	cat			char(10)		default ''	not null,
	descript		varchar(50)	default ''	null,
	descript1	varchar(50)	default ''	null,
	begin_		datetime						null,
	end_			datetime						null,
	rate			money			default 0	not null,
	point			int			default 0	not null,
	hotelcat		varchar(20)	default ''	not null,
	hotelid		varchar(100)	default ''	not null,   -- ???
	remark		varchar(255) default '' not null,
	halt			char(1)		default 'F'	not null,
	sequence		int			default 0	not null,
	cby			char(10)						not null,
	changed		datetime		default getdate() not null,
	logmark		int			default 0	not null
)
exec   sp_primarykey vippack, code
create unique index index1 on vippack(code)
;

--------------------------------------------------------------------------
--  basecode : vippack_item  -- �й� ��
--------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='vippack_item')
	delete basecode_cat where cat='vippack_item';
insert basecode_cat(cat,descript,descript1,len) 
	select 'vippack_item', '�����������Ŀ', 'Vipcard Packages Items', 10;
delete basecode where cat='vippack_item';
insert basecode(cat,code,descript,descript1) values('vippack_item', 'RateCode', '������', 'Rate Code');
insert basecode(cat,code,descript,descript1) values('vippack_item', 'PosMode', 'POS ģʽ', 'POS Mode');
insert basecode(cat,code,descript,descript1) values('vippack_item', 'Points', '����', 'Points');
insert basecode(cat,code,descript,descript1) values('vippack_item', 'RoomNights', '����', 'Room Nights');
insert basecode(cat,code,descript,descript1) values('vippack_item', 'SpoTimes', '���ִ���', 'SPO Times');

--------------------------------------------------------------------------
-- ����� ���۴��� ����
--------------------------------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "vippack_def")
   drop table vippack_def
;
create table vippack_def
(
	code			char(10)						not null,
	id				int			default 0	not null,
	item			char(10)						not null,   -- RateCode, PosMode, Points, RoomNights,SpoTimes, 
	value1		varchar(30)	default ''	not null,	-- ��Ŀֵ���ַ���
	value2		money			default 0	not null,	-- ��Ŀֵ��������
	begin_		datetime						null,			-- ��Ч�ڼ俪ʼ
	valid			char(10)		default ''	not null,	-- ��Ч�ڳ��� = Y1, M3, D15, 2004/12/12
	limit			varchar(100) default ''	null,			-- ����˵��
	remark		varchar(255) default ''	null,
	sequence		int			default 0	not null
)
exec   sp_primarykey vippack_def, code, id
create unique index index1 on vippack_def(code, id)
;

--------------------------------------------------------------------------
-- ����� ���۶���
--------------------------------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "vippack_set")
   drop table vippack_set
;
create table vippack_set
(
	no				char(20)						not null,	-- ����	
	code			char(10)						not null,
	id				int			default 0	not null,
	item			char(10)						not null,   -- RateCode, PosMode, Points, RoomNights,SpoTimes, 
	value1		varchar(30)	default ''	not null,	-- ��Ŀֵ���ַ���
	value2		money			default 0	not null,	-- ��Ŀֵ��������
	begin_		datetime						null,			-- ��Ч�ڼ俪ʼ
	valid			char(10)		default ''	not null,	-- ��Ч�ڳ��� = Y1, M3, D15, 2004/12/12
	limit			varchar(100) default ''	null,			-- ����˵��
	remark		varchar(255) default ''	null,
	sequence		int			default 0	not null
)
exec   sp_primarykey vippack_set, no, code, id
create unique index index1 on vippack_set(no, code, id)
;

----------------------------------------------------------------
--	���ݴ����¼ == ���� -���Ƶ�
----------------------------------------------------------------
if exists(select * from sysobjects where name = "datadown")
	drop table datadown
;
create table datadown
(
	date				datetime								not null,
	type				char(20)								not null,	-- ����	
	no					varchar(20)		default ''		not null,	-- ����(͹��),һ�����no. ������ϵͳ
	empno				char(10)			default ''		not null,	-- �޸Ĺ���  
	remark			varchar(20)							null	
)
exec sp_primarykey datadown, date, type, no
create unique index index1 on datadown(date, type, no)
create index index2 on datadown(no)
;

----------------------------------------------------------------
--	�ƿ���
----------------------------------------------------------------
if exists(select * from sysobjects where name = "vipcard_pool")
	drop table vipcard_pool
;
create table vipcard_pool
(
	type				char(10)								not null,
	pc_id				char(4)								not null,
	no					char(20)								not null
)
exec sp_primarykey vipcard_pool, type, pc_id, no
create unique index index1 on vipcard_pool(type, pc_id, no)
;

----------------------------------------------------------------
--	���ع����Զ�̼��˳���
----------------------------------------------------------------
if exists(select * from sysobjects where name = "vipcocar")
	drop table vipcocar
;
create table vipcocar
(
	id					char(10)								not null,
	cardno			char(20)								not null,	-- ���� vipcard.no
	cardtype			char(10)								not null,	-- ���� vipcard.guestcard
	cardar			char(10)								not null,	-- 		vipcard.araccnt1
	bdate				datetime								not null,
	modu_id			char(2)								not null,
	acttype			char(10)			default ''		not null,	-- �������� F(ront), B(os), P(os)
	accnt				char(10)								not null,	--	�˺�
	number			int				default 0		not null,	-- �ʴ�
	code				char(10)			default ''		not null,	-- ������� eg. bos_account
	amount			money				default 0		not null,	
	empno				char(10)			default ''		not null,	-- ��������
	shift				char(1)			default ''		not null,
	log_date			datetime								null,			-- ����ʱ��
	sendout			char(1)			default 'F'		not null,	-- �Ѿ�������ͬ����
	sendby			char(10)			default ''		not null,
	sendshift		char(1)			default ''		not null,
	sendtime			datetime								null
)
exec sp_primarykey vipcocar,id
create unique index index1 on vipcocar(id)
create unique index index2 on vipcocar(cardno,cardtype,acttype,accnt,number,code)
;


----------------------------------------------------------------
--	�������У�ת�˼�¼
----------------------------------------------------------------
if exists(select * from sysobjects where name = "vipcard_tranlog")
	drop table vipcard_tranlog
;
create table vipcard_tranlog
(
	no					varchar(20)		default ''		not null,
	number			int				default 0		not null,
	no1				varchar(20)		default ''		not null,
	number1			int				default 0		not null,
	empno				char(10)			default ''		not null,
	logdate			datetime								not null
)
exec sp_primarykey vipcard_tranlog, no, number
create unique index index1 on vipcard_tranlog(no, number)
;
