drop proc p_report_yyjc08;
create proc p_report_yyjc08

as

declare
    @type   char(5),
    @rooms  varchar(100),
    @number  integer,
    @roomno varchar(5)
   

create table #roomtype
(roomtype   varchar(5)   null,
 name0     varchar(20)      null,
 rooms0     varchar(100) null,
 rooms1     varchar(100) null,
 rooms2     varchar(100) null,
 rooms3     varchar(100) null,
 rooms4     varchar(100) null,
 rooms5     varchar(100) null,
 rooms6     varchar(100) null,
 rooms7     varchar(100) null,
 rooms8     varchar(100) null,
 rooms9     varchar(100) null,
 room0     varchar(100) null,
 room1     varchar(100) null,
 room2     varchar(100) null,
 room3     varchar(100) null,
 room4     varchar(100) null,
 room5     varchar(100) null,
 room6     varchar(100) null,
 room7     varchar(100) null,
 room8     varchar(100) null,
 room9     varchar(100) null,
 roomn0     varchar(100) null,
 roomn1     varchar(100) null,
 roomn2     varchar(100) null,
 roomn3     varchar(100) null,
 roomn4     varchar(100) null,
 roomn5     varchar(100) null,
 roomn6     varchar(100) null,
 roomn7     varchar(100) null,
 roomn8     varchar(100) null,
 roomn9     varchar(100) null
)
select @rooms = '',@number = 71  --定义每行显示的PCCODE的字符数
declare c_types cursor for select distinct deptno7 from pccode where argcode<'98'
declare c_rooms cursor for select isnull(rtrim(pccode),'***') from pccode where deptno7 = @type

open c_types
fetch c_types into @type
while @@sqlstatus = 0

     begin
          if not exists (select 1 from #roomtype where roomtype = @type)
             begin
             insert into #roomtype  select @type,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''
            
             end 
          open c_rooms 
          fetch c_rooms into @roomno
          while @@sqlstatus = 0
                begin
                    
       
                    if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms0),''))+datalength(@roomno)+1 <= @number)
                         update #roomtype set rooms0 = rooms0 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms1),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms1 = rooms1 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms2),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms2 = rooms2 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms3),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms3 = rooms3 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms4),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms4 = rooms4 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms5),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms5 = rooms5 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms6),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms6 = rooms6 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms7),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms7 = rooms7 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms8),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms8 = rooms8 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms9),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms9 = rooms9 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(room0),''))+datalength(@roomno)+1 <= @number)
                         update #roomtype set room0 = room0 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(room1),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set room1 = room1 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(room2),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set room2 = room2 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(room3),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set room3 = room3 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(room4),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set room4 = room4 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(room5),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set room5 = room5 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(room6),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set room6 = room6 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(room7),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set room7 = room7 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(room8),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set room8 = room8 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(room9),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set room9 = room9 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(roomn0),''))+datalength(@roomno)+1 <= @number)
                         update #roomtype set roomn0 = roomn0 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(roomn1),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set roomn1 = roomn1 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(roomn2),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set roomn2 = roomn2 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(roomn3),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set roomn3 = roomn3 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(roomn4),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set roomn4 = roomn4 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(roomn5),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set roomn5 = roomn5 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(roomn6),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set roomn6 = roomn6 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(roomn7),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set roomn7 = roomn7 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(roomn8),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set roomn8 = roomn8 + @roomno+',' where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(roomn9),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set roomn9 = roomn9 + @roomno+',' where roomtype = @type

                fetch c_rooms into @roomno
                end 
         close c_rooms
		                   
     fetch c_types into @type
     end                 
    close c_types
   deallocate cursor c_types                       
   deallocate cursor c_rooms       
   update #roomtype set name0 = 'Room Revenue',roomtype = '001' where roomtype = 'rm'
   update #roomtype set name0 = 'Food and Revenue',roomtype = '002' where roomtype = 'fb'
   update #roomtype set name0 = 'Meeting/Banquet',roomtype = '003' where roomtype = 'mt'
   update #roomtype set name0 = 'Other',roomtype = '004' where roomtype = 'ot'
   update #roomtype set name0 = 'Room Service',roomtype = '005' where roomtype = 'rs'
   --在此添加注释
                     
   select * from #roomtype
return 0;