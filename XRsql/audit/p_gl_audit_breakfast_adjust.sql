/* 统计明天早餐的预提数 */

if exists(select * from sysobjects where name = 'p_gl_audit_breakfast_adjust')
	drop proc p_gl_audit_breakfast_adjust;

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

//杭州索菲特西湖大酒店
//create table #breakfast
//(
//	accnt			char(10)			not null, 					/*  */
//	class			char(1)			not null
//)
////
//select @bdate = bdate1, @ret = 0, @msg = '' from sysdata
//select @posted = posted from breakfast where date = @bdate
//if @@rowcount = 0
//	insert breakfast (date) select @bdate
//else if @posted = 'T'
//	begin
//	select @ret, @msg
//	return 0
//	end
//exec p_gl_audit_breakfast_total @bdate, '1', 'R', @f out, @g out, @m out, @l out
//update breakfast set tf = @f, tg = @g, tm = @m, tl = @l where date = @bdate
////
////select @f = 0, @g = 0, @m = 0, @l = 0
////select @f = tf, @g = tg, @m = tm, @l = tl from breakfast where date = dateadd(dd, -1, @bdate)
////update breakfast set lf = isnull(@f, 0), lg = isnull(@g, 0), lm = isnull(@m, 0), ll = isnull(@l, 0) where date = @bdate
////
//select @rule = isnull((select value from sysoption where catalog = 'audit' and item = 'breakfast_adjust_rule'), 'c')
//if @rule = 'c'
//	select @f = -cf, @g = -cg, @m = -cm, @l = -cl
//		from breakfast where date = @bdate
//else if @rule = 't'
//	select @f = -tf, @g = -tg, @m = -tm, @l = -tl
//		from breakfast where date = @bdate
//else if @rule = 't+c-f'
//	select @f = -(tf + cf - lf), @g = -(tg + cg - lg), @m = -(tm + cm - lm), @l = -(tl + cl - ll)
//		from breakfast where date = @bdate
//else
//	select @f = 0, @g = 0, @m = 0, @l = 0
//select @amount = - @f - @g - @m - @l
//select @accnt = value from sysoption where catalog = 'audit' and item = 'breakfast_adjust_accnt'
//if exists (select 1 from master where accnt = @accnt and sta in ('I', 'S'))
//	begin
//	begin tran
//	save tran posting_1
//	exec @ret = p_gl_accnt_posting 'A', '02', '9999', 0, @shift, @empno, @accnt, 0, '011', '', 
//		1, @f, 0, 0, 0, 0, 0, '', '', @bdate, '', '', 'ARYY', 0, null, @msg out
//	if @ret = 1
//		GOTO RETURN_1
//	//
//	select @g = @g + @m
//	exec @ret = p_gl_accnt_posting 'A', '02', '9999', 0, @shift, @empno, @accnt, 0, '012', '', 
//		1, @g , 0, 0, 0, 0, 0, '', '', @bdate, '', '', 'ARYY', 0, null, @msg out
//	if @ret = 1
//		GOTO RETURN_1
//	//
//	exec @ret = p_gl_accnt_posting 'A', '02', '9999', 0, @shift, @empno, @accnt, 0, '013', '', 
//		1, @l , 0, 0, 0, 0, 0, '', '', @bdate, '', '', 'ARYY', 0, null, @msg out
//	if @ret = 1
//		GOTO RETURN_1
//	//
//	exec @ret = p_gl_accnt_posting 'A', '02', '9999', 0, @shift, @empno, @accnt, 0, '881', '', 
//		1, @amount , 0, 0, 0, 0, 0, '', '', @bdate, '', '', 'ARYY', 0, null, @msg out
//	//
//	update breakfast set posted = 'T' where date = @bdate
//	RETURN_1:
//	if @ret ! = 0
//		rollback tran posting_1
//	commit tran
//	end
//
//杭州东方豪生大酒店
--团体早餐自动package routing
update master set pcrec_pkg = groupno where groupno like 'G%'
select @ret, @msg
return 0
;