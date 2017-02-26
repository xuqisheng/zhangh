/* 帐务客人主单(指定账户) */

if exists(select * from sysobjects where name = "p_gl_ar_master_header4")
	drop proc p_gl_ar_master_header4;

create proc p_gl_ar_master_header4
	@pc_id				char(4),
	@mdi_id				integer,
	@roomno				char(5),
	@accnt				char(10),
	@subaccnt			integer
as

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
	@mobile				varchar(20), 
	@phone				varchar(20), 
	@email				varchar(30), 
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
//            
//select @rmrate = rmrate, @qtrate = qtrate, @setrate = setrate, @discount = discount, @discount1 = discount1, 
//	@haccnt = haccnt, @groupno = groupno, @cusno = cusno, @agent = agent
//	from ar_master where accnt = @accnt
//if @rmrate != @setrate
//	begin
//	select @rtdescript = '门市价:' + ltrim(convert(char(10), @rmrate)) + '元;'
//	if @rmrate != @qtrate
//		select @rtdescript = @rtdescript + '协议价:' + ltrim(convert(char(10), @qtrate)) + '元;'
//	if @qtrate != @setrate
//		select @rtdescript = @rtdescript + '优惠:' + ltrim(convert(char(10), @qtrate - @setrate)) + '元'
//	end
////
//declare c_transfer cursor for select distinct to_accnt from subaccnt where accnt = @accnt and type = '5' and pccodes != '-;' order by to_accnt
//open c_transfer
//fetch c_transfer into @to_accnt
//while @@sqlstatus = 0
//	begin
//	if @to_accnt != ''
//		select @ref = @ref + ',' + @to_accnt
//	fetch c_transfer into @to_accnt
//	end 
//close c_transfer
//deallocate cursor c_transfer
//if @ref != ''
//	select @ref = '自动转帐到' + rtrim(substring(@ref, 2, 250)) + ';'
select @name3 = b.name, @mobile = b.mobile, @phone = b.phone, @email = b.email from subaccnt a, guest b
	where a.accnt = @accnt and a.type = '5' and a.subaccnt = @subaccnt and a.haccnt *= b.no
select @balance = sum(charge - credit) from account where accnt = @accnt and subaccnt = @subaccnt
//
select a.accnt, b.name, a.sta, roomno = space(5), c.starting_time, c.closing_time, c.to_roomno, c.to_accnt, c.name, c.pccodes, 
	c.paycode, @name3, b.vip, i_times, mail = @cnt, @mobile, @phone, substring(isnull(@ref, '') + '  ' + isnull(a.ref, ''), 1, 250), a.srqs, a.paycode, setrate = 0, 
	addbed_rate = 0, rtreason = space(3), @email, locksta='', a.pcrec, @rtdescript, isnull(@balance, 0), accredit, ref1 = ''
	from ar_master a, guest b, subaccnt c where a.accnt = @accnt and a.haccnt = b.no and a.accnt = c.accnt and c.subaccnt = @subaccnt and c.type = '5'
return 0;
