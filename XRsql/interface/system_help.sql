drop table system_help;
CREATE TABLE system_help
 (
	appid 		char(1)		default '' not null,
	descript		char(50)		default '' not null,
	descript1	char(100)	default '' null,
	path 			char(100)	default '' not null,
	flag 			char(1)		default '' not null,
	sequence 	integer		default 0  not null			
);

exec sp_primarykey system_help,appid,flag,sequence
create unique index  system_help on system_help(appid,flag,sequence)
;

INSERT INTO system_help VALUES (
	'3',
	'定量分析',
	'定量分析_e',
	'c:\1.htm',
	'I',
	0);
INSERT INTO system_help VALUES (
	'3',
	'餐饮开单结帐',
	'餐饮开台结帐_e',
	'c:\2.htm',
	'S',
	1);
INSERT INTO system_help VALUES (
	'3',
	'餐饮系统帮助',
	'POS SYSTEM HELP',
	'c:\pos\餐饮系统帮助.htm',
	'S',
	0);
INSERT INTO system_help VALUES (
	'3',
	'餐饮预订接待',
	'餐饮预订接待_e',
	'',
	'S',
	2);
INSERT INTO system_help VALUES (
	'3',
	'餐饮吧台进销存',
	'餐饮吧台进销存_e',
	'',
	'S',
	3);
INSERT INTO system_help VALUES (
	'3',
	'餐饮菜式管理',
	'餐饮菜式管理_e',
	'',
	'S',
	4);
INSERT INTO system_help VALUES (
	'3',
	'餐饮信息查询管理',
	'餐饮信息查询管理_e',
	'',
	'S',
	5);
INSERT INTO system_help VALUES (
	'3',
	'模式定义',
	'模式定义_e',
	'',
	'I',
	1);
INSERT INTO system_help VALUES (
	'3',
	'餐位图',
	'餐位图_e',
	'',
	'I',
	2);
INSERT INTO system_help VALUES (
	'3',
	'转登记',
	'转登记_e',
	'',
	'I',
	3);
INSERT INTO system_help VALUES (
	'3',
	'典型餐单',
	'典型餐单_e',
	'',
	'I',
	4);
INSERT INTO system_help VALUES (
	'3',
	'重结',
	'重结_e',
	'',
	'I',
	5);
INSERT INTO system_help VALUES (
	'3',
	'预订金',
	'预订金_e',
	'',
	'I',
	6);
INSERT INTO system_help VALUES (
	'3',
	'排行榜',
	'排行榜_e',
	'',
	'I',
	7);
INSERT INTO system_help VALUES (
	'3',
	'套菜（标准菜）',
	'套菜（标准菜 ）_e',
	'',
	'I',
	8);
INSERT INTO system_help VALUES (
	'3',
	'配料管理',
	'配料管理_e',
	'',
	'I',
	9);
INSERT INTO system_help VALUES (
	'3',
	'台位管理（桌号定义）',
	'台位管理（桌号定义）_e',
	'',
	'I',
	10);
INSERT INTO system_help VALUES (
	'3',
	'吧台菜码维护',
	'吧台菜码维护_e',
	'',
	'I',
	11);
INSERT INTO system_help VALUES (
	'3',
	'时段定义',
	'时段定义_e',
	'',
	'I',
	12);
INSERT INTO system_help VALUES (
	'3',
	'收银点',
	'收银点_e',
	'',
	'I',
	13);
INSERT INTO system_help VALUES (
	'3',
	'工作站',
	'工作站_e',
	'',
	'I',
	14);
INSERT INTO system_help VALUES (
	'3',
	'营业点',
	'营业点_e',
	'',
	'I',
	15);
INSERT INTO system_help VALUES (
	'3',
	'月结',
	'月结_e',
	'',
	'I',
	16);
INSERT INTO system_help VALUES (
	'3',
	'喜好菜式',
	'喜好菜式_e',
	'',
	'I',
	17);
