if exists(select * from sysobjects where name = "p_zk_room_plan" and type ='P')
	drop proc p_zk_room_plan
;

create proc p_zk_room_plan
   
as
declare
   @room   char(5) ,
   @type  char(8) ,
   @status   char(2) ,
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
   @sta   char(1),
   @name   char(10),
   @bdate   datetime,
   @arr   datetime,
   @dep  datetime
   
 
create table #bob
(
	room   char(5) null,
   type  char(8) null,
   status   char(2) null,
   d1     char(10) null,
   d2     char(10) null,
   d3     char(10) null,
   d4      char(10) null,
   d5     char(10) null,
   d6     char(10) null,
   d7   char(10) null,
   d8   char(10) null,
   d9   char(10) null,
   d10    char(10) null,
   d11  char(10) null,
   d12   char(10) null,
   d13   char(10) null,
   d14    char(10) null
)

select @bdate = bdate1 from sysdata
insert #bob select distinct roomno,type,char10=(select eccocode from rmstamap where code=(rmsta.ocsta+rmsta.sta)),'','','','','','','','','','','','','','' from rmsta    order by roomno
--delete from #bob where status='OO'
--select * from #bob
--return 
select @day=0


declare c_cms cursor for select room from #bob order by room

declare d_rms cursor for select b.name,a.arr,a.dep from master a, guest b 
        where a.haccnt=b.no and ltrim(rtrim(a.roomno)) = ltrim(rtrim(@tmprm)) and a.sta in ('I', 'R') and datediff(dd,@bdate,a.dep)>=-1

--declare d_rms cursor for select code from phcoden
--declare d_rm cursor for select master_des.haccnt,master.arr,master.dep from master_des,master where master_des.haccnt_o=master.haccnt and rtrim(master.roomno)=rtrim(@tmprm) and @bdate<=master.dep order by master.arr
open c_cms
fetch c_cms into @tmprm
while @@sqlstatus = 0 
   begin
  -- return 10
   open d_rms
   fetch d_rms into @name,@arr,@dep
   --return @@sqlstatus
   --select @name=b.name,@arr=a.arr,@dep=a.dep from master a, guest b 
        --where a.haccnt=b.no and ltrim(rtrim(a.roomno)) = ltrim(rtrim(@tmprm)) and a.sta in ('I', 'R') and datediff(dd,@bdate,a.dep)>=-1
   while @@sqlstatus = 0 
      begin
      if @bdate>=@arr and @bdate<=@dep
         update #bob set d1=@name where room=@tmprm
      if dateadd(dd,1,@bdate)>=@arr and dateadd(dd,1,@bdate)<=@dep
         update #bob set d2=@name where room=@tmprm
      if dateadd(dd,2,@bdate)>=@arr and dateadd(dd,2,@bdate)<=@dep
         update #bob set d3=@name where room=@tmprm
      if dateadd(dd,3,@bdate)>=@arr and dateadd(dd,3,@bdate)<=@dep
         update #bob set d4=@name where room=@tmprm
      if dateadd(dd,4,@bdate)>=@arr and dateadd(dd,4,@bdate)<=@dep
         update #bob set d5=@name where room=@tmprm
      if dateadd(dd,5,@bdate)>=@arr and dateadd(dd,5,@bdate)<=@dep
         update #bob set d6=@name where room=@tmprm
      if dateadd(dd,6,@bdate)>=@arr and dateadd(dd,6,@bdate)<=@dep
         update #bob set d7=@name where room=@tmprm
      if dateadd(dd,7,@bdate)>=@arr and dateadd(dd,7,@bdate)<=@dep
         update #bob set d8=@name where room=@tmprm
      if dateadd(dd,8,@bdate)>=@arr and dateadd(dd,8,@bdate)<=@dep
         update #bob set d9=@name where room=@tmprm
      if dateadd(dd,9,@bdate)>=@arr and dateadd(dd,9,@bdate)<=@dep
         update #bob set d10=@name where room=@tmprm
      if dateadd(dd,10,@bdate)>=@arr and dateadd(dd,10,@bdate)<=@dep
         update #bob set d11=@name where room=@tmprm
      if dateadd(dd,11,@bdate)>=@arr and dateadd(dd,11,@bdate)<=@dep
         update #bob set d12=@name where room=@tmprm
      if dateadd(dd,12,@bdate)>=@arr and dateadd(dd,12,@bdate)<=@dep
         update #bob set d13=@name where room=@tmprm
      if dateadd(dd,13,@bdate)>=@arr and dateadd(dd,13,@bdate)<=@dep
         update #bob set d14=@name where room=@tmprm
      select @day=@day+1
      fetch d_rms into @name,@arr,@dep
      end
   select @arr=dbegin,@dep=dend from rm_ooo where rtrim(roomno)=rtrim(@tmprm)
   if @arr<>'' 
      begin
      if @bdate>=@arr and @bdate<=@dep
         update #bob set d1='OO HU' where room=@tmprm
      if dateadd(dd,1,@bdate)>=@arr and dateadd(dd,1,@bdate)<=@dep
         update #bob set d2='OO HU' where room=@tmprm
      if dateadd(dd,2,@bdate)>=@arr and dateadd(dd,2,@bdate)<=@dep
         update #bob set d3='OO HU' where room=@tmprm
      if dateadd(dd,3,@bdate)>=@arr and dateadd(dd,3,@bdate)<=@dep
         update #bob set d4='OO HU' where room=@tmprm
      if dateadd(dd,4,@bdate)>=@arr and dateadd(dd,4,@bdate)<=@dep
         update #bob set d5='OO HU' where room=@tmprm
      if dateadd(dd,5,@bdate)>=@arr and dateadd(dd,5,@bdate)<=@dep
         update #bob set d6='OO HU' where room=@tmprm
      if dateadd(dd,6,@bdate)>=@arr and dateadd(dd,6,@bdate)<=@dep
         update #bob set d7='OO HU' where room=@tmprm
      if dateadd(dd,7,@bdate)>=@arr and dateadd(dd,7,@bdate)<=@dep
         update #bob set d8='OO HU' where room=@tmprm
      if dateadd(dd,8,@bdate)>=@arr and dateadd(dd,8,@bdate)<=@dep
         update #bob set d9='OO HU' where room=@tmprm
      if dateadd(dd,9,@bdate)>=@arr and dateadd(dd,9,@bdate)<=@dep
         update #bob set d10='OO HU' where room=@tmprm
      if dateadd(dd,10,@bdate)>=@arr and dateadd(dd,10,@bdate)<=@dep
         update #bob set d11='OO HU' where room=@tmprm
      if dateadd(dd,11,@bdate)>=@arr and dateadd(dd,11,@bdate)<=@dep
         update #bob set d12='OO HU' where room=@tmprm
      if dateadd(dd,12,@bdate)>=@arr and dateadd(dd,12,@bdate)<=@dep
         update #bob set d13='OO HU' where room=@tmprm
      if dateadd(dd,13,@bdate)>=@arr and dateadd(dd,13,@bdate)<=@dep
         update #bob set d14='OO HU' where room=@tmprm
      end
   select @day=0,@arr='',@dep=''
   close d_rms
   fetch c_cms into @tmprm
   end
deallocate cursor d_rms
close c_cms
deallocate cursor c_cms


select room,type,status,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,@bdate,dateadd(dd,1,@bdate),dateadd(dd,2,@bdate),dateadd(dd,3,@bdate),dateadd(dd,4,@bdate),dateadd(dd,5,@bdate),dateadd(dd,6,@bdate),dateadd(dd,7,@bdate),dateadd(dd,8,@bdate),dateadd(dd,9,@bdate),dateadd(dd,10,@bdate),dateadd(dd,11,@bdate),dateadd(dd,12,@bdate),dateadd(dd,13,@bdate) from #bob order by room
;
