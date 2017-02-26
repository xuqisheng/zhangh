-------------------------------------------------------------
--- 会议总单数据窗口显示客房数, 	p_hxw_mtmain_2
-------------------------------------------------------------

if exists (select 1 from sysobjects where name = 'p_hxw_mtmain_2'  and type = 'P')
   drop procedure p_hxw_mtmain_2
;

create procedure  p_hxw_mtmain_2
  @accnt char(10)
as

declare 
       @ll_row   integer,
       @ll_con   integer,
       @i        integer

create table #rsvdtl
(
   accnt     char(10)  null,
	type      char(5)  null,
	blkmark   char(1)null,
	begin_    datetime null,
	end_      datetime null,
	quantity  int      null,
   descript  varchar(50) null,
	rate      money       null 
)

insert into #rsvdtl
	select accnt,type,blkmark,begin_,end_,quantity,remark,rate from  rsvsrc where accnt = @accnt
insert into #rsvdtl
	select accnt,type,'',arr,dep,rmnum,'',rmrate from master where groupno = @accnt

select @ll_row = count(*) from #rsvdtl 
delete #rsvdtl where quantity  = 0 
select @i =1 
if @ll_row <= 4 
begin

	select @ll_con = 4 - @ll_row
	
	while @i <= @ll_con
		begin
			insert into #rsvdtl(accnt,type,blkmark,begin_,end_,quantity)
				values(@accnt,'',null,null,null,null)
			select @i = @i + 1
	end
end
select accnt,type,blkmark,begin_,end_,quantity,descript,rate  
from #rsvdtl  
where quantity <> 0 or quantity = null 
order by type desc
;
exec p_hxw_mtmain_2 'F308290039';