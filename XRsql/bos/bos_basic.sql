
-- --------------------------------------------------------------------------
--
--	本SQL含 BOS 操作基本存储过程 
--	
--	p_gds_bos_unchk_folio				当前未结帐单显示 
--	
--	p_gds_bos_retrieve_bill				检索结帐单:包括借方及贷方 
--	p_gds_bos_retrieve_charge			检索一笔待结帐供修改或结帐或查询 
--	p_gds_bos_cancel_charge				冲消未结费用 
--	
--	p_gds_bos_input_dish
--	p_gds_bos_input_charge_etc
--	p_gds_bos_mark_charge				结帐步骤之一:给待结费用加站点标志 
--	p_gds_bos_input_credit
--	p_gds_bos_settlement
--	p_gds_bos_co							结帐冲销
--
--	p_gds_bos_init							初始化程序
-- --------------------------------------------------------------------------

//insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center)
//	values('bosfolio_sta','M','未结','Un-CO','T','F',100,'','F' );
//insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center)
//	values('bosfolio_sta','P','电话','Phone','T','F',200,'','F' );
//insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center)
//	values('bosfolio_sta','O','结帐','Chk.Out','T','F',300,'','F' );
//insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center)
//	values('bosfolio_sta','C','冲账','Deleted','T','F',400,'','F' );
//insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center)
//	values('bosfolio_sta','T','补单','L-added','T','F',500,'','F' );
//insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center)
//	values('bosfolio_sta','X','销单','Cancel','T','F',600,'','F' );



-- --------------------------------------------------------------------------
-- 考虑服务费可以不优惠
-- --------------------------------------------------------------------------
if not exists(select 1 from sysoption where catalog = 'bos' and item = 'p_mode')
	insert sysoption(catalog, item, value) select 'bos', 'p_mode', 'T';

-- --------------------------------------------------------------------------
--	检索结帐单:包括借方及贷方 
-- --------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_bos_retrieve_bill" and type = "P")
   drop proc p_gds_bos_retrieve_bill;
create proc  p_gds_bos_retrieve_bill
	@posno	 char(2), 
   @shift    char(1), 
   @empno    char(10), 
   @setnumb  char(10),  -- 状态
   @dategap  int
as
declare
   @bdate    datetime

select @setnumb = rtrim(@setnumb)
select @bdate = dateadd(day, @dategap, bdate1) from sysdata

if @dategap = 0
   select setnumb, shift1, empno1, log_date, pccode + ' ', pccode + ' ', name, fee, 0, foliono + space(3), sfoliono + ' - ' + site
		  from bos_folio where posno = @posno
							 and (rtrim(@shift) is null or shift2 = @shift or shift1 = @shift)
							 and (rtrim(@empno) is null or empno2 = @empno or empno1 = @empno)
							 and (@setnumb is null or sta = @setnumb)
   union
   select a.setnumb, a.shift, a.empno, a.log_date, a.code, a.code1, a.name, 0, a.amount, a.room + '-' + a.accnt, b.sfoliono + ' - ' + b.site
	      from bos_account a, bos_folio b where b.posno = @posno
							 and (rtrim(@shift) is null or b.shift1 = @shift or b.shift2 = @shift)
							 and (rtrim(@empno) is null or b.empno1 = @empno or b.empno2 = @empno)
							 and (a.setnumb = b.setnumb)
							 and (@setnumb is null or b.sta = @setnumb)
else
   select setnumb, shift1, empno1, log_date, pccode + ' ', pccode + ' ', name, fee, 0, foliono + space(3), sfoliono + ' - ' + site
	      from bos_hfolio where posno = @posno
							 and (rtrim(@shift) is null or shift2 = @shift or shift1 = @shift)
							 and (rtrim(@empno) is null or empno2 = @empno or empno1 = @empno) 
							 and (bdate1 = @bdate)
							 and (@setnumb is null or sta = @setnumb)
   union
   select a.setnumb, a.shift, a.empno, a.log_date, a.code, a.code1, a.name, 0, a.amount, a.room + '-' + a.accnt, b.sfoliono + ' - ' + b.site
	      from bos_haccount a, bos_hfolio b where b.posno = @posno
							 and (rtrim(@shift) is null or b.shift1 = @shift or b.shift2 = @shift)
							 and (rtrim(@empno) is null or b.empno1 = @empno or b.empno2 = @empno)
							 and (a.setnumb = b.setnumb)
							 and (b.bdate1 = @bdate)
							 and (@setnumb is null or b.sta = @setnumb)
return 0
;

-- --------------------------------------------------------------------------
--		检索一笔待结帐供修改或结帐或查询 
-- --------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_bos_retrieve_charge" and type = "P")
   drop proc p_gds_bos_retrieve_charge;
create proc p_gds_bos_retrieve_charge
   @pc_id    char(4), 
   @foliono  char(10), 
   @viewmark char(1)

as

declare
   @ret      int, 
   @msg      varchar(60), 
   @sta      char(1), 
   @checkout char(4), 
   @c_h      char(1)

select @ret = 0, @msg = ""
begin tran
save  tran p_gds_bos_retrieve_charge_s1
select @sta = sta, @checkout = checkout from bos_folio holdlock where foliono = @foliono
if @@rowcount = 0 
   begin
   if @viewmark = 'V' 
      begin
      select @sta = sta, @checkout = checkout from bos_hfolio holdlock where foliono = @foliono
      if @@rowcount = 0
         select @ret = 1, @msg = "不存在费用流水号%1^" + @foliono
      else
         select @c_h = 'H'
      end 
   else
      select @ret = 1, @msg = "不存在费用流水号%1^" + @foliono
   end 
else
   select @c_h = 'C'

if @ret = 0 and @viewmark <> 'V'
   begin 
   if @sta = 'O'
      select @ret = 1, @msg = "本费用已结, 不能再修改或结帐"
   else if charindex(@sta, 'cC') > 0 
      select @ret = 1, @msg = "对冲费用不能再修改, 也无需结帐"
   else if @checkout is not null and @checkout <> @pc_id
	  select @ret = 1, @msg = " BOS%1站点正在结单子%2^" +  @checkout + '^' + @foliono
   end 
if @ret = 0
   begin
   if @c_h = 'C'
      select @ret, @msg, fee_base, fee_serve, pfee_base, pfee_serve, pccode, rate = disc_value, reason, refer from bos_folio where foliono = @foliono
   else
      select @ret, @msg, fee_base, fee_serve, pfee_base, pfee_serve, pccode, rate = disc_value, reason, refer from bos_hfolio where foliono = @foliono
   end 
else
   select @ret, @msg, 0, 0, 0, 0, 0, 0, '', ''
commit tran
return @ret
;

-- --------------------------------------------------------------------------
--	冲消未结费用 --- 不再产生新单，直接修改状态
--			------  销单
-- --------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_bos_cancel_charge" and type = "P")
   drop proc p_gds_bos_cancel_charge;
create proc p_gds_bos_cancel_charge
   @pc_id    char(4), 
   @shift    char(1), 
   @empno    char(10), 
   @foliono  char(10)

as

declare
   @ret      int, 
   @msg      varchar(60), 
   @nfoliono char(10), 
   @sta      char(1), 
   @checkout char(4), 
   @bdate    datetime

select @ret = 0, @msg = ""
select @bdate = bdate1 from sysdata
select * into #tmpbos_folio from bos_folio where foliono = @foliono
begin tran
save  tran p_gds_bos_cancel_charge_s1
select @sta = sta, @checkout = checkout from bos_folio holdlock where foliono = @foliono
if @@rowcount = 0
   select @ret = 1, @msg = "不存在费用流水号--- > %1^" + @foliono
else if @sta = 'O'
   select @ret = 1, @msg = "本费用已经结账"
else if charindex(@sta, 'C') > 0
   select @ret = 1, @msg = "本费用已经被冲账"
else if charindex(@sta, 'X') > 0
   select @ret = 1, @msg = "本费用已经被销单"
else if @checkout is not null and @checkout <> @pc_id
   select @ret = 1, @msg = " BOS%1站点正在结这笔帐^" + @checkout
if @ret = 0
   begin 
	   update bos_folio  set sta = 'X', shift2 = @shift, empno2 = @empno, bdate1 = @bdate  
	                   where foliono = @foliono
		if @@rowcount = 0
			select @ret = 1, @msg = '销单失败 !'
   end
if @ret <> 0          
   rollback tran p_gds_bos_cancel_charge_s1
commit tran
select @ret, @msg 
return @ret
;


-- --------------------------------------------------------------------------
--	BOS 明细账目输入 
--			这种情况下，bos_folio 的优惠，服务，附加费等全部按实际金额方法计算
-- --------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_bos_input_dish" and type = "P")
   drop proc p_gds_bos_input_dish;
create proc p_gds_bos_input_dish
   @modu_id  char(2), 
   @pc_id    char(4), 
   @foliono  char(10)  output, 
   @sfoliono char(10), 
   @site     char(5), 
   @pccode   varchar(10), 			-- 参数 pccode : 增加参数销售柜台 5 + 5 
   @mode   	 char(1), 
	@reason	 char(3), 
   @empno    char(10), 
	@shift	 char(1), 
   @returnmode  char(1) = 'S',    -- 返回模式
	@refer		varchar(40)='' 
as

declare 
   @ret      int, 
   @msg      varchar(60), 
	@bdate	 datetime, 
	@dinput	 datetime, 
   @name	    char(24), 
	@posno	 char(2), 
	@id		 int, 
	@sta		 char(1), 
	@checkout char(4), 
	@site0	 char(5), 
	@gsite	 char(5), 		-- 实际销售的柜台
	@chgcod		char(5), 
	@count	int,
	@flag 		char(10)		-- 计算模式

select @ret = 0, @msg =  "", @dinput = getdate()
select @bdate = bdate1 from sysdata 

select @gsite = rtrim(substring(@pccode, 6, 5))
select @pccode = substring(@pccode, 1, 5)
exec @ret = p_gds_bos_pccode_check @pccode, 'R', @site0 output, @chgcod output, @name output, @msg output
if @ret <> 0
begin
	if @returnmode = 'S'
		select @ret, @msg
	return @ret
end

select @flag = flag from bos_pccode where pccode=@pccode 
if @@rowcount=0 or @flag is null	select @flag = '00'

if rtrim(@gsite) is null   -- 2004.5.21 gds in Kem
	select @gsite = @site0
select @posno = b.posno from bos_station a, bos_posdef b where a.posno = b.posno and a.netaddress = @pc_id and b.modu = @modu_id
if @@rowcount = 0
begin
	select @count = count(1) from bos_posdef where modu = @modu_id and def = 'T'
	if @count = 1
		select @posno = posno from bos_posdef where modu = @modu_id and def = 'T'
	else
	begin
		select @ret = 1, @msg = "收银点计算错误 !" + @modu_id
		if @returnmode = 'S'
			select @ret, @msg
		return @ret
	end
end
select @reason = ltrim(rtrim(@reason))
if @reason is null
	select @reason = ''
if @reason <> '' and not exists(select 1 from reason where code = @reason and p04 > 0)
begin
   select @ret = 1, @msg = "优惠理由输入错误 !"
	if @returnmode = 'S'
		select @ret, @msg
	return @ret
end
if not exists(select 1 from bos_site where pccode = @pccode and site = @gsite)
begin
   select @ret = 1, @msg = "地点码错误 !"
	if @returnmode = 'S'
		select @ret, @msg
	return @ret
end

begin tran 
save tran sss

-- 产生新单
if @foliono = "<new!>" 
begin
	exec @ret = p_GetAccnt1 'BUS', @foliono output
	if @ret <> 0
   	select @msg = "费用流水号生成出错, 请与电脑房联系!"
	else
	begin
		insert bos_folio(log_date, bdate, foliono, sfoliono, sta, modu, pccode, name, posno, mode, empno1, shift1, serve_type, tax_type, disc_type, reason, site0, chgcod)
			values(@dinput, @bdate, @foliono, @sfoliono, 'M', @modu_id, @pccode, @name, @posno, @mode, @empno, @shift, '1', '1', '1', @reason, @gsite, @chgcod)
		if @@rowcount = 0
			select @msg = "folio 插入错误!"
	end
end
else
begin
   select @sta = sta, @checkout = checkout from bos_folio holdlock where foliono = @foliono
   if @@rowcount = 0
      select @ret = 1, @msg = "不存在费用流水号%1^" + @foliono
   else if @sta = 'O'
      select @ret = 1, @msg = "本费用已结"
   else if charindex(@sta, 'cC') > 0 
      select @ret = 1, @msg = "本费用已冲"
   else if @checkout is not null and @checkout <> @pc_id
      select @ret = 1, @msg = " BOS%1站点正在结单子%2^" + @checkout + '^' + @foliono
end

if @ret <> 0 
	goto gout

if not exists(select 1 from bos_tmpdish where modu_id = @modu_id and pc_id = @pc_id)
begin	-- 没有明细
	update bos_folio set bdate = @bdate, empno1 = @empno, shift1 = @shift, site = @site, 
			sfoliono = @sfoliono, mode = @mode, reason = @reason, refer = @refer where foliono = @foliono
	if @@rowcount = 0
		select @ret = 1, @msg = '更新失败 !'
end
else
begin
	-- 插入纪录
	delete bos_dish where foliono = @foliono 
		and id in (select id from bos_tmpdish where modu_id = @modu_id and pc_id = @pc_id)
	insert bos_dish(log_date, foliono, pccode, id, sta, bdate, code, name, price, number, unit, serve_type,   
				serve_value, tax_type, tax_value, disc_type, disc_value, empno1, shift1)
		select @dinput, @foliono, @pccode, id, sta, @bdate, code, name, price, number, unit, serve_type,   
				serve_value, tax_type, tax_value, disc_type, disc_value, @empno, @shift
		from bos_tmpdish where modu_id = @modu_id and pc_id = @pc_id
	if @@rowcount = 0
	begin
		select @ret = 1, @msg = 'Insert bos_dish error !'
		goto gout
	end
	
	if exists(select 1 from bos_dish where foliono = @foliono and disc_value<> 0) and @reason = '' 
	begin
		select @ret = 1, @msg = '请输入优惠理由 !'
		goto gout
	end
	
	-- 重新计算
	update bos_dish set pfee_base = round(number*price, 2) where foliono = @foliono
	update bos_dish set pfee_tax = round(pfee_base*tax_value, 2) where foliono = @foliono and tax_type = '0'
	update bos_dish set pfee_tax = tax_value where foliono = @foliono and tax_type = '1'

	if substring(@flag,1,1)='0'
		update bos_dish set pfee_serve = round(pfee_base*serve_value, 2) where foliono = @foliono and serve_type = '0'
	else if substring(@flag,1,1)='1'
		update bos_dish set pfee_serve = round((pfee_base + pfee_tax)*serve_value, 2) where foliono = @foliono and serve_type = '0'
	else
		update bos_dish set pfee_serve = round(pfee_base*serve_value, 2) where foliono = @foliono and serve_type = '0'

	update bos_dish set pfee_serve = serve_value where foliono = @foliono and serve_type = '1'
	update bos_dish set pfee = pfee_base + pfee_serve + pfee_tax where foliono = @foliono
	
	update bos_dish set fee_base = pfee_base, fee_serve = pfee_serve, fee_tax = pfee_tax where foliono = @foliono

	if substring(@flag,2,1)='0'
		update bos_dish set fee_disc = round(fee_base*disc_value, 2) where foliono = @foliono and disc_type = '0'
	else if substring(@flag,2,1)='1'
		update bos_dish set fee_disc = round((fee_base + pfee_tax)*disc_value, 2) where foliono = @foliono and disc_type = '0'
	else
		update bos_dish set fee_disc = round(fee_base*disc_value, 2) where foliono = @foliono and disc_type = '0'

	update bos_dish set fee_disc = disc_value where foliono = @foliono and disc_type = '1'
	update bos_dish set fee = fee_base + fee_serve + fee_tax-fee_disc where foliono = @foliono
	
	update bos_folio set fee = (select sum(fee) from bos_dish where foliono = @foliono) where foliono = @foliono
	update bos_folio set fee_base = (select sum(fee_base) from bos_dish where foliono = @foliono) where foliono = @foliono
	update bos_folio set fee_serve = (select sum(fee_serve) from bos_dish where foliono = @foliono) where foliono = @foliono
	update bos_folio set fee_tax = (select sum(fee_tax) from bos_dish where foliono = @foliono) where foliono = @foliono
	update bos_folio set fee_disc = (select sum(fee_disc) from bos_dish where foliono = @foliono) where foliono = @foliono
	update bos_folio set pfee = (select sum(pfee) from bos_dish where foliono = @foliono) where foliono = @foliono
	update bos_folio set pfee_base = (select sum(pfee_base) from bos_dish where foliono = @foliono) where foliono = @foliono
	update bos_folio set pfee_serve = (select sum(pfee_serve) from bos_dish where foliono = @foliono) where foliono = @foliono
	update bos_folio set pfee_tax = (select sum(pfee_tax) from bos_dish where foliono = @foliono) where foliono = @foliono
	--update bos_folio set serve_value = (select sum(serve_value) from bos_dish where foliono = @foliono) where foliono = @foliono
	--update bos_folio set tax_value = (select sum(tax_value) from bos_dish where foliono = @foliono) where foliono = @foliono
	--update bos_folio set disc_value = (select sum(disc_value) from bos_dish where foliono = @foliono) where foliono = @foliono
	update bos_folio set serve_value = (select sum(fee_serve) from bos_dish where foliono = @foliono) where foliono = @foliono
	update bos_folio set tax_value = (select sum(fee_tax) from bos_dish where foliono = @foliono) where foliono = @foliono
	update bos_folio set disc_value = (select sum(fee_disc) from bos_dish where foliono = @foliono) where foliono = @foliono
	update bos_folio set sfoliono = @sfoliono, bdate = @bdate, empno1 = @empno, shift1 = @shift, site = @site, mode = @mode, reason = @reason, refer = @refer where foliono = @foliono
end

if not exists(select 1 from bos_dish where foliono = @foliono)
	select @ret = 1, @msg = '没有任何明细纪录'

gout:
if @ret <> 0 
	rollback tran sss
else
	select @msg = @foliono
commit

if @returnmode = 'S'
	select @ret, @msg
else
	select @foliono = substring(@msg, 1, 10)
return @ret
;

-- --------------------------------------------------------------------------
--	费用录入, 如还输入付款方式, 则要记录款项同时结帐
--   整个操作作为一个事务处理?
--
--	2001/12/07 -- 参数 pccode: 2- > 7  增加参数 site0
-- --------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_bos_input_charge_etc" and type = "P")
   drop proc p_gds_bos_input_charge_etc;
create proc     p_gds_bos_input_charge_etc
   @modu_id	    char(2), 
   @pc_id		 char(4), 
   @shift		 char(1), 
   @empno		 char(10), 
   @foliono	    char(10),   		--流水号
   @sfoliono	 char(10),   		--流水号
   @pccode		 varchar(10), 	 	--费用码 + site<柜台 >  
   @posno	 	 char(2), 	 
	@site			 char(5), 
	@mode			 char(3), 
   @initsta     char(1),    	--插入状态('P'由IDDCALL插入, 'M'由人工输入)
   @pfee_base	 money, 			--原基本费
   @serve_type	 char(1), 		--服务费定义
   @serve_value money, 		
   @tax_type	 char(1), 		--附加费定义
   @tax_value   money, 		
   @disc_type	 char(1), 		--折扣定义
   @disc_value  money, 		
	@reason		 char(3), 		--优惠原因
   @refer		 varchar(40), 	--备注
   @opmode      char(1),    	--M for modify, otherwise for Add 
   @paymth      char(3),    	--付款方式    
   @payreason	 char(2), 	 	--理由
   @accnt       char(10),    	--转帐帐号
   @room        char(5),    	--转帐房号
   @returnmode  char(1),    	--返回模式
   @msg         varchar(60) output
as
declare 
	@fee			money,   --费用总额
	@fee_base	money, 	--基本费
	@fee_serve	money, 	--服务费
	@fee_tax  	money, 	--附加费
	@fee_disc 	money, 	--折扣费

	@pfee		   money,   --原费用总额
	@pfee_serve	money, 	--原服务费
	@pfee_tax 	money 	--原附加费

declare
   @ret	        int, 
   @bdate	    datetime, 		--营业日期
   @name	   	 char(24), 		--费用码描述
   @name1       char(12), 		--付款描述
   @modu        char(2), 
   @code        char(3), 		--付款码
   @amount      money, 
   @setnumb     char(10), 
   @sta         char(1), 
   @package     char(3), 
   @checkout    char(4), 
	@p_mode		char(1), 
	@site0		char(5), 		-- 柜台
	@gsite	 char(5), 		-- 实际销售的柜台
	@chgcod		char(5),
	@flag			varchar(10)		-- 计算模式

select @paymth = null -- gds - 现在只输入费用

-- 计算模式  -- 以后要建立专门的模式表
select @p_mode = rtrim(value) from sysoption where catalog = 'bos' and item = 'p_mode'
if @@rowcount <> 1 
	insert sysoption(catalog, item, value) select 'bos', 'p_mode', 'T'
else if @p_mode = null or charindex(@p_mode, 'TtFf')< = 0
	update sysoption set value = 'T' where catalog = 'bos' and item = 'p_mode'

select @ret = 0, @msg = ""
select @bdate = bdate1 from sysdata

select @gsite = rtrim(substring(@pccode, 6, 5))
select @pccode = substring(@pccode, 1, 5)

exec @ret = p_gds_bos_pccode_check @pccode, 'R', @site0 output, @chgcod output, @name output, @msg output
if @ret = 0 
	if not exists(select 1 from bos_site where pccode = @pccode and site = @gsite)
   	select @ret = 1, @msg = "地点码错误, 请与电脑房联系!"
if @ret <> 0
   begin
   if @returnmode = 'S'
	   select @ret, @msg
   return @ret
   end

select @flag = flag from bos_pccode where pccode=@pccode 
if @@rowcount=0 or @flag is null	select @flag = '00'

begin tran
save  tran p_gds_bos_input_charge_etc_s1

-- 计算
-- tax
if @tax_type = '0' 
	select @fee_tax = round(@pfee_base * @tax_value, 2)
else
	select @fee_tax = @tax_value
select @pfee_tax = @fee_tax
-- srv
if @serve_type = '0' 
begin
	if substring(@flag,1,1)='0'
		select @fee_serve = round(@pfee_base * @serve_value, 2)
	else if substring(@flag,1,1)='1'
		select @fee_serve = round((@pfee_base + @pfee_tax) * @serve_value, 2)
	else
		select @fee_serve = round(@pfee_base * @serve_value, 2)
end
else
	select @fee_serve = @serve_value
select @pfee_serve = @fee_serve
-- disc
if @disc_type = '0' 
begin
	if substring(@flag,2,1)='0'
		select @fee_disc = round(@pfee_base * @disc_value, 2)
	else if substring(@flag,2,1)='1'
		select @fee_disc = round((@pfee_base + @pfee_tax) * @disc_value, 2)
	else
		select @fee_disc = round(@pfee_base * @disc_value, 2)
end
else
	select @fee_disc = @disc_value
-- fee
select @fee_base = @pfee_base
select @pfee = @pfee_base + @pfee_serve + @pfee_tax
select @fee = @fee_base + @fee_serve + @fee_tax - @fee_disc

if charindex(@opmode, 'mM') = 0
	-- 新增
   begin  
   exec @ret = p_GetAccnt1 'BUS', @foliono output
   if @ret <> 0
	   select @msg = " BOS 费用流水号生成出错, 请与电脑房联系!"
   else   
	   begin
	   insert bos_folio(sfoliono, log_date, bdate, foliono, site, mode, modu, pccode, name, empno1, shift1, 
					 fee, fee_base, fee_serve, fee_tax, fee_disc, 
					 pfee, pfee_base, pfee_serve, pfee_tax, 
					 serve_type, serve_value, tax_type, tax_value, disc_type, disc_value, 
					 reason, refer, sta, posno, site0, chgcod)
			  values(@sfoliono, getdate(), @bdate, @foliono, @site, @mode, @modu_id, @pccode, @name, @empno, @shift, 
					 @fee, @fee_base, @fee_serve, @fee_tax, @fee_disc, 
					 @pfee, @pfee_base, @pfee_serve, @pfee_tax, 
					 @serve_type, @serve_value, @tax_type, @tax_value, @disc_type, @disc_value, 
					 @reason, @refer, @initsta, @posno, @gsite, @chgcod)
	   if @@rowcount = 0
		   select @ret = 1, @msg = "费用输入存盘失败, 请与电脑房联系!"
	   end
   end 
else
	-- 修改
   begin
   select @sta = sta, @checkout = checkout from bos_folio holdlock where foliono = @foliono
   if @@rowcount = 0
      select @ret = 1, @msg = "不存在费用流水号%1^" + @foliono
   else if @sta = 'O'
      select @ret = 1, @msg = "本费用已结"
   else if charindex(@sta, 'cC') > 0 
      select @ret = 1, @msg = "本费用已冲"
   else if @checkout is not null and @checkout <> @pc_id
      select @ret = 1, @msg = " BOS%1站点正在结单子%2^" + @checkout + '^' + @foliono
   if @ret = 0
	   begin
	   update bos_folio   set
				bdate = @bdate, pccode = @pccode, name = @name, empno1 = @empno, shift1 = @shift, 
				sfoliono = @sfoliono, site = @site, mode = @mode, modu = @modu_id, chgcod = @chgcod, 
				fee = @fee, fee_base = @fee_base, fee_serve = @fee_serve, fee_tax = @fee_tax, fee_disc = @fee_disc, 
				pfee = @pfee, pfee_base = @pfee_base, pfee_serve = @pfee_serve, pfee_tax = @pfee_tax, 
				serve_type = @serve_type, serve_value = @serve_value, 
				tax_type = @tax_type, tax_value = @tax_value, 
				disc_type = @disc_type, disc_value = @disc_value, 
				reason = @reason, refer = @refer
         where foliono = @foliono 
      if @@rowcount = 0
	      select @ret = 1, @msg = "费用修改存盘失败, 请与电脑房联系!"
      end 
   end

if @ret = 0 and rtrim(@paymth) is not null  --处理付款
   begin
--   select @name1 = descript, @code = pccode from pccode where descript1 = @paymth and @paymth ! =  "TOG"	--在PB端应变TOG到TOA
   	select @name1 = descript, @code = pccode from pccode where pccode = @paymth

--   if @@rowcount = 0
--      select @ret = 1, @msg = "系统中还未设置付款方式" + @paymth
--   else
--	   begin
--	   select @amount = round(@pfee_base * @vrate, 2) + round(@pfee_serve * @pvrate, 2)
--	   exec @ret = p_GetAccnt1 'BST', @setnumb output
--	   if @ret <> 0
--		   select @msg = " BOS 结帐流水号生成出错, 请与电脑房联系!"
--	   if @ret = 0 and @paymth in ("TOA", "TOR")
--	      begin
--	      declare @selemark char(13), @lastnumb int, @inbalance money
--         select  @selemark = 'a' + @setnumb
--	      select @pccode = substring(@pccode, 1, 2) + "A", @package = ' ' + substring(@pccode, 1, 2)
--	      exec @ret = p_gl_accnt_post_charge @selemark, @lastnumb, @inbalance, 
--			     @modu_id, @pc_id, @shift, @empno, @accnt, '', @pccode, @package, @amount, NULL, @bdate, NULL, "IN", "R", null, 'I', @msg out
--	      end
--	   if @ret = 0
--		   begin
--		   insert bos_account(bdate, setnumb, code, code1, reason, name, amount, empno, shift, room, accnt)
--			       values(@bdate, @setnumb, @code, @paymth, @payreason, @name1, @amount, @empno, @shift, @room, @accnt)
--		   if @@rowcount = 0
--			   select @ret = 1, @msg = "款项表插入失败"
--		   else
--			   update bos_folio set setnumb = @setnumb, sta = 'O', shift2 = @shift, empno2 = @empno, bdate1 = @bdate
--                   where foliono = @foliono
--         end
--      end 
	end

if @ret <> 0 
   rollback tran p_gds_bos_input_charge_etc_s1
commit tran

if @ret = 0
   begin
   if rtrim(@paymth) is null
	   select @msg = @foliono
   else
	   select @msg = @setnumb + ';' + @foliono
   end

if @returnmode = 'S'
   select @ret, @msg

return @ret
;


-- --------------------------------------------------------------------------
--	BOS 结帐步骤之一:给待结费用加站点标志 
-- --------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_bos_mark_charge" and type = "P")
   drop proc p_gds_bos_mark_charge;
create proc p_gds_bos_mark_charge
   @modu_id  char(2), 
   @pc_id    char(4), 
   @foliono  char(10)

as

declare
   @ret      int, 
   @msg      varchar(60), 
   @sta      char(1), 
   @checkout char(4), 
	@omodu	 char(2)

select @ret = 0, @msg = ""
begin tran
save  tran p_gds_bos_mark_charge_s1
select @sta = sta, @checkout = checkout, @omodu = modu from bos_folio holdlock where foliono = @foliono
if @@rowcount = 0
   select @ret = 1, @msg = "不存在费用流水号%1^" + @foliono
else if @sta = 'O'
   select @ret = 1, @msg = "本费用已结, 不能再结"
else if charindex(@sta, 'cC') > 0 
   select @ret = 1, @msg = "对冲费用不需结帐"
else if @checkout is not null and @checkout <> @pc_id
   select @ret = 1, @msg = " BOS%1站点也在结单子%2^" + @checkout + '^' + @foliono
else if @omodu <> @modu_id
   select @ret = 1, @msg = "该费用单号不属于该模块 ! - %1^" + @foliono

if @ret = 0
   update bos_folio set checkout = @pc_id, modu = @modu_id where foliono = @foliono
if @ret <> 0
   rollback tran p_gds_bos_mark_charge_s1
commit tran
select @ret, @msg 
return @ret
;

 
-- --------------------------------------------------------------------------
--  BOS 结帐步骤之二:记录输入款项于临时表中 
-- --------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_bos_input_credit" and type = "P")
   drop proc p_gds_bos_input_credit;
create proc p_gds_bos_input_credit
   @modu_id  char(2), 
   @pc_id    char(4), 
   @shift    char(1), 
   @empno    char(10), 
   @paymth   char(5), 
   @reason   char(2), 
   @amount   money  , 
   @accnt    char(10), 
   @room     char(5), 
	@cardtype	char(10) = '', 
	@cardno		varchar(120) = '', 
	@quantity	money = 0, 
   @returnmode  char(1) = 'S'    --返回模式
as

declare 
   @ret      int, 
   @msg      varchar(60), 
   @code     char(5), 
   @name1    char(24), 
   @bdate    datetime, 
	@paytag1	 char(3), 
	@deptno4	 char(5), 
	@ref		 varchar(100), 
	@pos		 integer, 
	@deptno	 char(3)

select @ret = 0, @msg =  ""
select @bdate = bdate1 from sysdata 

if rtrim(@cardtype) is null select @cardtype = ''
if rtrim(@cardno) is null select @cardno = ''
if @quantity is null select @quantity = 0

select @code = pccode, @name1 = descript, @deptno =  deptno, @paytag1 = deptno2, @deptno4 = deptno4 from pccode where pccode = @paymth and deptno5 like '%F%' and argcode like '9%' 
if @@rowcount = 0
   select @ret = 1, @msg = "系统中还未设付款方式%1, 按 F1 有现有付款方式输入帮助^" + @paymth
if @ret = 0
--   begin 
--   if substring(@paytag1, 1, 2) = 'TO'
--      begin
--      if exists (select 1 from bos_partout where modu = @modu_id and checkout = @pc_id)
--     	   select @ret = 1, @msg = "有转账支付时, 只能设定一种结账款项 !"
--      end
--   else
--      begin
--	   if exists (select 1 from bos_partout a, pccode b where a.modu = @modu_id and a.checkout = @pc_id and a.code1 = b.pccode and substring(b.deptno2, 1, 2) like '%TO%')
--     	   select @ret = 1, @msg = "已有转帐款项!为了帐单清楚, 转帐时必须为单笔款项"
--	   end
--   end
if @ret = 0
   begin
   begin tran
   save  tran p_gds_bos_input_credit_s1

	if rtrim(@deptno4) is null select @deptno4 = ''
	if @deptno4 = 'ISC' 
		begin
		select @ref = rtrim(substring(@cardno, 1, 100))
		declare @ii int, @jj int 
		select @ii = charindex(':', @ref), @jj = charindex(';', @ref)
		if @ii > 0 and @jj > 0 and @jj > @ii
			select @cardno = substring(@ref, @ii + 1, @jj-@ii-1)
		else
			select @cardno = ''
		end
	else
		select @ref = ''

	-- accnt -- > room
	select @accnt = rtrim(@accnt), @room = rtrim(@room)
	if @accnt is null select @accnt = ''
	if @room is null select @room = ''
	if @accnt <> '' and @room = ''
		select @room = roomno from master where accnt = @accnt
	if @room is null select @room = ''
   if exists (select * from bos_partout where modu = @modu_id and checkout = @pc_id and code = @code)
	   update bos_partout set amount = amount + round(@amount, 2) where modu = @modu_id and checkout = @pc_id and code = @code
   else 
	  insert bos_partout(modu, bdate, checkout, code, code1, reason, name, amount, empno, shift, room, accnt, cardtype, cardno, quantity, ref)
		 values (@modu_id, @bdate, @pc_id, @code, @paymth, @reason, @name1, @amount, @empno, @shift, @room, @accnt, @cardtype, @cardno, @quantity, @ref)
     
   if @@rowcount =  0
      begin 
	   rollback tran p_gds_bos_input_credit_s1
	   select @ret = 1, @msg = "款项表操作失败"
	   end

	if (select count(1) from bos_partout where modu = @modu_id and checkout = @pc_id) > 1
		delete bos_partout where amount = 0 and modu = @modu_id and checkout = @pc_id and code = @code

   commit tran
   end

if @returnmode = 'S'
	select @ret, @msg
return @ret
;



if exists(select * from sysobjects where name = "p_gds_bos_settlement" and type = "P")
   drop proc p_gds_bos_settlement;

create proc p_gds_bos_settlement
   @modu_id				char(2), 
   @pc_id				char(4), 
   @returnmode			char(1) = 'S',    --返回模式
	@conumb				char(10) = '',
	@msg				varchar(60) = '' output 
as
-- --------------------------------------------------------------------------
--  BOS 结帐步骤之三: 款项及平衡检查, 数据转储, 结帐标志设定 
-- --------------------------------------------------------------------------

declare 
   @ret			      integer, 
	@lic_buy_1			varchar(255), 
	@lic_buy_2			varchar(255), 
	@arcreditcard		char(1),
   @shift				char(1), 
   @empno				char(10), 
   @paymth				char(5), 
   @accnt				char(10), 
   @charge				money, 
   @credit				money, 
   @setnumb				char(10), 
   @pccode				char(5), 
   @chgcod				char(5), 
   @bdate				datetime, 
   @today				datetime, 
	@paytag1				char(5), 
-- TOR
	@tor					char(1), 
	@inum					integer, 
	@gamount				money, 
	@selemark			char(27), 
	@lastnumb			integer, 
	@inbalance			money, 
-- PTS
	@hotelid 			varchar(20), 
	@cardtype			char(10), 
	@cardno 				char(20), 
	@amount 				money, 
	@quantity 			money, 
	@ref					varchar(24), 
	@ref1					varchar(10), 
	@ref2					varchar(50),
	@sfoliono			varchar(12),
	@part_amount		money,				--add by zk 2008-8-2
	@ar_accnt			char(10)

select @ret = 0, @msg = "", @today = getdate()
select @lic_buy_1 = isnull((select value from sysoption where catalog = 'hotel' and item = 'lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog = 'hotel' and item = 'lic_buy.2'), '')
select @charge = isnull(sum(round(fee, 2)), 0) from bos_folio where modu = @modu_id and checkout = @pc_id
select @credit = isnull(sum(round(amount, 2)), 0) from bos_partout where modu = @modu_id and checkout = @pc_id

declare	@postmode		char(1), 
			@code 			char(8),
			@number			int,
			@num1				int,
			@num2				int,
			@ref20			varchar(50)

select @postmode = isnull((select value from sysoption where catalog = 'bos' and item = 'posting_mode'), '0')
if @postmode <> '0' 
begin
	if not exists(select 1 from bos_folio a, bos_dish b where a.modu = @modu_id and a.checkout = @pc_id and a.foliono=b.foliono) 
		select @postmode = '0'
end

begin tran
save  tran p_gds_bos_settlement_s1

select @number = count(1) from bos_folio where modu = @modu_id and checkout = @pc_id
if @number > 1  -- 多个单据，合并结账
begin
	select @num1 = isnull((select count(distinct a.foliono) from  bos_folio a, bos_dish b where a.modu = @modu_id and a.checkout = @pc_id and a.foliono=b.foliono), 0)
	select @num2 = isnull((select count(distinct a.foliono) from  bos_folio a where a.modu = @modu_id and a.checkout = @pc_id), 0) 
	if @num1 <> 0 and @num1 <> @num2 
	begin
		select @ret =  1, @msg = "不同入账方式不能合并结账"
		goto gds 
	end
end

if @charge = 0 and exists(select 1 from bos_partout a, pccode b where a.modu = @modu_id and a.checkout = @pc_id and a.code=b.pccode and b.deptno='H')
   select @ret =  1, @msg = "费用=0，不能折扣款待类付款"
if @charge <> @credit
   select @ret =  1, @msg = "借贷不平, 请先平帐"
else if not exists(select 1 from bos_partout where modu = @modu_id and checkout = @pc_id)
   select @ret =  1, @msg = "没有任何付款记录 !"
	
if @ret = 0
   begin
	if @conumb = '' 
   	exec @ret = p_GetAccnt1 'BST', @setnumb output
	else
		select @setnumb = @conumb
   if @ret <> 0
		begin
	   select @msg = " BOS 结帐流水号生成出错, 请与电脑房联系"
		goto gds
		end
	select @inum = count(1) from bos_partout where modu = @modu_id and checkout = @pc_id
                
          
                                                                                     
             
        
-- change by zk 2008-8-2 加入多种付款方式结一笔bos账的功能
	declare c_partout cursor for select a.code,b.deptno2,a.shift,a.empno,a.bdate,a.ref,a.cardtype,a.amount,a.accnt from 
		bos_partout a,pccode b where a.code = b.pccode and a.modu = @modu_id and a.checkout = @pc_id order by a.code
	open c_partout 
	fetch c_partout into @paymth, @paytag1, @shift, @empno, @bdate ,@ref2 ,@cardtype ,@part_amount ,@ar_accnt
	while @@sqlstatus = 0
		begin
		-- 手工单号
		select @sfoliono=isnull((select max(sfoliono) from bos_folio where modu = @modu_id and checkout = @pc_id), '')
		select @sfoliono=isnull(ltrim(rtrim(@sfoliono)), ''),@tor = ''
		if @sfoliono<>'' select @sfoliono='('+@sfoliono+')'
		select @arcreditcard = isnull((select value from sysoption where catalog = 'ar' and item = 'creditcard'), 'F')
		if @arcreditcard = 'T' and exists (select 1 from bankcard where pccode = @paymth)
			and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
			-- 用信用卡付款时，自动转到相应的应收账户
			select @accnt = accnt, @tor = 'T' from bankcard where pccode = @paymth and bankcode = @cardtype
		else if @paytag1 in ("TOA", "TOR")	-- 转前台 & AR账
			select @accnt = @ar_accnt, @tor = 'T'  --select  @accnt = accnt, @tor = 'T' from bos_partout where modu = @modu_id and checkout = @pc_id
		else
		   select @tor = 'F'

		if @tor = 'T'
			begin
			select @ref20 = @ref2
			if @postmode='0'
				declare c_pccode cursor for select pccode, chgcod, '', 1, sum(round(fee, 2))   			-- 按费用码分类转
					from bos_folio where modu = @modu_id and checkout = @pc_id 
						group by pccode,chgcod order by pccode,chgcod
			else
				declare c_pccode cursor for select a.pccode, a.chgcod, b.code, sum(b.number), sum(round(b.fee, 2))  -- 按商品分类转
					from bos_folio a, bos_dish b 
						where a.modu = @modu_id and a.checkout = @pc_id and a.foliono=b.foliono and b.sta='I'
						group by a.pccode, a.chgcod, b.code order by a.pccode, a.chgcod, b.code
			
			open c_pccode 
			fetch c_pccode into @pccode, @chgcod, @code, @number, @gamount
			while @@sqlstatus = 0
				begin
				select @selemark = 'a' + @paymth + space(5) + @cardtype
				if @inum > 1
					select @gamount = @part_amount,@pccode = @paymth

				if @gamount is null 
					select @gamount = 0 

--				if @gamount = 0 
--				begin
--					fetch c_pccode into @pccode, @chgcod, @code, @number, @gamount
--					continue
--				end

				if @postmode<>'0' 
					select @ref2 = substring(@ref20 + ' ' + name+'*'+rtrim(convert(char(5),@number))+'-'+@sfoliono, 1, 50) from bos_plu where pccode=@pccode and code=@code 
				select @ref2 = isnull(rtrim(ltrim(@ref2)), '')
				exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id, 0, @shift, @empno, @accnt, 0, @chgcod, '', 1, @gamount, @gamount, 0, 0, 0, 0, @setnumb, @ref2, @today, '', '', 'IRYY', 0, '', @msg out
	
				if @ret <> 0
					begin
					close c_pccode
					deallocate cursor c_pccode
					goto gds
					end
				if @inum > 1 break --假如只有一种结账方式，则可以分pccode或者商品code转 假如多种结账方式则按照实际金额转
				fetch c_pccode into @pccode, @chgcod, @code, @number, @gamount 
				end
			close c_pccode
			deallocate cursor c_pccode
			end
	
		else if @paytag1 = 'PTS'  -- 使用贵宾卡积分付款
			begin
			if @inum > 1				--add by zk 2008-8-2
				begin
				select @ret = 1, @msg = "贵宾卡积分付款不支持多种付款方式同时付款"
				goto gds
				end
			select @amount = amount, @cardtype = cardtype, @cardno = cardno, @quantity = quantity from bos_partout 
				where modu = @modu_id and checkout = @pc_id and code1 = @paymth
			select @ref = rtrim(descript1) + '[' + rtrim(descript) + ']' from basecode where cat = 'moduno' and code = @modu_id
			if @@rowcount = 0	select @ref = 'BOS'
			select @ref1 = @setnumb, @ref2 = 'Card = ' + rtrim(@cardtype) + '-' + rtrim(@cardno) + ';'
			select @hotelid = isnull((select value from sysoption where catalog = 'hotel' and item = 'hotelid'), '')
			exec @ret = p_gds_vipcard_posting '', @modu_id, @pc_id, 0, @shift, @empno, @cardno, @hotelid, @bdate, '-', @amount, @amount, 0, 0, 0, @quantity, '', @setnumb, @ref, @ref1, @ref2, @paymth, 'R', @ret output, @msg output
			if @ret <> 0
				select @ret = 1, @msg = "VIPPOINT 操作失败"
			end
		fetch c_partout into @paymth, @paytag1, @shift, @empno, @bdate ,@ref2 ,@cardtype ,@part_amount ,@ar_accnt
		end
		close c_partout
		deallocate cursor c_partout

	if @ret = 0
		begin 
		update bos_folio set setnumb = @setnumb, sta = 'O', shift2 = @shift, empno2 = @empno, bdate1 = @bdate
			where modu = @modu_id and checkout = @pc_id

		-- 库存明细账
		declare @foliono char(10)
			declare c_detail cursor for select foliono from bos_folio a, bos_pccode b
				where a.modu = @modu_id and a.checkout = @pc_id and a.pccode = b.pccode and b.jxc > 0 
				order by foliono
		open c_detail 
		fetch c_detail into @foliono
		while @@sqlstatus = 0
			begin
			exec @ret = p_gds_bos_detail @modu_id, @pc_id, @foliono, 'S', '', @msg output
			if @ret <> 0
				begin
				close c_detail
				deallocate cursor c_detail
				goto gds
				end
			fetch c_detail into @foliono
			end
		close c_detail
		deallocate cursor c_detail

		update bos_folio set checkout = null where modu = @modu_id and checkout = @pc_id
		                                                                               insert bos_account select bos_partout.log_date, bos_partout.bdate, bos_partout.setnumb, bos_partout.code, bos_partout.code1, bos_partout.reason, bos_partout.name, bos_partout.amount, bos_partout.empno, bos_partout.shift, bos_partout.room, bos_partout.accnt, bos_partout.tranlog, bos_partout.cusno, bos_partout.cardtype, bos_partout.cardno, bos_partout.quantity, bos_partout.ref, bos_partout.modu, bos_partout.checkout from bos_partout where modu = @modu_id and checkout = @pc_id
		update bos_account set checkout = null, setnumb = @setnumb where modu = @modu_id and checkout = @pc_id
		delete bos_partout where modu = @modu_id and checkout = @pc_id
      end
   end

gds:
if @ret <>  0          
   rollback tran p_gds_bos_settlement_s1
commit tran

if @ret = 0
   select @msg = @setnumb + @msg
if @returnmode = 'S'
	select @ret, @msg
return @ret
;

-- --------------------------------------------------------------------------
--	结帐冲销
-- --------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_bos_co" and type = "P")
   drop proc p_gds_bos_co;
create proc p_gds_bos_co
	@modu_id				char(2), 
	@pc_id				char(4), 
   @setnumb				char(10), 
	@empno				char(10), 
	@shift				char(1), 
   @returnmode			char(1) = 'S'    --返回模式
as
declare 
   @ret					integer, 
   @msg					varchar(60), 
	@lic_buy_1			varchar(255), 
	@lic_buy_2			varchar(255), 
	@arcreditcard		char(1),
   @paymth				char(5), 
   @amount				money, 
   @accnt				char(10), 
   @charge				money, 
   @credit				money, 
   @pccode				char(5), 
   @chgcod				char(5), 
   @bdate				datetime, 
   @today				datetime, 
	@paytag1				char(5),
	@hotelid 			varchar(20), 
	@cardtype			char(10), 
	@cardno 				char(20), 
	@cardar				char(10), 
	@quantity		 	money, 
	@ref					varchar(24), 
	@ref1					varchar(10), 
	@ref2					varchar(50), 
	@id					char(10),
-- TOR
	@tor					char(1), 
	@inum					integer,
	@gamount				money,
	@selemark			char(27),
	@lastnumb			integer,
	@inbalance			money,
	@sfoliono			varchar(12),
	@part_amount		money,				--add by zk 2008-8-2
	@ar_accnt			char(10)

-- 2002/04/01------------------------------------------------------
--select @ret = 1, @msg = '此功能暂时取消，请填写负单冲账 !'
--if @returnmode = 'S'
--	select @ret, @msg
--return @ret
-- 2002/04/01------------------------------------------------------

select @inum = count(1) from bos_account where setnumb = @setnumb
select @ret = 0, @msg = '', @bdate = bdate1, @today = getdate() from sysdata
select @lic_buy_1 = isnull((select value from sysoption where catalog = 'hotel' and item = 'lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog = 'hotel' and item = 'lic_buy.2'), '')
if not exists(select 1 from bos_account where setnumb = @setnumb)
	or not exists(select 1 from bos_folio where setnumb = @setnumb)
	begin
	select @ret = 1, @msg = '结账单据不存在 !'
	if @returnmode = 'S'
		select @ret, @msg
	return @ret
	end

declare	@postmode		char(1), 
			@code 			char(8),
			@number			int,
			@ref20			varchar(50)
select @postmode = isnull((select value from sysoption where catalog = 'bos' and item = 'posting_mode'), '0')
if @postmode <> '0' 
begin
	if not exists(select 1 from bos_folio a, bos_dish b where a.setnumb = @setnumb and a.foliono=b.foliono) 
		select @postmode = '0'
end

begin tran
save  tran p_gds_bos_co_s1

declare c_partout cursor for select a.code,b.deptno2,a.shift,a.empno,a.bdate,a.ref,a.cardtype,a.amount,a.accnt from 
		bos_account a,pccode b where a.code = b.pccode and a.setnumb = @setnumb order by a.code
open c_partout 
fetch c_partout into @paymth, @paytag1, @shift, @empno, @bdate ,@ref2 ,@cardtype ,@part_amount ,@ar_accnt
while @@sqlstatus = 0
	begin

	select @arcreditcard = isnull((select value from sysoption where catalog = 'ar' and item = 'creditcard'), 'F')
	--if @arcreditcard = 'T' and exists (select 1 from bos_account a, bankcard b where a.setnumb = @setnumb and a.code = b.pccode)
	if @arcreditcard = 'T' and exists (select 1 from bankcard b where b.pccode = @paymth)
		and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
		-- 用信用卡付款时，自动转到相应的应收账户
		begin
		if @paytag1 in ('PTS','CAR')
			select @accnt = accnt, @tor = 'T' from bankcard where pccode = @paymth
		else
			select @accnt = accnt, @tor = 'T' from bankcard where pccode = @paymth and bankcode = @cardtype
		end
	else if exists(select 1 from pccode b where b.pccode = @paymth and b.deptno2 like '%TO%')
	-- 转前台 & AR账
		--select @paymth = code, @paytag1 = code1, @accnt = accnt, @ref2 = ref, @tor = 'T'
			--from bos_account where setnumb = @setnumb
		select @tor = 'T',@accnt = @ar_accnt
	else
		select @tor = 'F'
	if @tor = 'T'
		begin		-- 转账的情况
	
		-- 手工单号
		select @sfoliono=isnull((select max(sfoliono) from bos_folio where setnumb=@setnumb), '')
		select @sfoliono=isnull(ltrim(rtrim(@sfoliono)), '')
		if @sfoliono<>'' select @sfoliono='('+@sfoliono+')'
	
		select @ref20 = @ref2
		if @postmode='0'
			declare c_pccode cursor for select pccode, chgcod, '', 1, sum(round(fee, 2))  			-- 按费用码分类转
				from bos_folio where setnumb = @setnumb
					group by pccode,chgcod order by pccode,chgcod
		else
			declare c_pccode cursor for select a.pccode, a.chgcod, b.code, sum(b.number), sum(round(b.fee, 2))  -- 按商品分类转
				from bos_folio a, bos_dish b 
					where a.setnumb = @setnumb and a.foliono=b.foliono and b.sta='I'
						group by a.pccode, a.chgcod, b.code order by a.pccode, a.chgcod, b.code
			
		open c_pccode 
		fetch c_pccode into @pccode, @chgcod, @code, @number, @gamount
		while @@sqlstatus = 0
			begin
			select  @selemark = 'a' + @paymth + space(5) + @cardtype
			if @gamount is null or @gamount = 0 
			begin
				fetch c_pccode into @pccode, @chgcod, @code, @number, @gamount
				continue
			end
			if exists (select 1 from account where ref1 = @setnumb and billno <> '')
				begin
				select @ret = -1,@msg = "前台已结账，不能冲销"
				goto gds
				end
			if @inum > 1
					select @gamount = @part_amount,@pccode=@paymth
			if @postmode<>'0' 
				select @ref2 = substring(@ref20 + ' ' + name+'*'+rtrim(convert(char(5),@number))+'-'+@sfoliono, 1, 50) from bos_plu where pccode=@pccode and code=@code 
			select @ref2 = isnull(rtrim(ltrim(@ref2)), '')
			select @gamount = @gamount * -1
			exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id, 0, @shift, @empno, @accnt, 0, @chgcod, '', 1, @gamount, @gamount, 0, 0, 0, 0, @setnumb, @ref2, @today, '', '', 'IRYY', 0, '', @msg out
			if @ret <> 0
				begin
				close c_pccode
				deallocate cursor c_pccode
				goto gds
				end
			if @inum > 1 break
			fetch c_pccode into @pccode, @chgcod, @code, @number, @gamount
			end
		close c_pccode
		deallocate cursor c_pccode
		end
	if exists(select 1 from bos_account a, pccode b where a.setnumb = @setnumb and a.code1 = b.pccode and b.deptno2 like '%PTS%')
		begin		-- 积分的情况
		select @amount = amount, @cardtype = cardtype, @cardno = cardno, @quantity = quantity from bos_account where setnumb = @setnumb
		select @ref = rtrim(descript1) + '[' + rtrim(descript) + ']' from basecode where cat = 'moduno' and code = @modu_id
		if @@rowcount = 0	select @ref = 'BOS'
		select @ref1 = @setnumb, @ref2 = 'Card = ' + rtrim(@cardtype) + '-' + rtrim(@cardno) + ';'
		select @hotelid = isnull((select value from sysoption where catalog = 'hotel' and item = 'hotelid'), '')
		exec @ret = p_gds_vipcard_posting 'D', @modu_id, @pc_id, 0, @shift, @empno, @cardno, @hotelid, @bdate, '-', @amount, @amount, 0, 0, 0, @quantity, '', @setnumb, @ref, @ref1, @ref2,'', 'R', @ret output, @msg output
		if @ret <> 0
			select @ret = 1
		end
	else if exists(select 1 from bos_account a, pccode b where a.setnumb = @setnumb and a.code1 = b.pccode and b.deptno2 like '%CAR%')
		begin		-- 远程贵宾卡记账的情况
		exec p_GetAccnt1 'CAR', @id output
		select @paymth = code, @amount = amount, @cardtype = cardtype, @cardno = cardno, @cardar = accnt, @quantity = quantity from bos_account where setnumb = @setnumb
		insert vipcocar(id, cardno, cardtype, cardar, bdate, modu_id, acttype, accnt, number, code, amount, empno, log_date, sendout, sendby, sendtime, shift, sendshift)
			values(@id, @cardno, @cardtype, @cardar, @bdate, @modu_id, 'B', @setnumb, 0, @paymth, @amount, @empno, @today, 'F', '', null, @shift, '')
		if @@rowcount = 0
			select @ret = 1
		end
	fetch c_partout into @paymth, @paytag1, @shift, @empno, @bdate ,@ref2 ,@cardtype ,@part_amount ,@ar_accnt
	end
close c_partout
deallocate cursor c_partout

if @ret = 0
begin
	update bos_folio set setnumb = '', sta = 'C', shift2 = @shift, empno2 = @empno, bdate1 = @bdate where setnumb = @setnumb
	if @@rowcount = 0
		select @ret = 1
	else
	begin
		delete bos_account where setnumb = @setnumb
		if @@rowcount = 0
			select @ret = 1
	end
end

gds:
if @ret <>  0          
   rollback tran p_gds_bos_co_s1
commit tran
if @returnmode = 'S'
	select @ret, @msg
return @ret
;


-- --------------------------------------------------------------------------
--	BOS 初始化程序
-- --------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_bos_init")
	drop proc p_gds_bos_init;
create proc p_gds_bos_init

as

truncate table bos_folio
truncate table bos_hfolio

truncate table bos_dish
truncate table bos_hdish

truncate table bos_account
truncate table bos_haccount
truncate table bos_partout

truncate table bos_partfolio
truncate table bos_tmpdish

truncate table bosjie
truncate table bosdai
truncate table ybosjie
truncate table ybosdai

truncate table bos_kcmenu
truncate table bos_kcdish
truncate table bos_store
truncate table bos_hstore

truncate table bos_detail
truncate table bos_hdetail

return 0
;

