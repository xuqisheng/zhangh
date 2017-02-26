if exists(select * from sysobjects where name = "p_zk_block_forecast" and type ='P')
	drop proc p_zk_block_forecast
;


create proc p_zk_block_forecast
   
as
declare
   @resno   char(10) ,
   @name     char(40)  ,
   @ratecode   char(10) ,
   @type  char(8) ,
   @sta   char(8) ,
   @accnt   char(10) ,  
   @d1     char(10) ,
   @d2     char(10) ,
   @d3     char(10) ,
   @d4      char(10) ,
   @d5     char(10) ,
   @d6     char(10) ,
   @d7   char(10) ,
   @d8   char(10) ,
   @d9   char(10) ,
   @d10    char(10) ,
   @d11  char(10) ,
   @d12   char(10) ,
   @d13   char(10) ,
   @d14    char(10) ,
   @day    integer,
   @tmprm  varchar(8),
   @date   datetime,
   @bdate   datetime,
   @arr   datetime,
   @dep  datetime
   
 
create table #bob
(
	resno   char(10) null,
   name     char(40)  null,
   ratecode   char(10) null,
   type  char(8) null,
   sta   char(8) null,
   accnt   char(10)   null,
   arr    datetime null,
   dep    datetime  null,
   d1     char(1) null,
   d2     char(1) null,
   d3     char(1) null,
   d4      char(1) null,
   d5     char(1) null,
   d6     char(1) null,
   d7   char(1) null,
   d8   char(1) null,
   d9   char(1) null,
   d10    char(1) null,
   d11  char(1) null,
   d12   char(1) null,
   d13   char(1) null,
   d14    char(1) null
)

select @bdate = bdate1 from sysdata
insert #bob select a.resno , b.haccnt,a.ratecode,a.type,b.sta,a.accnt,a.arr,a.dep,'','','','','','','','','','','','','',''
from master a,master_des b where a.accnt=b.accnt and a.class='F' and a.sta='R' 
and ((convert(char(8),@bdate,12)<=convert(char(8),a.arr,12) and convert(char(8),dateadd(dd,14,@bdate),12)>=convert(char(8),a.arr,12)))--  or (convert(char(8),@bdate,12)<=convert(char(8),a.dep,12) and convert(char(8),@bdate,12)>=convert(char(8),a.arr,12) and convert(char(8),dateadd(dd,14,@bdate),12)>=convert(char(8),a.arr,12) and convert(char(8),dateadd(dd,14,@bdate),12)<=convert(char(8),a.dep,12)))
--select * from #bob
--return
--insert #bob select distinct roomno,type,char10=(select eccocode from rmstamap where code=(rmsta.ocsta+rmsta.sta)),'','','','','','','','','','','','','','' from rmsta    order by roomno
--delete from #bob where status='OO'
--select * from #bob
--return 
select @day=0


declare c_cms cursor for select accnt,arr,dep from #bob order by accnt
open c_cms
fetch c_cms into @accnt,@arr,@dep
while @@sqlstatus = 0 
   begin
      if @bdate>=@arr and @bdate<=@dep
         update #bob set d1='T' where accnt=@accnt
      if dateadd(dd,1,@bdate)>=@arr and dateadd(dd,1,@bdate)<=@dep
         update #bob set d2='T' where accnt=@accnt
      if dateadd(dd,2,@bdate)>=@arr and dateadd(dd,2,@bdate)<=@dep
         update #bob set d3='T' where accnt=@accnt
      if dateadd(dd,3,@bdate)>=@arr and dateadd(dd,3,@bdate)<=@dep
         update #bob set d4='T' where accnt=@accnt
      if dateadd(dd,4,@bdate)>=@arr and dateadd(dd,4,@bdate)<=@dep
         update #bob set d5='T' where accnt=@accnt
      if dateadd(dd,5,@bdate)>=@arr and dateadd(dd,5,@bdate)<=@dep
         update #bob set d6='T' where accnt=@accnt
      if dateadd(dd,6,@bdate)>=@arr and dateadd(dd,6,@bdate)<=@dep
         update #bob set d7='T' where accnt=@accnt
      if dateadd(dd,7,@bdate)>=@arr and dateadd(dd,7,@bdate)<=@dep
         update #bob set d8='T' where accnt=@accnt
      if dateadd(dd,8,@bdate)>=@arr and dateadd(dd,8,@bdate)<=@dep
         update #bob set d9='T' where accnt=@accnt
      if dateadd(dd,9,@bdate)>=@arr and dateadd(dd,9,@bdate)<=@dep
         update #bob set d10='T' where accnt=@accnt
      if dateadd(dd,10,@bdate)>=@arr and dateadd(dd,10,@bdate)<=@dep
         update #bob set d11='T' where accnt=@accnt
      if dateadd(dd,11,@bdate)>=@arr and dateadd(dd,11,@bdate)<=@dep
         update #bob set d12='T' where accnt=@accnt
      if dateadd(dd,12,@bdate)>=@arr and dateadd(dd,12,@bdate)<=@dep
         update #bob set d13='T' where accnt=@accnt
      if dateadd(dd,13,@bdate)>=@arr and dateadd(dd,13,@bdate)<=@dep
         update #bob set d14='T' where accnt=@accnt
   select @day=0,@arr='',@dep=''
   fetch c_cms into @accnt,@arr,@dep
   end



select resno,name,ratecode,type,sta,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,@bdate,dateadd(dd,1,@bdate),dateadd(dd,2,@bdate),dateadd(dd,3,@bdate),dateadd(dd,4,@bdate),dateadd(dd,5,@bdate),dateadd(dd,6,@bdate),dateadd(dd,7,@bdate),dateadd(dd,8,@bdate),dateadd(dd,9,@bdate),dateadd(dd,10,@bdate),dateadd(dd,11,@bdate),dateadd(dd,12,@bdate),dateadd(dd,13,@bdate) from #bob order by accnt,arr


;