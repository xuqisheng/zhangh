
// 0204 ��ÿ�շ��ۺ󣬸ù���ȡ�� - simon 2008.6.23 

//
//------------------------------------------------------------------------------
//-- ������������ 
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
//--		Э�������ʱ�䲨���Ĵ���
//--			----- ����ҹ���д���
//--
//--			�������漰ϵͳ��������
//--
//--			����������Ķ����ǣ�
//--				stayover , not share, ratecode not change , roomno not change , value changed 
//--			
//--			ע���۲��� sysoption(reserve, rmrate_autochg_mode, ?)   
//--									1=�ϸ���Э��۸� 2=��� 3=���� 
//-- ----------------------------------------------------------------------------
//
//-- ��ȡ����ģʽ - 1=�ϸ���Э��۸� 2=��� 3=���� 
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
//				@rmrate0			money,	-- ����Э��۸�
//				@rmrate1			money		-- ����Э��۸�
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
//--ҹ��ʱȡҹ����Ӫҵ���ں�ҹ��ǰ������
//select @duringaudit= audit from gate
//if @duringaudit = 'T'
//   select @bfdate = bdate from sysdata
//else
//	select @bfdate = bdate from accthead
//select @bdate = dateadd(day,1,@bfdate)
//
//
//-- ������������
//delete rmrate_tchg where date < dateadd(day, -180, @bdate)
//
//
//-- �����¼
//insert #goutput(accnt,master,groupno,haccnt,vip,cusno,agent,source,market,src,restype,type,roomno,arr,dep,ratecode,rtreason,ref,
//		last_rmrate,last_rate,today_rmrate,today_rate,setrate)
//	select a.accnt,a.master,a.groupno,a.haccnt,'',a.cusno,a.agent,a.source,a.market,a.src,a.restype,a.type,a.roomno,a.arr,a.dep,a.ratecode,a.rtreason,a.ref,
//		a.rmrate,a.setrate,0,b.setrate,0	from master_till a, master b 
//			where a.accnt=b.accnt and a.class='F' and a.sta='I' and b.sta='I' and datediff(dd,@bdate,b.dep) > 0
//				and a.ratecode=b.ratecode and a.roomno=b.roomno
//
//-- ɾ�� ��ѷ� �� ͬס������
//delete #goutput where last_rate = 0
//
//
//-- ɾ������ʵ���뱾��ʵ�۲���ȵķ��� -- ��ʾ�Ѿ�����������
//delete #goutput where last_rate <> today_rate
//
//
//-- Delete ����
//delete #goutput where roomno in (select a.roomno from #goutput a, #goutput b where a.roomno=b.roomno and a.master<>b.master)
//
//-- Delete ͬס���Ѳ��
//delete #goutput where roomno in (select a.roomno from #goutput a group by a.roomno having count(1) > 1 )
//
//-- ���¼���Э��۸�, ͬʱɾ��Э��۸�û�б仯��
//declare c_rate cursor for select accnt, last_rmrate, today_rmrate from #goutput 
//open c_rate
//fetch c_rate into @accnt, @rmrate0, @rmrate1
//while @@sqlstatus=0
//begin
//	-- ����Э���
//	exec @ret = p_gds_get_accnt_rmrate @accnt,@rmrate output,@msg output, @bfdate
//	if @ret = 0	select @rmrate0 = @rmrate
//	-- ����Э���
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
//-- ����ѡ�����۸� 
//if @mode = '1'				-- 1=�ϸ���Э��۸�
//begin
//	delete #goutput where last_rmrate <> last_rate
//	update #goutput set setrate = today_rmrate 
//end
//else if @mode = '2'		-- 2=���
//begin
//	update #goutput set setrate = last_rate - last_rmrate + today_rmrate
//end
//else							-- 3=���� 
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