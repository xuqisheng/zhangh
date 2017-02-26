if exists(select * from sysobjects where name = 'p_gds_vipcard_info1' and type ='P')
	drop proc p_gds_vipcard_info1;
create proc p_gds_vipcard_info1
	@no			char(20),
	@langid		int = 0
as
----------------------------------------------------------------
-- 积分简要信息　－－－for posting window
----------------------------------------------------------------
create table #gout (tag char(10) null, msg varchar(60)  null)

declare	@name			varchar(60),
			@type			char(3),
			@class		char(3),
			@sta			char(1),
			@charge		money,
			@credit		money,
			@limit		money,
			@hotelid		varchar(20)

-- hotelid
select @hotelid = ltrim(rtrim(value)) from sysoption where catalog='hotel' and item='hotelid'
if @@rowcount = 0 or @hotelid is null
	select @hotelid = '???'

-- base info 
select @name=name,@type=type,@sta=sta,@class=class,@charge=charge,@credit=credit,@limit=limit from vipcard where no=@no
if @@rowcount = 0
begin
	select tag, msg from #gout 
	return 0
end

-- 客户端不能处理集团卡
if @hotelid <> 'crs' and exists(select 1 from vipcard_type where code=@type and center='T')
begin
	select tag, msg from #gout 
	return 0
end

--
if @langid = 0
	insert #gout(tag, msg) select 'name', '卡上名称    : ' + @name
else
	insert #gout(tag, msg) select 'name', 'Name On Card: ' + @name

--
if @langid = 0
	insert #gout(tag, msg) select 'type', '卡类别      : ' + descript from  vipcard_type where code = @type
else
	insert #gout(tag, msg) select 'type', 'Card Type   : ' + descript1 from  vipcard_type where code = @type

--
if @langid = 0
	insert #gout(tag, msg) select 'type', '卡状态      : ' + descript from  basecode where cat = 'vipcard_sta' and code = @sta
else
	insert #gout(tag, msg) select 'type', 'Card Status : ' + descript1 from basecode where cat = 'vipcard_sta' and code = @sta

--
if @langid = 0
	insert #gout(tag, msg) select 'bal', '积分余额     : ' + convert(char(10), @credit-@charge)
else
	insert #gout(tag, msg) select 'bal', 'Point Bal    : ' + convert(char(10), @credit-@charge)

--
if @langid = 0
	insert #gout(tag, msg) select 'limit', '积分限额   : ' + convert(char(10), @limit)
else
	insert #gout(tag, msg) select 'limit', 'Limit      : ' + convert(char(10), @limit)

--
select tag, msg from #gout 

return 0
;
