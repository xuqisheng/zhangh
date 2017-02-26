drop  proc p_gl_pos_dinexcl;
create proc p_gl_pos_dinexcl
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
			@amount			money,
			@year			char(4),
			@month		int

begin tran
save  tran p_gl_pos_dinexcl_s

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

-- ���ʹ�ü�¼
insert into pos_hbkfuse select * from pos_bkfuse
delete pos_bkfuse

-- ͳ�ƿ��˲������ѽ�����
declare	c_menu cursor for select menu, cusno, haccnt from pos_tmenu where (haccnt > '' or cusno>'') and sta ='3' 
open c_menu
fetch c_menu into @menu, @cusno, @no
while @@sqlstatus = 0
begin
	select @amount = amount from pos_tmenu where menu = @menu and not exists(select 1 from pos_tpay a, pccode b where pos_tmenu.menu = a.menu and a.paycode = b.pccode and charindex(b.deptno2, 'TOA')>0 and charindex(a.crradjt, 'C CO')=0)
	if @amount is null
		select @amount = 0
	if rtrim(@no) is not null
		begin
		update guest set fb = isnull(fb,0) +  isnull(@amount,0), fb_times1 = isnull(fb_times1,0) + 1,tl=isnull(tl,0) +  isnull(@amount,0)  where no = @no
		select @year = convert(char(4), datepart(year, @bdate)), @month = datepart(month, @bdate)
		insert guest_xfttl(no, year, tag)
			select @no, @year, b.code from basecode b
			where b.cat='guest_sumtag' and not exists(select 1 from guest_xfttl c where c.no=@no and c.year=@year and c.tag=b.code)
		if @month = 1
			update guest_xfttl set m1=m1+@amount,ttl=ttl+@amount where guest_xfttl.no=@no and guest_xfttl.year=@year and (guest_xfttl.tag='FB' or guest_xfttl.tag='TTL')
		else if @month = 2
			update guest_xfttl set m2=m2+@amount,ttl=ttl+@amount where guest_xfttl.no=@no and guest_xfttl.year=@year and (guest_xfttl.tag='FB' or guest_xfttl.tag='TTL')
		else if @month = 3
			update guest_xfttl set m3=m3+@amount,ttl=ttl+@amount where guest_xfttl.no=@no and guest_xfttl.year=@year and (guest_xfttl.tag='FB' or guest_xfttl.tag='TTL')
		else if @month = 4
			update guest_xfttl set m4=m4+@amount,ttl=ttl+@amount where guest_xfttl.no=@no and guest_xfttl.year=@year and (guest_xfttl.tag='FB' or guest_xfttl.tag='TTL')
		else if @month = 5
			update guest_xfttl set m5=m5+@amount,ttl=ttl+@amount where guest_xfttl.no=@no and guest_xfttl.year=@year and (guest_xfttl.tag='FB' or guest_xfttl.tag='TTL')
		else if @month = 6
			update guest_xfttl set m6=m6+@amount,ttl=ttl+@amount where guest_xfttl.no=@no and guest_xfttl.year=@year and (guest_xfttl.tag='FB' or guest_xfttl.tag='TTL')
		else if @month = 7
			update guest_xfttl set m7=m7+@amount,ttl=ttl+@amount where guest_xfttl.no=@no and guest_xfttl.year=@year and (guest_xfttl.tag='FB' or guest_xfttl.tag='TTL')
		else if @month = 8
			update guest_xfttl set m8=m8+@amount,ttl=ttl+@amount where guest_xfttl.no=@no and guest_xfttl.year=@year and (guest_xfttl.tag='FB' or guest_xfttl.tag='TTL')
		else if @month = 9
			update guest_xfttl set m9=m9+@amount,ttl=ttl+@amount where guest_xfttl.no=@no and guest_xfttl.year=@year and (guest_xfttl.tag='FB' or guest_xfttl.tag='TTL')
		else if @month = 10
			update guest_xfttl set m10=m10+@amount,ttl=ttl+@amount where guest_xfttl.no=@no and guest_xfttl.year=@year and (guest_xfttl.tag='FB' or guest_xfttl.tag='TTL')
		else if @month = 11
			update guest_xfttl set m11=m11+@amount,ttl=ttl+@amount where guest_xfttl.no=@no and guest_xfttl.year=@year and (guest_xfttl.tag='FB' or guest_xfttl.tag='TTL')
		else if @month = 12
			update guest_xfttl set m12=m12+@amount,ttl=ttl+@amount where guest_xfttl.no=@no and guest_xfttl.year=@year and (guest_xfttl.tag='FB' or guest_xfttl.tag='TTL')
		end
	if rtrim(@cusno) is not null
		update guest set fb = isnull(fb,0) +  isnull(@amount,0), fb_times1 = isnull(fb_times1,0) + 1,tl=isnull(tl,0) +  isnull(@amount,0)  where no = @cusno
	fetch c_menu into @menu, @cusno, @no
end
close c_menu
deallocate cursor c_menu

--================���ֶ�ռ����
delete sp_tdish
insert sp_tdish select * from sp_dish
delete sp_tmenu
insert sp_tmenu select * from sp_menu
delete sp_tpay
-- -- ���������տ����sp_tpay, sp_pay ����ʷ����
insert sp_tpay select * from sp_pay where bdate = @bdate0

delete sp_hmenu from sp_hmenu where menu in (select menu from sp_tmenu)
insert sp_hmenu select * from sp_menu
delete sp_hdish from sp_hdish where menu in (select menu from sp_tmenu)
insert sp_hdish select * from sp_dish
--
delete sp_hpay where menu+convert(varchar,number) in (select menu + convert(varchar,number) from sp_pay)
-- -- δʹ�ö��𱣴��ڵ�ǰ�� sta = '1' and rtrim(mneu0) = null, sp_pay.menu0 <> ''��ָ��ʹ�ö��𡯺͡���ʹ�ö��� ���͡���������
insert sp_hpay select * from sp_pay where charindex(sta, '23') > 0 or rtrim(menu0) > ''

delete sp_dish
delete sp_menu
delete sp_pay where charindex(sta, '23') > 0 or rtrim(menu0) > ''
----
delete sp_hplaav where bdate = @bdate0
insert sp_hplaav select * from sp_plaav where bdate = @bdate0 and sta <> 'R'
delete sp_plaav where bdate = @bdate0 and sta <> 'R'

-- -- �ж����Ԥ�����ܵ�����ʷ��, Ҫ����sp_hreserve ���ظ���
--delete #resno
--insert into #resno  select resno from sp_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from sp_pay where sp_pay.menu = sp_reserve.resno and sp_pay.sta ='1')
delete sp_hreserve where resno in(select resno from sp_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from sp_pay where sp_pay.menu = sp_reserve.resno and sp_pay.sta ='1'))
delete sp_hplaav where resno   in(select resno from sp_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from sp_pay where sp_pay.menu = sp_reserve.resno and sp_pay.sta ='1'))
insert sp_hplaav select * from sp_plaav where resno in(select resno from sp_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from sp_pay where sp_pay.menu = sp_reserve.resno and sp_pay.sta ='1'))
delete sp_plaav where resno in(select resno from sp_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from sp_pay where sp_pay.menu = sp_reserve.resno and sp_pay.sta ='1'))
insert into sp_hreserve select * from sp_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from sp_pay where sp_pay.menu = sp_reserve.resno and sp_pay.sta ='1')
delete from sp_reserve where datediff(day ,date0 , @bdate)>0 and not exists(select 1 from sp_pay where sp_pay.menu = sp_reserve.resno and sp_pay.sta ='1')

-- ͳ�ƿ��˲������ѽ�����
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
   
commit tran
return 0

;