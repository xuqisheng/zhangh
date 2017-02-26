
if  exists(select * from sysobjects where name = "p_gds_audit_cus_xf_reb")
	drop proc p_gds_audit_cus_xf_reb
;
create proc p_gds_audit_cus_xf_reb
	@bdate				datetime,
	@ret				int output,
	@msg				varchar(60) output 
as
-----------------------------------------------------------------------------
--	   消费业绩、消费分析基础数据 - 以每日发生数为基础 
-- 	同时记录每日余额情况，替代原来的 act_bal  
--		前台部分要求全部；其他各点要求计算含客户信息的内容；
--    只要帐户还在当前状态，都做一个记录，即使没有任何帐务发生。-- 记录冗余较大 
--    由于过程设计余额等内容，因此不能针对任何日期，只能针对昨日。 
--        重建业绩部分需要单独的过程，不必合并到这里，避免复杂化 
-- 
-- 	注意： @rmpccodes -- 不同的宾馆有变化
--				如果前面输入错误，后面需要调整，如何处理呢 ？ 
-----------------------------------------------------------------------------
declare
	@billno			char(7),
	@lic_buy_1		varchar(255),
	@lic_buy_2		varchar(255),
	@argcode			char(3) 

-- 计算房晚、房费的费用码
declare	@rm_pccodes_nt	char(255), @rm_pccodes	char(255)
select @rm_pccodes_nt = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes_nt'), '')
select @rm_pccodes    = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes'), '')
select @argcode = min(argcode) from argcode 

--------- bdate ---------
select @billno  = '_' + substring(convert(char(4), datepart(yy, dateadd(dd, 1, @bdate))), 4, 1) +
	substring(convert(char(3), datepart(mm, dateadd(dd, 1, @bdate)) + 100), 2, 2) +
	substring(convert(char(3), datepart(dd, dateadd(dd, 1, @bdate)) + 100), 2, 2) + '%'

---------准备---------
select @ret = 0, @msg = 'OK'
truncate table cus_xf
delete ycus_xf where date = @bdate

----------------------------------------------
-------1. 前台部分
----------------------------------------------
-- 寻找发生账务的帐户 和 实际业务帐户, 剔除纯粹的预订帐户  
-- 暂不考虑查找历史账务记录，导致遗失帐户：曾经有过的自动转账的R帐户，并且自动转账的记录已经转入历史 
create table #all_accnt (accnt char(10) not null)
insert #all_accnt select distinct accntof from account where accntof<>'' 
insert #all_accnt select distinct accnt from account
insert #all_accnt select distinct accntof from ar_account where accntof<>'' 
insert #all_accnt select distinct accnt from ar_account
create table #dis_accnt (accnt char(10) not null)
insert #dis_accnt select distinct accnt from #all_accnt
insert #dis_accnt select accnt from master_till where sta<>'D' and (sta<>'R' or lastnumb>0) and accnt not in (select accnt from #dis_accnt) 
insert #dis_accnt select accnt from ar_master_till where sta<>'D' and lastnumb>0 and accnt not in (select accnt from #dis_accnt) 

-- 插入帐户 
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

-- 更新上日余额
update cus_xf set lastd = a.charge, lastc = a.credit, lastbl = a.charge - a.credit
	from master_last a where cus_xf.accnt = a.accnt
update cus_xf set lastd = a.charge + a.charge0, lastc = a.credit + a.credit0, lastbl = a.charge + a.charge0 - a.credit - a.credit0
	from ar_master_last a where cus_xf.accnt = a.accnt
-- 名称 
update cus_xf set name   = a.name from guest a where cus_xf.name = a.no

-- 临时帐务表 
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

-- 采集原始帐务
insert #account
	select accnt,accntof,'',pccode,'',quantity,charge,credit,tofrom,mode from gltemp where pccode<>'9' -- 9=合并结帐 
update #account set argcode=a.argcode from pccode a where #account.pccode=a.pccode 
if exists(select 1 from #account where argcode='' and pccode<>'')  -- 前台转应收的pccode='' 
begin
	select @ret=1, @msg='当前帐务存在 pccode.argcode=null'
	return @ret 
end
update #account set deptno=a.deptno7 from pccode a where #account.argcode<'9' and #account.pccode=a.pccode 
update #account set deptno=a.deptno from pccode a where #account.argcode>='9' and #account.pccode=a.pccode 
if exists(select 1 from #account where deptno='' and pccode<>'') 
begin
	select @ret=1, @msg='当前帐务存在 deptno=null'
	return @ret 
end

--------------------------------------------
-- 余额表部分 
--------------------------------------------
-- 当日帐务发生统计
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

-- 更新累计部分 
if @mode<>'R' -- 自动累加方式，跟上日对比处理 
begin
	-- 一句拆开二句，避免 linux 问题 
	update cus_xf set t_rm=rm, t_rm_svc=rm_svc, t_rm_bf=rm_bf, t_rm_cms=rm_cms, t_rm_lau=rm_lau, t_rm_opak=rm_opak, 
							t_fb=fb, t_mt=mt, t_en=en, t_sp=sp, t_dot=dot, t_dtl=dtl 
	update cus_xf set t_rmb=rmb, t_chk=chk, t_card1=card1, t_card2=card2, t_ar=ar, t_ticket=ticket, t_dscent=dscent, t_cot=cot, t_ctl=ctl 
	if exists(select 1 from ycus_xf where date=@bfdate)
	begin
		-- 一句拆开二句，避免 linux 问题  
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
-- 业绩统计
--------------------------------------------
delete #account where argcode>='9' 
delete #account where tofrom<>''
delete #account where charge = 0 and pccode<>'' and charindex(pccode,@rm_pccodes_nt)=0
-- 删除倒扣房费（也可以改成早餐费）
update #account set quantity=0,charge=0 where accntof<>'' and charindex(pccode,@rm_pccodes_nt)>0 and rtrim(mode) is null
update #account set quantity=0 where charindex(pccode,@rm_pccodes_nt)>0 and not mode like 'J[0-9]%'
update #account set accnt=accntof where accntof<>''

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
-- 房晚
update cus_xf set i_days=isnull((select sum(a.quantity) from #account a	where cus_xf.accnt=a.accnt and a.pccode<>'' and charindex(a.pccode,@rm_pccodes_nt)>0),0)
update cus_xf set x_times=1 where sta='X' and date=bdate 
update cus_xf set n_times=1 where sta='N' and date=bdate 

-- 更新统计指标
update cus_xf set t_arr='T' from master_till a, audit_date b 
	where cus_xf.accnt=a.accnt and a.sta in ('I','O','S') and a.citime is not null and a.citime>=b.begin_ and a.citime<=b.end_ and b.date=@bdate
update cus_xf set t_dep='T' from master_till a, audit_date b 
	where cus_xf.accnt=a.accnt and a.sta in ('O','S') and a.deptime is not null and a.deptime>=b.begin_ and a.deptime<=b.end_ and b.date=@bdate

-- 调整 master: 防止单位业绩重复计算，比如明明同住，但是按照 share 处理的时候，会出现统计错误 
-- 如果 .master 仅作为同住标记。这里也许要调整。比如复次卖房 
-- 2008.4 master 字段现在就是统一的同住共享标志，以下语句似乎不应该了
--update cus_xf set master = isnull((select min(a.accnt) from cus_xf a where a.roomno=cus_xf.roomno
--	and a.cusno=cus_xf.cusno and a.agent=cus_xf.agent and a.source=cus_xf.source and a.i_days>0), master)

--------------------------------------------
-- 余额表部分 - 累加部分完全重建
--------------------------------------------
if @mode = 'R' 
begin
	select @ret = 0 
end 

---- 补漏-1 统计关键字（不同的酒店可能不同）
--update cus_xf set market='OTH' where market=''   -- ar 帐户本来就没有市场码等 
--update cus_xf set src='OTH' where src=''
--update cus_xf set channel='OTH' where channel=''


-----------------------
--- 2. 餐饮消费----------- 
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
-- 修正单位的属性 
update #menu set agent=#menu.cusno from guest a where #menu.cusno=a.no and a.class='A'
update #menu set source=#menu.cusno from guest a where #menu.cusno=a.no and a.class='S'
update #menu set cusno='' where agent<>'' or source<>'' 

-- POS部分应该按照 fb,en 等内容分开 ? 
insert cus_xf(date,actcls, accnt, master, cusno, agent, source, haccnt,saleid, gstno, 
					xf_fb,xf_dtl,fb,dtl,t_fb,t_dtl,bdate,arr,dep) 
	select @bdate,'P', menu, menu, cusno, agent, source, haccnt, saleid, gstno, 
					charge, charge, charge, charge, charge, charge, @bdate,@bdate,@bdate 
		from #menu

-----------------------
-- 后续处理 
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
-- 并入通用统计数据表 
-----------------------
exec p_gl_statistic_saveas 'pcid', @bdate, 'cus_xf'
return @ret 
;
