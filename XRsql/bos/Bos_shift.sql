-- ------------------------------------------------------------------------------
--		shiftbosjie
--		shiftbosdai
--
--		bos_jie
--		bos_dai
--		bos_jiedai
--
--		p_gds_bos_shiftrep
--		p_gds_bos_shiftrep_exp
--
-- ------------------------------------------------------------------------------

--   
--	BOS 交班表 
--


if exists ( select * from sysobjects where name = 'shiftbosjie' and type ='U')
	drop table shiftbosjie;
create table shiftbosjie
(
	modu_id       char(2)	not null,
	pc_id         char(4)	not null,
	order_        int      default 0	,
	date          datetime default getdate(),
	code          char(5)  default '' not null,
	descript      char(24)  default '' not null,
	fee_bas       money    default 0  not null,
	fee_sur       money    default 0  not null,
	fee_tax       money    default 0  not null,
	fee_dsc	     money    default 0  not null,
	fee_ent	     money    default 0  not null,
	fee_ttl	     money    default 0  not null
)
exec sp_primarykey shiftbosjie,modu_id,pc_id,code
create unique index index1 on shiftbosjie(modu_id,pc_id,code)
;


if exists ( select * from sysobjects where name = 'shiftbosdai' and type ='U')
	drop table shiftbosdai;
create table shiftbosdai
(
	modu_id       char(2)	not null,
	pc_id         char(4)	not null,
	order_        int      default 0,
	date          datetime default    getdate(),
	paycode       char(5)  default '' not null,
	paytail       char(1)  default '' not null,
	descript      char(24) default '' not null,
	creditd       money    default 0  not null
)
exec sp_primarykey shiftbosdai,modu_id,pc_id,paycode,paytail
create unique index index1 on shiftbosdai(modu_id,pc_id,paycode,paytail)
;


--  
--	交班表统计临时表
--
if exists ( select * from sysobjects where name = 'bos_jie' and type ='U')
	drop table bos_jie;
create table bos_jie
(
	modu_id  char(2) not null,
   pc_id    char(4) not null,
	jiecode  char(5) not null,            --  借项  
	amount   money   default 0 not null,  --  基本费
	smount   money   default 0 not null,  --  服务费
	tmount   money   default 0 not null,  --  附加费
	pmount   money   default 0 not null,  --  百分比折扣
	dmount   money   default 0 not null,  --  贷扣
	emount   money   default 0 not null   --  款待
)
exec sp_primarykey bos_jie,modu_id,pc_id,jiecode
create unique index index1 on bos_jie (modu_id,pc_id,jiecode)
;

if exists ( select * from sysobjects where name = 'bos_dai' and type ='U')
   drop table bos_dai;
create table bos_dai
(
	modu_id       char(2) not null,
   pc_id       char(4) not null,
   daicode     char(5) not null,      --  贷项 
   daitail     char(1) default '',    --  贷项补钉 
   distribute  char(4) default '',    --  需分摊项,只对借项中净数额进行 
   amount      money   default 0  not null
)	 
exec sp_primarykey bos_dai,modu_id,pc_id,daicode,daitail
create unique index index1 on bos_dai (modu_id,pc_id,daicode,daitail)
;

if exists ( select * from sysobjects where name = 'bos_jiedai' and type ='U')
   drop table bos_jiedai;
create table bos_jiedai
(
   modu_id       char(2) not null,
   pc_id       char(4) not null,
   jiecode  char(5) default '',  --  借项 
   daicode  char(5) default '',  --  贷项 
   amount   money   default 0  not null,
   smount   money   default 0  not null,
   tmount   money   default 0  not null
)
exec sp_primarykey bos_jiedai,modu_id,pc_id,daicode,jiecode
create unique index index1 on bos_jiedai (modu_id,pc_id,daicode,jiecode)
;


--  
--		统计过程 
--
if exists ( select * from sysobjects where name = 'p_gds_bos_shiftrep' and type ='P')
	drop proc p_gds_bos_shiftrep;
create proc   p_gds_bos_shiftrep
	@modu_id  char(2),
	@pc_id    char(4),
	@limpcs	 varchar(120),	--  Pccode 限制
	@shift    char(1),
	@empno    char(10),
   @dategap  int 
as

declare
      @bdate         datetime,
      @bfdate        datetime,
		@duringaudit   char(1) ,
      @dsc_sttype    char(2) ,
      @isfstday      char(1) ,
		@isyfstday     char(1) , 
		@pccode	char(5),	-- 营业点
		@code 	char(5),
		@ccode 	char(5),	
		@descript char(12), -- 代码描述
      @amount	money,		-- 金额
		@camount money,		-- 金额
		@mper_dsc money,
		@jiecode char(5),
		@daicode char(5),
      @daitail char(1),
      @jamount money,
      @jtmount money,
		@damount money,
		@thispart money,
		@thispart1 money,
		@thispart2 money,
		@sumpart money,
		@sumpart1 money,
		@sumpart2 money,
		@divval  money,
      @diffpart money ,
		@diffpart1 money ,
		@diffpart2 money ,
		@credit money,
		@setnumb char(10),
		@msetnumb char(10),
   	@fee_base money,
  	   @fee_serve money,
  	   @fee_tax money,
		@jsmount money,
		@no_more int,
		@emount  money,
		@ret     int,
		@msg     varchar(60) 

select @bdate = bdate1 from sysdata
select @bfdate = dateadd(day,@dategap,@bdate),@ret=0,@msg='',@diffpart1=0,@diffpart2=0
select @dsc_sttype = value from sysoption where catalog = 'bos' and item = 'dsc_sttype'
if @@rowcount = 0
	begin
	insert sysoption(catalog,item,value) select 'bos', 'dsc_sttype', 'yy'
   select @dsc_sttype ='yy'
	end

select @mper_dsc = 0

--delete shiftbosjie where modu_id=@modu_id and pc_id = @pc_id
--delete shiftbosdai where modu_id=@modu_id and pc_id = @pc_id
--delete bos_jie     where modu_id=@modu_id and pc_id = @pc_id
--delete bos_dai     where modu_id=@modu_id and pc_id = @pc_id
--delete bos_jiedai  where modu_id=@modu_id and pc_id = @pc_id
delete shiftbosjie where  pc_id = @pc_id
delete shiftbosdai where  pc_id = @pc_id
delete bos_jie     where  pc_id = @pc_id
delete bos_dai     where  pc_id = @pc_id
delete bos_jiedai  where  pc_id = @pc_id

declare c_bos_jie  cursor for select jiecode,amount,smount,tmount from bos_jie
		where modu_id=@modu_id and pc_id = @pc_id order by jiecode
declare c_bos_jie1 cursor for select jiecode,amount,smount,tmount,pmount,dmount,emount from bos_jie
        where modu_id=@modu_id and pc_id = @pc_id order by jiecode
declare c_bos_dai  cursor for select daicode,daitail,amount from bos_dai
        where modu_id=@modu_id and pc_id = @pc_id order by daicode,daitail
declare c_bos_dai_dist cursor for select daicode,amount from bos_dai
		where modu_id=@modu_id and pc_id = @pc_id and distribute<>'' and amount <> 0
		order by daicode
declare c_bos_jiedai cursor for select jiecode from bos_jiedai
		where modu_id=@modu_id and pc_id = @pc_id and daicode = @daicode
		order by jiecode

if @dategap = 0  -- 这里需要对 posno or pccodes 限制
   begin 

-- 插入缺少的 bos_account  -- 只有 folio  2001/07
	if exists(select 1 from bos_folio where rtrim(setnumb) is not null and setnumb not in (select setnumb from bos_account))
		insert bos_account(log_date,bdate,setnumb,code,code1,name,amount,empno,shift,modu)
			select log_date,bdate,setnumb,'901','901','现金',0,empno1,shift1,modu 
				from bos_folio where rtrim(setnumb) is not null and setnumb not in (select setnumb from bos_account)

   declare c_bos_fol cursor for select pccode,fee_base-fee_disc,fee_serve,fee_tax,fee_disc
				     from bos_folio where setnumb = @msetnumb 
                     order by setnumb,pccode 
   declare c_bos_act cursor for select distinct a.setnumb,a.code,a.amount
				     from bos_account a, bos_folio b
				where (@empno is null or a.empno = @empno) 
						and (@shift is null or a.shift = @shift) 
						and a.setnumb=b.setnumb and (@limpcs is null or charindex(rtrim(b.pccode),@limpcs)>0)
				     order by a.setnumb, a.code
   end
else
   begin
   declare c_bos_fol cursor for select pccode,fee_base-fee_disc,fee_serve,fee_tax,fee_disc
			         from bos_hfolio where setnumb = @msetnumb
				     order by setnumb,pccode
   declare c_bos_act cursor for select distinct a.setnumb,a.code,a.amount
				     from bos_haccount a, bos_hfolio b
				where (@empno is null or a.empno = @empno) 
						and (@shift is null or a.shift = @shift) 
						and datediff(dd,@bdate,a.bdate) = @dategap   -- 时间间隔
						and a.setnumb=b.setnumb 
						and (@limpcs is null or charindex(rtrim(b.pccode),@limpcs)>0)
				     order by a.setnumb, a.code
   end

open c_bos_act
fetch c_bos_act into @setnumb,@ccode,@camount
select @msetnumb = @setnumb
while (1 = 1) 
   begin
   if @@sqlstatus <> 0
	  begin
      select @no_more = 1
	  if @msetnumb is null
		 break
	  end
   else if @setnumb = @msetnumb
	  begin
	  if not exists (select * from bos_dai where modu_id=@modu_id and pc_id = @pc_id and daicode = @ccode )
		 insert bos_dai (modu_id,pc_id,daicode,amount) values (@modu_id,@pc_id,@ccode,@camount)
	  else
		 update bos_dai set amount = amount + @camount where modu_id=@modu_id and pc_id = @pc_id and daicode = @ccode
	  fetch c_bos_act into @setnumb,@ccode,@camount
	  continue
	  end

   --  deal with bos_folio 

   open c_bos_fol
   fetch c_bos_fol into @pccode,@fee_base,@fee_serve,@fee_tax,@mper_dsc
   while @@sqlstatus = 0
	  begin
      if charindex(substring(@dsc_sttype,1,1),'yY') = 0 
	     select @mper_dsc = 0
	  if not exists  (select * from bos_jie where modu_id=@modu_id and pc_id = @pc_id and jiecode = @pccode+' ')
		 insert bos_jie (modu_id,pc_id,jiecode,amount,smount,tmount,pmount) values (@modu_id,@pc_id,@pccode,@fee_base,@fee_serve,@fee_tax,@mper_dsc)
	  else
		 update bos_jie set amount = amount + @fee_base,smount = smount +@fee_serve,tmount = tmount +@fee_tax,pmount = pmount + @mper_dsc
					 where modu_id=@modu_id and pc_id = @pc_id and jiecode = @pccode
	  fetch c_bos_fol into @pccode,@fee_base,@fee_serve,@fee_tax,@mper_dsc
	  end
   close c_bos_fol

   --  consider distribution 

--	update bos_dai set distribute = paymth.distribute
--	  from paymth where modu_id=@modu_id and pc_id = @pc_id and paycode = bos_dai.daicode and substring(paymth.distribute,1,1) = 'T'
	update bos_dai set distribute = pccode.deptno8 from pccode
		where bos_dai.modu_id=@modu_id and bos_dai.pc_id = @pc_id and pccode.pccode = bos_dai.daicode and pccode.deptno8<>''
	if exists ( select * from bos_dai where modu_id=@modu_id and pc_id = @pc_id and distribute<>'' and amount <> 0 )
	begin
		select @credit = sum(amount) from bos_dai where modu_id=@modu_id and pc_id = @pc_id
		if @credit <> 0
		begin
			open c_bos_dai_dist
			fetch c_bos_dai_dist into @daicode,@damount
			while @@sqlstatus = 0
			begin
				select @sumpart = 0,@sumpart1 = 0,@sumpart2 = 0,@divval = @damount / @credit
				open c_bos_jie
				fetch c_bos_jie into @jiecode,@jamount,@jsmount,@jtmount
				while @@sqlstatus = 0
					begin
					select @thispart = round( @jamount * @divval ,2),@thispart1 = round( @jsmount * @divval ,2),@thispart2 = round( @jtmount * @divval ,2)
					select @sumpart  = @sumpart + @thispart,@sumpart1  = @sumpart1 + @thispart1,@sumpart2  = @sumpart2 + @thispart2
					insert bos_jiedai (modu_id,pc_id,jiecode,daicode,amount,smount,tmount) values (@modu_id,@pc_id,@jiecode,@daicode,@thispart,@thispart1,@thispart2)
					fetch c_bos_jie into @jiecode,@jamount,@jsmount,@jtmount
					end
				close c_bos_jie

				select @diffpart = @damount - (@sumpart + @sumpart1 + @sumpart2)
				if @diffpart <> 0
				begin  
					open c_bos_jiedai
					fetch c_bos_jiedai into @jiecode
					while @@sqlstatus = 0
					begin
						update bos_jiedai set amount = amount + @diffpart,smount = smount + @diffpart1,tmount = tmount + @diffpart2
							 where modu_id=@modu_id and pc_id = @pc_id and jiecode = @jiecode and daicode =@daicode and (amount <> 0 or smount <> 0 or tmount <> 0)
						if @@rowcount = 1
							break
						fetch c_bos_jiedai into @jiecode
					end
					close c_bos_jiedai
				end 
				fetch c_bos_dai_dist into @daicode,@damount
			end
			close c_bos_dai_dist
		end
	end

   --  adjust  
   update bos_jie set amount = amount - isnull((select sum(amount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and bos_jiedai.jiecode = bos_jie.jiecode),0) where modu_id=@modu_id and pc_id = @pc_id
   update bos_jie set smount = smount - isnull((select sum(smount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and  bos_jiedai.jiecode = bos_jie.jiecode),0) where modu_id=@modu_id and pc_id = @pc_id
   update bos_jie set tmount = tmount - isnull((select sum(tmount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and  bos_jiedai.jiecode = bos_jie.jiecode),0) where modu_id=@modu_id and pc_id = @pc_id
   --update bos_jie set emount = emount + isnull((select sum(amount+smount+tmount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and bos_jiedai.jiecode = bos_jie.jiecode and bos_jiedai.daicode = '994'),0) where modu_id=@modu_id and pc_id = @pc_id
   --update bos_jie set dmount = dmount + isnull((select sum(amount+smount+tmount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and bos_jiedai.jiecode = bos_jie.jiecode and bos_jiedai.daicode <>'994'),0) where modu_id=@modu_id and pc_id = @pc_id
	--modi by zk. 奥运都快开幕了怎么能把费用码写死呢？2008-8-6
	update bos_jie set emount = emount + isnull((select sum(amount+smount+tmount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and bos_jiedai.jiecode = bos_jie.jiecode and bos_jiedai.daicode in (select pccode from pccode where deptno2 = 'ENT')),0) where modu_id=@modu_id and pc_id = @pc_id
   update bos_jie set dmount = dmount + isnull((select sum(amount+smount+tmount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and bos_jiedai.jiecode = bos_jie.jiecode and bos_jiedai.daicode not in (select pccode from pccode where deptno2 = 'ENT')),0) where modu_id=@modu_id and pc_id = @pc_id
	
   select @amount = isnull(sum(pmount),0) from bos_jie where modu_id=@modu_id and pc_id = @pc_id
   if @amount <> 0 
	  insert bos_dai (modu_id,pc_id,daicode,daitail,amount) values (@modu_id,@pc_id,'993',char(30),@amount)
   --  attribute #bus_shiftrep_jie data to shiftbosjie 
   open c_bos_jie1
   fetch c_bos_jie1 into @jiecode,@amount,@fee_serve,@fee_tax,@mper_dsc,@damount,@emount
   while @@sqlstatus = 0
	  begin
	  if not exists ( select * from shiftbosjie where modu_id=@modu_id and pc_id = @pc_id and code = @jiecode)
		 insert shiftbosjie (modu_id,pc_id,date,code,fee_bas,fee_sur,fee_tax,fee_dsc,fee_ent) values (@modu_id,@pc_id,@bfdate,@jiecode,@amount,@fee_serve,@fee_tax,@mper_dsc+@damount,@emount)
	  else
		 update shiftbosjie set date = @bfdate,fee_bas = fee_bas + @amount,fee_tax = fee_tax + @fee_tax,fee_sur = fee_sur + @fee_serve,fee_dsc = fee_dsc + @mper_dsc+@damount,fee_ent = fee_ent + @emount
							   where modu_id=@modu_id and pc_id = @pc_id and code = @jiecode
	  fetch c_bos_jie1 into @jiecode,@amount,@fee_serve,@fee_tax,@mper_dsc,@damount,@emount
	  end
   close c_bos_jie1
   --  attribute #dai data to deptdai 
   open c_bos_dai
   fetch c_bos_dai into @daicode,@daitail,@amount
   while @@sqlstatus = 0
	  begin
	  if not exists ( select * from shiftbosdai where modu_id=@modu_id and pc_id = @pc_id and paycode = @daicode and paytail = @daitail)
		 insert shiftbosdai (modu_id,pc_id,date,paycode,paytail,creditd) values (@modu_id,@pc_id,@bfdate,@daicode,@daitail,@amount)
      else 
		 update shiftbosdai set date = @bfdate,creditd = creditd + @amount
					   where modu_id=@modu_id and pc_id = @pc_id and paycode = @daicode and paytail = @daitail
	  fetch c_bos_dai into @daicode,@daitail,@amount
	  end
   close c_bos_dai
   if @no_more = 1
	  break
   select @msetnumb = @setnumb
   delete bos_jie where modu_id=@modu_id and pc_id = @pc_id 
   delete bos_dai where modu_id=@modu_id and pc_id = @pc_id
   delete bos_jiedai where modu_id=@modu_id and pc_id = @pc_id
   insert bos_dai (modu_id,pc_id,daicode,amount) values (@modu_id,@pc_id,@ccode,@camount)
   fetch c_bos_act into @setnumb,@ccode,@camount
   end
close c_bos_act

-- update titles  
update shiftbosjie  set fee_ttl  = fee_bas+fee_sur+fee_tax+fee_dsc+fee_ent
update shiftbosjie  set descript = bos_pccode.descript from bos_pccode 
	where substring(shiftbosjie.code,1,5)=bos_pccode.pccode

update shiftbosdai  set descript = pccode.descript
	from pccode where shiftbosdai.paycode = pccode.pccode

update shiftbosdai  set descript = '百分比折' where paycode = '993' and paytail = char(30)

select @no_more = 1

declare c_bos_s_jie cursor for select code from shiftbosjie where modu_id=@modu_id and pc_id = @pc_id order by code
open c_bos_s_jie
fetch c_bos_s_jie into @code
while @@sqlstatus = 0
   begin
   update shiftbosjie set order_ = @no_more where modu_id=@modu_id and pc_id = @pc_id and code = @code
   select @no_more = @no_more + 1 
   fetch c_bos_s_jie into @code
   end
close c_bos_s_jie
deallocate cursor c_bos_s_jie

select @no_more = 1

declare c_bos_s_dai cursor for select paycode from shiftbosdai where modu_id=@modu_id and pc_id = @pc_id order by paycode
open c_bos_s_dai
fetch c_bos_s_dai into @code
while @@sqlstatus = 0
   begin
   update shiftbosdai set order_ = @no_more where modu_id=@modu_id and pc_id = @pc_id and paycode = @code
   select @no_more = @no_more + 1 
   fetch c_bos_s_dai into @code
   end
close c_bos_s_dai
deallocate cursor c_bos_s_dai

--  deallocate cursor previous cursors 
deallocate cursor c_bos_jie
deallocate cursor c_bos_jie1
deallocate cursor c_bos_dai
deallocate cursor c_bos_dai_dist
deallocate cursor c_bos_jiedai
deallocate cursor c_bos_fol
deallocate cursor c_bos_act

select @ret,@msg
return @ret
;



-- ----------------------------------------------------------------------------
--  BOS  时间段 报表 统计过程
--		p_gds_bos_shiftrep 稍加改造而成 : 主要修改了日期参数和光标定义
-- ----------------------------------------------------------------------------
if exists ( select * from sysobjects where name = 'p_gds_bos_shiftrep_exp' and type ='P')
	drop proc p_gds_bos_shiftrep_exp;
create proc   p_gds_bos_shiftrep_exp
	@modu_id  char(2),
	@pc_id    char(4),
	@limpcs	 varchar(120),	--  Pccode 限制
	@shift    char(1),
	@empno    char(10),
	@begin_		datetime,
	@end_			datetime
as

declare
      @bdate         datetime,
      @bfdate        datetime,
		@duringaudit   char(1) ,
      @dsc_sttype    char(2) ,
      @isfstday      char(1) ,
		@isyfstday     char(1) , 
		@pccode	char(5),	-- 营业点
		@code 	char(5),
		@ccode 	char(5),	
		@descript char(12), -- 代码描述
      @amount	money,		-- 金额
		@camount money,		-- 金额
		@mper_dsc money,
		@jiecode char(5),
		@daicode char(5),
      @daitail char(1),
      @jamount money,
      @jtmount money,
		@damount money,
		@thispart money,
		@thispart1 money,
		@thispart2 money,
		@sumpart money,
		@sumpart1 money,
		@sumpart2 money,
		@divval  money,
      @diffpart money ,
		@diffpart1 money ,
		@diffpart2 money ,
		@credit money,
		@setnumb char(10),
		@msetnumb char(10),
   	@fee_base money,
  	   @fee_serve money,
  	   @fee_tax money,
		@jsmount money,
		@no_more int,
		@emount  money,
		@ret     int,
		@msg     varchar(60) 

select @bdate = bdate1 from sysdata
select @ret=0,@msg='',@diffpart1=0,@diffpart2=0
select @dsc_sttype = value from sysoption where catalog = 'bos' and item = 'dsc_sttype'
if @@rowcount = 0
	begin
	insert sysoption(catalog,item,value) select 'bos', 'dsc_sttype', 'yy'
   select @dsc_sttype ='yy'
	end

select @mper_dsc = 0

--delete shiftbosjie where modu_id=@modu_id and pc_id = @pc_id
--delete shiftbosdai where modu_id=@modu_id and pc_id = @pc_id
--delete bos_jie     where modu_id=@modu_id and pc_id = @pc_id
--delete bos_dai     where modu_id=@modu_id and pc_id = @pc_id
--delete bos_jiedai  where modu_id=@modu_id and pc_id = @pc_id
delete shiftbosjie where  pc_id = @pc_id
delete shiftbosdai where  pc_id = @pc_id
delete bos_jie     where  pc_id = @pc_id
delete bos_dai     where  pc_id = @pc_id
delete bos_jiedai  where  pc_id = @pc_id

declare c_bos_jie  cursor for select jiecode,amount,smount,tmount from bos_jie
		where modu_id=@modu_id and pc_id = @pc_id order by jiecode
declare c_bos_jie1 cursor for select jiecode,amount,smount,tmount,pmount,dmount,emount from bos_jie
        where modu_id=@modu_id and pc_id = @pc_id order by jiecode
declare c_bos_dai  cursor for select daicode,daitail,amount from bos_dai
        where modu_id=@modu_id and pc_id = @pc_id order by daicode,daitail
declare c_bos_dai_dist cursor for select daicode,amount from bos_dai
		where modu_id=@modu_id and pc_id = @pc_id and distribute<>'' and amount <> 0
		order by daicode
declare c_bos_jiedai cursor for select jiecode from bos_jiedai
		where modu_id=@modu_id and pc_id = @pc_id and daicode = @daicode
		order by jiecode

declare c_bos_fol cursor for select pccode,fee_base-fee_disc,fee_serve,fee_tax,fee_disc
        from bos_hfolio where setnumb = @msetnumb
		     order by setnumb,pccode
declare c_bos_act cursor for select distinct a.setnumb,a.code,a.amount
				  from bos_haccount a, bos_hfolio b
			where (@empno is null or a.empno = @empno) 
					and (@shift is null or a.shift = @shift) 
					and datediff(dd,@begin_,a.bdate)>=0 and datediff(dd,@end_,a.bdate)<=0
					and a.setnumb=b.setnumb and (@limpcs is null or charindex(rtrim(b.pccode),@limpcs)>0)
				  order by a.setnumb, a.code

open c_bos_act
fetch c_bos_act into @setnumb,@ccode,@camount
select @msetnumb = @setnumb
while (1 = 1) 
   begin
   if @@sqlstatus <> 0
	  begin
      select @no_more = 1
	  if @msetnumb is null
		 break
	  end
   else if @setnumb = @msetnumb
	  begin
	  if not exists (select * from bos_dai where modu_id=@modu_id and pc_id = @pc_id and daicode = @ccode )
		 insert bos_dai (modu_id,pc_id,daicode,amount) values (@modu_id,@pc_id,@ccode,@camount)
	  else
		 update bos_dai set amount = amount + @camount where modu_id=@modu_id and pc_id = @pc_id and daicode = @ccode
	  fetch c_bos_act into @setnumb,@ccode,@camount
	  continue
	  end

   --  deal with bos_folio 

   open c_bos_fol
   fetch c_bos_fol into @pccode,@fee_base,@fee_serve,@fee_tax,@mper_dsc
   while @@sqlstatus = 0
	  begin
      if charindex(substring(@dsc_sttype,1,1),'yY') = 0 
	     select @mper_dsc = 0
	  if not exists  (select * from bos_jie where modu_id=@modu_id and pc_id = @pc_id and jiecode = @pccode+' ')
		 insert bos_jie (modu_id,pc_id,jiecode,amount,smount,tmount,pmount) values (@modu_id,@pc_id,@pccode,@fee_base,@fee_serve,@fee_tax,@mper_dsc)
	  else
		 update bos_jie set amount = amount + @fee_base,smount = smount +@fee_serve,tmount = tmount +@fee_tax,pmount = pmount + @mper_dsc
					 where modu_id=@modu_id and pc_id = @pc_id and jiecode = @pccode
	  fetch c_bos_fol into @pccode,@fee_base,@fee_serve,@fee_tax,@mper_dsc
	  end
   close c_bos_fol

   --  consider distribution 

--	update bos_dai set distribute = paymth.distribute
--	  from paymth where modu_id=@modu_id and pc_id = @pc_id and paycode = bos_dai.daicode and substring(paymth.distribute,1,1) = 'T'
	update bos_dai set distribute = pccode.deptno8 from pccode
		where bos_dai.modu_id=@modu_id and bos_dai.pc_id = @pc_id and pccode.pccode = bos_dai.daicode and pccode.deptno8<>''
	if exists ( select * from bos_dai where modu_id=@modu_id and pc_id = @pc_id and distribute<>'' and amount <> 0 )
	begin
		select @credit = sum(amount) from bos_dai where modu_id=@modu_id and pc_id = @pc_id
		if @credit <> 0
		begin
			open c_bos_dai_dist
			fetch c_bos_dai_dist into @daicode,@damount
			while @@sqlstatus = 0
			begin
				select @sumpart = 0,@sumpart1 = 0,@sumpart2 = 0,@divval = @damount / @credit
				open c_bos_jie
				fetch c_bos_jie into @jiecode,@jamount,@jsmount,@jtmount
				while @@sqlstatus = 0
					begin
					select @thispart = round( @jamount * @divval ,2),@thispart1 = round( @jsmount * @divval ,2),@thispart2 = round( @jtmount * @divval ,2)
					select @sumpart  = @sumpart + @thispart,@sumpart1  = @sumpart1 + @thispart1,@sumpart2  = @sumpart2 + @thispart2
					insert bos_jiedai (modu_id,pc_id,jiecode,daicode,amount,smount,tmount) values (@modu_id,@pc_id,@jiecode,@daicode,@thispart,@thispart1,@thispart2)
					fetch c_bos_jie into @jiecode,@jamount,@jsmount,@jtmount
					end
				close c_bos_jie

				select @diffpart = @damount - (@sumpart + @sumpart1 + @sumpart2)
				if @diffpart <> 0
				begin 
					open c_bos_jiedai
					fetch c_bos_jiedai into @jiecode
					while @@sqlstatus = 0
					begin
						update bos_jiedai set amount = amount + @diffpart,smount = smount + @diffpart1,tmount = tmount + @diffpart2
							 where modu_id=@modu_id and pc_id = @pc_id and jiecode = @jiecode and daicode =@daicode and (amount <> 0 or smount <> 0 or tmount <> 0)
						if @@rowcount = 1
							break
						fetch c_bos_jiedai into @jiecode
					end
					close c_bos_jiedai
				end 
				fetch c_bos_dai_dist into @daicode,@damount
			end
			close c_bos_dai_dist
		end
	end

   --  adjust  
   update bos_jie set amount = amount - isnull((select sum(amount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and bos_jiedai.jiecode = bos_jie.jiecode),0) where modu_id=@modu_id and pc_id = @pc_id
   update bos_jie set smount = smount - isnull((select sum(smount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and  bos_jiedai.jiecode = bos_jie.jiecode),0) where modu_id=@modu_id and pc_id = @pc_id
   update bos_jie set tmount = tmount - isnull((select sum(tmount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and  bos_jiedai.jiecode = bos_jie.jiecode),0) where modu_id=@modu_id and pc_id = @pc_id
   --update bos_jie set emount = emount + isnull((select sum(amount+smount+tmount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and bos_jiedai.jiecode = bos_jie.jiecode and bos_jiedai.daicode = '994'),0) where modu_id=@modu_id and pc_id = @pc_id
   --update bos_jie set dmount = dmount + isnull((select sum(amount+smount+tmount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and bos_jiedai.jiecode = bos_jie.jiecode and bos_jiedai.daicode <>'994'),0) where modu_id=@modu_id and pc_id = @pc_id
	update bos_jie set emount = emount + isnull((select sum(amount+smount+tmount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and bos_jiedai.jiecode = bos_jie.jiecode and bos_jiedai.daicode in (select pccode from pccode where deptno2 = 'ENT')),0) where modu_id=@modu_id and pc_id = @pc_id
   update bos_jie set dmount = dmount + isnull((select sum(amount+smount+tmount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and bos_jiedai.jiecode = bos_jie.jiecode and bos_jiedai.daicode not in (select pccode from pccode where deptno2 = 'ENT')),0) where modu_id=@modu_id and pc_id = @pc_id
   select @amount = isnull(sum(pmount),0) from bos_jie where modu_id=@modu_id and pc_id = @pc_id
   if @amount <> 0 
	  insert bos_dai (modu_id,pc_id,daicode,daitail,amount) values (@modu_id,@pc_id,'993',char(30),@amount)
   --  attribute #bus_shiftrep_jie data to shiftbosjie 
   open c_bos_jie1
   fetch c_bos_jie1 into @jiecode,@amount,@fee_serve,@fee_tax,@mper_dsc,@damount,@emount
   while @@sqlstatus = 0
	  begin
	  if not exists ( select * from shiftbosjie where modu_id=@modu_id and pc_id = @pc_id and code = @jiecode)
		 insert shiftbosjie (modu_id,pc_id,date,code,fee_bas,fee_sur,fee_tax,fee_dsc,fee_ent) values (@modu_id,@pc_id,@bfdate,@jiecode,@amount,@fee_serve,@fee_tax,@mper_dsc+@damount,@emount)
	  else
		 update shiftbosjie set date = @bfdate,fee_bas = fee_bas + @amount,fee_tax = fee_tax + @fee_tax,fee_sur = fee_sur + @fee_serve,fee_dsc = fee_dsc + @mper_dsc+@damount,fee_ent = fee_ent + @emount
							   where modu_id=@modu_id and pc_id = @pc_id and code = @jiecode
	  fetch c_bos_jie1 into @jiecode,@amount,@fee_serve,@fee_tax,@mper_dsc,@damount,@emount
	  end
   close c_bos_jie1
   --  attribute #dai data to deptdai 
   open c_bos_dai
   fetch c_bos_dai into @daicode,@daitail,@amount
   while @@sqlstatus = 0
	  begin
	  if not exists ( select * from shiftbosdai where modu_id=@modu_id and pc_id = @pc_id and paycode = @daicode and paytail = @daitail)
		 insert shiftbosdai (modu_id,pc_id,date,paycode,paytail,creditd) values (@modu_id,@pc_id,@bfdate,@daicode,@daitail,@amount)
      else 
		 update shiftbosdai set date = @bfdate,creditd = creditd + @amount
					   where modu_id=@modu_id and pc_id = @pc_id and paycode = @daicode and paytail = @daitail
	  fetch c_bos_dai into @daicode,@daitail,@amount
	  end
   close c_bos_dai
   if @no_more = 1
	  break
   select @msetnumb = @setnumb
   delete bos_jie where modu_id=@modu_id and pc_id = @pc_id 
   delete bos_dai where modu_id=@modu_id and pc_id = @pc_id
   delete bos_jiedai where modu_id=@modu_id and pc_id = @pc_id
   insert bos_dai (modu_id,pc_id,daicode,amount) values (@modu_id,@pc_id,@ccode,@camount)
   fetch c_bos_act into @setnumb,@ccode,@camount
   end
close c_bos_act

-- update titles  
update shiftbosjie  set fee_ttl  = fee_bas+fee_sur+fee_tax+fee_dsc+fee_ent
update shiftbosjie  set descript = bos_pccode.descript from bos_pccode 
	where substring(shiftbosjie.code,1,5)=bos_pccode.pccode

update shiftbosdai  set descript = pccode.descript
	from pccode where shiftbosdai.paycode = pccode.pccode

update shiftbosdai  set descript = '百分比折' where paycode = '993' and paytail = char(30)

select @no_more = 1

declare c_bos_s_jie cursor for select code from shiftbosjie where modu_id=@modu_id and pc_id = @pc_id order by code
open c_bos_s_jie
fetch c_bos_s_jie into @code
while @@sqlstatus = 0
   begin
   update shiftbosjie set order_ = @no_more where modu_id=@modu_id and pc_id = @pc_id and code = @code
   select @no_more = @no_more + 1 
   fetch c_bos_s_jie into @code
   end
close c_bos_s_jie
deallocate cursor c_bos_s_jie

select @no_more = 1

declare c_bos_s_dai cursor for select paycode from shiftbosdai where modu_id=@modu_id and pc_id = @pc_id order by paycode
open c_bos_s_dai
fetch c_bos_s_dai into @code
while @@sqlstatus = 0
   begin
   update shiftbosdai set order_ = @no_more where modu_id=@modu_id and pc_id = @pc_id and paycode = @code
   select @no_more = @no_more + 1 
   fetch c_bos_s_dai into @code
   end
close c_bos_s_dai
deallocate cursor c_bos_s_dai

--  deallocate cursor previous cursors 
deallocate cursor c_bos_jie
deallocate cursor c_bos_jie1
deallocate cursor c_bos_dai
deallocate cursor c_bos_dai_dist
deallocate cursor c_bos_jiedai
deallocate cursor c_bos_fol
deallocate cursor c_bos_act

select @ret,@msg
return @ret
;
