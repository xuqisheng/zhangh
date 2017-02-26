drop proc p_wz_bos_kc_hdetail;
create Proc  p_wz_bos_kc_hdetail
	@pccode0		varChar(5),
	@site0		varchar(5),
	@code0		varchar(8),
	@begin_		DateTime,
	@end_			DateTime

as
declare
	@ret 			integer,
	@msg 			varchar(60),
	@sysdate		datetime

create table #bos_detail_temp
(	pccode      char(5)  		not null,
	site			char(5)			not null,
	code			char(8)			not null,
	id				char(6)			not null,
	ii				int				not null,
	flag			char(2)			not null,
	descript		varchar(20)	 		 null,
	folio			char(10)	 not null,
	sfolio		varchar(20)  		 null,
	fid			int 				default 0	not null,
	rsite			char(5)  		default '' not null,
	bdate			datetime			not null,
	act_date		datetime 		not null,
	log_date		datetime 		not null,
	empno			char(8)				 null,

	number		money	 			default 0	not null,
	amount0		money  			default 0	not null,
	amount		money  			default 0	not null,
	disc			money  			default 0	not null,
	profit		money  			default 0	not null,

	gnumber		money 		   default 0 	not null,
	gamount0		money  			default 0 	not null,
	gamount		money  			default 0 	not null,
	gprofit		money  			default 0 	not null,
	price0		money	 			default 0 	not null,
	price1		money  			default 0 	not null
	)

insert into #bos_detail_temp
	select pccode,site,code,id,ii,flag,descript,folio,sfolio,fid,rsite,bdate,act_date,log_date,empno,number,
		amount0,amount,disc,profit,gnumber,gamount0,gamount,gprofit,price0,price1 from bos_detail
	where datediff(day,@begin_, act_date) >= 0
	and datediff(day,act_date ,@end_) >= 0 and code like @code0+'%'
			and pccode = @pccode0 and site = @site0
	union
	select pccode,site,code,id,ii,flag,descript,folio,sfolio,fid,rsite,bdate,act_date,log_date,empno,number,
		amount0,amount,disc,profit,gnumber,gamount0,gamount,gprofit,price0,price1 from bos_hdetail
	where datediff(day,@begin_ , act_date) >= 0 and datediff(day, act_date,@end_) >= 0 and code like @code0+'%'
			and pccode = @pccode0 and site = @site0
	order by pccode,site,code,bdate


select ii,flag,bdate,act_date,descript,folio,sfolio,rsite,empno,
	number,amount0,amount,disc,profit,gnumber,gamount0,gamount,
	gprofit,price0,price1,pccode,site,code
from #bos_detail_temp
where  pccode = @pccode0 and  site = @site0
	and  code = @code0
order by act_date


Return 0;
