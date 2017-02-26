IF OBJECT_ID('dbo.p_gds_reserve_print_rmbmp2') IS NOT NULL
    DROP PROCEDURE dbo.p_gds_reserve_print_rmbmp2
;
create  proc  p_gds_reserve_print_rmbmp2
   @pc_id   char(4),
   @modu_id char(2),
   @hall    varchar(20),
   @auto    char(1)
as

declare
    @roomno char(5),
   @oroomno  char(5),
   @flr      char(3),
   @oflr     char(3),
   @nopart   char(2),
   @nocnt    int,
   @ocsta    char(1),
   @sta      char(1),
   @eccosta  char(3)

declare 	@gdate			datetime,
			@glen				int,
            @ptypes         varchar(255)

select @ptypes = ','+isnull((select rtrim(value) from sysoption where catalog='hotel' and item='proom_map'), '')+','
delete nopart_count where pc_id = @pc_id and modu_id = @modu_id
delete print_rmbmp  where pc_id = @pc_id and modu_id = @modu_id

create table #tmp(roomno char(5))
if @auto='T'
    begin
    insert into #tmp select a.roomno from hsmap_term_end a,hsmap b where a.pc_id = @pc_id and a.modu_id = @modu_id and b.pc_id = @pc_id and b.modu_id = @modu_id and a.roomno=b.roomno
    insert into #tmp select a.roomno from hsmap_term_end a,hsmap_new b where a.pc_id = @pc_id and a.modu_id = @modu_id and b.pc_id = @pc_id and b.modu_id = @modu_id and a.roomno=b.roomno
    end
else
    insert into #tmp select roomno from rmsta

declare c_rmsta cursor for select a.roomno,a.oroomno,a.flr from rmsta a,#tmp b where (rtrim(@hall) is null or charindex(rtrim(a.hall),@hall)>0)
			and (a.tag='K' or (a.tag='P' and  charindex(','+rtrim(a.type)+',', @ptypes)>0)) and a.roomno=b.roomno order by a.roomno
open  c_rmsta
fetch c_rmsta into @roomno,@oroomno,@flr
while @@sqlstatus = 0
   begin
   select @nopart = right(right(space(5)+rtrim(@roomno),5),2)
   --select @flr    = substring(right(space(5)+rtrim(@roomno),5),1,3)
   --select @oflr   = substring(right(space(5)+rtrim(@oroomno),5),1,3)
	select @oflr = @flr
   if not exists ( select 1 from nopart_count where pc_id = @pc_id and modu_id = @modu_id and no = @nopart)
      insert nopart_count (pc_id,modu_id,no) values (@pc_id,@modu_id,@nopart)
   if not exists ( select 1 from print_rmbmp where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr)
      insert print_rmbmp (pc_id,modu_id,oflr,flr) values (@pc_id,@modu_id,@oflr,@flr)
   fetch c_rmsta into @roomno,@oroomno,@flr
   end
close c_rmsta
deallocate cursor c_rmsta

select @nocnt = 0
declare c_nopart cursor for select no from nopart_count where pc_id = @pc_id and modu_id = @modu_id order by no
open  c_nopart
fetch c_nopart into @nopart
while @@sqlstatus = 0
   begin
   select @nocnt = @nocnt + 1
   update nopart_count set nocnt = @nocnt where pc_id = @pc_id and modu_id = @modu_id and no = @nopart
   fetch c_nopart into @nopart
   end
close c_nopart
deallocate cursor c_nopart

declare c_rmsta1 cursor for select a.roomno,a.oroomno,a.ocsta,a.sta,a.flr from rmsta a,#tmp b where  (rtrim(@hall) is null or charindex(rtrim(a.hall),@hall)>0)
			and (a.tag='K' or (a.tag='P' and  charindex(','+rtrim(a.type)+',', @ptypes)>0)) and a.roomno=b.roomno order by a.oroomno
open c_rmsta1
fetch c_rmsta1 into @roomno,@oroomno,@ocsta,@sta,@flr
while @@sqlstatus = 0
   begin
   select @nopart = right(right(space(5)+rtrim(@roomno),5),2)
   --select @flr    = substring(right(space(5)+rtrim(@roomno),5),1,3)
   --select @oflr   = substring(right(space(5)+rtrim(@oroomno),5),1,3)
	select @oflr=@flr
   select @nocnt  = nocnt from nopart_count where pc_id = @pc_id and modu_id = @modu_id and no = @nopart
   exec p_wz_translate_rm_sta @ocsta,@sta,@eccosta output
   if @eccosta = 'OCC'
      begin
      if exists(select 1 from master a,mktcode b where a.sta='I' and a.market = b.code and b.flag='HSE' and a.roomno=@roomno)
         select @eccosta = 'HU'
      else
         select @eccosta = 'O'
      end
   if @eccosta = 'CL'
	begin
      update print_rmbmp set vc = vc + 1    where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
		if exists(select 1 from master where roomno=@roomno and charindex(sta,'RCG') > 0)
		begin
			select @gdate = min(arr) from master where roomno=@roomno and charindex(sta,'RCG') > 0
			select @glen = isnull(datediff(dd,getdate(), @gdate),0)
			if @glen < 0
				select @eccosta = 'CL-'
			else if @glen >= 10
				select @eccosta = 'CL*'
			else
				select @eccosta = 'CL' + convert(char(1), @glen)
		end
	end
   else if @eccosta = 'DI'
	begin
      update print_rmbmp set vd = vd + 1    where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
		if exists(select 1 from master where roomno=@roomno and charindex(sta,'RCG') > 0)
		begin
			select @gdate = min(arr) from master where roomno=@roomno and charindex(sta,'RCG') > 0
			select @glen = isnull(datediff(dd,getdate(), @gdate),0)
			if @glen < 0
				select @eccosta = 'DI-'
			else if @glen >= 10
				select @eccosta = 'DI*'
			else
				select @eccosta = 'DI' + convert(char(1), @glen)
		end
	end
   else if @eccosta = 'O' or  @eccosta = 'OCC'
      update print_rmbmp set occ = occ + 1  where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @eccosta = 'HU'
      update print_rmbmp set hu = hu + 1    where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @eccosta = 'OO'
      update print_rmbmp set ooo = ooo + 1  where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   if @nocnt = 1
      update print_rmbmp set v01 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 2
      update print_rmbmp set v02 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 3
      update print_rmbmp set v03 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 4
      update print_rmbmp set v04 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 5
      update print_rmbmp set v05 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 6
      update print_rmbmp set v06 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 7
      update print_rmbmp set v07 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 8
      update print_rmbmp set v08 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 9
      update print_rmbmp set v09 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 10
      update print_rmbmp set v10 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 11
      update print_rmbmp set v11 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 12
      update print_rmbmp set v12 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 13
      update print_rmbmp set v13 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 14
      update print_rmbmp set v14 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 15
      update print_rmbmp set v15 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 16
      update print_rmbmp set v16 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 17
      update print_rmbmp set v17 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 18
      update print_rmbmp set v18 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 19
      update print_rmbmp set v19 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 20
      update print_rmbmp set v20 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 21
      update print_rmbmp set v21 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 22
      update print_rmbmp set v22 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 23
      update print_rmbmp set v23 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 24
      update print_rmbmp set v24 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 25
      update print_rmbmp set v25 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 26
      update print_rmbmp set v26 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 27
      update print_rmbmp set v27 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 28
      update print_rmbmp set v28 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 29
      update print_rmbmp set v29 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 30
      update print_rmbmp set v30 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   if @nocnt = 31
      update print_rmbmp set v31 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 32
      update print_rmbmp set v32 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 33
      update print_rmbmp set v33 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 34
      update print_rmbmp set v34 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 35
      update print_rmbmp set v35 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 36
      update print_rmbmp set v36 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 37
      update print_rmbmp set v37 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 38
      update print_rmbmp set v38 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 39
      update print_rmbmp set v39 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 40
      update print_rmbmp set v40 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 41
      update print_rmbmp set v41 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 42
      update print_rmbmp set v42 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 43
      update print_rmbmp set v43 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 44
      update print_rmbmp set v44 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 45
      update print_rmbmp set v45 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 46
      update print_rmbmp set v46 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 47
      update print_rmbmp set v47 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 48
      update print_rmbmp set v48 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 49
      update print_rmbmp set v49 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 50
      update print_rmbmp set v50 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 51
      update print_rmbmp set v51 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 52
      update print_rmbmp set v52 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 53
      update print_rmbmp set v53 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 54
      update print_rmbmp set v54 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 55
      update print_rmbmp set v55 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 56
      update print_rmbmp set v56 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 57
      update print_rmbmp set v57 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 58
      update print_rmbmp set v58 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 59
      update print_rmbmp set v59 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 60
      update print_rmbmp set v60 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
	else if @nocnt = 61
      update print_rmbmp set v61 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 62
      update print_rmbmp set v62 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 63
      update print_rmbmp set v63 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 64
      update print_rmbmp set v64 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 65
      update print_rmbmp set v65 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 66
      update print_rmbmp set v66 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 67
      update print_rmbmp set v67 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 68
      update print_rmbmp set v68 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 69
      update print_rmbmp set v69 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   else if @nocnt = 70
      update print_rmbmp set v70 = @eccosta where pc_id = @pc_id and modu_id = @modu_id and oflr = @oflr
   fetch c_rmsta1 into @roomno,@oroomno,@ocsta,@sta,@flr
   end
close c_rmsta1
deallocate cursor c_rmsta1
update print_rmbmp set ttl = vc+vd+occ+hu+ooo where pc_id = @pc_id and modu_id = @modu_id
return 0
;