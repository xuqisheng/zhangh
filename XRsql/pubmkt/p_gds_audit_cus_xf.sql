
if  exists(select * from sysobjects where name = "p_gds_audit_cus_xf")
	drop proc p_gds_audit_cus_xf
;
create proc p_gds_audit_cus_xf
	@mode				char(1) = 'A',  -- 'R'  -  recount all
	@ret				int output,
	@msg				varchar(60) output 
as
-----------------------------------------------------------------------------
--	����ҵ�������ѷ����������� - ��ÿ�շ�����Ϊ���� 
-- 	ͬʱ��¼ÿ�������������ԭ���� act_bal  
--	ǰ̨����Ҫ��ȫ������������Ҫ����㺬�ͻ���Ϣ�����ݣ�
--  ֻҪ�ʻ����ڵ�ǰ״̬������һ����¼����ʹû���κ���������-- ��¼����ϴ� 
--  ���ڹ�������������ݣ���˲�������κ����ڣ�ֻ��������ա� 
--        �ؽ�ҵ��������Ҫ�����Ĺ��̣����غϲ���������⸴�ӻ� 
-- 
-- 	ע�⣺ @rmpccodes -- ��ͬ�ı����б仯
--			���ǰ��������󣬺�����Ҫ��������δ����� �� 
-----------------------------------------------------------------------------
declare
	@bdate			datetime,
	@bfdate			datetime,
	@billno			char(7),
	@lic_buy_1		varchar(255),
	@lic_buy_2		varchar(255),
	@argcode		char(3) 

-- ���㷿�����ѵķ�����
declare	@rm_pccodes_nt	char(255), @rm_pccodes	char(255)
select @rm_pccodes_nt = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes_nt'), '')
select @rm_pccodes    = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes'), '')
select @argcode = min(argcode) from argcode 

--------- bdate ---------
if exists(select 1 from gate where audit = 'T')
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate=dateadd(dd, -1, @bdate) 
select @billno  = '_' + substring(convert(char(4), datepart(yy, dateadd(dd, 1, @bdate))), 4, 1) +
	substring(convert(char(3), datepart(mm, dateadd(dd, 1, @bdate)) + 100), 2, 2) +
	substring(convert(char(3), datepart(dd, dateadd(dd, 1, @bdate)) + 100), 2, 2) + '%'

---------׼��---------
select @ret = 0, @msg = 'OK'
truncate table cus_xf
delete ycus_xf where date = @bdate

----------------------------------------------
-------1. ǰ̨����
----------------------------------------------
-- Ѱ�ҷ���������ʻ� �� ʵ��ҵ���ʻ�, �޳������Ԥ���ʻ�  
-- �ݲ����ǲ�����ʷ�����¼��������ʧ�ʻ��������й����Զ�ת�˵�R�ʻ��������Զ�ת�˵ļ�¼�Ѿ�ת����ʷ 
create table #all_accnt (accnt char(10) not null)
insert #all_accnt select distinct accntof from account where accntof<>'' 
insert #all_accnt select distinct accnt from account
insert #all_accnt select distinct accntof from ar_account where accntof<>'' 
insert #all_accnt select distinct accnt from ar_account
create table #dis_accnt (accnt char(10) not null)
insert #dis_accnt select distinct accnt from #all_accnt
insert #dis_accnt select accnt from master_till where sta<>'D' and (sta<>'R' or lastnumb>0) and accnt not in (select accnt from #dis_accnt) 
insert #dis_accnt select accnt from ar_master_till where sta<>'D' and lastnumb>0 and accnt not in (select accnt from #dis_accnt) 

-- �����ʻ� 
insert cus_xf(date,actcls,accnt,sta,name,master,groupno,type,up_type,up_reason,roomno,rmreason,
				rmrate,setrate,rtreason,bdate,arr,dep,haccnt,cusno,agent,source,contact,saleid,market,
				src,channel,restype,artag1,artag2,ratecode,cmscode,cardcode,cardno,rmnum,gstno,children,
				tilld,tillc,tillbl)
	select @bdate,'F',a.accnt,a.sta,a.haccnt,a.master,a.groupno,a.type,a.up_type,a.up_reason,a.roomno,a.rmreason,
				a.rmrate,a.setrate,a.rtreason,a.bdate,a.arr,a.dep,a.haccnt,a.cusno,a.agent,a.source,isnull(a.exp_s2,''),a.saleid,a.market,
				a.src,a.channel,a.restype,a.artag1,a.artag2,a.ratecode,a.cmscode,a.cardcode,a.cardno,a.rmnum,a.gstno,a.children,
				charge,a.credit,a.charge - a.credit
	from master_till a, #dis_accnt b where a.sta <> 'D' and a.accnt=b.accnt 
insert cus_xf(date,actcls,accnt,sta,name,master,groupno,type,up_type,up_reason,roomno,rmreason,
				rmrate,setrate,rtreason,bdate,arr,dep,haccnt,cusno,agent,source,contact,saleid,market,
				src,channel,restype,artag1,artag2,ratecode,cmscode,cardcode,cardno,rmnum,gstno,children,
				tilld,tillc,tillbl)
	select @bdate,'F',a.accnt,a.sta,a.haccnt,a.master,'','','','','','',
				0,0,'',a.bdate,a.arr,a.dep,a.haccnt,'','','','',a.saleid,'',
				'','','',a.artag1,a.artag2,'','','','',0,0,0,
				a.charge, a.credit, a.charge - a.credit
	from ar_master_till a, #dis_accnt b where a.sta <> 'D' and a.accnt=b.accnt 

--
drop table #all_accnt
drop table #dis_accnt

-- �����������
update cus_xf set lastd = a.charge, lastc = a.credit, lastbl = a.charge - a.credit
	from master_last a where cus_xf.accnt = a.accnt
update cus_xf set lastd = a.charge + a.charge0, lastc = a.credit + a.credit0, lastbl = a.charge + a.charge0 - a.credit - a.credit0
	from ar_master_last a where cus_xf.accnt = a.accnt
-- ���� 
update cus_xf set name   = a.name from guest a where cus_xf.name = a.no

-- ��ʱ����� 
create table #account (
	accnt			char(10)							not null,
	accntof		char(10)							not null,
	deptno		char(5)		default ''		not null,
	pccode		char(5)							not null,
	argcode		char(3)		default ''		not null,
	quantity		money			default 0		not null,
	charge		money			default 0		not null,
	credit		money			default 0		not null,
	tofrom		char(2)		default '' 		not null,
	mode			char(10)							not null
)

-- �ɼ�ԭʼ����
insert #account
	select accnt,accntof,'',pccode,'',quantity,charge,credit,tofrom,mode from gltemp -- where pccode<>'9' -- 9=�ϲ�����Ҳ��Ҫ��ͳ�Ƶ� �������� 
update #account set argcode=a.argcode from pccode a where #account.pccode=a.pccode 
update #account set argcode='99', deptno='Z' where pccode='9' 
if exists(select 1 from #account where argcode='' and pccode<>'')  -- ǰ̨תӦ�յ�pccode='' 
begin
	select @ret=1, @msg='��ǰ������� pccode.argcode=null'
	return @ret 
end
update #account set deptno=a.deptno7 from pccode a where #account.argcode<'9' and #account.pccode=a.pccode 
update #account set deptno=a.deptno from pccode a where #account.argcode>='9' and #account.pccode=a.pccode 
if exists(select 1 from #account where deptno='' and pccode<>'' and pccode<>'9') 
begin
	select @ret=1, @msg='��ǰ������� deptno=null'
	return @ret 
end

--------------------------------------------
-- ������ 
--------------------------------------------
-- ����������ͳ��
update cus_xf set rm = 		isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno like 'rm%'),0)
update cus_xf set rm_svc = isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'rm_svc'),0)
update cus_xf set rm_bf = 	isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'rm_bf'),0)
update cus_xf set rm_cms = isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'rm_cms'),0)
update cus_xf set rm_lau = isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'rm_lau'),0)
update cus_xf set rm_opak = isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'rm_opak'),0)
update cus_xf set fb = 		isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'fb'),0)
update cus_xf set mt = 		isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'mt'),0)
update cus_xf set en = 		isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'en'),0)
update cus_xf set sp = 		isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'sp'),0)
update cus_xf set dot = 	isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno not like 'rm%' and a.deptno not in ('fb','mt','en','sp')),0)
update cus_xf set dtl=rm+fb+mt+en+sp+dot

update cus_xf set rmb 	= isnull((select sum(a.credit) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'A'),0)
update cus_xf set chk 	= isnull((select sum(a.credit) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'B'),0)
update cus_xf set card1 = isnull((select sum(a.credit) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'C'),0)
update cus_xf set card2 = isnull((select sum(a.credit) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'D'),0)
update cus_xf set ar 	= isnull((select sum(a.credit) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'J'),0)
update cus_xf set ticket = isnull((select sum(a.credit) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'F'),0)
update cus_xf set dscent = isnull((select sum(a.credit) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'H'),0)
update cus_xf set cot 	= isnull((select sum(a.credit) from #account a where cus_xf.accnt = a.accnt and a.deptno not in('A','B','C','D','J','F','H')),0)
update cus_xf set ctl=rmb+chk+card1+card2+ar+ticket+dscent+cot 


-- �����ۼƲ��� 
if @mode<>'R' -- �Զ��ۼӷ�ʽ�������նԱȴ��� 
begin
	-- һ��𿪶��䣬���� linux ���� 
	update cus_xf set t_rm=rm, t_rm_svc=rm_svc, t_rm_bf=rm_bf, t_rm_cms=rm_cms, t_rm_lau=rm_lau, t_rm_opak=rm_opak, 
							t_fb=fb, t_mt=mt, t_en=en, t_sp=sp, t_dot=dot, t_dtl=dtl 
	update cus_xf set t_rmb=rmb, t_chk=chk, t_card1=card1, t_card2=card2, t_ar=ar, t_ticket=ticket, t_dscent=dscent, t_cot=cot, t_ctl=ctl
	if exists(select 1 from ycus_xf where date=@bfdate)
	begin
		-- һ��𿪶��䣬���� linux ����  
		update cus_xf set t_rm=cus_xf.t_rm+a.t_rm, t_rm_svc=cus_xf.t_rm_svc+a.t_rm_svc, t_rm_bf=cus_xf.t_rm_bf+a.t_rm_bf, t_rm_cms=cus_xf.t_rm_cms+a.t_rm_cms, 
								t_rm_lau=cus_xf.t_rm_lau+a.t_rm_lau, t_rm_opak=cus_xf.t_rm_opak+a.t_rm_opak, 
								t_fb=cus_xf.t_fb+a.t_fb, t_mt=cus_xf.t_mt+a.t_mt, t_en=cus_xf.t_en+a.t_en, t_sp=cus_xf.t_sp+a.t_sp, t_dot=cus_xf.t_dot+a.t_dot,
								t_dtl=cus_xf.t_dtl+a.t_dtl 
			from ycus_xf a where a.date=@bfdate and a.accnt=cus_xf.accnt
		update cus_xf set t_rmb=cus_xf.t_rmb+a.t_rmb, t_chk=cus_xf.t_chk+a.t_chk, t_card1=cus_xf.t_card1+a.t_card1, t_card2=cus_xf.t_card2+a.t_card2, 
								t_ar=cus_xf.t_ar+a.t_ar, t_ticket=cus_xf.t_ticket+a.t_ticket, t_dscent=cus_xf.t_dscent+a.t_dscent, t_cot=cus_xf.t_cot+a.t_cot,
								t_ctl=cus_xf.t_ctl+a.t_ctl
			from ycus_xf a where a.date=@bfdate and a.accnt=cus_xf.accnt
	end 
end

--------------------------------------------
-- ҵ��ͳ��
--------------------------------------------
delete #account where argcode>='9' 
delete #account where tofrom<>''
delete #account where charge = 0 and pccode<>'' and charindex(pccode,@rm_pccodes_nt)=0
-- ɾ�����۷��ѣ�Ҳ���Ըĳ���ͷѣ�
update #account set quantity=0,charge=0 where accntof<>'' and charindex(pccode,@rm_pccodes_nt)>0 and rtrim(mode) is null
update #account set quantity=0 where charindex(pccode,@rm_pccodes_nt)>0 and not mode like 'J[0-9]%'
update #account set accnt=accntof where accntof<>''

--����package_detail����ͷ�
insert into #account select accnt,posted_accnt,'fb',pccodes,'',quantity,credit,0,'','' from package_detail where bdate=@bdate and tag<>'9'

update cus_xf set xf_rm = 		isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno like 'rm%'),0)
update cus_xf set xf_rm_svc = isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'rm_svc'),0)
update cus_xf set xf_rm_bf = 	isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'rm_bf'),0)
update cus_xf set xf_rm_cms = isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'rm_cms'),0)
update cus_xf set xf_rm_lau = isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'rm_lau'),0)
update cus_xf set xf_rm_opak = isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'rm_opak'),0)
update cus_xf set xf_fb = 		isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'fb'),0)
update cus_xf set xf_mt = 		isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'mt'),0)
update cus_xf set xf_en = 		isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'en'),0)
update cus_xf set xf_sp = 		isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'sp'),0)
--update cus_xf set xf_dot = 	isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno = 'dot'),0)
update cus_xf set xf_dot = 	isnull((select sum(a.charge) from #account a where cus_xf.accnt = a.accnt and a.deptno not like 'rm%' and a.deptno not in ('fb','mt','en','sp')),0)
update cus_xf set xf_dtl=xf_rm+xf_fb+xf_mt+xf_en+xf_sp+xf_dot
-- ����
update cus_xf set i_days=isnull((select sum(a.quantity) from #account a	where cus_xf.accnt=a.accnt and a.pccode<>'' and charindex(a.pccode,@rm_pccodes_nt)>0),0)
update cus_xf set x_times=1 where sta='X' and date=bdate 
update cus_xf set n_times=1 where sta='N' and date=bdate 

-- ����ͳ��ָ��
update cus_xf set t_arr='T' from master_till a, audit_date b 
	where cus_xf.accnt=a.accnt and a.sta in ('I','O','S') and a.citime is not null and a.citime>=b.begin_ and a.citime<=b.end_ and b.date=@bdate
update cus_xf set t_dep='T' from master_till a, audit_date b 
	where cus_xf.accnt=a.accnt and a.sta in ('O','S') and a.deptime is not null and a.deptime>=b.begin_ and a.deptime<=b.end_ and b.date=@bdate

-- ���� master: ��ֹ��λҵ���ظ����㣬��������ͬס�����ǰ��� share �����ʱ�򣬻����ͳ�ƴ��� 
-- ��� .master ����Ϊͬס��ǡ�����Ҳ��Ҫ���������縴������ 
-- 2008.4 master �ֶ����ھ���ͳһ��ͬס�����־����������ƺ���Ӧ����
--update cus_xf set master = isnull((select min(a.accnt) from cus_xf a where a.roomno=cus_xf.roomno
--	and a.cusno=cus_xf.cusno and a.agent=cus_xf.agent and a.source=cus_xf.source and a.i_days>0), master)

--------------------------------------------
-- ������ - �ۼӲ�����ȫ�ؽ�
--------------------------------------------
if @mode = 'R' 
begin
	select @ret = 0 
end 

---- ��©-1 ͳ�ƹؼ��֣���ͬ�ľƵ���ܲ�ͬ��
--update cus_xf set market='OTH' where market=''   -- ar �ʻ�������û���г���� 
--update cus_xf set src='OTH' where src=''
--update cus_xf set channel='OTH' where channel=''


-----------------------
--- 2. ��������----------- 
-----------------------
create table #menu (
	cusno			char(7)		default ''		not null,
	agent			char(7)		default ''		not null,
	source		char(7)		default ''		not null,
	haccnt		char(7)		default ''		not null,
	saleid		char(10)							not null,
	menu			char(10)							not null,
	gstno			money			default 0		not null,
	charge		money			default 0		not null
)
insert #menu
	select isnull(a.cusno,''), '', '', isnull(a.haccnt,''), a.saleid, a.menu,a.guest,sum(b.amount) 
		from pos_tmenu a, pos_tpay b, pccode c
			where (rtrim(a.cusno) is not null or rtrim(a.haccnt) is not null or rtrim(a.saleid) is not null ) and a.menu = b.menu 
				and a.sta ='3' and b.paycode = c.pccode and c.deptno2 <> 'TOA' and c.deptno2 <> 'TOR'
		group by a.cusno, a.haccnt, a.saleid, a.menu, a.guest
-- ������λ������ 
update #menu set agent=#menu.cusno from guest a where #menu.cusno=a.no and a.class='A'
update #menu set source=#menu.cusno from guest a where #menu.cusno=a.no and a.class='S'
update #menu set cusno='' where agent<>'' or source<>'' 

-- POS����Ӧ�ð��� fb,en �����ݷֿ� ? 
insert cus_xf(date,actcls, accnt, master, cusno, agent, source, haccnt,saleid, gstno, 
					xf_fb,xf_dtl,fb,dtl,t_fb,t_dtl,bdate,arr,dep) 
	select @bdate,'P', menu, menu, cusno, agent, source, haccnt, saleid, gstno, 
					charge, charge, charge, charge, charge, charge, @bdate,@bdate,@bdate 
		from #menu

-----------------------
-- �������� 
-----------------------
update cus_xf set saleid=a.saleid from guest a where cus_xf.saleid='' and cus_xf.cusno<>'' and cus_xf.cusno=a.no
update cus_xf set saleid=a.saleid from guest a where cus_xf.saleid='' and cus_xf.agent<>'' and cus_xf.agent=a.no
update cus_xf set saleid=a.saleid from guest a where cus_xf.saleid='' and cus_xf.source<>'' and cus_xf.source=a.no

update cus_xf set country=a.country, nation=a.nation from guest a where cus_xf.country='' and cus_xf.haccnt=a.no 
update cus_xf set country=a.country, nation=a.nation from guest a where cus_xf.country='' and cus_xf.cusno=a.no 
update cus_xf set country=a.country, nation=a.nation from guest a where cus_xf.country='' and cus_xf.agent=a.no 
update cus_xf set country=a.country, nation=a.nation from guest a where cus_xf.country='' and cus_xf.source=a.no 

--
insert ycus_xf select * from cus_xf

-----------------------
-- ����ͨ��ͳ�����ݱ� 
-----------------------
exec p_gl_statistic_saveas 'pcid', @bdate, 'cus_xf'
return @ret 
;
