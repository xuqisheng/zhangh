drop proc p_xym_specials_forecast;
create proc p_xym_specials_forecast
   @s_time datetime,
   @e_time datetime

as
-- ------------------------------------------------------------------------
-- 系统维护程序之 #special
--
-- 维护单个账号
-- ------------------------------------------------------------------------

declare	
   @accnt      char(10),
	@specials   char(255),
	@dep			datetime,
	@sc			char(1),
   @in         int,
	@gcolno		int,
   @gcolno1    int,
	@gin			int,
	@gline		int,
   @ogline     int,
   @rein       int,
   @content    varchar(30),
   @code       char(3) 

create table #special
   (
   accnt    char(10) not null,
   name     varchar(50) not null,
   roomno   char(5),
   type     char(5),
   sta      char(10),
   vip      char(3),
   arr      datetime not null,
   dep      datetime not null,
   adl      integer,
   chl      integer,
   nights   integer,
   blkcode  char(10),
   company  varchar(200),
   specials varchar(255)
   )

insert #special select a.accnt,b.name,a.roomno,a.type,c.sta,b.vip,a.arr,a.dep,a.gstno,a.children,datediff(dd,a.arr,a.dep),a.blkcode,
c.cusno+'/'+c.agent+'/'+c.source,a.srqs from master a,guest b,master_des c 
where a.class='F' and a.haccnt=b.no and a.accnt=c.accnt and a.sta ='I'  and (rtrim(a.srqs)<> '' or rtrim(a.srqs) is not null )
and a.arr>=@s_time and a.arr<=@e_time
order by a.oroomno,a.accnt
declare c_special cursor for select accnt,specials+',' from #special order by accnt
open  c_special
fetch c_special into @accnt,@specials
while @@sqlstatus = 0
	begin
//	if exists(select 1 from master where accnt=@accnt and sta='I' and class='F' and substring(extra,9,1)='1')
//		update #special set sta='Walk In' where accnt=@accnt
//	else if exists(select 1 from master where accnt=@accnt and sta='I' and class in ('F','G','M') and datediff(dd,dep,getdate())=0)
//		update #special set sta='Due Out' where accnt=@accnt
//	else if exists(select 1 from master where accnt=@accnt and sta='I' and class in ('F','G','M') and datediff(dd,dep,getdate())=0 and datediff(dd,arr,getdate())=0)
//		update #special set sta='Day Use' where accnt=@accnt
//	else if exists(select 1 from master where accnt=@accnt and sta='I' and class in ('F','G','M'))
//		update #special set sta='Checked In' where accnt=@accnt
//	else if exists(select 1 from master where accnt=@accnt and sta='O' and class in ('F','G','M'))
//		update #special set sta='Checked Out' where accnt=@accnt
//	else if exists(select 1 from master where accnt=@accnt and sta='R' and class in ('F','G','M'))
//		update #special set sta='Expected' where accnt=@accnt
//	else if exists(select 1 from master where accnt=@accnt and sta='X' and class in ('F','G','M'))
//		update #special set sta='CANCELED' where accnt=@accnt
//	else if exists(select 1 from master where accnt=@accnt and sta='S' and class in ('F','G','M'))
//		update #special set sta='Suspend' where accnt=@accnt
//	else if exists(select 1 from master where accnt=@accnt and sta='N' and class in ('F','G','M'))
//		update #special set sta='No-Show' where accnt=@accnt
//	else if exists(select 1 from master where accnt=@accnt and sta='W' and class in ('F','G','M'))
//		update #special set sta='WaitList' where accnt=@accnt
//	else if exists(select 1 from master where accnt=@accnt and sta='D' and class in ('F','G','M'))
//		update #special set sta='L-C/O' where accnt=@accnt

      update #special set specials = '' where accnt = @accnt
      select @content = ''
      select @rein = 1
      while 1 = 1
          begin
          if @rein > 0
           begin
            select @gin =  charindex(',',@specials)
            select @rein = @gin
            if @gin = 0 
              break
            select @code = substring(@specials,1,@gin-1)
            select @content = descript1 from reqcode where code = @code
            update #special set specials = specials + ' # ' + @code + ' - ' + @content where accnt = @accnt
            select @specials = substring(@specials,@gin+1,255)
           end
          else 
           break
          end

	fetch c_special into @accnt,@specials
	end
close c_special
deallocate cursor c_special

select    name,
   roomno,
   type,
   sta,
   vip,
   arr,
   dep,
   adl,
   chl,
   nights,
   blkcode,
   substring(company,1,99),
   substring(substring(specials,2,255),3,99) from #special

;
exec p_xym_specials_forecast '2006.08.01','2006.09.30';