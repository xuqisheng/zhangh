drop proc p_hry_reserve_rmlist_by_type;
create proc p_hry_reserve_rmlist_by_type
   @pc_id    char(4),
   @modu_id  char(2),
   @staset   varchar(50),				-- ×´Ì¬Ñ¡Ôñ 
   @lmode    char(1)						-- T=·¿Àà  F=Â¥²ã 
as

declare
   @type		char(5),
   @type1	char(5),
   @typeset  varchar(240),
   @roomno   char(5),
   @eccocode  char(3),
   @eccocode1  char(3),
   @oroomno  char(5),
   @maxcnt   int,
   @spccnt   int,
   @typeoff  int

-- 
delete rmlist_by_type  where pc_id = @pc_id and modu_id = @modu_id
delete rmcount_by_type where pc_id = @pc_id and modu_id = @modu_id

-- 
if @lmode = 'T'
   begin
   declare c_type  cursor for select distinct type from rmsta order by type
   open  c_type
   fetch c_type into @type
   while @@sqlstatus = 0
      begin
      insert rmcount_by_type (pc_id,modu_id,type) values (@pc_id,@modu_id,@type)
      select @typeset = @typeset + substring(ltrim(@type)+space(5),1,5) + '#'
      fetch c_type into @type
      end
   close c_type
   deallocate cursor c_type
   end
else
   begin
   declare c_oroomno cursor for select distinct flr from rmsta order by flr
   open  c_oroomno
   fetch c_oroomno into @type
   while @@sqlstatus = 0
      begin
      insert rmcount_by_type (pc_id,modu_id,type) values (@pc_id,@modu_id,@type)
      select @typeset = @typeset + substring(ltrim(@type)+space(5),1,5) + '#'
      fetch c_oroomno into @type
		end  
   close c_oroomno
   deallocate cursor c_oroomno
   end

if @lmode = 'T'
   declare c_rmsta cursor for 
		select b.eccocode,a.roomno,a.type from rmsta a, rmstamap b 
		where a.ocsta+a.sta=b.code and (rtrim(@staset) is null or charindex(rtrim(b.eccocode),@staset) > 0) 
      	order by b.eccocode,a.type,a.oroomno
else
   declare c_rmsta cursor for 
		select b.eccocode,a.roomno,a.flr from rmsta a, rmstamap b 
		where a.ocsta+a.sta=b.code and (rtrim(@staset) is null or charindex(rtrim(b.eccocode),@staset) > 0) 
      	order by b.eccocode,a.flr,a.oroomno
open  c_rmsta
fetch c_rmsta into @eccocode,@roomno,@type
select @type1='', @eccocode1='' 
while @@sqlstatus=0
   begin
	if @eccocode<>@eccocode1 
		select @maxcnt = 0, @spccnt = 1, @eccocode1=@eccocode
	else if @type<>@type1 
		select @spccnt = 1, @type1=@type 
	else
		select @spccnt = @spccnt + 1

	if @spccnt > @maxcnt
		begin
		select @maxcnt = @spccnt
		insert rmlist_by_type (pc_id,modu_id,sta,stacnt) values (@pc_id,@modu_id,@eccocode,@maxcnt)
		end

	select @typeoff = convert(int,(charindex(substring(ltrim(@type)+space(5),1,5)+'#',@typeset) + 5)/6)

	if @typeoff = 1
		update rmlist_by_type set v01 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 2
		update rmlist_by_type set v02 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 3
		update rmlist_by_type set v03 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 4
		update rmlist_by_type set v04 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 5
		update rmlist_by_type set v05 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 6
		update rmlist_by_type set v06 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 7
		update rmlist_by_type set v07 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 8
		update rmlist_by_type set v08 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 9
		update rmlist_by_type set v09 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 10
		update rmlist_by_type set v10 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 11
		update rmlist_by_type set v11 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 12
		update rmlist_by_type set v12 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 13
		update rmlist_by_type set v13 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 14
		update rmlist_by_type set v14 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 15
		update rmlist_by_type set v15 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 16
		update rmlist_by_type set v16 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 17
		update rmlist_by_type set v17 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 18
		update rmlist_by_type set v18 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 19
		update rmlist_by_type set v19 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 20
		update rmlist_by_type set v20 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 21
		update rmlist_by_type set v21 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 22
		update rmlist_by_type set v22 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
  else if @typeoff = 23
		update rmlist_by_type set v23 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 24
		update rmlist_by_type set v24 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 25
		update rmlist_by_type set v25 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 26
		update rmlist_by_type set v26 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 27
		update rmlist_by_type set v27 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 28
		update rmlist_by_type set v28 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 29
		update rmlist_by_type set v29 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt
	else if @typeoff = 30
		update rmlist_by_type set v30 = @roomno where pc_id = @pc_id and modu_id = @modu_id and sta = @eccocode and stacnt = @spccnt

	fetch c_rmsta into @eccocode,@roomno,@type
	end
close c_rmsta
deallocate cursor c_rmsta

return 0
/* ### DEFNCOPY: END OF DEFINITION */
;