
// 0204 有每日房价后，该功能取消 - simon 2008.6.23 
//
if exists(select * from sysobjects where name = "rmrate_tchg")
   drop table rmrate_tchg;
//-- ----------------------------------------------------------------------------
//--		房价检测和修改
//-- ----------------------------------------------------------------------------
if exists (select * from sysobjects where name = 'p_gds_rmrate_tchg')
	drop proc p_gds_rmrate_tchg;
//create proc p_gds_rmrate_tchg
//as
//-- ----------------------------------------------------------------------------
//--		协议价随着时间波动的处理
//--			----- 窗口功能，不放在夜审中处理
//--
//--			本程序不涉及系统调整房价
//--
//--			本程序调整的对象是：
//--				stayover , not share, ratecode not change , roomno not change , value changed 
//-- ----------------------------------------------------------------------------
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
//declare		@bdate			datetime,
//				@bfdate			datetime,
//				@accnt			char(10),
//				@rmrate			money,
//				@rmrate0			money,
//				@ret				int,
//				@msg				varchar(60)
//
//select @ret=0, @msg='', @bdate = bdate1 from sysdata
//select @bfdate = bdate from accthead
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
//-- Delete 共享房
//delete #goutput where roomno in (select a.roomno from #goutput a, #goutput b where a.roomno=b.roomno and a.master<>b.master)
//
//-- Delete 同住房费拆分
//delete #goutput where roomno in (select a.roomno from #goutput a group by a.roomno having count(1) > 1 )
//
//-- Calc today_rmrate
//declare c_rate cursor for select accnt from #goutput 
//open c_rate
//fetch c_rate into @accnt
//while @@sqlstatus=0
//begin
//
//	-- 上日协议价
//	exec @ret = p_gds_get_accnt_rmrate @accnt,@rmrate0 output,@msg output, @bfdate
//	if @ret = 0
//		update #goutput set last_rmrate = @rmrate0 where accnt = @accnt
//
//
//	-- 本日协议价
//	exec @ret = p_gds_get_accnt_rmrate @accnt,@rmrate output,@msg output, @bdate
//	if @ret = 0
//	begin
//		if @rmrate0 <> @rmrate 
//			update #goutput set today_rmrate = @rmrate where accnt = @accnt
//		else
//			delete #goutput where accnt = @accnt
//	end
//
//--	begin
//--		if @rmrate0 <> @rmrate 
//--			update #goutput set today_rmrate = @rmrate where accnt = @accnt
//--		else
//--			delete #goutput where accnt = @accnt
//--	end
//
//	fetch c_rate into @accnt
//end
//close c_rate
//deallocate cursor c_rate
//
//-- 
//update #goutput set vip = a.vip from guest a where #goutput.haccnt = a.no
//update #goutput set groupno = a.groupno,haccnt = a.haccnt,cusno = a.cusno,agent = a.agent,source = a.source
//	from master_des a where #goutput.accnt = a.accnt
//
//-- output
//select accnt,haccnt,vip,unit=groupno+'/'+cusno+'/'+agent+'/'+source,market,src,restype,type,roomno,arr,dep,ratecode,rtreason,ref,
//		last_rmrate,last_rate,today_rmrate,today_rate,setrate,need='F'
//	from #goutput order by roomno
//
//return 0
//;