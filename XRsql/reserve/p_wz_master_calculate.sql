
-- 0204 没有用了，类似功能应该加强结算单    simon  


if exists (select 1 from sysobjects where name  ='rmrev_expect' and type ='U')
	drop table rmrev_expect;

//create table rmrev_expect
//(	col			char(10),
//	row			varchar(30),
//	amount		money		default 0,
//	pc_id			char(5)	
//)	


if exists(select 1 from sysobjects where name = 'p_wz_master_calculate')
	drop proc p_wz_master_calculate
;
//create proc p_wz_master_calculate
//			@pc_id 		char(4)	,
//			@accnt 		char(10)	,
//			@mode			char(1)  ,			--T:room type    N:room no
//			@langid		integer
//as
//-----------------------------------------------------------------------
//---主要统计团队主单房晚数和其他费用！ write by wz at 2004.11.18 xihu
//-----------------------------------------------------------------------
//declare
//		@amount		money,
//		@room_charge_pccodes	varchar(50),
//
//		@accnt1     char(10),
//		@arr1			datetime,
//		@dep1			datetime,
//		@roomno1		char(5),
//		@roomno		char(5),
//		@type			char(5),
//		@groupno		char(10),
//
//		@accnt2		char(10),
//		@arr2			datetime,
//		@dep2			datetime,
//		@roomno2		char(5),
//		
//		@tarr			datetime,
//		@tdep			datetime,
//		@taccnt		char(10)
//
//	
//create table #woutput1
//(	accnt			char(10)		not null,
//	arr			datetime,
//	dep			datetime,
//	night			money			default 0,    	--房晚
//	roomno		char(5)		null,
//	type			char(5)		null,
//	rm_rate1		money			default 0,		--'Room Revenue Net'
//	rm_rate2		money			default 0,		--'Room Revenue Include SVC'
//	rm_rate3		money			default 0,		--'Room Revenue Include Packages'
//	rm_rate4		money			default 0,		--Room Revenue has been happened
//
//	rm				money			default 0,     --客房收入
//	fb				money			default 0,		--餐饮收入
//	en				money			default 0,		--娱乐
//	mt				money			default 0,		--会议
//	ot				money			default 0,		--其他
//	ttl			money			default 0		--合计
//) 
//
//
//create table #tmp
//(	taccnt			char(10)		not null,
//	tarr				datetime,
//	tdep				datetime,
//	night				money			default 0,    	--房晚
//	troomno			char(5)		null,
//	ttype				char(5)		null,
//	trm_rate1		money			default 0,		--'Room Revenue Net'
//	trm_rate2		money			default 0,		--'Room Revenue Include SVC'
//	trm_rate3		money			default 0,		--'Room Revenue Include Packages'
//	trm_rate4		money			default 0,		--Room Revenue has been happened
//
//	trm				money			default 0,     --客房收入
//	tfb				money			default 0,		--餐饮收入
//	ten				money			default 0,		--娱乐
//	tmt				money			default 0,		--会议
//	tot				money			default 0,		--其他
//	ttl		   	money			default 0		--合计
//) 
//
//create table #accnt 
//(	accnt			char(10)	not null,
//	pccode		char(10)	,
//	quantity		money		default 0   not null,
//	charge 		money		default 0	not null,
//	mode			char(10)  				null,
//	tofrom		char(2)	default '' 	null,
//	accntof		char(10)	default ''	null
//)
//
//delete rmrev_expect where pc_id = @pc_id
//--现在客户端传过来就是团队帐号，所以不必这样去取团队主帐号了
////--取团队主单帐号
////if exists(select 1 from master where accnt = @accnt and class= 'F' and groupno <> '' and sta in ('I','O','D','S','R') )
////	select @groupno =groupno from master where accnt = @accnt and class= 'F' and groupno <> '' and sta in ('I','O','D','S','R')  
////else if  exists(select 1 from hmaster where accnt = @accnt and class= 'F' and groupno <> ''  and sta in ('I','O','D','S','R'))
////	select @groupno =groupno from hmaster where accnt = @accnt and class= 'F' and groupno <> '' and sta in ('I','O','D','S','R') 
////else
// select @groupno = @accnt
//
//select @room_charge_pccodes = value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes'
//
//insert #woutput1(accnt,arr,dep,night,roomno,type)
//	select a.accnt,a.arr,a.dep,datediff(dd,a.arr,a.dep)*a.quantity,a.roomno,a.type from rsvsrc a,master b  
//		where a.accnt = b.accnt 
//		and  (b.groupno = @groupno or b.accnt =@groupno)
//		and b.sta in ('I','R')  
//union
//	select accnt,arr,dep,datediff(dd,arr,dep),roomno,type from master 
//		where groupno = @groupno and sta in ('O','S','D')
//union
//	select accnt,arr,dep,datediff(dd,arr,dep),roomno,type from hmaster 
//		where groupno = @groupno and sta = 'O'
//
//
//--
//declare c_cur1	cursor for select accnt,arr,dep from #woutput1
//open c_cur1
//fetch c_cur1 into @accnt1,@arr1,@dep1
//while @@sqlstatus = 0
//begin
//	while @arr1 < @dep1
//	begin
//		exec @amount = p_wz_master_rmcalc_index @arr1,@accnt1,'Room Revenue Net'
//		update #woutput1 set rm_rate1 = rm_rate1 + @amount where #woutput1.accnt = @accnt1	
//		select @amount = 0
//		 
//		exec @amount = p_wz_master_rmcalc_index @arr1,@accnt1,'Room Revenue Include SVC'
//		update #woutput1 set rm_rate2 = rm_rate2 + @amount where #woutput1.accnt = @accnt1	
//		select @amount = 0
//
//		exec @amount = p_wz_master_rmcalc_index @arr1,@accnt1,'Room Revenue Include Packages'
//		update #woutput1 set rm_rate3 =rm_rate3 + @amount where #woutput1.accnt = @accnt1	
//		select @amount = 0
//
//		select @arr1 = dateadd(dd,1,@arr1)
//	end	
//--???为什么uion就少记录
//	insert #accnt (accnt,pccode,quantity,charge,mode,tofrom,accntof)
//		select  @accnt1 ,pccode,quantity,charge,mode,tofrom,accntof 
//			from account 
//			where  tofrom ='' and accnt = @accnt1 
//	insert #accnt (accnt,pccode,quantity,charge,mode,tofrom,accntof)
//		select  @accnt1 ,pccode,quantity,charge,mode,tofrom,accntof 
//			from account 
//			where tofrom = '' and accntof = @accnt1	
//	insert #accnt (accnt,pccode,quantity,charge,mode,tofrom,accntof)
//		select  @accnt1 ,pccode,quantity,charge,mode,tofrom,accntof 
//			from haccount 
//			where accnt = @accnt1 and tofrom = ''
//	insert #accnt (accnt,pccode,quantity,charge,mode,tofrom,accntof)
//		select  @accnt1 ,pccode,quantity,charge,mode,tofrom,accntof 
//			from haccount 
//			where tofrom = '' and accntof = @accnt1	
//
//
//	fetch c_cur1 into @accnt1,@arr1,@dep1
//end 
//close c_cur1
//deallocate cursor c_cur1
//
//
//--dept charge  	
//update #woutput1 set rm_rate4 = isnull((select sum(a.charge) from #accnt a where #woutput1.accnt = a.accnt and charindex(rtrim(a.pccode),@room_charge_pccodes)>0),0)	
//update #woutput1 set rm = isnull((select sum(a.charge) from #accnt a,pccode b where #woutput1.accnt = a.accnt and a.pccode = b.pccode and b.deptno7 = 'rm'),0)	
//update #woutput1 set fb = isnull((select sum(a.charge) from #accnt a,pccode b where #woutput1.accnt = a.accnt and a.pccode = b.pccode and b.deptno7 = 'fb'),0)	
//update #woutput1 set en = isnull((select sum(a.charge) from #accnt a,pccode b where #woutput1.accnt = a.accnt and a.pccode = b.pccode and b.deptno7 = 'en'),0)	
//update #woutput1 set mt = isnull((select sum(a.charge) from #accnt a,pccode b where #woutput1.accnt = a.accnt and a.pccode = b.pccode and b.deptno7 = 'mt'),0)	
//update #woutput1 set ot = isnull((select sum(a.charge) from #accnt a,pccode b where #woutput1.accnt = a.accnt and a.pccode = b.pccode and b.deptno7 = 'ot'),0)	
//
////select * from #woutput1 order by roomno
//
//create table #wtmp
//(	accnt		char(10) 	not null,
//	arr		datetime,
//	dep		datetime,
//	roomno	char(5)		not null,
//	tag		char(1)	   default '0'     --0:    1:delete
//)
//--算房晚  同住的情况要考虑抵离日期不同
//declare c_cur2 cursor for select accnt,arr,dep,roomno from #woutput1 where roomno in (select  roomno from #woutput1 group by roomno having count(roomno) > 1) order by roomno
//open c_cur2
//fetch c_cur2 into @accnt2,@arr2,@dep2,@roomno2
//while @@sqlstatus = 0
//begin
//	select @roomno2 = ltrim(rtrim(@roomno2))
//	if not exists(select 1 from #wtmp where rtrim(roomno) = rtrim(@roomno2)) or rtrim(@roomno2) is null
//		insert #wtmp(accnt,arr,dep,roomno,tag) select @accnt2,@arr2,@dep2,@roomno2,'0'
//	else
//		insert #wtmp(accnt,arr,dep,roomno,tag) select @accnt2,@arr2,@dep2,@roomno2,'1'
//
//	fetch c_cur2 into @accnt2,@arr2,@dep2,@roomno2
//end 
//close c_cur2
//deallocate cursor c_cur2
//
////select * from #wtmp order by roomno
//
//declare c_cur3 cursor for select accnt,arr,dep,roomno from #wtmp where tag  = '0'
//open c_cur3
//fetch c_cur3 into @accnt1,@arr1,@dep1,@roomno1 
//while @@sqlstatus = 0
//begin
//	select @taccnt = accnt ,@tarr = arr,@tdep = dep from #wtmp where tag = '1' and roomno = @roomno1
//	if @tarr>=@arr1 and @tarr<@dep1 and @tdep>@dep1
//		select @amount = datediff(dd,@dep1,@tdep)
//	else
//		select @amount = 0
//	
//	update #woutput1 set night = night + @amount where accnt = @accnt1
//	fetch c_cur3 into @accnt1,@arr1,@dep1,@roomno1
//end 
//close c_cur3
//deallocate cursor c_cur3
//
//insert #tmp select * from #woutput1  where accnt in (select accnt from #wtmp where tag = '1')
//delete #woutput1 where accnt in (select accnt from #wtmp where tag = '1')
//
//
//update #woutput1 set rm_rate1 = rm_rate1+a.trm_rate1,rm_rate2 = rm_rate2+a.trm_rate2,rm_rate3=rm_rate3+a.trm_rate3,
//		rm_rate4 = rm_rate4+trm_rate4,rm=rm+a.trm,fb=fb+a.tfb,en=en+a.ten,mt=mt+a.tmt,ot=ot+a.tot 
//	from #tmp a where roomno = a.troomno
//
//update #woutput1 set ttl = rm+fb+mt+en+ot
//
//
//
//if @langid = 0 
//begin
//	if @mode = 'T'
//	begin
//		insert rmrev_expect select  type,'1.房晚',sum(night),@pc_id from #woutput1 group by type
//		insert rmrev_expect select  type,'2.净房费',sum(rm_rate1),@pc_id from #woutput1 group by type	
//		insert rmrev_expect select  type,'3.净房费+SVR',sum(rm_rate2),@pc_id from #woutput1 	group by type
//		insert rmrev_expect select  type,'4.净房费+SVR+PKG',sum(rm_rate3),@pc_id from #woutput1 	group by type
////		insert rmrev_expect select  type,'5.房费',sum(rm_rate4) from #woutput1 	group by type
//		insert rmrev_expect select  type,'5.平均房费',sum(rm_rate1)/sum(night),@pc_id from #woutput1 	group by type
//		insert rmrev_expect select  type,'R.客房',sum(rm),@pc_id from #woutput1 group by type	
//		insert rmrev_expect select  type,'F.餐饮',sum(fb),@pc_id from #woutput1 group by type
//		insert rmrev_expect select  type,'E.娱乐',sum(en),@pc_id from #woutput1 group by type	
//		insert rmrev_expect select  type,'M.会议',sum(mt),@pc_id from #woutput1 group by type	
//		insert rmrev_expect select  type,'O.其他',sum(ot),@pc_id from #woutput1 group by type	
//	end
//	else
//	begin
//		insert rmrev_expect select  roomno,'1.房晚',sum(night),@pc_id from #woutput1 group by roomno
//		insert rmrev_expect select  roomno,'2.净房费',sum(rm_rate1),@pc_id from #woutput1 group by roomno	
//		insert rmrev_expect select  roomno,'3.净房费+SVR',sum(rm_rate2),@pc_id from #woutput1 	group by roomno
//		insert rmrev_expect select  roomno,'4.净房费+SVR+PKG',sum(rm_rate3),@pc_id from #woutput1 	group by roomno
////		insert rmrev_expect select  roomno,'5.房费',sum(rm_rate4) from #woutput1 	group by roomno
//		insert rmrev_expect select  roomno,'5.平均房费',sum(rm_rate1)/sum(night),@pc_id from #woutput1 	group by roomno
//		insert rmrev_expect select  roomno,'R.客房',sum(rm),@pc_id from #woutput1 group by roomno	
//		insert rmrev_expect select  roomno,'F.餐饮',sum(fb),@pc_id from #woutput1 group by roomno
//		insert rmrev_expect select  roomno,'E.娱乐',sum(en),@pc_id from #woutput1 group by roomno	
//		insert rmrev_expect select  roomno,'M.会议',sum(mt),@pc_id from #woutput1 group by roomno	
//		insert rmrev_expect select  roomno,'O.其他',sum(ot),@pc_id from #woutput1 group by roomno	
//	end	
//
////--totel for crosstab
//		insert rmrev_expect select 'Z.合计','1.房晚',sum(amount),@pc_id from rmrev_expect where row = '1.房晚' and pc_id = @pc_id
//		insert rmrev_expect select 'Z.合计','2.净房费',sum(amount),@pc_id from rmrev_expect where row = '2.净房费' and pc_id = @pc_id
//		insert rmrev_expect select 'Z.合计','3.净房费+SVR',sum(amount),@pc_id from rmrev_expect where row = '3.净房费+SVR' and pc_id = @pc_id
//		insert rmrev_expect select 'Z.合计','4.净房费+SVR+PKG',sum(amount),@pc_id from rmrev_expect where row = '4.净房费+SVR+PKG'  and pc_id = @pc_id
//		insert rmrev_expect select 'Z.合计','5.平均房费', isnull((select sum(amount) from rmrev_expect where row = '2.净房费' and pc_id = @pc_id)/(select sum(amount) from rmrev_expect where row = '1.房晚' and pc_id = @pc_id),0),@pc_id
//		insert rmrev_expect select 'Z.合计','R.客房',sum(amount) ,@pc_id from rmrev_expect where row = 'R.客房' and pc_id = @pc_id
//		insert rmrev_expect select 'Z.合计','F.餐饮',sum(amount),@pc_id from rmrev_expect where row = 'F.餐饮' and pc_id = @pc_id
//		insert rmrev_expect select 'Z.合计','E.娱乐',sum(amount),@pc_id from rmrev_expect where row = 'E.娱乐' and pc_id = @pc_id
//		insert rmrev_expect select 'Z.合计','M.会议',sum(amount),@pc_id from rmrev_expect where row = 'M.会议' and pc_id = @pc_id
//		insert rmrev_expect select 'Z.合计','O.其他',sum(amount) ,@pc_id from rmrev_expect where row = 'O.其他' and pc_id = @pc_id
//end
//else 
//begin
//	if @mode = 'T'
//	begin
//		insert rmrev_expect select  type,'1.RM NTS',sum(night),@pc_id  from #woutput1 group by type
//		insert rmrev_expect select  type,'2.RM REVE NET',sum(rm_rate1) ,@pc_id from #woutput1 group by type	
//		insert rmrev_expect select  type,'3.RM REVE +15%',sum(rm_rate2) ,@pc_id from #woutput1 	group by type
//		insert rmrev_expect select  type,'4.TTL RM REVE',sum(rm_rate3) ,@pc_id from #woutput1 	group by type
////		insert rmrev_expect select  type,'5.RM REVE NET(ACT)',sum(rm_rate4) ,@pc_id from #woutput1 	group by type
//		insert rmrev_expect select  type,'5.ATR',sum(rm_rate1)/sum(night) ,@pc_id from #woutput1 	group by type
//		insert rmrev_expect select  type,'R.HSKP',sum(rm) ,@pc_id from #woutput1 group by type	
//		insert rmrev_expect select  type,'F.FB',sum(fb) ,@pc_id from #woutput1 group by type
//		insert rmrev_expect select  type,'E.ENT',sum(en) ,@pc_id from #woutput1 group by type	
//		insert rmrev_expect select  type,'M.MTG',sum(mt) ,@pc_id from #woutput1 group by type	
//		insert rmrev_expect select  type,'O.OTH',sum(ot) ,@pc_id from #woutput1 group by type	
//	end
//	else
//	begin
//		insert rmrev_expect select  roomno,'1.RM NTS',sum(night) ,@pc_id from #woutput1 group by roomno
//		insert rmrev_expect select  roomno,'2.RM REVE NET',sum(rm_rate1) ,@pc_id from #woutput1 group by roomno	
//		insert rmrev_expect select  roomno,'3.RM REVE +15%',sum(rm_rate2) ,@pc_id from #woutput1 	group by roomno
//		insert rmrev_expect select  roomno,'4.TTL RM REVE',sum(rm_rate3) ,@pc_id from #woutput1 	group by roomno
////		insert rmrev_expect select  roomno,'5.RM REVE NET(ACT)',sum(rm_rate4) ,@pc_id from #woutput1 	group by roomno
//		insert rmrev_expect select  roomno,'5.ATR',sum(rm_rate1)/sum(night) ,@pc_id from #woutput1 	group by roomno
//		insert rmrev_expect select  roomno,'R.HSKP',sum(rm) ,@pc_id from #woutput1 group by roomno	
//		insert rmrev_expect select  roomno,'F.FB',sum(fb) ,@pc_id from #woutput1 group by roomno
//		insert rmrev_expect select  roomno,'E.ENT',sum(en) ,@pc_id from #woutput1 group by roomno	
//		insert rmrev_expect select  roomno,'M.MTG',sum(mt) ,@pc_id from #woutput1 group by roomno	
//		insert rmrev_expect select  roomno,'O.OTH',sum(ot) ,@pc_id from #woutput1 group by roomno	
//	end
//
////--totel for crosstab
//		insert rmrev_expect select 'Z.Total','1.RM NTS',sum(amount) ,@pc_id from rmrev_expect where row = '1.RM NTS' and pc_id = @pc_id
//		insert rmrev_expect select 'Z.Total','2.RM REVE NET',sum(amount) ,@pc_id from rmrev_expect where row = '2.RM REVE NET' and pc_id = @pc_id
//		insert rmrev_expect select 'Z.Total','3.RM REVE +15%',sum(amount) ,@pc_id from rmrev_expect where row = '3.RM REVE +15%' and pc_id = @pc_id
//		insert rmrev_expect select 'Z.Total','4.TTL RM REVE',sum(amount) ,@pc_id from rmrev_expect where row = '4.TTL RM REVE' and pc_id = @pc_id
//		insert rmrev_expect select 'Z.Total','5.ATR', isnull((select sum(amount) from rmrev_expect where row = '2.RM REVE NET' and pc_id = @pc_id)/(select sum(amount) from rmrev_expect where row = '1.RM NTS' and pc_id = @pc_id),0),@pc_id
//		insert rmrev_expect select 'Z.Total','R.HSKP',sum(amount) ,@pc_id from rmrev_expect where row = 'R.HSKP' and pc_id = @pc_id
//		insert rmrev_expect select 'Z.Total','F.FB',sum(amount) ,@pc_id from rmrev_expect where row = 'F.FB' and pc_id = @pc_id
//		insert rmrev_expect select 'Z.Total','E.ENT',sum(amount) ,@pc_id from rmrev_expect where row = 'E.ENT' and pc_id = @pc_id
//		insert rmrev_expect select 'Z.Total','M.MTG',sum(amount) ,@pc_id from rmrev_expect where row = 'M.MTG' and pc_id = @pc_id
//		insert rmrev_expect select 'Z.Total','O.OTH',sum(amount) ,@pc_id from rmrev_expect where row = 'O.OTH' and pc_id = @pc_id
//end	
//
//
//return 0
//
//;