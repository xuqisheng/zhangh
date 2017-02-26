
if exists(select * from sysobjects where name = "p_gl_accnt_master_header4")
	drop proc p_gl_accnt_master_header4;

create proc p_gl_accnt_master_header4
	@pc_id				char(4),
	@mdi_id				integer,
	@roomno				char(5),
	@accnt				char(10),
	@subaccnt			integer
as
-- 帐务客人主单(指定账户) 

declare
	@name1				varchar(50), 
	@pccodes				varchar(250), 
	@name3				varchar(50), 
	@vip1					char(1), 
	@vip2					char(1), 
	@vip3					char(1), 
	@his1					char(1), 
	@his2					char(1), 
	@his3					char(1), 
	@ref					varchar(250), 
	@groupno				char(10), 
	@agent				char(7), 
	@cusno				char(7), 
	@to_roomno			char(5), 
	@to_accnt			char(10), 
	@paycode				char(5),
	@rtdescript			char(50), 
	@rmrate				money, 
	@qtrate				money, 
	@setrate				money, 
	@discount			money, 
	@discount1			money, 
	@balance				money, 
	@nation				char(3), 
	@vip					char(1), 
	@haccnt				char(10), 
	@cnt					integer, 
	@rmcode				char(3), 
	@rmcodedes			varchar(30)


select @ref = '', @cnt = 0, @name1 = '', @vip1 = 'F', @his1 = 'F', @pccodes = '', @vip2 = 'F', @his2 = 'F', @name3 = '', @vip3 = 'F', @his3 = 'F'
--            
select @rmrate = rmrate, @qtrate = qtrate, @setrate = setrate, @discount = discount, @discount1 = discount1, 
	@haccnt = haccnt, @groupno = groupno, @cusno = cusno, @agent = agent
	from master where accnt = @accnt
if @rmrate != @setrate
	begin
	select @rtdescript = '门市价:' + ltrim(convert(char(10), @rmrate)) + '元;'
	if @rmrate != @qtrate
		select @rtdescript = @rtdescript + '协议价:' + ltrim(convert(char(10), @qtrate)) + '元;'
	if @qtrate != @setrate
		select @rtdescript = @rtdescript + '优惠:' + ltrim(convert(char(10), @qtrate - @setrate)) + '元'
	end
--
select @to_accnt = to_accnt from subaccnt where accnt = @accnt and subaccnt = @subaccnt and type = '5' and pccodes != '-;'
if @to_accnt != ''
	select @ref = '自动转帐到' + @to_accnt + ';'
select @balance = sum(charge - credit) from account where accnt = @accnt and subaccnt = @subaccnt
--显示付款方式助记符
--select a.accnt, b.name, a.sta, a.roomno, c.starting_time, c.closing_time, c.to_roomno, c.to_accnt, c.name, c.pccodes, 
--	c.paycode, @name3, b.vip, i_times, mail = @cnt, a.packages, a.applicant, substring(isnull(@ref, '') + isnull(a.comsg, '') + '  ' + isnull(a.ref, ''), 1, 250), a.srqs, d.deptno2, a.setrate, 
--	addbed_rate, a.rtreason, a.ratecode, locksta='', a.pcrec, @rtdescript, isnull(@balance, 0), a.limit, ref1 = ''
--	from master a, guest b, subaccnt c, pccode d
--	where a.accnt = @accnt and a.haccnt = b.no and a.accnt = c.accnt and c.subaccnt = @subaccnt and c.type = '5' and a.paycode *= d.pccode
select a.accnt, b.name, a.sta, a.roomno, c.starting_time, c.closing_time, c.to_roomno, c.to_accnt, c.name, c.pccodes, 
		c.paycode, @name3, b.vip, i_times, mail = @cnt, a.packages, a.applicant, 
--		isnull(a.ref, '') + '  ' + substring(isnull(@ref, '') + isnull(a.comsg, ''), 1, 250), 
		substring(isnull(a.comsg, '')+' '+isnull(@ref, '')+' '+isnull(a.ref, ''), 1, 254),   -- 注意次序
		a.srqs, a.paycode, a.setrate, 
		addbed_rate, a.rtreason, a.ratecode, locksta='', a.pcrec, @rtdescript, isnull(@balance, 0), a.limit, ref1 = ''
	from master a, guest b, subaccnt c 
	where a.accnt = @accnt and a.haccnt = b.no and a.accnt = c.accnt and c.subaccnt = @subaccnt and c.type = '5'
return 0;
