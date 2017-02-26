//------------------------------------------------------------------------------
//	BOS  -- 与库存相关的 proc 
//
//		p_gds_bos_kc_folio_input		-- 物流单据的入账
//		p_gds_bos_kc_sta					-- 物流单据的删除，恢复
//		p_gds_bos_maint_store			-- 库存维护
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//			bos_kcmenu ---> bos_store
//				帐单的入帐, 冲帐, 补救
//				调整 bos_store, 记录 bos_kcdish -- 原金额	
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_gds_bos_kc_folio_input')
	drop proc p_gds_bos_kc_folio_input;
create proc  p_gds_bos_kc_folio_input
	@modu_id		char(2),
	@pc_id		char(4),
	@mode			char(2),          //IN-入帐  OU-冲帐  BJ-补救
	@folio		char(10),
	@empno		char(10),
	@msg			varchar(60) output,
	@returnmode	char(1)	= 'S'         // 'R'
as
declare 	@flag		char(2),
			@pccode	char(5),
			@sta		char(1),
			@site0	varchar(5),
			@site1	varchar(5),
			@code		char(8),
			@number	money,
			@price	money,
			@blow		money,
			@amount 	money,
			@amount1	money,
			@profit 	money,
			@bdate 	datetime,
			@bdate0 	datetime,
			@ret	 	int,
			@pc_id0	char(4),
			@id		char(6)

select @ret = 0, @msg = 'ok !'

// 取得营业日期   
select @bdate = bdate1 from sysdata

begin tran 
save tran p_gds_bos_kc_folio_input1

if not exists(select 1 from bos_kcmenu where folio = @folio) or not exists(select 1 from bos_kcdish where folio = @folio) 
	select @ret = 1, @msg = '该帐号不存在,或单据不完整 ! ---- ' + @folio

if @ret = 0 and @mode = 'IN'
	if not exists(select 1 from bos_kcmenu where folio = @folio and sta='I')
		select @ret = 1, @msg = '该帐号非有效状态 ! '

if @ret = 0 and @mode='IN'
begin
	select @pc_id0 = pc_id from bos_kcmenu where folio = @folio
	if @pc_id0 is not null and @pc_id0 <> @pc_id
		select @ret = 1, @msg = '该单据正在 '+@pc_id0+' 工作站修改 ! '
end

if @ret = 0 and @mode <> 'IN'
	if not exists(select 1 from bos_kcmenu where folio = @folio and sta='O')
		select @ret = 1, @msg = '该帐号非入账状态 ! '
/*  --> 销售要限制,其他不必 !
	else
	begin
		select @bdate0 = bdate from bos_kcmenu where folio = @folio
		if datediff(dd, @bdate, @bdate0) <> 0 
			select @ret = 1, @msg = '只能冲销补救当日单据 ! '
	end
*/

// 2002/03 
if @mode = 'OU'  // 冲帐
	select @ret = 1, @msg = '不能进行冲账 ! ---- 入账错误请输入相反的单据进行处理。'
else if @mode = 'BJ'	// 补救
	select @ret=1, @msg='暂时不提供补救功能，请用冲账 !'
else if @mode <> 'IN'
	select @ret=1, @msg='未知帐务处理标志'

// 明细记账
if @ret = 0
	exec @ret = p_gds_bos_detail @modu_id, @pc_id, @folio, '', '', @msg output

if @ret = 0 
begin
	// 取得营业日期  
	select @bdate = bdate1 from sysdata
	if @mode = 'IN'
	begin
		update bos_kcmenu set bdate=@bdate, sta = 'O', pc_id=null,cby=@empno, cdate=getdate(), logmark=logmark + 1 where folio = @folio
		if @@error <> 0 
			select @ret = 1, @msg = '更新 FOLIO 失败 !'
	end
	else if @mode = 'OU'  // 冲帐
		select @ret = 1, @msg = '不能进行冲账 ! ---- 入账错误请输入相反的单据进行处理。'
	else if @mode = 'BJ'	// 补救
		select @ret=1, @msg='暂时不提供补救功能，请用冲账 !'
	else
		select @ret=1, @msg='未知帐务处理标志'
end
gout:
if @ret <> 0
	rollback tran p_gds_bos_kc_folio_input1
commit tran

if @returnmode = 'S' 
	select @ret, @msg

return @ret
;


////------------------------------------------------------------------------------
////			bos_kcmenu ---> bos_store
////				帐单的入帐, 冲帐, 补救
////				调整 bos_store, 记录 bos_kcdish -- 原金额	
////------------------------------------------------------------------------------
//if exists (select 1 from sysobjects where name = 'p_gds_bos_kc_folio_input')
//	drop proc p_gds_bos_kc_folio_input;
//create proc  p_gds_bos_kc_folio_input
//	@pc_id		char(4),
//	@mode			char(2),          //IN-入帐  OU-冲帐  BJ-补救
//	@folio		char(10),
//	@empno		char(10),
//	@msg			varchar(60) output,
//	@returnmode	char(1)	= 'S'         // 'R'
//as
//declare 	@flag		char(2),
//			@pccode	char(3),
//			@sta		char(1),
//			@site0	varchar(5),
//			@site1	varchar(5),
//			@code		char(8),
//			@number	money,
//			@price	money,
//			@blow		money,
//			@amount 	money,
//			@amount1	money,
//			@profit 	money,
//			@bdate 	datetime,
//			@bdate0 	datetime,
//			@ret	 	int,
//			@pc_id0	char(4),
//			@empname	char(12),
//			@id		char(6)
//
//select @ret = 0, @msg = 'ok !'
//
//// 取得营业日期   
//select @bdate = bdate1 from sysdata
//
//begin tran 
//save tran p_gds_bos_kc_folio_input1
//
//if not exists(select 1 from bos_kcmenu where folio = @folio) or not exists(select 1 from bos_kcdish where folio = @folio) 
//	select @ret = 1, @msg = '该帐号不存在,或单据不完整 ! ---- ' + @folio
//
//if @ret = 0 and @mode = 'IN'
//	if not exists(select 1 from bos_kcmenu where folio = @folio and sta='I')
//		select @ret = 1, @msg = '该帐号非有效状态 ! '
//
//if @ret = 0 and @mode='IN'
//begin
//	select @pc_id0 = pc_id from bos_kcmenu where folio = @folio
//	if @pc_id0 is not null and @pc_id0 <> @pc_id
//		select @ret = 1, @msg = '该单据正在 '+@pc_id0+' 工作站修改 ! '
//end
//
//if @ret = 0 and @mode <> 'IN'
//	if not exists(select 1 from bos_kcmenu where folio = @folio and sta='O')
//		select @ret = 1, @msg = '该帐号非入账状态 ! '
///*  --> 销售要限制,其他不必 !
//	else
//	begin
//		select @bdate0 = bdate from bos_kcmenu where folio = @folio
//		if datediff(dd, @bdate, @bdate0) <> 0 
//			select @ret = 1, @msg = '只能冲销补救当日单据 ! '
//	end
//*/
//
//// 2002/03 
//if @mode = 'OU'  // 冲帐
//	select @ret = 1, @msg = '不能进行冲账 ! ---- 入账错误请输入相反的单据进行处理。'
//else if @mode = 'BJ'	// 补救
//	select @ret=1, @msg='暂时不提供补救功能，请用冲账 !'
//else if @mode <> 'IN'
//	select @ret=1, @msg='未知帐务处理标志'
//
//select @empname = name from auth_login where empno = @empno
//
//if @ret = 0
//begin
//	// 取得当前时间段的帐务标志
//	select @id = min(id) from bos_store
//
//	// 取得单据的标志 -- 入,损,盘,调,(售),领,内,外
//	select @pccode=pccode,@flag=flag,@site0=site0,@site1=site1 from bos_kcmenu where folio = @folio
//	declare cc cursor for select code, number, amount, amount1,profit from bos_kcdish where folio = @folio order by code
//	open cc
//	fetch cc into @code, @number, @amount, @amount1, @profit
//	while @@sqlstatus = 0
//	begin
//		if @number=0 continue
//		if @mode <> 'IN' 
//			select @number=@number* -1, @amount=@amount* -1, @amount1=@amount1* -1, @profit=@profit* -1
//		if not exists(select 1 from bos_store where pccode=@pccode and site = @site0 and code = @code)
//		begin
//			if not exists(select 1 from bos_site where pccode=@pccode and site=@site0)
//			begin
//				select @ret=1, @msg='地点0 错误 !'
//				goto gout
//			end
//			else
//				insert bos_store (id, pccode, site, code) select @id, @pccode, @site0, @code
//		end
//
//		if @flag = '入'
//			update bos_store set number1=number1+@number,amount1=amount1+@amount,sale1=slae1+@amount1,profit1=profit1+@profit,
//				number9=number9+@number,amount9=amount9+@amount,sale9=slae9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site0 and code = @code
//		else if @flag = '损'
//			update bos_store set number2=number2+@number,amount2=amount2+@amount,sale2=slae2+@amount1,profit2=profit2+@profit,
//				number9=number9-@number,amount9=amount9-@amount,sale9=slae9-@amount1,profit9=profit9-@profit where pccode=@pccode and site = @site0 and code = @code
//		else if @flag = '盘'  
//			update bos_store set number3=number3+@number,amount3=amount3+@amount,sale3=slae3+@amount1,profit3=profit3+@profit,
//				number9=number9+@number,amount9=amount9+@amount,sale9=slae9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site0 and code = @code
//		else if @flag = '调'  
//		begin
//			update bos_store set number4=number4+@number,amount4=amount4+@amount,sale4=slae4+@amount1,profit4=profit4+@profit,
//				number9=number9+@number,amount9=amount9+@amount,sale9=slae9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site0 and code = @code
//			if @site0 = @site1 
//			begin
//				select @ret=1, @msg='调拨单的两个地点相同，错误 !'
//				goto gout
//			end
//			if not exists(select 1 from bos_store where pccode=@pccode and site = @site1 and code = @code)
//			begin
//				if not exists(select 1 from bos_site where pccode=@pccode and site=@site1)
//				begin
//					select @ret=1, @msg='地点1 错误 !'
//					goto gout
//				end
//				else
//					insert bos_store (id, pccode, site, code) select @id, @pccode, @site1, @code
//			end
//			update bos_store set number4=number4-@number,amount4=amount4-@amount,sale4=slae4-@amount1,profit4=profit4-@profit,
//				number9=number9-@number,amount9=amount9-@amount,sale9=slae9-@amount1,profit9=profit9-@profit where pccode=@pccode and site = @site1 and code = @code
//		end
//		else if @flag = '领'  
//		begin
//			update bos_store set number6=number6+@number,amount6=amount6+@amount,sale6=slae6+@amount1,profit6=profit6+@profit,
//				number9=number9+@number,amount9=amount9+@amount,sale9=slae9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site0 and code = @code
//			if @site0 = @site1 
//			begin
//				select @ret=1, @msg='领料单的两个地点相同，错误 !'
//				goto gout
//			end
//			if not exists(select 1 from bos_store where pccode=@pccode and site = @site1 and code = @code)
//			begin
//				if not exists(select 1 from bos_site where pccode=@pccode and site=@site1)
//				begin
//					select @ret=1, @msg='地点1 错误 !'
//					goto gout
//				end
//				else
//					insert bos_store (id, pccode, site, code) select @id, @pccode, @site1, @code
//			end
//			update bos_store set number6=number6-@number,amount6=amount6-@amount,sale9=slae9-@amount1,profit9=profit9-@profit,
//				number9=number9-@number,amount9=amount9-@amount,sale9=slae9-@amount1,profit9=profit9-@profit where pccode=@pccode and site = @site1 and code = @code
//		end
//		else if @flag = '内'  // 与当前库存数量不一定必须相等, amount 为调整的差额 !
//		begin
////			if not exists(select 1 from bos_store where pccode=@pccode and site = @site0 and code = @code and number9=@number)
////			begin
////				select @ret=1, @msg='调价单的数量必须等于库存数量 !'
////				goto gout
////			end
//			update bos_store set number7=number7+@number,amount7=amount7+@amount,sale7=slae7+@amount1,profit7=profit7+@profit,
//				amount9=amount9+@amount,sale9=slae9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site0 and code = @code
//		end
//		else if @flag = '外'  // 与当前库存数量不一定必须相等, amount 为调整的差额 !
//		begin
////			if not exists(select 1 from bos_store where pccode=@pccode and site = @site0 and code = @code and number9=@number)
////			begin
////				select @ret=1, @msg='调价单的数量必须等于库存数量 !'
////				goto gout
////			end
//			update bos_store set number8=number8+@number,amount8=amount8+@amount,sale8=slae8+@amount1,profit8=profit8+@profit,
//				amount9=amount9+@amount,sale9=slae9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site0 and code = @code
//		end
//		else 
//		begin
//			select @ret=1, @msg='无效账单标志 !'
//			goto gout
//		end
//
//		// 关于明细账
//		
//
//		fetch cc into @code, @number, @amount, @amount1, @profit
//	end
//	close cc
//	deallocate cursor cc
//end
//
//if @ret = 0 
//begin
//	// 取得营业日期  
//	select @bdate = bdate1 from sysdata
//	if @mode = 'IN'
//	begin
//		update bos_kcmenu set bdate=@bdate, sta = 'O', pc_id=null,cby=@empno, cdate=getdate(), cname=@empname, logmark=logmark + 1 where folio = @folio
//		if @@error <> 0 
//			select @ret = 1, @msg = '更新 FOLIO 失败 !'
//	end
//	else if @mode = 'OU'  // 冲帐
//	begin
////		update bos_kcmenu set bdate=@bdate, sta = 'D', pc_id=null,dby=@empno, ddate=getdate(), dname=@empname,logmark=logmark + 1 where folio = @folio
////		if @@error <> 0 
////			select @ret = 1, @msg = '更新 FOLIO 失败 !'
//
//		// 2002/03 
//		select @ret = 1, @msg = '不能进行冲账 ! ---- 入账错误请输入相反的单据进行处理。'
//	end
//	else if @mode = 'BJ'	// 补救
//	begin
//		select @ret=1, @msg='暂时不提供补救功能，请用冲账 !'
//	end
//	else
//	begin
//		select @ret=1, @msg='未知帐务处理标志'
//	end
//end
//gout:
//if @ret <> 0
//	rollback tran p_gds_bos_kc_folio_input1
//commit tran
//
//if @returnmode = 'S' 
//	select @ret, @msg
//
//return @ret
//;
//


//------------------------------------------------------------------------------
//			帐单 删除 恢复 程序
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_gds_bos_kc_sta')
	drop proc p_gds_bos_kc_sta;
create proc  p_gds_bos_kc_sta
	@pc_id		char(4),
	@folio		char(10),
	@mode			char(4),        			// dele, back
	@msg			varchar(60) output,
	@returnmode	char(1)	= 'S'         	// 'R'
as

declare 	@ret		int, 
			@pc_id0	char(4)

select @ret = 0, @msg = ''

begin tran 
save tran p_gds_bos_kc_sta1

if @mode <> 'dele' and @mode <> 'back' 
	select @ret = 1, @msg = 'SP 的操作模式错误 !'

if @ret = 0
	if not exists(select 1 from bos_kcmenu where folio = @folio)
		select @ret = 1, @msg = '该单据不存在 !'

if @ret = 0
begin
	select @pc_id0 = pc_id from bos_kcmenu where folio = @folio
	if @pc_id0 is not null and @pc_id <> @pc_id0
		select @ret = 1, @msg = '该单据正在'+@pc_id0+'工作站修改 !'
end

if @ret = 0
begin
	if @mode = 'dele'
	begin
		if not exists(select 1 from bos_kcmenu where folio = @folio and sta='I')
			select @ret = 1, @msg = '该单据非有效状态 !'
		else
		begin
			update bos_kcmenu set sta = 'X', pc_id=null where folio = @folio
			if @@error <> 0 
				select @ret = 1, @msg = '数据库操作失败 !'
		end
	end	
	else
	begin
		if not exists(select 1 from bos_kcmenu where folio = @folio and sta='X')
			select @ret = 1, @msg = '该单据非有效状态 !'
		else
		begin
			update bos_kcmenu set sta = 'I', pc_id=null where folio = @folio
			if @@error <> 0 
				select @ret = 1, @msg = '数据库操作失败 !'
		end
	end	
end

if @ret <> 0
	rollback tran p_gds_bos_kc_sta1
commit tran 

if @returnmode = 'S' 
	select @ret, @msg

return @ret
;

//------------------------------------------------------------------------------
// 简单的 维护当月销售成本及库存金额 !
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_gds_bos_maint_store')
	drop proc p_gds_bos_maint_store;
create proc p_gds_bos_maint_store
as

// 产生综合的<本月>库存单价
create table #price 
(
	pccode	char(5)		not null,
	site		char(5)		not null,		
	code		char(8)		not null,		
	price		money	default 0	not null
)
insert #price select pccode,site,code,0 from bos_store

update #price set price = (a.amount0+a.amount1)/(a.number0+a.number1)
	from bos_store a where a.number0+a.number1 <> 0
		and a.pccode=#price.pccode and a.site=#price.site and a.code=#price.code
update #price set price = a.amount0/a.number0
	from bos_store a where a.number0+a.number1=0 and a.number0<>0
		and a.pccode=#price.pccode and a.site=#price.site and a.code=#price.code

// -- 此时需要一个参考价
//update #price set price =  ???
//	from bos_store a where a.number1=0 and a.number0=0
//		and a.pccode=#price.pccode and a.site=#price.site and a.code=#price.code

// 维护销售单据的成本价
update bos_hdish set amount0=round(number*b.price, 4)
	from bos_hfolio a, #price b
		where bos_hdish.foliono=a.foliono  
				and a.setnumb is not null
				and a.pccode=b.pccode 
				and a.site=b.site
				and bos_hdish.code=b.code
				
// 维护库存表的销售金额，和库存金额
update bos_store set amount5 = round(number5*a.price, 2)
	from #price a where bos_store.pccode=a.pccode and bos_store.site=a.site 
		and bos_store.code=a.code

update bos_store set amount9 = amount0+amount1-amount2+amount3-amount4-amount5

return 0
;

// 如果最后库存数量=0，但是金额<>0，此时需要把销售成本调整 !
// select * from bos_store where number9=0 and amount9<>0;

// 核查 :
// select * from bos_store where number0+number1-number2+number3-number4-number5<>number9;
// select * from bos_store where amount0+amount1-amount2+amount3-amount4-amount5<>amount9;

// 核查那一天的地表不平
//select a.date, a.day99, b.sumcre 
//	from yjierep a, ydairep b 
//	where a.date=b.date and a.class='999' and b.class='09000'
//			and a.day99<>b.sumcre
//			order by a.date;
