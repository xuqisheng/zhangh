
// ------------------------------------------------------------------------------
//		重建库存明细账	
//
//			-------- 在执行该程序期间，不能做一切与物流、销售有关的操作 !!!
//			-------- rebuild from bos_store 's code
//			-------- 该重建不计算 bos_dish 成本
// ------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_gds_bos_reb_detail')
	drop proc p_gds_bos_reb_detail;
create proc  p_gds_bos_reb_detail
	@id			char(6),
	@pccode		char(5),
	@site			char(5),
	@code			char(8),
	@check		char(1) = ''   // ''=只重建bos_detail; 
										//	'C'=重建bos_detail, 并且与 bos_store 比较余额
										//	'U'=重建bos_detail, 并且更新 bos_store
as
declare 	@ret		int,
			@msg		varchar(60),
			@msite	char(5),
			@mcode	char(8),
			@ii		int,
			@fid		int,
			@idcur	char(6),
			@idup		char(6),
			@begin	datetime,
			@end		datetime

declare	@folio	char(10),
			@sfolio	varchar(20),
			@rsite	char(5),
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
			@ref		varchar(20)

select @ret=0, @msg=''
if @check is null select @check=''

// 帐务区间
select @idcur = min(id) from bos_store where pccode=@pccode
if @id='' or rtrim(@id) is null 
	select @id = @idcur
if not exists(select 1 from bos_kcdate where id<=@idcur and id=@id)
	begin
	select @ret=1, @msg='要求重建的帐务区间错误 --- %1^' + @id
	select @ret, @msg
	return @ret
	end
if not exists(select 1 from bos_hstore where id<@id)
	begin
	select @ret=1, @msg='系统初始化数据不能重建 --- %1^' + @id
	select @ret, @msg
	return @ret
	end
select @idup = isnull(max(id),'') from bos_kcdate where id<@id
select @begin=begin_, @end=end_ from bos_kcdate where id=@id

// 明细账来源 --- 物流单据 和 销售单据
create table #detail 
(
	folio		char(10)			not null,				// 电脑单号(日期+流水号)
	sfolio	varchar(20),								// 手工号码
	rsite		char(5)	default '' not null,  		// 相关地点
	act_date	datetime			not null,				// 业务发生日期
	bdate		datetime			not null,				// 营业日期
	flag		char(2)			not null,				// 主单类型: 入<出>库, 损耗, 冲销, 盘存, 调拨
	cby		char(10)			not null,				// 创建
	cdate		datetime	default getdate()	not null,
	fid		int				not null,				// 物流单据=0  销售单据=id
	code		char(8)			not null,				// 代码
	number	money	default 0 not null,				// 数量
	amount	money	default 0 not null,				// 成本金额
	amount1	money	default 0 not null,				// 销售金额
	disc		money	default 0 not null,				// 折扣
	profit	money	default 0 not null,				// 进销差价
	ref		varchar(20)		null						// 备注
)

begin tran
save tran t_reb

if @id = @idcur // 当前
	declare c_reb cursor for select code, site from bos_store 
		where (@site='' or site=@site) and (@code='' or code=@code)
		order by code, site
else				// 历史
	declare c_reb cursor for select code, site from bos_hstore
		where id=@id and (@site='' or site=@site) and (@code='' or code=@code)
		order by code, site
declare c_detail cursor for 
	select folio,sfolio,rsite,act_date,bdate,flag,cby,cdate,fid,number,amount,amount1,disc,profit,ref 
		from #detail order by act_date,folio,fid

open c_reb
fetch c_reb into @mcode, @msite
while @@sqlstatus = 0
	begin
	if @id = @idcur
		delete bos_detail where pccode=@pccode and site=@msite and code=@mcode
	else
		delete bos_hdetail where id=@id and pccode=@pccode and site=@msite and code=@mcode
	delete #detail
	
	// 搜集原始记录 -- 物流单据：原地点
	insert #detail select a.folio,a.sfolio,a.site1,a.act_date,a.bdate,a.flag,
			a.cby,a.cdate,0,b.code,b.number,b.amount,b.amount1,0,b.profit,b.ref
		from bos_kcmenu a, bos_kcdish b 
			where a.folio=b.folio and a.pccode=@pccode 
				and a.site0=@msite and b.code=@mcode and a.sta='O'
				and a.bdate>=@begin and a.bdate<=@end
	// 搜集原始记录 -- 物流单据：相关地点
	insert #detail select a.folio,a.sfolio,a.site0,a.act_date,a.bdate,a.flag,
			a.cby,a.cdate,0,b.code,-1*b.number,-1*b.amount,-1*b.amount1,0,-1*b.profit,b.ref
		from bos_kcmenu a, bos_kcdish b 
			where a.folio=b.folio and a.pccode=@pccode 
				and a.site1=@msite and b.code=@mcode and a.sta='O'
				and a.bdate>=@begin and a.bdate<=@end
	// 搜集原始记录 -- 销售单据(历史)
	insert #detail select a.foliono,a.sfoliono,'',a.log_date,a.bdate,'售',
			a.empno2,a.log_date,b.id,b.code,b.number,b.amount0,b.fee,b.pfee_base-b.fee,b.pfee_base-b.amount0,''
		from bos_hfolio a, bos_hdish b 
			where a.foliono=b.foliono and a.pccode=@pccode 
				and a.site0=@msite and b.code=@mcode and a.sta='O' and b.sta='I'
				and a.bdate1>=@begin and a.bdate1<=@end
	// 搜集原始记录 -- 销售单据(当前)
	insert #detail select a.foliono,a.sfoliono,'',a.log_date,a.bdate,'售',
			a.empno2,a.log_date,b.id,b.code,b.number,b.amount0,b.fee,b.pfee_base-b.fee,b.pfee_base-b.amount0,''
		from bos_folio a, bos_dish b 
			where a.foliono=b.foliono and a.pccode=@pccode 
				and a.site0=@msite and b.code=@mcode and a.sta='O' and b.sta='I'
				and a.bdate1>=@begin and a.bdate1<=@end
				
	select @ii = 1 

	if @check = 'U'
		begin
		if @id = @idcur 
			update bos_store set 
				number0=0,amount0=0,sale0=0,profit0=0,
				number1=0,amount1=0,sale1=0,profit1=0,
				number2=0,amount2=0,sale2=0,profit2=0,
				number3=0,amount3=0,sale3=0,profit3=0,
				number4=0,amount4=0,sale4=0,profit4=0,
				number5=0,amount5=0,sale5=0,profit5=0,disc=0,
				number6=0,amount6=0,sale6=0,profit6=0,
				number7=0,amount7=0,sale7=0,profit7=0,
				number8=0,amount8=0,sale8=0,profit8=0,
				number9=0,amount9=0,sale9=0,profit9=0,price0=0,price1=0
				where pccode=@pccode and code=@mcode and site=@msite
		else
			update bos_hstore set 
				number0=0,amount0=0,sale0=0,profit0=0,
				number1=0,amount1=0,sale1=0,profit1=0,
				number2=0,amount2=0,sale2=0,profit2=0,
				number3=0,amount3=0,sale3=0,profit3=0,
				number4=0,amount4=0,sale4=0,profit4=0,
				number5=0,amount5=0,sale5=0,profit5=0,disc=0,
				number6=0,amount6=0,sale6=0,profit6=0,
				number7=0,amount7=0,sale7=0,profit7=0,
				number8=0,amount8=0,sale8=0,profit8=0,
				number9=0,amount9=0,sale9=0,profit9=0,price0=0,price1=0
				where id=@id and pccode=@pccode and code=@mcode and site=@msite
		end

//-------------------------------------------------------------------------------
//	 bos_detail 's column-----> 
//			pccode,site,code,id,ii,flag,descript,folio,sfolio,fid,
//			rsite,bdate,act_date,log_date,empno,number,amount0,
//			amount,disc,profit,gnumber,gamount0,gamount,gprofit,rate0,rate
//-------------------------------------------------------------------------------

	// 是否有‘期初余额’ --- 不管是否数量=0
	if exists(select 1 from bos_hstore where id=@idup and pccode=@pccode and code=@mcode and site=@msite)
		begin
		select @gnumber=number9,@gamount=amount9,@gamount1=sale9,@gprofit=profit9,@price0=price0,@price1=price1
			from bos_hstore where id=@idup and pccode=@pccode and code=@mcode and site=@msite
		if @gnumber <> 0
			select @price0=round(@gamount/@gnumber,4),@price1=round(@gamount1/@gnumber,2)
		if @id = @idcur 
			insert bos_detail values(@pccode,@msite,@mcode,@id,@ii,'续','期初余额','','',0,'',@begin,@begin,@begin,'',
					@gnumber,@gamount,@gamount1,0,@gprofit,@gnumber,@gamount,@gamount1,@gprofit,@price0,@price1)
		else
			insert bos_hdetail values(@pccode,@msite,@mcode,@id,@ii,'续','期初余额','','',0,'',@begin,@begin,@begin,'',
					@gnumber,@gamount,@gamount1,0,@gprofit,@gnumber,@gamount,@gamount1,@gprofit,@price0,@price1)

		if @check='U'
			begin
			if @id = @idcur 
				update bos_store set number0=@gnumber,amount0=@gamount,sale0=@gamount1,profit0=@gprofit,price0=@price0,price1=@price1
					where pccode=@pccode and code=@mcode and site=@msite
			else
				update bos_hstore set number0=@gnumber,amount0=@gamount,sale0=@gamount1,profit0=@gprofit,price0=@price0,price1=@price1
					where id=@id and pccode=@pccode and code=@mcode and site=@msite
			end
		select @ii = @ii + 1
		end
	else
		select @gnumber=0,@gamount=0,@gamount1=0,@gprofit=0,@price0=0,@price1=0

	open c_detail
	fetch c_detail into @folio,@sfolio,@rsite,@act_date,@bdate,@flag,@cby,@cdate,@fid,@number,@amount,@amount1,@disc,@profit,@ref
	while @@sqlstatus = 0
		begin
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
			select @ret=1, @msg='未知的物流单据类型 --- %1^' + @folio + '/' + @flag
			close c_detail
			goto goutput
			end

		if @check='U'
			begin
			if @id = @idcur 
				begin
				if @flag='入'
					update bos_store set number1=number1+@number,amount1=amount1+@amount,
							sale1=sale1+@amount1,profit1=profit1+@profit where pccode=@pccode and code=@mcode and site=@msite
				else if @flag='损'
					update bos_store set number2=number2+@number,amount2=amount2+@amount,
							sale2=sale2+@amount1,profit2=profit2+@profit where pccode=@pccode and code=@mcode and site=@msite
				else if @flag='盘'
					update bos_store set number3=number3+@number,amount3=amount3+@amount,
							sale3=sale3+@amount1,profit3=profit3+@profit where pccode=@pccode and code=@mcode and site=@msite
				else if @flag='调'
					update bos_store set number4=number4+@number,amount4=amount4+@amount,
							sale4=sale4+@amount1,profit4=profit4+@profit where pccode=@pccode and code=@mcode and site=@msite
				else if @flag='售'
					update bos_store set number5=number5+@number,amount5=amount5+@amount,disc=disc+@disc,
							sale5=sale5+@amount1,profit5=profit5+@profit where pccode=@pccode and code=@mcode and site=@msite
				else if @flag='领'
					update bos_store set number6=number6+@number,amount6=amount6+@amount,
							sale6=sale6+@amount1,profit6=profit6+@profit where pccode=@pccode and code=@mcode and site=@msite
				else if @flag='内'
					update bos_store set number7=number7+@number,amount7=amount7+@amount,
							sale7=sale7+@amount1,profit7=profit7+@profit where pccode=@pccode and code=@mcode and site=@msite
				else if @flag='外'
					update bos_store set number8=number8+@number,amount8=amount8+@amount,
							sale8=sale8+@amount1,profit8=profit8+@profit where pccode=@pccode and code=@mcode and site=@msite
				end
			else
				begin
				if @flag='入'
					update bos_hstore set number1=number1+@number,amount1=amount1+@amount,
							sale1=sale1+@amount1,profit1=profit1+@profit where pccode=@pccode and code=@mcode and site=@msite and id=@id
				else if @flag='损'
					update bos_hstore set number2=number2+@number,amount2=amount2+@amount,
							sale2=sale2+@amount1,profit2=profit2+@profit where pccode=@pccode and code=@mcode and site=@msite and id=@id
				else if @flag='盘'
					update bos_hstore set number3=number3+@number,amount3=amount3+@amount,
							sale3=sale3+@amount1,profit3=profit3+@profit where pccode=@pccode and code=@mcode and site=@msite and id=@id
				else if @flag='调'
					update bos_hstore set number4=number4+@number,amount4=amount4+@amount,
							sale4=sale4+@amount1,profit4=profit4+@profit where pccode=@pccode and code=@mcode and site=@msite and id=@id
				else if @flag='售'
					update bos_hstore set number5=number5+@number,amount5=amount5+@amount,disc=disc+@disc,
							sale5=sale5+@amount1,profit5=profit5+@profit where pccode=@pccode and code=@mcode and site=@msite and id=@id
				else if @flag='领'
					update bos_hstore set number6=number6+@number,amount6=amount6+@amount,
							sale6=sale6+@amount1,profit6=profit6+@profit where pccode=@pccode and code=@mcode and site=@msite and id=@id
				else if @flag='内'
					update bos_hstore set number7=number7+@number,amount7=amount7+@amount,
							sale7=sale7+@amount1,profit7=profit7+@profit where pccode=@pccode and code=@mcode and site=@msite and id=@id
				else if @flag='外'
					update bos_hstore set number8=number8+@number,amount8=amount8+@amount,
							sale8=sale8+@amount1,profit8=profit8+@profit where pccode=@pccode and code=@mcode and site=@msite and id=@id
				end
			end

		if @gnumber <> 0  // 重新计算价格
			select @price0=round(@gamount/@gnumber,4), @price1=round(@gamount1/@gnumber,2)
		
		if @id = @idcur 
			insert bos_detail values(@pccode,@msite,@mcode,@id,@ii,@flag,@ref,@folio,@sfolio,@fid,@rsite,@bdate,@act_date,@cdate,@cby,
					@number,@amount,@amount1,@disc,@profit,@gnumber,@gamount,@gamount1,@gprofit,@price0,@price1)
		else
			insert bos_hdetail values(@pccode,@msite,@mcode,@id,@ii,@flag,@ref,@folio,@sfolio,@fid,@rsite,@bdate,@act_date,@cdate,@cby,
					@number,@amount,@amount1,@disc,@profit,@gnumber,@gamount,@gamount1,@gprofit,@price0,@price1)
		select @ii = @ii + 1

		fetch c_detail into @folio,@sfolio,@rsite,@act_date,@bdate,@flag,@cby,@cdate,@fid,@number,@amount,@amount1,@disc,@profit,@ref
		end
	close c_detail

	if @gnumber=0 and (@gamount<>0 or @gamount1<>0 or @gprofit<>0)
		begin
		select @ret=1, @msg='该细帐数量=0，但是金额非零，请检查 --- %1^' + @msite + '/' + @mcode
		goto goutput
		end

	// 与当前的 bos_store 比较
	if @check='C' and ((@id=@idcur and exists(select 1 from bos_store where pccode=@pccode and code=@mcode and site=@msite and (number9<>@gnumber or amount9<>@gamount or sale9<>@gamount1 or profit9<>@gprofit)))
							or (@id<>@idcur and exists(select 1 from bos_hstore where id=@id and pccode=@pccode and code=@mcode and site=@msite and (number9<>@gnumber or amount9<>@gamount or sale9<>@gamount1 or profit9<>@gprofit))))
		begin
		select @ret=1, @msg='细账与库存记录不对应 --- %1^' + @msite + '/' + @mcode
		goto goutput
		end
	// 更新 bos_store
	else if @check = 'U'
		begin
		if @id = @idcur 
			begin
			update bos_store set number9=@gnumber where pccode=@pccode and code=@mcode and site=@msite
			update bos_store set amount9=@gamount where pccode=@pccode and code=@mcode and site=@msite
			update bos_store set sale9  =@gamount1 where pccode=@pccode and code=@mcode and site=@msite
			update bos_store set profit9=@gprofit where pccode=@pccode and code=@mcode and site=@msite
			update bos_store set price0 =@price0 where pccode=@pccode and code=@mcode and site=@msite
			update bos_store set price1 =@price1 where pccode=@pccode and code=@mcode and site=@msite
			end
		else
			begin
			update bos_hstore set number9=@gnumber where pccode=@pccode and code=@mcode and site=@msite and id=@id
			update bos_hstore set amount9=@gamount where pccode=@pccode and code=@mcode and site=@msite and id=@id
			update bos_hstore set sale9  =@gamount1 where pccode=@pccode and code=@mcode and site=@msite and id=@id
			update bos_hstore set profit9=@gprofit where pccode=@pccode and code=@mcode and site=@msite and id=@id
			update bos_hstore set price0 =@price0 where pccode=@pccode and code=@mcode and site=@msite and id=@id
			update bos_hstore set price1 =@price1 where pccode=@pccode and code=@mcode and site=@msite and id=@id
			end
		end

	fetch c_reb into @mcode, @msite
	end
close c_reb

goutput:
deallocate cursor c_reb
deallocate cursor c_detail

if @ret <> 0 
	rollback tran t_reb
commit tran

select @ret, @msg
return @ret
;
