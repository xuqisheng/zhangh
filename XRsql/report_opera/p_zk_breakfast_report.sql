if exists(select * from sysobjects where name = "p_zk_breakfast_report" and type ='P')
	drop proc p_zk_breakfast_report
;


create proc p_zk_breakfast_report
as
declare
	@roomno  varchar(8),
   @haccnt  char(40),
   @arr   datetime,
   @dep   datetime,
   @ratecode  varchar(8),
   @gstno   integer,
   @packages   char(50),
   @add_packages char(50),
   @packages_tmp char(50)
 
create table #ard_tmp
(
	roomno  varchar(8) null,
   haccnt  char(40) null,
   arr   datetime null,
   dep   datetime null,
   ratecode  varchar(8) null,
   gstno   integer null,
   package   char(50) null,
   add_package char(50) null
)

insert #ard_tmp select distinct a.roomno,b.haccnt,a.arr,a.dep,a.ratecode,a.gstno,a.packages,'' from master a,master_des b where a.haccnt=b.haccnt_o and a.sta='I' and a.roomno<>'' and a.packages<>'' order by roomno

declare c_cms cursor for select roomno,haccnt,arr,dep,ratecode,gstno,package from #ard_tmp
open c_cms
fetch c_cms into @roomno,@haccnt,@arr,@dep,@ratecode,@gstno,@packages
while @@sqlstatus = 0
begin
	select @packages_tmp = packages from rmratecode where halt='F' and rtrim(code)=rtrim(@ratecode)
   if rtrim(@packages_tmp)<>rtrim(@packages)
      begin
      select @packages_tmp=rtrim(@packages_tmp)
      select @packages=rtrim(@packages)
      --while datalength(rtrim(@packages_tmp))>1
       --  begin
       --  if charindex(substring(@packages_tmp,1,charindex(@packages_tmp,',') -1),@packages)<=0
       --     begin
       --     select substring(@packages_tmp,1,charindex(@packages_tmp,',') -1)
       --     return 1
       --     select @pack_tmp=@pack_tmp+substring(@packages_tmp,1,charindex(@packages_tmp,',') -1)+','
       --     end
       --  select @packages_tmp=substring(@packages_tmp,charindex(@packages_tmp,','),50)
      --   end
     -- select @pack_tmp=substring(@pack_tmp,1,datalength(@pack_tmp) -1)
      update  #ard_tmp set add_package=@packages_tmp where roomno=@roomno and haccnt=@haccnt
      end
   fetch c_cms into @roomno,@haccnt,@arr,@dep,@ratecode,@gstno,@packages
end

select * from #ard_tmp order by roomno
;