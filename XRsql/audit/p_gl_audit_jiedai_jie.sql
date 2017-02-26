if exists (select * from sysobjects where name ='p_gl_audit_jiedai_jie' and type ='P')
	drop proc p_gl_audit_jiedai_jie;
create proc p_gl_audit_jiedai_jie
	@ojierep			char(8), 
	@tail				char(30), 
	@roomno			char(5), 
	@pccode			char(5), 
	@tag				char(3), 
	@charge			money, 
	@charge1			money, 
	@charge2			money, 
	@charge3			money, 
	@charge4			money, 
	@charge5			money
as
declare
	@pccodes			varchar(255), 
	@njierep			char(8)
	
if @ojierep = '010'
	select @njierep = isnull((select jierep from mktcode where code = @tag), '010030')
else
	select @njierep = @ojierep
//
select @pccodes = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes'), '000,001,002')
if charindex(@pccode, @pccodes) > 0 and charindex('07', @tail) = 0
	begin
	update jierep set day01 = day01 + @charge1 - @charge2 + @charge5 where class = @njierep
	update jierep set day06 = day06 + @charge3 where class = @njierep
	update jierep set day05 = day05 + @charge4 where class = @njierep
	end
else
	begin
	if charindex('01', @tail) > 0
		update jierep set day01 = day01 + @charge where class = @njierep
	if charindex('02', @tail) > 0
		update jierep set day02 = day02 + @charge where class = @njierep
	if charindex('03', @tail) > 0
		update jierep set day03 = day03 + @charge where class = @njierep
	if charindex('04', @tail) > 0
		update jierep set day04 = day04 + @charge where class = @njierep
	if charindex('05', @tail) > 0
		update jierep set day05 = day05 + @charge where class = @njierep
	if charindex('06', @tail) > 0
		update jierep set day06 = day06 + @charge where class = @njierep
	if charindex('07', @tail) > 0
		update jierep set day07 = day07 + @charge where class = @njierep
	if charindex('08', @tail) > 0
		update jierep set day08 = day08 - @charge where class = @njierep
	if charindex('09', @tail) > 0
		update jierep set day09 = day09 - @charge where class = @njierep
--	else 
--		update jierep set day01 = day01 + @charge where class = @njierep
	end
return 0
;
