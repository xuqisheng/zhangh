if not exists(select 1 from sysoption where catalog='deal_data' and item='checkroom')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'checkroom',
		'31',
		'31',
		'夜审数据清除，相关数据保留天数：查房与报房',
		'夜审数据清除，相关数据保留天数：查房与报房',
		'GDS',
		'1-1-2005 0:0:0.000',
		'T',
		'');
if not exists(select 1 from sysoption where catalog='deal_data' and item='discrepant_room')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'discrepant_room',
		'7',
		'7',
		'夜审数据清除，相关数据保留天数：客房中心例行查房，产生矛盾房',
		'夜审数据清除，相关数据保留天数：客房中心例行查房，产生矛盾房',
		'GDS',
		'1-1-2005 0:0:0.000',
		'T',
		'');
if not exists(select 1 from sysoption where catalog='deal_data' and item='message_x')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'message_x',
		'90',
		'90',
		'夜审数据清除，相关数据保留天数：留言，消息',
		'夜审数据清除，相关数据保留天数：留言，消息',
		'ZHJ',
		'1-1-2005 0:0:0.000',
		'T',
		'');
if not exists(select 1 from sysoption where catalog='deal_data' and item='mktsummaryrep_detail')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'mktsummaryrep_detail',
		'40',
		'40',
		'夜审数据清除，相关数据保留天数：市场码统计明细记录',
		'夜审数据清除，相关数据保留天数：市场码统计明细记录',
		'GDS',
		'1-1-2005 0:0:0.000',
		'T',
		'');
if not exists(select 1 from sysoption where catalog='deal_data' and item='package_detail')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'package_detail',
		'40',
		'40',
		'夜审数据清除，相关数据保留天数：包价使用明细记录',
		'夜审数据清除，相关数据保留天数：包价使用明细记录',
		'GDS',
		'1-1-2005 0:0:0.000',
		'T',
		'');
if not exists(select 1 from sysoption where catalog='deal_data' and item='qroom')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'qroom',
		'30',
		'30',
		'夜审数据清除，相关数据保留天数：前台 Q-Room',
		'夜审数据清除，相关数据保留天数：前台 Q-Room',
		'GDS',
		'1-1-2005 0:0:0.000',
		'T',
		'');
if not exists(select 1 from sysoption where catalog='deal_data' and item='rmpostbucket')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'rmpostbucket',
		'365',
		'40',
		'夜审数据清除，相关数据保留天数：夜审房费入账记录',
		'夜审数据清除，相关数据保留天数：夜审房费入账记录',
		'GDS',
		'1-1-2005 0:0:0.000',
		'T',
		'');

if not exists(select 1 from sysoption where catalog='deal_data' and item='lgfl')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'lgfl',
		'60',
		'60',
		'夜审数据清除，相关数据保留天数：操作日志',
		'夜审数据清除，相关数据保留天数：操作日志',
		'GDS',
		'12-1-2006 0:0:0.000',
		'T',
		'');

if not exists(select 1 from sysoption where catalog='deal_data' and item='rsvsrc_log')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'rsvsrc_log',
		'60',
		'60',
		'夜审数据清除，相关数据保留天数：预留房日志',
		'夜审数据清除，相关数据保留天数：预留房日志',
		'GDS',
		'12-1-2006 0:0:0.000',
		'T',
		'');

if not exists(select 1 from sysoption where catalog='deal_data' and item='ncr')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'ncr',
		'60',
		'60',
		'夜审数据清除，相关数据保留天数：餐饮接口原始数据',
		'夜审数据清除，相关数据保留天数：餐饮接口原始数据',
		'GDS',
		'12-1-2006 0:0:0.000',
		'T',
		'');

if not exists(select 1 from sysoption where catalog='deal_data' and item='phfolio')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'phfolio',
		'400',
		'400',
		'夜审数据清除，相关数据保留天数：电话计费数据',
		'夜审数据清除，相关数据保留天数：电话计费数据',
		'GDS',
		'12-1-2006 0:0:0.000',
		'T',
		'');

if not exists(select 1 from sysoption where catalog='deal_data' and item='pos_menu')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'pos_menu',
		'400',
		'400',
		'夜审数据清除，相关数据保留天数：餐饮点菜记录',
		'夜审数据清除，相关数据保留天数：餐饮点菜记录',
		'GDS',
		'12-1-2006 0:0:0.000',
		'T',
		'');

if not exists(select 1 from sysoption where catalog='deal_data' and item='rm_ooo_log')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'rm_ooo_log',
		'100',
		'100',
		'夜审数据清除，相关数据保留天数：维修房日志',
		'夜审数据清除，相关数据保留天数：维修房日志',
		'GDS',
		'12-1-2006 0:0:0.000',
		'T',
		'');

if not exists(select 1 from sysoption where catalog='deal_data' and item='doorcard_req')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'doorcard_req',
		'14',
		'14',
		'夜审数据清除，相关数据保留天数：门卡接口记录',
		'夜审数据清除，相关数据保留天数：门卡接口记录',
		'GDS',
		'12-4-2006 0:0:0.000',
		'T',
		'');


//select * from sysoption where catalog='deal_data' order by item; 




























