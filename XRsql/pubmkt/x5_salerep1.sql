// -----------------------------------------
//	���ѷ����� ���� cus_xf
// -----------------------------------------

// -----------------------------------------
// ����Ա�ۺϷ��� : �Աȸ�����Ա
// -----------------------------------------
if object_id('p_gds_salesrep1_saleid') is not null
	drop proc p_gds_salesrep1_saleid
;
create proc p_gds_salesrep1_saleid
	@grpno		char(3),
	@begin_		datetime,
	@end_			datetime,
	@zero			char(1) = 't'	// 0 �Ƿ���ʾ
as

create table #gout
(
	code			varchar(12)				not null,
	descript		varchar(30)				not null,
	accnt			char(10)					not null,
	master		char(10)					not null,
	rm				money		default 0	not null,	// ����
	gstno			money		default 0	not null,	// �ͷ�
	days			money		default 0	not null,	// ����
	fb				money		default 0	not null,	// ����
	en				money		default 0	not null,	// ����
	ot				money		default 0	not null,	// ����
	tl				money		default 0	not null		// �ϼ�
)

if @begin_ is null
	select @begin_ = '1980/1/1'
if @end_ is null
	select @end_ = '2020/1/1'
if rtrim(@grpno) is null 
	select @grpno = '%'
   
// ������ϸ��¼
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

// ͬס�ķ�����Ϊ1
update #gout set days = 0 where accnt <> master

// ȫ��Ϊ 0 ��¼�Ƿ���ʾ
if charindex(@zero, 'tTyY') = 0      
	delete #gout where rm=0 and fb=0 and en=0 and ot=0 and tl=0 and days=0 and gstno=0 
else
	insert #gout(code, descript,accnt,master,rm,gstno,days,fb,en,ot,tl) select code, descript, '', '',0,0,0,0,0,0,0 from saleid where code not in (select distinct code from #gout)
--cq modify	
--insert #gout(code, descript) select code, descript from saleid where code not in (select distinct code from #gout)

// ���
select code, descript, sum(gstno), 
		sum(days), sum(rm), sum(fb), sum(en), sum(ot), sum(tl), ''
	from #gout
	group by code,descript 
	order by code,descript

return 0
;

// -----------------------------------------
// Э�鵥λ������ϸ���� - ��Ҫȷ�����
// -----------------------------------------
if object_id('p_gds_salesrep1_cusno') is not null
	drop proc p_gds_salesrep1_cusno
;
create proc p_gds_salesrep1_cusno
	@classkey	char(1),  // 1, 2, 3, 4 - ���
	@class		char(3),
	@begin_		datetime,
	@end_			datetime,
	@zero			char(1) = 't'	// 0 �Ƿ���ʾ
as

create table #gout
(
	code			char(3)					not null,	// ���
	descript		varchar(30)				not null,	// �������
	accnt			char(10)					not null,
	master		char(10)					not null,
	no				char(7)					not null,	// Э�鵥λ
	sno			char(15)					null,			// 
	name			varchar(60)				not null,
	rm				money		default 0	not null,	// ����
	gstno			money		default 0	not null,	// �ͷ�
	days			money		default 0	not null,	// ����
	fb				money		default 0	not null,	// ����
	en				money		default 0	not null,	// ����
	ot				money		default 0	not null,	// ����
	tl				money		default 0	not null		// �ϼ�
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

// ȫ��Ϊ 0 ��¼�Ƿ���ʾ
if charindex(@zero, 'tTyY') = 0      
	delete #gout where rm=0 and fb=0 and en=0 and ot=0 and tl=0 and days=0 and gstno=0 
else
	if @classkey='1'     --cq modify #gout û��дȫ���²����ֵ
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

// ͬס�ķ�����Ϊ1
update #gout set days = 0 where accnt <> master

//
create table #gout1
(
	code			char(3)					not null,	// ���
	descript		varchar(30)				not null,	// �������
	no				char(7)					not null,	// Э�鵥λ
	sno			char(15)					null,			// 
	name			varchar(60)				not null,
	rm				money		default 0	not null,	// ����
	gstno			money		default 0	not null,	// �ͷ�
	days			money		default 0	not null,	// ����
	fb				money		default 0	not null,	// ����
	en				money		default 0	not null,	// ����
	ot				money		default 0	not null,	// ����
	tl				money		default 0	not null		// �ϼ�
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
// ����Ա֮��λ������ϸ����
// -----------------------------------------
if object_id('p_gds_salerep1_saleid_more') is not null
	drop proc p_gds_salerep1_saleid_more
;
create proc p_gds_salerep1_saleid_more
	@saleid		varchar(12),
	@begin_		datetime,
	@end_			datetime,
	@more			char(1)= 'f'	// ������ϸ ? ע�ⷵ�ص��в�һ�� !
as

create table #gout
(
	code			varchar(12)				not null,	// ����Ա
	descript		varchar(30)				not null,
	accnt			char(10)					not null,
	master		char(10)					not null,
	no				char(7)					not null,	// ��λ����
	sno			char(15)					null,
	name			varchar(60)				not null,
	actcls		char(1)					not null,
	actno			char(10)					not null,	// ǰ̨�˺ţ����߲����˺�
	haccnt		char(7)					not null,
	gstname		varchar(60)				null,	
	arr			datetime					null,
	dep			datetime					null,
	roomno		char(5)					null,			// ���ţ�����
	rate			money		default 0	null,			// ����
	rm				money		default 0	not null,	// ����
	gstno			money		default 0	not null,	// �ͷ�
	days			money		default 0	not null,	// ����
	fb				money		default 0	not null,	// ����
	en				money		default 0	not null,	// ����
	ot				money		default 0	not null,	// ����
	tl				money		default 0	not null		// �ϼ�
)

if @begin_ is null
	select @begin_ = '1980/1/1'
if @end_ is null
	select @end_ = '2020/1/1'
   
// ������ϸ��¼
insert #gout
	select a.code, a.descript, b.accnt, b.master, isnull(rtrim(b.cusno), isnull(rtrim(b.agent), b.source)) , '', '', 
			b.actcls, b.accnt, b.haccnt, '', null, null, '', 0, b.rm, b.gstno, b.i_days, b.fb, b.en, b.ot, b.ttl
		From saleid a, ycus_xf b
		Where a.code=@saleid and a.code=b.saleid
			and b.date>=@begin_ and b.date<=@end_

// ͬס�ķ�����Ϊ1
update #gout set days = 0 where accnt <> master

--
update #gout set gstname = a.name from guest a where #gout.haccnt=a.no
update #gout set sno=a.sno, name = a.name from guest a where #gout.no=a.no
update #gout set arr=a.arr, dep=a.dep, roomno=a.roomno, rate=a.setrate from master a where #gout.actcls='F' and #gout.actno=a.accnt
update #gout set arr=a.arr, dep=a.dep, roomno=a.roomno, rate=a.setrate from hmaster a where #gout.actcls='F' and #gout.actno=a.accnt

--
if charindex(@more, 'tTyY') > 0  // ��ϸ
	select no+'-'+sno+'-'+name,actno,gstname,arr,dep,roomno,rate,gstno,rm,fb,en,ot,tl
		from #gout order by no
else										// ÿ��λһ��
	select no+'-'+sno+'-'+name,sum(gstno),sum(days),sum(rm),sum(fb),sum(en),sum(ot),sum(tl)
		from #gout group by no,sno,name order by no,sno,name

return 0
;

// -----------------------------------------
// ��λ������ϸ����
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
	no				char(7)					not null,	// ��λ����
	sno			char(15)					null,
	name			varchar(60)				not null,
	actcls		char(1)					not null,
	actno			char(10)					not null,	// ǰ̨�˺ţ����߲����˺�
	haccnt		char(7)	default ''	not null,
	gstname		varchar(60)				null,	
	arr			datetime					null,
	dep			datetime					null,
	roomno		char(5)					null,			// ���ţ�����
	rate			money		default 0	null,			// ����
	rm				money		default 0	not null,	// ����
	gstno			money		default 0	not null,	// �ͷ�
	days			money		default 0	not null,	// ����
	fb				money		default 0	not null,	// ����
	en				money		default 0	not null,	// ����
	ot				money		default 0	not null,	// ����
	tl				money		default 0	not null		// �ϼ�
)

if @begin_ is null
	select @begin_ = '1980/1/1'
if @end_ is null
	select @end_ = '2020/1/1'
   
// ������ϸ��¼
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

// ͬס�ķ�����Ϊ1
update #gout set days = 0 where accnt <> master

update #gout set gstname = a.name from guest a where #gout.haccnt=a.no
update #gout set sno=a.sno, name = a.name from guest a where #gout.no=a.no
update #gout set arr=a.arr, dep=a.dep, roomno=a.roomno, rate=a.setrate from master a where #gout.actcls='F' and #gout.actno=a.accnt
update #gout set arr=a.arr, dep=a.dep, roomno=a.roomno, rate=a.setrate from hmaster a where #gout.actcls='F' and #gout.actno=a.accnt


// ���
select actno,gstname,arr,dep,roomno,rate,days,rm,fb,en,ot,tl,no+'-'+sno+'-'+name
	from #gout order by actno,arr

return 0
;
