IF OBJECT_ID('dbo.p_gds_guest_card_query') IS NOT NULL
    DROP PROCEDURE dbo.p_gds_guest_card_query
;
create proc p_gds_guest_card_query
	@cond			varchar(60),
	@crs			char(1),			--- 是否指定为中央卡 vipcard_type.center
	@read			char(1),   		--- 是否经过物理刷卡 vipcad_type.mustread
	@langid		integer	= 0
as
---------------------------------------------------------------------------------------
-- 贵宾卡  -  读卡  -- 有广泛的含义
--
--   兼顾考虑 guest_card, vipcard
--
--   以下的匹配，大小写敏感
---------------------------------------------------------------------------------------
create table #gout (
	no				char(20)								not null,
	sta			char(1)								not null,
	sno			char(20)			default ''		null,
	name			varchar(50)		default ''		not null,
	name2			varchar(50)							null,
	sex			char(1)								null,
	nation		char(3)								null,
	vip			char(3)								null,
	i_times		int				default 0		null,
	i_days		int				default 0		null,
	cardcode		char(10)								null,
	cardno		char(20)								null,
	flag			char(10)								null,
	hno			char(7)								null,
	cno			char(7)								null,
	araccnt		char(10)								null,
	credit		money				default 0		null,
	charge		money				default 0		null,
	limit			money				default 0		null,
	ref1			varchar(60)							null,
	ref2			varchar(60)							null,
	ref3			varchar(60)							null,
	dep			datetime								null,
	kname			varchar(60)							null,    -- 卡上姓名
	arbal			money				default 0		null,
   sign			varchar(60)						   null,
	accredit		money									null)

--
declare
	@lic_buy_1		varchar(255),
	@lic_buy_2		varchar(255),
	@nar				char(1)								-- 是否为新AR账
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
if charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0
	select @nar = 'T'
else
	select @nar = 'F'

-- 检查条件
select @cond = isnull(rtrim(@cond), '???')
if @crs <> 'T'
	select @crs = '%'

-- 检索
if @read = 'F'   -- 用户手工录入条件
begin
	-- guest_card
	insert #gout(no,sta,name,name2,sex,nation,vip,i_times,i_days,cardcode,cardno,ref1,ref2,ref3,dep,kname,sign,accredit)
		select a.no,'I',a.name,a.name2,a.sex,a.nation,a.vip,a.i_times,a.i_days,b.cardcode,b.cardno,'','','',b.expiry_date,a.name,a.grade,0
			from guest a,guest_card b
			where a.no = b.no and b.halt='F' and ( b.cardno like @cond+'%' or a.name like '%'+@cond+'%' or a.name2 like '%'+@cond+'%')
				and b.cardcode not in (select code from guest_card_type where flag='FOX')
	-- vipcard
	insert #gout(no,sta,name,name2,sex,nation,vip,i_times,i_days,cardcode,cardno,ref1,ref2,ref3,dep,kname,sign,accredit)
		select a.no,b.sta,a.name,a.name2,a.sex,a.nation,a.vip,a.i_times,a.i_days,c.guestcard,b.no,'','','',b.dep,b.name,a.grade,0
			from guest a,vipcard b, vipcard_type c
			where a.no = b.kno and b.type=c.code and c.center like @crs and c.mustread='F'
				and ( b.no like @cond+'%' or b.sno like @cond+'%' or a.name like '%'+@cond+'%'  or a.name2 like '%'+@cond+'%'or b.name like '%'+@cond+'%')
end
else					-- 刷卡（肯定是 vipcard ）
begin
	-- vipcard
	insert #gout(no,sta,name,name2,sex,nation,vip,i_times,i_days,cardcode,cardno,ref1,ref2,ref3,dep,kname,sign,accredit)
		select a.no,b.sta,a.name,a.name2,a.sex,a.nation,a.vip,a.i_times,a.i_days,c.guestcard,b.no,'','','',b.dep,b.name,a.grade,0
			from guest a,vipcard b, vipcard_type c
			where a.no = b.kno and b.type=c.code and c.center like @crs and c.mustread='T'
				and ( b.no like @cond+'%' or b.sno like @cond+'%' or a.name like '%'+@cond+'%'  or a.name2 like '%'+@cond+'%'or b.name like '%'+@cond+'%')
end

-- guest_card_type.flag - 判断是否为fox系统发行
update #gout set flag = a.flag from guest_card_type a where #gout.cardcode=a.code

-- fox 系统发行卡的 ar 信息
update #gout set araccnt=a.araccnt1, sno=a.sno, hno=a.hno, cno=a.cno,charge=a.charge, credit=a.credit, limit=a.limit
	from vipcard a where #gout.flag='FOX' and #gout.cardno=a.no

update #gout set sign = a.descript from basecode a where a.cat='guest_grade' and a.code = #gout.sign

-- 各种附加信息
update #gout set ref1 = 'Point Balance = ' + convert(char(30), a.credit-a.charge),ref3 = substring(a.ref, 1, 60)
	 from vipcard a
	where #gout.flag='FOX' and #gout.cardno=a.no
if @nar='T'
	update #gout set ref2 = 'AR = ' + a.accnt + 'Balance = ' + convert(char(30), a.charge-a.credit), arbal=a.charge-a.credit,accredit=a.accredit from ar_master a
		where #gout.flag='FOX' and #gout.araccnt=a.accnt
else
	update #gout set ref2 = 'AR = ' + a.accnt + 'Balance = ' + convert(char(30), a.charge-a.credit), arbal=a.charge-a.credit,accredit=a.accredit from master a
		where #gout.flag='FOX' and #gout.araccnt=a.accnt


-- 输出
select no,sta,name,name2,sex,nation,vip,i_times,i_days,cardcode,cardno,ref1,ref2,ref3,sno,hno,cno,credit,charge,limit,araccnt,dep,kname,arbal,sign,0
	from #gout order by name

return 0
;