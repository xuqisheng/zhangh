
IF OBJECT_ID('p_gds_sc_master_actcrt') IS NOT NULL
    DROP PROCEDURE p_gds_sc_master_actcrt
;
create proc p_gds_sc_master_actcrt
   @accnt  	char(10),
	@class	char(1),
	@hno		char(7),
	@arr		datetime,
	@dep		datetime,
	@rmnum	int,
	@gstno	int,
   @empno  	char(10),
	@retmode	char(1) = 'S',
	@ret		int				output,
	@msg		varchar(60)		output
as

--------------------------------------------------------------------
--	sc_master (block)  产生前台团体会议主单
--
--		产生散客主单由 p_gds_master_pick_grid 处理 
--------------------------------------------------------------------
declare
	@sta       	char(1),
	@foact		char(10),
	@bdate		datetime,
	@today		datetime,
	@extra		char(30),
	@maccnt		char(10)

select @ret = 0, @msg = ""
select @bdate = bdate1, @today=getdate() from sysdata

begin tran
save  tran p_gds_sc_master_actcrt_s1

-- Block 主单校验 
select @sta=sta, @foact=foact, @extra=extra from sc_master where accnt=@accnt
if @@rowcount = 0
begin
	select @ret=1, @msg='当前账户不存在'
	goto gout
end
if substring(@foact,2,1)<>'F'
begin
	select @ret=1, @msg='当前Block还没有发送到前台系统'
	goto gout
end
if @sta<>'R'
begin
	select @ret=1, @msg='当前账户非有效预订状态'
	goto gout
end

-- 过程参数校验 
if @class not in ('G', 'M') 
begin
	select @ret=1, @msg='创建类型错误'
	goto gout
end
if not exists(select 1 from guest where no=@hno and class='G' and sta='I') 
begin
	select @ret=1, @msg='%1无效或不存在^团体会议档案'
	goto gout
end


-- 开始账号产生 
if @class='G' 
	exec p_GetAccnt1 'GRP', @maccnt output
else
	exec p_GetAccnt1 'MET', @maccnt output

insert master(accnt,haccnt,groupno,type,otype,up_type,up_reason,rmnum,ormnum,roomno,oroomno,bdate,
	sta,osta,ressta,exp_sta,sta_tm,rmpoststa,rmposted,tag0,arr,dep,resdep,oarr,odep,agent,cusno,
	source,class,src,market,restype,channel,artag1,artag2,share,gstno,children,rmreason,ratecode,
	packages,fixrate,rmrate,qtrate,setrate,rtreason,discount,discount1,addbed,addbed_rate,crib,crib_rate,
	paycode,limit,credcode,credman,credunit,applname,applicant,araccnt,phone,fax,email,
	wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,extra,
	charge,credit,accredit,lastnumb,lastinumb,srqs,amenities,master,saccnt,blkcode,pcrec,pcrec_pkg,resno,
	crsno,ref,comsg,card,saleid,cmscode,cardcode,cardno,resby,restime,ciby,citime,coby,cotime,depby,
	deptime,cby,changed,exp_m1,exp_m2,exp_dt1,exp_dt2,exp_s1,exp_s2,exp_s3,logmark)
SELECT @maccnt,@hno,'',type,otype,'','',@rmnum,@rmnum,'','',@bdate,
	'R','R','','','','','F','',@arr,@dep,null,@arr,@arr,agent,cusno,
	source,@class,src,market,restype,channel,'','','F',@gstno,0,'',ratecode,
	packages,'F',setrate,setrate,setrate,'',0,0,0,0,0,0,
	paycode,limit,credcode,credman,credunit,'','',araccnt,'','','',
	wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,@extra,
	0,0,0,0,0,srqs,amenities,@maccnt,'',@accnt,'','',resno,			-- 这里的预定号码需要更换吗 ？ 
	crsno,ref,comsg,'',saleid,cmscode,cardcode,cardno,@empno,@today,'',null,'',null,'',
	null,@empno,@today,exp_m1,exp_m2,cutoff,exp_dt2,exp_s1,contact,exp_s3,0 
FROM sc_master where accnt=@accnt
if @@rowcount = 0 
	select @ret=1, @msg='Insert maser error !'
//else
//	exec @ret = p_gds_reserve_chktprm @maccnt,'0','',@empno,'',1,0,@msg output

--
gout:
if @ret <> 0
   rollback tran p_gds_sc_master_actcrt_s1
commit tran

if @retmode = 'S'
	select @ret,@msg
return @ret
;

