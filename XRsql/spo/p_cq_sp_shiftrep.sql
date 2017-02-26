drop procedure p_cq_sp_shiftrep;
create proc p_cq_sp_shiftrep
	@pc_id				char(4),
	@limpcs				varchar(120),
	@date					datetime,
	@empno				char(10),
	@shift				char(1),
	@break				char(1),
	@langid				int	=0
as

declare
	@bdate				datetime,
	@type					char(3),
	@tocode				char(3),
	@pccod            char(3),
	@pccode1          char(3),
	@deptno1          char(3),
	@deptno8          char(3),
	@payname          char(12),
	@descript1			char(12),

	@dsc_sttype 		char(2) ,
	@p_daokous			varchar(100),
	@daokou	  			char(1) ,

	@menu					char(10),
	@pccode				char(3),

	@code					char(3),
	@amount				money,

	@descript			char(12),
	@paycode				char(5),
	@paytail				char(1),
	@i						integer,
	@feed					money,
	@feedd				money,
	@pccodes				varchar(255),
	@modu_ids			varchar(255),
	@codes				varchar(255),
	@paycodes			varchar(255),
	@vpos					integer,
	@tocode1          char(3),
	@amountall        money






if rtrim(@empno) is null
	select @empno = '%'
if rtrim(@shift) is null
	select @shift = '%'
select @bdate = bdate1 from sysdata

select @pccodes = pccodes  from pos_posdef where posno = (select posno from pos_station where netaddress = @pc_id)
select @dsc_sttype = value from sysoption where catalog = 'pos' and item = 'dsc_sttype'
if @@rowcount = 0
	select @dsc_sttype  = 'nn'
select @p_daokous = null

select * into #account from account where 1 = 2
select * into #sp_menu from sp_menu where 1 = 2
select * into #sp_pay from sp_pay where 1 = 2
if @date = @bdate
	begin
	insert #account select * from account where bdate = @date and empno like @empno and shift like @shift
	insert #sp_menu select * from sp_menu
	insert #sp_pay select * from sp_pay where  bdate = @date
	end
else
	begin
	insert #account select * from account where bdate = @date and empno like @empno and shift like @shift
		union select * from haccount where bdate = @date and empno like @empno and shift like @shift
	insert #sp_menu select * from sp_hmenu where bdate = @date
	insert #sp_pay select * from sp_hpay where  bdate = @date
	insert #sp_pay select * from sp_pay where  bdate = @date
	end
delete #account where charindex(modu_id, @modu_ids) = 0 or charindex(pccode, @pccodes) = 0 or charindex(pccode, @limpcs) = 0
delete #sp_menu where not empno3 like @empno or not shift like @shift or charindex(pccode, @pccodes) = 0 or charindex(pccode, @limpcs) = 0
declare c_pccode cursor for select pccode, daokou from pos_pccode
open c_pccode
fetch c_pccode into @pccode, @daokou
while @@sqlstatus = 0
	begin
	select @p_daokous = @p_daokous + @pccode + @daokou+'#'
	fetch c_pccode into @pccode, @daokou
	end
close c_pccode
deallocate cursor c_pccode

delete posjie where pc_id = @pc_id
delete posdai where pc_id = @pc_id





update #sp_menu set guest = sum(guests) from sp_plaav where sp_menu = #sp_menu.menu
declare c_cur3 cursor for select distinct tocode from pos_detail_jie where date = @date and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 and special <>'E'
declare c_cur4 cursor for select distinct pccode from pos_pccode where charindex(pccode, @pccodes) > 0
open c_cur4
fetch c_cur4 into @pccode1
while @@sqlstatus = 0
begin
   open c_cur3
	fetch c_cur3 into @tocode1
	while @@sqlstatus = 0
   begin
	select @amountall = sum(amount0 - amount2) from pos_detail_jie where  date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and pccode = @pccode1 and tocode = @tocode1	and special <>'E' and type not in (select pccode from pccode where pccode>'900' and deptno8<>'' and deptno8 is not null)
	insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, tocode, @amountall - sum(amount1) - sum(amount3)
		from pos_detail_jie where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and pccode =@pccode1 and tocode = @tocode1
		and special <>'E'
		group by pccode, tocode
	fetch c_cur3 into @tocode1
	end
	close c_cur3

	fetch c_cur4 into @pccode1
end
close c_cur4
deallocate cursor c_cur4
deallocate cursor c_cur3



insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '607', sum(amount3)
	from pos_detail_jie where date = @date and type = '8' and special = 'N'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 group by pccode
insert posdai (pc_id, pccode, paycode, paytail, creditd) select @pc_id, pccode, 'D93', char(29), sum(amount3)
	from pos_detail_jie where date = @date and type = '8' and special = 'N'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 group by pccode

insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '605', sum(amount3)
	from pos_detail_jie where date = @date and type = '6' and special = 'N'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 group by pccode
insert posdai (pc_id, pccode, paycode, paytail, creditd) select @pc_id, pccode, 'D93', char(28), sum(amount3)
	from pos_detail_jie where date = @date and type = '6' and special = 'N'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 group by pccode

insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '602', sum(amount3)
	from pos_detail_jie where date = @date and type = '4' and special = 'N'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 group by pccode
insert posdai (pc_id, pccode, paycode, paytail, creditd) select @pc_id, pccode, 'D93', char(27), sum(amount3)
	from pos_detail_jie where date = @date and type = '4' and special = 'N'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 group by pccode

insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '610', sum(amount1+amount2)
	from pos_detail_jie where date = @date and type in ('0','4','6','8') and special <> 'T'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 group by pccode
insert posdai (pc_id, pccode, paycode, paytail, creditd) select @pc_id, pccode, 'D93', char(30), sum(amount1+amount2)
	from pos_detail_jie where date = @date and type in ('0','4','6','8') and special <> 'T'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 group by pccode

insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '620', sum(amount3)
	from pos_detail_jie where date = @date and type = '0' and special = 'T'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 group by pccode
insert posdai (pc_id, pccode, paycode, paytail, creditd) select @pc_id, pccode, 'D93', char(31), sum(amount3)
	from pos_detail_jie where date = @date and type = '0' and special = 'T'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 group by pccode

declare c_cur2 cursor for
   select c.pccode,c.deptno8
		from pccode c
		where c.deptno8 <> '' and c.deptno8 is not null and c.pccode > '900'

open c_cur2
fetch c_cur2 into @pccod,@deptno8
while @@sqlstatus = 0
	begin

	insert posjie (pc_id, pccode, code, feed) select @pc_id, a.pccode, @deptno8, sum(a.amount3)
	from pos_detail_jie a,pccode b where a.date = @date and b.pccode = a.type
	and shift like @shift and empno like @empno and b.pccode = @pccod
	and charindex(a.pccode, @pccodes) > 0 and charindex(a.pccode, @limpcs) > 0 group by a.pccode , b.deptno8
	fetch c_cur2 into @pccod,@deptno8
	end
close c_cur2
deallocate cursor c_cur2








insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '999', sum(feed)
	from posjie where pc_id = @pc_id  group by pccode

insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '6', sum(feed)
	from posjie where pc_id = @pc_id and code < '6' group by pccode

insert posjie (pc_id, pccode, code, feed) select distinct @pc_id, pccode, '99B', 0
	from posjie where pc_id = @pc_id

select @modu_ids = isnull((select value from sysoption where catalog = 'audit' and item = 'modu_id'), '02#03#05#')
insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, 'ZZZ', sum(charge) from #account group by pccode

insert posjie (pc_id, pccode, code, feed) select @pc_id, a.pccode, '99A', sum(guest) from #sp_menu a
	where a.paid = '1' group by a.pccode


if exists (select 1 from #sp_menu where paid = '0')
	insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '900', sum(amount) from #sp_menu
	where paid = '0' group by pccode


declare c_cur7 cursor for
   select c.deptno1,c.descript
		from #sp_menu a, pos_detail_dai b,pccode c
		where a.menu = b.menu and a.paid = '1'
		and b.paycode =  c.pccode and  substring(b.reason3, 1, 2) = '��' and (c.deptno8 = '' or c.deptno8 is null)
		group by a.pccode, c.deptno1
open c_cur7
fetch c_cur7 into @pccod,@payname
while @@sqlstatus = 0
begin
	insert posdai (pc_id, pccode, paycode, paytail, creditd,descript)
		select @pc_id, a.pccode, 'B' + substring(@pccod,2,2), '', sum(b.amount),@payname
		from #sp_menu a, pos_detail_dai b,pccode c
		where a.menu = b.menu and a.paid = '1'
		and b.paycode = c.pccode and b.paycode = @pccod and substring(b.reason3, 1, 2) = '��' and (c.deptno8 = '' or c.deptno8 is null)
		group by a.pccode, c.deptno1
		fetch c_cur7 into @pccod,@payname
end
close c_cur7
deallocate cursor c_cur7


insert posdai (pc_id, pccode, paycode, paytail, creditd)
	select @pc_id, a.pccode,  c.deptno1, '', sum(b.amount)
	from #sp_menu a, pos_detail_dai b,pccode c
	where a.menu = b.menu and a.paid = '1'
	and b.paycode =  c.pccode and substring(b.reason3, 1, 2) <> '��' and (c.deptno8 = '' or c.deptno8 is null)
	group by a.pccode, c.deptno1




declare c_cur1 cursor for
   select c.pccode,c.descript,deptno1
		from pccode c
		where c.deptno8 <> '' and c.deptno8 is not null and c.pccode > '900'

open c_cur1
fetch c_cur1 into @pccod,@payname,@deptno1
while @@sqlstatus = 0
	begin
	insert posdai (pc_id, pccode, paycode, paytail, creditd)
		select @pc_id, a.pccode, 'D' + substring(@deptno1,2,2), '', sum(b.amount)
		from #sp_menu a, pos_detail_dai b,pccode c
		where a.menu = b.menu and a.paid = '1'
		and b.paycode =  c.pccode and b.paycode = @pccod and c.deptno8 <> '' and c.deptno8 is not null
		group by a.pccode, c.deptno1
	fetch c_cur1 into @pccod,@payname,@deptno1
	end
close c_cur1
deallocate cursor c_cur1



insert posdai (pc_id, pccode, paycode, paytail, creditd, descript)
	select @pc_id, a.pccode, 'E' + substring(c.deptno1, 2, 2), '', sum(b.amount),'Ԥ��'
	from pos_reserve a, #sp_pay b, pccode c
	where a.resno = b.menu and b.bdate = @date and b.shift like @shift and b.empno like @empno
	and b.sta = '1' and charindex(b.crradjt, 'C CO') = 0
	and b.paycode = c.pccode
	group by a.pccode, c.deptno1, b.paycode
insert posdai (pc_id, pccode, paycode, paytail, creditd, descript)
	select @pc_id, a.pccode, 'E' + substring(c.deptno1, 2, 2), '', sum(b.amount),'Ԥ��'
	from pos_hreserve a, #sp_pay b, pccode c
	where a.resno = b.menu and b.bdate = @date and b.shift like @shift and b.empno like @empno
	and b.sta = '1' and charindex(b.crradjt, 'C CO') = 0
	and b.paycode = c.pccode
	group by a.pccode, c.deptno1, b.paycode


if exists(select 1 from sysoption where catalog = 'hotel' and item = 'name' and value like '%��������%')
	insert posdai (pc_id, pccode, paycode, paytail, creditd, descript)
		select @pc_id, a.pccode, 'FF1', '', sum(b.amount),'ת�Ǽ���'
		from #sp_menu a, #sp_pay b, pccode c, master d
		where a.menu = b.menu and b.bdate = @date and b.shift like @shift and b.empno like @empno

		and b.accnt = d.accnt and d.accnt like 'AR%' and d.artag1 = 'Z'
		and charindex(b.crradjt, 'C CO') = 0
		and b.paycode = c.pccode
		group by a.pccode, c.deptno1



-----jjh----------------------------
declare	@billno		char(10), @sum_charge money
select * into #araccnt0 from account where 1=2
select * into #araccnt from account where 1=2
insert into #araccnt0 select a.* from account a, master b where a.accnt = b.accnt and a.accnt like 'AR%' and b.artag1 = 'Z' and a.bdate = @date and a.shift like @shift and a.empno like @empno
insert into #araccnt0 select a.* from haccount a, master b where a.accnt = b.accnt and a.accnt like 'AR%' and b.artag1 = 'Z' and a.bdate = @date and a.shift like @shift and a.empno like @empno
insert into #araccnt0 select b.* from #araccnt0 a,account b where a.accnt = b.accnt and a.billno = b.billno and substring(a.billno,2,5) = substring(convert(char(8), @date, 12),2,5) and b.bdate <> @date
insert into #araccnt0 select b.* from #araccnt0 a,haccount b where a.accnt = b.accnt and a.billno = b.billno and substring(a.billno,2,5) = substring(convert(char(8), @date, 12),2,5) and b.bdate <> @date

insert into #araccnt select distinct * from #araccnt0

delete #araccnt where bdate <> @date and billno not like 'B%'


insert posdai (pc_id, pccode, paycode, paytail, creditd, descript)
	select @pc_id, a.pccode, 'G' + substring(c.deptno1,2,2), '', 0, ''
	from #araccnt a, #araccnt b, pccode c
	where a.accnt = b.accnt and a.billno = b.billno and a.billno like 'B%' and a.pccode < '9' and b.pccode > '9'
	and b.pccode = c.pccode
	group by a.pccode, b.pccode

declare	@tmp_pc		char(3), @tmp_charge money

declare  c_billno cursor  for select distinct billno from #araccnt where billno like 'B%' and substring(billno,2,5) = substring(convert(char(8), @date,12),2,5)
declare  c_pc     cursor  for select pccode, charge from #araccnt where pccode < '9' and billno = @billno
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
			update posdai set creditd = creditd + round(@tmp_charge * c.credit / @sum_charge, 2)
			from posdai a, #araccnt c, pccode b where c.billno = @billno and c.pccode > '9'
			and a.pccode = @tmp_pc   and a.paycode = 'G' + substring(b.deptno1, 2, 2)
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


insert posdai (pc_id, pccode, paycode, paytail, creditd, descript)
	select @pc_id, a.pccode, 'GG1' , '', sum(-1 * a.charge), 'ת����'
	from #araccnt a
	where  a.billno  like 'T%' and a.pccode < '9'
	group by a.pccode

insert posdai (pc_id, pccode, paycode, paytail, creditd, descript)
	select @pc_id, a.pccode, 'GG2' , '', sum(a.charge), '������'
	from #araccnt a
	where  rtrim(a.billno) is null and pccode < '9' and a.modu_id ='02'
	group by a.pccode

-----jjh----------------------------




insert posdai (pc_id, pccode, paycode, paytail, descript, creditd)
	select @pc_id, pccode, 'D99', '', '��    ��', sum(creditd)
	from posdai where pc_id = @pc_id and paycode < 'D99' group by pccode


update posdai set descript = '�ϲ�����', paycode = 'C//' where pc_id = @pc_id and paycode = ''
insert posdai (pc_id, pccode, paycode, paytail, descript, creditd)
	select @pc_id, pccode, 'C99', '', '**�ϼ�**', sum(creditd)
	from posdai where pc_id = @pc_id and paycode < 'C99' group by pccode
if exists (select 1 from posdai where paycode like 'B%')
	begin
	insert posdai (pc_id, pccode, paycode, paytail, descript, creditd)
		select @pc_id, pccode, 'B', '', '  ��Ԥ��', sum(creditd)
		from posdai where pc_id = @pc_id and paycode like 'B%' group by pccode
	insert posdai (pc_id, pccode, paycode, paytail, descript, creditd)
		select @pc_id, pccode, 'C', '', '  ʵ�տ�', sum(creditd)
		from posdai where pc_id = @pc_id and paycode > 'C' and paycode < 'C99' group by pccode
	end
insert posdai (pc_id, pccode, paycode, paytail, descript, creditd)
	select @pc_id, pccode, 'E', '', '  Ԥ�պϼ�', sum(creditd)
	from posdai where pc_id = @pc_id and paycode like 'E%' group by pccode



---------------------------------
insert posdai (pc_id, pccode, paycode, paytail, descript, creditd)
	select @pc_id, pccode, 'G', '', '  �Ǽ��ջ�', sum(creditd)
	from posdai where pc_id = @pc_id and paycode like 'G%' group by pccode

if @langid = 0
	begin
	update posjie set descript = a.descript from pos_namedef a, pccode b, pos_pccode c
		where posjie.pc_id = @pc_id and posjie.pccode = c.pccode and b.pccode = c.chgcod and a.deptno = b.deptno and a.code = posjie.code
	update posjie set descript = pccode.descript from pccode where posjie.pc_id = @pc_id
		and posjie.code = substring(pccode.deptno1, 1, 3) and posjie.code > '6'
	end
else
	begin
	update posjie set descript = a.descript1 from pos_namedef a, pccode b, pos_pccode c
		where posjie.pc_id = @pc_id and posjie.pccode = c.pccode and b.pccode = c.chgcod and a.deptno = b.deptno and a.code = posjie.code
	update posjie set descript = pccode.descript1 from pccode where posjie.pc_id = @pc_id
		and posjie.code = substring(pccode.deptno1, 1, 3) and posjie.code > '6'
	end

---------------------------------






if @langid = 0
	begin
	update posdai set descript = pccode.descript from pccode
		where posdai.pc_id = @pc_id and substring(posdai.paycode, 2, 2) = substring(pccode.deptno8, 1, 2) and paytail = ' ' and paycode not like 'G%' and paycode not like 'E%' and paycode not like 'B%' and paycode not like 'C%' and paycode >'999'
	update posdai set descript = pccode.descript from pccode
		where posdai.pc_id = @pc_id and posdai.paycode = pccode.pccode and paytail = ' ' and pccode.pccode >'900'
	update posdai set descript = pccode.descript from pccode
		where posdai.pc_id = @pc_id and substring(posdai.paycode, 2, 2) = substring(pccode.deptno1, 2, 2) and paytail = ' ' and pccode.pccode >'900'
	update posdai set descript1 = pccode.descript from pccode
		where posdai.pc_id = @pc_id and substring(posdai.paycode, 2, 2) = substring(pccode.deptno8, 1, 2)  and paycode not like 'E%' and paycode not like 'F%'
	update posdai set descript = '�ٷֱ��ۿ�' where pc_id = @pc_id and paycode = 'D93' and paytail = char(30)
	update posdai set descript = '�������ۿ�' where pc_id = @pc_id and paycode = 'D93' and paytail = char(31)

	update posdai set descript = '<����>' where pc_id = @pc_id and paycode = 'D93' and paytail = char(27)
	update posdai set descript = '<ȫ��>' where pc_id = @pc_id and paycode = 'D93' and paytail = char(28)
	update posdai set descript = '<�����ۿ�>' where pc_id = @pc_id and paycode = 'D93' and paytail = char(29)
	update posdai set descript = '<���>' where pc_id = @pc_id and paycode = 'D94'
	update posdai set descript = '<�ۿ�>' where pc_id = @pc_id and paycode = 'D93' and paytail =''
	end
else
	begin
	update posdai set descript = pccode.descript1 from pccode
		where posdai.pc_id = @pc_id and substring(posdai.paycode, 2, 2) = substring(pccode.deptno8, 1, 2) and paytail = ' ' and paycode not like 'G%' and paycode not like 'E%' and paycode not like 'B%' and paycode not like 'C%' and paycode >'999'
	update posdai set descript = pccode.descript1 from pccode
		where posdai.pc_id = @pc_id and posdai.paycode = pccode.pccode and paytail = ' ' and pccode.pccode >'900'
	update posdai set descript = pccode.descript1 from pccode
		where posdai.pc_id = @pc_id and substring(posdai.paycode, 2, 2) = substring(pccode.deptno1, 2, 2) and paytail = ' ' and pccode.pccode >'900'
	update posdai set descript1 = pccode.descript1 from pccode
		where posdai.pc_id = @pc_id and substring(posdai.paycode, 2, 2) = substring(pccode.deptno8, 1, 2)  and paycode not like 'E%' and paycode not like 'F%'
	update posdai set descript = 'Per DSC' where pc_id = @pc_id and paycode = 'D93' and paytail = char(30)
	update posdai set descript = 'Spec. DSC' where pc_id = @pc_id and paycode = 'D93' and paytail = char(31)

	update posdai set descript = 'Reward' where pc_id = @pc_id and paycode = 'D93' and paytail = char(27)
	update posdai set descript = 'Free' where pc_id = @pc_id and paycode = 'D93' and paytail = char(28)
	update posdai set descript = 'Dish DSC' where pc_id = @pc_id and paycode = 'D93' and paytail = char(29)
	update posdai set descript = 'ENT' where pc_id = @pc_id and paycode = 'D94'
	update posdai set descript = 'DSC' where pc_id = @pc_id and paycode = 'D93' and paytail =''
	update posdai set descript = '*Sub total*' where pc_id = @pc_id and paycode = 'C99'
	update posdai set descript = 'Total' where pc_id = @pc_id and paycode = 'D99'
	update posdai set descript = '  Eearnest Used' where pc_id = @pc_id and paycode = 'B'
	update posdai set descript = '  Gathering' where pc_id = @pc_id and paycode = 'C'
	update posdai set descript = '  Eearnest' where pc_id = @pc_id and paycode = 'E'

	end






declare c_posjie cursor for select pccode, feed from posjie where code = '999' and pc_id = @pc_id
open c_posjie
fetch c_posjie into @pccode, @feed
while @@sqlstatus = 0
	begin
	select @feedd = isnull((select feed from posjie where pc_id = @pc_id and pccode = @pccode and code = '99A'), 0)
	if @feedd = 0
		update posjie set feed = 0 where pc_id = @pc_id and pccode = @pccode and code = '99B'
	else
		update posjie set feed = round(@feed/@feedd, 2) where pc_id = @pc_id and pccode = @pccode and code  = '99B'
	fetch c_posjie into @pccode, @feed
	end
close c_posjie
deallocate cursor c_posjie


if charindex(@break, '1') > 0
	return 0
delete pos_shift_detail  where pc_id = @pc_id
declare c_detail_dai cursor for select b.pccode, a.menu, a.paycode, a.amount
	from pos_detail_dai a, #sp_menu b where a.menu = b.menu and b.paid = '1'
	order by a.menu, a.paycode
declare c_detail_jie cursor for
	select pccode, menu, '0', amount0, tocode, '���' from pos_detail_jie
		where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0
		and type = '0' and special <> 'T'
	union all select pccode, menu, '1', amount1+amount2, tocode, '�ٷֱ��ۿ�' from pos_detail_jie
		where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0
		and type = '0' and special <> 'T'


	union all select pccode, menu, '2', amount3, tocode, '�������ۿ�' from pos_detail_jie
		where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0	and special = 'T'
		and charindex(type,'486') = 0
	union all select pccode, menu, '4', amount3, tocode, '����' from pos_detail_jie
		where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0	and special = 'N'
		and type = '4'
	union all select pccode, menu, '6', amount3, tocode, 'ȫ��' from pos_detail_jie
		where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0	and special = 'N'
		and type = '6'
	union all select pccode, menu, '8', amount3, tocode, '�����ۿ�' from pos_detail_jie
		where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0	and special = 'N'
		and type = '8'
	union all select pccode, menu, '0', amount0, tocode, '���' from pos_detail_jie
		where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0
		and (type = '8' or type = '6' or type = '4') and special = 'N'
	union all select pccode, menu, '1', amount1+amount2, tocode, '�ٷֱ��ۿ�' from pos_detail_jie
		where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0
		and (type = '8' or type = '6' or type = '4') and special = 'N'

	union all select a.pccode, a.menu, a.type, a.amount3, a.tocode, rtrim(b.descript1)+rtrim(b.descript2)
		from pos_detail_jie a, pccode b
		where b.deptno1 = a.type and a.date = @date and a.shift like @shift and a.empno like @empno
		and charindex(a.pccode, @pccodes) > 0 and charindex(a.pccode, @limpcs) > 0







declare c_namedef cursor for select distinct code, descript
	from posjie where pc_id = @pc_id and code < '6' order by code
open c_namedef
fetch c_namedef into @code, @descript
while @@sqlstatus = 0
	begin
	select @codes = @codes + @code +'#'
	fetch c_namedef into @code, @descript
	end
close c_namedef
deallocate cursor c_namedef

open c_detail_jie
fetch c_detail_jie into @pccode, @menu, @type, @amount, @tocode, @descript1
while @@sqlstatus  = 0
	begin
	if @amount = 0 and @type <> '0'
		begin
		fetch c_detail_jie into @pccode, @menu, @type, @amount, @tocode, @descript1
		continue
		end
	if not exists (select 1 from pos_shift_detail where pc_id = @pc_id and pccode = @pccode and menu = @menu and type = '{{{')
		begin
		insert pos_shift_detail (pc_id, pccode, menu, descript1, type) values (@pc_id, @pccode, @menu, '�ϼ�', '{{{')
		if not exists ( select 1 from pos_shift_detail where pc_id = @pc_id and pccode = @pccode and menu = 'С��' and type = '{{{')
			begin
			insert pos_shift_detail (pc_id, pccode, menu, descript1, type) values (@pc_id, @pccode, 'С��', '�ϼ�', '{{{')
			if not exists ( select 1 from pos_shift_detail where pc_id = @pc_id and menu = '�ܼ�' and type = '{{{')
				insert pos_shift_detail (pc_id, pccode, menu, descript1, type) values (@pc_id, '{{', '�ܼ�', '�ϼ�', '{{{')
			end
		end
	if not exists (select 1 from pos_shift_detail where pc_id = @pc_id and pccode = @pccode and menu = @menu and type = @type)
		begin
		insert pos_shift_detail (pc_id, pccode, menu, descript1, type) values (@pc_id, @pccode, @menu, @descript1, @type)
		if not exists ( select 1 from pos_shift_detail where pc_id = @pc_id and pccode = @pccode and menu = 'С��' and type = @type)
			begin
			insert pos_shift_detail (pc_id, pccode, menu, descript1, type) values (@pc_id, @pccode, 'С��', @descript1, @type)
			if not exists ( select 1 from pos_shift_detail where pc_id = @pc_id and menu = '�ܼ�' and type = @type)
				insert pos_shift_detail (pc_id, pccode, menu, descript1, type) values (@pc_id, '{{', '�ܼ�', @descript1, @type)
			end
		end
	select @i = 0 ,  @vpos = convert(int, (charindex(@tocode, @codes) + 3) / 4)
	while @i < 2
		begin
		if @i = 1
			begin
			if @type <> '0'
				select @amount = - @amount
			select @type = '{{{'
			end


		 if @vpos = 1
			 update pos_shift_detail set jie1 = jie1 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 2
			 update pos_shift_detail set jie2 = jie2 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 3
			 update pos_shift_detail set jie3 = jie3 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 4
			 update pos_shift_detail set jie4 = jie4 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 5
			 update pos_shift_detail set jie5 = jie5 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 6
			 update pos_shift_detail set jie6 = jie6 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 7
			 update pos_shift_detail set jie7 = jie7 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 8
			 update pos_shift_detail set jie8 = jie8 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 9
			 update pos_shift_detail set jie9 = jie9 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 10
			 update pos_shift_detail set jie10 = jie10 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 11
			 update pos_shift_detail set jie11 = jie11 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 12
			 update pos_shift_detail set jie12 = jie12 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 13
			 update pos_shift_detail set jie13 = jie13 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 14
			 update pos_shift_detail set jie14 = jie14 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 15
			 update pos_shift_detail set jie15 = jie15 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 16
			 update pos_shift_detail set jie16 = jie16 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 17
			 update pos_shift_detail set jie17 = jie17 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 18
			 update pos_shift_detail set jie18 = jie18 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 19
			 update pos_shift_detail set jie19 = jie19 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 20
			 update pos_shift_detail set jie20 = jie20 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 21
			 update pos_shift_detail set jie21 = jie21 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 22
			 update pos_shift_detail set jie22 = jie22 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 23
			 update pos_shift_detail set jie23 = jie23 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 24
			 update pos_shift_detail set jie24 = jie24 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 25
			 update pos_shift_detail set jie25 = jie25 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 26
			 update pos_shift_detail set jie26 = jie26 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 27
			 update pos_shift_detail set jie27 = jie27 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 28
			 update pos_shift_detail set jie28 = jie28 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else if @vpos = 29
			 update pos_shift_detail set jie29 = jie29 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 else
			 update pos_shift_detail set jie30 = jie30 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		 update pos_shift_detail set jiettl = jiettl + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = 'С��')) or menu = '�ܼ�') and type = @type
		select @i = @i + 1
		end
	fetch c_detail_jie into @pccode, @menu, @type, @amount, @tocode, @descript1
	end
close c_detail_jie
deallocate cursor c_detail_jie





declare c_paymth cursor for select distinct paycode, paytail
	from posdai where pc_id = @pc_id and substring(paycode, 2, 2) <> '99' order by paycode, paytail
open c_paymth
fetch c_paymth into @paycode, @paytail
while @@sqlstatus = 0
	begin
	select @paycodes = @paycodes + substring(@paycode, 2, 2) + @paytail +'#'
	fetch c_paymth into @paycode, @paytail
	end
close c_paymth
deallocate cursor c_paymth

open c_detail_dai
fetch c_detail_dai into @pccode, @menu, @code, @amount
while @@sqlstatus = 0
	begin
	select @vpos = convert(int, (charindex(substring(@code, 2, 2)+' ', @paycodes)+3)/4)
	if exists (select 1 from pos_shift_detail where pccode = @pccode and menu = @menu and type = @code)
		select @type = @code
	else
		select @type = '{{{'

	exec p_gl_pos_shiftdai @vpos, @amount, @pc_id, @pccode, @menu, @type

	fetch c_detail_dai into @pccode, @menu, @code, @amount
	end
close c_detail_dai
deallocate cursor c_detail_dai

declare c_shift_detail cursor for
	select pccode, menu, type, jiettl from pos_shift_detail
		where pc_id = @pc_id and datalength(rtrim(menu)) = 10 and type in ('1', '2','4','6','8')
open c_shift_detail
fetch c_shift_detail into @pccode, @menu, @type, @amount
while @@sqlstatus = 0
	begin
	if @type = '1'
		select @vpos = convert(int, (charindex('93'+char(30), @paycodes)+3)/4)
	else if @type = '2'
		select @vpos = convert(int, (charindex('93'+char(31), @paycodes)+3)/4)
	else if @type = '4'
		select @vpos = convert(int, (charindex('93'+char(27), @paycodes)+3)/4)
	else if @type = '6'
		select @vpos = convert(int, (charindex('93'+char(28), @paycodes)+3)/4)
	else if @type = '8'
		select @vpos = convert(int, (charindex('93'+char(29), @paycodes)+3)/4)
	exec p_gl_pos_shiftdai @vpos, @amount, @pc_id, @pccode, @menu, @type
	fetch c_shift_detail into @pccode, @menu, @type, @amount
	end
close c_shift_detail
deallocate cursor c_shift_detail

update pos_shift_detail set guest = isnull((select b.guest from #sp_menu b where b.menu = pos_shift_detail.menu), 0)
	where pc_id = @pc_id

delete pos_shift_detail where type = '0' and (select count(1) from pos_shift_detail a where a.menu = pos_shift_detail.menu and pc_id = @pc_id) = 2
update pos_shift_detail set guest = (select sum(guest) from pos_shift_detail b where b.pc_id = @pc_id and b.pccode = pos_shift_detail.pccode and b.type = '{{{')
	where pc_id = @pc_id and menu = 'С��'

update pos_shift_detail set guest = (select sum(guest) from pos_shift_detail b where b.pc_id = @pc_id and b.menu = 'С��' and b.type = '{{{')
	where pc_id = @pc_id and menu = '�ܼ�'
update pos_shift_detail set descript = b.descript from pccode b where  pos_shift_detail.pccode = b.pccode

return 0;