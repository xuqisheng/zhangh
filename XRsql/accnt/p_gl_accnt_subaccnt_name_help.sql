if exists(select * from sysobjects where name = "p_gl_accnt_subaccnt_name_help")
	drop proc p_gl_accnt_subaccnt_name_help;

create proc p_gl_accnt_subaccnt_name_help
	@roomno				char(5),						-- 房号
	@accnt				char(10)						-- 账号
as
declare
	@lic_buy_1			varchar(255),
	@lic_buy_2			varchar(255),
	@groupno				char(10),
	@cusno				char(7),
	@agent				char(7),
	@source				char(7),
	@name					char(50)

create table #name
(
	name			char(50)		not null,
	ar				char(10)		null				-- ar or roomno
)

select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
-- 新应收账
if substring(@accnt, 1, 1) = 'A' and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
	insert #name select b.name, '' from ar_master a, guest b where a.accnt = @accnt and a.haccnt = b.no
else
	begin
	-- Key 
	select @groupno = groupno, @cusno = cusno, @agent = agent, @source = source from master where accnt = @accnt
	
	-- self or group master
	if @accnt like 'F%'
		insert #name select b.name, a.roomno from master a, guest b where a.accnt = @accnt and a.haccnt = b.no
	else
		insert #name select b.name, '' from master a, guest b where a.accnt = @accnt and a.haccnt = b.no
	
	-- group master
	insert #name select b.name, '' from master a, guest b where a.accnt = @groupno and a.haccnt = b.no
	
	-- company
	insert #name select name, isnull(araccnt1, '') from guest where no = @cusno or no = @agent or no = @source
	end

-- Output
select name, ar from #name

return
;

