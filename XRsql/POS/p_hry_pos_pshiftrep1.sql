drop  proc p_hry_pos_pshiftrep1;
create proc p_hry_pos_pshiftrep1
   @pc_id   char(4)

as

declare
   @code    char(3),
   @coden   char(1),
   @pccode  char(3),
   @pccodes varchar(120),
   @spccode char(3),
   @fee     money,
   @vpos    int,
   @tl      money,
   @count   money,
   @avfee   money,
   @jiedai  char(1),
   @itemcnt int

declare c_pccode cursor for select distinct pccode from posjie where pc_id = @pc_id
	union  select distinct pccode from posdai where pc_id = @pc_id
order by pccode

open  c_pccode
fetch c_pccode into @pccode
while @@sqlstatus = 0
   begin
   select @pccodes = @pccodes + @pccode +'#'
   fetch c_pccode into @pccode
   end
close c_pccode
deallocate cursor c_pccode
delete  pdeptrep where pc_id = @pc_id
insert  pdeptrep (pc_id,jiedai,code,descript) select distinct @pc_id,'A',code,descript from posjie where pc_id = @pc_id
declare c_ydeptjie cursor for select pccode,code,feed from posjie where pc_id = @pc_id
				       order by pccode,code
select @spccode = ''
open  c_ydeptjie
fetch c_ydeptjie into @pccode,@code,@fee
while @@sqlstatus = 0
   begin
   if @spccode <> @pccode
	   select @spccode=@pccode,@vpos = convert(int,(charindex(@pccode,@pccodes)+3)/4)
   if @vpos = 1
	  update pdeptrep set v1 = v1 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 2
	  update pdeptrep set v2 = v2 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 3
	  update pdeptrep set v3 = v3 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 4
	  update pdeptrep set v4 = v4 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 5
	  update pdeptrep set v5 = v5 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 6
	  update pdeptrep set v6 = v6 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 7
	  update pdeptrep set v7 = v7 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 8
	  update pdeptrep set v8 = v8 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 9
	  update pdeptrep set v9= v9 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 10
	  update pdeptrep set v10 = v10 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 11
	  update pdeptrep set v11 = v11 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 12
	  update pdeptrep set v12 = v12 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 13
	  update pdeptrep set v13 = v13 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 14
	  update pdeptrep set v14 = v14 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 15
	  update pdeptrep set v15 = v15 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 16
	  update pdeptrep set v16 = v16 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 17
	  update pdeptrep set v17 = v17 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 18
	  update pdeptrep set v18 = v18 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 19
	  update pdeptrep set v19 = v19 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 20
	  update pdeptrep set v20 = v20 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 21
	  update pdeptrep set v21 = v21 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 22
	  update pdeptrep set v22 = v22 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 23
	  update pdeptrep set v23 = v23 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 24
	  update pdeptrep set v24 = v24 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 25
	  update pdeptrep set v25 = v25 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 26
	  update pdeptrep set v26 = v26 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 27
	  update pdeptrep set v27 = v27 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 28
	  update pdeptrep set v28 = v28 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 29
	  update pdeptrep set v29 = v29 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 30
	  update pdeptrep set v30 = v30 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   if @vpos = 31
	  update pdeptrep set v31 = v31 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 32
	  update pdeptrep set v32 = v32 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 33
	  update pdeptrep set v33 = v33 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 34
	  update pdeptrep set v34 = v34 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 35
	  update pdeptrep set v35 = v35 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 36
	  update pdeptrep set v36 = v36 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 37
	  update pdeptrep set v37 = v37 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 38
	  update pdeptrep set v38 = v38 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 39
	  update pdeptrep set v39 = v39 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 40
	  update pdeptrep set v40 = v40 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   fetch c_ydeptjie into @pccode,@code,@fee
   end
close c_ydeptjie
deallocate cursor c_ydeptjie
update pdeptrep set vtl = v1+v2+v3+v4+v5+v6+v7+v8+v9+v10+v11+v12+v13+v14+v15+v16+v17+v18+v19+v20+v21+v22+v23+v24+v25+v26+v27+v28+v29+v30+v31+v32+v33+v34+v35+v36+v37+v38+v39+v40
		 where pc_id = @pc_id and jiedai ='A'
select @count = vtl from pdeptrep where pc_id = @pc_id and jiedai ='A' and code ='99A'
select @tl    = vtl from pdeptrep where pc_id = @pc_id and jiedai ='A' and code ='999'
if @count = 0
   select @avfee = 0
else
   select @avfee = @tl/@count
update pdeptrep set vtl = @avfee where pc_id = @pc_id and jiedai ='A' and code ='99B'
insert pdeptrep (pc_id,jiedai,code,coden,descript)
	   select distinct @pc_id,'B',paycode,paytail,descript from posdai
					   where pc_id = @pc_id
declare c_ydeptdai cursor for select pccode,paycode,paytail,creditd from posdai
				   where pc_id = @pc_id
				   order by pccode,paycode,paytail
select @spccode = ''
open c_ydeptdai
fetch c_ydeptdai into @pccode,@code,@coden,@fee
while @@sqlstatus = 0
   begin
   if @spccode <> @pccode
	  select @spccode=@pccode,@vpos = convert(int,(charindex(@pccode,@pccodes)+3)/4)
   if @vpos = 1
	  update pdeptrep set v1 = v1 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 2
	  update pdeptrep set v2 = v2 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 3
	  update pdeptrep set v3 = v3 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 4
	  update pdeptrep set v4 = v4 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 5
	  update pdeptrep set v5 = v5+ @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 6
	  update pdeptrep set v6 = v6 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 7
	  update pdeptrep set v7= v7 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 8
	  update pdeptrep set v8 = v8 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 9
	  update pdeptrep set v9 = v9 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 10
	  update pdeptrep set v10 = v10 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 11
	  update pdeptrep set v11 = v11 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 12
	  update pdeptrep set v12 = v12 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 13
	  update pdeptrep set v13 = v13 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 14
	  update pdeptrep set v14 = v14 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 15
	  update pdeptrep set v15 = v15 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 16
	  update pdeptrep set v16 = v16 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
  else if @vpos = 17
	  update pdeptrep set v17 = v17 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 18
	  update pdeptrep set v18 = v18 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 19
	  update pdeptrep set v19 = v19 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 20
	  update pdeptrep set v20 = v20 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 21
	  update pdeptrep set v21 = v21 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 22
	  update pdeptrep set v22 = v22 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 23
	  update pdeptrep set v23 = v23 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 24
	  update pdeptrep set v24 = v24 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 25
	  update pdeptrep set v25 = v25 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 26
	  update pdeptrep set v26 = v26 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 27
	  update pdeptrep set v27 = v27 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 28
	  update pdeptrep set v28 = v28 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 29
	  update pdeptrep set v29 = v29 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 30
	  update pdeptrep set v30 = v30 +@fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   if @vpos = 31
	  update pdeptrep set v31 = v31 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 32
	  update pdeptrep set v32 =v32 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 33
	  update pdeptrep set v33 = v33 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 34
	  update pdeptrep set v34 = v34 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 35
	  update pdeptrep set v35 = v35 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 36
	  update pdeptrep set v36 = v36 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 37
	  update pdeptrep set v37 = v37 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 38
	  update pdeptrep set v38 = v38 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 39
	  update pdeptrep set v39 = v39 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 40
	  update pdeptrep set v40 = v40 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   fetch c_ydeptdai into @pccode,@code,@coden,@fee
   end
close c_ydeptdai
deallocate cursor c_ydeptdai
update pdeptrep set vtl = v1+v2+v3+v4+v5+v6+v7+v8+v9+v10+v11+v12+v13+v14+v15+v16+v17+v18+v19+v20+v21+v22+v23+v24+v25+v26+v27+v28+v29+v30+v31+v32+v33+v34+v35+v36+v37+v38+v39+v40
		 where pc_id = @pc_id and jiedai ='B'
select @itemcnt = 0
declare c_pdeptrep cursor for select jiedai,code,coden from pdeptrep
                   where pc_id = @pc_id order by jiedai,code,coden
open c_pdeptrep
fetch  c_pdeptrep into @jiedai,@code,@coden
while @@sqlstatus = 0
   begin
   select @itemcnt = @itemcnt + 1
   update pdeptrep set itemcnt = @itemcnt where pc_id = @pc_id and jiedai = @jiedai
                                                and code = @code and coden = @coden
   fetch  c_pdeptrep into @jiedai,@code,@coden
   end
close c_pdeptrep
deallocate cursor c_pdeptrep
update pdeptrep set itemcnt = itemcnt - (select count(*) from pdeptrep b where b.pc_id = @pc_id and b.jiedai ='A')
                where pdeptrep.pc_id = @pc_id and pdeptrep.jiedai ='B'
update pdeptrep set itemcnt = (select max(itemcnt)+1 from pdeptrep where pdeptrep.pc_id = @pc_id and pdeptrep.jiedai ='B') where pdeptrep.pc_id = @pc_id  and pdeptrep.code ='B'
return 0
;