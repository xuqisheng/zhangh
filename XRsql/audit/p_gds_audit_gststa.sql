drop proc p_gds_audit_gststa ;
create proc p_gds_audit_gststa 
	@ret				integer		out,
	@msg				varchar(70)	out
as
-- ------------------------------
--	����Ϊ�� 
-- 2009.7.20 @lclpro ���жϸ��� prvcode.code=cntcode.prv 
-- ------------------------------
declare
	@bdate			datetime,
	@bfdate			datetime,
	@duringaudit	char(1),
	@heji				varchar(1),
	@shengnei		varchar(1),
	@shengwai		varchar(1),
	@jingwai			varchar(1),
	@huaqiao			varchar(2),
	@hongkong		varchar(2),
	@taiwan			varchar(2),
	@macao			varchar(2),
	@waibin			varchar(2),
	@class			char(1),
	@isfstday		char(1),
	@isyfstday		char(1),
	@accnt			varchar(10),
	@nation			char(3),
	@arr				datetime,
	@wherefrom		char(6),
	@ident			char(20),
	@lclpro			char(2),
	@groupno			char(10),
	@dgt				integer,
	@dmt				integer,
	@dgc				integer,
	@dmc				integer,
	@flag1			char(3),
	@chncode       varchar(3),
	@noaddress     varchar(2),
	@sta				char(1),
	@prv				char(3) 


select @ret = 0, @msg = ''
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)

select @lclpro = rtrim(value) from sysoption where catalog ='hotel' and item = 'lclpro'
--add
select @lclpro = rtrim(code) from prvcode where s_zip =  @lclpro
--add end

-- added by hry---2009.2.13------------------------
select @chncode = code from countrycode where code='CHN'
if rtrim(@chncode) is null
   select @chncode = code from countrycode where code='CN'
-- added by hry---2009.2.13------------------------

 
--
select @heji ='1', @shengnei='2', @shengwai='3', @jingwai ='4'
select @huaqiao='00', @hongkong='01', @taiwan  ='02', @macao	='03', @waibin  ='04'
select @noaddress='00'

if not exists (select 1from gststa where rtrim(gclass) = @heji)
	insert gststa (date, gclass, order_, descript, descript1,nation) values (@bfdate, @heji, '', '��     ��', 'Total','')
if not exists (select 1 from gststa where rtrim(gclass) = @shengnei)
	insert gststa (date, gclass, order_, descript, descript1 ,nation) values (@bfdate, @shengnei, '', 'ʡ  ��', 'Province Inside','')
if not exists (select 1 from gststa where rtrim(gclass) = @shengwai)
	insert gststa (date, gclass, order_, descript, descript1,nation) values (@bfdate, @shengwai, '', 'ʡ  ��', 'Province Outside','')
if not exists (select 1 from gststa where rtrim(gclass) = @shengnei and order_=@noaddress)
	insert gststa (date, gclass, order_, descript, descript1,nation) values (@bfdate, @shengnei, @noaddress, '-��ַ����-', 'No Address','')
if not exists (select 1 from gststa where rtrim(gclass) = @jingwai)
	insert gststa(date, gclass, order_, descript, descript1,nation) values (@bfdate, @jingwai, '', '---����---', '---Overseas---','')

--
if not exists (select 1 from gststa where rtrim(gclass) = @jingwai and order_ = @huaqiao)
	insert gststa (date, gclass, order_, nation) values (@bfdate, @jingwai, @huaqiao, 'HQ')
if not exists (select 1 from gststa where rtrim(gclass) = @jingwai and order_ = @hongkong)
	insert gststa (date, gclass, order_, nation, descript, descript1) values (@bfdate, @jingwai, @hongkong, 'HK', '��  ��', 'Province Inside')
if not exists (select 1 from gststa where rtrim(gclass) = @jingwai and order_ = @macao)
	insert gststa (date, gclass, order_, nation, descript, descript1) values (@bfdate, @jingwai, @macao, 'MO', '��   ��', 'ProvinceInside')
if not exists (select 1 from gststa where rtrim(gclass) = @jingwai and order_ = @taiwan)
	insert gststa (date, gclass, order_, nation, descript, descript1) values (@bfdate, @jingwai, @taiwan, 'TW', '�й�̨��', 'Province Inside')
if not exists(select 1 from gststa where rtrim(gclass) = @jingwai and order_ = @waibin and nation=space(3))
	insert gststa (date, gclass, order_, descript, descript1) values (@bfdate, @jingwai, @waibin, '---���---', '---Foreign Guest---')

--
if exists (select 1from gststa where date = @bdate)
	update gststa set
		mtc = mtc-dtc, mtt = mtt-dtt, mgc = mgc-dgc, mgt = mgt-dgt, mmc = mmc-dmc, mmt = mmt-dmt,
		ytc = ytc-dtc, ytt = ytt-dtt, ygc = ygc-dgc, ygt = ygt-dgt, ymc = ymc-dmc, ymt = ymt-dmt
update gststa set dtc = 0, dtt = 0, dgc = 0, dgt = 0, dmc = 0, dmt = 0, date = @bfdate

-- ͳ�ƶ��󣺵�ҹ��������
declare c_guest cursor for select a.accnt, isnull(b.nation, @chncode),isnull(c.flag1,''),a.bdate,a.wherefrom,b.ident,a.groupno
	from master_till a, guest b, countrycode c
	where a.haccnt = b.no and ( a.sta='I' or (a.sta in ('S','O') and not exists(select 1 from master_last d where d.accnt=a.accnt and d.sta in ('I','S')) )) 
			and substring(a.extra,1,1) <> '1' and a.class='F' and isnull(b.nation, @chncode) *= c.code
open c_guest
fetch c_guest into @accnt, @nation,@flag1, @arr, @wherefrom,@ident,@groupno
while @@sqlstatus = 0
	begin
--
	select @sta = sta from master_till where accnt=@accnt
	if exists(select 1 from master_last where accnt=@accnt and sta='I')
		select @arr = bdate from master_last
--wherefromΪ�յģ������֤��ȡ���֤ǰ6λ xia  20090218
	if rtrim(@wherefrom ) = null and rtrim(@ident) <> null and datalength(rtrim(@ident))>= 15  
		select @wherefrom = substring(@ident,1,6)
	if not exists (select code from cntcode where code = @wherefrom )
		 select @wherefrom = space(6)  
	-- ���� @nation �仯ǰ������ @prv 	
	select @prv=isnull((select prv from cntcode where country=@nation and code=@wherefrom), '')
	-- ��ȡ @nation.flag 
	if @flag1<>'' and rtrim(@flag1)<> null
		select @nation=@flag1
--  
	if @groupno<>''		-- ���岿��
		begin
		if @groupno like 'G%'
			select @dgt = 1, @dmt = 0, @dgc = 1, @dmc = 0
		else
			select @dgt = 0, @dmt = 1, @dgc = 0, @dmc = 1
		if @arr <= @bdate  and @sta='I'  -- ����
			begin
			update gststa set dgt = dgt + @dgt, dmt = dmt + @dmt where rtrim(gclass) = @heji
			if rtrim(@nation) = 'CN'
				begin
				if rtrim(@wherefrom) is null
				   update gststa set dgt = dgt + @dgt, dmt = dmt + @dmt where rtrim(gclass) = @shengnei and order_ = @noaddress
            else if @prv = @lclpro -- substring(@wherefrom, 1, 2) = @lclpro
					update gststa set dgt = dgt + @dgt, dmt = dmt + @dmt where rtrim(gclass) = @shengnei and rtrim(order_) is null 
				else
					update gststa set dgt = dgt + @dgt, dmt = dmt + @dmt where rtrim(gclass) = @shengwai
				end
			else
				begin
				update gststa set dgt = dgt + @dgt, dmt = dmt +@dmt where rtrim(gclass) = @jingwai and order_ = space(2)
				if rtrim(@nation) = 'HQ'
					update gststa set dgt =dgt + @dgt, dmt = dmt + @dmt where rtrim(gclass) = @jingwai and order_ = @huaqiao
				else if rtrim(@nation) = 'HK'
					update gststa set dgt = dgt + @dgt, dmt =dmt + @dmt where rtrim(gclass) = @jingwai and order_ = @hongkong
				else if rtrim(@nation) = 'MO'
					update gststa set dgt = dgt + @dgt, dmt = dmt + @dmt where rtrim(gclass) = @jingwai and order_ = @macao
				else if rtrim(@nation) = 'TW'
					update gststa set dgt = dgt + @dgt, dmt = dmt + @dmt where rtrim(gclass) = @jingwai and order_= @taiwan
				else
					begin
					update gststa set dgt = dgt + @dgt, dmt = dmt + @dmt where rtrim(gclass) = @jingwai and order_ = @waibin and nation=space(3)
					if not exists (select * from gststa where rtrim(gclass) = @jingwai and order_ = @waibin and nation = @nation)
						insert gststa (date, gclass, order_, nation) values (@bfdate, @jingwai, @waibin, @nation)
					update gststa set dgt = dgt + @dgt, dmt = dmt + @dmt where rtrim(gclass) = @jingwai and order_ = @waibin and nation = @nation
					end
				end
			end

		if datediff(day,@arr,@bdate)=0	-- �˴�
			begin
			update gststa set dgc = dgc + @dgc, dmc = dmc + @dmc where rtrim(gclass) = @heji
			if rtrim(@nation) = 'CN'
				begin
				if rtrim(@wherefrom) is null
					update gststa set dgc = dgc + @dgc, dmc = dmc + @dmc where rtrim(gclass) = @shengnei and order_ = @noaddress
				else if @prv = @lclpro -- substring(@wherefrom, 1, 2) = @lclpro
					update gststa set dgc = dgc + @dgc, dmc = dmc + @dmc where rtrim(gclass) = @shengnei and rtrim(order_) is null 
				else
					update gststa set dgc = dgc + @dgc, dmc = dmc + @dmc where rtrim(gclass) = @shengwai
				end
			else
				begin
				update gststa set dgc = dgc + @dgc, dmc = dmc + @dmc where rtrim(gclass) = @jingwai and order_ = space(2)
				if rtrim(@nation) = 'HQ'
					update gststa set dgc = dgc + @dgc, dmc = dmc + @dmc where rtrim(gclass) = @jingwai and order_ = @huaqiao
				else if rtrim(@nation) = 'HK'
					update gststa set dgc = dgc + @dgc, dmc = dmc + @dmc where rtrim(gclass) = @jingwai and order_ = @hongkong
				else if rtrim(@nation) = 'MO'
					update gststa set dgc = dgc + @dgc, dmc = dmc + @dmc where rtrim(gclass) = @jingwai and order_ = @macao
				else if rtrim(@nation) = 'TW'
					update gststa set dgc = dgc + @dgc, dmc = dmc + @dmc where rtrim(gclass) = @jingwai and order_ = @taiwan
				else
					begin
					update gststa set dgc = dgc + @dgc, dmc = dmc + @dmc where rtrim(gclass) = @jingwai and order_ = @waibin and nation=space(3)
					if not exists(select * from gststa where rtrim(gclass) = @jingwai and order_ = @waibin and nation = @nation)
						insert gststa (date, gclass, order_, nation) values (@bfdate, @jingwai, @waibin, @nation)
					update gststa set dgc = dgc + @dgc, dmc = dmc + @dmc where rtrim(gclass) = @jingwai and order_ = @waibin and nation = @nation
					end
				end
			end
		end
	else			--- ɢ�Ͳ���
		begin
		if @arr <= @bdate and @sta='I'
			begin
			update gststa set dtt = dtt + 1 where rtrim(gclass) = @heji
			if rtrim(@nation) = 'CN'
				begin
				if rtrim(@wherefrom) is null
					update gststa set dtt = dtt + 1 where rtrim(gclass) = @shengnei and order_ = @noaddress
            else if @prv = @lclpro -- substring(@wherefrom, 1, 2) = @lclpro
					update gststa set dtt = dtt + 1 where rtrim(gclass) = @shengnei and rtrim(order_) is null 
				else
					update gststa set dtt = dtt + 1 where rtrim(gclass) = @shengwai
				end
			else
				begin
				update gststa set dtt = dtt + 1 where rtrim(gclass) = @jingwai and order_ = space(2)
				if rtrim(@nation) = 'HQ'
					update gststa set dtt = dtt + 1 where rtrim(gclass) = @jingwai and order_ = @huaqiao
				else if rtrim(@nation) = 'HK'
					update gststa set dtt = dtt + 1 where rtrim(gclass) = @jingwai and order_ = @hongkong
				else if rtrim(@nation) = 'MO'
					update gststa set dtt = dtt + 1 where rtrim(gclass) = @jingwai and order_ = @macao
				else if rtrim(@nation) = 'TW'
					update gststa set dtt = dtt + 1 where rtrim(gclass) = @jingwai and order_ = @taiwan
				else
					begin
					update gststa set dtt = dtt + 1 where rtrim(gclass) = @jingwai and order_ = @waibin and nation=space(3)
					if not exists (select * from gststa where rtrim(gclass) = @jingwai and order_ = @waibin and nation = @nation)
						insert gststa (date, gclass, order_, nation) values (@bfdate, @jingwai, @waibin, @nation)
					update gststa set dtt = dtt + 1 where rtrim(gclass) = @jingwai and order_ = @waibin and nation = @nation
					end
				end
			end
		if @arr =  @bdate
			begin
			update gststa set dtc = dtc + 1 where rtrim(gclass) = @heji
			if rtrim(@nation) = 'CN'
				begin
				if rtrim(@wherefrom) is null
					update gststa set dtc = dtc + 1 where rtrim(gclass) = @shengnei and order_ = @noaddress
            else if @prv = @lclpro -- substring(@wherefrom, 1, 2) = @lclpro
					update gststa set dtc = dtc + 1 where rtrim(gclass) = @shengnei and rtrim(order_) is null 
				else
					update gststa set dtc = dtc + 1 where rtrim(gclass) = @shengwai
				end
			else
				begin
				update gststa set dtc = dtc + 1 where rtrim(gclass) = @jingwai and order_ = space(2)
				if rtrim(@nation) = 'HQ'
					update gststa set dtc = dtc + 1 where rtrim(gclass) = @jingwai and order_ = @huaqiao
				else if rtrim(@nation) = 'HK'
					update gststa set dtc = dtc + 1 where rtrim(gclass) = @jingwai and order_ = @hongkong
				else if rtrim(@nation) = 'MO'
					update gststa set dtc = dtc + 1 where rtrim(gclass) = @jingwai and order_ = @macao
				else if rtrim(@nation) = 'TW'
					update gststa set dtc = dtc + 1 where rtrim(gclass) =@jingwai and order_ = @taiwan
				else
					begin
					update gststa set dtc = dtc + 1 where rtrim(gclass) = @jingwai and order_ = @waibin and nation=space(3)
					if not exists (select * from gststa where rtrim(gclass) = @jingwai and order_ = @waibin and nation =@nation)
						insert gststa (date, gclass, order_, nation) values (@bfdate, @jingwai, @waibin, @nation)
					update gststa set dtc = dtc + 1 where rtrim(gclass) = @jingwai and order_ = @waibin and nation = @nation
					end
				end
			end
		end
	fetch c_guest into @accnt, @nation,@flag1, @arr, @wherefrom,@ident,@groupno
	end
close c_guest
deallocate cursor c_guest

--
exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @isfstday = 'T'
	update gststa set mtc = dtc, mtt = dtt, mgc = dgc, mgt = dgt, mmc = dmc, mmt = dmt
else
	update gststa set mtc = mtc + dtc, mtt = mtt + dtt, mgc = mgc + dgc, mgt = mgt + dgt, mmc = mmc + dmc, mmt = mmt + dmt
if @isyfstday = 'T'
	update gststa set ytc = dtc, ytt = dtt, ygc = dgc, ygt = dgt, ymc = dmc, ymt = dmt
else
	update gststa set ytc = ytc + dtc, ytt = ytt + dtt, ygc = ygc + dgc, ygt = ygt + dgt, ymc = ymc + dmc, ymt = ymt + dmt
--
update gststa set descript = b.descript, descript1 = b.descript1 from countrycode b where gststa.nation = b.code and rtrim(gststa.nation)<> ''

update gststa set date = @bdate
delete ygststa where date = @bdate
insert ygststa select gststa.date, gststa.gclass, gststa.order_, gststa.nation, gststa.descript, gststa.descript1, gststa.sequence, gststa.dtc, gststa.dgc, gststa.dmc, gststa.dtt, gststa.dgt, gststa.dmt, gststa.mtc, gststa.mgc, gststa.mmc, gststa.mtt, gststa.mgt, gststa.mmt, gststa.ytc, gststa.ygc, gststa.ymc, gststa.ytt, gststa.ygt, gststa.ymt from gststa

return @ret
;