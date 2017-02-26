if exists(select 1 from sysobjects where name='p_yjw_reserve_upselling' and type='P')
drop procedure p_yjw_reserve_upselling
;
create procedure p_yjw_reserve_upselling


as

declare @oldtype varchar(10),
        @empno   varchar(20),
        @oldrmrate money,
        @newrmrate money,
        @ratediff  money

create table #upselling
(
  roomno   char(5),
  name     varchar(50),
  type     char(3),
  oldtype  char(3),
  setrate  money,
  oldrate  money,
  newrate  money,
  ratediff money,
  ratecode char(10),
  arr      datetime,
  dep      datetime,
  unit     varchar(100),
  ref      varchar(255),
  empno    varchar(20)

)

insert #upselling select a.roomno,b.name,a.type,'',a.setrate,0,0,0,a.ratecode,a.arr,a.dep,
char991  =  c.groupno+'/'+c.cusno+c.agent+c.source,a.ref,'' 
from master a,guest b,master_des c where a.class='F' and a.haccnt=b.no and a.accnt=c.accnt and a.sta ='I' and a.srqs like '%UPS%' order by a.oroomno,a.accnt
update #upselling set oldtype=substring(ref,isnull(charindex('=',ref),0)+1,isnull(charindex(',',ref),0)-isnull(charindex('=',ref),0)-1)

update #upselling  set oldrate=a.rate from typim a where oldtype=a.type 
update #upselling  set newrate=a.rate from typim a where #upselling.type=a.type 
update #upselling  set ratediff=(newrate-oldrate)
update #upselling  set ratediff=(newrate-oldrate)
update #upselling  set empno=substring(ref,isnull(charindex(',',ref),0)+1,isnull(charindex(';',ref),0) - isnull(charindex(',',ref),0) -1)

select roomno,name,type,oldtype,setrate,oldrate,newrate,ratediff,ratecode,arr,dep,unit,empno from #upselling
;

