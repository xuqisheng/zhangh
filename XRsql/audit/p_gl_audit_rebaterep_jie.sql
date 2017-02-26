if exists (select * from sysobjects where name ='p_gl_audit_rebaterep_jie' and type ='P')
	drop proc p_gl_audit_rebaterep_jie;
create proc p_gl_audit_rebaterep_jie
	@ojierep			char(8), 
	@tail				char(2), 
	@roomno			char(5), 
	@paycode			char(5), 
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
	begin
	if substring(@tag, 1, 1) in ('G', 'M')
		select @njierep = '010020'
	else if substring(@tag, 1, 1) = 'F' and substring(@tag, 2, 1) = '1'
		select @njierep = '010030'
	else if substring(@tag, 1, 1) = 'F'
		select @njierep = '010010'
	else 
		select @njierep = '010040'
	end 
else
	select @njierep = @ojierep
//
select @pccodes = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes'), '000,001,002')
if not exists (select 1 from rebaterep where paycode = @paycode and class = @njierep)
	insert rebaterep (date, paycode, class) select bdate, @paycode, @njierep from sysdata
if charindex(@pccode, @pccodes) > 0
	begin
	update rebaterep set day01 = day01 + @charge1 - @charge2 + @charge5 where paycode = @paycode and class = @njierep
	update rebaterep set day06 = day06 + @charge3 where paycode = @paycode and class = @njierep
	update rebaterep set day05 = day05 + @charge4 where paycode = @paycode and class = @njierep
	end
else
	begin
	if @tail = '01'
		update rebaterep set day01 = day01 + @charge where paycode = @paycode and class = @njierep
	else if @tail = '02'
		update rebaterep set day02 = day02 + @charge where paycode = @paycode and class = @njierep
	else if @tail = '03'
		update rebaterep set day03 = day03 + @charge where paycode = @paycode and class = @njierep
	else if @tail = '04'
		update rebaterep set day04 = day04 + @charge where paycode = @paycode and class = @njierep
	else if @tail = '05'
		update rebaterep set day05 = day05 + @charge where paycode = @paycode and class = @njierep
	else if @tail = '06'
		update rebaterep set day06 = day06 + @charge where paycode = @paycode and class = @njierep
	else if @tail = '07'
		update rebaterep set day07 = day07 + @charge where paycode = @paycode and class = @njierep
	else 
		update rebaterep set day01 = day01 + @charge where paycode = @paycode and class = @njierep
	end
return 0
;
