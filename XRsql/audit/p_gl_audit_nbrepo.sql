IF OBJECT_ID('dbo.p_gl_audit_nbrepo') IS NOT NULL
    DROP PROCEDURE dbo.p_gl_audit_nbrepo
;
create proc p_gl_audit_nbrepo
	@ret			integer		out, 
	@msg			varchar(70)	out

as
-- 应收帐款日报表
declare
	@accnt		char(10), 
	@waiter		char(3), 
	@pccode		char(5), 
	@argcode		char(3), 
	@tag			char(3), 
	@credit		money, 
	@charge		money, 			 	
	@crradjt		char(2), 
	@tofrom		char(2), 
	@modu_id		char(2),
	@bdate 		datetime, 
	@value 		money

select @ret = 0, @msg = ''
if exists ( select 1 from gate where audit='T')
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead

delete nbrepo 

insert nbrepo(bdate,deptno, deptname, pccode, descript) select @bdate,deptno, '', pccode, '  ' + descript from pccode
update nbrepo set deptname = a.descript from basecode a where nbrepo.deptno = a.code and a.cat = 'chgcod_deptno'
update nbrepo set deptname = a.descript from basecode a where nbrepo.deptno = a.code and a.cat = 'paymth_deptno'

declare audit_nbrepo cursor for
	select accnt, pccode, argcode, tag, credit, charge, crradjt, tofrom, modu_id, waiter from gltemp
open audit_nbrepo
fetch audit_nbrepo into @accnt, @pccode, @argcode, @tag, @credit, @charge, @crradjt, @tofrom, @modu_id, @waiter
while @@sqlstatus = 0
	begin
	if @argcode > '9'
		begin
		if @accnt not like 'A%'					--客帐
			begin
			if @argcode in ('98')			--定金
				update nbrepo set f_in = f_in + @credit where pccode = @pccode
			else									--清算
				update nbrepo	set f_tran = f_tran + @credit where pccode = @pccode
			end
		else
			begin
			if @argcode in ('98')				--定金
				update nbrepo set b_in = b_in + @credit where pccode = @pccode
			else									--清算
				update nbrepo set b_tran = b_tran + @credit where pccode = @pccode
			end
		end
	else
		begin
		if @accnt not like 'A%'					--客帐
			begin
			if @modu_id = '02'					--录入
				update nbrepo set f_in = f_in + @charge where pccode = @pccode
			else										--转帐
				update nbrepo set f_tran = f_tran + @charge where pccode = @pccode
			end
		else
			begin
			if @modu_id = '02'					--录入
				update nbrepo set b_in = b_in + @charge where pccode = @pccode
			else										--转帐
				update nbrepo set b_tran = b_tran + @charge where pccode = @pccode
			end
		end
	fetch audit_nbrepo into @accnt, @pccode, @argcode, @tag, @credit, @charge, @crradjt, @tofrom, @modu_id, @waiter
	end
close audit_nbrepo
deallocate cursor audit_nbrepo

-- 增加 packages -- 杭州东方豪生大酒店
-- insert nbrepo (bdate,deptno,deptname,pccode,descript) values(@bdate,'8Z','Package','8ZZ','    Package')
-- select @value = isnull((select sum(credit) from package_detail where bdate=@bdate), 0)
-- update nbrepo set f_in = @value, f_out = @value where deptno='8Z' and pccode='8ZZ' and bdate = @bdate
-- update nbrepo set f_tran = isnull((select sum(charge) from package_detail where starting_date=@bdate), 0) * -1  where deptno='8Z' and pccode='8ZZ' and bdate = @bdate

delete nbrepo where f_in = 0 and b_in = 0 and f_out = 0 and b_out = 0 and f_tran = 0 and b_tran = 0

delete ynbrepo where bdate = @bdate
insert ynbrepo select * from nbrepo 

return @ret
;