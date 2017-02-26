drop proc p_gds_audit_gststa1;
create proc p_gds_audit_gststa1
	@ret				integer		out,
	@msg				varchar(70)	out
as
-- ------------------------------
--	境内为主
-- ------------------------------
declare
	@bdate			datetime,
	@bfdate			datetime,
	@duringaudit	char(1),
	@heji				char(2),
	@jingwai			char(2),
	@jingnei			char(2),
	@shengnei		char(2),
	@shengwai		char(2),
	@buxiang			char(2),
//	@heji				varchar(3),
//	@jingwai			varchar(3),
//	@jingnei			varchar(3),
//	@shengnei		varchar(3),
//	@shengwai		varchar(3),
//	@buxiang			varchar(3),
	@class			char(1),
	@isfstday		char(1),
	@isyfstday		char(1),
	@accnt			varchar(10),
	@bdate1			datetime,	--master_last表bdate
	@nation			char(3),
	@arr				datetime,
	@wherefrom		char(6),
	@ident			char(20),   -- wherefrom为空的，用身份证的取身份证前6位 xia
	@lclpro			char(2),
	@groupno			char(10),
	@dgt				integer,
	@dmt				integer,
	@dgc				integer,
	@dmc				integer,
	@chncode       varchar(3),
	@flag1			varchar(3),
	@sta				char(1),
	@prv				char(3)

select @ret = 0, @msg = ''
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)
select @lclpro = value from sysoption where catalog = 'hotel' and item = 'lclpro'
select @lclpro = max(prv) from cntcode where substring(code,1,2) = @lclpro 
-- added by hry---2009.2.13------------------------
select @chncode = short from countrycode where code='CHN'
if rtrim(@chncode) is null
   select @chncode = short from countrycode where code='CN'
-- added by hry---2009.2.13------------------------
select @heji = '10', @jingwai = '20', @jingnei = '30', @shengnei = '40', @shengwai = '50', @buxiang = '60'
if not exists (select 1 from gststa1 where gclass = @heji)
	insert gststa1 (date, gclass, descript) values (@bfdate, @heji, '合计')
if not exists (select 1 from gststa1 where gclass = @jingwai)
	insert gststa1 (date, gclass, descript) values (@bfdate, @jingwai, '  境外')
if not exists (select 1 from gststa1 where gclass = @jingnei)
	insert gststa1 (date, gclass, descript) values (@bfdate, @jingnei, '  境内')
if not exists (select 1 from gststa1 where gclass = @shengnei)
	insert gststa1 (date, gclass, descript) values (@bfdate, @shengnei, '---省内---')
if not exists (select 1 from gststa1 where gclass = @shengwai)
	insert gststa1 (date, gclass, descript) values (@bfdate, @shengwai, '---省外---')
if not exists (select 1 from gststa1 where gclass = @buxiang)
	insert gststa1 (date, gclass, descript) values (@bfdate, @buxiang, '--地址不详--')
if exists (select 1 from gststa1 where date = @bdate)
	update gststa1 set
		mtc = mtc-dtc, mtt = mtt-dtt, mgc = mgc-dgc, mgt = mgt-dgt, mmc = mmc-dmc, mmt = mmt-dmt,
		ytc = ytc-dtc, ytt = ytt-dtt, ygc = ygc-dgc, ygt = ygt-dgt, ymc = ymc-dmc, ymt = ymt-dmt
update gststa1 set dtc = 0, dtt = 0, dgc = 0, dgt = 0, dmc = 0, dmt = 0, date = @bfdate

                 
declare c_guest cursor for select a.accnt, isnull(c.short, @chncode),isnull(c.flag1,''), a.bdate,a.wherefrom,b.ident,a.groupno
	from master_till a, guest b, countrycode c
	where a.haccnt = b.no and (a.sta='I' or (a.sta in ('S','O') and not exists(select 1 from master_last d where d.accnt=a.accnt and d.sta in ('I','S')))) and substring(a.extra,1,1) <> '1' and a.class='F' and b.nation *= c.code
open c_guest
fetch c_guest into @accnt, @nation, @flag1, @arr, @wherefrom,@ident,@groupno
while @@sqlstatus = 0
	begin
--
	select @sta = sta from master_till where accnt=@accnt
	if exists(select 1 from master_last where accnt=@accnt AND sta='I')
		select @arr = bdate from master_last
--wherefrom为空的，用身份证的取身份证前6位 xia  20090218
	if rtrim(@wherefrom ) = null and rtrim(@ident) <> null and datalength(rtrim(@ident))>= 15  
		select @wherefrom = substring(@ident,1,6)
	if not exists (select code from cntcode where code = @wherefrom )
		 select @wherefrom = space(6)  
	if rtrim(@wherefrom) is null
		select @wherefrom = space(6)
	-- 赶在 @nation 变化前，捕获 @prv 
	select @prv=isnull((select prv from cntcode where code=@wherefrom), '')
                                                                                       

	-- 提取 @nation.flag 
	if @flag1<>'' and rtrim(@flag1)<> null
		select @nation=@flag1

	if @groupno<>''
		begin
		if @groupno like 'G%'
			select @dgt = 1, @dmt = 0, @dgc = 1, @dmc = 0
		else
			select @dgt = 0, @dmt = 1, @dgc = 0, @dmc = 1
		if @arr <= @bdate and @sta='I'
			begin
			update gststa1 set dgt = dgt + @dgt, dmt = dmt + @dmt where gclass = @heji
			if @nation <> 'CN'
				update gststa1 set dgt = dgt + @dgt, dmt = dmt + @dmt where gclass = @jingwai
			else
				begin
				update gststa1 set dgt = dgt + @dgt, dmt = dmt + @dmt where gclass = @jingnei
				if rtrim(@wherefrom) is null
					update gststa1 set dgt = dgt + @dgt, dmt = dmt + @dmt where gclass = @buxiang
				else if @prv <> @lclpro -- substring(@wherefrom, 1, 2) <> @lclpro
					begin
					update gststa1 set dgt = dgt + @dgt, dmt = dmt + @dmt where gclass = @shengwai
					if not exists (select 1 from gststa1 where gclass=substring(@shengwai, 1, 1) + '1' and wfrom=@prv)
						begin
						insert gststa1 (date, gclass, wfrom) values (@bfdate, substring(@shengwai, 1, 1) + '1', @prv)
						update gststa1 set descript = prvcode.descript from prvcode
							where gclass=substring(@shengwai, 1, 1) + '1' and  wfrom = prvcode.code 
						end
					update gststa1 set dgt = dgt + @dgt, dmt = dmt + @dmt where gclass=substring(@shengwai, 1, 1) + '1' and  wfrom=@prv 
					end
				else
					begin
					update gststa1 set dgt = dgt + @dgt, dmt = dmt + @dmt where gclass = @shengnei
					if not exists (select * from gststa1 where gclass=substring(@shengnei, 1, 1) + '1' and  wfrom = @wherefrom)
						begin
						insert gststa1 (date, gclass, wfrom) values (@bfdate, substring(@shengnei, 1, 1) + '1', @wherefrom)
						update gststa1 set descript = cntcode.descript from cntcode
							where gclass=substring(@shengnei, 1, 1) + '1' and  wfrom = @wherefrom
							and @wherefrom = cntcode.code
						end
					update gststa1 set dgt = dgt + @dgt, dmt = dmt + @dmt where gclass=substring(@shengnei, 1, 1) + '1' and  wfrom = @wherefrom
					end
				end
		 	end
	 	if @arr =  @bdate
			begin
			update gststa1 set dgc = dgc + @dgc, dmc = dmc + @dmc where gclass = @heji
			if @nation <> @chncode
				update gststa1 set dgc = dgc + @dgc, dmc = dmc + @dmc where gclass = @jingwai
			else
				begin
				update gststa1 set dgc = dgc + @dgc, dmc = dmc + @dmc where gclass = @jingnei
				if rtrim(@wherefrom) is null
					update gststa1 set dgc = dgc + @dgc, dmc = dmc + @dmc where gclass = @buxiang
				else if @prv <> @lclpro
					begin
					update gststa1 set dgc = dgc + @dgc, dmc = dmc + @dmc where gclass = @shengwai
					if not exists (select * from gststa1 where gclass=substring(@shengwai, 1, 1) + '1' and  wfrom = @prv)
						begin
						insert gststa1 (date, gclass, wfrom) values (@bfdate, substring(@shengwai, 1, 1) + '1', @prv)
						update gststa1 set descript = prvcode.descript from prvcode
							where gclass=substring(@shengwai, 1, 1) + '1' and  wfrom = prvcode.code
						end
					update gststa1 set dgc = dgc + @dgc, dmc = dmc + @dmc where gclass=substring(@shengwai, 1, 1) + '1' and  wfrom = @prv 
					end
				else
					begin
					update gststa1 set dgc = dgc + @dgc, dmc = dmc + @dmc where gclass = @shengnei
					if not exists (select * from gststa1 where gclass=substring(@shengnei, 1, 1) + '1' and  wfrom = @wherefrom)
						begin
						insert gststa1 (date, gclass, wfrom) values (@bfdate, substring(@shengnei, 1, 1) + '1', @wherefrom)
						update gststa1 set descript = cntcode.descript from cntcode
							where gclass=substring(@shengnei, 1, 1) + '1' and  wfrom = @wherefrom
							and @wherefrom = cntcode.code
						end
					update gststa1 set dgc = dgc + @dgc, dmc = dmc + @dmc where gclass=substring(@shengnei, 1, 1) + '1' and  wfrom = @wherefrom
					end
				end
			end
		end
	else
		begin
		if @arr <= @bdate and @sta='I'
			begin
			update gststa1 set dtt = dtt + 1 where gclass = @heji
			if @nation <> @chncode
				update gststa1 set dtt = dtt + 1 where gclass = @jingwai
			else
				begin
				update gststa1 set dtt = dtt + 1 where gclass = @jingnei
				if rtrim(@wherefrom) is null
					update gststa1 set dtt = dtt + 1 where gclass = @buxiang
				else if @prv <> @lclpro
					begin
					update gststa1 set dtt = dtt + 1 where gclass = @shengwai
					if not exists (select * from gststa1 where gclass=substring(@shengwai, 1, 1) + '1' and  wfrom =@prv)
						begin
						insert gststa1 (date, gclass, wfrom) values (@bfdate, substring(@shengwai, 1, 1) + '1', @prv)
						update gststa1 set descript = prvcode.descript from prvcode
							where gclass=substring(@shengwai, 1, 1) + '1' and  wfrom = prvcode.code
						end
					update gststa1 set dtt = dtt + 1 where gclass=substring(@shengwai, 1, 1) + '1' and  wfrom = @prv 
					end
				else
					begin
					update gststa1 set dtt = dtt + 1 where gclass = @shengnei
					if not exists (select * from gststa1 where gclass=substring(@shengnei, 1, 1) + '1' and  wfrom = @wherefrom)
						begin
						insert gststa1 (date, gclass, wfrom) values (@bfdate, substring(@shengnei, 1, 1) + '1', @wherefrom)
						update gststa1 set descript = cntcode.descript from cntcode
							where gclass=substring(@shengnei, 1, 1) + '1' and  wfrom = @wherefrom
							and @wherefrom = cntcode.code

						end
					update gststa1 set dtt = dtt + 1 where gclass=substring(@shengnei, 1, 1) + '1' and  wfrom = @wherefrom
					end
				end
			end
		if @arr =  @bdate
			begin
			update gststa1 set dtc = dtc + 1 where gclass = @heji
			if @nation <> @chncode
				update gststa1 set dtc = dtc + 1 where gclass = @jingwai
			else
				begin
				update gststa1 set dtc = dtc + 1 where gclass = @jingnei
				if rtrim(@wherefrom) is null
					update gststa1 set dtc = dtc + 1 where gclass = @buxiang
				else if @prv <> @lclpro
					begin
					update gststa1 set dtc = dtc + 1 where gclass = @shengwai
					if not exists (select * from gststa1 where gclass=substring(@shengwai, 1, 1) + '1' and  wfrom = @prv)
						begin
						insert gststa1 (date, gclass, wfrom) values (@bfdate, substring(@shengwai, 1, 1) + '1', @prv)
						update gststa1 set descript = prvcode.descript from prvcode
							where gclass=substring(@shengwai, 1, 1) + '1' and  wfrom = prvcode.code
						end
					update gststa1 set dtc = dtc + 1 where gclass=substring(@shengwai, 1, 1) + '1' and  wfrom = @prv
					end
				else
					begin
					update gststa1 set dtc = dtc + 1 where gclass = @shengnei
					if not exists (select * from gststa1 where gclass=substring(@shengnei, 1, 1) + '1' and  wfrom = @wherefrom)
						begin
						insert gststa1 (date, gclass, wfrom) values (@bfdate, substring(@shengnei, 1, 1) + '1', @wherefrom)
						update gststa1 set descript =  cntcode.descript from cntcode
							where gclass=substring(@shengnei, 1, 1) + '1' and  wfrom = @wherefrom
							and @wherefrom = cntcode.code

						end
					update gststa1 set dtc = dtc + 1 where gclass=substring(@shengnei, 1, 1) + '1' and  wfrom = @wherefrom
					end
				end
			end
		end
	fetch c_guest into @accnt, @nation, @flag1, @arr, @wherefrom,@ident,@groupno
	end
close c_guest
deallocate cursor c_guest
exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @isfstday = 'T'
	update gststa1 set mtc = dtc, mtt = dtt, mgc = dgc, mgt = dgt, mmc = dmc, mmt = dmt
else
	update gststa1 set mtc = mtc + dtc, mtt = mtt + dtt, mgc = mgc + dgc, mgt = mgt + dgt, mmc = mmc + dmc, mmt = mmt + dmt
if @isyfstday = 'T'
	update gststa1 set ytc = dtc, ytt = dtt, ygc = dgc, ygt = dgt, ymc = dmc, ymt = dmt
else
	update gststa1 set ytc = ytc + dtc, ytt = ytt + dtt, ygc = ygc + dgc, ygt = ygt + dgt, ymc = ymc + dmc, ymt = ymt + dmt
update gststa1 set date = @bdate
delete ygststa1 where  date = @bdate
insert ygststa1 select gststa1.date, gststa1.gclass, gststa1.wfrom, gststa1.descript, gststa1.descript1, gststa1.sequence, gststa1.dtc, gststa1.dgc, gststa1.dmc, gststa1.dtt, gststa1.dgt, gststa1.dmt, gststa1.mtc, gststa1.mgc, gststa1.mmc, gststa1.mtt, gststa1.mgt, gststa1.mmt, gststa1.ytc, gststa1.ygc, gststa1.ymc, gststa1.ytt, gststa1.ygt, gststa1.ymt from gststa1
return @ret

;