

if exists(select * from sysobjects where name = "p_gds_sc_rsvblk_sync")
   drop proc p_gds_sc_rsvblk_sync;

create proc p_gds_sc_rsvblk_sync
   @grpaccnt 	char(10),
	@empno		char(10)
as
--------------------------------------------------------
-- 根据 rsvsrc 内容同步 sc_master 
--------------------------------------------------------
declare
   @rmnum0      	int,
   @gstno0      	int,
	@rate0			money,
   @rmnum      	int,
   @gstno      	int,
	@rate				money

-- Old Info 
select @rmnum0=rmnum, @gstno0=gstno, @rate0=setrate from sc_master where accnt=@grpaccnt and foact=''
if @@rowcount = 0 
	return 

-- 
if not exists(select 1 from rsvsrc where accnt=@grpaccnt and id>0)
	return 

-- New Info
exec p_gds_sc_rsvblk_cal @grpaccnt, 'F', 'R', @rmnum output, @gstno output, @rate output 

-- update -- 暂时不考虑人数 
if @rmnum0<>@rmnum or @rate0<>@rate 
	update sc_master set rmnum=@rmnum, setrate=@rate, cby=@empno, changed=getdate(), logmark=logmark+1 where accnt=@grpaccnt

return
;