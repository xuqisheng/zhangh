drop proc p_gl_reserve_rmbmp
;
create  proc p_gl_reserve_rmbmp
	@date			datetime
as
------------------------------------------------------------------------------------------
--	房态表：干特图
------------------------------------------------------------------------------------------

declare
	@bdate		datetime,
	@count		integer, 
	@roomno		char(5),
--
	@caccnt		char(10), 
	@cname		varchar(80), 
	@csta			char(1),
	@cvip			char(1),
	@carr			datetime,
	@cdep			datetime,
--
	@laccnt		char(10),
	@accnt		char(10),
	@name			varchar(80), 
	@sta			char(1),
	@vip			char(1),
	@arr			datetime,
	@dep			datetime,
--
	@a				money, 
	@d				money,
	@ptypes		varchar(255)

-- 假房显示参数
select @ptypes = ','+isnull((select rtrim(value) from sysoption where catalog='hotel' and item='proom_map'), '')+','

create table #rmbmp
(
	roomno		char(5)					not null,
	oroomno		char(5)					not null,
	type			char(5)					not null,
	sta			char(1)					null,
	ocsta			char(1)					null,
	hall			char(1)					null,
	flr			char(3)					null,
	tmpsta		char(1)					null,
	tmpsta_color		integer	default 0	not null,
	a1				money		default 0	not null,
	d1				money		default 0	not null,
	accnt1		char(10)					null,
	name1			char(80)					null,
	sta1			char(1)					null,		-- 客人状态
	vip1			char(1)					null,
	arr1			datetime					null,
	dep1			datetime					null,
	--
	a2				money		default 0	not null,
	d2				money		default 0	not null,
	accnt2		char(10)					null,
	name2			char(80)					null,
	sta2			char(1)					null,
	vip2			char(1)					null,
	arr2			datetime					null,
	dep2			datetime					null,
	--
	a3				money		default 0	not null,
	d3				money		default 0	not null,
	accnt3		char(10)					null,
	name3			char(80)					null,
	sta3			char(1)					null,
	vip3			char(1)					null,
	arr3			datetime					null,
	dep3			datetime					null,
    feature         varchar(50)                 null
)
create unique index index1 on #rmbmp(roomno)

select @bdate = bdate1 from sysdata

declare 
	@appid		varchar(5),
	@empno		char(10),
	@shift		char(1),
	@pc_id		char(4),
	@pret			int,  
	@halls		varchar(30),
	@types		varchar(100) 

exec @pret = p_gds_get_login_info 'R', @empno output,@shift output, @pc_id output, @appid output  	
if @pret = 0 
begin
	select @halls=isnull(rtrim(halls),'#'), @types=isnull(rtrim(types),'#') from hall_station where pc_id=@pc_id 
	if @@rowcount=0 
		select @halls='#', @types='#' 
end
else
	select @halls='#', @types='#' 

-- Insert roomno --0908 clg 增加客房特征
if @halls='#' and @types='#' 
	insert #rmbmp (roomno, oroomno, type, sta, ocsta, hall, flr, tmpsta,feature)
		select roomno, oroomno, type, sta, ocsta, hall, flr, tmpsta,feature 
		from rmsta
			where (tag='K' or (tag='P' and  charindex(','+rtrim(type)+',', @ptypes)>0)) 
else
begin
	if @types<>'#' 
		select @types=','+@types+',' 
	insert #rmbmp (roomno, oroomno, type, sta, ocsta, hall, flr, tmpsta,feature)
		select roomno, oroomno, type, sta, ocsta, hall, flr, tmpsta,feature 
			from rmsta 
				where (@halls='#' or charindex(hall,@halls)>0) 
					and (@types='#' or charindex(','+rtrim(type)+',',@types)>0) 
					and (tag='K' or (tag='P' and  charindex(','+rtrim(type)+',', @ptypes)>0)) 
end 

-- cursor 
declare c_accnt cursor for
	select a.accnt, b.name, a.sta, a.arr, a.dep, b.vip from master a, guest b 
		where a.haccnt=b.no and a.roomno = @roomno and a.sta in ('I', 'R') and datediff(dd,@date,a.dep)>-1
	union all 
--	select folio, reason, 'M', dateadd(hh, 12, dbegin), dateadd(hh, 12, dend), '0' from rm_ooo where roomno = @roomno and status = 'I' and datediff(dd,@date,dend)>=-1
	select folio, reason, 'M', dateadd(hh, 0, dbegin), dateadd(hh, 0, dend), '0' from rm_ooo where roomno = @roomno and status = 'I' and datediff(dd,@date,dend)>-1
	order by arr
declare c_roomno cursor for
	select roomno from #rmbmp order by roomno

open c_roomno
fetch c_roomno into @roomno
while @@sqlstatus = 0
	begin
	select @count = 1, @accnt = '', @laccnt = '', @name = '', @sta = '', @arr = '1900/1/1', @dep = '1900/1/1'
	select @a=0, @d=0

	open c_accnt
	fetch c_accnt into @caccnt, @cname, @csta, @carr, @cdep, @vip
	while @@sqlstatus = 0 and @count <= 3
		begin
--		if @carr < @date
--			select @carr = @date
		if datediff(dd,@carr,@arr)<=0 and datediff(dd,@carr,@dep)>0
			begin
			if @carr < @arr
				select @arr = @carr
			if @cdep > @dep
				select @dep = @cdep
			select @name = isnull(rtrim(@name), '') + '/' + @cname, @count = @count - 1, @accnt = '*', @sta = '*'
			end
		else
			select @accnt = @caccnt, @name = @cname, @sta = @csta, @arr = @carr, @dep = @cdep
		select @laccnt = @caccnt, @a = datediff(dd, @date, @arr), @d = datediff(dd, @date, @dep)
		if @a < 0
			select @a = -1
		if @d <= 0
			select @d = 0.5

		if @d is null            -- gds -- jjh  2001/10
			select @d = 0
		if @a is null
			select @a = 0

		if @d = @a
			select @d = @d + 0.5

		if @count = 1
			update #rmbmp set accnt1 = @accnt, name1 = @name, sta1 = @sta, vip1 = isnull(@vip,'0'), arr1 = @arr, dep1 = @dep, a1 = @a, d1 = @d
				where roomno = @roomno
		else if @count = 2
			update #rmbmp set accnt2 = @accnt, name2 = @name, sta2 = @sta, vip2 = isnull(@vip,'0'), arr2 = @arr, dep2 = @dep, a2 = @a, d2 = @d
				where roomno = @roomno
		else if @count = 3
			update #rmbmp set accnt3 = @accnt, name3 = @name, sta3 = @sta, vip3 = isnull(@vip,'0'), arr3 = @arr, dep3 = @dep, a3 = @a, d3 = @d
				where roomno = @roomno
		select @count = @count + 1
		fetch c_accnt into @caccnt, @cname, @csta, @carr, @cdep, @vip
		end
	close c_accnt
	fetch c_roomno into @roomno
	end
deallocate cursor c_accnt
close c_roomno
deallocate cursor c_roomno

if @date = @bdate
	update #rmbmp set tmpsta_color = a.color from rmstalist1 a where #rmbmp.tmpsta = a.code
--update #rmbmp set a1 = a1 + 0.5, d1 = d1 + 0.5

--------------------------------------------------------------------------
-- 防止客户端数据窗口对象宽度计算超界 2004/12/22 
update #rmbmp set d1 = 70 where d1 > 70
update #rmbmp set d2 = 70 where d2 > 70
update #rmbmp set d3 = 70 where d3 > 70
--------------------------------------------------------------------------

select roomno, type, sta, ocsta, hall, flr, tmpsta_color, 
	a1, d1, accnt1, name1, sta1, vip1,
	a2, d2, accnt2, name2, sta2, vip2, 
	a3, d3, accnt3, name3, sta3, vip3, bdate = @date,feature from #rmbmp order by oroomno

return 0
;