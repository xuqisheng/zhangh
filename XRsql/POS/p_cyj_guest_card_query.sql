if exists(select 1 from sysobjects where name ='p_cyj_guest_card_query' and type ='P')
	drop  proc p_cyj_guest_card_query;
create proc p_cyj_guest_card_query
	@cond			varchar(60),
	@crs			char(1),			--- �Ƿ�ָ��Ϊ���뿨 vipcard_type.center
	@read			char(1),   		--- �Ƿ񾭹�����ˢ�� vipcad_type.mustread
	@langid		integer	= 0
as
---------------------------------------------------------------------------------------
-- �����  -  ����  -- �й㷺�ĺ���
--
--   ��˿��� guest_card, vipcard
--
--   ���µ�ƥ�䣬��Сд����
---------------------------------------------------------------------------------------
create table #gout (
	no				char(20)								not null,
	sta			char(1)								not null,
	sta_des		char(60)								null,
	sno			char(20)			default ''		null,
	name			varchar(50)		default ''		not null,
	name2			varchar(50)							null,
	unit			varchar(50)							null,
	sex			char(1)								null,
	sex_des		char(60)								null,
	nation		char(3)								null,
	vip			char(3)								null,
	i_times		int				default 0		null,
	i_days		int				default 0		null,
	cardcode		char(10)								null,
	cardcode_des	char(50)							null,
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
	ref3			varchar(250)							null,
	dep			datetime								null,
	kname			varchar(60)							null,    -- ��������
	a_credit		money				default 0		null,
	a_charge		money				default 0		null,
	a_limit			money				default 0		null,
	sign			char(60)						      null
)


declare 
	@mustread 	char(1),
	@araccnt		char(10)

-- �������
select @cond = isnull(rtrim(@cond), '???')

if @crs <> 'T'
	select @crs = '%',@mustread = '%'
else
	select @mustread = @read


-- ����
if @read = 'F'   -- �û��ֹ�¼������
begin
	-- guest_card   ȥ��guest_card��ѯ  tcr 2005.1.6
--	insert #gout(no,sta,name,name2,sex,nation,vip,i_times,i_days,cardcode,cardno,ref1,ref2,ref3,dep,kname)
--		select a.no,'I',a.name,a.name2,a.sex,a.nation,a.vip,a.i_times,a.i_days,b.cardcode,b.cardno,'','','',b.expiry_date,a.name
--			from guest a,guest_card b
--			where a.no= b.no and b.halt='F' and ( b.cardno like @cond+'%' or a.name like '%'+@cond+'%' or a.name2 like '%'+@cond+'%')
	-- vipcard

	insert #gout(no,sta,name,name2,sex,nation,vip,i_times,i_days,cardcode,cardno,ref1,ref2,ref3,dep,kname,sign,hno,cno)
		select distinct '','','','','','','',0,0,c.guestcard,b.no,'','','',b.dep,b.name,'',b.hno,b.cno
			from guest a,vipcard b, vipcard_type c
			where (a.no = b.hno or a.no = b.cno or a.no = b.kno) and b.type=c.code and c.center like @crs and c.mustread like @mustread
				and ( b.no like @cond+'%' or b.sno like @cond+'%' or a.name like '%'+@cond+'%'  or a.name2 like '%'+@cond+'%'or b.name like '%'+@cond+'%')

//	insert #gout(no,sta,name,name2,sex,nation,vip,i_times,i_days,cardcode,cardno,ref1,ref2,ref3,dep,kname,sign)
//		select a.no,b.sta,a.name,a.name2,a.sex,a.nation,a.vip,a.i_times,a.i_days,c.guestcard,b.no,'','','',b.dep,b.name,''
//			from guest a,vipcard b, vipcard_type c
//			where (a.no = b.hno or a.no = b.cno or a.no = b.kno) and b.type=c.code and c.center like @crs and c.mustread like @mustread
//				and ( b.no like @cond+'%' or b.sno like @cond+'%' or a.name like '%'+@cond+'%'  or a.name2 like '%'+@cond+'%'or b.name like '%'+@cond+'%')
end
else					--ˢ�����϶��� vipcard ��
begin
	-- vipcard 
	insert #gout(no,sta,name,name2,sex,nation,vip,i_times,i_days,cardcode,cardno,ref1,ref2,ref3,dep,kname,sign)
		select a.no,b.sta,a.name,a.name2,a.sex,a.nation,a.vip,a.i_times,a.i_days,c.guestcard,b.no,'','','',b.dep,b.name,''
			from guest a,vipcard b, vipcard_type c
			where (a.no = b.hno or a.no = b.cno or a.no = b.kno) and b.type=c.code and c.center like @crs and c.mustread like @mustread
				and ( b.no like @cond+'%' or b.sno like @cond+'%' or a.name like '%'+@cond+'%'  or a.name2 like '%'+@cond+'%'or b.name like '%'+@cond+'%')
end

-- ������λ
update #gout set no = a.no, sta = a.sta, name = a.name, name2 = a.name2, sex = a.sex, nation = a.nation, vip = a.vip, i_times = a.i_times, i_days = a.i_days, unit = a.name
	from guest a where #gout.cno = a.no
-- ��������
update #gout set no = a.no, sta = a.sta, name = a.name, name2 = a.name2, sex = a.sex, nation = a.nation, vip = a.vip, i_times = a.i_times, i_days = a.i_days
	from guest a where #gout.hno = a.no

-- fox ϵͳ���п��� ar ��Ϣ
update #gout set araccnt=a.araccnt1, sno=a.sno, hno=a.hno, cno=a.cno,charge=a.charge, credit=a.credit, limit=a.limit
	from vipcard a where #gout.cardno=a.no

-- �����
if exists(select 1 from armst)
	update #gout set a_charge=a.charge, a_credit=a.credit, limit=a.limit
		from armst a where #gout.araccnt=a.accnt
else
	update #gout set a_charge=a.charge, a_credit=a.credit, limit=a.limit
		from master a where #gout.araccnt=a.accnt

-- ���ָ�����Ϣ
update #gout set ref1 = 'Point Balance = ' + convert(char(10), a.credit-a.charge) from vipcard a
	where #gout.cardno=a.no


update #gout set ref3 = substring(a.ref, 1, 250) from vipcard a
	where #gout.cardno=a.no


-- ���ִ��������滻
update #gout set sex_des = descript from basecode where cat = 'sex' and code=#gout.sex
update #gout set sta_des = descript from basecode where cat = 'vipcard_sta' and code=#gout.sta
update #gout set cardcode_des = descript from vipcard_type where guestcard=#gout.cardcode

--���
select no,sta,name,name2,unit,sex,nation,vip,i_times,i_days,cardcode,cardno,ref1,ref2,ref3,sno,hno,cno,credit,charge,limit,araccnt,dep,kname,a_credit,a_charge,a_limit,sign,sta_des,sex_des,cardcode_des
	from #gout order by name

return 0;
