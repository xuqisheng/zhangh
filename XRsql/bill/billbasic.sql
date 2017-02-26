----------------------------------
--  վ���ӡ������ 
----------------------------------
if exists(select * from sysobjects where name = "bill_pcprint" and type = 'U')
	drop table bill_pcprint;
create table bill_pcprint
(
	pc_id					char(4)						not null,							-- վ��
	printtype         char(10)		         	not null,  							-- �˵����
	printer	         varchar(128) default ''	not null,							-- ��ӡ������
	printer1	         varchar(128) default ''	not null								-- ��ӡ������
)
;
create unique  index index1 on bill_pcprint(pc_id,printtype) ;
----------------------------------
-- �ʵ�ҵ�����
----------------------------------
if exists(select * from sysobjects where name = "bill_default" and type = 'U')
	drop table bill_default;
create table bill_default
(
	modu	        		varchar(10)			not null,	 					-- ��ʾ����
	descript          varchar(30)			null,		 						-- ����
	descript1         varchar(30)			null,		 						-- ����1
	code	        		varchar(3)			not null 	 					-- ȱʡ��ʾ
)
;
create unique  index index2 on bill_default(modu) ;

----------------------------------
-- �ʵ���ʾ���
----------------------------------
if exists(select * from sysobjects where name = "bill_mode" and type = 'U')
	drop table bill_mode;
create table bill_mode
(
	code	        		varchar(3)			not null,	 					-- ��ʾ����
	descript          varchar(30)			null,		 						-- ����
	descript1         varchar(30)			null,		 						-- ����1
	printtype         varchar(10)			null,								-- �˵����
	modu	       		varchar(254)		null,								-- ģ���б�
	halt					char(1)	default 'F'	null,							-- �Ƿ�ͣ��
	sequence				int		default 0	null,
	extctrl          	varchar(16)     			 		null				-- ��չ���ƴ�,Bit1==�Ƿ��Ƿ�Ʊ��T-��Ʊ F-���ݣ� 
)
;
create unique  index index2 on bill_mode(code) ;

----------------------------------
-- �˵�������� 
----------------------------------
if exists(select * from sysobjects where name = "bill_unit" and type = 'U')
	drop table bill_unit;
create table bill_unit
(
	printtype         char(10)								not null, 		-- �˵����
	language				char(1) 			default 'C' 	not null,	 	-- ����				
	descript          varchar(30)							null,       	-- �˵�����
	descript1         varchar(30)							null,       	-- �˵�����
	paperwidth        int 				default 200		null,         	-- �˵���
	paperlength       int				default 200		null,         	-- �˵���
	papertype			char(1)			default 'P' 	not null,		-- ��ʾȱʡ����: P-ֱ�Ӵ�ӡ V-Ԥ�� D-ģ�� W-ֻ��ģ��
	detailrow    		int 				default 10		null,				-- �˵���������	 
	syntax				text									null,				-- ����datawindow�﷨
	inumber				int 				default 0 		null,				-- in_allprint.inumber ����
	savemodi				char(1) 			default 'F' 	not null,  		-- �Ƿ�Ҫ�����޸�ǰ������
	paperzoom			int 				default 100 	not null, 		-- �˵�����
	worddot          	varchar(254)     			 		null,				-- �˵�Wordģ���ļ�
	extctrl          	varchar(16)     			 		null				-- �˵���չ���ƴ�,Bit1==�Ƿ���ʺŴ� 
)
;
create unique  index index1 on bill_unit(printtype, language) ;


----------------------------------
--  ���ݽ����
----------------------------------
if exists(select * from sysobjects where name = "bill_data" and type = 'U')
	drop table bill_data;
create table bill_data
(
	pc_id				char(4)						not null,			--  ���Ա�־
	inumber			int							null,					--  ��ţ���pos_dish.inumber
	code 				char(15)		default ''  null,					--  ��Ʒ���룬���ô��룬��������
	descript 		char(20)		default ''  null,					--  ��������
	descript1 		char(20)		default ''  null,					--  Ӣ������
	unit				char(4)		default ''  null,    			--  ��λ����pos_dish.unit
	number			money							null,  				--  ��������pos_dish.number
	price				money							null,  				--  ���ۣ���pos_dish.price
	charge			money							null,    			--  ���� 
	credit			money							null,    			--  ���� 
	empno				char(10)		default ''  null,    			--  ����
	logdate			datetime						null, 				--  ʱ��
	item 				varchar(255)				null,					--  ���ַ���ƴ������Ҫ��ӡ����ϸ����
	sort 				char(10)		default ''  null,					-- ����
	char1		 		varchar(50)	default ''  null,				--  ����1
	char2 			varchar(50)	default ''  null,				--  ����2
	char3 			varchar(50)	default ''  null,				--  ����3
	char4 			varchar(50)	default ''  null,				--  ����4
	char5 			varchar(50)	default ''  null,				--  ����5
	char6 			varchar(50)	default ''  null,				--  ����6
	char7 			varchar(50)	default ''  null,				--  ����7
	char8 			varchar(50)	default ''  null,				--  ����8
	char9 			varchar(50)	default ''  null,				--  ����9
	char10 			varchar(50)	default ''  null,				--  ����10
	char11 			varchar(50)	default ''  null,				--  ����11
	char12 			varchar(50)	default ''  null,				--  ����12
	char13 			varchar(50)	default ''  null,				--  ����13
	char14 			varchar(50)	default ''  null,				--  ����14
	mone1				money			default 0   null,    		--  �������1
	mone2				money			default 0   null,    		--  �������2
	mone3				money			default 0   null,    		--  �������3
	mone4				money			default 0   null,    		--  �������4
	date1				datetime						null,  			--  ����1
	date2				datetime						null,  			--  ����2
	date3				datetime						null,  			--  ����3
	date4				datetime						null,  			--  ����4
	sum1	 			varchar(255)				null,				--  ����β����1����ϼ�
	sum2 				varchar(255)				null,				--  ����β����2����ϼ�
	sum3	 			varchar(255)				null,				--  ����β����3����ϼ�
	sum4 				varchar(255)				null,				--  ����β����4����ϼ�
	sum5	 			varchar(255)				null,				--  ����β����5����ϼ�
	sum6 				varchar(255)				null,				--  ����β����6����ϼ�
	sum7	 			varchar(255)				null,				--  ����β����7����ϼ�
	sum8 				varchar(255)				null,				--  ����β����8����ϼ�
	sum9	 			varchar(255)				null				--  ����β����9����ϼ�
);
