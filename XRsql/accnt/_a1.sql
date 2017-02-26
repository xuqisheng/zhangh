/* 生成收付明细 */
if exists ( select * from sysobjects where name = 'p_a1' and type ='P')
	drop proc p_a1;
create proc p_a1
	@bdate			datetime
as

declare
	@duringaudit	char(1), 
	@modu_id			char(2), 
	@pccode			char(3), 
	@key0				char(3), 
	@billno			char(10), 
	@menu				char(10), 
	@setnumb			char(10), 
	@refer			char(15), 
	@pc_id			char(4), 
	@retmode			char(1), 
	@ret				integer, 
	@msg				varchar(70)

select @ret=0, @msg = convert(char(10), @bdate, 111), @pc_id = '9999'
select @msg = 'B' + substring(@msg, 4, 1) + substring(@msg, 6, 2) + substring(@msg, 9, 2) + '%'
truncate table gltemp
insert gltemp select * from account where bdate=@bdate
	union select * from haccount where bdate=@bdate
truncate table outtemp
insert outtemp select * from account where billno like @msg
	union select * from haccount where billno like @msg
truncate table pos_tmenu
insert pos_tmenu select * from pos_hmenu where bdate=@bdate
truncate table pos_tdish
insert pos_tdish select a.* from pos_hdish a, pos_tmenu b where a.menu = b.menu
truncate table pos_tpay
insert pos_tpay select a.* from pos_hpay a, pos_tmenu b where a.menu = b.menu
truncate table account_detail
/* <<第一部分>> 计算总台付款明细 */
declare billno_cursor cursor for select distinct billno from outtemp where billno like 'B%'
open billno_cursor
fetch billno_cursor into @billno
while @@sqlstatus = 0
	begin
	delete apportion_jie where pc_id = @pc_id
	delete apportion_dai where pc_id = @pc_id
	delete apportion_jiedai where pc_id = @pc_id
	insert apportion_jie select @pc_id, accnt, number, pccode, tag, charge from outtemp where billno = @billno and pccode < '9'
	insert apportion_dai 
		select @pc_id, a.pccode, sum(a.credit), isnull(b.type, ''), '' from outtemp a, reason b
		where a.billno = @billno and a.pccode > '9' and a.reason *= b.code
		group by a.pccode, isnull(b.type, '')
	update apportion_dai set accnt = isnull((select min(a.accnt) from outtemp a where a.billno = @billno), '')
		where pc_id = @pc_id
	exec p_gl_audit_apportion @pc_id, '01'
	insert account_detail (date, modu_id, accnt, number, pccode, refer, charge, paycode, key0, billno)
		select @bdate, '02', accnt, number, pccode, refer, charge, paycode, key0, @billno
		from apportion_jiedai where pc_id = @pc_id
	fetch billno_cursor into @billno
	end
close billno_cursor
deallocate cursor billno_cursor
/* <<第二部分>> 计算综合收银付款明细 */
declare menu_cursor cursor for
	select distinct isnull(rtrim(pcrec), menu), pccode from pos_tmenu 
	where charindex(paid, '1') > 0 and setmodes <> ''
//	where charindex(paid, '1') > 0 and setmodes <> '' and substring(isnull(remark, space(20)), 11, 3) <> '---'
open menu_cursor
fetch menu_cursor into @menu, @pccode
while @@sqlstatus = 0
	begin
	delete apportion_jie where pc_id = @pc_id
	delete apportion_dai where pc_id = @pc_id
	delete apportion_jiedai where pc_id = @pc_id
	insert apportion_jie 
		select @pc_id, a.menu, a.inumber, @pccode, a.code, a.amount + a.srv - a.dsc - a.tax from pos_tdish a, pos_tmenu b
		where (b.menu = @menu or b.pcrec = @menu) and a.menu = b.menu and a.amount != 0 and not code in ('X','Y','Z')
	insert apportion_dai 
		select @pc_id, a.paycode, sum(a.amount), isnull(c.type, ''), a.menu from pos_tpay a, pos_tmenu b, reason c
		where (b.menu = @menu or b.pcrec = @menu) and a.menu = b.menu and a.reason *= c.code
		group by a.paycode, isnull(c.type, ''), a.menu
	exec p_gl_audit_apportion @pc_id, @pccode
	insert account_detail 
		(date, modu_id, accnt, number, pccode, refer, charge, paycode, key0)
		select @bdate, '04', accnt, number, pccode, refer, charge, paycode, key0
		from apportion_jiedai where pc_id = @pc_id
	fetch menu_cursor into @menu, @pccode
	end
close menu_cursor
deallocate cursor menu_cursor
/* <<第三部分>> 计算商务中心付款明细 */
declare bus_cursor cursor for
	select distinct setnumb from bos_haccount where bdate = @bdate
open bus_cursor
fetch bus_cursor into @setnumb
while @@sqlstatus = 0
	begin
	delete apportion_jie where pc_id = @pc_id
	delete apportion_dai where pc_id = @pc_id
	delete apportion_jiedai where pc_id = @pc_id
	insert apportion_jie 
		select @pc_id, setnumb, convert(integer, substring(foliono, 2, 9)), pccode, '', fee 
		from bos_hfolio where setnumb = @setnumb
	insert apportion_dai 
		select @pc_id, a.code1, sum(a.amount), isnull(b.type, ''), @setnumb
		from bos_haccount a, reason b
		where a.setnumb = @setnumb and a.reason *= b.code
		group by a.code1, isnull(b.type, '')
	select @pccode = min(pccode) from bos_hfolio where setnumb = @setnumb
	exec p_gl_audit_apportion @pc_id, @pccode
	insert account_detail 
		(date, modu_id, accnt, number, pccode, refer, charge, paycode, key0)
		select @bdate, '06', accnt, number, pccode, refer, charge, paycode, key0
		from apportion_jiedai where pc_id = @pc_id
	fetch bus_cursor into @setnumb
	end
close bus_cursor
deallocate cursor bus_cursor
//   
if @retmode ='S'
	select @ret, @msg 
return @ret;
