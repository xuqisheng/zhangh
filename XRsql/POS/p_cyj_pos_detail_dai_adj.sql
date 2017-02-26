if exists(select 1 from sysobjects where name='p_cyj_pos_detail_dai_adj' and type ='P')
	drop proc p_cyj_pos_detail_dai_adj;
create proc p_cyj_pos_detail_dai_adj
	@menu			char(10)
as
--------------------------------------------------------------------------------------------------
-- 联单多种付款，又可能每个餐单分摊不均，调整pos_detail_dai
--------------------------------------------------------------------------------------------------
declare		
	@hpay		char(1),
	@pcrec	char(10),
	@tmps		char(5),
	@paycode	char(5),
	@ii		integer,
	@Cnt		integer,
	@tmpd		money,
	@amount	money

if exists(select 1 from pos_menu where menu=@menu)
	select @hpay = 'F'
else
	select @hpay = 'T'

if @hpay = 'F'
	select @pcrec = pcrec from pos_menu where menu = @menu 
else
	select @pcrec = pcrec from pos_hmenu where menu = @menu 
if ltrim(@pcrec) = '' or  ltrim(@pcrec) is null
	return 

if @hpay = 'F'
	if not exists(select 1 from pos_menu a where a.menu =@pcrec and 
		(select sum(b.amount - b.dsc + b.srv + b.tax) from pos_dish b where a.menu=b.menu and ltrim(code)<='X' and charindex(sta, '03579A')>0)
	<> (select sum(c.amount) from pos_detail_dai c where a.menu=c.menu) 	)
		return
if @hpay = 'T'
	if not exists(select 1 from pos_hmenu a where a.menu =@pcrec and 
		(select sum(b.amount - b.dsc + b.srv + b.tax) from pos_hdish b where a.menu=b.menu and ltrim(code)<='X' and charindex(sta, '03579A')>0)
	<> (select sum(c.amount) from pos_detail_dai c where a.menu=c.menu) 	)
		return

if @hpay ='F'
	declare  c_cur1 cursor for
	select paycode,count(1) from pos_detail_dai a,pos_menu b where b.pcrec =@pcrec and a.menu=b.menu group by paycode
else
	declare  c_cur1 cursor for
	select paycode,count(1) from pos_detail_dai a,pos_hmenu b where b.pcrec =@pcrec and a.menu=b.menu group by paycode

open c_cur1
select @Cnt = 0
fetch c_cur1 into @tmps,@ii
while @@sqlstatus = 0 
	begin
	if @ii > @Cnt
		select @Cnt = @ii
	fetch c_cur1 into @tmps,@ii
	end	
close c_cur1

if @hpay ='F'
	declare  c_cur2 cursor for
	select paycode,sum(a.amount) from pos_detail_dai a,pos_menu b where b.pcrec =@pcrec and a.menu=b.menu group by paycode having count(1) = @Cnt
else
	declare  c_cur2 cursor for
	select paycode,sum(a.amount) from pos_detail_dai a,pos_hmenu b where b.pcrec =@pcrec and a.menu=b.menu group by paycode having count(1) = @Cnt
open c_cur2
select @amount = 0
fetch c_cur2 into @tmps,@tmpd
while @@sqlstatus = 0 
	begin
	if @amount < @tmpd
		select @amount = @tmpd, @paycode = @tmps
	fetch c_cur2 into @tmps,@tmpd
	end
close c_cur2
if @hpay = 'F'
	update pos_detail_dai set amount = a.amount 
	- isnull((select sum(c.amount) from pos_detail_dai c where c.menu=b.menu),0) + isnull((select sum(d.amount - d.dsc + d.srv + d.tax) from pos_dish d where b.menu=d.menu and ltrim(d.code)<='X' and charindex(d.sta, '03579A')>0),0) 
	from pos_detail_dai a, pos_menu b where a.menu=b.menu and b.pcrec = @pcrec and a.paycode = @paycode
else
	update pos_detail_dai set amount = a.amount 
	- isnull((select sum(c.amount) from pos_detail_dai c where c.menu=b.menu),0) + isnull((select sum(d.amount - d.dsc + d.srv + d.tax) from pos_hdish d where b.menu=d.menu and ltrim(d.code)<='X'and charindex(d.sta, '03579A')>0),0) 
	from pos_detail_dai a, pos_hmenu b where a.menu=b.menu and b.pcrec = @pcrec and a.paycode = @paycode
deallocate cursor c_cur1
deallocate cursor c_cur2
	

;
