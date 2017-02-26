//grp_base_hotel 存放单体酒店基本信息
if exists(select 1 from sysobjects where name='grp_base_hotel' and type='U')
	drop table grp_base_hotel;
Create table grp_base_hotel(
	hotelid char(20),//酒店ID
	hotelname char(60),//酒店名称
	hotelename char(60),//酒店英文名
	roomnumber money,//客房数
	flag	char(10),
	sequence int
)
;
create unique index index1 on grp_base_hotel(hotelid);
//grp_base_datatype 数据类型表
if exists(select 1 from sysobjects where name='grp_base_datatype' and type='U')
	drop table grp_base_datatype;
Create table grp_base_datatype(
	datatype char(30),//数据类型
	description char(60),//数据类型描述
	edescription char(60),//数据类型英文描述
	remark varchar(100),//备注
	sequence int

);
create unique index index1 on grp_base_datatype(datatype);

//grp_base_periodtype 周期类型表	
if exists(select 1 from sysobjects where name='grp_base_periodtype' and type='U')
	drop table grp_base_periodtype;
Create table grp_base_periodtype(
	periodtype char(10),//周期类型
	description char(60),//周期类型描述
	edescription char(60),//周期类型英文描述
	remark varchar(100),//备注
	sequence int

);
create unique index index1 on grp_base_periodtype(periodtype);

//grp_group_basedata_day 每日数据集
if exists(select 1 from sysobjects where name='grp_group_basedata_day' and type='U')
	drop table grp_group_basedata_day;
Create table grp_group_basedata_day(
	hotelid char(20),//酒店ID
	datatype char(30),//数据类型
	crrtday datetime,//当前日期
	dayvalue  money//值
)
;
create unique clustered index index1 on grp_group_basedata_day(hotelid,datatype,crrtday);

//grp_group_basedata_period 周期数据集
if exists(select 1 from sysobjects where name='grp_group_basedata_period' and type='U')
	drop table grp_group_basedata_period;
Create table grp_group_basedata_period(
	hotelid char(20),//酒店id
	datatype char(30),//数据类型
	periodtype char(10),//周期类型
	crrtperiod char(20),//当前周期
	dayvalue  money//值
)
;
create unique clustered index index1 on grp_group_basedata_period(hotelid,datatype,periodtype,crrtperiod);

//grp_group_basedata_one 固定数据集
if exists(select 1 from sysobjects where name='grp_group_basedata_one' and type='U')
	drop table grp_group_basedata_one;
Create table grp_group_basedata_one(
	hotelid char(20),//酒店ID
	datatype char(30),//数据类型
	onevalue varchar(60)//值
)
;
create unique clustered index index1 on grp_group_basedata_one(hotelid,datatype);