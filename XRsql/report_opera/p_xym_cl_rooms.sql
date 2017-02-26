drop proc p_xym_cl_rooms;
create proc p_xym_cl_rooms
as
-- ------------------------------------------------------------------------
-- 系统维护程序之 #special
--
-- 维护单个账号
-- ------------------------------------------------------------------------

declare	
   @id      integer,
   @colin   integer,
   @type    char(10),
   @roomno  char(5) 

create table #vacant
   (
   id       integer,
   room1    char(16),
   room2    char(16),
   room3    char(16),
   room4    char(16),
   room5    char(16),
   room6    char(16),
   room7    char(16),
   room8    char(16)     
   )
select @id = 0,@colin=0

declare c_vacant cursor for select type,roomno from rmsta where ocsta='V' and sta = 'R' order by roomno
open  c_vacant
fetch c_vacant into @type,@roomno
while @@sqlstatus = 0
	begin
     
     if @colin = 0 
       begin
         insert #vacant select @id,'','','','','','','',''
         update #vacant set room1 = @type + '   ' + @roomno where id = @id
       end
     if @colin = 1 
         update #vacant set room2 = @type + '   ' + @roomno where id = @id
     if @colin = 2 
         update #vacant set room3 = @type + '   ' + @roomno where id = @id
     if @colin = 3 
         update #vacant set room4 = @type + '   ' + @roomno where id = @id
     if @colin = 4 
         update #vacant set room5 = @type + '   ' + @roomno where id = @id
     if @colin = 5 
         update #vacant set room6 = @type + '   ' + @roomno where id = @id
     if @colin = 6 
         update #vacant set room7 = @type + '   ' + @roomno where id = @id
     if @colin = 7 
         update #vacant set room8 = @type + '   ' + @roomno where id = @id
     if @colin = 8
       begin 
         select @colin = -1
         select @id = @id + 1
       end
     select @colin = @colin + 1
	fetch c_vacant into @type,@roomno
	end
close c_vacant

deallocate cursor c_vacant

select room1,room2,room3,room4,room5,room6,room7,room8 from #vacant order by id

;
exec p_xym_cl_rooms;