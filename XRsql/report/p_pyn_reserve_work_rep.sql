IF OBJECT_ID('dbo.p_pyn_reserve_work_rep') IS NOT NULL
    DROP PROCEDURE dbo.p_pyn_reserve_work_rep
;
create proc p_pyn_reserve_work_rep
	@begin		datetime,
	@end			datetime
as

declare
      @accnt		char(10)    ,
      @setrate		money	      ,
      @rmnum		int			,
      @gstno      int         ,
		@arr			datetime	   ,
		@dep			datetime	   ,
		@resby		char(10)		,
		@restime		datetime		,
		@ciby			char(10)		,
		@citime		datetime		,
		@coby			char(10)		,
		@cotime		datetime		,
		@depby		char(10)		,
		@deptime		datetime		,
		@cby			char(10)		,
		@changed		datetime

create table #workrep (
	empno  		char(10)			default '' 	not null,
	name			char(20)			default 0 	not null,
   deptno      char(3)        default '' 	not null,
   descript    varchar(40)    default '' 	not null,
   descript1   varchar(60)    default '' 	not null,
   checkin     money				default ''	not null,
   checkout    money				default 0 	not null,
   booking     money				default 0 	not null,
   departure   money				default 0 	not null
)

insert #workrep select a.empno,a.name,a.deptno,b.descript,b.descript1,0,0,0,0 from sys_empno a ,basecode b where a.deptno = b.code and b.cat='dept'

update #workrep set booking  = booking  + isnull((select sum(a.rmnum) from master  a where #workrep.empno = resby and a.bdate>=@begin and a.bdate<=@end and a.class in ('F','G','M')),0)
update #workrep set booking  = booking  + isnull((select sum(a.rmnum) from hmaster a where #workrep.empno = resby and a.bdate>=@begin and a.bdate<=@end and a.class in ('F','G','M')),0)
update #workrep set checkin  = checkin  + isnull((select count(1)     from master  a where #workrep.empno = ciby  and a.bdate>=@begin and a.bdate<=@end and a.class in ('F','G','M')),0)
update #workrep set checkin  = checkin  + isnull((select count(1)     from hmaster a where #workrep.empno = ciby  and a.bdate>=@begin and a.bdate<=@end and a.class in ('F','G','M')),0)
update #workrep set checkout = checkout + isnull((select count(1)     from master  a where #workrep.empno = coby  and a.bdate>=@begin and a.bdate<=@end and a.class in ('F','G','M')),0)
update #workrep set checkout = checkout + isnull((select count(1)     from hmaster a where #workrep.empno = coby  and a.bdate>=@begin and a.bdate<=@end and a.class in ('F','G','M')),0)
update #workrep set departure= departure+ isnull((select count(1)     from master  a where #workrep.empno = depby and a.bdate>=@begin and a.bdate<=@end and a.class in ('F','G','M')),0)
update #workrep set departure= departure+ isnull((select count(1)     from hmaster a where #workrep.empno = depby and a.bdate>=@begin and a.bdate<=@end and a.class in ('F','G','M')),0)

delete #workrep where checkout=0 and checkin=0 and booking=0 and departure =0
select deptno,descript,empno,name,checkin,checkout,booking,departure from #workrep
return 0
;
