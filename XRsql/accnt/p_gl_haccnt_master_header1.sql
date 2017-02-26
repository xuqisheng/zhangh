/* 帐务客人主单(同行客人) */

if exists(select * from sysobjects where name = "p_gl_haccnt_master_header1")
	drop proc p_gl_haccnt_master_header1;

create proc p_gl_haccnt_master_header1
	@pc_id				char(4),
	@mdi_id				integer,
	@roomno				char(5),
	@accnt				char(10),
	@subaccnt			integer
as

declare
	@roomnos				integer,
	@names				varchar(250), 
	@name					varchar(50), 
	@name1				varchar(50), 
	@name2				varchar(50), 
	@name3				varchar(50), 
	@roomno1				char(5),
	@roomno2				char(5),
	@roomno3				char(5),
	@packages			varchar(50), 
	@packages1			varchar(50), 
	@packages2			varchar(50), 
	@packages3			varchar(50), 
	@vip					char(3), 
	@vip1					char(3), 
	@vip2					char(3), 
	@vip3					char(3), 
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
	@setrate				money, 
	@setrate1			money, 
	@setrate2			money, 
	@setrate3			money, 
	@arr					datetime, 
	@carr					datetime, 
	@arr_tag				char(1), 
	@dep					datetime, 
	@cdep					datetime, 
	@dep_tag				char(1), 
	@srqs					varchar(30), 
	@csrqs				varchar(30), 
	@gstno		   	integer,
	@cgstno		   	integer,
	@children			integer,
	@cchildren			integer,
	@balance				money,
	@cbalance			money,
	@limit				money,
	@climit				money,
	@haccnt				char(10), 
	@message				varchar(250), 
	@count				integer, 
	@rmcodedes			varchar(30)


select @ref = '', @count = 1, @names = '', @srqs = '', @gstno = 0, @children = 0, @balance = 0, @limit = 0, @arr_tag = '', @dep_tag = '',
	@name1 = '', @vip1 = 'F', @his1 = 'F', @name2 = '', @vip2 = 'F', @his2 = 'F', @name3 = '', @vip3 = 'F', @his3 = 'F'
//
declare c_guest cursor for
	select a.accnt, a.roomno, b.arr, b.dep, b.srqs, b.setrate, b.charge - b.credit, b.limit, b.packages, b.gstno, b.children, c.vip, substring(b.extra, 1, 1), c.name
	from accnt_set a, hmaster b, guest c
	where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and a.accnt = b.accnt and b.haccnt = c.no order by accnt
open c_guest
fetch c_guest into @accnt, @roomno, @carr, @cdep, @csrqs, @setrate, @cbalance, @climit, @packages, @cgstno, @cchildren, @vip, @his, @name
while @@sqlstatus = 0
	begin
	if @count = 1
		select @name1 = @name, @roomno1 = @roomno, @vip1 = @vip, @setrate1 = @setrate, @packages1 = @packages
	else if @count = 2
		select @name2 = @name, @roomno2 = @roomno, @vip2 = @vip, @setrate2 = @setrate, @packages2 = @packages
	else
		select @name3 = @name, @roomno3 = @roomno, @vip3 = @vip, @setrate3 = @setrate, @packages3 = @packages
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
	if @csrqs <> ''
		select @srqs = @srqs + @csrqs + ','
	select @names = @names + '/' + @name, @balance = @balance + @cbalance, @limit = @limit + @climit, 
		@gstno = @gstno + @cgstno, @children = @children + @cchildren, @count = @count + 1
	fetch c_guest into @accnt, @roomno, @carr, @cdep, @csrqs, @setrate, @cbalance, @climit, @packages, @cgstno, @cchildren, @vip, @his, @name
	end 
close c_guest
deallocate cursor c_guest
select @names = substring(@names, 1, 250), @names = substring(@names, 1, 250)
select @roomnos = count(distinct roomno) from accnt_set where pc_id = @pc_id and mdi_id = @mdi_id and roomno <> '' and subaccnt = 0
select @roomnos, @names, @gstno, @children, @arr, @arr_tag, @dep, @dep_tag, @balance, @limit, @srqs, @ref, 
	@name1, @roomno1, @setrate1, @vip1, @his1, @packages1, 
	@name2, @roomno2, @setrate2, @vip2, @his2, @packages2, 
	@name3, @roomno3, @setrate3, @vip3, @his3, @packages3
return 0;
