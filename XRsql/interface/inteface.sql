drop table interface_group;
CREATE TABLE interface_group 
(
	id 		char(2)		default '' not null,
	descript char(30)		default '' not null,
	remark 	char(50)		default '' null
)
exec sp_primarykey interface_group,id
create unique index  interface_group on interface_group(id)
;



drop table interface;
create table interface
(
	groupid	char(2)		default ''	not null,
	id			char(2)		default '1'	not null,
	sta		char(1)		default 'F'	not null,   //运行标记
	pc_id		char(4)		default ''  not null,   //运行IP
	descript		char(30)		default ''	not null,
	descript1	char(50)		default ''	null,
	window	char(40)		default ''	not null,
	tag		char(20)		default ''  null,
	com		char(2)		default ''  not null,
	svr_ip   char(40)		default ''	null,     //服务器IP
	remark	char(50)		default ''	null,
	start_i	datetime		null,
	start_c	datetime		null
)
exec sp_primarykey interface,groupid,id
create unique index  interface on interface(groupid,id)

;

drop  table interface_option;
create table interface_option
(
	groupid				char(2)		default ''	not null,
	interface_id		char(2)	default '0'	not null,
	code					char(2)	default ''	not null,
	descript				char(20)	default ''	not null,
	value					char(50) DEFAULT ''  NOT NULL,
	remark				char(60)					null
)
exec sp_primarykey interface_option,groupid,interface_id,code
create unique index  interface_option on interface_option(groupid,interface_id,code)
	

;

drop table interface_pcid;
create table interface_pcid
(
	groupid	         char(2)		default ''	not null,
	interface_id		char(2)	default ''	not null,
	pc_id					char(4)	default ''	not null,
	sta					char(1)	default 'F'	not null
)

exec sp_primarykey interface_pcid,groupid,interface_id,pc_id
create unique index  interface_pcid on interface_pcid(groupid,interface_id,pc_id)

;
drop table room_door;
create table room_door
(
	pc_id		char(4)		default ''  not null,
	empno		char(10)		default ''	not null,
	accnt		char(10)		default ''	not null,
	room		char(5)		default ''	not null,
	cardno	char(10)		default ''	not null,
	sta1		char(10)		default ''	not null,
	sta2		char(3)		default ''	not null,
	times		integer		default 0	not null
)
exec sp_primarykey room_door,pc_id,accnt,room,cardno
create unique index room_door on room_door(pc_id,accnt,room,cardno)
;

drop table door_log;
create table door_log
(	id			char(10)		not null,
	pc_id		char(4)		not null,
	empno		char(10)		not null,
	bdate		datetime		not null,
	date0		datetime		not null,
	room		char(5)		default ''	not null,
	cardno	char(8)		default ''	not null,
	sta		char(10)		default ''	not null,
	remark	char(30)		default ''	not null
)
exec sp_primarykey door_log,id,bdate
create unique index door_log on door_log(id,bdate)
;
// 餐饮接口：数据接收日志
drop table ncr;
create table ncr
(
		bdate			datetime    not null,
	   id				char(10)    not null,
		source		text        not null,
		result		char(50)		not null,
		times			datetime			not null
)
;
exec sp_primarykey ncr,bdate,id
create unique index  ncr on ncr(bdate,id)
;


drop table user_data;
create table user_data
(
	data			char(20) default ''	not null,
	remark		char(60) default ''  null
)
exec sp_primarykey user_data,data
create unique index  user_data on user_data(data)
;

INSERT INTO user_data VALUES ('RemotePort','服务器端口');
INSERT INTO user_data VALUES ('LocalPort','本机端口');
INSERT INTO user_data VALUES ('LocalDotAddr','本机地址');
INSERT INTO user_data VALUES ('Debug','');
INSERT INTO user_data VALUES ('ShowIcon','');
INSERT INTO user_data VALUES ('CommPort','串口');
INSERT INTO user_data VALUES ('baud_rate','波特率');
INSERT INTO user_data VALUES ('bit','数据位');
INSERT INTO user_data VALUES ('parity','奇偶校验');
INSERT INTO user_data VALUES ('stop','停止位');
INSERT INTO user_data VALUES ('handshaking','握手协议');
INSERT INTO user_data VALUES ('rthreshold','R阀值');
INSERT INTO user_data VALUES ('RemoteHost','服务器地址');
INSERT INTO user_data VALUES ('server_ip','允许运行接口的服务器地址');
INSERT INTO user_data VALUES ('empty_select','漏单的选择 1,转入消费账,<>1则有提示和警报');
INSERT INTO user_data VALUES ('autologin','自动登陆的掺数,T是自动,<> T 手动');
INSERT INTO user_data VALUES ('phcode','特殊号码提醒,格式如:110,120,122,119');
INSERT INTO user_data VALUES ('times','长时间不动作的提醒,格式:分钟(时间段)#分钟(时间段)如:60(0600-');
INSERT INTO user_data VALUES ('sthreshold','S阀值');
INSERT INTO user_data VALUES ('dtrenable','');
INSERT INTO user_data VALUES ('rtsenable','');
INSERT INTO user_data VALUES ('nulldiscard','是否丢掉空值');
INSERT INTO user_data VALUES ('inputlen','接收字符串的长度');
INSERT INTO user_data VALUES ('outbuffersize','串口发送缓存大小');
INSERT INTO user_data VALUES ('inbuffersize','串口接收缓存大小');


drop table door_int;
create table door_int
(
	data			char(3)  default ''	not null,
	name1			char(40) default ''	not null,
	remark		char(40) default ''  not null
)
exec sp_primarykey door_int,data
create unique index  door_int on door_int(data)
;

drop table room_device;
create table room_device
(
	deviceid		integer  default 0	not null,
	room			char(40) default ''	not null,
	remark		char(40) default ''  not null
)
exec sp_primarykey room_device,deviceid
create unique index  room_device on room_device(deviceid)
;



// 餐饮接口：付款码和费用码对照表
drop table pos_int_pccode ;
CREATE TABLE pos_int_pccode 
(
	class 			char(1),				// 1,付款码 2,费用码
	pccode 			char(5),				// 
	int_code 		char(5),				// 付款码 or 费用码
	name1 			char(20),
	name2 			char(30)		null,
	shift				char(1)		null,
	pos_pccode		char(3)  	null,
	itemdef			char(3)		null  //保留

);

exec sp_primarykey pos_int_pccode,class,pccode
create unique index index1 on pos_int_pccode(class, pccode)
;

drop table interface_operate;
create table interface_operate
(
	appid			char(20)	default ''	not null,
	groupid		char(2)	default ''  not null,
	id				char(2)  default ''  not null,
	code			char(20) default ''  not null,			
	descript		char(20)	default ''  not null,
	descript1   char(40) default ''  not null,
	wtype			char(20) default ''  not null,
	window		char(60)	default ''  not null,
	parm			char(60) default ''	null,
	event			char(30)	default ''  not null,
	son			char(1)  default ''  not null,
	sequence		integer	default 0   not null,
	display		char(1)  default 'T' null,
	content		text		default ''  null
)
exec sp_primarykey interface_operate,code
create unique index  interface_operate on interface_operate(code)
;




drop table interface_son;
create table interface_son
(
	groupid		char(2)	default ''  not null,
	id				char(2)  default ''  not null,
	code			char(20) default ''  not null,
	item			char(20) default ''  not null,			
	descript		char(20)	default ''  not null,
	descript1   char(40) default ''  not null,
	wtype			char(20) default ''  not null,
	window		char(60)	default ''  not null,
	parm			char(60) default ''	null,
	event			char(30)	default ''  not null,
	sequence		integer	default 0   null,
	content		text		default ''  null
)
exec sp_primarykey interface_son,item
create unique index  interface_son on interface_son(item)
;







