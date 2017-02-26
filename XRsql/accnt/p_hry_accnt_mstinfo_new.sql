/* 新帐务客人主单 */

if exists(select * from sysobjects where name = "p_hry_accnt_mstinfo_new")
	drop proc p_hry_accnt_mstinfo_new;

create proc p_hry_accnt_mstinfo_new
	@accnt		char(10)
as

declare
	@onename		varchar(50), 
	@name1		varchar(50), 
	@name2		varchar(50), 
	@name3		varchar(50), 
	@vip1			char(1), 
	@vip2			char(1), 
	@vip3			char(1), 
	@his1			char(1), 
	@his2			char(1), 
	@his3			char(1), 
	@ref			varchar(254), 
	@to_accnt	char(7), 
	@rtdescript	char(50), 
	@qtrate		money, 
	@discount	money, 
	@discount1	money, 
	@nation		char(3), 
	@vip			char(1), 
	@haccnt		char(7), 
	@cnt			integer, 
	@message		varchar(254), 
	@rmcode		char(3), 
	@rmcodedes	varchar(30)


select @cnt = 0, @name1 = '', @vip1 = 'F', @his1 = 'F', @name2 = '', @vip2 = 'F', @his2 = 'F', @name3 = '', @vip3 = 'F', @his3 = 'F'
//declare c_name cursor for select ltrim(name), nation, vip, haccnt from guest where accnt = @accnt order by guestid
//open c_name
//fetch c_name into @onename, @nation, @vip, @haccnt
//while @@sqlstatus = 0
//	begin
//	select @cnt = @cnt + 1
//	if @cnt = 1 
//		begin
//		select @name1 = substring(@onename+'            ', 1, 12)+' - ['+@nation+']', @vip1 = isnull(rtrim(@vip), 'F')
//		if rtrim(@haccnt) is null
//			select @his1 = 'F'
//		else
//			select @his1 = 'T'
//		end
//	else if @cnt = 2 
//		begin
//		select @name2 = substring(@onename+'            ', 1, 12)+' - ['+@nation+']', @vip2 = isnull(rtrim(@vip), 'F')
//		if rtrim(@haccnt) is null
//			select @his2 = 'F'
//		else
//			select @his2 = 'T'
//		end
//	else if @cnt = 3
//		begin
//		select @name3 = substring(@onename+'            ', 1, 12)+' - ['+@nation+']', @vip3 = isnull(rtrim(@vip), 'F')
//		if rtrim(@haccnt) is null
//			select @his3 = 'F'
//		else
//			select @his3 = 'T'
//		end
//	else
//		select @name3 = @name3 + '.'
//
//	fetch c_name into @onename, @nation, @vip, @haccnt
//	end 
//close c_name
//deallocate cursor c_name
////            
//select @qtrate = qtrate, @discount = discount, @discount1 = discount1 
//	from master where accnt = @accnt
//if @discount != 0 or @discount1 != 0
//	begin
//	select @rtdescript = '原价:' + ltrim(convert(char(10), @qtrate)) + '元;'
//	if @discount != 0 
//		select @rtdescript = @rtdescript + '优惠:' + ltrim(convert(char(10), @discount)) + '元'
//	else
//		select @rtdescript = @rtdescript + '优惠:' + ltrim(convert(char(10), convert(int, @discount1 * 100))) + '%'
//	end
////
//if exists (select to_accnt from accnt_ab where accnt = @accnt and type = '4' and pccodes != '-;')
//	begin
//	declare c_transfer cursor for select distinct to_accnt from accnt_ab where accnt = @accnt and type = '4' and pccodes != '-;' order by to_accnt
//	open c_transfer
//	fetch c_transfer into @to_accnt
//	while @@sqlstatus = 0
//		begin
//		select @ref = substring(@ref + ', ' + @to_accnt , 1 , 254)
//		fetch c_transfer into @to_accnt
//		end 
//	close c_transfer
//	deallocate cursor c_transfer
//	select @ref = '自动转帐到' + rtrim(substring(@ref, 2, 254)) + ';'
//	end
//if exists (select b.accnt from master a, accnt_ab b where a.accnt = @accnt and a.groupno = b.accnt
//	and b.type = '2' and b.pccodes != '-;')
//	select @ref = rtrim(@ref) + '团体主单为其付帐;'
////
//declare c_message cursor for select convert(varchar(254), content) from message 
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
//select @rmcode = right('000'+ltrim(rtrim(convert(char(3), ratemode))), 3) from master where accnt = @accnt
//if rtrim(@rmcode) is null
//	select  @rmcode = '000'
//if exists(select 1 from ratemode_name where code = @rmcode and accnt = @accnt)
//	select @rmcodedes = descript from ratemode_name where code = @rmcode and accnt = @accnt
//else if exists(select 1 from ratemode_name where code = @rmcode)
//	select @rmcodedes = descript from ratemode_name where code = @rmcode
//else
//	select @rmcodedes = ''
//select @cnt = (select count(1) from message a, master b where a.accnt = @accnt and a.type = '0' and a.accnt = b.accnt and a.tranmark = 'F')
//
select @ref = substring(@ref, 1, 100)
select a.accnt, a.sta, a.roomno, a.arr, a.dep, a.araccnt, 
	name1 = b.name, vip1 = b.vip, his1 = @his1, name2 = @name2, vip2 = @vip2, his2 = @his2, 
	name3 = @name3, vip3 = @vip3, his3 = @his3, mail = @cnt, a.packages + ', ' + src, 
	a.applicant, @ref, a.groupno, a.srqs, a.paycode, rate = a.setrate * (1 - a.discount1), 
	extrabed = 0, a.rtreason, locksta='', a.pcrec, @rtdescript, @rmcodedes, limit, credcode, ref=''
	from master a, hgstinf b where a.accnt = @accnt and a.haccnt *= b.no
return 0;
