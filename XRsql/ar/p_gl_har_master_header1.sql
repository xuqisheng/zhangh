/* 帐务客人主单(同行客人) */

if exists(select * from sysobjects where name = "p_gl_har_master_header1")
	drop proc p_gl_har_master_header1;

create proc p_gl_har_master_header1
	@pc_id				char(4),
	@mdi_id				integer,
	@roomno				char(5),
	@accnt				char(10),
	@subaccnt			integer
as

declare
	@accnts				integer,
	@names				varchar(250), 
	@name					varchar(50), 
	@name1				varchar(50), 
	@name2				varchar(50), 
	@name3				varchar(50), 
	@sno					char(15),
	@sno1					char(15),
	@sno2					char(15),
	@sno3					char(15),
	@cycle				char(20), 
	@cycle1				char(20), 
	@cycle2				char(20), 
	@cycle3				char(20), 
	@permanent			char(1), 
	@permanent1			char(1), 
	@permanent2			char(1), 
	@permanent3			char(1), 
	@his					char(1), 
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
	@srqs					char(30), 
	@srqs1				char(30), 
	@srqs2				char(30), 
	@srqs3				char(30), 
	@arr					datetime, 
	@carr					datetime, 
	@arr_tag				char(1), 
	@dep					datetime, 
	@cdep					datetime, 
	@dep_tag				char(1), 
	@gstno		   	integer,
	@cgstno		   	integer,
	@children			integer,
	@cchildren			integer,
	@balance				money,
	@cbalance			money,
	@accredit			money,
	@caccredit			money,
	@disputed			money,
	@cdisputed			money,
	@haccnt				char(10), 
	@message				varchar(250), 
	@count				integer, 
	@rmcodedes			varchar(30)


select @ref = '', @count = 1, @names = '', @gstno = 0, @children = 0, @balance = 0, @accredit = 0, @arr_tag = '', @dep_tag = '',
	@name1 = '', @permanent1 = 'F', @his1 = 'F', @name2 = '', @permanent2 = 'F', @his2 = 'F', @name3 = '', @permanent3 = 'F', @his3 = 'F'
//
declare c_guest cursor for
	select a.accnt, c.sno, b.arr, b.dep, b.srqs, b.charge - b.credit, b.accredit, b.disputed, b.cycle, substring(b.extra, 1, 1), substring(b.extra, 1, 1), c.name
	from accnt_set a, har_master b, guest c
	where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and a.accnt = b.accnt and b.haccnt = c.no order by accnt
open c_guest
fetch c_guest into @accnt, @sno, @carr, @cdep, @srqs, @cbalance, @caccredit, @cdisputed, @cycle, @permanent, @his, @name
while @@sqlstatus = 0
	begin
	if @count = 1
		select @name1 = @name, @sno1 = @sno, @permanent1 = @permanent, @srqs1 = @srqs, @cycle1 = @cycle
	else if @count = 2
		select @name2 = @name, @sno2 = @sno, @permanent2 = @permanent, @srqs2 = @srqs, @cycle2 = @cycle
	else
		select @name3 = @name, @sno3 = @sno, @permanent3 = @permanent, @srqs3 = @srqs, @cycle3 = @cycle
	//
	if @arr is null
		select @arr = @carr
	else if convert(char(10), @arr, 101) != convert(char(10), @carr, 101)
		select @arr_tag = 'T'
	if @dep is null
		select @dep = @cdep
	else if convert(char(10), @dep, 101) != convert(char(10), @cdep, 101)
		select @dep_tag = 'T'
	//
	select @names = @names + '/' + @name, @balance = @balance + @cbalance, @accredit = @accredit + @caccredit, @disputed = @disputed + @cdisputed, @count = @count + 1
	fetch c_guest into @accnt, @sno, @carr, @cdep, @srqs, @cbalance, @caccredit, @cdisputed, @cycle, @permanent, @his, @name
	end 
close c_guest
deallocate cursor c_guest
select @names = substring(@names, 1, 250), @ref = substring(@ref, 1, 250)
//if @ref != ''
//	select @ref = '自动转帐到' + rtrim(substring(@ref, 2, 250)) + ';'
////
//declare c_message cursor for select convert(varchar(250), content) from message 
//	where type = '61' and accnt = @accnt order by msgno desc
//open c_message
//fetch c_message into @message
//while @@sqlstatus = 0
//	begin
//	select @ref = @ref + @message
//	fetch c_message into @message
//	end
//close c_message
//deallocate cursor c_message
////
//select @name1 = name from master a, guest b where a.accnt = @groupno and a.haccnt *= b.no
//select @name2 = name from cusinf where no = @cusno
//select @name3 = name from cusinf where no = @agent
////select @cnt = (select count(1) from message a, master b where a.accnt = @accnt and a.type = '0' and a.accnt = b.accnt and a.tranmark = 'F')
////
//select @ref = substring(@ref, 1, 100)
select @accnts = count(distinct accnt) from accnt_set where pc_id = @pc_id and mdi_id = @mdi_id and accnt <> '' and subaccnt = 0
select @accnts, @names, @gstno, @children, @arr, @arr_tag, @dep, @dep_tag, @balance, @accredit, @disputed, @ref, 
	@name1, @sno1, @srqs1, @permanent1, @his1, @cycle1, 
	@name2, @sno2, @srqs2, @permanent2, @his2, @cycle2, 
	@name3, @sno3, @srqs3, @permanent3, @his3, @cycle3
return 0;
