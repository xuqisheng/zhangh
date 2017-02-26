if exists(select * from sysobjects where name = 'p_gds_report_breakfast_sum')
	drop proc p_gds_report_breakfast_sum;

create proc p_gds_report_breakfast_sum
	@begin			datetime, 
	@end				datetime, 
	@type				char(1),		-- 包价代码类别
	@class			char(1)    	-- 分类方法：
as
------------------------------------------
-- 早餐报表生成
------------------------------------------
create table #breakfast
(
	accnt			char(10)			not null,
	code			char(10)			not null,
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


create table #breakfast_out
(
	code			char(10)			not null,
	descript    char(20)       null,
	number      money				default 0 not null,
	amount		money				default 0 not null
)

declare 	@curdate		datetime,
			@bcode		char(3)
select  @curdate = bdate1 from sysdata

--
insert #breakfast (accnt, code,roomno, package, pccode, quantity, amount) 
	select a.accnt, a.code,a.roomno, a.code, b.pccode, a.quantity, a.quantity*b.amount from package_detail a, package b
		where datediff(dd,a.bdate, @begin) <= 0 and datediff(dd,a.bdate, @end) >=0 and a.tag < '5' and a.code = b.code and b.type = @type
	union all 
	select a.accnt, a.code,a.roomno, a.code, b.pccode, a.quantity, a.quantity*b.amount from hpackage_detail a, package b
		where datediff(dd,a.bdate, @begin) <= 0 and datediff(dd,a.bdate, @end) >=0 and a.tag < '5' and a.code = b.code and b.type = @type

update #breakfast set groupno = a.groupno, headname = a.headname, name = a.name
	from rmpostbucket a where #breakfast.accnt = a.accnt and a.rmpostdate = @begin

--
update #breakfast set arr=a.arr, dep=a.dep,market=a.market from master a where #breakfast.accnt=a.accnt
update #breakfast set arr=a.arr, dep=a.dep,market=a.market from hmaster a where #breakfast.accnt=a.accnt
update #breakfast set grp=a.grp from mktcode a where #breakfast.market=a.code

if @class = '1'  --按包价定义汇总
	begin
	insert #breakfast_out select a.code ,'',sum(a.quantity),sum(a.amount) from #breakfast a group by a.code
	update #breakfast_out set descript = a.descript from package a where #breakfast_out.code = a.code
	end
else				  --按市场码定义汇总
	begin
	insert #breakfast_out select a.market,'',sum(a.quantity),sum(a.amount) from #breakfast a group by a.market
	update #breakfast_out set descript = a.descript from mktcode a where #breakfast_out.code = a.code
	end

select code,descript,number,amount from  #breakfast_out

return 0
;