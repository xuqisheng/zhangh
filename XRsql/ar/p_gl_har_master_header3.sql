/* 历史AR账主单 */

if exists(select * from sysobjects where name = "p_gl_har_master_header3")
	drop proc p_gl_har_master_header3;

create proc p_gl_har_master_header3
	@pc_id				char(4),
	@mdi_id				integer,
	@roomno				char(5),
	@accnt				char(10),
	@subaccnt			integer
as

declare
	@name1				varchar(50), 
	@name2				varchar(50), 
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
	@to_accnt			char(10), 
	@rtdescript			char(50), 
	@rmrate				money, 
	@qtrate				money, 
	@setrate				money, 
	@discount			money, 
	@discount1			money, 
	@nation				char(3), 
	@vip					char(1), 
	@haccnt				char(7), 
	@cnt					integer, 
	@rmcode				char(3), 
	@rmcodedes			varchar(30)


select @ref = '', @cnt = 0, @name1 = '', @vip1 = 'F', @his1 = 'F', @name2 = '', @vip2 = 'F', @his2 = 'F', @name3 = '', @vip3 = 'F', @his3 = 'F'
//            
//select @rmrate = rmrate, @qtrate = qtrate, @setrate = setrate, @discount = discount, @discount1 = discount1, 
//	@haccnt = haccnt, @groupno = groupno, @cusno = cusno, @agent = agent
select @haccnt = haccnt from har_master where accnt = @accnt
if @rmrate != @setrate
	begin
	select @rtdescript = '门市价:' + ltrim(convert(char(10), @rmrate)) + '元;'
	if @rmrate != @qtrate
		select @rtdescript = @rtdescript + '协议价:' + ltrim(convert(char(10), @qtrate)) + '元;'
	if @qtrate != @setrate
		select @rtdescript = @rtdescript + '优惠:' + ltrim(convert(char(10), @qtrate - @setrate)) + '元'
	end
//
declare c_transfer cursor for select distinct to_accnt from subaccnt where accnt = @accnt and type = '5' and pccodes != '-;' order by to_accnt
open c_transfer
fetch c_transfer into @to_accnt
while @@sqlstatus = 0
	begin
	if @to_accnt != ''
		select @ref = @ref + ',' + @to_accnt
	fetch c_transfer into @to_accnt
	end 
close c_transfer
deallocate cursor c_transfer
if @ref != ''
	select @ref = '自动转帐到' + rtrim(substring(@ref, 2, 250)) + ';'
//
select @name1 = name from har_master a, guest b where a.accnt = @groupno and a.haccnt *= b.no
select @name2 = name from guest where no = @cusno
select @name3 = name from guest where no = @agent
//
select a.accnt, b.name, a.sta, b.sno, a.arr, a.dep, b.liason, @name1, b.phone, @name2, mobile, @name3, 
	b.vip, i_times, b.email, packages = '', a.applicant, substring(isnull(@ref, '') + '  ' + isnull(a.ref, ''), 1, 250), a.srqs, a.paycode, 
	a.limit, a.disputed, rtreason = '', ratecode = '', locksta='', a.pcrec, @rtdescript, balance = charge - credit, accredit, ref1 = ''
	from har_master a, guest b where a.accnt = @accnt and a.haccnt = b.no
return 0;
