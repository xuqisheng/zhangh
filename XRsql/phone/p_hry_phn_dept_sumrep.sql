IF OBJECT_ID('p_hry_phn_dept_sumrep') IS NOT NULL
    DROP PROCEDURE p_hry_phn_dept_sumrep
;
create proc   p_hry_phn_dept_sumrep
   @pc_id     char(4),
   @s_time    datetime,
   @e_time    datetime,
   @referpat  varchar(20)

as

declare
   @refer     char(8),
   @room      char(8),
   @date      datetime,
   @length    char(8),
   @calltype  char(1),
   @fee       money,
   @phnclsset varchar(20),
   @tpos      int,
   @ret       int,
   @msg       varchar(60)

select @ret=0,@msg=''
if @s_time > @e_time
   begin
   select @date = @s_time
   select @s_time = @e_time
   select @e_time = @date
 end
select @e_time = dateadd(day,1,@e_time)

declare c_phncls cursor for select class from phncls order by class
open    c_phncls
fetch   c_phncls into @calltype
while @@sqlstatus = 0
   begin
   select @phnclsset=@phnclsset+@calltype
   fetch  c_phncls into @calltype
   end
close c_phncls
deallocate cursor c_phncls

delete phn_dept_sumrep where pc_id = @pc_id
declare c_phfolio cursor for select refer,room,length,calltype,fee
        from phfolio where date >= @s_time and date < @e_time and refer like @referpat
open    c_phfolio
fetch   c_phfolio into @refer,@room,@length,@calltype,@fee
while @@sqlstatus = 0
   begin
   if datalength(rtrim(@refer)) = 7 and charindex(substring(@refer,1,1),'0123456789') > 0
      select @refer = 'EEE'
   if not exists (select 1 from phn_dept_sumrep where pc_id=@pc_id and dept=@refer and room = @room)
      begin
      insert phn_dept_sumrep (pc_id,dept,room) values (@pc_id,@refer,@room)
      if not exists (select 1 from phn_dept_sumrep where pc_id=@pc_id and dept=@refer and room='{{{{{')
         insert phn_dept_sumrep (pc_id,dept,room) values (@pc_id,@refer,'{{{{{')
      end
   select @tpos = charindex(@calltype,@phnclsset)
   if @tpos = 1
      update phn_dept_sumrep set n1 = n1+1,v1=v1+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 2
      update phn_dept_sumrep set n2 = n2+1,v2=v2+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 3
      update phn_dept_sumrep set n3 = n3+1,v3=v3+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 4
      update phn_dept_sumrep set n4 = n4+1,v4=v4+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 5
      update phn_dept_sumrep set n5 = n5+1,v5=v5+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 6
      update phn_dept_sumrep set n6 = n6+1,v6=v6+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 7
      update phn_dept_sumrep set n7 = n7+1,v7=v7+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 8
      update phn_dept_sumrep set n8 = n8+1,v8=v8+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 9
      update phn_dept_sumrep set n9 = n9+1,v9=v9+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 10
      update phn_dept_sumrep set n10 = n10+1,v10=v10+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 11
      update phn_dept_sumrep set n11 = n11+1,v11=v11+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 12
 update phn_dept_sumrep set n12 = n12+1,v12=v12+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 13
      update phn_dept_sumrep set n13 = n13+1,v13=v13+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 14
      update phn_dept_sumrep set n14 = n14+1,v14=v14+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 15
      update phn_dept_sumrep set n15 = n15+1,v15=v15+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 16
      update phn_dept_sumrep set n16 = n16+1,v16=v16+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 17
      update phn_dept_sumrep set n17 = n17+1,v17=v17+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   else if @tpos = 18
      update phn_dept_sumrep set n18 = n18+1,v18=v18+@fee where pc_id=@pc_id and dept=@refer and (room = @room or room='{{{{{')
   fetch   c_phfolio into @refer,@room,@length,@calltype,@fee
   end
close c_phfolio
deallocate cursor c_phfolio
update phn_dept_sumrep set name1 = b.name from phdeptdef b where phn_dept_sumrep.dept = b.dept and phn_dept_sumrep.pc_id = @pc_id
update phn_dept_sumrep set name1 = '客房电话'   where dept = 'EEE' and pc_id = @pc_id
update phn_dept_sumrep set name1 = '没定义区号' where dept = 'NO CODE' and pc_id = @pc_id
update phn_dept_sumrep set name1 = '没组别类别' where dept = 'NOCLASS' and pc_id = @pc_id
update phn_dept_sumrep set name1 = '空客房电话' where dept = 'NO ROOM' and pc_id = @pc_id
update phn_dept_sumrep set name1 = '空客房帐号' where dept = 'EMPTY' and pc_id = @pc_id
update phn_dept_sumrep set name1 = '免记费电话' where dept = 'FREE' and pc_id = @pc_id
update phn_dept_sumrep set name2 = b.site from phextroom b where phn_dept_sumrep.room = b.extno and phn_dept_sumrep.pc_id = @pc_id
update phn_dept_sumrep set name2 = '分机-'+room where rtrim(name2) is null and pc_id = @pc_id
update phn_dept_sumrep set nt=n1+n2+n3+n4+n5+n6+n7+n8+n9+n10+n11+n12+n13+n14+n15+n16+n17+n18,vt=v1+v2+v3+v4+v5+v6+v7+v8+v9+v10+v11+v12+v13+v14+v15+v16+v17+v18 where pc_id = @pc_id
select @ret,@msg
return @ret
;