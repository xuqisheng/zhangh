 --  

if exists(select * from sysobjects where name = 'p_zk_checkroom_check')
	drop proc p_zk_checkroom_check;

create proc p_zk_checkroom_check
	@pc_id				char(4), 
	@mdi_id				integer, 
	@roomno				char(5), 
	@accnt				char(10), 
	@subaccnt			integer, 
	@operation			char(10), 
	@shift				char(1),
	@empno				char(10)
as
declare
	@date				datetime, 
	@billno				char(10),
	@msg					varchar(60), 
	@room_num         integer,
	@ret					integer,
	@_pnumber			integer,
	@_log_date			datetime, 
	@log_date			datetime

select @date=arr from master where accnt=@accnt

select @room_num=count(*) from master where roomno=@roomno and sta='I'
if @room_num>1 
	begin
	select @ret=0,@msg=''
	goto gout
	end

if not exists (select 1 from checkroom where roomno=@roomno and sta='9' and type='1' and date3<getdate() and date3>@date)
	begin
	select @ret=1,@msg='房间尚未查毕'
	goto gout
	end

if exists (select 1 from checkroom where roomno=@roomno and sta='0' and type='1')
	begin
	select @ret=1,@msg='房间尚未查毕'
	goto gout
	end

if exists (select 1 from checkroom where roomno=@roomno and sta='1' and type='1')
	begin
	select @ret=1,@msg='正在查房，请稍等'
	goto gout
	end



if  exists (select 1 from checkroom where roomno=@roomno and sta='9' and date3<getdate() and date3>@date and type='1')
	begin
	select @ret=0,@msg=''
	goto gout
	end
else
	begin
	select @ret=1,@msg='尚未查房'
	goto gout
	end

gout:
if @subaccnt=0
	select @ret, @msg

return @ret
;
