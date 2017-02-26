if exists(select 1 from sysobjects where name = "p_gds_master_share_get")
	drop proc p_gds_master_share_get;
create proc p_gds_master_share_get
	@accnt		char(10),
	@pc_id		char(4)
as
----------------------------------------------------------------------------------------------
--		提取同住帐号到临时表 selected_account(type=S, pc_id, 0, accnt, 0)
----------------------------------------------------------------------------------------------
delete selected_account where type='S' and pc_id=@pc_id and mdi_id=0

declare	@roomno		char(5),
			@arr			datetime,
			@dep			datetime

select @roomno=roomno, @arr=arr, @dep=dep from master where accnt=@accnt 
if @@rowcount = 0 
	insert selected_account(type,pc_id,mdi_id,accnt,number)
		values('S',@pc_id,0,@accnt,0)
else
begin
	if @roomno='' 
		insert selected_account(type,pc_id,mdi_id,accnt,number)
			values('S',@pc_id,0,@accnt,0)
	else if datediff(dd, @arr, @dep) = 0
		insert selected_account(type,pc_id,mdi_id,accnt,number)
			select distinct 'S',@pc_id,0,accnt,0 from rsvsrc 
				where roomno=@roomno and datediff(dd,@arr,begin_)<=0 and datediff(dd,@arr,end_)>=0
	else
		insert selected_account(type,pc_id,mdi_id,accnt,number)
			select distinct 'S',@pc_id,0,accnt,0 from rsvsrc 
				where roomno=@roomno 
					and ((datediff(dd,begin_,end_)=0 and datediff(dd,@arr,begin_)>=0 and datediff(dd,@dep,begin_)>=0) 
					or (datediff(dd,begin_,end_)<>0 and datediff(dd,@arr,end_)>0 and datediff(dd,@dep,begin_)<0))

end

return 0
;

