--------------------------------------------------------
--  特殊要求报表  x5
--
--	客房布置，没有房号的也需要显示，起码可以显示有几间客房
--------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_req_rep")
   drop proc p_gds_req_rep;
create  proc p_gds_req_rep
	@gitem		char(1),			-- T=特殊要求  K=客房布置 Z=客房特征
	@req_str		varchar(120),
	@sta_str		varchar(10),
	@begin		datetime,
	@end			datetime
as

declare
	@gitemno		int,
	@glineno		int,
	@glinestr	varchar(80),
	@gaccnt		char(10),
	@gsta			char(1),
	@groomno		char(5),
	@ogroomno		char(5),
	@greq			varchar(20),
	@gcode		varchar(3),
	@gdes			char(60),
	@gclsno		int,
	@saccnt		char(10),
	@osaccnt		char(10),
	@type			char(5),
	@ogcode		varchar(3)


-- Output Table
create table #res_req_rep (
	itemno			int   	not null,
	req_code			char(3)	null,
	req_des			char(60)	null,
	number			int		null,
	content			varchar(80)	default '' null
)
create unique index index1 on #res_req_rep(itemno)

-- Define Cursor
if @gitem = 'T'
begin
	declare c_req  cursor for select rtrim(code), descript from reqcode
		where charindex(','+rtrim(code)+',', @req_str)>0 or rtrim(@req_str) = '###'
			order by sequence, code
	declare c_list cursor for select accnt, sta, type, roomno, srqs, saccnt from master
		where class='F' and (charindex(sta, @sta_str)>0  or rtrim(@sta_str) = '###')
				and datediff(dd, @begin, arr)>=0 and datediff(dd, @end, arr)<=0 and charindex(','+rtrim(@gcode)+',', ','+srqs+',') > 0
			order by roomno
end
else if @gitem = 'K'
begin
	declare c_req  cursor for select rtrim(code), descript from basecode
		where cat='amenities' and (charindex(','+rtrim(code)+',', @req_str)>0 or rtrim(@req_str) = '###')
			order by sequence, code
	declare c_list cursor for select a.accnt, a.sta, a.type,a.roomno, a.amenities, a.saccnt from master a
		where a.class='F' and (charindex(a.sta, @sta_str)>0  or rtrim(@sta_str) = '###')
				and datediff(dd, @begin, a.arr)>=0 and datediff(dd, @end, a.arr)<=0 and charindex(','+rtrim(@gcode)+',', ','+a.amenities+',') > 0
			order by roomno
end
else
begin
	declare c_req  cursor for select rtrim(code), descript from basecode
		where cat='feature' and (charindex(','+rtrim(code)+',', @req_str)>0 or rtrim(@req_str) = '###')
			order by sequence, code
	declare c_list cursor for select a.accnt, a.sta, a.type,a.roomno, b.feature, a.saccnt from master a,rmsta b
		where a.class='F' and (charindex(a.sta, @sta_str)>0  or rtrim(@sta_str) = '###') and a.roomno = b.roomno
				and datediff(dd, @begin, a.arr)>=0 and datediff(dd, @end, a.arr)<=0 and charindex(','+rtrim(@gcode)+',', ','+b.feature+',') > 0
			order by roomno
end

-- Begin
select @gitemno = 0, @ogroomno = '', @osaccnt = ''

open c_req
fetch c_req into @gcode, @gdes
while @@sqlstatus = 0
begin
	select @gclsno = 0
	select @gitemno = @gitemno + 1
	insert #res_req_rep(itemno, req_code, req_des, number,content)
		values(@gitemno, @gcode, @gdes, 0, '')
	select @glineno = 1
	select @glinestr = ''

	open c_list
	fetch c_list into @gaccnt, @gsta, @type, @groomno, @greq, @saccnt
	while @@sqlstatus = 0
	begin
		if @glineno > 5
		begin
			select @gitemno = @gitemno + 1
			insert #res_req_rep select @gitemno, '', '',null,@glinestr
			select @glineno = 1
			select @glinestr = ''
		end

		if not ((@ogroomno = @groomno and @ogcode = @gcode) or (@saccnt = @osaccnt and @ogcode = @gcode) )
		begin
			select @gclsno = @gclsno + 1  -- --记录数目--

			if @groomno<>''
				select @glinestr = @glinestr + '    ' +substring(ltrim(rtrim(@groomno))+'('+@gsta+')'+space(8),1,8)
			else
				select @glinestr = @glinestr + '    ' +substring(ltrim(rtrim(@type))+'('+@gsta+')'+space(8),1,8)  -- 还没有分配房号
		end
		select @ogroomno = @groomno, @osaccnt=@saccnt ,@ogcode = @gcode
		select @glineno = @glineno + 1

		fetch c_list into @gaccnt, @gsta, @type, @groomno, @greq, @saccnt
	end

	if @glineno > 1   --  ---非完整行--
	begin
		select @gitemno = @gitemno + 1
		insert #res_req_rep select @gitemno, '', '',null,@glinestr
	end
	update #res_req_rep set number = @gclsno where req_code = @gcode
	close c_list

	fetch c_req into @gcode, @gdes
end
deallocate cursor c_list
close c_req
deallocate cursor c_req

select req_code, req_des, number, content from #res_req_rep order by itemno

return 0
;


if exists(select * from sysobjects where name = "p_gds_req_rep_list")
   drop proc p_gds_req_rep_list;
create  proc p_gds_req_rep_list
	@gitem		char(1),			-- T=特殊要求  K=客房布置 Z=客房特征
	@req_str		varchar(120),
	@sta_str		varchar(10),
	@begin		datetime,
	@end			datetime
as

declare
	@gaccnt		char(10),
	@gcode		char(3)

create table #accnt (accnt		char(10))

if @gitem = 'T'
begin
	declare c_req  cursor for select rtrim(code) from reqcode
		where charindex(','+rtrim(code)+',', @req_str)>0 or rtrim(@req_str) = '###'
			order by sequence, code
	open c_req
	fetch c_req into @gcode
	while @@sqlstatus = 0
	begin
		insert #accnt select accnt from master
			where class='F' and (charindex(sta, @sta_str)>0  or rtrim(@sta_str) = '###')
				and datediff(dd, @begin, arr)>=0 and datediff(dd, @end, arr)<=0 and charindex(','+rtrim(@gcode)+',', ','+srqs+',') > 0
				and accnt not in (select accnt from #accnt)

		fetch c_req into @gcode
	end
	close c_req
	deallocate cursor c_req
end
else if @gitem = 'K'
begin
	declare c_amenities  cursor for select rtrim(code) from basecode
		where cat='amenities' and (charindex(','+rtrim(code)+',', @req_str)>0 or rtrim(@req_str) = '###')
			order by sequence, code
	open c_amenities
	fetch c_amenities into @gcode
	while @@sqlstatus = 0
	begin
		insert #accnt select a.accnt from master a
			where a.class='F' and (charindex(a.sta, @sta_str)>0  or rtrim(@sta_str) = '###')
				and datediff(dd, @begin, a.arr)>=0 and datediff(dd, @end, a.arr)<=0 and charindex(','+rtrim(@gcode)+',', ','+a.amenities+',') > 0
				and a.accnt not in (select accnt from #accnt)

		fetch c_amenities into @gcode
	end
	close c_amenities
	deallocate cursor c_amenities
end
else
begin
	declare c_feature  cursor for select rtrim(code) from basecode
		where cat='feature' and (charindex(','+rtrim(code)+',', @req_str)>0 or rtrim(@req_str) = '###')
			order by sequence, code
	open c_feature
	fetch c_feature into @gcode
	while @@sqlstatus = 0
	begin

		insert #accnt select a.accnt from master a,rmsta b
			where a.class='F' and (charindex(a.sta, @sta_str)>0  or rtrim(@sta_str) = '###') and a.roomno = b.roomno
				and datediff(dd, @begin, a.arr)>=0 and datediff(dd, @end, a.arr)<=0 and charindex(','+rtrim(@gcode)+',', ','+b.feature+',') > 0
				and a.accnt not in (select accnt from #accnt)

		fetch c_feature into @gcode
	end
	close c_feature
	deallocate cursor c_feature
end

-- Output
select a.accnt,a.sta,a.type,a.roomno,a.setrate,a.arr,a.dep,b.haccnt,convert(char(99), b.cusno+'/'+b.agent+'/'+b.source),
		a.amenities,a.srqs,b.groupno,convert(char(99), a.ref),a.saccnt
	from master a, master_des b, #accnt d
	where a.accnt=b.accnt and a.accnt=d.accnt
order by a.roomno,a.accnt

return 0
;