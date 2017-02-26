---------------------------------------------------------------------------------
-- 夜间稽核-> 根据 cms_rec 记录，向 消费帐进行入账处理
-- 金陵饭店 = 每个市场码建立一个对应的消费帐户 basecode/cat=cmslink
--
-- 这种方法在标准版本中弃用 !
---------------------------------------------------------------------------------


if  exists(select * from sysobjects where name = "p_tcr_audit_cmspost")
	drop proc p_tcr_audit_cmspost
;
//create proc p_tcr_audit_cmspost
//	@modu_id				char(2),
//	@shift				char(1),
//	@empno				char(10),
//	@operation			char(1)
//as
//---------------------------------------------------------------------------------
//-- 夜间稽核-> 根据 cms_rec 记录，向 消费帐进行入账处理
//-- 金陵饭店 = 每个市场码建立一个对应的消费帐户 basecode/cat=cmslink
//--
//-- 这种方法在标准版本中弃用 !
//---------------------------------------------------------------------------------
//declare
//	@pc_id				char(4),
//	@mdi_id				integer,
//	@selemark			char(17),
//	@accnt				char(10),
//	@roomno				char(5),
//	@ratecode			char(10),
//	@today				datetime,
//	@rmpostdate			datetime,
//	@ret					integer,
//	@msg					char(60),
//	@quantity			money,
//	@charge1				money,
//	@charge2				money,
//	@charge3				money,
//	@charge4				money,
//	@charge5				money,
//	@rtreason			char(3),
//                        
//	@package				char(10),
//	@pccode				char(5),
//	@argcode				char(3),
//	@rmpccode			char(5),
//	@column				integer,
//	@count				integer,
//	@amount				money,
//	@rule_calc			char(10),
//	@mode					char(10),
//	@ref2					char(50),
//	@w_or_h				integer,
//
//	@srqs					char(18),
//	@tranlog				char(10),
//	@extrainf			char(30),
//	@pos					integer,
//	@ent1					integer,
//	@ent2					integer,
//	@errorlog			varchar(255),
//	@groupno				char(10),
//	@mktcode				char(3),
//	@to_accnt			char(10)
//
//select @shift = '3', @today = getdate(), @pc_id = '9999', @mdi_id = 0
//select @rmpostdate = bdate from sysdata
//select @rmpccode = '0109'
//select @selemark = 'A' + convert(char(10), @rmpostdate, 111)
//create table #cms_rec
//		(mktcode   char(3) not null,
//		 accnt     char(10) not null,
//		 cms       money default 0 not null)	
//
//
//insert into #cms_rec 
//select market,'',sum(cms0-cms) from cms_rec  where  sta = 'I' and back='F' group by market
//
//update #cms_rec set accnt = a.descript from basecode a where a.cat ='cmslink' and #cms_rec.mktcode = a.code
//
//declare c_rmpostbucket cursor for
//	select a.accnt, -1*a.cms,a.mktcode from #cms_rec a
//
//open c_rmpostbucket
//fetch c_rmpostbucket into @accnt, @amount,@mktcode
//while @@sqlstatus = 0
//	begin
//	begin tran
//	save tran p_tcr_audit_cmspost_s1
//	select @mode = '', @quantity = 1
//	select @ret = 0, @ref2 = null
//	exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id, @mdi_id, @shift, @empno, @accnt, 0, @rmpccode, '',
//		@quantity, @amount, 0, 0, 0, 0, 0, '', @ref2, @rmpostdate, 'OO', @mode, 'IRYY', 0, @to_accnt out, @msg out
//
//
//	if @ret = 0
//			update cms_rec set back = 'T'  where sta = 'I' and back='F' and market = @mktcode
//	if @ret != 0
//		begin
//		select @errorlog = rtrim(@errorlog) + '[' + @accnt + ']' + @msg + ' '
//		rollback tran p_tcr_audit_cmspost_s1
//		end
//	commit tran
//	fetch c_rmpostbucket into @accnt, @amount,@mktcode
//	end
//close c_rmpostbucket
//deallocate cursor c_rmpostbucket
//
//select @count = count(1) from cms_rec where bdate = @rmpostdate and sta = 'I' and back='F'
//if @count > 0
//	select @ret = 1, @errorlog = '有' + ltrim(convert(char(5), @count)) + '个客人的佣金入账失败，请检查'
//else
//	begin
//	if @operation = 'R'
//		select @ret = 0, @errorlog = '成功'
//	end
//
//if @operation = 'S'
//	select @ret, @errorlog
//return @ret
//;
//