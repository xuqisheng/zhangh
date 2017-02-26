
if exists (select 1 from sysobjects where name = 'p_gl_reserve_rmbmp4')
	drop proc p_gl_reserve_rmbmp4;

create  proc p_gl_reserve_rmbmp4
	@date			datetime,
	@hall			char(1),
	@flr			char(3)
as
------------------------------------------------------------------------------------------
--	房态表：楼层平面图
------------------------------------------------------------------------------------------
declare
	@bdate		datetime,
	@count		integer,
	@roomno		char(5),

	@caccnt		char(10),
	@cname		varchar(80),
	@csta			char(1),
	@cvip			char(1),
	@carr			datetime,
	@cdep			datetime,

	@accnt		char(10),
	@name			varchar(80),
	@gsta			char(1),
	@vip			char(1),
	@message		integer,
	@arr			datetime,
	@dep			datetime,
	@ptypes		varchar(255)

-- 假房显示参数
select @ptypes = ','+isnull((select rtrim(value) from sysoption where catalog='hotel' and item='proom_map'), '')+','

create table #rmbmp
(
	roomno		char(5)					not null,
	type			char(5)					not null,
	sta			char(1)					null,
	x				integer					not null,
	y				integer					not null,
	height		integer					not null,
	width			integer					not null,
	f5				char(2)					null,
	f5_color		integer	default 0	not null,
	accnt			char(10)					null,
	name			char(80)					null,
	gsta			char(1)					null,
	vip			char(1)	default '0'	not null,
	message		integer	default 0	not null,
	arr			datetime					null,
	dep			datetime					null,
)
create unique index index1 on #rmbmp(roomno)

select @bdate = bdate1 from sysdata
insert #rmbmp (roomno, type, sta,x, y, height, width, f5)
	select roomno, type, sta, x, y, height, width, tmpsta
	from rmsta 
	where hall = @hall and flr = @flr
			and (tag='K' or (tag='P' and  charindex(','+rtrim(type)+',', @ptypes)>0)) 

declare c_accnt cursor for
	select a.accnt, b.name, a.sta, a.arr, a.dep, b.vip from master a, guest b 
		where a.haccnt=b.no and a.roomno = @roomno and a.sta in ('I', 'R')
	union all 
	select folio, reason, 'M', dbegin, dend, '0' from rm_ooo where roomno = @roomno and status = 'I'
	order by arr
declare c_roomno cursor for
	select roomno from rmsta where hall = @hall and flr = @flr

open c_roomno
fetch c_roomno into @roomno
while @@sqlstatus = 0
	begin
	select @count = 1, @accnt = '', @name = '', @gsta = '', @vip = '0', @message = 0, @arr = '1900/1/1', @dep = '1900/1/1'
	open c_accnt
	fetch c_accnt into @caccnt, @cname, @csta, @carr, @cdep, @vip
	while @@sqlstatus = 0 and @count <= 3
		begin
		if @csta in ('I', 'M') or convert(char(10), @carr, 111) = convert(char(10), @bdate, 111)
			begin


			if @carr >= @arr and @carr < @dep
				begin
				if @carr < @arr
					select @arr = @carr
				if @cdep > @dep
					select @dep = @cdep
				select @name = @name + '/' + @cname, @count = @count - 1, @accnt = '*', @gsta = '*'
				end
			else
				select @accnt = @caccnt, @name = @cname, @gsta = @csta, @arr = @carr, @dep = @cdep

--			select @cvip = max(vip) from guest where accnt = @caccnt
--			if @cvip > @vip
--				select @vip = @cvip

			select @message = @message + (select count(1) from message_leaveword where accnt = @accnt and tag < '2')

			if @count = 1
				update #rmbmp set accnt = @accnt, name = @name, gsta = @gsta,
					vip = @vip, message = @message, arr = @arr, dep = @dep
					where roomno = @roomno
			else
				break
			select @count = @count + 1
			end
		fetch c_accnt into @caccnt, @cname, @csta, @carr, @cdep, @vip
		end
	close c_accnt
	fetch c_roomno into @roomno
	end
deallocate cursor c_accnt
close c_roomno
deallocate cursor c_roomno
if @date = @bdate
	update #rmbmp set f5_color = a.color from rmstalist1 a where #rmbmp.f5 = a.code

select roomno, type, sta, x, y, height, width, f5_color,
	accnt, name, gsta, vip, message, arr, dep, bdate = @date from #rmbmp order by roomno
return 0;
