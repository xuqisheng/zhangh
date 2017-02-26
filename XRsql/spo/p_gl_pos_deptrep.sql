drop  proc p_gl_pos_deptrep;
create proc p_gl_pos_deptrep
as
-----------------------------------------------------------------------------------*/
--
--		餐饮部门日报表: 夜审生成
--				 jjh
--					posdai.code = 'FF1' 转登记AR账, 已经包含在转AR里，只需在最后单列
--					posdai.code = 'G'   登记账结账, 包括转到其他账
--																									jjhotel cyj
--			定金统计，因为预定单倒入历史在前，所以别忘了关联pos_hreserve   cyj 2004/03/01
------------------------------------------------------------------------------------*/
declare
	@duringaudit		char(1),
	@bdate				datetime,
	@bfdate				datetime,
   @isfstday			char(1) ,
   @isyfstday			char(1) ,

	@type					char(3),
	@tocode				char(3),
	@descript1			char(10),

   @dsc_sttype    char(2) ,
   @p_daokous     varchar(100),
   @daokou        char(1) ,

	@menu				char(10),
	@pccode			char(3),

	@code   char(3),
   @amount	money,

	@descript		char(10),
	@paycode			char(3),
	@paytail			char(1),
	@shift			char(1),
	@empno			char(10),
	@i					integer,
	@feed				money,
	@feedd			money,
	@feem				money,
	@feemm			money,
	@pccodes			varchar(120),
	@modu_ids		varchar(120),
	@codes			varchar(160),
	@paycodes		varchar(160),
	@vpos				integer,
	@subtotal		varchar(255),
	@ydeptrep		varchar(255),
	@pccode1         char(3),
	@tocode1			char(3),
	@amountall    money

create table #deptjie
(
	pccode         char(3)  default '' not null,
	shift          char(1)  default '' not null,
	empno          char(10)  default '' not null,
	code           char(3)  default '' not null,
	feed          money    default 0  not null
)
create unique index index1 on #deptjie(pccode,shift,empno,code)

create table #deptdai
(
	pccode         char(3)  default '' not null,
	shift          char(1) default '' not null,
	empno          char(10)  default '' not null,
	paycode        char(3)  default '' not null,
	paytail        char(1)  default '' not null,
	creditd        money    default 0  not null
)
create unique index index1 on #deptdai(pccode,shift,empno,paycode,paytail)

select * into #pos_pay from pos_pay where 1=2
select * into #pos_reserve from pos_reserve where 1=2
----sport
select * into #sp_pay from sp_pay where 1=2
select * into #sp_reserve from sp_reserve where 1=2
-----------
select * into #pos_detail_jie_link from pos_detail_jie_link where 1=2

select @duringaudit= audit from gate
if @duringaudit = 'T'
   select @bdate = bdate from sysdata
else
   select @bdate = bdate from accthead
select @bfdate = dateadd(day,-1,@bdate)
select @dsc_sttype = value from sysoption where catalog = 'pos' and item = 'dsc_sttype'
if @@rowcount = 0
select @dsc_sttype ='nn'
exec p_hry_audit_fstday @bdate,@isfstday out,@isyfstday out

insert into #pos_pay select * from pos_pay where bdate = @bdate
	union select * from pos_hpay where bdate = @bdate
insert into #pos_reserve select * from pos_reserve where resno in (select menu from #pos_pay)
insert into #pos_reserve select * from pos_hreserve where resno in (select menu from #pos_pay) and resno not in (select resno from #pos_reserve)
-------sport-------
insert into #sp_pay select * from sp_pay where bdate = @bdate
	union select * from sp_hpay where bdate = @bdate
insert into #sp_reserve select * from sp_reserve where resno in (select menu from #sp_pay)
insert into #sp_reserve select * from sp_hreserve where resno in (select menu from #sp_pay) and resno not in (select resno from #sp_reserve)
-------------------
select @p_daokous =''
declare c_pccode cursor for select pccode,daokou from pos_pccode
open c_pccode
fetch c_pccode into @pccode,@daokou
while @@sqlstatus = 0
   begin
   select @p_daokous = @p_daokous + @pccode + @daokou+'#'
   fetch c_pccode into @pccode,@daokou
   end
close c_pccode
deallocate cursor c_pccode
if @isfstday = 'T'
   begin
   truncate table deptjie
   truncate table deptdai
   end
begin  tran
update deptjie set feem = feem - feed  where date = @bdate
update deptjie set feed = 0,date = @bfdate,daymark = ' '
update deptdai set creditm = creditm - creditd  where date = @bdate
update deptdai set creditd = 0,date = @bfdate,daymark = ' '
commit tran


exec  p_gl_pos_detail  '',	@bdate   --餐饮
exec  p_cq_sp_detail  '',	@bdate   --康乐


exec p_gds_pos_detail_jie_link 'PCID',@bdate,'1'

insert into #pos_detail_jie_link select * from pos_detail_jie_link where date = @bdate and pc_id = 'PCID'
update #pos_detail_jie_link set amount0 = 0,amount1= 0,amount2 = 0 where type in (select pccode from pccode where pccode>'900' and deptno8<>'' and deptno8 is not null) and special <>'E'

-- 所有点菜
insert #deptjie (pccode,shift,empno,code,feed) select pccode,shift,empno,tocode, sum(amount0 -amount1 - amount2 - amount3)
	from #pos_detail_jie_link where date = @bdate  and special <> 'E'
	group by pccode,shift,empno,tocode


-- <单菜折扣>
insert #deptjie (pccode,shift,empno,code,feed) select pccode,shift,empno,'607',sum(amount3)
	from #pos_detail_jie_link where date =@bdate and type='8' and special = 'N'
	group by pccode,shift,empno
insert #deptdai (pccode,shift,empno,paycode,paytail,creditd) select pccode,shift,empno,'D93',char(29),sum(amount3)
	from #pos_detail_jie_link where date = @bdate and type='8' and special = 'N'
	group by pccode,shift,empno

-- <全免>
insert #deptjie (pccode,shift,empno,code,feed) select pccode,shift,empno,'605',sum(amount3)
	from #pos_detail_jie_link where date = @bdate and type='6' and special = 'N'
	group by pccode,shift,empno
insert #deptdai (pccode,shift,empno,paycode,paytail,creditd) select pccode,shift,empno,'D93',char(28),sum(amount3)
	from #pos_detail_jie_link where date = @bdate and type='6' and special = 'N'
	group by pccode,shift,empno
-- <赠送>
insert #deptjie (pccode,shift,empno,code,feed) select pccode,shift,empno,'602',sum(amount3)
	from #pos_detail_jie_link where date = @bdate and type='4' and special = 'N'
	group by pccode,shift,empno
insert #deptdai (pccode,shift,empno,paycode,paytail,creditd) select pccode,shift,empno,'D93',char(27),sum(amount3)
	from #pos_detail_jie_link where date = @bdate and type='4' and special = 'N'
	group by pccode,shift,empno

-- 百分比折扣
insert #deptjie (pccode,shift,empno,code,feed) select pccode,shift,empno,'610',sum(amount1+amount2)
	from #pos_detail_jie_link where date = @bdate and type in ('0','','4','6','8') and special <> 'T'
	group by pccode,shift,empno
insert #deptdai (pccode,shift,empno,paycode,paytail,creditd) select pccode,shift,empno,'D93',char(30),sum(amount1+amount2)
	from #pos_detail_jie_link where date = @bdate and type in ('0','','4','6','8') and special <> 'T'
	group by pccode,shift,empno
-- 特优码折扣
insert #deptjie (pccode,shift,empno,code,feed) select pccode,shift,empno,'620',sum(amount3)
	from #pos_detail_jie_link where date = @bdate and type='0' and special = 'T'
	group by pccode,shift,empno
insert #deptdai (pccode,shift,empno,paycode,paytail,creditd) select pccode,shift,empno,'D93',char(31),sum(amount3)
	from #pos_detail_jie_link where date = @bdate and type='0' and special = 'T'
	group by pccode,shift,empno

-- 款待
insert #deptjie (pccode,shift,empno,code,feed) select a.pccode,a.shift,a.empno,substring(b.deptno8,1,3),sum(a.amount3)
	from #pos_detail_jie_link a,pccode b where a.date = @bdate and b.pccode = a.type
	group by a.pccode,a.shift,a.empno,substring(b.deptno8,1,3)

-- 总计
insert #deptjie (pccode,shift,empno,code,feed) select pccode,shift,empno,'999',sum(feed)
	from #deptjie
	group by pccode,shift,empno
-- 实际收入
insert #deptjie (pccode,shift,empno,code,feed) select pccode,shift,empno,'6',sum(feed)
	from #deptjie where code < '6'
	group by pccode,shift,empno
-- 平均消费：元
insert #deptjie (pccode,shift,empno,code,feed) select distinct pccode,shift,empno,'99B',0
	from #deptjie

-- 总台输入
select @modu_ids = isnull((select value from sysoption where catalog = 'audit' and item = 'modu_id'), '02#03#05#')
--daniel changed  2004.09.21
--insert #deptjie (pccode, shift, empno, code, feed) select substring(pccode,1,2)+'0', shift, empno, 'ZZZ', sum(charge)
--	from gltemp where charindex(modu_id, @modu_ids) > 0 group by substring(pccode,1,2)+'0', shift, empno
insert #deptjie (pccode, shift, empno, code, feed) select b.pccode, a.shift, a.empno, 'ZZX', isnull(sum(a.charge),0)
	from gltemp a,pos_pccode b  where a.pccode = b.chgcod and charindex(modu_id, @modu_ids) > 0
   group by b.pccode, a.shift, a.empno


--收入合计--
--daniel add for 收入合计 2004.09.22

insert #deptjie (pccode,shift,empno,code,feed) select pccode,shift,empno,'ZZZ',isnull(sum(feed),0)
	from #deptjie where code < '6'
	group by pccode,shift,empno

update #deptjie set feed = feed + (select isnull(sum(feed),0) from #deptjie b where b.code='ZZX'
											 and #deptjie.pccode=b.pccode and  #deptjie.code=b.code
                 and #deptjie.shift =b.shift)
     where #deptjie.code='ZZZ'


-- 就餐人数：人
insert #deptjie (pccode,shift,empno,code,feed) select pccode,shift,empno3,'99A',sum(guest)
	from pos_tmenu
	where paid = '1'
	group by pccode,shift,empno3
-- 桌   数
insert #deptjie (pccode,shift,empno,code,feed) select pccode,shift,empno3,'99C',sum(tables)
	from pos_tmenu
	where paid = '1'
	group by pccode,shift,empno3

-- <逃帐>
insert #deptjie (pccode,shift,empno,code,feed) select pccode,shift,empno3,'900',sum(amount)
	from pos_tmenu
	where paid = '0'
	group by pccode,shift,empno3

-- <逃帐追回>
if exists (select 1 from pos_tmenu where  menu not like convert(char(6), bdate, 12) +'%')
	insert #deptjie (pccode, shift, empno, code, feed) select pccode, shift,empno3, '905', sum(amount)
	from pos_tmenu
	where  menu not like convert(char(6), bdate, 12) +'%' and paid ='1'
	group by pccode,shift,empno3


insert #deptjie (pccode,shift,empno,code,feed) select pccode,'9',empno,code,sum(feed)
	from #deptjie
	group by pccode,empno,code

insert #deptjie (pccode,shift,empno,code,feed) select pccode,shift,'{{{',code,sum(feed)
	from #deptjie
	group by pccode,shift,code


-- 使用定金
insert #deptdai (pccode,shift,empno,paycode,paytail,creditd)
	select a.pccode,a.shift,a.empno3,'B' + substring(c.deptno1, 2, 2),'',sum(b.amount)
	from pos_tmenu a,pos_detail_dai b,pccode c
	where a.menu = b.menu and a.paid = '1' and b.paycode = c.pccode
	and b.reason3 = '定' and (c.deptno8 = '' or c.deptno8 is null)
	group by a.pccode,a.shift,a.empno3,c.deptno1

-- 结帐
insert #deptdai (pccode,shift,empno,paycode,paytail,creditd)
	select a.pccode,a.shift,a.empno3, c.deptno1,'',sum(b.amount)
	from pos_tmenu a,pos_detail_dai b,pccode c
	where a.menu= b.menu and a.paid = '1' and b.paycode = c.pccode
	and b.reason3 <> '定' and (c.deptno8 = '' or c.deptno8 is null)
	group by a.pccode,a.shift,a.empno3,c.deptno1

-- 款待优惠
insert #deptdai (pccode,shift,empno,paycode,paytail,creditd)
	select a.pccode,a.shift,a.empno3,'D' + substring(c.deptno1, 2, 2),'',sum(b.amount)
	from pos_tmenu a,pos_detail_dai b,pccode c
	where a.menu = b.menu and a.paid = '1' and b.paycode = c.pccode and c.deptno8 <> '' and  c.deptno8 is not null
	group by a.pccode,a.shift,a.empno3,c.deptno1

-- 定金
insert #deptdai (pccode,shift,empno,paycode,paytail,creditd)
	select a.pccode,b.shift,b.empno,'E' + substring(c.deptno1, 2, 2),'',sum(b.amount)
	from #pos_reserve a,#pos_pay b,pccode c
	where a.resno = b.menu and b.bdate = @bdate and b.paycode = c.pccode and b.sta ='1'
	group by a.pccode,b.shift,b.empno,c.deptno1

insert #deptdai (pccode,shift,empno,paycode,paytail,creditd)
	select a.pccode,b.shift,b.empno,'E' + substring(c.deptno1, 2, 2),'',sum(b.amount)
	from pos_tmenu a,#pos_pay b,pccode c
	where a.menu = b.menu and b.bdate = @bdate and b.paycode = c.pccode and b.sta ='1'
	group by a.pccode,b.shift,b.empno,c.deptno1


insert #deptdai (pccode,shift,empno,paycode,paytail,creditd)
	select a.pccode, b.shift, b.empno, 'FF1', '', sum(b.amount)
	from pos_tmenu a, pos_tpay b, master d
	where a.menu = b.menu and b.bdate = @bdate
	and b.accnt = d.accnt and d.accnt like 'AR%' and d.artag1 = 'Z'
	and charindex(b.crradjt, 'C CO') = 0
	group by a.pccode, b.shift, b.empno

--sport-----------
-- <逃帐>
insert #deptjie (pccode,shift,empno,code,feed) select pccode,shift,empno3,'900',sum(amount)
	from sp_tmenu
	where paid = '0'
	group by pccode,shift,empno3

-- <逃帐追回>
if exists (select 1 from pos_tmenu where  menu not like convert(char(6), bdate, 12) +'%')
	insert #deptjie (pccode, shift, empno, code, feed) select pccode, shift,empno3, '905', sum(amount)
	from sp_tmenu
	where  menu not like convert(char(6), bdate, 12) +'%' and paid ='1'
	group by pccode,shift,empno3

-- 使用定金
insert #deptdai (pccode,shift,empno,paycode,paytail,creditd)
	select a.pccode,a.shift,a.empno3,'B' + substring(c.deptno1, 2, 2),'',sum(b.amount)
	from sp_tmenu a,pos_detail_dai b,pccode c
	where a.menu = b.menu and a.paid = '1' and b.paycode = c.pccode
	and b.reason3 = '定' and (c.deptno8 = '' or c.deptno8 is null)
	group by a.pccode,a.shift,a.empno3,c.deptno1

-- 结帐
insert #deptdai (pccode,shift,empno,paycode,paytail,creditd)
	select a.pccode,a.shift,a.empno3, c.deptno1,'',sum(b.amount)
	from sp_tmenu a,pos_detail_dai b,pccode c
	where a.menu= b.menu and a.paid = '1' and b.paycode = c.pccode
	and b.reason3 <> '定' and (c.deptno8 = '' or c.deptno8 is null)
	group by a.pccode,a.shift,a.empno3,c.deptno1

-- 款待优惠
insert #deptdai (pccode,shift,empno,paycode,paytail,creditd)
	select a.pccode,a.shift,a.empno3,'D' + substring(c.deptno1, 2, 2),'',sum(b.amount)
	from sp_tmenu a,pos_detail_dai b,pccode c
	where a.menu = b.menu and a.paid = '1' and b.paycode = c.pccode and c.deptno8 <> '' and  c.deptno8 is not null
	group by a.pccode,a.shift,a.empno3,c.deptno1

-- 定金
insert #deptdai (pccode,shift,empno,paycode,paytail,creditd)
	select a.pccode,b.shift,b.empno,'E' + substring(c.deptno1, 2, 2),'',sum(b.amount)
	from #sp_reserve a,#sp_pay b,pccode c
	where a.resno = b.menu and b.bdate = @bdate and b.paycode = c.pccode and b.sta ='1'
	group by a.pccode,b.shift,b.empno,c.deptno1

insert #deptdai (pccode,shift,empno,paycode,paytail,creditd)
	select a.pccode,b.shift,b.empno,'E' + substring(c.deptno1, 2, 2),'',sum(b.amount)
	from sp_tmenu a,#pos_pay b,pccode c
	where a.menu = b.menu and b.bdate = @bdate and b.paycode = c.pccode and b.sta ='1'
	group by a.pccode,b.shift,b.empno,c.deptno1


insert #deptdai (pccode,shift,empno,paycode,paytail,creditd)
	select a.pccode, b.shift, b.empno, 'FF1', '', sum(b.amount)
	from sp_tmenu a, pos_tpay b, master d
	where a.menu = b.menu and b.bdate = @bdate
	and b.accnt = d.accnt and d.accnt like 'AR%' and d.artag1 = 'Z'
	and charindex(b.crradjt, 'C CO') = 0
	group by a.pccode, b.shift, b.empno
-----------------------------

-----jjh----------------------------
declare	@billno		char(10), @sum_charge money
select * into #araccnt0 from account where 1=2
select * into #araccnt from account where 1=2
insert into #araccnt0 select a.* from account a, master b where a.accnt = b.accnt and a.accnt like 'AR%' and b.artag1 = 'Z' and a.bdate = @bdate
insert into #araccnt0 select a.* from haccount a, master b where a.accnt = b.accnt and a.accnt like 'AR%' and b.artag1 = 'Z' and a.bdate = @bdate
insert into #araccnt0 select b.* from #araccnt0 a,account b where a.billno = b.billno and substring(a.billno,2,5) = substring(convert(char(8), @bdate, 12),2,5) and b.bdate <> @bdate
insert into #araccnt0 select b.* from #araccnt0 a,haccount b where a.billno = b.billno and substring(a.billno,2,5) = substring(convert(char(8), @bdate, 12),2,5) and b.bdate <> @bdate

insert into #araccnt select distinct * from #araccnt0

--  将登记账中的不是餐饮转账过滤, 并将登记账中的费用码改回对应的餐厅号
if exists(select 1 from sysoption where catalog ='pos' and item ='using_pos_int_pccode' and charindex(rtrim(value),'TtYy')>0 )
	begin
	delete #araccnt where pccode not in(select pccode from pos_int_pccode where class ='2')
	update #araccnt set pccode = a.pos_pccode from pos_int_pccode a where #araccnt.pccode = a.pccode and a.class ='2'
	end
else
	begin
	delete #araccnt where pccode not in(select chgcod from pos_pccode)
	update #araccnt set pccode = a.pccode from pos_pccode a where #araccnt.pccode = a.chgcod
	end

delete #araccnt where bdate <> @bdate and billno not like 'B%'


insert #deptdai (pccode,shift,empno,paycode,paytail,creditd)
	select d.pos_pccode, b.shift, b.empno, 'G' + substring(c.deptno1,2,2), '', 0
	from #araccnt a, #araccnt b, pccode c, pos_int_pccode d
	where a.accnt = b.accnt and a.billno = b.billno and a.billno like 'B%' and a.pccode < '9' and b.pccode > '9'
	and b.pccode = c.pccode and a.pccode = d.pccode and d.class='2'
	group by d.pos_pccode, c.deptno1, b.shift, b.empno

declare	@tmp_pc		char(3), @tmp_charge money

declare  c_billno cursor  for select distinct billno from #araccnt where billno like 'B%' and substring(billno,2,5) = substring(convert(char(8), @bdate,12),2,5)
declare  c_pc     cursor  for select distinct b.pos_pccode, a.charge from #araccnt a, pos_int_pccode b where b.class='2' and a.pccode = b.pccode and a.pccode < '9' and a.billno = @billno
open c_billno
fetch c_billno into @billno
while @@sqlstatus = 0
	begin
	select @sum_charge = sum(charge) from #araccnt where billno = @billno
	if @sum_charge <> 0
		begin
		open c_pc
		fetch c_pc into @tmp_pc, @tmp_charge
		while @@sqlstatus = 0
			begin
			update #deptdai set creditd =creditd + round(@tmp_charge * c.credit / @sum_charge, 2)
			from #deptdai a, #araccnt c, pccode b where c.billno = @billno and c.pccode > '9'
			and a.pccode = @tmp_pc   and a.paycode = 'G' + substring(b.deptno1, 2, 2)
			and c.shift = a.shift and c.empno = a.empno
			and c.pccode = b.pccode
			fetch c_pc into @tmp_pc, @tmp_charge
			end
		close c_pc
		end
	fetch c_billno into @billno
	end
close c_billno
deallocate cursor c_billno
deallocate cursor c_pc


insert #deptdai (pccode,shift,empno,paycode,paytail,creditd)
	select b.pos_pccode, a.shift, a.empno, 'GG1' , '', sum(-1 * a.charge)
	from #araccnt a, pos_int_pccode b
	where  b.class='2' and a.pccode = b.pccode and a.billno  like 'T%' and a.pccode < '9'
	group by b.pos_pccode, a.shift, a.empno


insert #deptdai (pccode,shift,empno,paycode,paytail,creditd)
	select b.pos_pccode, a.shift, a.empno, 'GG2' , '', sum(a.charge)
	from #araccnt a, pos_int_pccode b
	where b.class='2' and a.pccode =b.pccode and rtrim(a.billno) is null and a.pccode < '9' and a.modu_id ='02'
	group by b.pos_pccode, a.shift, a.empno
-----jjh----------------------------



insert #deptdai (pccode,shift,empno,paycode,paytail,creditd) select pccode,shift,empno,'D99','',sum(creditd)
	from #deptdai where paycode < 'D99'
	group by pccode,shift,empno

insert #deptdai (pccode,shift,empno,paycode,paytail,creditd) select pccode,shift,empno,'C99','',sum(creditd)
	from #deptdai where paycode <'C99'
	group by pccode,shift,empno
if exists (select 1 from #deptdai where paycode like 'B%')
	begin
	insert #deptdai (pccode,shift,empno,paycode,paytail,creditd) select pccode,shift,empno,'B','',sum(creditd)
		from #deptdai where paycode like 'B%'
		group by pccode,shift,empno
	insert #deptdai (pccode,shift,empno,paycode,paytail,creditd) select pccode,shift,empno,'C','',sum(creditd)
		from #deptdai where paycode > 'C' and paycode < 'C99'
		group by pccode,shift,empno
	end
insert #deptdai (pccode,shift,empno,paycode,paytail,creditd) select pccode,shift,empno,'E','',sum(creditd)
	from #deptdai where paycode like 'E%'
	group by pccode,shift,empno

--- jjh cyj 2003.11.07---
insert #deptdai (pccode,shift,empno,paycode,paytail,creditd) select pccode,shift,empno,'G','',sum(creditd)
	from #deptdai where paycode like 'G%'
	group by pccode,shift,empno
--- jjh cyj 2003.11.07---


insert #deptdai (pccode,shift,empno,paycode,paytail,creditd) select pccode,'9',empno,paycode,paytail,sum(creditd)
	from #deptdai
	group by pccode,empno,paycode,paytail

insert #deptdai (pccode,shift,empno,paycode,paytail,creditd) select pccode,shift,'{{{',paycode,paytail,sum(creditd)
	from #deptdai
	group by pccode,shift,paycode,paytail

update deptjie set deptjie.feed = a.feed,daymark = 'D' from #deptjie a
	where deptjie.pccode = a.pccode and deptjie.shift = a.shift and deptjie.empno = a.empno and deptjie.code = a.code
insert deptjie (date,pccode,shift,empno,code,daymark,feed)
	select @bdate,pccode,shift,empno,code,'D',feed
	from #deptjie a
	where not exists (select 1 from deptjie b where b.pccode = a.pccode and b.shift = a.shift and b.empno = a.empno and b.code = a.code)

update deptdai set deptdai.creditd = a.creditd,daymark = 'D' from #deptdai a
	where deptdai.pccode = a.pccode and deptdai.shift = a.shift and deptdai.empno = a.empno and deptdai.paycode = a.paycode and deptdai.paytail = a.paytail
insert deptdai(date,pccode,shift,empno,paycode,paytail,daymark,creditd)
	select @bdate,pccode,shift,empno,paycode,paytail,'D',creditd
	from #deptdai a
	where not exists (select 1 from deptdai b where b.pccode = a.pccode and b.shift = a.shift and b.empno = a.empno and b.paycode = a.paycode and b.paytail = a.paytail)

update deptjie set descript = a.descript from pos_namedef a, pccode b, pos_pccode c
	where deptjie.pccode = c.pccode and b.pccode = c.chgcod  and a.deptno = b.deptno and a.code = deptjie.code
update deptjie set descript = pccode.descript from deptjie,pccode where deptjie.code = substring(pccode.deptno8,1,3) and deptjie.code > '6' and deptjie.code < '999'

update deptdai set descript = pccode.descript from pccode
	where deptdai.paycode = pccode.pccode and paytail = ' '

update deptdai set descript = pccode.descript from pccode
	where substring(deptdai.paycode, 2, 2) = substring(pccode.deptno1, 2, 2) and paytail = ' '  and deptdai.paycode <> pccode.pccode and pccode.pccode > '900'
update deptdai set descript1 = pccode.deptno2 from pccode
	where substring(deptdai.paycode, 2, 2) = substring(pccode.pccode, 2, 2) and pccode.pccode >'9'


update deptdai set descript = '**合计**' where paycode = 'C99'
update deptdai set descript = '  冲预付' where paycode = 'B'
update deptdai set descript = '  实收款' where paycode = 'C'
update deptdai set descript = '  预收' where paycode = 'E'
--- jjh cyj 2003.11.07---
update deptdai set descript = '  转登记' where paycode = 'FF1'
update deptdai set descript = '  登记收回' where paycode = 'G'
update deptdai set descript = '转走账' where paycode = 'GG1'
update deptdai set descript ='输入账' where paycode = 'GG2'
--- jjh cyj 2003.11.07---

update deptdai set descript = '<赠送>' where paycode = 'D93' and paytail = char(27)
update deptdai set descript = '<全免>' where paycode = 'D93' and paytail = char(28)
update deptdai set descript = '<单菜折扣>' where paycode = 'D93' and paytail = char(29)

update deptdai set descript = '百分比折扣' where paycode = 'D93' and paytail = char(30)
update deptdai set descript = '特优码折扣' where paycode = 'D93' and paytail = char(31)
update deptdai set descript = '折扣' where paycode = 'D93' and paytail =''
update deptdai set descript = '总    计' where paycode = 'D99'

begin tran
if @isfstday = 'T'
   update deptjie set feem = feed ,date = @bdate
else
   update deptjie set feem = feem + feed,date = @bdate
commit tran
declare c_deptjie cursor for select pccode,shift,empno,feed,feem from deptjie where code='999'
open c_deptjie
fetch c_deptjie into @pccode,@shift,@empno,@feed,@feem
while @@sqlstatus = 0
   begin
	select @feedd = 0,@feemm = 0
   select @feedd = feed, @feemm = feem from deptjie where pccode=@pccode and shift = @shift and empno =@empno and code ='99A'
   if @feedd = 0 or @feedd is null
	  update deptjie set feed = 0 where pccode=@pccode and shift = @shift and empno =@empno and code ='99B'
   else
	  update deptjie set feed = round(@feed/@feedd,2) where pccode=@pccode and shift = @shift and empno =@empno and code ='99B'
   if @feemm = 0 or @feemm is null
	  update deptjie set feem = 0 where pccode=@pccode and shift = @shift and empno =@empno and code ='99B'
   else
	  update deptjie set feem = round(@feem/@feemm,2) where pccode=@pccode and shift = @shift and empno =@empno and code ='99B'
   fetch c_deptjie into @pccode,@shift,@empno,@feed,@feem
   end
close c_deptjie
deallocate cursor c_deptjie
begin tran
if @isfstday = 'T'
   update deptdai set creditm = creditd ,date = @bdate
else
   update deptdai set creditm = creditm + creditd,date = @bdate
commit tran

select @subtotal = value from sysoption where catalog = 'audit_report' and item = 'ydeptrep(include subtotal)'
select @ydeptrep = value from sysoption where catalog = 'audit_report' and item = 'ydeptrep'
begin tran
delete ydeptjie where date = @bdate
delete ydeptdai where date = @bdate
if @subtotal <> 'T'
	begin
	if @ydeptrep = '9{{{'
		begin
		insert ydeptjie select * from deptjie where code <> '6' and shift = '9' and empno = '{{{'
		insert ydeptdai select * from deptdai where paycode <> 'C99' and shift = '9' and empno = '{{{'
		end
	else if @ydeptrep = '*{{{'
		begin
		insert ydeptjie select * from deptjie where code <> '6' and empno = '{{{'
		insert ydeptdai select * from deptdai where paycode <> 'C99' and empno = '{{{'
		end
	else
		begin
		insert ydeptjie select * from deptjie where code <> '6'
		insert ydeptdai select * from deptdai where paycode <> 'C99'
		end
	end
else
	begin
	if @ydeptrep= '9{{{'
		begin
		insert ydeptjie select * from deptjie where shift = '9' and empno = '{{{'
		insert ydeptdai select * from deptdai where shift = '9' and empno = '{{{'
		end
	else if @ydeptrep = '*{{{'
		begin
		insert ydeptjie select * from deptjie where empno = '{{{'
		insert ydeptdai select * from deptdai where empno = '{{{'
		end
	else
		begin
		insert ydeptjie select * from deptjie
		insert ydeptdai select * from deptdai
		end
	end
commit tran

return 0

;