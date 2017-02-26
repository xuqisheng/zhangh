
IF OBJECT_ID('p_gl_audit_breakfast_adjust') IS NOT NULL
    DROP PROCEDURE p_gl_audit_breakfast_adjust
;
create proc p_gl_audit_breakfast_adjust
	@shift				char(1),
	@empno				char(10)
as

declare
	@bdate				datetime,
	@posted				char(1),
	@accnt				char(10),
	@f						money,
	@g						money,
	@m						money,
	@l						money,
	@amount				money,
	@rule					varchar(255),
	@ret					integer,
	@msg					char(60)

create table #breakfast
(
	accnt			char(10)			not null,
	class			char(1)			not null
)

select @bdate = bdate1, @ret = 0, @msg = '' from sysdata
select @posted = posted from breakfast where date = @bdate
if @@rowcount = 0
	insert breakfast (date) select @bdate
else if @posted = 'T'
	begin
	select @ret, @msg
	return 0
	end
exec p_gl_audit_breakfast_total @bdate, '1', 'R', @f out, @g out, @m out, @l out
update breakfast set tf = @f, tg = @g, tm = @m, tl = @l where date = @bdate





select @rule = isnull((select value from sysoption where catalog = 'audit' and item = 'breakfast_adjust_rule'), 'c')
if @rule = 'c'
	select @f = -cf, @g = -cg, @m = -cm, @l = -cl
		from breakfast where date = @bdate
else if @rule = 't'
	select @f = -tf, @g = -tg, @m = -tm, @l = -tl
		from breakfast where date = @bdate
else if @rule = 't+c-f'
	select @f = -(tf + cf - lf), @g = -(tg + cg - lg), @m = -(tm + cm - lm), @l = -(tl + cl - ll)
		from breakfast where date = @bdate
else
	select @f = 0, @g = 0, @m = 0, @l = 0
select @amount = - @f - @g - @m - @l
select @accnt = value from sysoption where catalog = 'audit' and item = 'breakfast_adjust_accnt'
if exists (select 1 from master where accnt = @accnt and sta in ('I', 'S'))
	begin
	begin tran
	save tran posting_1
	exec @ret = p_gl_accnt_posting 'A', '02', '9999', 0, @shift, @empno, @accnt, 0, '011', '',
		1, @f, 0, 0, 0, 0, 0, '', '', @bdate, '', '', 'ARYY', 0, null, @msg out
	if @ret = 1
		GOTO RETURN_1

	select @g = @g + @m
	exec @ret = p_gl_accnt_posting 'A', '02', '9999', 0, @shift, @empno, @accnt, 0, '012', '',
		1, @g , 0, 0, 0, 0, 0, '', '', @bdate, '', '', 'ARYY', 0, null, @msg out
	if @ret = 1
		GOTO RETURN_1

	exec @ret = p_gl_accnt_posting 'A', '02', '9999', 0, @shift, @empno, @accnt, 0, '013', '',
		1, @l , 0, 0, 0, 0, 0, '', '', @bdate, '', '', 'ARYY', 0, null, @msg out
	if @ret = 1
		GOTO RETURN_1

	exec @ret = p_gl_accnt_posting 'A', '02', '9999', 0, @shift, @empno, @accnt, 0, '881', '',
		1, @amount , 0, 0, 0, 0, 0, '', '', @bdate, '', '', 'ARYY', 0, null, @msg out

	update breakfast set posted = 'T' where date = @bdate
	RETURN_1:
	if @ret ! = 0
		rollback tran posting_1
	commit tran
	end

select @ret, @msg
return 0
;



IF OBJECT_ID('p_gl_audit_breakfast_total') IS NOT NULL
    DROP PROCEDURE p_gl_audit_breakfast_total
;
create proc p_gl_audit_breakfast_total
	@bdate			datetime, 
	@type				char(1), 
	@operation		char(1) = 'S', 
	@f					money = 0 output, 
	@g					money = 0 output, 
	@m					money = 0 output, 
	@l					money = 0 output
as

create table #breakfast
(
	accnt			char(10)			not null, 					      
	class			char(1)			not null,
	quantity		money				default 0 not null,
	amount		money				default 0 not null,
)
   
insert #breakfast select a.accnt, '', a.quantity, a.credit from package_detail a, package b
	where a.bdate = @bdate and a.tag < '5' and a.code = b.code and b.type = @type
update #breakfast set class = a.class
	from rmpostbucket a where #breakfast.accnt = a.accnt and a.rmpostdate = @bdate

---add by wz at 2004.2.26
update #breakfast set class = 'L' from master where #breakfast.accnt = master.accnt and master.market = 'LON'

                                                              
                                                              
                        
                                                              
select @f = sum(amount) from #breakfast where class = 'F'
select @g = sum(amount) from #breakfast where class = 'G'
select @m = sum(amount) from #breakfast where class = 'M'
select @l = sum(amount) from #breakfast where class = 'L'
select @f = isnull(@f, 0), @g = isnull(@g, 0), @m = isnull(@m, 0), @l = isnull(@l, 0)
if @operation = 'S'
	select @f, @g, @m, @l
return 0
;