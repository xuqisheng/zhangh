
if object_id('p_gds_vod_address') is not null
    drop procedure p_gds_vod_address
;
create proc p_gds_vod_address
	@roomno			char(5),
	@obox_addr		varchar(10),
	@box_addr		varchar(10),
   @empno	    	char(10),
	@date				datetime,
   @shift	    	char(1)
as
declare 	@ret 		int,
			@msg 		varchar(60),
			@grade	char(1)

select @ret = 0, @msg = ''

if not exists(select 1 from rmsta where roomno = @roomno)
	select @ret = 1, @msg = '房号错误'
if @ret=0 and exists(select 1 from vod_grd where roomno = @roomno and charindex(changed, 'ff') > 0)
		select @ret = 1, @msg = '该房有命令仍未完成，请等待'
if @ret=0
begin
	if rtrim(@obox_addr) is null
		if rtrim(@box_addr) is null
			select @ret = 1, @msg = '请输入新装机顶盒地址'
		else
			select @grade = '3', @msg = '新装机顶盒地址'
	else
		if  rtrim(@box_addr) is null
			select @grade = '5', @msg = '删除机顶盒地址'
		else
			select @grade = '4', @msg = '更改机顶盒地址'
end

if @ret=0
begin
	if exists(select 1 from vod_grd where roomno = @roomno)
		update vod_grd set obox_addr = @obox_addr, box_addr = @box_addr, grade = @grade, empno = @empno, shift = @shift, date = @date , logmark = logmark + 1
			where roomno = @roomno
	else
		insert vod_grd(roomno, box_addr, grade, empno, shift, date)
			values (@roomno, @box_addr, @grade, @empno, @shift, @date)

	if @@rowcount = 0
		select @msg = @msg + '---- faile!!!'
end

select @ret, @msg

return 0
;


if object_id('p_gds_vod_board_show') is not null
    drop procedure p_gds_vod_board_show
;
create proc p_gds_vod_board_show
	@pc_id		char(4),
	@begin		datetime,
	@end			datetime,
	@less			int
as

delete vod_board where pc_id = @pc_id
delete vod_board_tmp where pc_id = @pc_id

insert into vod_board_tmp
	select @pc_id, pgm_name, count(pgm_name) from vodfolio
		where log_date >= @begin and log_date <= @end
			group by pgm_name
			order by pgm_name

delete vod_board_tmp where number < @less

declare @no int, @number int, @program varchar(20)
select @no = 1
declare cc cursor for select program , number from vod_board_tmp order by number desc, program asc
open cc
fetch cc into @program, @number
while @@sqlstatus = 0
begin
	insert vod_board select @pc_id, @no, @program, @number
	select @no = @no + 1
	fetch cc into @program, @number
end
close cc
deallocate cursor cc

return 0
;


if object_id('p_gds_vod_grade') is not null
    drop procedure p_gds_vod_grade
;
create proc p_gds_vod_grade
	@roomno			char(5),
	@grade			char(1),
	@gst_grd			char(1),
   @gst_name	   varchar(10),
	@empno			char(10),
   @shift	    	char(1),
	@date				datetime,
	@retmode			char(1) = 's'
as
declare 	@ret 			int,
			@msg 			varchar(60),
			@ograde		char(1)

select @ret = 0, @msg = ''

if not exists(select 1 from rmsta where roomno = @roomno)
	select @ret = 1, @msg = '房号错误'
if @ret=0 and (rtrim(@grade) is  null or not exists(select 1 from basecode where cat='vod_grade' and code=@grade))
	select @ret = 1, @msg = '控制等级错误 '
if @ret=0 and (rtrim(@gst_grd) is  null or rtrim(@gst_name) is  null )
	select @ret = 1, @msg = '客人等级,客人姓名不能为空 '

if @ret=0
begin
	if exists(select 1 from vod_grd where roomno = @roomno)
	begin
		select @ograde = grade from vod_grd where roomno = @roomno
		update vod_grd set ograde = @ograde, grade = @grade, changed='f',
								gst_grd = @gst_grd, gst_name = @gst_name,
								empno = @empno, shift = @shift, date = @date , logmark = logmark + 1
			where roomno = @roomno
	end
	else
		insert vod_grd(roomno, changed, ograde, grade, gst_grd, gst_name, empno, shift, date, logmark)
			values (@roomno, 'f', @ograde, @grade, @gst_grd, @gst_name, @empno, @shift, @date, 0)

	if @@rowcount = 0
		select @ret = 1, @msg = 'faile!'
end

if @retmode='s'
	select @ret, @msg
return @ret
;


if object_id('p_gds_vod_init') is not null
    drop procedure p_gds_vod_init
;
create proc p_gds_vod_init
as

truncate table vod_err
truncate table vod_posterr
truncate table vod_src

truncate table vodfolio
truncate table vodhfolio

truncate table vod_grd
truncate table vod_grd_log

return 0
;

if object_id('p_gds_vod_postcharge') is not null
    drop procedure p_gds_vod_postcharge
;
create proc p_gds_vod_postcharge
	@modu_id			char(2),
	@pc_id			char(4),
	@shift			char(1),
	@empno			char(10),
	@p_vodno			char(10),
	@p_roomno		char(5),
	@p_movie			char(15),
	@p_charge		money	,
	@p_time			datetime,
	@returnmode  	char(1)
as
declare
	@ret				integer,
	@accnt			char(10),
	@sta				char(1),
	@selemark		char(13),
	@lastnumb		integer,
	@inbalance		money,
	@bdate			datetime,
	@sucmark			char(1),
	@id				integer,
	@pccode			varchar(3),
	@mprompt			char(10),
	@package			varchar(3),
	@msg				varchar(60),
	@posterr			varchar(50),
	@today			datetime

select @ret = 0, @msg = '', @mprompt = '?', @today=getdate()
select @selemark = 'a' + @p_movie, @bdate = bdate1 from sysdata

select @sta = ocsta, @accnt = substring(accntset, 1, 10) from rmsta where roomno = @p_roomno
if @sta is null or rtrim(@accnt) is null
	begin
	if @sta is null
		select @ret = 1, @msg = '没有这个有效房号:%1^' + @p_roomno, @mprompt = 'no room'
	else if rtrim(@accnt) is null or @sta <> 'o'
		select @ret = 1, @msg = '该房号没有有效帐号:%1^' + @p_roomno, @mprompt = 'empty  '
	end
else
	begin
	declare @arrtime datetime
	select @arrtime = arr from master where accnt = @accnt
	if datediff(second, @arrtime, @p_time)< 0
		select @ret = 1, @msg = '在指定时间该房号没有有效帐号:%1^' + @p_roomno, @mprompt = 'empty  '
	else
		begin
		select @pccode = value from sysoption where catalog = 'vod' and item = 'pccode'
		if rtrim(@pccode) is null
			select @ret = 1, @msg = '系统没有指定vod费用代码!!', @mprompt = 'no pccd'
		else
			if not exists(select * from pccode where pccode = @pccode)
				select @ret = 1, @msg = '系统指定的vod费用代码不存在!!!', @mprompt = 'no pccd'

		if @ret = 0
			begin
			begin tran
			save  tran p_gds_vod_postcharge_s1
			select @package = ' ' + @pccode, @pccode = @pccode + 'a'
			if @p_charge <> 0
--				exec @ret = p_gl_accnt_post_charge @selemark, 0, 0, @modu_id, @pc_id, @shift, @empno, @accnt, '', '', @pccode, @package, @p_charge, null, @bdate, null, 'in', 'r', null, 'i', @msg out
				exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id,0,@shift, @empno, @accnt,0, @pccode, '',1, @p_charge,@p_charge,0,0,0,0,'vod charge','', @today, '', '', 'iryy', 0, '', @msg out

			if @ret <> 0
				begin
					rollback tran p_gds_vod_postcharge_s1
					select @mprompt = 'posterr'

					select @posterr = isnull(@p_vodno, ' ') + ' ' + isnull(@p_roomno, ' ') + ' ' + isnull(@p_movie, ' ')
					insert vod_posterr select getdate(), @posterr
				end
			else
				select @sucmark = 't', @mprompt = @accnt

			commit tran
			end
		end
	end


select @id = isnull((select max(inumber) from vodfolio), 0) + 1
insert vodfolio(inumber, log_date, status, seq_id, usr_id, pgm_name, p_time, pgm_amt, refer, empno, shift)
	values(@id, getdate(), '1', @p_vodno, @p_roomno, @p_movie, @p_time, @p_charge, @mprompt, @empno, @shift)

if @returnmode = 's'
	select @ret, @msg, @mprompt

return @ret
;
