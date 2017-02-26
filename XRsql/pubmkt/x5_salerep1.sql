// -----------------------------------------
//	消费分析： 基于 cus_xf
// -----------------------------------------

// -----------------------------------------
// 销售员综合分析 : 对比各销售员
// -----------------------------------------
if object_id('p_gds_salesrep1_saleid') is not null
	drop proc p_gds_salesrep1_saleid
;
create proc p_gds_salesrep1_saleid
	@grpno		char(3),
	@begin_		datetime,
	@end_			datetime,
	@zero			char(1) = 't'	// 0 是否显示
as

create table #gout
(
	code			varchar(12)				not null,
	descript		varchar(30)				not null,
	accnt			char(10)					not null,
	master		char(10)					not null,
	rm				money		default 0	not null,	// 房费
	gstno			money		default 0	not null,	// 餐费
	days			money		default 0	not null,	// 人数
	fb				money		default 0	not null,	// 间天
	en				money		default 0	not null,	// 康乐
	ot				money		default 0	not null,	// 其他
	tl				money		default 0	not null		// 合计
)

if @begin_ is null
	select @begin_ = '1980/1/1'
if @end_ is null
	select @end_ = '2020/1/1'
if rtrim(@grpno) is null 
	select @grpno = '%'
   
// 插入明细记录
insert #gout
	select a.code, a.descript, b.accnt, b.master, b.rm, b.gstno, b.i_days, b.fb, b.en, b.ot, b.ttl
		From saleid a, ycus_xf b
		Where a.grp like @grpno and a.code=b.saleid
			and b.date>=@begin_ and b.date<=@end_ and b.t_arr='T'
insert #gout
	select a.code, a.descript, b.accnt, b.master, b.rm, 0, b.i_days, b.fb, b.en, b.ot, b.ttl
		From saleid a, ycus_xf b
		Where a.grp like @grpno and a.code=b.saleid
			and b.date>=@begin_ and b.date<=@end_ and b.t_arr='F'

// 同住的房晚数为1
update #gout set days = 0 where accnt <> master

// 全部为 0 记录是否显示
if charindex(@zero, 'tTyY') = 0      
	delete #gout where rm=0 and fb=0 and en=0 and ot=0 and tl=0 and days=0 and gstno=0 
else
	insert #gout(code, descript,accnt,master,rm,gstno,days,fb,en,ot,tl) select code, descript, '', '',0,0,0,0,0,0,0 from saleid where code not in (select distinct code from #gout)
--cq modify	
--insert #gout(code, descript) select code, descript from saleid where code not in (select distinct code from #gout)

// 输出
select code, descript, sum(gstno), 
		sum(days), sum(rm), sum(fb), sum(en), sum(ot), sum(tl), ''
	from #gout
	group by code,descript 
	order by code,descript

return 0
;

// -----------------------------------------
// 协议单位消费明细分析 - 需要确认类别
// -----------------------------------------
if object_id('p_gds_salesrep1_cusno') is not null
	drop proc p_gds_salesrep1_cusno
;
create proc p_gds_salesrep1_cusno
	@classkey	char(1),  // 1, 2, 3, 4 - 类别
	@class		char(3),
	@begin_		datetime,
	@end_			datetime,
	@zero			char(1) = 't'	// 0 是否显示
as

create table #gout
(
	code			char(3)					not null,	// 类别
	descript		varchar(30)				not null,	// 类别名称
	accnt			char(10)					not null,
	master		char(10)					not null,
	no				char(7)					not null,	// 协议单位
	sno			char(15)					null,			// 
	name			varchar(60)				not null,
	rm				money		default 0	not null,	// 房费
	gstno			money		default 0	not null,	// 餐费
	days			money		default 0	not null,	// 人数
	fb				money		default 0	not null,	// 间天
	en				money		default 0	not null,	// 康乐
	ot				money		default 0	not null,	// 其他
	tl				money		default 0	not null		// 合计
)

if @begin_ is null
	select @begin_ = '1980/1/1'
if @end_ is null
	select @end_ = '2020/1/1'
   
if charindex(@classkey, '1234')=0
	select @classkey = '1'
if rtrim(@class) is null
	select @class = '%'

if @classkey = '1' 
begin
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, b.gstno, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls1' and a.code like @class
				and a.code=c.class1 and (b.cusno=c.no )
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='T'
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, b.gstno, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls1' and a.code like @class
				and a.code=c.class1 and ( b.agent=c.no )
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='T'
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, b.gstno, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls1' and a.code like @class
				and a.code=c.class1 and ( b.source=c.no)
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='T'

	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, 0, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls1' and a.code like @class
				and a.code=c.class1 and (b.cusno=c.no )
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='F'
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, 0, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls1' and a.code like @class
				and a.code=c.class1 and ( b.agent=c.no )
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='F'
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, 0, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls1' and a.code like @class
				and a.code=c.class1 and ( b.source=c.no)
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='F'
end
else if @classkey = '2'
begin
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, b.gstno, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls2' and a.code like @class
				and a.code=c.class1 and (b.cusno=c.no )
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='T'
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, b.gstno, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls2' and a.code like @class
				and a.code=c.class1 and ( b.agent=c.no )
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='T'
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, b.gstno, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls2' and a.code like @class
				and a.code=c.class1 and ( b.source=c.no)
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='T'

	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, 0, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls2' and a.code like @class
				and a.code=c.class1 and (b.cusno=c.no )
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='F'
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, 0, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls2' and a.code like @class
				and a.code=c.class1 and ( b.agent=c.no )
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='F'
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, 0, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls2' and a.code like @class
				and a.code=c.class1 and ( b.source=c.no)
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='F'
end
else if @classkey = '3'
begin
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, b.gstno, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls3' and a.code like @class
				and a.code=c.class1 and (b.cusno=c.no )
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='T'
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, b.gstno, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls3' and a.code like @class
				and a.code=c.class1 and ( b.agent=c.no )
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='T'
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, b.gstno, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls3' and a.code like @class
				and a.code=c.class1 and ( b.source=c.no)
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='T'

	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, 0, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls3' and a.code like @class
				and a.code=c.class1 and (b.cusno=c.no )
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='F'
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, 0, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls3' and a.code like @class
				and a.code=c.class1 and ( b.agent=c.no )
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='F'
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, 0, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls3' and a.code like @class
				and a.code=c.class1 and ( b.source=c.no)
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='F'
end
else if @classkey = '4'
begin
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, b.gstno, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls4' and a.code like @class
				and a.code=c.class1 and (b.cusno=c.no )
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='T'
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, b.gstno, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls4' and a.code like @class
				and a.code=c.class1 and ( b.agent=c.no )
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='T'
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, b.gstno, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls4' and a.code like @class
				and a.code=c.class1 and ( b.source=c.no)
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='T'

	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, 0, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls4' and a.code like @class
				and a.code=c.class1 and (b.cusno=c.no )
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='F'
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, 0, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls4' and a.code like @class
				and a.code=c.class1 and ( b.agent=c.no )
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='F'
	insert #gout
		select a.code, a.descript, b.accnt, b.master, c.no, c.sno, c.name, b.rm, 0, b.i_days, b.fb, b.en, b.ot, b.ttl
			From basecode a, ycus_xf b, guest c
			Where a.cat='cuscls4' and a.code like @class
				and a.code=c.class1 and ( b.source=c.no)
				and b.date>=@begin_ and b.date<=@end_ and b.t_arr='F'
end

// 全部为 0 记录是否显示
if charindex(@zero, 'tTyY') = 0      
	delete #gout where rm=0 and fb=0 and en=0 and ot=0 and tl=0 and days=0 and gstno=0 
else
	if @classkey='1'     --cq modify #gout 没有写全导致插入空值
		insert #gout(code, descript, accnt,master,no, sno, name,rm,gstno,days,fb,en,ot,tl) 
			select b.code, b.descript,'','', a.no, a.sno, a.name,0,0,0,0,0,0,0 from guest a, basecode b 
				where b.cat='cuscls1' and a.class1=b.code and a.class in ('C','A','S') and a.no not in (select distinct no from #gout)
	else if @classkey='2'
		insert #gout(code, descript, accnt,master,no, sno, name,rm,gstno,days,fb,en,ot,tl) 
			select b.code, b.descript,'','', a.no, a.sno, a.name,0,0,0,0,0,0,0 from guest a, basecode b 
				where b.cat='cuscls2' and a.class2=b.code and a.class in ('C','A','S') and a.no not in (select distinct no from #gout)
	else if @classkey='3'
		insert #gout(code, descript, accnt,master,no, sno, name,rm,gstno,days,fb,en,ot,tl) 
			select b.code, b.descript,'','', a.no, a.sno, a.name,0,0,0,0,0,0,0 from guest a, basecode b 
				where b.cat='cuscls3' and a.class3=b.code and a.class in ('C','A','S') and a.no not in (select distinct no from #gout)
	else if @classkey='4'
		insert #gout(code, descript, accnt,master,no, sno, name,rm,gstno,days,fb,en,ot,tl) 
			select b.code, b.descript,'','', a.no, a.sno, a.name,0,0,0,0,0,0,0 from guest a, basecode b 
				where b.cat='cuscls4' and a.class4=b.code and a.class in ('C','A','S') and a.no not in (select distinct no from #gout)

// 同住的房晚数为1
update #gout set days = 0 where accnt <> master

//
create table #gout1
(
	code			char(3)					not null,	// 类别
	descript		varchar(30)				not null,	// 类别名称
	no				char(7)					not null,	// 协议单位
	sno			char(15)					null,			// 
	name			varchar(60)				not null,
	rm				money		default 0	not null,	// 房费
	gstno			money		default 0	not null,	// 餐费
	days			money		default 0	not null,	// 人数
	fb				money		default 0	not null,	// 间天
	en				money		default 0	not null,	// 康乐
	ot				money		default 0	not null,	// 其他
	tl				money		default 0	not null		// 合计
)

insert #gout1
select code, descript, no, sno, name, sum(rm), sum(gstno),sum(days),sum(fb), sum(en), sum(ot), sum(tl)
	from #gout
	group by code,descript, no, sno, name 

select descript, no, sno, name, sum(gstno),sum(days),sum(rm), sum(fb), sum(en), sum(ot), sum(tl), ''
	from #gout1
	group by code,descript, no, sno, name
	order by code,descript, days desc, no, sno, name

return 0
;


// -----------------------------------------
// 销售员之单位消费明细分析
// -----------------------------------------
if object_id('p_gds_salerep1_saleid_more') is not null
	drop proc p_gds_salerep1_saleid_more
;
create proc p_gds_salerep1_saleid_more
	@saleid		varchar(12),
	@begin_		datetime,
	@end_			datetime,
	@more			char(1)= 'f'	// 消费明细 ? 注意返回的列不一样 !
as

create table #gout
(
	code			varchar(12)				not null,	// 销售员
	descript		varchar(30)				not null,
	accnt			char(10)					not null,
	master		char(10)					not null,
	no				char(7)					not null,	// 单位号码
	sno			char(15)					null,
	name			varchar(60)				not null,
	actcls		char(1)					not null,
	actno			char(10)					not null,	// 前台账号，或者餐饮账号
	haccnt		char(7)					not null,
	gstname		varchar(60)				null,	
	arr			datetime					null,
	dep			datetime					null,
	roomno		char(5)					null,			// 房号，桌号
	rate			money		default 0	null,			// 房价
	rm				money		default 0	not null,	// 房费
	gstno			money		default 0	not null,	// 餐费
	days			money		default 0	not null,	// 人数
	fb				money		default 0	not null,	// 间天
	en				money		default 0	not null,	// 康乐
	ot				money		default 0	not null,	// 其他
	tl				money		default 0	not null		// 合计
)

if @begin_ is null
	select @begin_ = '1980/1/1'
if @end_ is null
	select @end_ = '2020/1/1'
   
// 插入明细记录
insert #gout
	select a.code, a.descript, b.accnt, b.master, isnull(rtrim(b.cusno), isnull(rtrim(b.agent), b.source)) , '', '', 
			b.actcls, b.accnt, b.haccnt, '', null, null, '', 0, b.rm, b.gstno, b.i_days, b.fb, b.en, b.ot, b.ttl
		From saleid a, ycus_xf b
		Where a.code=@saleid and a.code=b.saleid
			and b.date>=@begin_ and b.date<=@end_

// 同住的房晚数为1
update #gout set days = 0 where accnt <> master

--
update #gout set gstname = a.name from guest a where #gout.haccnt=a.no
update #gout set sno=a.sno, name = a.name from guest a where #gout.no=a.no
update #gout set arr=a.arr, dep=a.dep, roomno=a.roomno, rate=a.setrate from master a where #gout.actcls='F' and #gout.actno=a.accnt
update #gout set arr=a.arr, dep=a.dep, roomno=a.roomno, rate=a.setrate from hmaster a where #gout.actcls='F' and #gout.actno=a.accnt

--
if charindex(@more, 'tTyY') > 0  // 明细
	select no+'-'+sno+'-'+name,actno,gstname,arr,dep,roomno,rate,gstno,rm,fb,en,ot,tl
		from #gout order by no
else										// 每单位一行
	select no+'-'+sno+'-'+name,sum(gstno),sum(days),sum(rm),sum(fb),sum(en),sum(ot),sum(tl)
		from #gout group by no,sno,name order by no,sno,name

return 0
;

// -----------------------------------------
// 单位消费明细分析
// -----------------------------------------
if object_id('p_gds_salesrep1_cusno_more') is not null
	drop proc p_gds_salesrep1_cusno_more
;
create proc p_gds_salesrep1_cusno_more
	@no			char(7),
	@begin_		datetime,
	@end_			datetime
as

create table #gout
(
	accnt			char(10)					not null,
	master		char(10)					not null,
	no				char(7)					not null,	// 单位号码
	sno			char(15)					null,
	name			varchar(60)				not null,
	actcls		char(1)					not null,
	actno			char(10)					not null,	// 前台账号，或者餐饮账号
	haccnt		char(7)	default ''	not null,
	gstname		varchar(60)				null,	
	arr			datetime					null,
	dep			datetime					null,
	roomno		char(5)					null,			// 房号，桌号
	rate			money		default 0	null,			// 房价
	rm				money		default 0	not null,	// 房费
	gstno			money		default 0	not null,	// 餐费
	days			money		default 0	not null,	// 人数
	fb				money		default 0	not null,	// 间天
	en				money		default 0	not null,	// 康乐
	ot				money		default 0	not null,	// 其他
	tl				money		default 0	not null		// 合计
)

if @begin_ is null
	select @begin_ = '1980/1/1'
if @end_ is null
	select @end_ = '2020/1/1'
   
// 插入明细记录
--cq modify  union --->insert #gout
insert #gout
	select accnt, master, cusno , '', '', actcls, accnt, haccnt,'',null, null, '', 0, rm, gstno, i_days, fb, en, ot, ttl
		From ycus_xf Where (cusno=@no or agent=@no or source=@no) and date>=@begin_ and date<=@end_
//insert #gout
//	select accnt, master, agent , '', '', actcls, accnt, haccnt,'',null, null, '', 0, rm, gstno, i_days, fb, en, ot, ttl
//		From ycus_xf Where agent=@no and date>=@begin_ and date<=@end_
//insert #gout
//	select accnt, master, source , '', '', actcls, accnt, haccnt,'',null, null, '', 0, rm, gstno, i_days, fb, en, ot, ttl
//		From ycus_xf Where source=@no and date>=@begin_ and date<=@end_

// 同住的房晚数为1
update #gout set days = 0 where accnt <> master

update #gout set gstname = a.name from guest a where #gout.haccnt=a.no
update #gout set sno=a.sno, name = a.name from guest a where #gout.no=a.no
update #gout set arr=a.arr, dep=a.dep, roomno=a.roomno, rate=a.setrate from master a where #gout.actcls='F' and #gout.actno=a.accnt
update #gout set arr=a.arr, dep=a.dep, roomno=a.roomno, rate=a.setrate from hmaster a where #gout.actcls='F' and #gout.actno=a.accnt


// 输出
select actno,gstname,arr,dep,roomno,rate,days,rm,fb,en,ot,tl,no+'-'+sno+'-'+name
	from #gout order by actno,arr

return 0
;
