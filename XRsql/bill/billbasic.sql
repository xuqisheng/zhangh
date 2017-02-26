----------------------------------
--  站点打印机定义 
----------------------------------
if exists(select * from sysobjects where name = "bill_pcprint" and type = 'U')
	drop table bill_pcprint;
create table bill_pcprint
(
	pc_id					char(4)						not null,							-- 站点
	printtype         char(10)		         	not null,  							-- 账单类别
	printer	         varchar(128) default ''	not null,							-- 打印机名称
	printer1	         varchar(128) default ''	not null								-- 打印机名称
)
;
create unique  index index1 on bill_pcprint(pc_id,printtype) ;
----------------------------------
-- 帐单业务控制
----------------------------------
if exists(select * from sysobjects where name = "bill_default" and type = 'U')
	drop table bill_default;
create table bill_default
(
	modu	        		varchar(10)			not null,	 					-- 显示控制
	descript          varchar(30)			null,		 						-- 描述
	descript1         varchar(30)			null,		 						-- 描述1
	code	        		varchar(3)			not null 	 					-- 缺省显示
)
;
create unique  index index2 on bill_default(modu) ;

----------------------------------
-- 帐单显示类别
----------------------------------
if exists(select * from sysobjects where name = "bill_mode" and type = 'U')
	drop table bill_mode;
create table bill_mode
(
	code	        		varchar(3)			not null,	 					-- 显示控制
	descript          varchar(30)			null,		 						-- 描述
	descript1         varchar(30)			null,		 						-- 描述1
	printtype         varchar(10)			null,								-- 账单类别
	modu	       		varchar(254)		null,								-- 模块列表
	halt					char(1)	default 'F'	null,							-- 是否停用
	sequence				int		default 0	null,
	extctrl          	varchar(16)     			 		null				-- 拓展控制串,Bit1==是否是发票（T-发票 F-单据） 
)
;
create unique  index index2 on bill_mode(code) ;

----------------------------------
-- 账单单据类别 
----------------------------------
if exists(select * from sysobjects where name = "bill_unit" and type = 'U')
	drop table bill_unit;
create table bill_unit
(
	printtype         char(10)								not null, 		-- 账单类别
	language				char(1) 			default 'C' 	not null,	 	-- 语言				
	descript          varchar(30)							null,       	-- 账单描述
	descript1         varchar(30)							null,       	-- 账单描述
	paperwidth        int 				default 200		null,         	-- 账单宽
	paperlength       int				default 200		null,         	-- 账单长
	papertype			char(1)			default 'P' 	not null,		-- 显示缺省控制: P-直接打印 V-预览 D-模板 W-只用模板
	detailrow    		int 				default 10		null,				-- 账单内容行数	 
	syntax				text									null,				-- 单据datawindow语法
	inumber				int 				default 0 		null,				-- in_allprint.inumber 索引
	savemodi				char(1) 			default 'F' 	not null,  		-- 是否要保存修改前后内容
	paperzoom			int 				default 100 	not null, 		-- 账单缩放
	worddot          	varchar(254)     			 		null,				-- 账单Word模板文件
	extctrl          	varchar(16)     			 		null				-- 账单拓展控制串,Bit1==是否分帐号打 
)
;
create unique  index index1 on bill_unit(printtype, language) ;


----------------------------------
--  单据结果集
----------------------------------
if exists(select * from sysobjects where name = "bill_data" and type = 'U')
	drop table bill_data;
create table bill_data
(
	pc_id				char(4)						not null,			--  电脑标志
	inumber			int							null,					--  序号，如pos_dish.inumber
	code 				char(15)		default ''  null,					--  菜品代码，费用代码，付款代码等
	descript 		char(20)		default ''  null,					--  中文描述
	descript1 		char(20)		default ''  null,					--  英文描述
	unit				char(4)		default ''  null,    			--  单位，如pos_dish.unit
	number			money							null,  				--  数量，如pos_dish.number
	price				money							null,  				--  单价，如pos_dish.price
	charge			money							null,    			--  费用 
	credit			money							null,    			--  付款 
	empno				char(10)		default ''  null,    			--  工号
	logdate			datetime						null, 				--  时间
	item 				varchar(255)				null,					--  用字符串拼出整行要打印的明细内容
	sort 				char(10)		default ''  null,					-- 排序
	char1		 		varchar(50)	default ''  null,				--  描述1
	char2 			varchar(50)	default ''  null,				--  描述2
	char3 			varchar(50)	default ''  null,				--  描述3
	char4 			varchar(50)	default ''  null,				--  描述4
	char5 			varchar(50)	default ''  null,				--  描述5
	char6 			varchar(50)	default ''  null,				--  描述6
	char7 			varchar(50)	default ''  null,				--  描述7
	char8 			varchar(50)	default ''  null,				--  描述8
	char9 			varchar(50)	default ''  null,				--  描述9
	char10 			varchar(50)	default ''  null,				--  描述10
	char11 			varchar(50)	default ''  null,				--  描述11
	char12 			varchar(50)	default ''  null,				--  描述12
	char13 			varchar(50)	default ''  null,				--  描述13
	char14 			varchar(50)	default ''  null,				--  描述14
	mone1				money			default 0   null,    		--  金额数量1
	mone2				money			default 0   null,    		--  金额数量2
	mone3				money			default 0   null,    		--  金额数量3
	mone4				money			default 0   null,    		--  金额数量4
	date1				datetime						null,  			--  日期1
	date2				datetime						null,  			--  日期2
	date3				datetime						null,  			--  日期3
	date4				datetime						null,  			--  日期4
	sum1	 			varchar(255)				null,				--  单据尾描述1，如合计
	sum2 				varchar(255)				null,				--  单据尾描述2，如合计
	sum3	 			varchar(255)				null,				--  单据尾描述3，如合计
	sum4 				varchar(255)				null,				--  单据尾描述4，如合计
	sum5	 			varchar(255)				null,				--  单据尾描述5，如合计
	sum6 				varchar(255)				null,				--  单据尾描述6，如合计
	sum7	 			varchar(255)				null,				--  单据尾描述7，如合计
	sum8 				varchar(255)				null,				--  单据尾描述8，如合计
	sum9	 			varchar(255)				null				--  单据尾描述9，如合计
);
