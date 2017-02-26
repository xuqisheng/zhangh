drop proc  p_gl_pos_dinexcl;
create proc p_gl_pos_dinexcl
as
---------------------------------------------------------------------------------
--
-- 餐饮夜审独占部分
--
---------------------------------------------------------------------------------

declare	@bdate			datetime,
			@bdate0			datetime,
			@savedays		integer,
			@no				char(7),
			@menu				char(10),
			@amount			money

select  @savedays = convert(integer, value) from sysoption where catalog = 'pos' and item = 'detail_savedays'
select  @savedays = isnull(@savedays, 30)
select @bdate = bdate1, @bdate0 = bdate from sysdata
                                                               
truncate table pos_tdish
insert pos_tdish select * from pos_dish
truncate table pos_tmenu
insert pos_tmenu select * from pos_menu
truncate table pos_tpay
-- -- 当天所有收款插入pos_tpay, pos_pay 有历史定金
insert pos_tpay select * from pos_pay where bdate = @bdate0

delete pos_hmenu from pos_hmenu where menu in (select menu from pos_tmenu)
insert pos_hmenu select * from pos_menu
delete pos_hdish from pos_hdish where menu in (select menu from pos_tmenu)
insert pos_hdish select * from pos_dish
--
delete pos_hpay where menu+convert(varchar,number) in (select menu + convert(varchar,number) from pos_pay)
-- -- 未使用定金保存在当前库 sta = '1' and rtrim(mneu0) = null, pos_pay.menu0 <> ''是指‘使用定金’和‘被使用定金 ’和‘冲销定金’
insert pos_hpay select * from pos_pay where charindex(sta, '23') > 0 or rtrim(menu0) > ''

truncate table pos_dish
truncate table pos_menu
delete pos_pay where charindex(sta, '23') > 0 or rtrim(menu0) > ''

delete pos_tblav where bdate < @bdate
update sysdata set pbase = datepart(yy, @bdate) % 100 * 100000000.0 + datepart(mm, @bdate) * 1000000.0 + datepart(dd, @bdate) * 10000.0 + 1
update sysdata set hbase = datepart(yy, @bdate) % 100 * 100000000.0 + datepart(mm, @bdate) * 1000000.0 + datepart(dd, @bdate) * 10000.0 + 1


delete pos_plu_log where datediff(day, date, @bdate) > @savedays
delete pos_sort_log where datediff(day, date, @bdate) > @savedays
delete pos_detail_jie where datediff(day, date, @bdate) > @savedays
delete pos_detail_dai where datediff(day, date, @bdate) > @savedays

truncate table pos_thxsale
insert pos_thxsale select * from pos_hxsale
delete pos_hhxsale where datediff(dd,bdate, @bdate)=1
insert into pos_hhxsale select * from pos_hxsale
delete pos_hxsale

-- -- 有定金的预定不能倒入历史中, 要避免pos_hreserve 有重复键
create table #resno ( resno char(10) )
insert into #resno       select resno from pos_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from pos_pay where pos_pay.menu = pos_reserve.resno and pos_pay.sta ='1')
delete pos_hreserve where resno in(select resno from #resno)
insert into pos_hreserve select *     from pos_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from pos_pay where pos_pay.menu = pos_reserve.resno and pos_pay.sta ='1')
delete from pos_reserve 										 where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from pos_pay where pos_pay.menu = pos_reserve.resno and pos_pay.sta ='1')

delete pos_rsvpc where bdate < @bdate
delete pos_rsvdtl where bdate < @bdate
-- --pos_hdishcard 可以统计历史各厨房烧菜量
insert into pos_hdishcard select * from pos_dishcard where bdate = @bdate0
delete pos_dishcard where bdate = @bdate0

update pos_assess set number = 0, number1 = 0, bdate = @bdate
truncate table pos_dish_add

-- 统计客人餐饮消费金额及次数
declare	c_menu cursor for select menu, haccnt from pos_tmenu where haccnt > '' and sta ='3'
open c_menu
fetch c_menu into @menu, @no
while @@sqlstatus = 0
begin
	select @amount = amount from pos_tmenu where menu = @menu and not exists(select 1 from pos_tpay where pos_tmenu.menu = pos_tpay.menu and charindex(pos_tpay.paycode, '986#988')>0 and charindex(pos_tpay.crradjt, 'C CO')=0)
	update guest set fb = isnull(fb,0) +  isnull(@amount,0), fb_times1 = isnull(fb_times1,0) + 1  where no = @no
	fetch c_menu into @menu, @no
end
close c_menu
deallocate cursor c_menu
                                                                    
   
                                                               
truncate table sp_tdish
insert sp_tdish select * from sp_dish
truncate table sp_tmenu
insert sp_tmenu select * from sp_menu
truncate table sp_tpay
-- -- 当天所有收款插入sp_tpay, sp_pay 有历史定金
insert sp_tpay select * from sp_pay where bdate = @bdate0

delete sp_hmenu from sp_hmenu where menu in (select menu from sp_tmenu)
insert sp_hmenu select * from sp_menu
delete sp_hdish from sp_hdish where menu in (select menu from sp_tmenu)
insert sp_hdish select * from sp_dish
--
delete sp_hpay where menu+convert(varchar,number) in (select menu + convert(varchar,number) from sp_pay)
-- -- 未使用定金保存在当前库 sta = '1' and rtrim(mneu0) = null, sp_pay.menu0 <> ''是指‘使用定金’和‘被使用定金 ’和‘冲销定金’
insert sp_hpay select * from sp_pay where charindex(sta, '23') > 0 or rtrim(menu0) > ''

truncate table sp_dish
truncate table sp_menu
delete sp_pay where charindex(sta, '23') > 0 or rtrim(menu0) > ''
----
delete sp_hplaav where bdate = @bdate0
insert sp_hplaav select * from sp_plaav where bdate = @bdate0 and sta <> 'R'
delete sp_plaav where bdate = @bdate0 and sta <> 'R'

-- -- 有定金的预定不能倒入历史中, 要避免sp_hreserve 有重复键
                                         
insert into #resno  select resno from sp_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from sp_pay where sp_pay.menu = sp_reserve.resno and sp_pay.sta ='1')
delete sp_hreserve where resno in(select resno from #resno)
delete sp_hplaav where resno in(select resno from #resno)
insert sp_hplaav select * from sp_plaav where resno in(select resno from #resno)
delete sp_plaav where resno in(select resno from #resno)
insert into sp_hreserve select * from sp_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from sp_pay where sp_pay.menu = sp_reserve.resno and sp_pay.sta ='1')
delete from sp_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from sp_pay where sp_pay.menu = sp_reserve.resno and sp_pay.sta ='1')

-- 统计客人餐饮消费金额及次数
declare	c_place cursor for select menu, haccnt from sp_tmenu where haccnt > '' and sta ='3'
open c_place
fetch c_place into @menu, @no
while @@sqlstatus = 0
begin
	select @amount = amount from sp_tmenu where menu = @menu and not exists(select 1 from sp_tpay where sp_tmenu.menu = sp_tpay.menu and charindex(sp_tpay.paycode, '986#988')>0 and charindex(sp_tpay.crradjt, 'C CO')=0)
	update guest set en = isnull(en,0) +  isnull(@amount,0), en_times2 = isnull(en_times2,0) + 1  where no = @no
	fetch c_place into @menu, @no
end
close c_place
deallocate cursor c_place


return 0

;