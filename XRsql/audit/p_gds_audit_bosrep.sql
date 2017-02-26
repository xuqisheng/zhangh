// -----------------------------------------------------------------------------
//	BOS 报表
// -----------------------------------------------------------------------------
if exists ( select * from sysobjects where name = 'p_gds_audit_bosrep' and type ='P')
	drop proc p_gds_audit_bosrep;
create proc p_gds_audit_bosrep
	@pc_id			char(4), 
	@retmode			char(1),  
	@ret				integer		out, 
	@msg				varchar(70)	out
as

declare
	@bdate			datetime, 
	@bfdate			datetime, 
	@duringaudit	char(1) , 
	@dsc_sttype		char(2) , 
	@isfstday		char(1) , 
	@isyfstday		char(1) ,  
	@pccode			char(5), 		--营业点
	@shift			char(1), 	 	--班  别
	@hshift			char(1), 	 
	@empno			char(10), 	 	--工  号
	@hempno			char(10), 	 
	@code				char(5), 	
	@ccode			char(5), 	
	@descript		char(12),  	--代码描述
	@amount			money, 		--金额
	@camount			money, 		--金额
	@i					integer, 
	@j					integer, 
	@k					integer, 
	@mper_dsc		money, 
	@jiecode			char(5), 
	@daicode			char(5), 
	@daitail			char(1), 
	@jamount			money, 
	@damount			money, 
	@thispart		money, 
	@thispart1		money, 
	@thispart2		money, 
	@sumpart			money, 
	@sumpart1		money, 
	@sumpart2		money, 
	@divval			money, 
	@diffpart		money, 
	@diffpart1		money, 
	@diffpart2		money, 
	@credit			money, 
	@setnumb			char(10), 
	@msetnumb		char(10), 
	@fee_base		money, 
	@fee_serve		money, 
	@fee_tax			money, 
	@fee_disc		money, 
	@pfee_base		money, 
	@pfee_serve		money, 
	@pfee_tax		money, 
	@jsmount			money, 
	@jtmount			money, 
	@no_more			integer, 
	@emount			money

select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate), @ret=0, @msg='', @diffpart1=0, @diffpart2=0

select @dsc_sttype = value from sysoption where catalog = 'bos' and item = 'dsc_sttype'
if @@rowcount = 0
	select @dsc_sttype ='yy'
select @mper_dsc = 0
exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @isfstday = 'T'
	begin	 
	truncate table bosjie
	truncate table bosdai
	end

begin tran
update bosjie set fee_basm = fee_basm-fee_bas, fee_surm = fee_surm-fee_sur, fee_taxm = fee_taxm-fee_tax,
	fee_dscm = fee_dscm-fee_dsc, fee_entm = fee_entm-fee_ent, 
	fee_ttlm = fee_ttlm-fee_ttl where date = @bdate
update bosjie set fee_bas = 0, fee_sur = 0, fee_tax = 0, fee_dsc = 0, fee_ent = 0, 
	fee_ttl = 0, daymark = ' ', date = @bfdate
update bosdai set creditm = creditm - creditd where date = @bdate
update bosdai set creditd = 0, daymark = ' ', date = @bfdate
commit tran

delete bos_jie	  where pc_id = @pc_id and modu_id='99'  // 99 - audit
delete bos_dai	  where pc_id = @pc_id and modu_id='99'
delete bos_jiedai  where pc_id = @pc_id and modu_id='99'

declare c_bosrep_jie cursor for select jiecode, amount, smount, tmount
	from bos_jie where modu_id='99' and pc_id = @pc_id order by jiecode
declare c_bosrep_jie1 cursor for select jiecode, amount, smount, tmount, pmount, dmount, emount
	from bos_jie where modu_id='99' and pc_id = @pc_id order by jiecode

declare c_bosrep_dai cursor for select daicode, daitail, amount
	from bos_dai where modu_id='99' and pc_id = @pc_id order by daicode
declare c_bosrep_dai_dist cursor for select daicode, amount
	from bos_dai where modu_id='99' and pc_id = @pc_id and distribute <> '' and amount <> 0

declare c_bosrep_jiedai cursor for select jiecode
	from bos_jiedai where modu_id='99' and pc_id = @pc_id and daicode = @daicode order by jiecode
declare c_bosrep_fol cursor for select pccode, fee_base-fee_disc, fee_serve, fee_tax, fee_disc, pfee_base, pfee_serve
	from bos_hfolio where setnumb = @msetnumb
declare c_bosrep_act cursor for select setnumb, code, amount, empno, shift
	from bos_haccount where bdate = @bdate order by setnumb

open c_bosrep_act
fetch c_bosrep_act into @setnumb, @ccode, @camount, @empno, @shift
select @msetnumb = @setnumb
while (1=1) 
	begin
	if @@sqlstatus <> 0
		begin
		select @no_more = 1
		if @msetnumb is null
			break
		end
	else if @setnumb = @msetnumb
		begin
		if not exists (select * from bos_dai  where modu_id = '99' and pc_id = @pc_id and daicode = @ccode )
			insert bos_dai  ( modu_id, pc_id , daicode, amount) values ('99', @pc_id, @ccode, @camount)
		else
			update bos_dai  set amount = amount + @camount where modu_id = '99' and pc_id = @pc_id and daicode = @ccode
		fetch c_bosrep_act into @setnumb, @ccode, @camount, @empno, @shift
		continue
		end
	-- deal with bos_folio 
	open c_bosrep_fol
	fetch c_bosrep_fol into @pccode, @fee_base, @fee_serve, @fee_tax, @fee_disc, @pfee_base, @pfee_serve
	while @@sqlstatus = 0
		begin
		if charindex(substring(@dsc_sttype, 1, 1), 'yY') > 0
		begin
//			select @mper_dsc = round(@pfee_base + @pfee_serve - @fee_base - @fee_serve, 2)
			select @mper_dsc = round(@fee_disc, 2)
		end

		if not exists  (select * from bos_jie where modu_id = '99' and pc_id = @pc_id and jiecode = @pccode + ' ')
			insert bos_jie (modu_id, pc_id ,  jiecode, amount, smount, tmount, pmount) values ('99', @pc_id , @pccode, @fee_base, @fee_serve, @fee_tax, @mper_dsc)
		else
			update bos_jie set amount = amount + @fee_base, smount = smount  + @fee_serve, tmount = tmount  + @fee_tax, pmount = pmount + @mper_dsc
				where  modu_id='99' and pc_id = @pc_id and jiecode = @pccode
		fetch c_bosrep_fol into @pccode, @fee_base, @fee_serve, @fee_tax, @fee_disc, @pfee_base, @pfee_serve
		end
	close c_bosrep_fol

	-- consider distribution 
--	update bos_dai set distribute = paymth.distribute from paymth 
--		where modu_id='99' and pc_id = @pc_id and paycode = bos_dai.daicode and substring(paymth.distribute, 1, 1) = 'T'
	update bos_dai set distribute = pccode.deptno8 from pccode 
		where modu_id='99' and pc_id = @pc_id and pccode = bos_dai.daicode and pccode.deptno8<>''
	if exists ( select * from bos_dai  where distribute <> '' and amount <> 0 and modu_id='99' and pc_id=@pc_id)
		begin
		select @credit = sum(amount) from bos_dai where modu_id='99' and pc_id=@pc_id
		if @credit <> 0
			begin
			open c_bosrep_dai_dist
			fetch c_bosrep_dai_dist into @daicode, @damount
			while @@sqlstatus = 0
				begin
				select @sumpart = 0, @sumpart1 = 0, @sumpart2 = 0, @divval = @damount / @credit
  				open c_bosrep_jie
				fetch c_bosrep_jie into @jiecode, @jamount, @jsmount, @jtmount
				while @@sqlstatus = 0
					begin
					select @thispart = round( @jamount * @divval , 2), @thispart1 = round( @jsmount * @divval , 2), @thispart2 = round( @jtmount * @divval , 2)
					select @sumpart  = @sumpart + @thispart, @sumpart1  = @sumpart1 + @thispart1, @sumpart2  = @sumpart2 + @thispart2
					insert bos_jiedai (modu_id, pc_id, jiecode, daicode, amount, smount, tmount) values ('99', @pc_id, @jiecode, @daicode, @thispart, @thispart1, @thispart2)
					fetch c_bosrep_jie into @jiecode, @jamount, @jsmount, @jtmount
					end
				close c_bosrep_jie
				select @diffpart = @damount - (@sumpart + @sumpart1 + @sumpart2)
				if @diffpart <> 0
					begin 
					open c_bosrep_jiedai
					fetch c_bosrep_jiedai into @jiecode
					while @@sqlstatus = 0
				 		begin
						update bos_jiedai set amount = amount + @diffpart, smount = smount + @diffpart1, tmount = tmount + @diffpart2
							where modu_id='99' and pc_id = @pc_id and jiecode = @jiecode and daicode =@daicode and (amount <> 0 or smount <> 0 or tmount <> 0)
						if @@rowcount = 1
							break
						fetch c_bosrep_jiedai into @jiecode
						end
					close c_bosrep_jiedai
					end 
				fetch c_bosrep_dai_dist into @daicode, @damount
			end
		close c_bosrep_dai_dist
		end
	end
	-- adjust  
	update bos_jie set amount = amount - isnull((select sum(amount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and bos_jiedai.modu_id = '99' and bos_jiedai.jiecode = bos_jie.jiecode), 0) where pc_id = @pc_id and modu_id='99'
	update bos_jie set smount = smount - isnull((select sum(smount) from bos_jiedai where  bos_jiedai.pc_id = @pc_id and bos_jiedai.modu_id = '99' and bos_jiedai.jiecode = bos_jie.jiecode), 0) where pc_id = @pc_id and modu_id='99'
	update bos_jie set tmount = tmount - isnull((select sum(tmount) from bos_jiedai where  bos_jiedai.pc_id = @pc_id and bos_jiedai.modu_id = '99' and bos_jiedai.jiecode = bos_jie.jiecode), 0) where pc_id = @pc_id and modu_id='99'
	update bos_jie set emount = emount + isnull((select sum(amount + smount + tmount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and bos_jiedai.modu_id = '99' and bos_jiedai.jiecode = bos_jie.jiecode and bos_jiedai.daicode in (select pccode from pccode where deptno2 = 'ENT')), 0) where pc_id = @pc_id and modu_id='99'
	update bos_jie set dmount = dmount + isnull((select sum(amount + smount + tmount) from bos_jiedai where bos_jiedai.pc_id = @pc_id and bos_jiedai.modu_id = '99' and bos_jiedai.jiecode = bos_jie.jiecode and bos_jiedai.daicode not in (select pccode from pccode where deptno2 = 'ENT')), 0) where pc_id = @pc_id and modu_id='99'
	select @amount = isnull(sum(pmount), 0) from bos_jie where pc_id = @pc_id and modu_id='99'
	if @amount <> 0 
		insert bos_dai (modu_id, pc_id, daicode, daitail, amount) values ('99', @pc_id, '993', char(30), @amount)
	-- attribute bos_jie data to bosjie 
	open c_bosrep_jie1
	fetch c_bosrep_jie1 into @jiecode, @amount, @fee_serve, @fee_tax, @mper_dsc, @damount, @emount
	while @@sqlstatus = 0
		begin
		select @i = 0
		while @i < 2
	  		begin
	 		if @i = 0
		 		select @hshift = @shift
	 		else
		 		select @hshift = '9'
			select @j = 0
			while  @j < 2
				begin
	 			if @j = 0
		 			select @hempno = @empno
				else
					select @hempno = '{{{'
				if not exists ( select 1 from bosjie where shift = @hshift and empno = @hempno and code = @jiecode)
					insert bosjie (date, shift, empno, code, fee_bas, fee_sur, fee_tax, fee_dsc, fee_ent, daymark) 
						values (@bfdate, @hshift, @hempno, @jiecode, @amount, @fee_serve, @fee_tax, @mper_dsc + @damount, @emount, 'D')
				else
					update bosjie set date = @bfdate, daymark = 'D', fee_bas = fee_bas + @amount, 
						fee_sur = fee_sur + @fee_serve, fee_tax = fee_tax + @fee_tax, fee_dsc = fee_dsc + @mper_dsc + @damount, fee_ent = fee_ent + @emount
						where shift = @hshift and empno = @hempno and code = @jiecode
				if not exists ( select * from bosjie where shift = @hshift and empno = @hempno and code = '999')
					insert bosjie (date, shift, empno, code, fee_bas, fee_sur, fee_tax, fee_dsc, fee_ent, daymark) values (@bfdate, @hshift, @hempno, '999', @amount, @fee_serve, @fee_tax, @mper_dsc + @damount, @emount, 'D')
				else
					update bosjie set date = @bfdate, daymark = 'D', fee_bas = fee_bas + @amount, fee_sur = fee_sur + @fee_serve, fee_tax = fee_tax + @fee_tax, fee_dsc = fee_dsc + @mper_dsc + @damount, fee_ent = fee_ent + @emount
						where shift = @hshift and empno = @hempno and code = '999'
				select @j = @j + 1
				end
			select @i = @i + 1
			end
		fetch c_bosrep_jie1 into @jiecode, @amount, @fee_serve, @fee_tax, @mper_dsc, @damount, @emount
		end
	close c_bosrep_jie1
	-- attribute bos_dai  data to deptdai 
	open c_bosrep_dai
	fetch c_bosrep_dai into @daicode, @daitail, @amount
	while @@sqlstatus = 0
		begin
		select @i = 0
		while  @i < 2
	  		begin
			if @i = 0
				select @hshift = @shift
	 		else
				select @hshift = '9'
			select @j = 0
			while  @j < 2
				begin
				if @j = 0
					select @hempno = @empno
				else
					select @hempno = '{{{'
			 	if not exists ( select * from bosdai where shift = @hshift and empno = @hempno and paycode = @daicode and paytail = @daitail)
					insert bosdai (date, shift, empno, paycode, paytail, creditd, daymark) 
						values (@bfdate, @hshift, @hempno, @daicode, @daitail, @amount, 'D')
				else 
					update bosdai set date = @bfdate, daymark = 'D', creditd = creditd + @amount
						where shift = @hshift and empno = @hempno and paycode = @daicode and paytail = @daitail 
				if not exists ( select * from bosdai where shift = @hshift and empno = @hempno and paycode = '999')
					insert bosdai (date, shift, empno, paycode, creditd, daymark) values (@bfdate, @hshift, @hempno, '999', @amount, 'D')
				else 
					update bosdai set date = @bfdate, daymark = 'D', creditd = creditd + @amount
						where shift = @hshift and empno = @hempno and paycode = '999'
				select @j = @j + 1
				end
			select @i = @i + 1
			end
		fetch c_bosrep_dai into @daicode, @daitail, @amount
		end
	close c_bosrep_dai
	if @no_more = 1
		break
	select @msetnumb = @setnumb
	delete bos_jie	where modu_id='99' and pc_id = @pc_id
	delete bos_dai	where modu_id='99' and pc_id = @pc_id
	delete bos_jiedai where modu_id='99' and pc_id = @pc_id
	insert bos_dai (modu_id,pc_id, daicode, amount) values ('99', @pc_id, @ccode, @camount)
	fetch c_bosrep_act into @setnumb, @ccode, @camount, @empno, @shift
	end
close c_bosrep_act
--update titles  
update bosjie set fee_ttl  = fee_bas + fee_sur + fee_tax + fee_dsc + fee_ent 
update bosjie set descript = bos_pccode.descript from bos_pccode 
	where substring(bosjie.code, 1, 5)=bos_pccode.pccode and bosjie.code <> '999'
update bosjie set descript = '合	 计' where code = '999'

update bosdai set descript = pccode.descript
	from pccode where bosdai.paycode = pccode.pccode

update bosdai set descript = '百分比折' where paycode = '993' and paytail = char(30)
update bosdai set descript = '合	 计' where paycode = '999'
begin tran
if @isfstday = 'T'
	update bosjie  set 
		fee_basm = fee_bas, fee_surm = fee_sur, fee_taxm = fee_tax, fee_dscm = fee_dsc, 
		fee_entm = fee_ent, fee_ttlm = fee_ttl, date = @bdate
else
	update bosjie  set 
		fee_basm = fee_basm + fee_bas, fee_surm = fee_surm + fee_sur, fee_taxm = fee_taxm + fee_tax, 
		fee_dscm = fee_dscm + fee_dsc, fee_entm = fee_entm + fee_ent, 
		fee_ttlm = fee_ttlm + fee_ttl, date = @bdate
if @isfstday = 'T'
	update bosdai set creditm = creditd, date = @bdate
else
	update bosdai set creditm = creditm + creditd, date = @bdate
commit tran

begin tran
delete ybosjie where date = @bdate
insert ybosjie select * from bosjie
delete ybosdai where date = @bdate
insert ybosdai select * from bosdai
commit tran

deallocate cursor c_bosrep_jie
deallocate cursor c_bosrep_jie1
deallocate cursor c_bosrep_dai
deallocate cursor c_bosrep_dai_dist
deallocate cursor c_bosrep_jiedai
deallocate cursor c_bosrep_fol
deallocate cursor c_bosrep_act

if @retmode = 'S'
	select @ret, @msg 

return @ret
;


