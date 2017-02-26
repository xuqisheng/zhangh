if exists(select * from sysobjects where name = 'p_gl_report_breakfast')
	drop proc p_gl_report_breakfast;

create proc p_gl_report_breakfast
	@bdate			datetime, 
	@type				char(1) 
as
------------------------------------------
-- 早餐报表生成
------------------------------------------
create table #breakfast
(
	accnt			char(10)			not null,
	roomno		char(5)			not null,
	groupno		char(10)			null, 
	headname		varchar(100)	null, 
	name			varchar(50)		null, 
	package		char(4)			null, 
	pccode		char(5)			null, 
	descript		char(24)			null, 
   market      char(3)        null,
   grp         char(16)       null,
	quantity		integer			default 0 not null, 
	amount		money				default 0 not null,
	inhouse		integer			default 1 not null,  -- 当前住客 -> 预测用
	arr			datetime			null,
	dep			datetime			null
)

declare 	@curdate		datetime,
			@bcode		char(4)
select  @curdate = bdate1 from sysdata

if @bdate <= @curdate 
begin
	--
	select @bdate = dateadd(dd, -1, @bdate)
	insert #breakfast (accnt, roomno, package, pccode, quantity, amount) 
		select a.accnt, a.roomno, a.code, b.pccode, a.quantity, a.quantity*b.amount from package_detail a, package b
			where a.bdate = @bdate and a.tag < '5' and a.code = b.code and b.type = @type
		union all 
		select a.accnt, a.roomno, a.code, b.pccode, a.quantity, a.quantity*b.amount from hpackage_detail a, package b
			where a.bdate = @bdate and a.tag < '5' and a.code = b.code and b.type = @type

	update #breakfast set groupno = a.groupno, headname = a.headname, name = a.name
		from rmpostbucket a where #breakfast.accnt = a.accnt and a.rmpostdate = @bdate
end
else
begin
	declare c_gds cursor for select code from package where type='1' order by code
	open c_gds 
	fetch c_gds into @bcode
	while @@sqlstatus = 0
	begin
	insert #breakfast (accnt, roomno, groupno, package, inhouse)
			select accnt, roomno, groupno, @bcode, 1 from master 
			where datediff(dd,@bdate,dep)>=0 and class='F' and sta='I' and charindex(','+rtrim(@bcode)+',',','+rtrim(packages)+',')>0
		insert #breakfast (accnt, roomno, groupno, package, inhouse)
			select accnt, roomno, groupno, @bcode, 0 from master 
			where datediff(dd,@bdate,dep)>=0 and datediff(dd,@bdate,arr)=-1 and class='F' and sta='R' and charindex(','+rtrim(@bcode)+',',','+rtrim(packages)+',')>0
		
		fetch c_gds into @bcode
	end
	close c_gds
	deallocate cursor c_gds

	update #breakfast set pccode=a.pccode, quantity=a.quantity, amount=a.amount --, descript=a.descript 
		from package a where #breakfast.package=a.code
	update #breakfast set name=a.haccnt, headname='[ 散客 ]' 
		from master_des a where #breakfast.groupno='' and #breakfast.accnt=a.accnt
	update #breakfast set name=a.haccnt, headname='[ 长包房 ]' 
		from master_des a, mktcode b where #breakfast.groupno='' and #breakfast.accnt=a.accnt and a.market_o=b.code and b.flag='LON'
	update #breakfast set name=a.haccnt, headname=a.groupno 
		from master_des a where #breakfast.groupno<>'' and #breakfast.accnt=a.accnt
end

--
update #breakfast set arr=a.arr, dep=a.dep,market=a.market from master a where #breakfast.accnt=a.accnt
update #breakfast set arr=a.arr, dep=a.dep,market=a.market from hmaster a where #breakfast.accnt=a.accnt
update #breakfast set grp=a.grp from mktcode a where #breakfast.market=a.code

--
--select pccode, descript, groupno, headname, accnt, roomno, name, package, quantity, amount, inhouse 
--	from #breakfast order by pccode, groupno, headname, roomno

select a.pccode, a.descript, a.groupno, a.headname, a.accnt, a.roomno, a.name,
		a.package,a.grp,a.market,a.quantity, a.amount, a.arr, a.dep
	from #breakfast a, rmsta b where a.roomno*=b.roomno
		order by a.grp,a.market,b.oroomno, a.pccode, a.groupno, a.roomno


return 0
;