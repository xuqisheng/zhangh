// --------------------------------------------------------------------------
//	�ͷ�������� ��
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
//		basecode:		rmmaint_reason, ocsta, hall, hsregion, feature, amenities
//							sw_class, sw_grade, sw_sta, hs_empno
//
//		table:			hs_sysdata, hs_mapparm				- �ͷ�����ϵͳ��������
//							flrcode, typim, rmsta, rmsta_till, rmsta_last, rmsta_log,
//							rmstalist, rmstalist1, rmstamap, gtype, 
//							checkroom, checkroomset				- �鷿
//							discrepant_room, room_input		- ì�ܷ�
//							hsmap_term, hsmap_term_end			- �ͻ��˿ͷ���̬ѡ�񣨷�̬����̬����
//							rm_ooo, hrm_ooo, rm_ooo_log		- ά�޷�
//							rmtmpsta, hrmtmpsta					- ��ʱ̬
//							hs_mapclr, hsmapsel					- ��̬����
//							hsmap, hsmap_des, hsmap_bu			- ��̬��2
//							attendant_allot						- �ͷ�������������ʱ��
//							hsmap_new								- ��̬��5��һ����ʱ�� 
//							hsmap_project							- ��̬��5��ɫ�����÷����ı��sysoption�����
//							hall_station 
// --------------------------------------------------------------------------


// --------------------------------------------------------------------------
//  basecode : rmmaint_reason	�ͷ�ά��ԭ��
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='rmmaint_reason')
	delete basecode_cat where cat='rmmaint_reason';
insert basecode_cat select 'rmmaint_reason', '�ͷ�ά��ԭ��', 'Room Maintn Reason', 3;
delete basecode where cat='rmmaint_reason';
insert basecode(cat,code,descript,descript1) select 'rmmaint_reason', 'WAT', 'ȱˮ', 'No Water';
insert basecode(cat,code,descript,descript1) select 'rmmaint_reason', 'ELE', '�޵�', 'No Electricity';
insert basecode(cat,code,descript,descript1) select 'rmmaint_reason', 'TEL', '�绰��', 'Phone Error';
insert basecode(cat,code,descript,descript1) select 'rmmaint_reason', 'MIN',  '�ưɻ�', 'MiniBar Error';


// --------------------------------------------------------------------------
//  basecode : ocsta
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='ocsta')
	delete basecode_cat where cat='ocsta';
insert basecode_cat select 'ocsta', '�ͷ�ռ��״̬', 'Room Occ. Status', 1;

delete basecode where cat='ocsta';
insert basecode(cat,code,descript,descript1,sys) select 'ocsta', 'O', 'Occ', 'Occ', 'T';
insert basecode(cat,code,descript,descript1,sys) select 'ocsta', 'V', 'Vac', 'Vac', 'T';


// --------------------------------------------------------------------------
//  basecode : hall
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='hall')
	delete basecode_cat where cat='hall';
insert basecode_cat select 'hall', '¥��', 'Room Building', 1;

delete basecode where cat='hall';
insert basecode(cat,code,descript,descript1) select 'hall', '0', '��¥', 'Main Building';


// --------------------------------------------------------------------------
//  basecode : rmtag	 �����־
// --------------------------------------------------------------------------
update basecode set sys='F' where cat='rmtag';
delete basecode where cat='rmtag';
delete basecode_cat where cat='rmtag';
insert basecode_cat(cat,descript,descript1,len) select 'rmtag', '�����־', 'Room Flag', 1;
INSERT INTO basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) VALUES ('rmtag','K','�ͷ�','Guest Room','T','F',100,'','F');
INSERT INTO basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) VALUES ('rmtag','B','�칫','Office Room1','T','F',200,'','F');
INSERT INTO basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) VALUES ('rmtag','X','д�ּ�','Office Room2','T','F',300,'','F');
INSERT INTO basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) VALUES ('rmtag','G','��Ԣ','mansion','T','F',400,'','F');
INSERT INTO basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) VALUES ('rmtag','P','�ٷ�','Pseudo','T','F',900,'','F');


// --------------------------------------------------------------------
//	Reservation code : gtype
// --------------------------------------------------------------------
if exists(select 1 from sysobjects where name='gtype' and type='U')
   drop table gtype;
create table gtype
(
   code				char(3)						not null,
   descript			varchar(30)					not null,
   descript1		varchar(30)	default ''	not null,
	tag				char(1)		default 'K'	not null,
	halt				char(1)		default 'F'	not null,
	cby				char(10)		default '' not null,
	changed			datetime		default getdate() not null, 
	sequence			int			default 0	not null
)
exec sp_primarykey gtype,code
create unique index index1 on gtype(code)
;
insert gtype(code,descript,descript1) select 'SIN', '���˼�', 'Single';
insert gtype(code,descript,descript1) select 'DOU', '˫�˼�', 'Double';
insert gtype(code,descript,descript1) select 'SUT', '�׼�', 'Suite';


// --------------------------------------------------------------------------
//  basecode : room region
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='hsregion')
	delete basecode_cat where cat='hsregion';
insert basecode_cat select 'hsregion', '�ͷ�����', 'Room Region', 3;

delete basecode where cat='hsregion';
insert basecode(cat,code,descript,descript1) select 'hsregion', '0', '�ͷ�����', 'Room Region';


// --------------------------------------------------------------------------
//  basecode : feature
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='feature')
	delete basecode_cat where cat='feature';
insert basecode_cat select 'feature', '�ͷ�����', 'Room Feature', 3;

delete basecode where cat='feature';
insert basecode(cat,code,descript,descript1) select 'feature', 'NS', '���̷�', 'No Smoking';
insert basecode(cat,code,descript,descript1) select 'feature', 'SM', '���̷�', 'Smoking';
insert basecode(cat,code,descript,descript1) select 'feature', 'SS', '��ԡ', 'Stand Shower';
insert basecode(cat,code,descript,descript1) select 'feature', 'CV', '�Ǿ���', 'City View';
insert basecode(cat,code,descript,descript1) select 'feature', 'LV', '������', 'Lake View';
insert basecode(cat,code,descript,descript1) select 'feature', 'CN', '��ͨ��', 'Connecting Room';
insert basecode(cat,code,descript,descript1) select 'feature', 'BT', 'ԡ��', 'Bidet';
insert basecode(cat,code,descript,descript1) select 'feature', 'ADS', '�����', 'VOD & ADSL System';
insert basecode(cat,code,descript,descript1) select 'feature', 'HDC', '�м���', 'Handicap';


// --------------------------------------------------------------------------
//  basecode : expend
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='expend')
	delete basecode_cat where cat='expend';
insert basecode_cat select 'expend', '����Ʒ', 'Room Expend', 3;

delete basecode where cat='expend';
insert basecode(cat,code,descript,descript1) select 'expend', '101', '����', 't';
insert basecode(cat,code,descript,descript1) select 'expend', '102', '��Ь', 't';
insert basecode(cat,code,descript,descript1) select 'expend', '103', '����', 't';
insert basecode(cat,code,descript,descript1) select 'expend', '104', 'ԡñ', 't';


// --------------------------------------------------------------------------
//  basecode : jifen		��������
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='jifen')
	delete basecode_cat where cat='jifen';
insert basecode_cat select 'jifen', '������', 'Hswk Credit', 10;
delete basecode where cat='jifen';


// --------------------------------------------------------------------------
//  basecode : jineng	��ɨ����
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='jineng')
	delete basecode_cat where cat='jineng';
insert basecode_cat select 'jineng', '����ֵ', 'Room Capability', 10;
delete basecode where cat='jineng';


// --------------------------------------------------------------------------
//  basecode : amenities
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='amenities')
	delete basecode_cat where cat='amenities';
insert basecode_cat select 'amenities', '�ͷ�����', 'Room amenities', 3;

delete basecode where cat='amenities';
insert basecode(cat,code,descript,descript1) select 'amenities', 'SS', '��ԡ', 'Stand Shower';
insert basecode(cat,code,descript,descript1) select 'amenities', 'BT', 'ԡ��', 'Bidet';
insert basecode(cat,code,descript,descript1) select 'amenities', 'ADS', '�����', 'VOD & ADSL System';
insert basecode(cat,code,descript,descript1) select 'amenities', 'FLR', '�ʻ�', 'Flower';
insert basecode(cat,code,descript,descript1) select 'amenities', 'FRT', 'ˮ��', 'Fruit';
insert basecode(cat,code,descript,descript1) select 'amenities', 'DIR', '�й��ձ�', 'China Diary';


// --------------------------------------------------------------------------
//  basecode : sw_grade	ʧ��ȼ�
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='sw_grade')
	delete basecode_cat where cat='sw_grade';
insert basecode_cat select 'sw_grade', 'ʧ��ȼ�', 'Lostings Grade', 1;
delete basecode where cat='sw_grade';

// --------------------------------------------------------------------------
//  basecode : sw_class	ʧ�����
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='sw_class')
	delete basecode_cat where cat='sw_class';
insert basecode_cat select 'sw_class', 'ʧ�����', 'Lostings Class', 1;
delete basecode where cat='sw_class';

// --------------------------------------------------------------------------
//  basecode : sw_sta	ʧ��״̬
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='sw_sta')
	delete basecode_cat where cat='sw_sta';
insert basecode_cat select 'sw_sta', 'ʧ��״̬', 'Lostings Status', 1;
delete basecode where cat='sw_sta';


//------------------------------------------------------------------------------
//		�ͷ�����ϵ�в�����
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'hs_sysdata')
	drop table hs_sysdata
;
create table  hs_sysdata(
	mapcode		varchar(10)		not null,  	// �ͷ����ķ�̬��������
	mbbase		numeric(10,0)	not null,	// �������¿���MINI���ʺ� 
	xhbase		numeric(10,0)	not null,	// �������¿��������ʺ� 
	sbbase		numeric(10,0)	not null,	// �������¿����豸�ʺ� 
	xybase		numeric(10,0)	not null,	// �������¿���ϴ���ʺ� 
	oobase		numeric(10,0)	not null,	// �������¿���ά���ʺ� 
	swbase		numeric(10,0)	not null,	// �������¿���ʧ���ʺ� 
	pcbase		numeric(10,0)	not null,	// �������¿����⳥�ʺ� 
	habase		numeric(10,0)	not null,	// �������¿���HA�ʺ� 
	hbbase		numeric(10,0)	not null,	// �������¿���HB�ʺ� 
	hcbase		numeric(10,0)	not null,	// �������¿���HC�ʺ� 
	mbstart		char(1) default 'F' not null,	// MB is running ?
	hstime1		datetime			null,			// Ԥ��
	hstime2		datetime			null,			// Ԥ��
	hstime3		datetime			null,			// Ԥ��
	hstime4		datetime			null			// Ԥ��
)
;

//declare @bdate datetime
//select @bdate = bdate1 from sysdata
//insert hs_sysdata values(	
//			'XR',
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			'F',
//			null,
//			null,
//			null,
//			null
//		   );
//
//select * from hs_sysdata;



//------------------------------------------------------------------------------
//		�ͷ����ķ�̬�����ò���
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'hs_mapparm')
	drop table hs_mapparm
;
create table  hs_mapparm (
	code			varchar(10)	not null,				
	rownum		int	default 0 not null,
	colnum		int	default 0 not null,
	rowspacing	int	default 0 not null,
	colspacing	int	default 0 not null,	
	width			int	default 0 not null,
	height		int	default 0 not null,
	zoom			int	default 0 not null,
	baseclr		money	default 0 not null,	// ����ɫ
	clsclr1		money	default 0 not null,	// ���ɫ 1-8
	clsclr2		money	default 0 not null,
	clsclr3		money	default 0 not null,
	clsclr4		money	default 0 not null,
	clsclr5		money	default 0 not null,
	clsclr6		money	default 0 not null,
	clsclr7		money	default 0 not null,
	clsclr8		money	default 0 not null,
	addclr1		money	default 0 not null,	// ����ɫ1-3
	addclr2		money	default 0 not null,
	addclr3		money	default 0 not null,
	maptip		int	default 16 not null	// 
)
exec sp_primarykey hs_mapparm, code
create unique index code on hs_mapparm(code)
;

//insert hs_mapparm
//	select 'XR', 11, 11, 100, 100, 1500, 800, 100, 
//	 	12639424,
//		32768,
//		8388608,
//		128,
//		32896,
//		16711680,
//		8388736,
//		65535,
//	 	12639424,
//		255,
//		15780518,    // 8421376
//		65280,
//		16;
//select * from hs_mapparm;

//   --------------------------  end ---------------------------------------------

// --------------------------------------------------------------------
//	Reservation code : flrcode
// --------------------------------------------------------------------
if exists(select 1 from sysobjects where name='flrcode' and type='U')
   drop table flrcode;
create table flrcode
(
   code				char(3)						not null,
   descript			varchar(30)					not null,
   descript1		varchar(30)	default ''	not null,
	ground_plan		varchar(60)	default ''	not null,	// ƽ��ͼ
	halt				char(1)		default 'F' not null,
	cby				char(10)		default 'FOX' not null,
	changed			datetime		default getdate() not null, 
	sequence			int			default 0	not null
)
exec sp_primarykey flrcode,code
create unique index index1 on flrcode(code)
;
//insert flrcode select *, 0 from aa_flrcode;


// --------------------------------------------------------------------------
//	Reservation code : type
// --------------------------------------------------------------------------
if exists(select 1 from sysobjects where name='typim' and type='U')
   drop table typim;
create table typim
(
   type			char(5)						not null,
   descript		char(60)						not null,
   descript1	char(60)		default ''	not null,
   descript2	char(60)		default ''	not null,
   descript3	char(60)		default ''	not null,
   descript4	char(60)		default ''	not null,
   quantity		int			default 0	not null,
   overquan		int			default 0	not null,
   futdate		datetime	      			null,
   adjquan		int			default 0   not null,
	ratecode		char(10)		default ''	not null,
   rate			money			default 0	not null,
   futrate		money			default 0	not null,
   begin_		datetime						null	,
	hotelcode	char(10)		default ''	not null,	// �Ƶ����
	sequence		int			default 0	not null,
	gtype			char(3)						not null,  	// ����
	tag			char(1)		default 'K'	not null,
	internal		int			default 0 	not null,	// �ڲ���
	yieldable	char(1)		default 'F'	not null,	// ���Ʋ���
	yieldcat		char(3)		default ''	not null,
	crsthr		int			default 0	not null,	// ȫ��Ԥ��
	crsper		int			default 0	not null,
	pic			varchar(60)	default ''	not null,
	halt				char(1)		default 'F' not null,
	cby				char(10)		default 'FOX' not null,
	changed			datetime		default getdate() not null
)
exec sp_primarykey typim,type
create unique index index1 on typim(type)
;
//insert typim(type,descript,quantity,overquan,futdate,adjquan,rate,futrate,begin_,gtype)
//	select type,descript,quantity,overquan,futdate,adjquan,rate,futrate,begin_,'' from aa_typim;



// --------------------------------------------------------------------
//	Reservation code : rmsta, rmsta_till, rmsta_last, rmsta_log
//
// 		������� 8 �ַ�̬: 	CL = Clean					VR
//										DI = Dirty					VD
//										IS = Inspected				VI
//										TU = Touch Up				VT
//
//										OO = Out of Order			VM
//										OS = Out of Service		VL
//
//										OC = Occupy Clean			OR
//										OD = Occupy Dirty			OD
// --------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'rmsta' and type='U')
   drop table rmsta;
create table rmsta
(
   roomno		char(5)				    not null,
   oroomno		char(5)	default ''   not null,	//	�ڲ�����
	hall			char(1)					 not null,	// ¥��
	flr			char(3)					 not null,	// ¥��
   rmreg		   char(3)	default ''   not null,	// �ͷ�����
   type		   char(5)				    not null,
	tag			char(1)	default 'K'	 not null,
   ocsta		   char(1)	default 'V'	 not null,
   oldsta		char(1)	default 'R'	 not null,
   sta			char(1)	default 'R'	 not null,
   tmpsta		char(1)	default ''	 not null,	// ��ʱ̬
   people		int		default 1    not null,
   bedno		   int		default 0    not null,
   special		char(1)	default 'F'  not null,	// ���ⷿ��
   ratecode	   char(10)	default ''	 not null,
   rate		   money		default 0    not null,
   feature		varchar(50)	default ''	not null,	// �ͷ�����
   locked		char(1)	default 'N'	 not null,	// ����
   futsta		char(1)	default ''   not null,	// δ����̬
   futbegin	   datetime			       null,
   futend		datetime			       null,
   fcdate      datetime              null,
   fempno      char(10)               null,
   onumber		int	   default 0	 null,
   number		int	   default 0	 null,
   accntset	   char(70)	default ''   null,
   futmark		char(1)	default 'F'  not null,	// Ԥ���־
   futdate		datetime		          null,		// ��������
   empty_days  int      default 0    not null,		// ?
	x				int		default 0	 not null,
	y				int		default 0	 not null,
	width			int		default 0	 not null,
	height		int		default 0	 not null,
	s1				char(3)	default ''	 not null,	// Ԥ���ֶ�
	s2				char(3)	default ''	 not null,
	s3				char(3)	default ''	 not null,
	s4				char(3)	default ''	 not null,
	n1				int		default 0	 not null,
	n2				int		default 0	 not null,
	n3				int		default 0	 not null,
	n4				int		default 0	 not null,
	ref			varchar(50)	default ''	null,		// ˵��
	sequence		int		default 0	not null,
   empno		   char(10)				    not null,
   changed		datetime	default getdate()	not null,
   logmark     int      default 0	 not null
)
exec   sp_primarykey rmsta,roomno
create unique clustered index index1 on rmsta(roomno)
create unique index index2 on rmsta(oroomno)
create index index3 on rmsta(type)
create index index4 on rmsta(locked,type)
create index index5 on rmsta(changed)
create index index6 on rmsta(flr)
;
//insert rmsta
//  SELECT roomno,oroomno,hall,flr,f4,type,ocsta,oldsta,sta,f5,people,bedno,special,'',rate,'',
//	locked,futsta,futbegin,futend,fcdate,fempno,onumber,number,accntset,futmark,futdate,
//	isnull(empty_days,0),x,y,width,height,'','','','',0,0,0,0,ref,0,empno,cdate,logmark
//    from  aa_rmsta;
//update rmsta set tmpsta='' where tmpsta='E';

if exists (select 1 from sysobjects where name = 'rmsta_till' and type='U')
   drop table rmsta_till;
create table rmsta_till
(
   roomno		char(5)				    not null,
   oroomno		char(5)	default ''   not null,	//	�ڲ�����
	hall			char(1)					 not null,	// ¥��
	flr			char(3)					 not null,	// ¥��
   rmreg		   char(3)	default ''   not null,	// �ͷ�����
   type		   char(5)				    not null,
	tag			char(1)	default 'K'	 not null,
   ocsta		   char(1)	default 'V'	 not null,
   oldsta		char(1)	default 'R'	 not null,
   sta			char(1)	default 'R'	 not null,
   tmpsta		char(1)	default ''	 not null,	// ��ʱ̬
   people		int		default 1    not null,
   bedno		   int		default 0    not null,
   special		char(1)	default 'F'  not null,	// ���ⷿ��
   ratecode	   char(10)	default ''	 not null,
   rate		   money		default 0    not null,
   feature		varchar(50)	default ''	not null,	// �ͷ�����
   locked		char(1)	default 'N'	 not null,	// ����
   futsta		char(1)	default ''   not null,	// δ����̬
   futbegin	   datetime			       null,
   futend		datetime			       null,
   fcdate      datetime              null,
   fempno      char(10)               null,
   onumber		int	   default 0	 null,
   number		int	   default 0	 null,
   accntset	   char(70)	default ''   null,
   futmark		char(1)	default 'F'  not null,	// Ԥ���־
   futdate		datetime		          null,		// ��������
   empty_days  int      default 0    not null,		// ?
	x				int		default 0	 not null,
	y				int		default 0	 not null,
	width			int		default 0	 not null,
	height		int		default 0	 not null,
	s1				char(3)	default ''	 not null,	// Ԥ���ֶ�
	s2				char(3)	default ''	 not null,
	s3				char(3)	default ''	 not null,
	s4				char(3)	default ''	 not null,
	n1				int		default 0	 not null,
	n2				int		default 0	 not null,
	n3				int		default 0	 not null,
	n4				int		default 0	 not null,
	ref			varchar(50)	default ''	null,		// ˵��
	sequence		int		default 0	not null,
   empno		   char(10)				    not null,
   changed		datetime	default getdate()	not null,
   logmark     int      default 0	 not null
)
exec   sp_primarykey rmsta_till,roomno
create unique clustered index index1 on rmsta_till(roomno)
create unique index index2 on rmsta_till(oroomno)
create index index3 on rmsta_till(type)
create index index4 on rmsta_till(locked,type)
create index index5 on rmsta_till(changed)
create index index6 on rmsta_till(flr)
;

if exists (select 1 from sysobjects where name = 'rmsta_last' and type='U')
   drop table rmsta_last;
create table rmsta_last
(
   roomno		char(5)				    not null,
   oroomno		char(5)	default ''   not null,	//	�ڲ�����
	hall			char(1)					 not null,	// ¥��
	flr			char(3)					 not null,	// ¥��
   rmreg		   char(3)	default ''   not null,	// �ͷ�����
   type		   char(5)				    not null,
	tag			char(1)	default 'K'	 not null,
   ocsta		   char(1)	default 'V'	 not null,
   oldsta		char(1)	default 'R'	 not null,
   sta			char(1)	default 'R'	 not null,
   tmpsta		char(1)	default ''	 not null,	// ��ʱ̬
   people		int		default 1    not null,
   bedno		   int		default 0    not null,
   special		char(1)	default 'F'  not null,	// ���ⷿ��
   ratecode	   char(10)	default ''	 not null,
   rate		   money		default 0    not null,
   feature		varchar(50)	default ''	not null,	// �ͷ�����
   locked		char(1)	default 'N'	 not null,	// ����
   futsta		char(1)	default ''   not null,	// δ����̬
   futbegin	   datetime			       null,
   futend		datetime			       null,
   fcdate      datetime              null,
   fempno      char(10)               null,
   onumber		int	   default 0	 null,
   number		int	   default 0	 null,
   accntset	   char(70)	default ''   null,
   futmark		char(1)	default 'F'  not null,	// Ԥ���־
   futdate		datetime		          null,		// ��������
   empty_days  int      default 0    not null,		// ?
	x				int		default 0	 not null,
	y				int		default 0	 not null,
	width			int		default 0	 not null,
	height		int		default 0	 not null,
	s1				char(3)	default ''	 not null,	// Ԥ���ֶ�
	s2				char(3)	default ''	 not null,
	s3				char(3)	default ''	 not null,
	s4				char(3)	default ''	 not null,
	n1				int		default 0	 not null,
	n2				int		default 0	 not null,
	n3				int		default 0	 not null,
	n4				int		default 0	 not null,
	ref			varchar(50)	default ''	null,		// ˵��
	sequence		int		default 0	not null,
   empno		   char(10)				    not null,
   changed		datetime	default getdate()	not null,
   logmark     int      default 0	 not null
)
exec   sp_primarykey rmsta_last,roomno
create unique clustered index index1 on rmsta_last(roomno)
create unique index index2 on rmsta_last(oroomno)
create index index3 on rmsta_last(type)
create index index4 on rmsta_last(locked,type)
create index index5 on rmsta_last(changed)
create index index6 on rmsta_last(flr)
;


if exists (select 1 from sysobjects where name = 'rmsta_log' and type='U')
   drop table rmsta_log;
create table rmsta_log
(
   roomno		char(5)				    not null,
   oroomno		char(5)	default ''   not null,	//	�ڲ�����
	hall			char(1)					 not null,	// ¥��
	flr			char(3)					 not null,	// ¥��
   rmreg		   char(3)	default ''   not null,	// �ͷ�����
   type		   char(5)				    not null,
	tag			char(1)	default 'K'	 not null,
   ocsta		   char(1)	default 'V'	 not null,
   oldsta		char(1)	default 'R'	 not null,
   sta			char(1)	default 'R'	 not null,
   tmpsta		char(1)	default ''	 not null,	// ��ʱ̬
   people		int		default 1    not null,
   bedno		   int		default 0    not null,
   special		char(1)	default 'F'  not null,	// ���ⷿ��
   ratecode	   char(10)	default ''	 not null,
   rate		   money		default 0    not null,
   feature		varchar(50)	default ''	not null,	// �ͷ�����
   locked		char(1)	default 'N'	 not null,	// ����
   futsta		char(1)	default ''   not null,	// δ����̬
   futbegin	   datetime			       null,
   futend		datetime			       null,
   fcdate      datetime              null,
   fempno      char(10)               null,
   onumber		int	   default 0	 null,
   number		int	   default 0	 null,
   accntset	   char(70)	default ''   null,
   futmark		char(1)	default 'F'  not null,	// Ԥ���־
   futdate		datetime		          null,		// ��������
   empty_days  int      default 0    not null,		// ?
	x				int		default 0	 not null,
	y				int		default 0	 not null,
	width			int		default 0	 not null,
	height		int		default 0	 not null,
	s1				char(3)	default ''	 not null,	// Ԥ���ֶ�
	s2				char(3)	default ''	 not null,
	s3				char(3)	default ''	 not null,
	s4				char(3)	default ''	 not null,
	n1				int		default 0	 not null,
	n2				int		default 0	 not null,
	n3				int		default 0	 not null,
	n4				int		default 0	 not null,
	ref			varchar(50)	default ''	null,		// ˵��
	sequence		int		default 0	not null,
   empno		   char(10)				    not null,
   changed		datetime	default getdate()	not null,
   logmark     int      default 0	 not null
)
exec   sp_primarykey rmsta_log,roomno,logmark
create unique clustered index index1 on rmsta_log(roomno,logmark)
;



// --------------------------------------------------------------------
//	Reservation rmstalist : ����״̬��,���л�δ��ÿ�������״̬
// --------------------------------------------------------------------
if exists(select * from sysobjects where name = "rmstalist" and type='U')
	drop table rmstalist;
create table rmstalist
(
   sta 		   char(1)     			not null,		/* ״̬�� */
   descript    char(8)     			not null,		/* ����   */
   descript1   char(12) default ''	not null,		/* ����   */
   maintnmark  char(1)  default 'F'	not null,		/* �Ƿ�ά���� */
   instready  	char(1)  default 'T'	not null,		/* �Ƿ����á���Ҫ��� I, T */
	sequence		int		default 0	not null
)
exec sp_primarykey rmstalist,sta
create unique clustered index rmstalist on rmstalist(sta)
;
insert into rmstalist values ('R','�ɾ�','Clean','F', 'T', 10)
insert into rmstalist values ('D','�෿','Dirty','F', 'T', 20)
insert into rmstalist values ('I','���','Inspected','F', 'T', 30)
insert into rmstalist values ('T','Touch-Up','Touch-Up','F', 'T', 40)

insert into rmstalist values ('S','����','Lock','T', 'T', 50)
insert into rmstalist values ('O','ά��','Maint','T', 'T', 60)
;


// --------------------------------------------------------------------
//	Reservation rmstalist1 : �ͷ���ʱ״̬��
// --------------------------------------------------------------------
if exists(select * from sysobjects where name = "rmstalist1" and type='U')
	drop table rmstalist1;
create table rmstalist1
(
   code 		   char(1)     			not null,
	cat			char(1)					not null,	// ���: G-ǰ̨����  H-�ͷ���������
   descript    char(20)     			not null,
   descript1   char(30) default ''	not null,
	color			int		default 255	not null,
	rlock			char(1) 	default 'F' not null,	// ��ֹԤ��
	ilock			char(1) 	default 'F' not null,	// ��ֹ��ס
	sequence		int		default 0	not null,
	halt			char(1) 	default 'F' not null,
	cby			char(10) default 'FOX' not null,
	changed		datetime	default getdate() not null 
)
exec sp_primarykey rmstalist1,code
create unique clustered index rmstalist1 on rmstalist1(code)
;
insert into rmstalist1(code,cat,descript,descript1,color) values ('A','H','ì�ܷ�','Problem',255)
insert into rmstalist1(code,cat,descript,descript1,color) values ('B','G','�ι۷�','Visit',65535)
insert into rmstalist1(code,cat,descript,descript1,color) values ('C','H','�쵼��','Leader',65280)
insert into rmstalist1(code,cat,descript,descript1,color) values ('D','H','������','No bag',8388736)
insert into rmstalist1(code,cat,descript,descript1,color) values ('E','H','Ԥ  ��','Reservation',16711935)
;



// --------------------------------------------------------------------
//	Reservation rmstamap : ״̬���ձ�
// --------------------------------------------------------------------
if exists(select * from sysobjects where name = "rmstamap")
   drop table rmstamap;
create table rmstamap
(
	code		   char(2)	not null,
	eccocode    char(3)  not null	  // �����ݿ����Զ���
)
exec sp_primarykey rmstamap,code,eccocode
create unique clustered index index1 on rmstamap(code,eccocode)
;
insert rmstamap values ('VR','CL')
insert rmstamap values ('VD','DI')
insert rmstamap values ('VT','TU')
insert rmstamap values ('VI','IS')
insert rmstamap values ('VO','OO')
insert rmstamap values ('VS','OS')

insert rmstamap values ('OD','OD')
insert rmstamap values ('OR','OC')
insert rmstamap values ('OT','OC')
insert rmstamap values ('OI','OC')
insert rmstamap values ('OO','OC')
insert rmstamap values ('OS','OC')
;


// --------------------------------------------------------------------------
//  basecode : hs_empno
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='hs_empno')
	delete basecode_cat where cat='hs_empno';
insert basecode_cat select 'hs_empno', '�ͷ�����Ա��', 'HSK Employee', 10;
delete basecode where cat='hs_empno';
insert basecode(cat,code,descript,descript1) select 'hs_empno', 'KITTY', 'KITTY','KITTY';
insert basecode(cat,code,descript,descript1) select 'hs_empno', 'MARRY', 'MARRY','MARRY';
insert basecode(cat,code,descript,descript1) select 'hs_empno', 'JONE', 'JONE','JONE';
insert basecode(cat,code,descript,descript1) select 'hs_empno', 'MIKE',  'MIKE', 'MIKE';

//---------------------------------------------------------------
//	�ͷ�������������ʱ��
//---------------------------------------------------------------
if exists(select 1 from sysobjects where name='attendant_allot' and type='U')
	drop table attendant_allot;
create table attendant_allot(
			cdate			datetime					not null,
			empno			char(10)					null,
			attendant	integer					null,
			hall			char(1)					null,
			flr			char(3)					null,
			roomno 		char(5)					null,
			status		char(4)					null,
			people		integer	default 0	null,
			vip			char(3)					null,	
			credits		money		default 0	null
);
exec sp_primarykey attendant_allot,roomno;
create unique index index1 on attendant_allot(attendant,roomno);

//====================================================================
//����һ����̬��5��һ����ʱ�� 
//write by wz at 2003.07.01 
//====================================================================
drop table hsmap_new ;
create table hsmap_new (
	modu_id		char(2)						not null,
	pc_id			char(4)						not null,
	roomno		char(5)						not null,
	flr			char(3)						not null,
	type			char(5)						not null,
	ocsta			char(1)	default 'V' 	not null,
	sta			char(1)	default 'R' 	not null,
	main			char(3)	default ''		not null,
	ea				int		default 0		not null,
	ed				int		default 0		not null,
	flag			varchar(10)	default '' 	not null,
	limit			int		default 0 		not null,
	gstno			int		default 0		not null,
	tmpsta		char(1)	default ''			 null,
	groupno		char(10)	default ''		    null,
	extra			char(15)	default ''		    null,
	dep			datetime						not null,
	addbed		money		default 0  	not null,
	rate			money		default 0 		not null,
	phonesta		char(1)	default '0' 	not null,
	vsta			integer	default 1		not null,
	ar1			char(2)	default '' 		not null,
	ar2			char(2)	default '' 		not null
)
;
exec sp_primarykey hsmap_new,roomno;
create unique index index2 on hsmap_new(modu_id,pc_id,roomno);

//====================================================================
// ��̬��5�����ı��sysoption�����
//====================================================================
drop table hsmap_project;
create table hsmap_project(
			project		varchar(10)		         not null,
			colnum		integer	default 0		not null,
			rowspac		integer	default 0		not null,
			colspac 		integer 	default 0		not null,
			width			integer	default 0		not null,
			height		integer	default 0		not null,
			zoom			integer	default 0		not null,
			clr_d			money		default 0		not null,
			clr_m			money		default 0		not null,
			clr_v			money		default 0		not null,
			clr_o			money		default 0		not null,
			dw				varchar(30)	default ''  not null
);
//init
insert hsmap_project
	select 'STANDARD',8,18,18,440,288,100,8421504,65535,12639424,9830364,'d_wz_house_map_standard';
//insert sysoption select 'house','project','STANDARD','' ;

// ------------------------------------------------
//  �鷿��
// ------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "checkroom")
	drop table checkroom
;
create table checkroom
(
	type			char(1)	default '1' not null,					/* ҵ������
																					1.�鷿 */
	pc_id			char(4)	default ''	not null,					/* IP��ַ */
	roomno		char(5)	default ''  not null,					/* ���� */
	accnt			char(10)	default ''  null,							/* �˺� */
	sta			char(1)	default '0' not null,					/* ҵ�����
																					0.��̨����鷿
																					1.�ͷ����Ĳ鷿
																					9.�鷿��� */
	empno1		char(10)	default ''	null,							/* ���빤�� */
	date1			datetime	default getdate() not null,			/* ����ʱ�� */
	empno2		char(10)	default ''	null,							/* �𸴹��� */
	date2			datetime	null,											/* ��ʱ�� */
	empno3		char(10)	default ''	null,							/* ��ɹ��� */
	date3			datetime	null,											/* ���ʱ�� */
	refer			varchar(100)	default ''	null					/* ��ע */
)
exec sp_primarykey checkroom, type, pc_id, roomno
create index index1 on checkroom(type, pc_id, roomno)
;

// ------------------------------------------------
// ���Ʋ鷿, ������Ϣ�ĵĹ���վ��ʾ
// ------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "checkroomset")
	drop table checkroomset
;
create table checkroomset
(
	rcid		char(4)		not null,
	type		varchar(255)	 default '' not null,  	// ����
	sdid		varchar(100) default '' not null,  		// �ձ�ʾ����
	halt			char(1) 	default 'F' not null,
	cby			char(10) default 'FOX' not null,
	changed		datetime	default getdate() not null 
)
exec sp_primarykey checkroomset, rcid
create index index1 on checkroomset(rcid)
;

-------------------------------------------------------------------------------
--	Discrepant Room  -- ì�ܷ�
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "discrepant_room" and type = 'U')
	drop table discrepant_room;
create table discrepant_room
(
	id			int			default 0			not null,
	sta		char(1)		default 'I'			not null,	   -- I, X
	roomno	char(5)								not null,
	hs_sta	char(1)								not null,
	fo_sta	char(1)								not null,
	remark	varchar(50)	default ''			not null,
	crtby		char(10)		default ''			not null,      -- ����
   crttime	datetime		default getdate() not null,		-- ��������       
	cby		char(10)		default ''			not null,      -- �޸�
   changed	datetime		default 				null				
)
exec sp_primarykey discrepant_room,id
create unique index index1 on discrepant_room(id)
create index index2 on discrepant_room(roomno,sta)
create index index3 on discrepant_room(cby)
create index index4 on discrepant_room(crttime)
;

-------------------------------------------------------------------------------
--	room_input  -- ����¼��
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "room_input" and type = 'U')
	drop table room_input;
create table room_input
(
	logdate	datetime		default getdate() not null,		-- ��������
	roomno	char(5)								not null,
	ocsta		char(1)								not null,	   -- V, O, M-ά��, S-����
	empno		char(10)		default ''			not null,      -- ����Ա��
	crtby		char(10)		default ''			not null,      -- ����
	id			int			default 0			not null,		-- ì�ܷ���¼����
)
exec sp_primarykey room_input,logdate,roomno
create unique index index1 on room_input(logdate,roomno)
create index index2 on room_input(roomno)
;


// --------------------------------------------------------------------
// �ͻ��˿ͷ���̬ѡ��
//		Ӧ�� : ��̬�� ��̬�޸�
// --------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'hsmap_term')
	drop table hsmap_term
;
create table hsmap_term (
	code			char(2)							not null,
	cat			char(1)							not null,	// 1-��̬�� 2-��̬�޸�
	descript		varchar(30)						not null,
	descript1	varchar(40)		default ''	not null,
	term			varchar(255)					not null,	// ��������
	sequence		int				default 0	not null
)
exec sp_primarykey hsmap_term, code
create unique index index1 on hsmap_term(code)
;
insert hsmap_term(cat,code,descript,term) select "1", "A1", "OCC", 	"select roomno from rmsta where ocsta='O'"
insert hsmap_term(cat,code,descript,term) select "1", "A2", "VC", 	"select roomno from rmsta where ocsta='V' and sta='R'"
insert hsmap_term(cat,code,descript,term) select "1", "A3", "VD", 	"select roomno from rmsta where ocsta='V' and sta='D'"
insert hsmap_term(cat,code,descript,term) select "1", "A4", "OOO", 	"select roomno from rmsta where ocsta='V' and sta in ('O','S')"
insert hsmap_term(cat,code,descript,term) select "1", "A5", "������", "select roomno from rmsta where bedno=1"
insert hsmap_term(cat,code,descript,term) select "1", "A6", "˫����", "select roomno from rmsta where bedno=2"
insert hsmap_term(cat,code,descript,term) select "1", "A8", "��ʱ̬", "select roomno from rmsta where not (tmpsta='E' or tmpsta='')"

insert hsmap_term(cat,code,descript,term) select "1", "B1", "���÷�", "select roomno from master where sta='I' and class='Z'"
insert hsmap_term(cat,code,descript,term) select "1", "B2", "������", "select roomno from master where sta='I' and class='L'"
insert hsmap_term(cat,code,descript,term) select "1", "B3", "��ѷ�", "select roomno from master where sta='I' and setrate*(1-discount1)=0"
insert hsmap_term(cat,code,descript,term) select "1", "B4", "���ս���", "select roomno from master where charindex(sta,'RCG')>0 and datediff(dd,getdate(),arr)<=0"
insert hsmap_term(cat,code,descript,term) select "1", "B5", "���ս���", "select roomno from master where sta='I' and datediff(dd,getdate(),dep)<=0"
insert hsmap_term(cat,code,descript,term) select "1", "B6", "��ǰɢ�ͷ�", "select roomno from master where groupno='' and charindex(sta,'RICG')>0 and datediff(dd,arr,getdate())>=0"
insert hsmap_term(cat,code,descript,term) select "1", "B7", "��ǰ���巿", "select roomno from master where groupno<>'' and charindex(sta,'RICG')>0 and datediff(dd,arr,getdate())>=0"

insert hsmap_term(cat,code,descript,term) select "1", "C1", "�⼮ס��", "select a.roomno from master a, guest b where a.haccnt=b.no and a.sta='I' and b.nation<>'CHN'"
insert hsmap_term(cat,code,descript,term) select "1", "C2", "����ס��", "select a.roomno from master a, guest b where a.haccnt=b.no and a.sta='I' and secret='T'"
insert hsmap_term(cat,code,descript,term) select "1", "C3", "Ůס��", "select a.roomno from master a, guest b where a.haccnt=b.no and sta='I' and sex='2'"
insert hsmap_term(cat,code,descript,term) select "1", "C4", "����>=60", "select a.roomno from master a, guest b where a.haccnt=b.no and sta='I' and birth is not null and datediff(yy,birth,getdate())>=60"
//
//insert hsmap_term(cat,code,descript,term) select "1", "D1", "ָ���Ŷ�", "grpmst", "accnt='#char12!�����������˺Ż����ƹؼ���#' or name like '%#char12#%'"

// ��̬��������
insert hsmap_term(cat,code,descript,term) select "2", "U0", "�շ�", "select roomno from rmsta where ocsta='V' "
insert hsmap_term(cat,code,descript,term) select "2", "U1", "�շ�+��", "select roomno from rmsta where ocsta='V' and sta='D' "
insert hsmap_term(cat,code,descript,term) select "2", "U2", "ס�ͷ�", "select roomno from rmsta where ocsta='O' "
insert hsmap_term(cat,code,descript,term) select "2", "U3", "���ս���", "select distinct roomno from master where sta='R' and datediff(dd,arr,getdate())=0 and roomno<>'' "
insert hsmap_term(cat,code,descript,term) select "2", "U4", "���ս���+��", "select distinct a.roomno from master a, rmsta b where a.sta='R' and datediff(dd,a.arr,getdate())=0 and a.roomno=b.roomno and b.sta='D' "
insert hsmap_term(cat,code,descript,term) select "2", "U5", "���ս���", "select distinct roomno from master where sta='I' and datediff(dd,dep,getdate())=0 and roomno<>'' "
insert hsmap_term(cat,code,descript,term) select "2", "U6", "�����˷�", "select distinct roomno from master where sta='O' and roomno<>'' "
insert hsmap_term(cat,code,descript,term) select "2", "U7", "������ס", "select distinct roomno from master where sta='I' and datediff(dd,arr,getdate())=0 and roomno<>'' "
insert hsmap_term(cat,code,descript,term) select "2", "V0", "��ʱ̬�ͷ�", "select roomno from rmsta where tmpsta<>'E' and tmpsta<>'' "
insert hsmap_term(cat,code,descript,term) select "2", "V1", "ά�޷�", "select roomno from rmsta where sta='O' "
insert hsmap_term(cat,code,descript,term) select "2", "V2", "������", "select roomno from rmsta where sta='S' "
;

// --------------------------------------------------------------------
// ��̬��2 �Զ������� -- ���
// --------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'hsmap_term_end')
	drop table hsmap_term_end
;
create table hsmap_term_end (
	modu_id		char(2)	not null,
	pc_id			char(4)	not null,
	cat			char(1)	not null,
	roomno		char(5)	not null
)
exec sp_primarykey hsmap_term_end, modu_id, pc_id, cat, roomno;
create unique index index1 on hsmap_term_end(modu_id, pc_id, cat, roomno)
;


//-----------------------------------------------------------------------
// ��ǰά��������
//
//		ά��������� -- folio Ψһ����, 
//
//		��Ҫ��Ϊ���Ժ����Ҫ�빤�̲���ϵ���ʿ�ṹ�����±仯
//			1��folio -- Ψһ��־�ţ�����������
//			2. roomno + status('I') Ψһ����, ϵͳ�ݲ�֧��һ������ͬʱ��������Чά�޵�;
//			3�����ŷֿ���ְ����� ---- empno1, empno2, empno3
//			4��Ԥ���ֶ�----- l1, l2
//			5��ͨ��״̬�������ݱ���
//-----------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'rm_ooo')
	drop table rm_ooo
;
create table rm_ooo 
(
	folio		varchar(10)					not null,  // ��ˮ��
	sfolio	varchar(10)	default''	not null,  // ���ݺ�
	status	char(1)		default 'I' not null,  // ��Ч(I),���(O),ȡ��(X)
	roomno	char(5)						not null,
	oroomno	char(5)						not null,
	sta		char(1)						not null, // ά��̬ --> O��S
	dbegin	datetime						not null,
	dend		datetime 					null,
	reason	char(3)						not null, // ԭ��
	remark	varchar(255)	default ''	not null, // ����
	empno1	char(10)						not null, // �趨����
	date1		datetime						not null,
	empno2	char(10)						null,	    // ά�޹���
	date2		datetime						null,
	empno3	char(10)						null,	    // �������
	date3		datetime						null,
	empno4	char(10)						null,	    // ȡ������
	date4		datetime						null,
	l1			varchar(10)					null,		
	l2			varchar(10)					null,		
	logmark	int			default 0 	not null
)
exec sp_primarykey rm_ooo, folio
create unique index index1 on rm_ooo(folio)
create index index2 on rm_ooo(roomno, status)  // I ״̬����Ψһ, ����״̬��һ��
create  index index3 on rm_ooo(roomno, folio)
create  index index4 on rm_ooo(reason)
;
// ��ʷά��������
if exists (select 1 from sysobjects where name = 'hrm_ooo')
	drop table hrm_ooo;
select * into hrm_ooo from rm_ooo where 1=2;
exec sp_primarykey hrm_ooo, folio
create unique index index1 on hrm_ooo(folio)
create  index index2 on hrm_ooo(roomno, folio)
create  index index3 on hrm_ooo(reason)
;
// ά����������־
if exists (select 1 from sysobjects where name = 'rm_ooo_log')
	drop table rm_ooo_log;
select * into rm_ooo_log from rm_ooo where 1=2;
exec sp_primarykey rm_ooo_log, folio, logmark
create unique index index1 on rm_ooo_log(folio, logmark)
;


//------------------------------------------------------------------------------
//		�ͷ����ķ�̬����ɫ������ʱ��
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'hs_mapclr')
	drop table hs_mapclr
;
create table  hs_mapclr (
	pc_id			char(4)			not null,
	modu_id		char(2)			not null,
	baseclr		money	default 0 not null,	// ����ɫ
	clsclr1		money	default 0 not null,	// ���ɫ 1-8
	clsclr2		money	default 0 not null,
	clsclr3		money	default 0 not null,
	clsclr4		money	default 0 not null,
	clsclr5		money	default 0 not null,
	clsclr6		money	default 0 not null,
	clsclr7		money	default 0 not null,
	clsclr8		money	default 0 not null,
	addclr1		money	default 0 not null,	// ����ɫ1-3
	addclr2		money	default 0 not null,
	addclr3		money	default 0 not null
)
exec sp_primarykey hs_mapclr, pc_id, modu_id
create unique index code on hs_mapclr(pc_id, modu_id)
;


//------------------------------------------------------------------------------------
// �ͷ�ʵʱ��̬����, �洢ѡ�е���
//------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = 'hsmapsel' and type = 'U')
	drop table hsmapsel
;
create table hsmapsel
(
	pc_id		char(4)	null,
	modu_id	char(2)	null,
	irow 		integer	null
)
exec sp_primarykey hsmapsel, pc_id, modu_id, irow
create unique index index1 on hsmapsel(pc_id, modu_id, irow)
;

//------------------------------------------------------------------------------
//		�ͷ�����̬�� -- ��ͳ���鷿̬��Ӧ����Ϊ�ռ��÷�̬��
//		�ñ�ע�⣺���ܴ����κ�����������
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'hsmap')
	drop table hsmap
;
create table hsmap (
	pc_id		char(4) not null,
	modu_id	char(2) not null,
	roomno	char(5) not null,
	oroomno	char(5) not null,
	flr		char(3) not null,
	bu			char(1) default 'F' not null,    // �����
	base		char(1) default '' not null,  	// ����״̬
	ad1		char(1) default '' not null,		// ����״̬  --  ��̬�е���ʱ̬
	ad2		char(1) default '' not null,		// ����״̬  --  ����
	ad3		char(1) default '' not null,		// ����״̬  --  ����
	box		char(1) default '' not null,		// �߿�
	num0		smallint	default 0 not null,
	num1		smallint	default 0 not null,
	num2		smallint	default 0 not null,
	num3		smallint	default 0 not null,
	num4		smallint	default 0 not null,
	num5		smallint	default 0 not null,
	num6		smallint	default 0 not null,
	num7		smallint	default 0 not null,
	adn1		smallint	default 0 not null,		// number of ad1
	adn2		smallint	default 0 not null,		// number of ad2
	adn3		smallint	default 0 not null		// number of ad3
)

//------------------------------------------------------------------------------
//		�ͷ�����̬��  -- ����
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'hsmap_des')
	drop table hsmap_des
;
create table hsmap_des (
	pc_id		char(4) not null,
	modu_id	char(2) not null,
	base0		char(4) null,
	base1		char(4) null,
	base2		char(4) null,
	base3		char(4) null,
	base4		char(4) null,
	base5		char(4) null,
	base6		char(4) null,
	base7		char(4) null,
	ad1		char(4) null,
	ad2		char(4) null,
	ad3		char(4) null
)

// --------------------------------------------------------------------
// Ϊ��¥�㻻��,���е����ⷿ�ŵĲ���
// --------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'hsmap_bu')
	drop table hsmap_bu
;
create table hsmap_bu (
	modu_id		char(2)	not null,
	pc_id			char(4)	not null,
	oroomno		char(5)	not null,
	flr			char(3)	not null
)
exec sp_primarykey hsmap_bu, modu_id, pc_id, oroomno;
create unique index index1 on hsmap_bu(modu_id, pc_id, oroomno)
;

// --------------------------------------------------------------------
//	��ʱ̬
// --------------------------------------------------------------------
IF OBJECT_ID('rmtmpsta') IS NOT NULL
    DROP TABLE rmtmpsta
;
CREATE TABLE rmtmpsta 
(
    roomno char(5)     NOT NULL,
    tmpsta char(1)     NOT NULL,
    remark varchar(60) NULL,
    empno  char(10)     NULL,
    date   datetime    NULL
);
EXEC sp_primarykey 'rmtmpsta', roomno;
CREATE UNIQUE NONCLUSTERED INDEX index1  ON rmtmpsta(roomno);
// ��ʷ��ʱ̬
if exists (select 1 from sysobjects where name = 'hrmtmpsta')
	drop table hrmtmpsta;
CREATE TABLE hrmtmpsta 
(
    roomno char(5)     NOT NULL,
    tmpsta char(1)     NOT NULL,
    remark varchar(60) NULL,
    empno  char(10)    NULL,
    date   datetime    NULL,
    empno1 char(10)    NULL,
    date1  datetime    NULL,
	 status char(1)	  NULL
);
exec sp_primarykey hrmtmpsta, roomno,date1;
create unique index index1 on hrmtmpsta(roomno,date1)
;

IF OBJECT_ID('hsmap_bu_cond') IS NOT NULL
    DROP TABLE hsmap_bu_cond
;
CREATE TABLE hsmap_bu_cond 
(
    modu_id char(2) NOT NULL,
    pc_id   char(4) NOT NULL,
    hall    char(1) NULL,
    type    char(5) NULL,
    flr     char(3) NULL
)
EXEC sp_primarykey 'hsmap_bu_cond', modu_id,pc_id
CREATE UNIQUE NONCLUSTERED INDEX index1   ON hsmap_bu_cond(modu_id,pc_id)
;

IF OBJECT_ID('rmstarep') IS NOT NULL
    DROP TABLE rmstarep
;
CREATE TABLE rmstarep 
(
    pc_id   char(4)  NOT NULL,
    modu_id char(2)  NOT NULL,
    type    char(5)  NOT NULL,
    flr     char(3)  NOT NULL,
    roomno  char(5)  NOT NULL,
    sta     char(3)  NOT NULL,
    bksta   char(12) NULL,
    locked1 char(1)  NULL,
    locksta char(1)  NOT NULL,
    v01     char(2)  NULL,
    v02     char(2)  NULL,
    v03     char(2)  NULL,
    v04     char(2)  NULL,
    v05     char(2)  NULL,
    v06     char(2)  NULL,
    v07     char(2)  NULL,
    v08     char(2)  NULL,
    v09     char(2)  NULL,
    v10     char(2)  NULL,
    v11     char(2)  NULL,
    v12     char(2)  NULL,
    v13     char(2)  NULL,
    v14     char(2)  NULL,
    v15     char(2)  NULL
)
EXEC sp_primarykey 'rmstarep', pc_id,modu_id,roomno
CREATE UNIQUE NONCLUSTERED INDEX index1    ON rmstarep(pc_id,modu_id,roomno)
;


//------------------------------------------------------------------------------
//		�ͷ��������Ա���������Ŀǰ����3��
//------------------------------------------------------------------------------
IF OBJECT_ID('task_assignment') IS NOT NULL
    DROP TABLE task_assignment
;
CREATE TABLE task_assignment
       (no money NOT NULL,
       rmno char(8) NOT NULL,
       rmtype char(8) NULL,
       lou char(6) NULL,
       floor char(6) NULL,
       guestname char(60) NULL,
       vip char(15) NULL,
       foreigner char(20) NULL,
       rmamenities char(80) NULL,
       rmsta char(4) NULL,
       points money NULL,
       attendantid char(10) NULL,
       attendantname char(20) NULL,
       checked char(4) NULL,
       specialflag char(4) NULL,
       expendable char(80) NULL,
       cleantime datetime NULL,
       assigntime datetime NULL,
       beizhu char(80) NULL,
       beizhu2 char(80) NULL,
       assignman char(20) NULL,
       checkman char(20) NULL,
       usedtime int NULL,
       ocsta char(4) NULL,
       newsta char(4) NULL,
       changetime datetime NULL,
       changer char(20) NULL,
       e1 integer NULL,
       e2 integer NULL,
       e3 integer NULL,
       e4 integer NULL,
       e5 integer NULL,
       e6 integer NULL,
       e7 integer NULL,
       e8 integer NULL,
       e9 integer NULL,
       e10 integer NULL,
       e11 integer NULL,
       e12 integer NULL,
       e13 integer NULL,
       e14 integer NULL,
       e15 integer NULL,
       e16 integer NULL,
       e17 integer NULL,
       e18 integer NULL,
       e19 integer NULL,
       e20 integer NULL,
       e21 integer NULL,
       e22 integer NULL,
       e23 integer NULL,
       e24 integer NULL,
       e25 integer NULL,
       e26 integer NULL,
       e27 integer NULL,
       e28 integer NULL,
       e29 integer NULL,
       e30 integer NULL,
		 accnt char(10) NULL) ; 
EXEC sp_primarykey 'task_assignment',
       'no' ;

IF OBJECT_ID('attendant_info') IS NOT NULL
    DROP TABLE attendant_info
;
CREATE TABLE attendant_info
       (no int NULL,
       id char(10) NOT NULL,
       name varchar(30) NOT NULL,
       name2 varchar(30) NULL,
       hall varchar(10) NULL,
       flr varchar(60) NULL,
       english int NULL,
       capability money NULL,
       totalpoints money NULL,
       other varchar(60) NULL,
       sta char(5) NULL,
       changetime datetime NULL,
       changer char(5) NULL) ; 
EXEC sp_primarykey 'attendant_info',
       'id' ;

IF OBJECT_ID('task_rooms') IS NOT NULL
    DROP TABLE task_rooms
;
CREATE TABLE task_rooms
       (roomno char(6) NOT NULL) ;



------------------------------------------------
--	hall_station 
------------------------------------------------
//exec sp_rename hall_station, a_hall_station; 
if object_id('hall_station') is not null 
	drop TABLE hall_station ; 
CREATE TABLE hall_station 
(
    pc_id char(4)      NOT NULL,
    halls varchar(30)  NULL,
    types varchar(100) NULL
);
EXEC sp_primarykey 'hall_station', pc_id;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON hall_station(pc_id);
//insert hall_station select * from a_hall_station; 
//drop table a_hall_station; 
//select * from hall_station; 


------------------------------------------------
--	hall_station_user 
------------------------------------------------
if object_id('hall_station_user') is not null 
	drop TABLE hall_station_user ; 
CREATE TABLE hall_station_user 
(
    empno char(10)      NOT NULL,
    halls varchar(255)  NULL,
    types varchar(255) 	NULL
);
EXEC sp_primarykey 'hall_station_user', empno;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON hall_station_user(empno);
insert hall_station_user(empno, halls, types) 
	select code, descript, descript1 from basecode where cat='rmscope'; 
select * from hall_station_user; 


