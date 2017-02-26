drop proc p_report_yyjc14;
create proc p_report_yyjc14

as

declare
    @type   char(5),
    @rooms  varchar(255),
    @number  integer,
    @roomno varchar(5)
   

create table #roomtype
(roomtype   varchar(5)   null,
 maxocc     integer      null,
 rooms0     varchar(255) null,
 rooms1     varchar(255) null,
 rooms2     varchar(255) null,
 rooms3     varchar(255) null,
 rooms4     varchar(255) null,
 rooms5     varchar(255) null,
 rooms6     varchar(255) null,
 rooms7     varchar(255) null,
 rooms8     varchar(255) null,
 rooms9     varchar(255) null
)
select @rooms = '',@number = 130  --可定义每行显示的房间的字符长度。
declare c_types cursor for select distinct type from typim
declare c_rooms cursor for select isnull(rtrim(roomno),'***') from rmsta where type = @type

open c_types
fetch c_types into @type
while @@sqlstatus = 0

     begin
          if not exists (select 1 from #roomtype where roomtype = @type)
             begin
             insert into #roomtype  select @type,0,'','','','','','','','','',''
             update #roomtype set maxocc = (select max(a.people) from rmsta a where a.type = @type) where #roomtype.roomtype = @type
             end 
          open c_rooms 
          fetch c_rooms into @roomno
          while @@sqlstatus = 0
                begin
                    
       
                    if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms0),''))+datalength(@roomno)+1 - 1 <=@number )
                  
                         update #roomtype set rooms0 = rooms0 +','+ @roomno where roomtype = @type
                         
                         
                         
                         
                     else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms1),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms1 = rooms1 +','+ @roomno where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms2),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms2 = rooms2 +','+ @roomno where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms3),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms3 = rooms3 +','+ @roomno where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms4),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms4 = rooms4 +','+ @roomno where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms5),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms5 = rooms5 +','+ @roomno where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms6),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms6 = rooms6 +','+ @roomno where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms7),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms7 = rooms7 +','+ @roomno where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms8),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms8 = rooms8 +','+ @roomno where roomtype = @type
                    else if exists (select 1 from #roomtype where roomtype = @type and datalength(isnull(rtrim(rooms9),''))+datalength(@roomno)+1<=@number)
                         update #roomtype set rooms9 = rooms9 +','+ @roomno where roomtype = @type

                fetch c_rooms into @roomno
                end 
         close c_rooms
		                   
     fetch c_types into @type
     end                 
    close c_types
   deallocate cursor c_types                       
   deallocate cursor c_rooms                          
   select a.*,b.descript1,b.gtype,b.quantity,b.ratecode,b.rate,b.sequence from    #roomtype a,typim b where a.roomtype = b.type
return 0 ;                     



                    
                    
                    
                    
                    
                    
                    
                    
                    


          






