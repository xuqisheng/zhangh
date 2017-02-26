IF OBJECT_ID('p_wz_reserve_quick_reg') IS NOT NULL
    DROP PROCEDURE p_wz_reserve_quick_reg
   ;
create proc p_wz_reserve_quick_reg
	@modu_id		char(2),
	@pc_id		char(4),
	@link			char(1)
as

declare 	@ret 				int,
			@msg 				varchar(70),
			@guestid 		char(7),
			@accnt			char(10),
			@sta 				char(1),
			@groupno 		char(7),
			@bdate 			datetime,
			@changed 		datetime,
			@srcdef			char(1),
			@accnts			varchar(255),
			@rooms			varchar(255)

declare
			@ratecode		char(10),
			@type		   	char(5),
			@roomno			char(5),
			@arr				datetime,
			@dep				datetime,
			@num				int,
			@src				char(3),
			@market			char(3),
			@restype			char(3),
			@resno			char(10),
			@class		   char(1),
			@qtrate			money,
			@setrate			money,
			@rtreason	   char(3),
			@discount	   money,
			@discount1		money,
			@name				varchar(50),
			@lname       	varchar(30),
			@nation			char(3),
			@haccnt			char(7),
			@pcrec		   char(7),
			@extra	  		char(30),
			@ref				varchar(80),
			@resby			char(8),
			@restime			datetime,
			@packages		varchar(50),
			@hno				char(7)

select @guestid = value from sysoption where catalog = 'reserve' and item = 'default_guestid'
if not exists(select 1 from master_quick where modu_id=@modu_id and pc_id=@pc_id)
begin
	select @ret=1, @msg='没有需要快速登记的记录 !'
	select @ret, @msg, ''
	return @ret
end


select  	@ret = 0, @msg = '', @changed = getdate(), @accnts=''
select 	@bdate = bdate1 from sysdata

declare c_roomno cursor for select ratecode,type,roomno,arr,dep,num,src,market,restype,resno,packages,class,qtrate,setrate,
			rtreason,discount,discount1,name,lname,nation,haccnt,pcrec,extra,resby,restime,sta
	from master_quick where modu_id=@modu_id and pc_id=@pc_id order by roomno
open c_roomno
fetch c_roomno into
			@ratecode,@type,@roomno,@arr,@dep,@num,@src,@market,@restype,@resno,@packages,@class,@qtrate,@setrate,
			@rtreason,@discount,@discount1,@name,@lname,@nation,@haccnt,@pcrec,@extra,@resby,@restime,@sta
while @@sqlstatus = 0
begin

	begin tran
	save tran p_mst_s1
	exec p_GetAccnt1 'FIT',@accnt output
	insert master (accnt,haccnt,market,src,restype,resno,packages, class,rmrate,qtrate, setrate, rtreason, sta, bdate, arr, dep, extra,
				osta, groupno, type,otype,roomno,oroomno,rmnum,ormnum,gstno, discount, discount1,ratecode, resby, restime, cby, changed)
	values(@accnt,@haccnt,@market,@src,@restype,@resno,@packages,@class,@qtrate,0, @setrate, @rtreason, @sta, @bdate, @arr, @dep, @extra
				,'', '', @type,@type,@roomno,@roomno,1,1,1,@discount, @discount1,@ratecode, @resby, @restime, @resby, @restime)
	if @@rowcount = 0
		select @ret = 1,@msg = '主单插入失败 !'
	if @ret = 0
	begin
			exec @ret = p_gds_reserve_chktprm @accnt,'0','',@resby,'',1,1,@msg output
		if @ret = 0
		begin
			update master set logmark = logmark + 1 where accnt = @accnt
		end
	end

	if @ret = 0
	begin
		if @haccnt <> @hno
		update guest set nation = @nation ,country = @nation where no = @haccnt
	end

	if @ret <> 0
		rollback tran p_mst_s1
	else
	begin
		select @accnts=@accnts+@accnt+'/', @rooms=@rooms+@roomno+'/'
		update master_quick set accnt=@accnt where roomno=@roomno
	end
	commit tran

	if @ret <> 0
		goto gout

	fetch c_roomno into 	@ratecode,@type,@roomno,@arr,@dep,@num,@src,@market,@restype,@resno,@packages,@class,@qtrate,@setrate,
			@rtreason,@discount,@discount1,@name,@lname,@nation,@haccnt,@pcrec,@extra,@resby,@restime,@sta


end

gout:
close c_roomno
deallocate cursor c_roomno


select @rooms=ltrim(@rooms), @accnts=ltrim(@accnts)
if @link = 'T' and datalength(@accnts) > 10
begin
	select @accnt=substring(@accnts, 1, 10)
	update master set pcrec=@accnt where charindex(accnt, @accnts) > 0
end


select @ret, @msg, @rooms

return @ret
;