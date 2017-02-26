drop procedure p_yjw_sc_revenue_forcast
;
create procedure p_yjw_sc_revenue_forcast
               @begin_ datetime,
               @end_   datetime,
               @type_  varchar(255)
as
declare
  @evtresno  char(10),
  @tmprevenue03  money,
  @tmprevenue04  money,
  @tmprevenue05  money,
  @tmprevenue06  money,
  @tmprevenue07  money,
  @code          char(10)


if @type_='%'
begin
  select @type_=''
  declare c_gettype cursor for select rtrim(code) from basecode where cat='evttype'
  open c_gettype
  fetch c_gettype into @code
  while @@sqlstatus=0
    begin
    	select @type_= rtrim(@type_)+','+@code
    	fetch c_gettype into @code
    end
  close c_gettype
  deallocate cursor c_gettype
end



--select指定时间段内的所有event,mone03--场租,mone04--食品,mone05--酒水,mone06--设备,mone07--总计
create table #tmp
  (
   char10_1 varchar(10),
  char99_1 varchar(99),
char10_2   varchar(10),
date01     datetime,
mone01     money,
mone02     money,
char99_2   varchar(99),
char10_3   varchar(10),
char99_3   varchar(99),
char99_4   varchar(99),
char99_5   varchar(99),
char99_6   varchar(99),
mone03     money,
mone04   money,
mone05   money,
mone06   money,
mone07   money,
)

insert
 #tmp select char10_1=a.account,char99_1=a.descript1,char10_2=a.evtresno,date01=a.begindate,
		 mone01=a.fattendees,  mone02=a.gattendees,
		 char99_2=b.name,char10_3=f.name2,char99_3  =  convert(varchar(99),c.descript1+'/'+c.descript2),char99_4=d.descript,char99_5=e.descript,char99_6=a.descript2,mone03=0,mone04=0,mone05=0,mone06=0,mone07=0 
from sc_eventreservation a,sc_master b,sc_spaces c,basecode d,basecode e,saleid f
where b.saleid=f.code and a.account=b.accnt and a.space=c.spaceid and (a.layout=d.code and d.cat='layoutstyle')
		and (a.eventtype=e.code and e.cat='evttype') and a.begindate>=@begin_ and a.enddate<=@end_ and charindex(a.eventtype,@type_)>0 and a.status<>'X'




select * into #tmp1 from #tmp

declare c_getevtno cursor for select char10_2 from #tmp1
open c_getevtno
fetch c_getevtno into @evtresno
while @@sqlstatus=0
  begin

    select @tmprevenue03=isnull(a.fprice,0)*(1+isnull(a.discount,0))*isnull(a.quantity,0) from sc_resourcreservation a,sc_resourcedetails b where a.rsid=b.rsid and a.resno=@evtresno and b.rsclsid='003'
    select @tmprevenue03=isnull(@tmprevenue03,0)+isnull(a.fprice,0) from sc_eventreservation a where a.evtresno=@evtresno
    update #tmp set mone03=isnull(@tmprevenue03,0) where char10_2=@evtresno

    select @tmprevenue04=isnull(a.fprice,0)*(1+isnull(a.discount,0))*isnull(a.quantity,0) from sc_resourcreservation a,sc_resourcedetails b where a.rsid=b.rsid and a.resno=@evtresno and b.rsclsid='001'
    update #tmp set mone04=isnull(@tmprevenue04,0) where char10_2=@evtresno

    select @tmprevenue05=isnull(a.fprice,0)*(1+isnull(a.discount,0))*isnull(a.quantity,0) from sc_resourcreservation a,sc_resourcedetails b where a.rsid=b.rsid and a.resno=@evtresno and b.rsclsid='004'
    update #tmp set mone05=isnull(@tmprevenue05,0) where char10_2=@evtresno

    select @tmprevenue06=isnull(a.fprice,0)*(1+isnull(a.discount,0))*isnull(a.quantity,0) from sc_resourcreservation a,sc_resourcedetails b where a.rsid=b.rsid and a.resno=@evtresno and b.rsclsid='002'
    update #tmp set mone06=isnull(@tmprevenue06,0) where char10_2=@evtresno

    select @tmprevenue07=@tmprevenue03+@tmprevenue04+@tmprevenue05+@tmprevenue06
    update #tmp set mone07=isnull(@tmprevenue07,0) where char10_2=@evtresno

    select @tmprevenue03=0,@tmprevenue04=0,@tmprevenue05=0,@tmprevenue06=0,@tmprevenue07=0
    fetch c_getevtno into @evtresno

  end
close c_getevtno
deallocate cursor c_getevtno
select * from #tmp;
