//CREATE TABLE sys_column_show (
//	window char(50),
//	column char(20),
//	descript char(50),
//	descript1 char(50),
//	syntax char(32766),
//	sequance float,
//	ctype char(4),
//	exp char(100));
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'cusid',
	'单位号',
	'单位号',
	'a.cms_cusid:单位号=8=[general]=alignment="2";',
	100,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'amount',
	'金额',
	'金额',
	'a.cms0sum:金额=8=0.00=alignment="1";',
	110,
	'mone',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'nights',
	'房晚',
	'房晚',
	'a.w_or_hsum:房晚=8=0.0=alignment="2";',
	120,
	'mone',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'payby',
	'支付人',
	'支付人',
	'a.payby:支付人=8=[general]=alignment="2";',
	130,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'paydate',
	'支付日期',
	'支付日期',
	'a.paydate:日期=10=yyyy/mm/dd=alignment="2";',
	140,
	'date',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'cbydate',
	'操作日期',
	'操作日期',
	'a.cbydate:操作日期=10=yyyy/mm/dd=alignment="2";',
	160,
	'date',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'billno',
	'单据号',
	'单据号',
	'a.billno:单据号=8=[general]=alignment="2";',
	170,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'sno',
	'公司编码',
	'公司编码',
	'b.sno:公司编码=8=[general]=alignment="2";',
	180,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'name',
	'名称',
	'名称',
	'b.name:名称2=20=[general]=alignment="0";',
	185,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'name2',
	'名称2',
	'名称2',
	'b.name2:名称2=20=[general]=alignment="0";',
	190,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'country',
	'国家',
	'国家',
	'b.country:国家=8=[general]=alignment="2";',
	200,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'town',
	'城市',
	'城市',
	'b.town:城市=8=[general]=alignment="2";',
	210,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'street',
	'街道',
	'街道',
	'b.street:街道=18=[general]=alignment="0";',
	220,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'email',
	'电邮',
	'电邮',
	'b.email:电邮=12=[general]=alignment="0";',
	230,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'phone',
	'电话',
	'电话',
	'b.phone:电话=12=[general]=alignment="0";',
	250,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'fax',
	'传真',
	'传真',
	'b.fax:传真=12=[general]=alignment="0";',
	260,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'liason',
	'联系人',
	'联系人',
	'b.liason:联系人=18=[general]=alignment="0";',
	270,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'liason1',
	'联系方式',
	'联系方式',
	'b.liason1:联系方式=18=[general]=alignment="0";',
	280,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'code1',
	'房价码',
	'房价码',
	'b.code1:房价码=8=[general]=alignment="2";',
	290,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'iata',
	'IATA',
	'IATA',
	'b.iata:IATA=8=[general]=alignment="2";',
	300,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'araccnt1',
	'应收帐户',
	'应收帐户',
	'b.araccnt1:应收帐户=8=[general]=alignment="2";',
	310,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'cby',
	'操作人',
	'操作人',
	'a.cby:操作人=8=[general]=alignment="2";',
	150,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'mobile',
	'手机',
	'手机',
	'b.mobile:手机=12=[general]=alignment="0";',
	240,
	'char',
	NULL);
INSERT INTO sys_column_show VALUES (
	'w_gds_rep_comm2',
	'saleid',
	'销售员',
	'销售员',
	'b.saleid:单据号=8=[general]=alignment="2";',
	320,
	'char',
	NULL);
