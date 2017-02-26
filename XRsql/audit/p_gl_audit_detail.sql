if exists ( select * from sysobjects where name = 'p_gl_audit_detail' and type ='P')
	drop proc p_gl_audit_detail;
create proc p_gl_audit_detail
	@pc_id			char(4), 
	@retmode			char(1), 
	@ret				integer out, 
	@msg				varchar(70) out
as
-- 生成收付明细 

declare
	@bdate			datetime, 
	@duringaudit	char(1), 
	@modu_id			char(2), 
	@pccode			char(5), 
	@key0				char(3), 
	@billno			char(10), 
	@menu				char(10), 
	@setnumb			char(10), 
	@refer			char(15)

select @ret=0, @msg = ''
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
truncate table account_detail
-- <<第一部分>> 计算总台付款明细 
declare billno_cursor cursor for select distinct billno from outtemp where billno like 'B%'
open billno_cursor
fetch billno_cursor into @billno
while @@sqlstatus = 0
	begin
	delete apportion_jie where pc_id = @pc_id
	delete apportion_dai where pc_id = @pc_id
	delete apportion_jiedai where pc_id = @pc_id
	insert apportion_jie select @pc_id, accnt, number, pccode, tag, charge from outtemp where billno = @billno and argcode < '9'
	insert apportion_dai 
		select @pc_id, a.pccode, sum(a.credit), isnull(b.type, ''), '' from outtemp a, reason b
		where a.billno = @billno and a.argcode > '9' and a.reason *= b.code
		group by a.pccode, isnull(b.type, '')
	if @@rowcount > 0
		begin
		update apportion_dai set accnt = isnull((select min(a.accnt) from outtemp a where a.billno = @billno), '')
			where pc_id = @pc_id
		exec p_gl_audit_apportion @pc_id, '01'
		insert account_detail (date, modu_id, accnt, number, pccode, refer, charge, paycode, key0, billno)
			select @bdate, '02', accnt, number, pccode, refer, charge, paycode, key0, @billno
			from apportion_jiedai where pc_id = @pc_id
		end
	fetch billno_cursor into @billno
	end
close billno_cursor
deallocate cursor billno_cursor
-- <<第二部分>> 计算综合收银付款明细 
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
		where (b.menu = @menu or b.pcrec = @menu) and a.menu = b.menu and a.amount != 0 and not code in ('Y','Z')
	insert apportion_dai 
		select @pc_id, a.paycode, sum(a.amount), isnull(c.type, ''), a.menu from pos_tpay a, pos_tmenu b, reason c
		where (b.menu = @menu or b.pcrec = @menu) and a.menu = b.menu and a.reason *= c.code
		group by a.paycode, isnull(c.type, ''), a.menu
	if @@rowcount > 0
		begin
		exec p_gl_audit_apportion @pc_id, @pccode
		insert account_detail 
			(date, modu_id, accnt, number, pccode, refer, charge, paycode, key0)
			select @bdate, '04', accnt, number, pccode, refer, charge, paycode, key0
			from apportion_jiedai where pc_id = @pc_id
		end
	fetch menu_cursor into @menu, @pccode
	end
close menu_cursor
deallocate cursor menu_cursor
-- <<第三部分>> 计算商务中心付款明细 
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
	if @@rowcount > 0
		begin
		select @pccode = min(pccode) from bos_hfolio where setnumb = @setnumb
		exec p_gl_audit_apportion @pc_id, @pccode
		insert account_detail 
			(date, modu_id, accnt, number, pccode, refer, charge, paycode, key0)
			select @bdate, '06', accnt, number, pccode, refer, charge, paycode, key0
			from apportion_jiedai where pc_id = @pc_id
		end
	fetch bus_cursor into @setnumb
	end
close bus_cursor
deallocate cursor bus_cursor
//   
if @retmode ='S'
	select @ret, @msg 
return @ret;
