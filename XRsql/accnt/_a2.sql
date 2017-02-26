/* ��̯ */
if exists ( select * from sysobjects where name = 'p_a2' and type ='P')
	drop proc p_a2;
create proc p_a2
	@bdate			datetime
as

declare
	@bfdate			datetime, 
	@duringaudit	char(1), 
	@isfstday		char(1), 
	@isyfstday		char(1), 
	@number			integer, 
	@jierep			char(8), 
	@pccode			char(3), 
	@paycode			char(3), 
	@key0				char(3), 
	@charge			money, 
	@billno			char(10), 
	@accnt			char(10), 
	@menu				char(10), 
	@reason1			char(3), 
	@reason2			char(3), 
	@reason3			char(3), 
	@special			char(1), 
	@amount1			money, 
	@amount2			money, 
	@amount3			money, 
	@sqlmark			integer, 
	@pc_id			char(4), 
	@retmode			char(1), 
	@ret				integer, 
	@msg				varchar(70)

//select @duringaudit = audit from gate
//if @duringaudit = 'T'
//	select @bdate = bdate from sysdata
//else
//	select @bdate = bdate from accthead
exec p_gl_pos_detail '', @bdate
select @bfdate = dateadd(day, -1, @bdate)
//
truncate table discount_detail
if exists ( select 1 from discount where date = @bdate )
	update discount set month = month - day, year = year - day
update discount set day = 0, date = @bfdate
/* ��һ���ִ�ACCOUNT_DETAIL��ȡ������DSC, ENT */
insert discount_detail 
	select date, modu_id, accnt, 0, pccode, sum(charge), paycode, isnull(key0,''), billno
	from account_detail where key0 <> ''
	group by date, modu_id, accnt, pccode, paycode, key0, billno
/* �ڶ����ּ�����̨�Ż�(charge2 != 0) */
declare gltemp_cursor cursor for
	select a.accnt, a.number, a.pccode, a.charge2, isnull(b.type, '')
	from gltemp a, reason b
	where a.pccode < '9' and a.charge2 != 0 and a.reason *= b.code
open gltemp_cursor
fetch gltemp_cursor into @accnt, @number, @pccode, @charge, @key0
while @@sqlstatus = 0
	begin
	insert discount_detail values (@bdate, '02', @accnt, @number,@pccode, @charge, 'ZZZ', @key0, '')
	fetch gltemp_cursor into @accnt, @number, @pccode, @charge, @key0
	end
close gltemp_cursor
deallocate cursor gltemp_cursor
/* �������ּ�����������Ż�(pos_detail_jie) */
declare pos_cursor cursor for
	select menu, pccode, amount1, amount2, amount3, reason1, reason2, reason3
	from pos_detail_jie
	where date = @bdate and type = '0'
open pos_cursor
fetch pos_cursor into @menu, @pccode, @amount1, @amount2, @amount3, @reason1, @reason2, @reason3
while @@sqlstatus = 0
	begin
	// ģʽ�Ż�
	if @amount1 != 0
		begin
		if not exists(select 1 from reason where code = @reason1)
			select @key0 = ''
		else
			select @key0 = type from reason where code = @reason1
		if not exists (select 1 from discount_detail where modu_id = '04' and accnt = @menu 
			and paycode = 'ZZZ' and key0 = @key0)
			insert discount_detail values (@bdate, '04', @menu, 0, @pccode, @amount1, 'ZZZ', @key0, '')
		else
			update discount_detail set charge = charge + @amount1 
				where modu_id = '04' and accnt = @menu and paycode = 'ZZZ' and key0 = @key0
		end
	// �˵��Ż�
	if @amount2 != 0
		begin
		if not exists(select 1 from reason where code = @reason2)
			select @key0 = ''
		else
			select @key0 = type from reason where code = @reason2
		if not exists (select 1 from discount_detail where modu_id = '04' and accnt = @menu 
			and paycode = 'ZZZ' and key0 = @key0)
			insert discount_detail values (@bdate, '04', @menu, 0, @pccode, @amount2, 'ZZZ', @key0, '')
		else
			update discount_detail set charge = charge + @amount2 
				where modu_id = '04' and accnt = @menu and paycode = 'ZZZ' and key0 = @key0
		end
	// �������ۿ�
	if @amount3 != 0
		begin
		if not exists(select 1 from reason where code = @reason3)
			select @key0 = ''
		else
			select @key0 = type from reason where code = @reason3
		if not exists (select 1 from discount_detail where modu_id = '04' and accnt = @menu 
			and paycode = 'ZZZ' and key0 = @key0)
			insert discount_detail values (@bdate, '04', @menu, 0, @pccode, @amount3, 'ZZZ', @key0, '')
		else
			update discount_detail set charge = charge + @amount3 
				where modu_id = '04' and accnt = @menu and paycode = 'ZZZ' and key0 = @key0
		end
	fetch pos_cursor into @menu, @pccode, @amount1, @amount2, @amount3, @reason1, @reason2, @reason3
	end
close pos_cursor
deallocate cursor pos_cursor
/* ���Ĳ�������discount */
declare detail_cursor cursor for
	select key0, paycode, pccode, charge from discount_detail
open detail_cursor
fetch detail_cursor into @key0, @paycode, @pccode, @charge
while @@sqlstatus = 0
	begin
	if not exists ( select 1 from discount where key0 = @key0 and paycode = @paycode and pccode = @pccode)
		insert discount select @bfdate, @key0, @paycode, @pccode, @charge, 0, 0
	else
		update discount set day = day + @charge
			where key0 = @key0 and paycode = @paycode and pccode = @pccode
	fetch detail_cursor into @key0, @paycode, @pccode, @charge
	end
//
exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @isfstday = 'T'
	update discount set month = 0
if @isyfstday = 'T'
	update discount set month = 0, year = 0
update discount set month = month + day, year = year + day, date = @bdate
//
delete ydiscount where date = @bdate
insert ydiscount select * from discount
if @retmode ='S'
	select @ret, @msg 
return @ret
;
