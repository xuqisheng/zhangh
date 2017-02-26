
// 0204 有每日房价后，该功能取消 - simon 2008.6.23 

//
//------------------------------------------------------------------------------
//-- 保留处理数据 
//------------------------------------------------------------------------------
if object_id('rmrate_tchg') is not null 
	drop table rmrate_tchg;
//create table rmrate_tchg
//(
//	date				datetime								not null,
//	accnt				char(10)								not null,
//	master			char(10)								not null,
//	groupno			varchar(60)		default ''		not null,
//	haccnt			varchar(60)							not null,
//	vip				char(3)			default ''		not null,
//	cusno				varchar(60)		default ''		not null,
//	agent				varchar(60)		default ''		not null,
//	source			varchar(60)		default ''		not null,
//	market			char(3)			default ''		null,
//	src				char(3)			default ''		null,
//	restype			char(3)			default ''		null,
//	type				char(5)								not null,
//	roomno			char(5)								not null,
//	arr				datetime								not null,
//	dep				datetime								not null,
//	ratecode			varchar(10)		default ''		not null,
//	rtreason			char(3)			default ''		not null,
//	ref				varchar(255)						null,	
//
//	last_rmrate		money				default 0		not null,
//	last_rate		money				default 0		not null,
//	today_rmrate	money				default 0		not null,
//	today_rate		money				default 0		not null,
//	setrate			money				default 0		not null,
//
//	cby				char(10)								not null,
//	changed			datetime								not null
//);
//create unique index index1 on rmrate_tchg(date, accnt);
//
//
if object_id('p_gds_audit_rmrate_tchg') is not null 
	drop proc p_gds_audit_rmrate_tchg;
//create proc p_gds_audit_rmrate_tchg
//	@empno 		varchar(10),
//	@ret			integer			out,
//	@msg			varchar(70)		out
//as
//-- ----------------------------------------------------------------------------
//--		协议价随着时间波动的处理
//--			----- 放在夜审中处理
//--
//--			本程序不涉及系统调整房价
//--
//--			本程序调整的对象是：
//--				stayover , not share, ratecode not change , roomno not change , value changed 
//--			
//--			注意变价参数 sysoption(reserve, rmrate_autochg_mode, ?)   
//--									1=严格按照协议价格 2=差价 3=比率 
//-- ----------------------------------------------------------------------------
//
//-- 提取计算模式 - 1=严格按照协议价格 2=差价 3=比率 
//declare		@mode				char(1)
//select @mode = isnull((select substring(value,1,1) from sysoption where catalog = 'reserve' and item = 'rmrate_autochg_mode'), '0')
//if charindex(@mode, '123') = 0 
//	return 0
//
//
//declare		@duringaudit	char(1),
//				@bdate			datetime,
//				@bfdate			datetime,
//				@accnt			char(10),
//				@rmrate			money,
//				@setrate			money,
//				@rmrate0			money,	-- 上日协议价格
//				@rmrate1			money		-- 本日协议价格
//				
//                   
//create table #goutput
//(
//	accnt				char(10)								not null,
//	master			char(10)								not null,
//	groupno			varchar(60)		default ''		not null,
//	haccnt			varchar(60)							not null,
//	vip				char(3)			default ''		not null,
//	cusno				varchar(60)		default ''		not null,
//	agent				varchar(60)		default ''		not null,
//	source			varchar(60)		default ''		not null,
//	market			char(3)			default ''		null,
//	src				char(3)			default ''		null,
//	restype			char(3)			default ''		null,
//	type				char(5)								not null,
//	roomno			char(5)								not null,
//	arr				datetime								not null,
//	dep				datetime								not null,
//	ratecode			varchar(10)		default ''		not null,
//	rtreason			char(3)			default ''		not null,
//	ref				varchar(255)						null,	
//
//	last_rmrate		money				default 0		not null,
//	last_rate		money				default 0		not null,
//	today_rmrate	money				default 0		not null,
//	today_rate		money				default 0		not null,
//	setrate			money				default 0		not null 
//)
//
//
//select @ret=0, @msg=''
//
//--夜审时取夜审后的营业日期和夜审前的日期
//select @duringaudit= audit from gate
//if @duringaudit = 'T'
//   select @bfdate = bdate from sysdata
//else
//	select @bfdate = bdate from accthead
//select @bdate = dateadd(day,1,@bfdate)
//
//
//-- 保留半年数据
//delete rmrate_tchg where date < dateadd(day, -180, @bdate)
//
//
//-- 插入纪录
//insert #goutput(accnt,master,groupno,haccnt,vip,cusno,agent,source,market,src,restype,type,roomno,arr,dep,ratecode,rtreason,ref,
//		last_rmrate,last_rate,today_rmrate,today_rate,setrate)
//	select a.accnt,a.master,a.groupno,a.haccnt,'',a.cusno,a.agent,a.source,a.market,a.src,a.restype,a.type,a.roomno,a.arr,a.dep,a.ratecode,a.rtreason,a.ref,
//		a.rmrate,a.setrate,0,b.setrate,0	from master_till a, master b 
//			where a.accnt=b.accnt and a.class='F' and a.sta='I' and b.sta='I' and datediff(dd,@bdate,b.dep) > 0
//				and a.ratecode=b.ratecode and a.roomno=b.roomno
//
//-- 删除 免费房 和 同住附属房
//delete #goutput where last_rate = 0
//
//
//-- 删除上日实价与本日实价不相等的房间 -- 表示已经做过处理了
//delete #goutput where last_rate <> today_rate
//
//
//-- Delete 共享房
//delete #goutput where roomno in (select a.roomno from #goutput a, #goutput b where a.roomno=b.roomno and a.master<>b.master)
//
//-- Delete 同住房费拆分
//delete #goutput where roomno in (select a.roomno from #goutput a group by a.roomno having count(1) > 1 )
//
//-- 重新计算协议价格, 同时删除协议价格没有变化的
//declare c_rate cursor for select accnt, last_rmrate, today_rmrate from #goutput 
//open c_rate
//fetch c_rate into @accnt, @rmrate0, @rmrate1
//while @@sqlstatus=0
//begin
//	-- 上日协议价
//	exec @ret = p_gds_get_accnt_rmrate @accnt,@rmrate output,@msg output, @bfdate
//	if @ret = 0	select @rmrate0 = @rmrate
//	-- 本日协议价
//	exec @ret = p_gds_get_accnt_rmrate @accnt,@rmrate output,@msg output, @bdate
//	if @ret = 0	select @rmrate1 = @rmrate
//
//	update #goutput set last_rmrate =@rmrate0, today_rmrate =@rmrate1 where accnt = @accnt
//
//	fetch c_rate into @accnt, @rmrate0, @rmrate1
//end
//close c_rate
//deallocate cursor c_rate
//delete #goutput where last_rmrate = today_rmrate 
//
//
//-- 根据选项计算价格 
//if @mode = '1'				-- 1=严格按照协议价格
//begin
//	delete #goutput where last_rmrate <> last_rate
//	update #goutput set setrate = today_rmrate 
//end
//else if @mode = '2'		-- 2=差价
//begin
//	update #goutput set setrate = last_rate - last_rmrate + today_rmrate
//end
//else							-- 3=比率 
//begin
//	delete #goutput where last_rmrate<>0 
//	update #goutput set setrate = round(today_rmrate * last_rate / last_rmrate, 2) 
//end
//update #goutput set setrate = 0 where setrate<0 
//
//
//-- 
//update #goutput set vip = a.vip from guest a where #goutput.haccnt = a.no
//update #goutput set groupno = a.groupno,haccnt = a.haccnt,cusno = a.cusno,agent = a.agent,source = a.source
//	from master_des a where #goutput.accnt = a.accnt
//
//
//--update master setrate
//begin tran
//save tran p_gds_audit_rmrate_tchg_s1
//select @ret = 0,@msg=''
//declare c_chg_rmrate cursor for select accnt,today_rmrate,setrate from #goutput order by roomno
//open c_chg_rmrate
//fetch c_chg_rmrate into @accnt,@rmrate,@setrate
//while @@sqlstatus=0
//begin
//	update master set rmrate=@rmrate, setrate=@setrate, cby=@empno, changed=getdate(), logmark=logmark+1 where accnt = @accnt
//   if @@rowcount = 0
//		begin
//		select @ret=1, @msg='Update Error'
//		break
//		end
//	else
//      insert rmrate_tchg select @bdate, *, @empno, getdate() from #goutput where accnt=@accnt
//
//	fetch c_chg_rmrate into @accnt,@rmrate,@setrate
//end
//close c_chg_rmrate
//deallocate cursor c_chg_rmrate
//
//--gout:
//if @ret <> 0
//   rollback tran p_gds_audit_rmrate_tchg_s1
//commit tran
//
//return @ret;
//