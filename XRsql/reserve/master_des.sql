//==========================================================================
//Table : master_des
//
//			master key column's descript 
//
//		如何维护该表
//			-- 本来放在 master 触发器中， 导致系统运行很慢
//			运用：内容修改  - 
//					状态修改  - update trigger
//
//==========================================================================

//--------------------------------------------------------------------------
//		master_des, master_des_till, master_des_last
//--------------------------------------------------------------------------
if exists(select * from sysobjects where name = "master_des" and type="U")
	drop table master_des;
create table master_des
(
	accnt		   	char(10)						not null,	/* 帐号:主键(其生成见说明书)  */

	sta_o		   	char(1)			default ''	not null,	
	sta		   	char(20)			default ''	not null,	

	haccnt_o			char(7)			default '' 	not null,	/* 宾客档案号  */
	haccnt			varchar(50)		default '' 	not null,	/* 宾客档案号  */

	groupno_o		char(10)			default '' 	not null,	/* 所属团号  */
	groupno			varchar(50)		default '' 	not null,	/* 所属团号  */

	blkcode_o		char(10)			default '' 	not null,	/* 所属blkcode  */
	blkcode			varchar(50)		default '' 	not null,	

	arr				datetime	   				not null,	/* 到店日期=arrival */
	dep				datetime	   				not null,	/* 离店日期=departure */

	unit				varchar(60)		default '' 	not null,	// profile unit 

	agent_o			char(7)			default '' 	not null,
	agent				varchar(50)		default '' 	not null,

	cusno_o			char(7)			default '' 	not null,
	cusno				varchar(50)		default '' 	not null,

	source_o			char(7)			default '' 	not null,
	source			varchar(50)		default '' 	not null,

	src_o				char(3)			default '' 	not null,	/* 来源 */
	src				varchar(40)		default '' 	not null,	/* 来源 */

	market_o			char(3)			default '' 	not null,	/* 市场码 */
	market			varchar(40)		default '' 	not null,	/* 市场码 */

	restype_o		char(3)			default '' 	not null,	/* 预订类别 */
	restype			varchar(40)		default '' 	not null,	/* 预订类别 */

	channel_o		varchar(3)		default '' 	not null,	/* 渠道 */
	channel			varchar(40)		default '' 	not null,	/* 渠道 */

	artag1_o			char(3)			default '' 	not null,
	artag1			varchar(40)		default '' 	not null,

	artag2_o			char(3)			default '' 	not null,
	artag2			varchar(40)		default '' 	not null,
	
	ratecode_o		char(10)    	default '' 	not null,	/* 房价码  */
	ratecode			varchar(60)    default '' 	not null,	/* 房价码  */

	rtreason_o		char(3)			default ''	not null,	/* 房价优惠理由(cf.rtreason.dbf) */
	rtreason			varchar(20)		default ''	not null,	/* 房价优惠理由(cf.rtreason.dbf) */

	paycode_o		char(3)			default ''	not null,	/* 结算方式 */
	paycode			varchar(24)		default ''	not null,	/* 结算方式 */

	wherefrom_o		char(6)			default ''	not null,	/* 何地来 */
	wherefrom		varchar(40)		default ''	not null,	/* 何地来 */

	whereto_o		char(6)			default ''	not null,	/* 何地去 */
	whereto			varchar(40)		default ''	not null,	/* 何地去 */

	saleid_o			char(10)			default ''	not null,	/* 销售员 */
	saleid			varchar(30)		default ''	not null		/* 销售员 */
)
exec sp_primarykey master_des,accnt
create unique index index1 on master_des(accnt)
;


if exists(select * from sysobjects where name = "master_des_till" and type="U")
	drop table master_des_till;
create table master_des_till
(
	accnt		   	char(10)						not null,	/* 帐号:主键(其生成见说明书)  */

	sta_o		   	char(1)			default ''	not null,	
	sta		   	char(20)			default ''	not null,	

	haccnt_o			char(7)			default '' 	not null,	/* 宾客档案号  */
	haccnt			varchar(50)		default '' 	not null,	/* 宾客档案号  */

	groupno_o		char(10)			default '' 	not null,	/* 所属团号  */
	groupno			varchar(50)		default '' 	not null,	/* 所属团号  */

	blkcode_o		char(10)			default '' 	not null,	/* 所属blkcode  */
	blkcode			varchar(50)		default '' 	not null,	

	arr				datetime	   				not null,	/* 到店日期=arrival */
	dep				datetime	   				not null,	/* 离店日期=departure */

	unit				varchar(60)		default '' 	not null,	// profile unit 

	agent_o			char(7)			default '' 	not null,
	agent				varchar(50)		default '' 	not null,

	cusno_o			char(7)			default '' 	not null,
	cusno				varchar(50)		default '' 	not null,

	source_o			char(7)			default '' 	not null,
	source			varchar(50)		default '' 	not null,

	src_o				char(3)			default '' 	not null,	/* 来源 */
	src				varchar(40)		default '' 	not null,	/* 来源 */

	market_o			char(3)			default '' 	not null,	/* 市场码 */
	market			varchar(40)		default '' 	not null,	/* 市场码 */

	restype_o		char(3)			default '' 	not null,	/* 预订类别 */
	restype			varchar(40)		default '' 	not null,	/* 预订类别 */

	channel_o		varchar(3)		default '' 	not null,	/* 渠道 */
	channel			varchar(40)		default '' 	not null,	/* 渠道 */

	artag1_o			char(3)			default '' 	not null,
	artag1			varchar(40)		default '' 	not null,

	artag2_o			char(3)			default '' 	not null,
	artag2			varchar(40)		default '' 	not null,
	
	ratecode_o		char(10)    	default '' 	not null,	/* 房价码  */
	ratecode			varchar(60)    default '' 	not null,	/* 房价码  */

	rtreason_o		char(3)			default ''	not null,	/* 房价优惠理由(cf.rtreason.dbf) */
	rtreason			varchar(20)		default ''	not null,	/* 房价优惠理由(cf.rtreason.dbf) */

	paycode_o		char(3)			default ''	not null,	/* 结算方式 */
	paycode			varchar(24)		default ''	not null,	/* 结算方式 */

	wherefrom_o		char(6)			default ''	not null,	/* 何地来 */
	wherefrom		varchar(40)		default ''	not null,	/* 何地来 */

	whereto_o		char(6)			default ''	not null,	/* 何地去 */
	whereto			varchar(40)		default ''	not null,	/* 何地去 */

	saleid_o			char(10)			default ''	not null,	/* 销售员 */
	saleid			varchar(30)		default ''	not null		/* 销售员 */
)
exec sp_primarykey master_des_till,accnt
create unique index index1 on master_des_till(accnt)
;


if exists(select * from sysobjects where name = "master_des_last" and type="U")
	drop table master_des_last;
create table master_des_last
(
	accnt		   	char(10)						not null,	/* 帐号:主键(其生成见说明书)  */

	sta_o		   	char(1)			default ''	not null,	
	sta		   	char(20)			default ''	not null,	

	haccnt_o			char(7)			default '' 	not null,	/* 宾客档案号  */
	haccnt			varchar(50)		default '' 	not null,	/* 宾客档案号  */

	groupno_o		char(10)			default '' 	not null,	/* 所属团号  */
	groupno			varchar(50)		default '' 	not null,	/* 所属团号  */

	blkcode_o		char(10)			default '' 	not null,	/* 所属blkcode  */
	blkcode			varchar(50)		default '' 	not null,	

	arr				datetime	   				not null,	/* 到店日期=arrival */
	dep				datetime	   				not null,	/* 离店日期=departure */

	unit				varchar(60)		default '' 	not null,	// profile unit 

	agent_o			char(7)			default '' 	not null,
	agent				varchar(50)		default '' 	not null,

	cusno_o			char(7)			default '' 	not null,
	cusno				varchar(50)		default '' 	not null,

	source_o			char(7)			default '' 	not null,
	source			varchar(50)		default '' 	not null,

	src_o				char(3)			default '' 	not null,	/* 来源 */
	src				varchar(40)		default '' 	not null,	/* 来源 */

	market_o			char(3)			default '' 	not null,	/* 市场码 */
	market			varchar(40)		default '' 	not null,	/* 市场码 */

	restype_o		char(3)			default '' 	not null,	/* 预订类别 */
	restype			varchar(40)		default '' 	not null,	/* 预订类别 */

	channel_o		varchar(3)		default '' 	not null,	/* 渠道 */
	channel			varchar(40)		default '' 	not null,	/* 渠道 */

	artag1_o			char(3)			default '' 	not null,
	artag1			varchar(40)		default '' 	not null,

	artag2_o			char(3)			default '' 	not null,
	artag2			varchar(40)		default '' 	not null,
	
	ratecode_o		char(10)    	default '' 	not null,	/* 房价码  */
	ratecode			varchar(60)    default '' 	not null,	/* 房价码  */

	rtreason_o		char(3)			default ''	not null,	/* 房价优惠理由(cf.rtreason.dbf) */
	rtreason			varchar(20)		default ''	not null,	/* 房价优惠理由(cf.rtreason.dbf) */

	paycode_o		char(3)			default ''	not null,	/* 结算方式 */
	paycode			varchar(24)		default ''	not null,	/* 结算方式 */

	wherefrom_o		char(6)			default ''	not null,	/* 何地来 */
	wherefrom		varchar(40)		default ''	not null,	/* 何地来 */

	whereto_o		char(6)			default ''	not null,	/* 何地去 */
	whereto			varchar(40)		default ''	not null,	/* 何地去 */

	saleid_o			char(10)			default ''	not null,	/* 销售员 */
	saleid			varchar(30)		default ''	not null		/* 销售员 */
)
exec sp_primarykey master_des_last,accnt
create unique index index1 on master_des_last(accnt)
;
