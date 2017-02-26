// -------------------------------------------------------------------------------------
//	��ʷ���� -- �������˺͵�λ
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest_sync")
	drop table guest_sync;
create table  guest_sync
(
	no    		char(7)		 						not null,		// ������:�����Զ����� 
	sta			char(1)			default 'I' 	not null,		// ״̬- I(n), O(ff), S(top), X(cancel)
	sno         varchar(15)		default ''		not null,   	// �ͻ��� ��λ�Զ��� 
	cno         varchar(20)		default ''		not null,   	// ��ͬ���� 

	hotelid		varchar(20)		default ''		not null,   	// Hotel ID.
	central		char(1)			default 'F'		not null,
	censeq		varchar(30)		default ''		not null,   	// Karis Seq.

	name		   varchar(50)	 						not null,	 	// ����: ���� 
	fname       varchar(30)		default ''		not null, 		// Ӣ���� 
	lname			varchar(30)		default '' 		not null,		// Ӣ���� 
	name2		   varchar(50)		default '' 		not null,		// �������� 
	name3		   varchar(50)		default '' 		not null,		// �������� 
	name4		   varchar(255)	default '' 		not null,		// �������� 
	class			char(1)			default ''		not null,		// ���: 'F'=���� G=���� C=��˾��A=�����磻S=�������� --> �̶����룻 
	type			char(1)			default 'N'		not null,		// ���� -- N=��ͨ/B=������/C=�ָ�/R=���� 
	grade			char(1)			default ''		not null,		// ���õȼ�
	latency		char(1)			default '0'		not null,		// Ǳ�ڿͻ� 0 - ��Ǳ�ڿͻ���������ʾ���

	class1		char(3)			default '0'		not null, 		// �������	0=��ʾû�ж��壻
	class2		char(3)			default '0'		not null,
	class3		char(3)			default '0'		not null,
	class4		char(3)			default '0'		not null,
	src			char(3)			default ''		not null,		// ������Դ
	market		char(3)			default ''		not null,		// �г�����
	vip			char(3)			default '0'		not null,  		// vip 
	keep			char(1) 			default 'F'  	not null,  		// ���� 
	belong		varchar(15) 	default ''  	not null,  		// �������� -- ���������Ҫ�����ı��͵���������

	sex			char(1)			default '1'		not null,      // �Ա�:M,F 
	lang			char(1)			default 'C'		not null,		// ���� 
	title			char(3)			default ''		not null,		// �ƺ� 
	salutation	varchar(60)		default ''		not null,		// �ƺ� 

	birth       datetime								null,         	// ���� 		
	race			char(2)			default ''		not null, 		// ����
	religion		char(2)			default ''		not null, 		// �ڽ�
	occupation	char(2)			default ''		not null,		// ְҵ 
	nation		char(3)			default ''		not null,	  // ���� 

   idcls       char(3)     	default ''		not null,     	// ����֤����� 
	ident		   char(20)	   	default ''		not null,     	// ����֤������ 
	idend			datetime								null,		   	// ֤����Ч��			-- New
	cusno			char(7)			default ''		not null,		// ��λ�� 
	unit        varchar(60)		default ''		not null,		// ��λ 

	cardcode		varchar(10)		default ''		not null,		// ���ÿ���
	cardno		varchar(20)		default ''		not null,		// ���ÿ���
	cardlevel	varchar(3)		default ''		not null,		// ����

	country		char(3)			default ''		not null,	   // ���� 
	state			char(3)			default ''		not null,	   // ���� 
	town			varchar(40)		default ''		not null,		// ����
	city  		char(6)			default ''		not null,      // ����
	street	   varchar(100)		default ''		not null,		// סַ 
	zip			varchar(6)		default ''		not null,		// �������� 
	mobile		varchar(20)		default ''		not null,		// �ֻ� 
	phone			varchar(20)		default ''		not null,		// �绰 
	fax			varchar(20)		default ''		not null,		// ���� 
	wetsite		varchar(30)		default ''		not null,		// ��ַ 
	email			varchar(30)		default ''		not null,		// ���� 

	country1		char(3)			default ''		not null,	   // ���� 
	state1		char(3)			default ''		not null,	   // ���� 
	town1			varchar(40)		default ''		not null,		// ����
	city1  		char(6)			default ''		not null,      // ����
	street1	   varchar(100)		default ''		not null,		// סַ 
	zip1			varchar(6)		default ''		not null,		// �������� 
	mobile1		varchar(20)		default ''		not null,		// �ֻ� 
	phone1		varchar(20)		default ''		not null,		// �绰 
	fax1			varchar(20)		default ''		not null,		// ���� 
	email1		varchar(30)		default ''		not null,		// ���� 

	visaid		char(3)			default ''		null,			// ǩ֤��� 
	visaend		datetime								null,		   // ǩ֤��Ч�� 
	visano		varchar(20)							null,  		// ǩ֤���� 
	visaunit		char(4)								null,    	// ǩ֤���� 
   rjplace     char(3)     						null,       // �뾳�ڰ� 
	rjdate		datetime								null,		   // �뾳���� 

   srqs        varchar(30)		default ''		not null,   // ����Ҫ�� 
	amenities  	varchar(30)		default ''		not null,	// ���䲼��
   feature		varchar(30)		default ''		not null,   // ����ϲ��1 
	rmpref		varchar(20)		default ''		not null,   // ����ϲ��2 
   interest		varchar(30)		default ''		not null,   // ��Ȥ���� 

	lawman		varchar(16)		default ''		null,			// ����������
	regno			varchar(20)		default ''		null,			// ��ҵ�ǼǺ�
	bank			varchar(50)		default ''		null,			// ��������
	bankno		varchar(20)		default ''		null,			// �����ʺ�
	taxno			varchar(20)		default ''		null,			// ˰��
   liason      varchar(30)   	default ''		not null,   // ��ϵ��
   liason1     varchar(30)   	default ''		null,     	// ��ϵ��ʽ
	extrainf		varchar(30)	 	default '' 		not null, 	// for gaoliang  
   refer1     	varchar(250) 	default ''		not null,   // �ͷ�ϲ��
   refer2     	varchar(250) 	default ''		not null,   // ����ϲ��
   refer3     	varchar(250) 	default ''		not null,   // ����ϲ�� 
   comment    	varchar(100) 	default ''		not null,   // ˵��
   remark      text 									null,			// ��ע 
	override		char(1)     	default 'F'		not null,	// ���Գ���� 

   arr         datetime      						null,  		// ��Ч����
   dep         datetime      						null,			// ��ֹ����

	code1			char(10)			default ''		not null, 	// ������ 
	code2			char(10)			default ''		not null, 	// ������ 
	code3			char(10)			default ''		not null, 	// ���� 
	code4			char(10)			default ''		not null, 	// ���� 
	code5			char(10)			default ''		not null, 	// ���� 

	iata			varchar(30)		default ''		not null, 	// ������
	flag			varchar(50)		default ''		not null, 

   saleid      char(12)      	default ''		not null,	// ����Ա 

	araccnt1		char(10)     	default ''		not null,	// Ӧ���ʺ� 
	araccnt2		char(10)     	default ''		not null,	// Ӧ���ʺ� 
	master		char(7)     	default ''		not null,	// ���ʺ� 

	fv_date		datetime								null,			// �״ε��� 
	fv_room		char(5)			default ''		not null,
	fv_rate		money				default 0		not null,
	lv_date		datetime								null,			// �ϴε��� 
	lv_room		char(5)			default ''		not null,
	lv_rate		money				default 0		not null,

   i_times     int 				default 0 		not null,   // ס����� 
   x_times     int 				default 0 		not null,   // ȡ��Ԥ������ 
   n_times     int 				default 0 		not null,   // Ӧ��δ������ 
   l_times     int 				default 0 		not null,   // �������� 
   i_days      int 				default 0 		not null,   // ס������ 

   fb_times1    int 				default 0 		not null,   // �������� 
   en_times2    int 				default 0 		not null,   // ���ִ��� 

   rm          money 			default 0 		not null, 	// ��������
   fb          money 			default 0 		not null, 	// ��������
   en          money 			default 0 		not null, 	// ��������
   mt          money 			default 0 		not null, 	// ��������
   ot          money 			default 0 		not null, 	// ��������
   tl          money 			default 0 		not null, 	// ������  

-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_dt3		datetime			null,
	exp_dt4		datetime			null,
	exp_dt5		datetime			null,
	exp_dt6		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,
	exp_s4		varchar(30)		null,
	exp_s5		varchar(30)		null,
	exp_s6		varchar(50)		null,

   crtby       char(10)								not null,	// ���� 
	crttime     datetime 		default getdate()	not null,
   cby         char(10)								not null,	// �޸� 
	changed     datetime 		default getdate()	not null,
	logmark     int 				default 0 		not null
)
exec sp_primarykey guest_sync,no
create unique index index1 on guest_sync(no)
;
