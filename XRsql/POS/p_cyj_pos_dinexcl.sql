if exists(select 1 from sysobjects where name ='p_cyj_pos_dinexcl' and type = 'P')
	drop  proc p_cyj_pos_dinexcl;
create proc p_cyj_pos_dinexcl
	@ret			integer 	output, 
	@msg			char(50)	output
as
---------------------------------------------------------------------------------
--
-- ����ҹ���ռ����
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

-- ʹ�ö���ͽ������ڸ���(v5.5,x5���ڳ���pos_pay.bdateȡֵ������) cyj 2005.10.13
update pos_pay set bdate = @bdate0 where sta ='2' or sta ='3'

delete pos_tdish
insert pos_tdish select * from pos_dish
delete pos_tmenu
insert pos_tmenu select * from pos_menu
delete pos_tpay
-- -- ���������տ����pos_tpay, pos_pay ����ʷ����
insert pos_tpay select * from pos_pay where bdate = @bdate0

delete pos_hmenu from pos_hmenu where menu in (select menu from pos_tmenu)
insert pos_hmenu select * from pos_menu
delete pos_hdish from pos_hdish where menu in (select menu from pos_tmenu)
insert pos_hdish select * from pos_dish
-- 
delete pos_hpay where menu+convert(varchar,number) in (select menu + convert(varchar,number) from pos_pay)
-- -- δʹ�ö��𱣴��ڵ�ǰ�� sta = '1' and rtrim(mneu0) = null, pos_pay.menu0 <> ''��ָ��ʹ�ö��𡯺͡���ʹ�ö��� ���͡���������
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


-- -- �ж����Ԥ�����ܵ�����ʷ��, Ҫ����pos_hreserve ���ظ���
--insert into #resno       select resno from pos_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from pos_pay where pos_pay.menu = pos_reserve.resno and pos_pay.sta ='1')
delete from pos_hreserve 				 				 	where resno in(select resno from pos_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from pos_pay where pos_pay.menu = pos_reserve.resno and pos_pay.sta ='1'))
insert into pos_hreserve select * from pos_reserve where resno in(select resno from pos_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from pos_pay where pos_pay.menu = pos_reserve.resno and pos_pay.sta ='1'))
delete from pos_reserve 									where resno in(select resno from pos_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from pos_pay where pos_pay.menu = pos_reserve.resno and pos_pay.sta ='1'))

-- --pos_hdishcard ����ͳ����ʷ�������ղ���
insert into pos_hdishcard select * from pos_dishcard where bdate = @bdate0
delete pos_dishcard where bdate = @bdate0

-- --pos_hcondbuf ƴ����Ҫ���ǳɱ�
insert into pos_hcondbuf select * from pos_condbuf where bdate = @bdate0
delete pos_condbuf where bdate = @bdate0

update pos_assess set number = 0, number1 = 0, bdate = @bdate

-- ������ϵ�����ʷ, ���Ϊ��Ĳ��ص���
delete pos_order_cook where amount = 0
insert into pos_horder_cook select * from pos_order_cook
delete pos_order_cook

-- ͳ�ƿ��˲������ѽ�����
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

-- ͳ�ƿ��˲������ѽ�����

commit tran
return 0

;