// ------------------------------------------------------------------------------
//		bos 库存明细账 -------- 记账
//
//			1。根据 物流单据 或者 销售单据 记账
//			2。记账表涉及 bos_store & bos_detail，暂时不校验结果对比
//			3。自动校验库存清空的合理性 ---- 数量，金额 同时清空
//
// ------------------------------------------------------------------------------

if exists (select 1 from sysobjects where name = 'p_gds_bos_detail')
	drop proc p_gds_bos_detail;
create proc  p_gds_bos_detail
	@modu_id		char(2),
	@pc_id		char(4),
	@folio		char(10),
	@mode			char(1) = '',     // ''=物流单据    'S'=销售单据
	@returnmode	char(1) = '',		// S
	@msg		varchar(60)	output
as
declare 	@ret		int,
			@id		char(6),
			@ii		int,
			@fid		int,
			@pccode	char(5),
			@site		char(5),
			@rsite	char(5),
			@code		char(8)

declare	@sfolio	varchar(20),
			@act_date	datetime,
			@bdate	datetime,
			@flag		char(2),
			@cby		char(10),
			@cdate	datetime,
			@number	money,
			@amount	money,
			@amount1	money,
			@disc		money,
			@profit	money,
			@gnumber	money,
			@gamount	money,
			@gamount1	money,
			@gprofit	money,
			@price0	money,
			@price1	money,
			@ref		varchar(20),
			@ls_charge char(1),
			@li_row	integer

select @ret=0, @msg=''
if (@mode='S' and exists(select 1 from bos_detail where folio=@folio and flag='售'))
	or (@mode='' and exists(select 1 from bos_detail where folio=@folio and flag<>'售'))
	begin
	select @ret=1, @msg='该单据已经记账 !'
	if @returnmode = 'S'
		select @ret, @msg
	return @ret
	end

delete bos_tmpdetail where modu_id=@modu_id and pc_id=@pc_id

begin tran
save tran t_input

// 销售单据 算成本
if @mode='S' 
	begin
	select @pccode=pccode,@site=site0 from bos_folio where foliono=@folio
	declare c_dish cursor for select id,code,number 
		from bos_dish where foliono=@folio and sta='I' order by id
	open c_dish 
	fetch c_dish into @ii, @code, @number
	while @@sqlstatus = 0
		begin
		select @price0=price0,@gnumber=number9,@gamount=amount9 from bos_store where pccode=@pccode and site=@site and code=@code
		if @@rowcount = 0	// 没有记录
			begin
			// 其他柜台是否有，取参考价
			if not exists(select 1 from bos_store where pccode=@pccode and code=@code and price0<>0) 
				begin
				select @ret=1, @msg='没有当前商品的成本记录 !'
				goto goutput1
				end
			else
				begin
				select @site=min(site) from bos_store where pccode=@pccode and code=@code and price0<>0
				select @price0=price0 from bos_store where pccode=@pccode and code=@code and site=@site
				select @amount = round(@number*@price0, 4)
				end
			end
		else
			begin
//			if @price0 = 0 
//				begin
//				select @ret=1, @msg='成本价=0 ! 请检查'
//				goto goutput1
//				end
			if @number=@gnumber		// 刚好售完，直接取成本金额
				select @amount=@gamount
			else
				select @amount=round(@number*@price0,4)
			end
		update bos_dish set amount0=@amount where foliono=@folio and id=@ii
		fetch c_dish into @ii, @code, @number
		end
	close c_dish
	deallocate cursor c_dish
	end

// 细帐建立
declare c_detail cursor for 
	select folio,sfolio,site,rsite,act_date,bdate,flag,cby,cdate,fid,code,number,amount,amount1,disc,profit,ref 
		from bos_tmpdetail where modu_id=@modu_id and pc_id=@pc_id order by act_date,folio,site,code,fid

if @mode='S'		// 销售单据
	begin
	insert bos_tmpdetail select @modu_id,@pc_id,a.foliono,a.sfoliono,a.site0,'',a.log_date,a.bdate,'售',
			a.empno2,a.log_date,b.id,b.code,b.number,b.amount0,b.fee,b.pfee_base-b.fee,b.pfee_base-b.amount0,''
		from bos_folio a, bos_dish b 
			where a.foliono=b.foliono and a.foliono=@folio and b.sta='I'
	select @pccode=pccode from bos_folio where foliono=@folio
	end
else					// 物流单据
	begin
	// 操作地点
	insert bos_tmpdetail select @modu_id,@pc_id,a.folio,a.sfolio,a.site0,a.site1,a.act_date,a.bdate,a.flag,
			a.cby,a.cdate,0,b.code,b.number,b.amount,b.amount1,0,b.profit,b.ref
		from bos_kcmenu a, bos_kcdish b 
			where a.folio=b.folio and a.folio=@folio

	// 相关地点
	insert bos_tmpdetail select @modu_id,@pc_id,a.folio,a.sfolio,a.site1,a.site0,a.act_date,a.bdate,a.flag,
			a.cby,a.cdate,0,b.code,-1*b.number,-1*b.amount,-1*b.amount1,0,-1*b.profit,b.ref
		from bos_kcmenu a, bos_kcdish b 
			where a.folio=b.folio and a.folio=@folio and a.site1<>''
	select @pccode=pccode from bos_kcmenu where folio=@folio
	end
				
// 帐务区间
select @id = min(id) from bos_store where pccode=@pccode
select @ls_charge = value from sysoption where catalog = 'house' and item = 'flr_roomno'

open c_detail
fetch c_detail into @folio,@sfolio,@site,@rsite,@act_date,@bdate,@flag,@cby,@cdate,@fid,@code,@number,@amount,@amount1,@disc,@profit,@ref
while @@sqlstatus = 0
	begin
	// --------------------------------------------------------------------
	// 更新 bos_store 
	// --------------------------------------------------------------------
	if not exists(select 1 from bos_store where pccode=@pccode and site = @site and code = @code)
		begin
		if not exists(select 1 from bos_site where pccode=@pccode and site=@site)
			begin
			if @ls_charge = 'T' 
				select @li_row = count(1) from flrcode where code = @site
			else 
				select @li_row = count(1) from rmsta where roomno = @site
			if @li_row < 0
			begin
				select @ret=1, @msg='地点错误 ! --- ' + @pccode+'/'+@site
				goto goutput
			end
		 end
			insert bos_store (id, pccode, site, code) select @id, @pccode, @site, @code
		end
	

	if @flag = '入'
		update bos_store set number1=number1+@number,amount1=amount1+@amount,sale1=sale1+@amount1,profit1=profit1+@profit,
			number9=number9+@number,amount9=amount9+@amount,sale9=sale9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site and code = @code
	else if @flag = '损'
		update bos_store set number2=number2+@number,amount2=amount2+@amount,sale2=sale2+@amount1,profit2=profit2+@profit,
			number9=number9-@number,amount9=amount9-@amount,sale9=sale9-@amount1,profit9=profit9-@profit where pccode=@pccode and site = @site and code = @code
	else if @flag = '盘'  
		update bos_store set number3=number3+@number,amount3=amount3+@amount,sale3=sale3+@amount1,profit3=profit3+@profit,
			number9=number9+@number,amount9=amount9+@amount,sale9=sale9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site and code = @code
	else if @flag = '调'  
		update bos_store set number4=number4+@number,amount4=amount4+@amount,sale4=sale4+@amount1,profit4=profit4+@profit,
			number9=number9+@number,amount9=amount9+@amount,sale9=sale9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site and code = @code
	else if @flag = '售'  
		update bos_store set number5=number5+@number,amount5=amount5+@amount,sale5=sale5+@amount1,profit5=profit5+@profit,disc=disc+@disc,
			number9=number9-@number,amount9=amount9-@amount,sale9=sale9-@amount1-@disc,profit9=profit9-@profit where pccode=@pccode and site = @site and code = @code
	else if @flag = '领'  
		update bos_store set number6=number6+@number,amount6=amount6+@amount,sale6=sale6+@amount1,profit6=profit6+@profit,
			number9=number9+@number,amount9=amount9+@amount,sale9=sale9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site and code = @code
	else if @flag = '内'  // 与当前库存数量不一定必须相等, amount 为调整的差额 !
		update bos_store set number7=number7+@number,amount7=amount7+@amount,sale7=sale7+@amount1,profit7=profit7+@profit,
			amount9=amount9+@amount,sale9=sale9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site and code = @code
	else if @flag = '外'  // 与当前库存数量不一定必须相等, amount 为调整的差额 !
		update bos_store set number8=number8+@number,amount8=amount8+@amount,sale8=sale8+@amount1,profit8=profit8+@profit,
			amount9=amount9+@amount,sale9=sale9+@amount1,profit9=profit9+@profit where pccode=@pccode and site = @site and code = @code
	else 
		begin
		select @ret=1, @msg='无效账单标志 !  --- ' + @flag
		goto goutput
		end

	// 数据检验
	if exists(select 1 from bos_store where pccode=@pccode and site = @site and code = @code and number9=0 and (amount9<>0 or sale9<>0 or profit9<>0) )
		begin
		select @ret=1, @msg='Str注意，该操作导致库存数=0，但有相应金额帐<>0，请检查 !'
		goto goutput
		end
	// 价格信息
	if exists(select 1 from bos_store where pccode=@pccode and site = @site and code = @code and number9<>0)
		begin
		update bos_store set price0 = round(amount9/number9,4) where pccode=@pccode and code=@code and site=@site
		update bos_store set price1 = round(sale9/number9,2) where pccode=@pccode and code=@code and site=@site
		end

	// --------------------------------------------------------------------
	// bos_detail 
	//	是否有上笔明细记录
	// --------------------------------------------------------------------
	select @ii = isnull(max(ii),0) from bos_detail where pccode=@pccode and code=@code and site=@site
	if @ii > 0
		select @gnumber=gnumber,@gamount=gamount0,@gamount1=gamount,@gprofit=gprofit,@price0=price0,@price1=price1
			from bos_detail where pccode=@pccode and code=@code and site=@site and ii=@ii
	else
		select @gnumber=0,@gamount=0,@gamount1=0,@gprofit=0,@price0=0,@price1=0
	select @ii = @ii + 1

	if @flag='入' or @flag='领' or @flag='盘' or @flag='调'  // 增加
		select @gnumber=@gnumber+@number,@gamount=@gamount+@amount,
			@gamount1=@gamount1+@amount1+@disc,@gprofit=@gprofit+@profit
	else if @flag='内' or @flag='外'
		select @gamount=@gamount+@amount,@gamount1=@gamount1+@amount1+@disc,@gprofit=@gprofit+@profit
	else if @flag='损' or @flag='售'		// 减少
		select @gnumber=@gnumber-@number,@gamount=@gamount-@amount,
			@gamount1=@gamount1-@amount1-@disc,@gprofit=@gprofit-@profit
	else
		begin
		select @ret=1, @msg='未知的物流单据类型 --- ' + @folio + '/' + @flag
		goto goutput
		end

	if @gnumber=0 and (@gamount<>0 or @gamount1<>0 or @gprofit<>0) // 检验数据
		begin
		select @ret=1, @msg='Dtl 注意，该操作导致库存数=0，但有相应的金额帐<>0，请检查 !'
		goto goutput
		end

	if @gnumber <> 0  // 重新计算价格
		select @price0=round(@gamount/@gnumber,4), @price1=round(@gamount1/@gnumber,2)
	insert bos_detail values(@pccode,@site,@code,@id,@ii,@flag,@ref,@folio,@sfolio,@fid,@rsite,@bdate,@act_date,@cdate,@cby,
			@number,@amount,@amount1,@disc,@profit,@gnumber,@gamount,@gamount1,@gprofit,@price0,@price1)

	// bos_plu 's 价格
	update bos_plu set price=@price1 where pccode=@pccode and code=@code

	fetch c_detail into @folio,@sfolio,@site,@rsite,@act_date,@bdate,@flag,@cby,@cdate,@fid,@code,@number,@amount,@amount1,@disc,@profit,@ref
	end

goutput:
close c_detail
deallocate cursor c_detail

goutput1:
if @ret <> 0 
	rollback tran t_input
commit tran

if @returnmode = 'S'
	select @ret, @msg
return @ret
;