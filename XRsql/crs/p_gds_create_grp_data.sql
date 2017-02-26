
if exists ( select * from sysobjects where name = 'p_foxhis_create_grp_datatype' and type = 'P')
	drop proc p_foxhis_create_grp_datatype;
create proc p_foxhis_create_grp_datatype
as
----------------------------------------------------
-- grp_base_datatype 数据类型表
----------------------------------------------------

-- 清除数据，全新插入
delete grp_base_datatype

-- 指标录入


------------------
-- 1.收入
------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('RevTtl', '总收入', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RevRm', '客房收入', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RevRm.f', '客房收入-散客', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RevRm.g', '客房收入-团体', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RevRm.c', '客房收入-会议', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RevRm.l', '客房收入-长包', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RevFB', '餐饮收入', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RevOth', '其他收入', '', '')

------------------
-- 2.房数
------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsTtl', '客房总数', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsOO', '维修房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsOS', '锁定房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsSold', '已售房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsSold.f', '已售房-散客', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsSold.g', '已售房-团体', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsSold.c', '已售房-会议', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsSold.l', '已售房-长包', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsHtl', '自用房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsEnt', '免费房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsAvl', '可用房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsExtra', '加床', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsArr', '客房-当日抵达', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsDep', '客房-当日离店', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsDaybook', '客房-当日预订量', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsNoshow', '客房-NoShow', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsCXL', '客房-取消预订', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsExtend', '客房-续住', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsRetu', '客房-回头客', '', '')

------------------
-- 3.人数
------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('GstTtl', '客人总数', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Gst.f', '客人数-散客', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Gst.g', '客人数-团体', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Gst.c', '客人数-会议', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Gst.l', '客人数-长包', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Gst.in', '客人数-内宾', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Gst.ou', '客人数-外宾', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Gst.retu', '客人数-回头客', '', '')

------------------
-- 4.市场码相关 
------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmRev.1', '市场码-收入-无协议散客', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmRev.2', '市场码-收入-团队', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmRev.3', '市场码-收入-订房中心', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmRev.4', '市场码-收入-协议公司', '', '')
--------------------------------------------------------------------------------------------------------------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmNgt.1', '市场码-房晚-无协议散客', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmNgt.2', '市场码-房晚-团队', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmNgt.3', '市场码-房晚-订房中心', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmNgt.4', '市场码-房晚-协议公司', '', '')
--------------------------------------------------------------------------------------------------------------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmGst.1', '市场码-人数-无协议散客', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmGst.2', '市场码-人数-团队', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmGst.3', '市场码-人数-订房中心', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmGst.4', '市场码-人数-协议公司', '', '')

------------------
-- 5.来源码相关
------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmRev.1', '来源码-收入-中央预订', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmRev.2', '来源码-收入-上门散客', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmRev.3', '来源码-收入-网上预订', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmRev.4', '来源码-收入-金陵贵宾', '', '')
--------------------------------------------------------------------------------------------------------------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmNgt.1', '来源码-房晚-中央预订', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmNgt.2', '来源码-房晚-上门散客', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmNgt.3', '来源码-房晚-网上预订', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmNgt.4', '来源码-房晚-金陵贵宾', '', '')
--------------------------------------------------------------------------------------------------------------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmGst.1', '来源码-人数-中央预订', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmGst.2', '来源码-人数-上门散客', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmGst.3', '来源码-人数-网上预订', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmGst.4', '来源码-人数-金陵贵宾', '', '')

---------------
-- 6.房类相关
---------------
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmRev.1', '房类-收入-经济房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmRev.2', '房类-收入-商务房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmRev.3', '房类-收入-家庭套房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmRev.4', '房类-收入-单人房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmRev.5', '房类-收入-标准房', '', '')
--------------------------------------------------------------------------------------------------------------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmNgt.1', '房类-房晚-经济房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmNgt.2', '房类-房晚-商务房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmNgt.3', '房类-房晚-家庭套房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmNgt.4', '房类-房晚-单人房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmNgt.5', '房类-房晚-标准房', '', '')
--------------------------------------------------------------------------------------------------------------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmGst.1', '房类-人数-经济房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmGst.2', '房类-人数-商务房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmGst.3', '房类-人数-家庭套房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmGst.4', '房类-人数-单人房', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmGst.5', '房类-人数-标准房', '', '')

;


if exists ( select * from sysobjects where name = 'p_foxhis_create_grp_data_x' and type = 'P')
	drop proc p_foxhis_create_grp_data_x;
create proc p_foxhis_create_grp_data_x
	@date		datetime 
as
----------------------------------------------------
-- 单体酒店集团数据采集 for X 系列
--
-- 该过程在成员酒店每日执行
-- 根据集团指标代码的规定，进行针对性采集 
----------------------------------------------------
declare
	@hotelid 	char(20),
	@hotelname 	char(60),
	@hotelename char(60),
	@roomnumber money

----------------------------------------------------
-- 0. grp_base_hotel 存放单体酒店基本信息
----------------------------------------------------
select @hotelid = isnull(rtrim(ltrim(value)),'') from sysoption where catalog='hotel' and item='hotelid'
if @hotelid <> ''
begin
	delete from grp_base_hotel where hotelid=@hotelid  -- 每次更新 

	select @hotelname = isnull(rtrim(ltrim(value)), '') from sysoption where catalog='hotel' and item='name'
	select @hotelename = isnull(rtrim(ltrim(value)), '') from sysoption where catalog='hotel' and item='ename'
	select @roomnumber = isnull((select sum(quantity) from typim where tag<>'P'), 0) 
	insert grp_base_hotel(hotelid, hotelname, hotelename, roomnumber)
		values (@hotelid, @hotelname, @hotelename, @roomnumber)
end
else
	return 


------------------------------------
-- 开始采集每日数据 
------------------------------------
delete grp_group_basedata_day where hotelid=@hotelid and crrtday=@date
insert grp_group_basedata_day(hotelid,datatype,crrtday,dayvalue)
	select @hotelid, datatype, @date, 0 from grp_base_datatype 
--
-- update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype=''

---------------------------------------------------------------------
-- 1.收入 - 推荐取数 yjourrep or yaudit_impdata 
---------------------------------------------------------------------
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class='000100'), 0) where hotelid=@hotelid and crrtday=@date and datatype='RevTtl'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class='000005'), 0) where hotelid=@hotelid and crrtday=@date and datatype='RevRm'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010140', '010168')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RevRm.f'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class='010150'), 0) where hotelid=@hotelid and crrtday=@date and datatype='RevRm.g'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class='010155'), 0) where hotelid=@hotelid and crrtday=@date and datatype='RevRm.c'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class='010160'), 0) where hotelid=@hotelid and crrtday=@date and datatype='RevRm.l'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class='000020'), 0) where hotelid=@hotelid and crrtday=@date and datatype='RevFB'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class<'000100' and class<>'000071'), 0) where hotelid=@hotelid and crrtday=@date and datatype='RevOth'

---------------------------------------------------------------------
-- 2.房数 - 推荐取数 yjourrep or yaudit_impdata 
---------------------------------------------------------------------
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010012', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsTtl'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010014', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsOO'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsOS'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010030', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsSold'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010040', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsSold.f'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010050', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsSold.g'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010060', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsSold.c'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010070', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsSold.l'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010015', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsHtl'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010016', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsEnt'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010020', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsAvl'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010075', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsExtra'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010505', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsArr'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010506', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsDep'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010510', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsDaybook'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010502', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsNoshow'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010503', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsCXL'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010504', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsExtend'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsRetu'


---------------------------------------------------------------------
-- 3.人数 - 推荐取数 yjourrep or yaudit_impdata or yrmsalerep_new 
---------------------------------------------------------------------


---------------------------------------------------------------------
-- 4.市场码相关 - 推荐取数 ymktsummaryrep (class='M' 市场码=code)
---------------------------------------------------------------------


---------------------------------------------------------------------
-- 5.来源码相关 - 推荐取数 ymktsummaryrep (class='S' 来源码=code)
---------------------------------------------------------------------


---------------------------------------------------------------------
-- 6.房类相关 - 推荐取数 yrmsalerep_new (gkey='t' 房类=code) 
---------------------------------------------------------------------


;


//exec p_foxhis_create_grp_datatype;
//exec p_foxhis_create_grp_data_x '2005.11.11';
//
////select * from grp_base_datatype;
////select * from grp_base_hotel;
//select * from grp_group_basedata_day;
//