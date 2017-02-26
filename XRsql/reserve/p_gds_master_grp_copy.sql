
if exists(select 1 from sysobjects where name = "p_gds_master_grp_copy")
	drop proc p_gds_master_grp_copy;
create proc p_gds_master_grp_copy
	@accnt			char(10),
	@arr				datetime,
	@dep				datetime,
	@ratecode		char(10),
	@rate				money,
	@quan				int,
	@gstno			int,
	@remark			varchar(50),
	@empno			char(10),
	@retmode			char(1),			-- S, R
	@ret        	int			output,
   @msg        	varchar(60) output 
as
----------------------------------------------------------------------------------------------
--		团体复制
--
--		仅仅复制主单，不包括客房预留；
--
----------------------------------------------------------------------------------------------
declare		@class			char(1),
				@maccnt			char(10),
				@resno			char(10),
				@bdate			datetime,
				@haccnt0			char(7),
				@haccnt			char(7),
				@newgst			char(1),
				@today			datetime

-- msg = newgst 表示要创建新的团体档案 
if @msg is not null and @msg='newgst' 
	select @newgst='T'
else
	select @newgst='F'

select @ret=0, @msg='', @maccnt='', @bdate=bdate1, @today=getdate() from sysdata

-- 不能放在事务里面
select * into #master from master where 1=2  
select * into #guest from guest where 1=2

begin tran
save 	tran group_copy

-- Begin
if datediff(dd, @arr, @today) >0 or datediff(dd, @arr, @dep)<0 
begin
	select @ret=1, @msg='日期错误'
	goto gout
end

select @class = ''
insert #master select * from master where accnt=@accnt 
if @@rowcount = 0
begin
	 -- hmaster 字段比master 多一部分 guest 简要内容   
	insert #master(accnt,haccnt,groupno,type,otype,up_type,up_reason,rmnum,
				ormnum,roomno,oroomno,bdate,sta,osta,ressta,exp_sta,sta_tm,
				rmpoststa,rmposted,tag0,arr,dep,resdep,oarr,odep,agent,cusno,
				source,class,src,market,restype,channel,artag1,artag2,share,gstno,
				children,rmreason,ratecode,packages,fixrate,rmrate,qtrate,setrate,
				rtreason,discount,discount1,addbed,addbed_rate,crib,crib_rate,paycode,
				limit,credcode,credman,credunit,applname,applicant,araccnt,phone,fax,
				email,wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,
				depinfo,depcar,deprate,extra,charge,credit,accredit,lastnumb,lastinumb,
				srqs,amenities,master,saccnt,blkcode,pcrec,pcrec_pkg,resno,crsno,ref,
				comsg,card,saleid,cmscode,cardcode,cardno,resby,restime,ciby,citime,
				coby,cotime,depby,deptime,cby,changed,exp_m1,exp_m2,exp_dt1,exp_dt2,
				exp_s1,exp_s2,exp_s3,logmark,oblkcode,exp_s4,exp_s5,exp_s6)
		select a.accnt,a.haccnt,a.groupno,a.type,a.otype,a.up_type,a.up_reason,a.rmnum,
				a.ormnum,a.roomno,a.oroomno,a.bdate,a.sta,a.osta,a.ressta,a.exp_sta,a.sta_tm,
				a.rmpoststa,a.rmposted,a.tag0,a.arr,a.dep,a.resdep,a.oarr,a.odep,a.agent,a.cusno,
				a.source,a.class,a.src,a.market,a.restype,a.channel,a.artag1,a.artag2,a.share,a.gstno,
				a.children,a.rmreason,a.ratecode,a.packages,a.fixrate,a.rmrate,a.qtrate,a.setrate,
				a.rtreason,a.discount,a.discount1,a.addbed,a.addbed_rate,a.crib,a.crib_rate,a.paycode,
				a.limit,a.credcode,a.credman,a.credunit,a.applname,a.applicant,a.araccnt,a.phone,a.fax,
				a.email,a.wherefrom,a.whereto,a.purpose,a.arrdate,a.arrinfo,a.arrcar,a.arrrate,a.depdate,
				a.depinfo,a.depcar,a.deprate,a.extra,a.charge,a.credit,a.accredit,a.lastnumb,a.lastinumb,
				a.srqs,a.amenities,a.master,a.saccnt,a.blkcode,a.pcrec,a.pcrec_pkg,a.resno,a.crsno,a.ref,
				a.comsg,a.card,a.saleid,a.cmscode,a.cardcode,a.cardno,a.resby,a.restime,a.ciby,a.citime,
				a.coby,a.cotime,a.depby,a.deptime,a.cby,a.changed,a.exp_m1,a.exp_m2,a.exp_dt1,a.exp_dt2,
				a.exp_s1,a.exp_s2,a.exp_s3,a.logmark,a.oblkcode,a.exp_s4,a.exp_s5,a.exp_s6  
		 from hmaster a where a.accnt=@accnt 
	if @@rowcount=0
	begin
		select @ret=1, @msg='需要复制的团体不存在-%1^' + @accnt
		goto gout
	end
end

select @class = class, @haccnt=haccnt from #master
if @@rowcount=0 or @class not in ('G', 'M')
begin
	select @ret=1, @msg='需要复制的团体不存在-%1^' + @accnt
	goto gout
end
if not exists(select 1 from guest where no=@haccnt)
begin
	select @ret=1, @msg='档案不存在'
	goto gout
end
select @haccnt0 = @haccnt

-- 
if @class = 'G'
	exec p_GetAccnt1 'GRP', @maccnt output
else
	exec p_GetAccnt1 'MET', @maccnt output
exec p_GetAccnt1 'RES', @resno output

if @newgst='T'
begin
	exec p_GetAccnt1 'HIS', @haccnt output
	insert #guest select * from guest where no=@haccnt0 
	update #guest set no=@haccnt, crtby=@empno,crttime=@today,cby=@empno,changed=@today,logmark=0,
		name=name+'(copy)',name2=name2+'(copy)',name3=name3+'(copy)' 
	insert guest select * from #guest 
	if @@rowcount = 0 
	begin
		select @ret=1, @msg='档案创建失败'
		goto gout
	end
	exec p_gds_guest_name4 @haccnt  
end

--, oarr=null odep=null,
update #master set accnt=@maccnt, haccnt=@haccnt, resno=@resno, crsno='', sta='R', osta='', 
	arr=@arr, dep=@dep, oarr=@arr, odep=@dep, resdep=null,
	rmnum=@quan, ormnum=0, gstno=@gstno, children=0, ratecode=@ratecode, qtrate=@rate, rmrate=@rate, setrate=@rate, 
	pcrec='',pcrec_pkg='', resby=@empno,restime=@today,ciby='',citime=null,
	coby='',cotime=null,depby='',deptime=null,cby=@empno,changed=@today,
	arrdate=null, arrinfo='', arrcar='', arrrate=null,
	depdate=null, depinfo='', depcar='', deprate=null,
	lastnumb=0,lastinumb=0,charge=0,credit=0,accredit=0, logmark=0
if @@rowcount = 1
begin
	if rtrim(@remark) is not null
		update #master set ref=@remark
	insert master select * from #master
	if @@rowcount = 0
		select @ret=1, @msg='更新失败'
end
else
	select @ret=1, @msg='更新失败'

--
gout:
if @ret <> 0
	rollback tran group_copy
else
begin
	exec p_gds_master_des_maint @maccnt
	select @msg = @maccnt
end
commit tran
drop table #master
--
if @retmode='S'
	select @ret, @msg
return @ret
;

