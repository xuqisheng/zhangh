if object_id('p_sc_sheet_headbyds') is not null
drop proc p_sc_sheet_headbyds
;
create procedure p_sc_sheet_headbyds
                 @accnt char(10),
                 @evtresno char(10),
                 @date  datetime,
                 @enddate datetime
as
declare
      @cusno_o   char(7),
      @agent_o   char(7),
      @source_o  char(7)

create table #sheethead
(
  title   varchar(50) null,
  account varchar(255) null,
  status  varchar(10) null,
  coname  varchar(20) null,
  paycode varchar(10) null,
  street  varchar(100) null,
  city    varchar(20) null,
  phone   varchar(15) null,
  fax     varchar(15) null,
  sname   varchar(30) null,
  arrdep  varchar(30) null,
  market  varchar(10) null,
  infoboard varchar(50) null,
  repname varchar(50) null,
  bdate   datetime  null,
  name    varchar(50)
)


select @cusno_o=cusno_o,@agent_o=agent_o,@source_o=source_o from master_des where accnt=@accnt

if @cusno_o<>'' and @cusno_o is not null
   insert #sheethead select
       char30=datename(weekday,@date)+","+convert(varchar,@date,107)+'--'+datename(weekday,@enddate)+","+convert(varchar,@enddate,107),
       char99=a.cusno+a.agent+a.source,
       b.c_status,
       c.name,
       h.descript1,
       e.street,
       e.city,
       e.phone,
       e.fax,
       rtrim(d.name2)+'/'+rtrim(f.name2),
       char20=convert(varchar,b.arr,110)+'/'+convert(varchar,b.dep,110),
       b.market,
       b.c_infoboard,
       g.name2,
       getdate(),
       b.name
       from master_des a,sc_master b,guest c,saleid d,guest e,saleid f,saleid g,pccode h
       where a.accnt=b.accnt and b.contact*=c.no and b.saleid*=d.code and (e.no=*a.cusno_o) and b.accnt=@accnt and b.c_saleid*=f.code and b.saleid2*=g.code
             and h.pccode=*b.paycode
else if @agent_o<>'' and @agent_o is not null
    insert #sheethead select
       char30=datename(weekday,@date)+","+convert(varchar,@date,107),
       char99=a.cusno+a.agent+a.source,
       b.c_status,
       c.name,
       b.paycode,
       e.street,
       e.city,
       e.phone,
       e.fax,
       rtrim(d.name2)+'/'+rtrim(f.name2),
       char20=convert(varchar,b.arr,110)+'/'+convert(varchar,b.dep,110),
       b.market,
       b.c_infoboard,
       g.name2,
       getdate(),
       b.name
       from master_des a,sc_master b,guest c,saleid d,guest e,saleid f,saleid g,pccode h
       where a.accnt=b.accnt and b.contact*=c.no and b.saleid*=d.code and (e.no=*a.agent_o) and b.accnt=@accnt and b.c_saleid*=f.code and b.saleid2*=g.code
             and h.pccode=*b.paycode
else if @source_o<>'' and @source_o is not null
    insert #sheethead select
       char30=datename(weekday,@date)+","+convert(varchar,@date,107),
       char99=a.cusno+a.agent+a.source,
       b.c_status,
       c.name,
       h.descript1,
       e.street,
       e.city,
       e.phone,
       e.fax,
       rtrim(d.name2)+'/'+rtrim(f.name2),
       char20=convert(varchar,b.arr,110)+'/'+convert(varchar,b.dep,110),
       b.market,
       b.c_infoboard,
       g.name2,
       getdate(),
       b.name
       from master_des a,sc_master b,guest c,saleid d,guest e,saleid f,saleid g,pccode h
       where a.accnt=b.accnt and b.contact*=c.no and b.saleid*=d.code and (e.no=*a.source_o) and b.accnt=@accnt and b.c_saleid*=f.code and b.saleid2*=g.code
            and h.pccode=*b.paycode

select *,@accnt,@evtresno,@date,@enddate from #sheethead
;