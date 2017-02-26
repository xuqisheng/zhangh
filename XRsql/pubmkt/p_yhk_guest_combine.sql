
if object_id('p_yhk_guest_combine') is not null 
	drop proc p_yhk_guest_combine;
create proc p_yhk_guest_combine
	@no1				char(7),		-- org
	@no2				char(7),		-- combine
	@empno			char(10)
as
----------------------------------------------------------------------------------
-- 	客史合并 -- 只是针对 guest
--		lgfl -- 里面的记录不管了.
-- 	被合并的档案存储到 guest_del
----------------------------------------------------------------------------------
declare	@ret			int,
			@msg			varchar(60),
			@sta1			char(1),			@sta2			char(1),
			@class1		char(1),			@class2		char(1),
			@fv_date1	datetime,		@fv_date2	datetime,
			@fv_room1	char(5),			@fv_room2	char(5),
			@fv_rate1	money,			@fv_rate2	money,
			@lv_date1	datetime,		@lv_date2	datetime,
			@lv_room1	char(5),			@lv_room2	char(5),
			@lv_rate1	money,			@lv_rate2	money,
			@i_times1	int,				@i_times2	int,
			@x_times1	int,				@x_times2	int,
			@n_times1	int,				@n_times2	int,
			@l_times1	int,				@l_times2	int,
			@i_days1		int,				@i_days2		int,
			@fb_times11	int,				@fb_times12	int,
			@en_times21	int,				@en_times22	int,
			@rm1			money,			@rm2			money,
			@fb1			money,			@fb2			money,
			@en1			money,			@en2			money,
			@mt1			money,			@mt2			money,
			@ot1			money,			@ot2			money,
			@tl1			money,			@tl2			money

select @ret=0, @msg=''

-- Check Data
select @class1=class,@sta1=sta,@fv_date1=fv_date,@fv_room1=fv_room,@fv_rate1=fv_rate,@lv_date1=lv_date,
	@lv_room1=lv_room,@lv_rate1=lv_rate,@i_times1=i_times,@x_times1=x_times,@n_times1=n_times,
	@l_times1=l_times,@i_days1=i_days,@fb_times11=fb_times1,@en_times21=en_times2,
	@rm1=rm,@fb1=fb,@en1=en,@mt1=mt,@ot1=ot,@tl1=tl from guest where no=@no1
if @@rowcount = 0
begin
	select @ret=1, @msg='原始档案不存在'
	goto gout
end
if @no1=@no2
begin
	select @ret=1, @msg='档案号相同, 没有必要合并'
	goto gout
end
select @class2=class,@sta2=sta,@fv_date2=fv_date,@fv_room2=fv_room,@fv_rate2=fv_rate,@lv_date2=lv_date,
	@lv_room2=lv_room,@lv_rate2=lv_rate,@i_times2=i_times,@x_times2=x_times,@n_times2=n_times,
	@l_times2=l_times,@i_days2=i_days,@fb_times12=fb_times1,@en_times22=en_times2,
	@rm2=rm,@fb2=fb,@en2=en,@mt2=mt,@ot2=ot,@tl2=tl from guest where no=@no2
if @@rowcount = 0
begin
	select @ret=1, @msg='需要合并的档案不存在'
	goto gout
end
if ((@class1='F' or @class1='G') and @class1<>@class2)
	or (@class1 in ('A','C','S') and not @class2 in ('A','C','S')) 
	or @class1 not in ('A','C','S','F','G') 
begin
	select @ret=1, @msg='档案类型不一致,不能合并'
	goto gout
end
if @class1 not in ('F', 'C', 'A', 'S', 'G')
begin
	select @ret=1, @msg='当前类型档案不能合并'
	goto gout
end

-- Update business data
begin tran
save tran guest_combine

if @class1 in ('F', 'G')   -- 宾客, 团体
begin
	update master set haccnt=@no1 where haccnt=@no2
	update master_till set haccnt=@no1 where haccnt=@no2
	update master_last set haccnt=@no1 where haccnt=@no2
	update master_log set haccnt=@no1 where haccnt=@no2
	update hmaster set haccnt=@no1 where haccnt=@no2
	update master_middle set haccnt=@no1 where haccnt=@no2

	update vipcard set hno=@no1 where hno=@no2
	update vipcard set kno=@no1 where kno=@no2

	update cus_xf set haccnt=@no1 where haccnt=@no2
	update ycus_xf set haccnt=@no1 where haccnt=@no2
	
	if @class1 = 'F'
	begin
		update pos_menu set haccnt=@no1 where haccnt=@no2
		update pos_tmenu set haccnt=@no1 where haccnt=@no2
		update pos_hmenu set haccnt=@no1 where haccnt=@no2
	end 
end
else if @class1 in ('A', 'S', 'C')	-- 旅行社 / 公司 / 定房中心
begin
	-- 1. cusno 
	update master 			set cusno=@no1 where cusno=@no2  
	update master_till 	set cusno=@no1 where cusno=@no2
	update master_last 	set cusno=@no1 where cusno=@no2
	update master_log 	set cusno=@no1 where cusno=@no2
	update hmaster 		set cusno=@no1 where cusno=@no2
	update master_middle set cusno=@no1 where cusno=@no2

	update cus_xf 			set cusno=@no1 where cusno=@no2
	update ycus_xf 		set cusno=@no1 where cusno=@no2

	-- 2. agent 
	update master 			set agent=@no1 where agent=@no2  
	update master_till 	set agent=@no1 where agent=@no2
	update master_last 	set agent=@no1 where agent=@no2
	update master_log 	set agent=@no1 where agent=@no2
	update hmaster 		set agent=@no1 where agent=@no2
	update master_middle set agent=@no1 where agent=@no2

	update cus_xf 			set agent=@no1 where agent=@no2
	update ycus_xf 		set agent=@no1 where agent=@no2

	-- 3. source 
	update master 			set source=@no1 where source=@no2  
	update master_till 	set source=@no1 where source=@no2
	update master_last 	set source=@no1 where source=@no2
	update master_log 	set source=@no1 where source=@no2
	update hmaster 		set source=@no1 where source=@no2
	update master_middle set source=@no1 where source=@no2

	update cus_xf 			set source=@no1 where source=@no2
	update ycus_xf 		set source=@no1 where source=@no2

	-- vipcard 
	update vipcard set cno=@no1 where cno=@no2
	update vipcard set kno=@no1 where kno=@no2

	-- pos 
	update pos_menu set cusno=@no1 where cusno=@no2
	update pos_tmenu set cusno=@no1 where cusno=@no2
	update pos_hmenu set cusno=@no1 where cusno=@no2
end

-- Deal with summary data
if @fv_date1 is null or (@fv_date1 is not null and @fv_date2 is not null and @fv_date2<@fv_date1)
	select @fv_date1=@fv_date2, @fv_room1=@fv_room2, @fv_rate1=@fv_rate2
if @lv_date1 is null or (@lv_date1 is not null and @lv_date2 is not null and @lv_date2>@lv_date1)
	select @lv_date1=@lv_date2, @lv_room1=@lv_room2, @lv_rate1=@lv_rate2
select @i_times1	= @i_times1 + @i_times2   --入住次数
select @x_times1	= @x_times1 + @x_times2   --取消次数
select @n_times1	= @n_times1 + @n_times2   --noshow次数
select @l_times1	= @l_times1 + @l_times2
select @i_days1	= @i_days1 + @i_days2     --入住房晚数
select @fb_times11	= @fb_times11 + @fb_times12    --餐饮次数
select @en_times21	= @en_times21 + @en_times22   --娱乐次数
select @rm1	= @rm1 + @rm2   --房费
select @fb1	= @fb1 + @fb2	--餐饮
select @en1	= @en1 + @en2	--娱乐
select @mt1	= @mt1 + @mt2	--会议
select @ot1	= @ot1 + @ot2	--其他
select @tl1	= @tl1 + @tl2	--合计
if @sta1='I' or @sta2='I'
	select @sta1 = 'I'

--
update guest set sta=@sta1, fv_date=@fv_date1,fv_room=@fv_room1,fv_rate=@fv_rate1,
	lv_date=@lv_date1,lv_room=@lv_room1,lv_rate=@lv_rate1,
	i_times=@i_times1,x_times=@x_times1,n_times=@n_times1,l_times=@l_times1,i_days=@i_days1,
	fb_times1=@fb_times11,en_times2=@en_times21,
	rm=@rm1,fb=@fb1,en=@en1,mt=@mt1,ot=@ot1,tl=@tl1,
	comment=comment+' combine:'+@no2, cby=@empno, logmark=logmark+1
	where no=@no1
if @@rowcount=0
begin
	select @ret=1, @msg='Update error'
	goto pout
end

-- name4 
exec p_gds_guest_name4 @no1 

-- 房价码 
insert guest_extra(no, item, value)
	select @no1, 'ratecode', a.value 
		from guest_extra a 
			where a.no=@no2 and a.item='ratecode' 
				and a.value not in (select b.value from guest_extra b where b.no=@no1 and b.item='ratecode') 

-- 黑名单信息 
-- ...... 

-- 备份被删除的记录
insert guest_del select * from guest where no=@no2
if @@rowcount=0
begin
	select @ret=1, @msg='Insert guest_del error'
	goto pout
end
delete guest where no=@no2
if @@rowcount=0
begin
	select @ret=1, @msg='Delete error'
	goto pout
end

--
pout:
if @ret<>0
	rollback tran guest_combine
else
	insert lgfl (accnt, columnname, old, new, empno, date)
		select "profile", "combine", @no1, @no2, @empno, getdate()

commit tran

if @ret=0
	-- 重建  guest_xfttl 
	exec p_gds_guest_income_reb @no1, '1' 

if @ret=0
	-- 重建  statistic_m statistic_y  
	exec p_zk_guest_statistic_reb @no1, @no2

--
gout:
select @ret, @msg
return @ret
;