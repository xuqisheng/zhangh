//--------------------------------------------------------------------------------
// 快速登记临时表
//
//		集合了 master, guest 有关内容
//		快速登记每次每房入住一个人 !
//--------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "master_quick" and type="U")
	drop table master_quick;
//create table master_quick
//(
//	modu_id		char(2)							not null,
//	pc_id			char(4)							not null,
//	ratemode		char(10)		default ''		not null,
//	type		   char(3)		default ''		not null,	//房间类型
//	roomno		char(5)		default ''		not null,	//房号
//	arr			datetime	   					null,			//到店日期=arrival
//	dep			datetime	   					null,			//离店日期=departure
//	num			int	   						null,			//天数
//	cusno			char(10)							null,
//	agent			char(10)							null,
//	source		char(10)							null,
//	market		char(3)							null,			//市场码
//	src			char(3)							null,			//来源
//	channel		char(3)							null,			//渠道
//	qtrate		money			default 0		null,			//房间报价
//	rmrate		money			default 0		null,			//协议价
//	setrate		money			default 0		null,			//实价
//	rtreason	   char(3)		default ''		null,			//房价优惠理由(cf.rtreason.dbf)
//	discount	   money			default 0		not null,	//优惠额
//	discount1	money			default 0		not null,	//优惠比例
//
//	name		   varchar(50)	 					not null,	//姓名: 本名 
//	fname       varchar(30)	default ''		not null, 	//英文名 
//	lname			varchar(30)	default '' 		not null,	//英文姓 
//	name2		   varchar(50)	default '' 		not null,	//扩充名字 
//	name3		   varchar(50)	default '' 		not null,	//扩充名字 
//   idcls       char(3)     default ''		not null,   //证件类别
//	ident			char(20)		default ''		not null,	//证件号码
//	sex			char(1)		default '1'		not null,   //性别:M,F 
//	lang			char(1)		default 'C'		not null,	//语种 
//	birth       datetime							null,			//生日with format mm/dd
//	vip			char(3)		default '0'		not null,  	//vip 
//	nation		char(3)		default ''		not null,	//国籍或地区码
//	pcusno		char(7)		default ''		not null,	//单位号 
//	punit       varchar(60)	default ''		not null,	//单位 
//	street	   varchar(60)	default ''		not null,	//住址 
//	birthplace	char(6)							null,			//籍贯
//	haccnt		char(7)							null,			//历史帐号
//
//	paycode		char(5)							null,			//结算方式
//	exp_s			varchar(10)						null,
//	applicant	varchar(30)						null,			//单位/委托单位
//	master	   char(10)							null,			//联房标志账号 
//	pcrec		   char(10)							null,			//联房标志账号 
//	secret		char(1) 		default 'F'		null,  		//保密 
//	phonesta	   char(1)							null,			//分机等级
//	vodsta	   char(1)							null,			//分机等级
//	intsta	   char(1)							null,			//分机等级
//	ref			varchar(255)					null,			//备注
//	resby			char(10)							not null,	//登记员工号=reserved by
//	reserved		datetime							not null,	//订单输入时间,用系统时间,不可修改
//	accnt			char(10)							not null		//帐号
//)
//exec sp_primarykey master_quick, modu_id, pc_id, roomno
//create unique index  master_quick on master_quick(modu_id, pc_id, roomno)
//;


CREATE TABLE master_quick 
(
    modu_id   char(2)     NOT NULL,
    pc_id     char(4)     NOT NULL,
    accnt     char(10)    NULL,
    haccnt    char(7)     DEFAULT '' NOT NULL,
    type      char(3)     DEFAULT space(3) NULL,
    roomno    char(5)     DEFAULT space(5) NULL,
    arr       datetime    NULL,
    dep       datetime    NULL,
    num       int         NULL,
    class     char(1)     DEFAULT '' NOT NULL,
    src       char(3)     DEFAULT '' NOT NULL,
    market    char(3)     DEFAULT '' NOT NULL,
    restype   char(3)     DEFAULT '' NOT NULL,
	 channel	  char(3)     DEFAULT '' NOT NULL,
    ratecode  char(10)    DEFAULT '' NOT NULL,
    packages  char(20)    DEFAULT '' NOT NULL,
    master    char(10)    DEFAULT '' NOT NULL,
    saccnt    char(10)    DEFAULT '' NOT NULL,
    pcrec     char(10)    DEFAULT '' NOT NULL,
    resno     varchar(10) DEFAULT '' NOT NULL,
    extra     char(30)    DEFAULT '' NOT NULL,
    qtrate    money       DEFAULT 0 NULL,
    setrate   money       DEFAULT 0 NULL,
    rtreason  char(3)     DEFAULT ' ' NULL,
    discount  money       DEFAULT 0 NOT NULL,
    discount1 money       DEFAULT 0 NOT NULL,
    name      varchar(50) NOT NULL,
    lname     varchar(30) DEFAULT "" NULL,
    nation    char(3)     DEFAULT '' NULL,
    resby     char(10)    DEFAULT '' NOT NULL,
    restime   datetime    NULL,
    sta       char(1)     NULL
)
EXEC sp_primarykey master_quick, modu_id,pc_id,roomno
CREATE UNIQUE INDEX index1 ON master_quick(modu_id,pc_id,type,roomno)
;