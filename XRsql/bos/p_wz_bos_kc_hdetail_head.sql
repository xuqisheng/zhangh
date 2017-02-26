if exists (select 1 from sysobjects where name = 'p_wz_bos_kc_hdetail_head')
	drop proc p_wz_bos_kc_hdetail_head;

create Proc  p_wz_bos_kc_hdetail_head
	@pccode0		varChar(5),
	@site0		varchar(5),
	@code0		varchar(8),
	@begin_		DateTime,
	@end_			DateTime

as
declare
	@ret 			integer,
	@msg 			varchar(60),
	@sysdate		datetime ,
	@charge		char(1)


create table #woutput
(		site			char(5),
		des			char(20),
		pccode 		char(5),
		code 			char(8),
		name1			char(20),
		standent		varchar(12)	default null,
		unit			char(4)		default null,
		provider		char(20),
		name2			char(20),
		begin_		datetime,
		end_			datetime,
		datediff		integer
)


select @charge = value from sysoption where catalog = 'house' and item = 'flr_roomno'

if @charge = 'T'
begin
	if not exists(select 1 from bos_site where site = @site0)
	begin
		insert #woutput(site,pccode,code,name1,standent,unit,provider,name2,begin_,end_,datediff)
			select @site0,@pccode0,a.code,a.name,isnull(a.standent,''),isnull(a.unit,''),a.provider,b.name,@begin_,@end_,datediff(day,@begin_,@end_) 
					from bos_plu a,bos_provider b where a.code	= @code0 and a.provider = b.accnt
		update #woutput	set des =	descript	from flrcode a where a.code = @site0 	and #woutput.site = a.code
	end
	else
		insert #woutput(site,des,pccode,code,name1,standent,unit,provider,name2,begin_,end_,datediff)
			select distinct c.site,c.descript,a.pccode,a.code,a.name,isnull(a.standent,''),isnull(a.unit,''),
				a.provider,b.name,@begin_,@end_,datediff(day,@begin_,@end_)
				from bos_plu a, bos_provider b, bos_site c
				where a.pccode = @pccode0 and a.code = @code0 and a.provider = b.accnt and c.site = @site0  
end
else
begin
	if not exists(select 1 from bos_site where site = @site0)
	begin
		insert #woutput(site,pccode,code,name1,standent,unit,provider,name2,begin_,end_,datediff)
			select @site0,@pccode0,a.code,a.name,isnull(a.standent,''),isnull(a.unit,''),a.provider,b.name,@begin_,@end_,datediff(day,@begin_,@end_) 
					from bos_plu a,bos_provider b where a.code	= @code0 and a.provider = b.accnt
		update #woutput	set des =a.roomno+ '·¿¼ä'	from rmsta a where a.roomno = @site0 	and #woutput.site = a.roomno
	end
	else
		insert #woutput(site,des,pccode,code,name1,standent,unit,provider,name2,begin_,end_,datediff)
			select distinct c.site,c.descript,a.pccode,a.code,a.name,isnull(a.standent,''),isnull(a.unit,''),
				a.provider,b.name,@begin_,@end_,datediff(day,@begin_,@end_)
				from bos_plu a, bos_provider b, bos_site c
				where a.pccode = @pccode0 and a.code = @code0 and a.provider = b.accnt and c.site = @site0  
end

			

select site,des,pccode,code,name1,standent,unit,provider,name2,begin_,end_,datediff from #woutput	                 

Return 0
;
