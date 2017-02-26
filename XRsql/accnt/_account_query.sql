if exists(select * from sysobjects where name = "account_query")
   drop table account_query;

create table account_query
(
	code				char(3)			not null,							/*代码*/
	name1				char(30)			not null,							/*中文描述*/
	name2				char(30)			null,									/*英文描述*/
	pccode			varchar(255)	null,									/*费用码*/
	argcode			varchar(255)	null,									/*账单编码*/
	ref				char(1)			null,									/*0:所有;1.费用;2.付款*/
	reason			char(30)			null,									/*优惠理由*/
	crradjt			char(30)			null,									/*标志*/
	modu_id			char(30)			null,									/*模块号*/
	tofrom			char(30)			null,									/*转账方式*/
	mode				char(30)			null,									/*房费类型*/
	billno			char(30)			null,									/*结账单号*/
	amount			char(30)			null,									/*金额范围*/
	query_table		char(30)			null,									/*数据源*/
	query_where		varchar(255)	null,									/*条件*/
	query_order		varchar(255)	null									/*排序*/
)
exec   sp_primarykey account_query, code
create unique index index1 on account_query(code)
;
insert account_query values("010", "费用", "", null, "-98-99", "1", null, null, null, null, null, null, null, "gltemp", "", " roomno, accnt, number ")
insert account_query values("020", "款项", "", null, "+98+99", "2", null, null, null, null, null, null, null, "gltemp", "", " roomno, accnt, number ")
insert account_query values("030", "------------------------------", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
insert account_query values("040", "手工账", "", "-000", null, "0", null, "+  +AD+LT+LA", "+02", "-TO-FM", null, null, null, "gltemp", "", " pccode,accnt,servcode ")
insert account_query values("050", "调整账(所有)", "", null, null, "0", null, "+AD+LA", "+02", null, null, null, null, "gltemp", " ", " pccode,roomno,accnt,servcode ")
insert account_query values("060", "调整账(调加)", "", null, null, "0", null, "+AD+LA", "+02", null, null, null, ">=0", "gltemp", " ", " pccode,roomno,accnt,servcode ")
insert account_query values("070", "调整账(调减)", "", null, null, "0", null, "+AD+LA", "+02", null, null, null, "<0", "gltemp", " ", " pccode,roomno,accnt,servcode ")
insert account_query values("080", "------------------------------", null, null, null, null, null, null, null,null, null, null, null, null, null, null)
insert account_query values("090", "对冲账", "", null, null, "0", null, "+C +CO+CA", null, null, null, null, null, "gltemp", " ", " pccode,roomno,accnt,servcode ")
insert account_query values("100", "------------------------------", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
insert account_query values("110", "优惠账(所有)", "", null, "", "0", null, null, null, null, null, null, null, "gltemp", " ", " pccode,roomno,accnt,servcode ")
insert account_query values("120", "优惠账(手工)", "", "-02", "", "0", null, null, null, null, null, null, null, "gltemp", "", " pccode,roomno,accnt,servcode ")
insert account_query values("130", "------------------------------", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
insert account_query values("140", "稽核房费", "", "+000", null, "1", null, "-C -CO", null, null, "+J+j", null, null, "gltemp", "", " pccode,roomno,accnt,servcode ")
insert account_query values("150", "半价稽核房费", "", "+000", null, "1", null, "-C -CO", null, null, "+j", null, null, "gltemp", "", " pccode,roomno,accnt,servcode ")
insert account_query values("160", "全免房费(含自用房)", "", "+000", null, "1", null, "-C -CO", null, null, "+J+j+C", null, null, "gltemp", " ", " pccode,roomno,accnt,servcode ")
insert account_query values("170", "日租加收全天房费", "", "+000", null, "1", null, "-C -CO", null, null, "+N", null, null, "gltemp", " ", " pccode,roomno,accnt,servcode ")
insert account_query values("180", "日租加收半天房费", "", "+000", null, "1", null, "-C -CO", null, null, "+P", null, null, "gltemp", "", " pccode,roomno,accnt,servcode ")
insert account_query values("190", "手工房费", "", "+010", null, "", null, "-C -CO", null, null, "+S+T", null, null, "gltemp", "", " pccode,roomno,accnt,servcode ")
insert account_query values("200", "------------------------------", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
insert account_query values("220", "结账账目", "", null, null, "0", null, null, null, null, null, null, null, "outtemp", " 1=1 ", " pccode,roomno,accnt,servcode ")
insert account_query values("230", "------------------------------", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
insert account_query values("240", "按行转账", "", null, null, "0", null, "-CT-LC", null, "+TO+FM", null, null, null, "gltemp", null, " roomno,accnt,tofrom,accntof,number ")
insert account_query values("250", "部分转账", "", null, null, "0", null, "+CT+LC", null, "+TO+FM", null, null, null, "gltemp", null, " roomno,accnt,tofrom,accntof,number ")
insert account_query values("530", "------------------------------", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
insert account_query values("540", "电话转账明细", "", null, null, "0", null, null, "+05", null, null, null, null, "gltemp", "", " pccode,roomno,accnt,servcode ")
insert account_query values("550", "综合收银转账明细", "", null, null, "0", null, null, "+04", null, null, null, null, "gltemp", "", " pccode,roomno,accnt,servcode ")
insert account_query values("560", "商务中心转账明细", "", null, null, "0", null, null, "+06", null, null, null, null, "gltemp", "", " pccode,roomno,accnt,servcode ")
insert account_query values("799", "----------用户自定义----------", null, null, null, null, null, null, null, null, null, null, null, null, null, null)
;

insert basecode values ('account_table',	'gltemp',		'上日账务(所有)',	'',	'T',	'F',	10,	'');
insert basecode values ('account_table',	'gltemp_f',		'上日账务(宾客)',	'',	'T',	'F',	20,	'');
insert basecode values ('account_table',	'gltemp_a',		'上日账务(AR账)',	'',	'T',	'F',	30,	'');
insert basecode values ('account_table',	'taccount',		'本日账务(所有)',	'',	'T',	'F',	40,	'');
insert basecode values ('account_table',	'taccount_f',	'本日账务(宾客)',	'',	'T',	'F',	50,	'');
insert basecode values ('account_table',	'taccount_a',	'本日账务(AR账)',	'',	'T',	'F',	60,	'');
insert basecode values ('account_table',	'outtemp',		'结账账务(所有)',	'',	'T',	'F',	70,	'');
insert basecode values ('account_table',	'outtemp_f',	'结账账务(宾客)',	'',	'T',	'F',	80,	'');
insert basecode values ('account_table',	'outtemp_a',	'结账账务(AR账)',	'',	'T',	'F',	90,	'');
insert basecode values ('account_table',	'account',		'当前账务(所有)',	'',	'T',	'F',	100,	'');
insert basecode values ('account_table',	'account_f',	'当前账务(宾客)',	'',	'T',	'F',	110,	'');
insert basecode values ('account_table',	'account_a',	'当前账务(AR账)',	'',	'T',	'F',	120,	'');
insert basecode values ('account_table',	'haccount',		'历史账务(所有)',	'',	'T',	'F',	130,	'');
insert basecode values ('account_table',	'haccount_f',	'历史账务(宾客)',	'',	'T',	'F',	140,	'');
insert basecode values ('account_table',	'haccount_a',	'历史账务(AR账)',	'',	'T',	'F',	150,	'');
insert basecode values ('account_table',	'aaccount',		'所有账务(所有)',	'',	'T',	'F',	160,	'');
insert basecode values ('account_table',	'aaccount_f',	'所有账务(宾客)',	'',	'T',	'F',	170,	'');
insert basecode values ('account_table',	'aaccount_a',	'所有账务(AR账)',	'',	'T',	'F',	180,	'');
//
insert into basecode values ('accntcode_crradjt','AD','调整账','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','C','被冲的账','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','CO','冲账','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','CA','被冲的调整账','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','LT','按行转账标志','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','LA','被转的调整账','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','LL','被转的转入账(按行转入)','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','  ','普通账','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','CT','部分转账标志','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_crradjt','LC','被转的转入账(部分转入)','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_tofrom','TO','转出账务','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_tofrom','FM','转入账务','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_mode','J','稽核房费(全天)','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_mode','j','稽核房费(半天)','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_mode','B','补过房费(全天)','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_mode','b','补过房费(半天)','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_mode','P','半天房费','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_mode','N','全天房费','', 'T', 'F', 10, '');
insert into basecode values ('accntcode_mode','S','手工房费','', 'T', 'F', 10, '');
