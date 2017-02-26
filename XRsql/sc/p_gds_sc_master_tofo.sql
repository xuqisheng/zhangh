

IF OBJECT_ID('p_gds_sc_master_tofo') IS NOT NULL
    DROP PROCEDURE p_gds_sc_master_tofo
;
create proc p_gds_sc_master_tofo
   @accnt  	char(10),
   @empno  	char(10),
	@retmode	char(1) = 'S',
	@ret		int				output,
	@msg		varchar(60)		output
as

--------------------------------------------------------------------
--	sc_master tofo --> send to front office system
-- 仅仅需要更改 foact 标记 
--------------------------------------------------------------------
declare
	@sta       	char(1),
	@foact		char(10),
	@bdate		datetime,
	@status		char(10)

select @ret = 0, @msg = "" 
select @bdate = bdate1 from sysdata

select @status=status, @sta=sta, @foact=foact from sc_master where accnt=@accnt
if @@rowcount = 0
begin
	select @ret=1, @msg='当前账户不存在'
	goto gout
end
if substring(@foact,2,1)='F' 
begin
	select @ret=1, @msg='当前账户已经发送到前台系统'
	goto gout
end
if @sta<>'R'
begin
	select @ret=1, @msg='当前账户非有效预订状态'
	goto gout
end
if not exists(select 1 from sc_ressta where code=@status and definite='T')
begin
	select @ret=1, @msg='非确认预订不能发送到前台'
	goto gout
end

update sc_master set foact=stuff(foact,2,1,'F'), 
	cby=@empno, changed=getdate(), 
	tfby=@empno, tftime=getdate(), logmark=logmark+1 where accnt=@accnt 
if @@rowcount = 0
	select @ret=1, @msg='发送失败'

--
gout:

if @retmode = 'S'
	select @ret,@msg
return @ret
;








//
//IF OBJECT_ID('p_gds_sc_master_tofo') IS NOT NULL
//    DROP PROCEDURE p_gds_sc_master_tofo
//;
//create proc p_gds_sc_master_tofo
//   @accnt  	char(10),
//   @empno  	char(10),
//	@retmode	char(1) = 'S',
//	@ret		int				output,
//	@msg		varchar(60)		output
//as
//
//--------------------------------------------------------------------
//--	sc_master tofo --> send to front office system
//--------------------------------------------------------------------
//declare
//	@sta       	char(1),
//	@lastinumb 	int,
//	@foact		char(10),
//	@bdate		datetime,
//	@haccnt		char(7),
//	@extra		char(30),
//	@update     char(1)
//
//select @ret = 0,@msg = "",@update='F'
//select @bdate = bdate1 from sysdata
//
//begin tran
//save  tran p_gds_sc_master_tofo_s1
//
//select @sta=sta, @foact=foact, @haccnt=haccnt, @extra=extra from sc_master where accnt=@accnt
//if @@rowcount = 0
//begin
//	select @ret=1, @msg='当前账户不存在'
//	goto gout
//end
//if @foact<>'' or exists(select 1 from master where accnt=@accnt)
//begin
//	--select @ret=1, @msg='当前账户已经发送到前台系统'
//	--goto gout
//    select @update='T'
//end
//if @sta<>'R'
//begin
//	select @ret=1, @msg='当前账户非有效预订状态'
//	goto gout
//end
//if @haccnt=''
//begin
//	select @ret=1, @msg='没有团体档案'
//	goto gout
//end
//
//update sc_master set sta = sta where accnt = @accnt
//
//-- 注意几个对应关系
//--			master.extra = 14/15 -> 1
//--			master.exp_s2 = sc_master.contact
//--			master.exp_dt1 = sc_master.cutoff
//select @extra = stuff(@extra, 14, 2, '11')
//if @update='F'
//	insert master(accnt,haccnt,groupno,type,otype,up_type,up_reason,rmnum,ormnum,roomno,oroomno,bdate,
//		sta,osta,ressta,exp_sta,sta_tm,rmpoststa,rmposted,tag0,arr,dep,resdep,oarr,odep,agent,cusno,
//		source,class,src,market,restype,channel,artag1,artag2,share,gstno,children,rmreason,ratecode,
//		packages,fixrate,rmrate,qtrate,setrate,rtreason,discount,discount1,addbed,addbed_rate,crib,crib_rate,
//		paycode,limit,credcode,credman,credunit,applname,applicant,araccnt,phone,fax,email,
//		wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,extra,
//		charge,credit,accredit,lastnumb,lastinumb,srqs,amenities,master,saccnt,pcrec,pcrec_pkg,resno,
//		crsno,ref,comsg,card,saleid,cmscode,cardcode,cardno,resby,restime,ciby,citime,coby,cotime,depby,
//		deptime,cby,changed,exp_m1,exp_m2,exp_dt1,exp_dt2,exp_s1,exp_s2,exp_s3,logmark)
//	SELECT accnt,haccnt,'',type,otype,'','',rmnum,rmnum,'','',bdate,
//		sta,osta,'','','','','F','',arr,dep,null,oarr,odep,agent,cusno,
//		source,class,src,market,restype,channel,'','','F',gstno,children,'',ratecode,
//		packages,'F',setrate,setrate,setrate,'',0,0,0,0,0,0,
//		paycode,limit,credcode,credman,credunit,'','',araccnt,'','','',
//		wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,@extra,
//		charge,credit,accredit,lastnumb,lastinumb,srqs,amenities,master,saccnt,pcrec,pcrec_pkg,resno,
//		crsno,ref,comsg,'',saleid,cmscode,cardcode,cardno,resby,restime,'',null,coby,cotime,depby,
//		deptime,cby,changed,exp_m1,exp_m2,cutoff,exp_dt2,exp_s1,contact,exp_s3,logmark
//   FROM sc_master where accnt=@accnt
//else
//   update master set haccnt=a.haccnt,groupno='',type=a.type,otype=a.otype,up_type='',up_reason='',rmnum=a.rmnum,ormnum=a.rmnum,roomno='',oroomno='',bdate=a.bdate,
//			sta=a.sta,osta=a.osta,ressta='',exp_sta='',sta_tm='',rmpoststa='',tag0='F',arr='',dep='',resdep=null,oarr=a.oarr,odep=a.odep,agent=a.agent,cusno=a.cusno,
//			source=a.source,class=a.class,src=a.src,market=a.market,restype=a.restype,channel=a.channel,artag1='',artag2='',share='F',gstno=a.gstno,children=a.children,rmreason='',ratecode=a.ratecode,
//			packages=a.packages,fixrate='F',rmrate=a.setrate,qtrate=a.setrate,setrate=a.setrate,rtreason='',discount=0,discount1=0,addbed=0,addbed_rate=0,crib=0,crib_rate=0,
//			paycode=a.paycode,limit=a.limit,credcode=a.credcode,credman=a.credman,credunit=a.credunit,applname='',applicant='',araccnt=a.araccnt,phone='',fax='',email='',
//			wherefrom=a.wherefrom,whereto=a.whereto,purpose=a.purpose,arrdate=a.arrdate,arrinfo=a.arrinfo,arrcar=a.arrcar,arrrate=a.arrrate,depdate=a.depdate,depinfo=a.depinfo,depcar=a.depcar,deprate=a.deprate,extra=@extra,
//			charge=a.charge,credit=a.credit,accredit=a.accredit,lastnumb=a.lastnumb,lastinumb=a.lastinumb,srqs=a.srqs,amenities=a.amenities,master=a.master,saccnt=a.saccnt,pcrec=a.pcrec,pcrec_pkg=a.pcrec_pkg,resno=a.resno,
//			crsno=a.crsno,ref=a.ref,comsg=a.comsg,card='',saleid=a.saleid,cmscode=a.cmscode,cardcode=a.cardcode,cardno=a.cardno,resby=a.resby,restime=a.restime,ciby='',citime=null,coby=a.coby,cotime=a.cotime,depby=a.depby,
//			deptime=a.deptime,cby=a.cby,changed=a.changed,exp_m1=a.exp_m1,exp_m2=a.exp_m2,exp_dt1=a.cutoff,exp_dt2=a.exp_dt2,exp_s1=a.exp_s1,exp_s2=a.contact,exp_s3=a.exp_s3
//         from sc_master a 
//			where master.accnt=a.accnt and a.accnt=@accnt
//if @@rowcount = 1
//begin
//	update sc_master set foact=accnt,tfby=@empno, tftime=getdate() where accnt=@accnt
//	if @@rowcount = 0
//		select @ret=1, @msg='发送失败'
//	else
//		exec p_gds_master_grpmid @accnt, 'R', @ret output,  @msg output
//end
//else
//begin
//	select @ret=1, @msg='发送失败'
//end
//
//--
//gout:
//if @ret <> 0
//   rollback tran p_gds_sc_master_tofo_s1
//commit tran
//
//if @retmode = 'S'
//	select @ret,@msg
//return @ret
//;
//
//