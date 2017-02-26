if exists(select * from sysobjects where name = "p_zk_arrival_detailed" and type ='P')
	drop proc p_zk_arrival_detailed
;


create proc p_zk_arrival_detailed

   @adate datetime,
   @ddate datetime

as
declare
	@roomno  char(8) ,
   @name  char(40) ,
   @company   char(40) ,
   @arr   datetime ,
   @dep   datetime ,
   @roomtype   char(10) ,
   @adults  integer ,
   @rmnum   integer ,
   @market   char(10) ,
   @src char(10) ,
   @resno   char(10) ,
   @vip   char(6) ,
   @prev integer ,
   @lastroom char(10) ,
   @car    char(10) ,
   @haccnt_o  char(10)
 
create table #ard
(
	roomno  varchar(8) null,
   name  char(40) null,
   company   char(40) null,
   arr   datetime null,
   dep   datetime null,
   roomtype   char(10) null,
   adults  integer null,
   child   integer null,
   rmnum   integer null,
   market   char(10) null,
   src char(10) null,
   resno   char(10) null,
   vip   char(6) null,
   prev integer null,
   lastroom char(10) null,
   car    char(10) null,
   haccnt_o   varchar(10) null
   
)

insert #ard select distinct a.roomno, b.haccnt, b.cusno,a.arr,a.dep ,a.type, a.gstno,a.children,a.rmnum,a.market,a.src,a.resno,c.vip,0,'',isnull(a.arrcar,''),a.haccnt from master a,master_des b,guest c where a.haccnt=b.haccnt_o and a.sta='R' and a.haccnt=c.no and a.class='F' and a.arr>=@adate and a.arr<=@ddate order by roomno
declare c_cms cursor for select haccnt_o from #ard order by roomno
open c_cms
fetch c_cms into @haccnt_o
while @@sqlstatus = 0
begin
   select @prev=count(*) -1 from master where rtrim(haccnt)=rtrim(@haccnt_o)
	select distinct @lastroom = roomno from master where rtrim(haccnt)=rtrim(@haccnt_o)  and sta<>'I' and sta<>'R' and arr = (select max(arr) from master where rtrim(haccnt)=rtrim(@haccnt_o)  and sta<>'I' and sta<>'R')
   if @lastroom=null select @lastroom=''  
   if @prev>0
      begin
      update #ard set prev=@prev,lastroom=@lastroom where rtrim(haccnt_o)=rtrim(@haccnt_o)
      end 
   fetch c_cms into @haccnt_o
end
select * from #ard
;

