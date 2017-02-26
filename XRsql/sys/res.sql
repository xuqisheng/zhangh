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
//  basecode : lastname  -- 中国 姓
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='lastname')
	delete basecode_cat where cat='lastname';
insert basecode_cat select 'lastname', '中国姓', 'Chinese Last Name', 1;
delete basecode where cat='lastname';
insert basecode(cat,code,descript,descript1) values('lastname', '诸葛', '诸葛', '诸葛_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '上官', '上官', '上官_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '欧阳', '欧阳', '欧阳_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '西门', '西门', '西门_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '司马', '司马', '司马_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '司徒', '司徒', '司徒_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '端木', '端木', '端木_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '慕容', '慕容', '慕容_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '夏侯', '夏侯', '夏侯_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '淳于', '淳于', '淳于_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '长孙', '长孙', '长孙_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '公孙', '公孙', '公孙_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '南宫', '南宫', '南宫_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '呼延', '呼延', '呼延_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '尉迟', '尉迟', '尉迟_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '纳兰', '纳兰', '纳兰_eng');
insert basecode(cat,code,descript,descript1) values('lastname', '宇文', '宇文', '宇文_eng');
// insert basecode(cat,code,descript,descript1) values('lastname', '', '', '_eng');


// --------------------------------------------------------------------------
//  basecode : artag1  -- ar accnt tag1
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='artag1')
	delete basecode_cat where cat='artag1';
insert basecode_cat select 'artag1', 'ar 主单类别1', 'ar Master Class1', 1;
delete basecode where cat='artag1';
insert basecode(cat,code,descript,descript1,sequence) values('artag1', '1', '金融', '金融_eng', 10);
insert basecode(cat,code,descript,descript1,sequence) values('artag1', '2', '机关', '机关_eng', 20);
insert basecode(cat,code,descript,descript1,sequence) values('artag1', '3', '公司', '公司_eng', 30);
insert basecode(cat,code,descript,descript1,sequence) values('artag1', '4', '长包房', '长包房_eng', 40);
insert basecode(cat,code,descript,descript1,sequence) values('artag1', '5', '贵宾卡', '贵宾卡_eng', 50);
insert basecode(cat,code,descript,descript1,sequence) values('artag1', '6', '其他', '其他_eng', 60);


// --------------------------------------------------------------------------
//  basecode : artag2  -- ar accnt tag2
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='artag2')
	delete basecode_cat where cat='artag2';
insert basecode_cat select 'artag2', 'ar 主单类别2', 'ar Master Class2', 1;
delete basecode where cat='artag2';
insert basecode(cat,code,descript,descript1,sequence) values('artag2', '1', '普通ＡＲ帐', '普通ＡＲ帐_eng', 10);
insert basecode(cat,code,descript,descript1,sequence) values('artag2', '2', '无限额 ＩＣ卡帐', '无限额 ＩＣ卡帐_eng', 20);
insert basecode(cat,code,descript,descript1,sequence) values('artag2', '3', '有限额 ＩＣ卡帐', '有限额 ＩＣ卡帐_eng', 30);



// --------------------------------------------------------------------------
//  basecode : priority  -- 优先级
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='priority')
	delete basecode_cat where cat='priority';
insert basecode_cat select 'priority', '优先级', 'Priority', 1;
delete basecode where cat='priority';
insert basecode(cat,code,descript,descript1,sequence,sys) values('priority', '0', '低', '低_eng', 10,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('priority', '1', '中', '中_eng', 20,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('priority', '2', '高', '高_eng', 30,'T');



// --------------------------------------------------------------------------
//  basecode : mstcls  -- master class
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='mstcls')
	delete basecode_cat where cat='mstcls';
insert basecode_cat select 'mstcls', '主单类别', 'Master Class', 1;
delete basecode where cat='mstcls';
insert basecode(cat,code,descript,descript1,sequence,sys) values('mstcls', 'F', '宾客', '宾客_eng', 10,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mstcls', 'G', '团体', '团体_eng', 20,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mstcls', 'M', '会议', '会议_eng', 30,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mstcls', 'C', '消费帐', '消费帐_eng', 40,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mstcls', 'A', '应收帐', '应收帐_eng', 50,'T');


// --------------------------------------------------------------------------
//  basecode : mststa  -- master 主单状态
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='mststa')
	delete basecode_cat where cat='mststa';
insert basecode_cat select 'mststa', '主单状态', 'Master Status', 1;
delete basecode where cat='mststa';
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'I', '在住', '', 100,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'R', '一般预订', '', 101,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'W', 'Waitlist', '', 102,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'O', '当天结帐', '', 104,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'D', '昨日结帐', '', 106,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'X', '预订取消', '', 108,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'S', '临时挂帐', '', 109,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'N', '预订未到', '', 110,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'E', '逃帐客人', '', 500,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('mststa', 'L', '转馆', '', 911,'T');


// --------------------------------------------------------------------------
//  basecode : waitlist  -- 等候预订
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='waitlist')
	delete basecode_cat where cat='waitlist';
insert basecode_cat select 'waitlist', '等候预订', 'waitlist', 3;
delete basecode where cat='waitlist';
insert basecode(cat,code,descript,descript1) select 'waitlist', 'FUL', '客满', 'Fully Booked';
insert basecode(cat,code,descript,descript1) select 'waitlist', 'OVL', '超额预订', 'Over Booked';
insert basecode(cat,code,descript,descript1) select 'waitlist', 'RAT', '无可用房价码', 'Rate code not available';
insert basecode(cat,code,descript,descript1) select 'waitlist', 'TYP', '无可用房类', 'Room Type not available';


// --------------------------------------------------------------------------
//  basecode : turnaway
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='turnaway')
	delete basecode_cat where cat='turnaway';
insert basecode_cat select 'turnaway', 'TurnAway', 'turnaway', 1;
delete basecode where cat='turnaway';
insert basecode(cat,code,descript,descript1) select 'turnaway', 'A', '客满', 'Fully Booked';
insert basecode(cat,code,descript,descript1) select 'turnaway', 'B', '超额预订', 'Over Booked';
insert basecode(cat,code,descript,descript1) select 'turnaway', 'C', '无可用房价码', 'Rate code not available';
insert basecode(cat,code,descript,descript1) select 'turnaway', 'D', '无可用房类', 'Room Type not available';
insert basecode(cat,code,descript,descript1) select 'turnaway', 'H', '房价过高', 'Rate Too High';
insert basecode(cat,code,descript,descript1) select 'turnaway', 'Z', '没有提供理由', 'No Reasons';



// --------------------------------------------------------------------------
//  basecode : channel  -- 预订渠道
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='channel')
	delete basecode_cat where cat='channel';
insert basecode_cat select 'channel', '预订渠道', 'Reservation Channel', 3;
delete basecode where cat='channel';
insert basecode(cat,code,descript,descript1) select 'channel', 'WKI', '直接上门', 'Walk In';
insert basecode(cat,code,descript,descript1) select 'channel', 'TEL', '电话', 'Telephone';
insert basecode(cat,code,descript,descript1) select 'channel', 'FAX', '传真', 'Fax';
insert basecode(cat,code,descript,descript1) select 'channel', 'EML', '电邮', 'E-mail';
insert basecode(cat,code,descript,descript1) select 'channel', 'WWW', '互联网', 'Website';
insert basecode(cat,code,descript,descript1) select 'channel', 'OTH', '其他', 'Other';


// --------------------------------------------------------------------------
//  basecode : worldcode  -- 国际区域代码
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='worldcode')
	delete basecode_cat where cat='worldcode';
insert basecode_cat select 'worldcode', '国际区域代码', 'World Region', 3;
delete basecode where cat='worldcode';
insert basecode(cat,code,descript,descript1) select 'worldcode', 'NAM', '北美洲', 'North America';
insert basecode(cat,code,descript,descript1) select 'worldcode', 'SAM', '南美洲', 'South America';
insert basecode(cat,code,descript,descript1) select 'worldcode', 'ASI', '亚洲', 'Asia';
insert basecode(cat,code,descript,descript1) select 'worldcode', 'AFR', '非洲', 'Africa';
insert basecode(cat,code,descript,descript1) select 'worldcode', 'EUR', '欧洲', 'Europe';
insert basecode(cat,code,descript,descript1) select 'worldcode', 'RES', '其他', 'Rest of World';


// --------------------------------------------------------------------------
//  basecode : rmreason  -- 换房理由
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='rmreason')
	delete basecode_cat where cat='rmreason';
insert basecode_cat select 'rmreason', '换房理由', 'Change Room Reason', 1;

delete basecode where cat='rmreason';
insert basecode(cat,code,descript,descript1) select 'rmreason', '1', '原房维修', 'Old Room Error';
insert basecode(cat,code,descript,descript1) select 'rmreason', '2', '客人要求', 'Guest Request';
insert basecode(cat,code,descript,descript1) select 'rmreason', '3', '共享房间', 'Share Room';
insert basecode(cat,code,descript,descript1) select 'rmreason', '4', '宾馆要求', 'Hotel Request';
insert basecode(cat,code,descript,descript1) select 'rmreason', '5', '输入错误', 'Input Error';


// --------------------------------------------------------------------------
//  basecode : up_reason  -- 客房升级理由
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='up_reason')
	delete basecode_cat where cat='up_reason';
insert basecode_cat select 'up_reason', '客房升级理由', 'up_reason', 3;
delete basecode where cat='up_reason';
insert basecode(cat,code,descript,descript1) select 'up_reason', 'UPG', '强迫升级', 'Forced Upgrade';
insert basecode(cat,code,descript,descript1) select 'up_reason', 'BUS', '商业关系', 'Business Relations';
insert basecode(cat,code,descript,descript1) select 'up_reason', 'CON', '契约', 'Per Contract';
insert basecode(cat,code,descript,descript1) select 'up_reason', 'COU', '宾馆礼遇', 'Courtesy Upgrade';
insert basecode(cat,code,descript,descript1) select 'up_reason', 'GST', '宾客抱怨', 'Guest Complaint';
insert basecode(cat,code,descript,descript1) select 'up_reason', 'GPD', '宾客支付', 'Guest paying Difference';


// --------------------------------------------------------------------------
//  basecode : vip  -- 贵宾
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='vip')
	delete basecode_cat where cat='vip';
insert basecode_cat select 'vip', '贵宾', 'VIP', 1;

delete basecode where cat='vip';
insert basecode(cat,code,descript,descript1) select 'vip', '0', '普通客人', 'normal guest';
insert basecode(cat,code,descript,descript1) select 'vip', '1', 'VIP - 1', 'VIP - 1';
insert basecode(cat,code,descript,descript1) select 'vip', '2', 'VIP - 2', 'VIP - 2';
insert basecode(cat,code,descript,descript1) select 'vip', '3', 'VIP - 3', 'VIP - 3';
insert basecode(cat,code,descript,descript1) select 'vip', '4', 'VIP - 4', 'VIP - 4';


// --------------------------------------------------------------------------
//  basecode : secret  -- 保密
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='secret')
	delete basecode_cat where cat='secret';
insert basecode_cat select 'secret', '保密', 'Secret', 1;

delete basecode where cat='secret';
insert basecode(cat,code,descript,descript1) select 'secret', '0', '不保密', 'normal guest';
insert basecode(cat,code,descript,descript1) select 'secret', '1', '保密 - 1', 'secret - 1';
insert basecode(cat,code,descript,descript1) select 'secret', '2', '保密 - 2', 'secret - 2';
insert basecode(cat,code,descript,descript1) select 'secret', '3', '保密 - 3', 'secret - 3';


// --------------------------------------------------------------------------
//  basecode : rescancel  -- 取消预订 - fidelio 把散客和团体理由分开了，这里合并
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='rescancel')
	delete basecode_cat where cat='rescancel';
insert basecode_cat select 'rescancel', '取消预订', 'Reservation Cancel Reason', 2;

delete basecode where cat='rescancel';
insert basecode(cat,code,descript,descript1) select 'rescancel', '1', '重复预订', 'Double reservation';
insert basecode(cat,code,descript,descript1) select 'rescancel', '2', '超过下午6点', '6 p.m release';
insert basecode(cat,code,descript,descript1) select 'rescancel', '3', '计划更改', 'Plans changed';
insert basecode(cat,code,descript,descript1) select 'rescancel', '4', '天气', 'Weather';
insert basecode(cat,code,descript,descript1) select 'rescancel', '5', '会议取消', 'Convention cancelled';
insert basecode(cat,code,descript,descript1) select 'rescancel', '6', '生病', 'Illness';
insert basecode(cat,code,descript,descript1) select 'rescancel', '7', '安排取消', 'Allocation no longer required';
insert basecode(cat,code,descript,descript1) select 'rescancel', '8', '房间不足', 'Pickup insufficent block cancelled';
insert basecode(cat,code,descript,descript1) select 'rescancel', '9', '条件不能接受', 'Offer not acceptable';
insert basecode(cat,code,descript,descript1) select 'rescancel', '10', 'Option not taken up', 'Option not taken up';
insert basecode(cat,code,descript,descript1) select 'rescancel', '11', '没有原因', 'Without reason';


// --------------------------------------------------------------------------
//  basecode : sex  -- 性别
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='sex')
	delete basecode_cat where cat='sex';
insert basecode_cat select 'sex', '性别', 'sex', 1;

delete basecode where cat='sex';
insert basecode(cat,code,descript,descript1,sys,sequence) select 'sex', '?', '未知', 'Unknown', 'T', 1;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'sex', 'M', '男性', 'Male', 'T', 2;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'sex', 'F', '女性', 'Female', 'T', 3;


// --------------------------------------------------------------------
//	Reservation reqcode : 特殊要求代码库  -- fidelio 还有回收和计价方面的属性
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
	flag1			char(10)		default ''	not null,	-- 标记固定特要，比如接机，送机等，报表应用  
	flag2			char(10)		default ''	not null,	-- 预留
	flag3			char(20)		default ''	not null,	-- 预留
	flag4			char(30)		default ''	not null,	-- 预留
	rate1			money		default 0	not null,		-- 价格1
	rate2			money		default 0	not null,		-- 价格2
	n1				int		default 0	not null,		-- 预留 		
	n2				int		default 0	not null,		-- 预留 		
	retu			char(1)	default 'F' not null,		-- 是否要收回 
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
//insert reqcode(code,descript,descript1) select 'LV','湖景房','Lake View Room';
//insert reqcode(code,descript,descript1) select 'NS','无烟房','Non-Smoking Room';
//insert reqcode(code,descript,descript1) select 'SM','吸烟房','Smoking Room';
//insert reqcode(code,descript,descript1) select 'RU','客房雨伞','Room Umbrella';
//insert reqcode(code,descript,descript1) select 'HF','高楼层','High Floor';
//insert reqcode(code,descript,descript1) select 'FAX','传真机','Fax Machine';
//insert reqcode(code,descript,descript1) select 'WC','轮椅','Wheelchair';
//insert reqcode(code,descript,descript1) select 'LO','迟退房','Late Check-out Requested';
//insert reqcode(code,descript,descript1) select 'LIM','豪华轿车','Limo Requested';


// --------------------------------------------------------------------
//	Reservation restype : 预订类型  -- 老版本 resmode
// --------------------------------------------------------------------
if exists(select * from sysobjects where name = "restype")
   drop table restype;
create table restype
(
	code		   char(3)						not null,
	descript    varchar(16)					not null,
	descript1   varchar(20)	default ''	not null,
	definite		char(1)		default 'F'	not null,	// 是否确认预订 definite or tentative
	req_arr		char(1)		default 'F'	not null,	// 是否确认抵达时间 mandatory arr. time
	req_card		char(1)		default 'F'	not null,	// 信用卡
	req_credit	char(1)		default 'F'	not null,	// 押金
	scope			char(10)		default 'FGM'	not null,	// F散客 G团体 M会议 
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
//insert restype(code,descript,descript1,definite,mat) select '0', '在住预订', 'Checked In','T','F'
//insert restype(code,descript,descript1,definite,mat) select '1', '保留到6点', '6 P.M.','T','F'
//insert restype(code,descript,descript1,definite,mat) select '2', 'Gtd. Credit Card', 'Gtd. Credit Card','T','F'
//insert restype(code,descript,descript1,definite,mat) select '3', 'Gtd. Company', 'Gtd. Company','T','F'
//insert restype(code,descript,descript1,definite,mat) select '4', 'Gtd. Voucher', 'Gtd. Voucher','T','F'
//insert restype(code,descript,descript1,definite,mat) select '5', 'Block Definite', 'Block Definite','T','F'
//insert restype(code,descript,descript1,definite,mat) select '6', 'Block Tentative', 'Block Tentative','F','F'
//insert restype(code,descript,descript1,definite,mat) select '7', 'Group Pickup', 'Group Pickup','T','F'
//insert restype(code,descript,descript1,definite,mat) select '8', 'Deposit Requested', 'Deposit Requested','T','F'
//;


// ------------------------------------------------------------------------------
//	Reservation countrycode : 国籍
// ------------------------------------------------------------------------------
// exec sp_rename countrycode, a_countrycode;
if exists(select * from sysobjects where name = "countrycode")
   drop table countrycode;
create table countrycode
(
   code			char(3)							not null,
   descript 	varchar(30)						not null,
   descript1 	varchar(40)	default ''		not null,
   helpcode  	varchar(20) default '' 		not null,  	/* 助记码*/
   short			char(3)		default ''		not null,	/* 缩写 */
   iso			char(3)		default ''		not null,	/* ISO Code */
   addfmt		char(1)		default ''		not null,	/* 信封地址代码 */
	worldcode	char(3)  	default '' 		not null,
	lang			char(1)		default 'E'		not null,		/* 语种 */
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
//  basecode : race  -- 民族
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='race')
	delete basecode_cat where cat='race';
insert basecode_cat select 'race', '民族', 'race', 2;
delete basecode where cat='race';
insert basecode(cat,code,descript,descript1) 
	select 'race', code, descript, hlpcode from racecode;


// --------------------------------------------------------------------------
//  basecode : occupation  -- 职业
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='occupation')
	delete basecode_cat where cat='occupation';
insert basecode_cat select 'occupation', '职业', 'occupation', 2;
delete basecode where cat='occupation';
insert basecode(cat,code,descript,descript1) 
	select 'occupation', code, descript, '' from jobcode;



// --------------------------------------------------------------------------
//  basecode : idcode  -- 证件
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='idcode')
	delete basecode_cat where cat='idcode';
insert basecode_cat select 'idcode', '证件', 'idcode', 3;
delete basecode where cat='idcode';
insert basecode(cat,code,descript,descript1) 
	select 'idcode', code, descript, '' from idcode;


// --------------------------------------------------------------------------
//  basecode : visaid  -- 签证类别
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='visaid')
	delete basecode_cat where cat='visaid';
insert basecode_cat select 'visaid', '签证类别', 'visaid', 3;
delete basecode where cat='visaid';
insert basecode(cat,code,descript,descript1) 
	select 'visaid', code, descript, '' from asscode;



// --------------------------------------------------------------------------
//  basecode : visaunit  -- 签证机关
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='visaunit')
	delete basecode_cat where cat='visaunit';
insert basecode_cat select 'visaunit', '签证机关', 'visaunit', 4;
delete basecode where cat='visaunit';
insert basecode(cat,code,descript,descript1) 
	select 'visaunit', code, descript, '' from assunit;



// --------------------------------------------------------------------------
//  basecode : rjcode  -- 入境口岸
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='rjcode')
	delete basecode_cat where cat='rjcode';
insert basecode_cat select 'rjcode', '入境口岸', 'rjcode', 3;
delete basecode where cat='rjcode';
insert basecode(cat,code,descript,descript1) 
	select 'rjcode', code, descript, '' from rjcode;



// ------------------------------------------------------------------------------
//	Reservation prvcode : 省
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
   short			char(3)		default ''	not null,	// 缩写
	s_zip			char(6)		default ''	not null,	// 邮政编码
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
//	Reservation cntcode : 行政区域
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
	s_zip			char(6)		default ''	not null,	// 邮政编码
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
//	Reservation srccode : 来源
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
//insert srccode(code,descript,descript1,grp) select 'LOC','本地公司','Local company','COMPANY'
//insert srccode(code,descript,descript1,grp) select 'NAC','国内公司','National company','COMPANY'
//insert srccode(code,descript,descript1,grp) select 'INC','国外公司','Internet. company','COMPANY'
//insert srccode(code,descript,descript1,grp) select 'LOA','本地旅行社','Local agent','AGENT'
//insert srccode(code,descript,descript1,grp) select 'NAA','国内旅行社','National agent','AGENT'
//insert srccode(code,descript,descript1,grp) select 'INA','国外旅行社','Internet agent','AGENT'
//insert srccode(code,descript,descript1,grp) select 'RES','预订系统','Reservation system','MISCELLANEOUS'
//insert srccode(code,descript,descript1,grp) select 'IND','散客','Individual','MISCELLANEOUS'
//insert srccode(code,descript,descript1,grp) select 'A/R','应收客户','Accounts receivable','ACCOUNT'
//insert srccode(code,descript,descript1,grp) select 'RSO','地区销售','Regional sales office','MISCELLANEOUS'
//insert srccode(code,descript,descript1,grp) select 'SHO','展会','Showcase','MISCELLANEOUS'
//insert srccode(code,descript,descript1,grp) select 'RBU','回头客','Repeat business','MISCELLANEOUS'
//insert srccode(code,descript,descript1,grp) select 'WLK','直接上门','Walk in','MISCELLANEOUS'
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
   rollback trigger with raiserror 20000 "增加代码错误HRY_MARK"

-----------------------------
-- 描述
-----------------------------
if rtrim(@des) is null or  rtrim(@des1) is null 
   rollback trigger with raiserror 20000 "请输入描述HRY_MARK"
if charindex("'", @des)>0 or charindex('"', @des)>0 or charindex("'", @des1)>0 or charindex('"', @des1)>0
   rollback trigger with raiserror 20000 "描述里禁止使用英文引号HRY_MARK"
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
-- 描述
-----------------------------
if rtrim(@des) is null or  rtrim(@des1) is null 
   rollback trigger with raiserror 20000 "请输入描述HRY_MARK"
if charindex("'", @des)>0 or charindex('"', @des)>0 or charindex("'", @des1)>0 or charindex('"', @des1)>0
   rollback trigger with raiserror 20000 "描述里禁止使用英文引号HRY_MARK"
end
;




// ------------------------------------------------------------------------------
//	Reservation mktcode : 市场码
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
   rollback trigger with raiserror 20000 "增加代码错误HRY_MARK"

-----------------------------
-- 描述
-----------------------------
if rtrim(@des) is null or  rtrim(@des1) is null 
   rollback trigger with raiserror 20000 "请输入描述HRY_MARK"
if charindex("'", @des)>0 or charindex('"', @des)>0 or charindex("'", @des1)>0 or charindex('"', @des1)>0
   rollback trigger with raiserror 20000 "描述里禁止使用英文引号HRY_MARK"
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
-- 描述
-----------------------------
if rtrim(@des) is null or  rtrim(@des1) is null 
   rollback trigger with raiserror 20000 "请输入描述HRY_MARK"
if charindex("'", @des)>0 or charindex('"', @des)>0 or charindex("'", @des1)>0 or charindex('"', @des1)>0
   rollback trigger with raiserror 20000 "描述里禁止使用英文引号HRY_MARK"
end
;




// ------------------------------------------------------------------------------
//	greeting : 称呼
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