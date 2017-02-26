if exists(select 1 from sysobjects where name ='p_cyj_pos_dinexcl' and type = 'P')
	drop  proc p_cyj_pos_dinexcl;
create proc p_cyj_pos_dinexcl
	@ret			integer 	output, 
	@msg			char(50)	output
as
---------------------------------------------------------------------------------
--
-- 餐饮夜审独占部分
--
---------------------------------------------------------------------------------

declare	@bdate			datetime,
			@bdate0			datetime,
			@savedays		integer,
			@cusno			char(7),
			@no				char(7),
			@menu				char(10),
			@amount			money


begin tran
save  tran p_cyj_pos_dinexcl_s
select @ret = 0, @msg = ''
select  @savedays = convert(integer, value) from sysoption where catalog = 'pos' and item = 'detail_savedays'
select  @savedays = isnull(@savedays, 30)
select @bdate = bdate1, @bdate0 = bdate from sysdata

-- 使用定金和结账日期改正(v5.5,x5早期程序pos_pay.bdate取值有问题) cyj 2005.10.13
update pos_pay set bdate = @bdate0 where sta ='2' or sta ='3'

delete pos_tdish
insert pos_tdish select * from pos_dish
delete pos_tmenu
insert pos_tmenu select * from pos_menu
delete pos_tpay
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
delete pos_dish
delete pos_menu
delete pos_pay where charindex(sta, '23') > 0 or rtrim(menu0) > ''

delete pos_tblav where bdate < @bdate
update sysdata set pbase = datepart(yy, @bdate) % 100 * 100000000.0 + datepart(mm, @bdate) * 1000000.0 + datepart(dd, @bdate) * 10000.0 + 1
update sysdata set hbase = datepart(yy, @bdate) % 100 * 100000000.0 + datepart(mm, @bdate) * 1000000.0 + datepart(dd, @bdate) * 10000.0 + 1


delete pos_plu_log where datediff(day, date, @bdate) > @savedays
delete pos_sort_log where datediff(day, date, @bdate) > @savedays
delete pos_detail_jie where datediff(day, date, @bdate) > @savedays
delete pos_detail_dai where datediff(day, date, @bdate) > @savedays


-- -- 有定金的预定不能倒入历史中, 要避免pos_hreserve 有重复键
--insert into #resno       select resno from pos_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from pos_pay where pos_pay.menu = pos_reserve.resno and pos_pay.sta ='1')
delete from pos_hreserve 				 				 	where resno in(select resno from pos_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from pos_pay where pos_pay.menu = pos_reserve.resno and pos_pay.sta ='1'))
insert into pos_hreserve select * from pos_reserve where resno in(select resno from pos_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from pos_pay where pos_pay.menu = pos_reserve.resno and pos_pay.sta ='1'))
delete from pos_reserve 									where resno in(select resno from pos_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from pos_pay where pos_pay.menu = pos_reserve.resno and pos_pay.sta ='1'))

-- --pos_hdishcard 可以统计历史各厨房烧菜量
insert into pos_hdishcard select * from pos_dishcard where bdate = @bdate0
delete pos_dishcard where bdate = @bdate0

-- --pos_hcondbuf 拼菜需要考虑成本
insert into pos_hcondbuf select * from pos_condbuf where bdate = @bdate0
delete pos_condbuf where bdate = @bdate0

update pos_assess set number = 0, number1 = 0, bdate = @bdate

-- 点菜配料倒入历史, 金额为零的不必倒入
delete pos_order_cook where amount = 0
insert into pos_horder_cook select * from pos_order_cook
delete pos_order_cook

-- 统计客人餐饮消费金额及次数
declare	c_menu cursor for select menu, cusno, haccnt from pos_tmenu where haccnt > '' and sta ='3' 
open c_menu
fetch c_menu into @menu, @cusno, @no
while @@sqlstatus = 0
begin
	select @amount = amount from pos_tmenu where menu = @menu and not exists(select 1 from pos_tpay a, pccode b where pos_tmenu.menu = a.menu and a.paycode = b.pccode and charindex(substring(b.deptno2,1,3), 'TOA#TOR')>0 and charindex(a.crradjt, 'C CO')=0)
	if rtrim(@no) is not null
		update guest set fb = isnull(fb,0) +  isnull(@amount,0), tl = isnull(tl,0) + isnull(@amount,0), fb_times1 = isnull(fb_times1,0) + 1  where no = @no
	if rtrim(@cusno) is not null
		update guest set fb = isnull(fb,0) +  isnull(@amount,0), tl = isnull(tl,0) + isnull(@amount,0), fb_times1 = isnull(fb_times1,0) + 1  where no = @cusno
	fetch c_menu into @menu, @cusno, @no
end
close c_menu
deallocate cursor c_menu

-- 统计客人餐饮消费金额及次数

commit tran
return 0

;