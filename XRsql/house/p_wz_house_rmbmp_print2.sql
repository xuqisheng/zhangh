IF OBJECT_ID('p_wz_house_rmbmp_print2') IS NOT NULL
    DROP PROCEDURE p_wz_house_rmbmp_print2
;
create proc p_wz_house_rmbmp_print2
		@pc_id		char(4),
		@modu_id    char(2),
        @hall       varchar(20),
        @flr_       varchar(60),
        @auto       char(1)
as
declare
	   @roomno		char(5),
		@oroomno		char(5),
	   @oflr			char(3),
	   @flr			char(3),
	   @nocnt		integer,
	   @nopart		char(2),
 	   @ocsta		char(1),
		@sta			char(1),
		@enocsta		char(7),
        @ptypes         varchar(255)

delete nopart_count where pc_id = @pc_id and modu_id = @modu_id
delete print_rmbmp where pc_id = @pc_id and modu_id = @modu_id
select @ptypes = ','+isnull((select rtrim(value) from sysoption where catalog='hotel' and item='proom_map'), '')+','
create table #tmp(roomno char(5))
if @auto='T'
    begin
    insert into #tmp select a.roomno from hsmap_term_end a,hsmap b where a.pc_id = @pc_id and a.modu_id = @modu_id and b.pc_id = @pc_id and b.modu_id = @modu_id and a.roomno=b.roomno
    insert into #tmp select a.roomno from hsmap_term_end a,hsmap_new b where a.pc_id = @pc_id and a.modu_id = @modu_id and b.pc_id = @pc_id and b.modu_id = @modu_id and a.roomno=b.roomno
    end
else
    insert into #tmp select roomno from rmsta

select @nocnt = 0

declare c_rmno cursor for select a.roomno from rmsta a,#tmp b where (rtrim(@flr_) is null or charindex(rtrim(a.flr),@flr_)>0) and (rtrim(@hall) is null or charindex(rtrim(a.hall),@hall)>0)
			and (a.tag='K' or (a.tag='P' and  charindex(','+rtrim(a.type)+',', @ptypes)>0)) and a.roomno=b.roomno order by a.roomno
open c_rmno
fetch c_rmno into @roomno
while @@sqlstatus = 0
	begin
		select @flr = substring(right(space(5) + rtrim(@roomno), 5),1,3)
		select @nopart = right(right(space(5)+rtrim(@roomno),5),2)
		if not exists (select 1 from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and flr = @nopart)
			insert print_rmbmp (modu_id,pc_id,oflr,flr) select @modu_id,@pc_id,@nopart,@nopart
		if not exists (select 1 from nopart_count where modu_id = @modu_id and pc_id = @pc_id and no = @flr )
			insert nopart_count (modu_id,pc_id,no) select @modu_id,@pc_id,@flr
		fetch c_rmno into @roomno
	end
close c_rmno
deallocate cursor c_rmno


declare c_no cursor for select no from nopart_count where modu_id = @modu_id and pc_id = @pc_id order by no
open c_no
fetch c_no into @flr
while @@sqlstatus = 0
	begin
		select @nocnt = @nocnt + 1
		update nopart_count set nocnt = @nocnt where modu_id = @modu_id and pc_id = @pc_id and no = @flr
		fetch c_no into @flr
	end
close c_no
deallocate cursor c_no

declare c_sta cursor for select a.roomno,a.oroomno,a.ocsta,a.sta from rmsta a,#tmp b where  (rtrim(@flr_) is null or charindex(rtrim(a.flr),@flr_)>0) and (rtrim(@hall) is null or charindex(rtrim(a.hall),@hall)>0)
			and (a.tag='K' or (a.tag='P' and  charindex(','+rtrim(a.type)+',', @ptypes)>0)) and a.roomno=b.roomno order by a.roomno

open c_sta
fetch c_sta into @roomno,@oroomno,@ocsta,@sta
while @@sqlstatus = 0
	begin
		select @flr = substring(right(space(5) + rtrim(@roomno),5),1,3)
		select @nopart = right(right(space(5) + rtrim(@roomno),5),2)
		select @nocnt = nocnt from nopart_count where modu_id = @modu_id and pc_id = @pc_id and no = @flr

		if @ocsta ='O'
            if exists (select 1 from master where charindex(sta,'I')>0  and market = 'HSE' and roomno = @roomno)
    			select @enocsta = 'HU'
    		else
    			select @enocsta = 'OCC'
		if @ocsta = 'V' and @sta = 'R'
			select @enocsta = 'CL'
		if @ocsta = 'V' and @sta = 'D'
			select @enocsta = 'DI'
		if charindex(@sta,'OS') >0 and @ocsta<> 'O'
			select @enocsta = 'OO'

		if @nocnt = 1
			begin
				update print_rmbmp set v01 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v01 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
	   else if @nocnt = 2
			begin
				update print_rmbmp set v02 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v02 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt =3
			begin
				update print_rmbmp set v03 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v03 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 4
			begin
				update print_rmbmp set v04 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v04 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 5
			begin
				update print_rmbmp set v05 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v05 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 6
			begin
				update print_rmbmp set v06 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v06 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 7
			begin
				update print_rmbmp set v07 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where  modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v07 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 8
			begin
				update print_rmbmp set v08 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v08 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 9
			begin
				update print_rmbmp set v09 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v09 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 10
			begin
				update print_rmbmp set v10 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v10 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 11
			begin
				update print_rmbmp set v11 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v11 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 12
			begin
				update print_rmbmp set v12 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v12 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 13
			begin
				update print_rmbmp set v13 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v13 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 14
			begin
				update print_rmbmp set v14 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v14 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 15
			begin
				update print_rmbmp set v15 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v15 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 16
			begin
				update print_rmbmp set v16 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v16 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 17
			begin
				update print_rmbmp set v17 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v18 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 18
			begin
				update print_rmbmp set v18 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v18 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 19
			begin
				update print_rmbmp set v19 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v19 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 20
			begin
				update print_rmbmp set v20 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v20 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 21
			begin
				update print_rmbmp set v21 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v21 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 22
			begin
				update print_rmbmp set v22 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v22 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 23
			begin
				update print_rmbmp set v23 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v23 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 24
			begin
				update print_rmbmp set v24 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v24 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 25
			begin
				update print_rmbmp set v25 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v25 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 26
			begin
				update print_rmbmp set v26 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v26 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 27
			begin
				update print_rmbmp set v27 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v27 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 28
			begin
				update print_rmbmp set v28 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v28 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 29
			begin
				update print_rmbmp set v29 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v29 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 30
			begin
				update print_rmbmp set v30 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v30 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 31
			begin
				update print_rmbmp set v31 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v31 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 32
			begin
				update print_rmbmp set v32 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v32 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 33
			begin
				update print_rmbmp set v33 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v35 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 34
			begin
				update print_rmbmp set v34 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v34 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 35
			begin
				update print_rmbmp set v35 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v35 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 36
			begin
				update print_rmbmp set v36 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v36 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 37
			begin
				update print_rmbmp set v37 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v37 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 38
			begin
				update print_rmbmp set v38 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v38 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 39
			begin
				update print_rmbmp set v39 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v39 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 40
			begin
				update print_rmbmp set v40 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v40 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 41
			begin
				update print_rmbmp set v41 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
				update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
				update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
				update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
				update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
				update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
				if @ocsta = 'O' and charindex(@sta,'OS')>0
				update print_rmbmp set v41 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
			end
		else if @nocnt = 42
					begin
						update print_rmbmp set v42 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v42 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 43
					begin
						update print_rmbmp set v43 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v43 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 44
					begin
						update print_rmbmp set v44 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v44 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 45
					begin
						update print_rmbmp set v45 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v45 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 46
					begin
						update print_rmbmp set v46 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v46 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 47
					begin
						update print_rmbmp set v47 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v47 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 48
					begin
						update print_rmbmp set v48 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v48 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 49
					begin
						update print_rmbmp set v49 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v49 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 50
					begin
						update print_rmbmp set v50 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v50 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 51
					begin
						update print_rmbmp set v51 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v51 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 52
					begin
						update print_rmbmp set v52 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v52 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 53
					begin
						update print_rmbmp set v53 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v53 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 54
					begin
						update print_rmbmp set v54 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v54 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 55
					begin
						update print_rmbmp set v55 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v55 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 56
					begin
						update print_rmbmp set v56 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v56 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 57
					begin
						update print_rmbmp set v57 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v57 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 58
					begin
						update print_rmbmp set v58 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v58 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 59
					begin
						update print_rmbmp set v59 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v59 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end
		else if @nocnt = 60
					begin
						update print_rmbmp set v60 = @enocsta from print_rmbmp where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
						update print_rmbmp set vc = vc + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='CL'
						update print_rmbmp set vd = vd + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='DI'
						update print_rmbmp set occ = occ + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OCC'
						update print_rmbmp set hu = hu + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='HU'
						update print_rmbmp set ooo = ooo + 1 where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart and @enocsta ='OO'
						if @ocsta = 'O' and charindex(@sta,'OS')>0
						update print_rmbmp set v60 ='OCC/OO' where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
					end

		update print_rmbmp set ttl = isnull(vc + vd + occ + hu + ooo,0) where modu_id = @modu_id and pc_id = @pc_id and oflr = @nopart
		fetch c_sta into @roomno,@oroomno,@ocsta,@sta
	end
close c_sta
deallocate cursor c_sta

return 0
;
