
if exists(select 1 from sysobjects where name = "p_gds_master_list_for_addman")
	drop proc p_gds_master_list_for_addman;
create proc p_gds_master_list_for_addman
	@pc_id		char(4)
as
----------------------------------------------------------------------------------------------
--		需要往主单加人的订单列表。 用作 dw 数据源  
--		每间客房只能显示一行 
----------------------------------------------------------------------------------------------
declare		@sta		char(1),
				@class	char(1)

create table #glist (
	accnt		char(10)		not null,
	sta		char(1)		not null,
	name		varchar(50)	null,
	type		char(5)		null,
	roomno	char(5)		null,
	gstno		int			null,
	done		char(1)		null,
	gindex	int			null,
	saccnt	char(10)		null,
	checkin	char(1)		null,
	arr		datetime		null,
	dep		datetime		null 
)

insert #glist select a.accnt, b.sta, c.name, b.type, b.roomno, b.gstno, 'F', 0, b.saccnt, b.sta, b.arr,b.dep  
	from selected_account a, master b, guest c  
		where a.type='g' and a.pc_id=@pc_id and a.mdi_id=0 
			and a.accnt=b.accnt and b.haccnt=c.no and b.class='F' and b.sta in ('R', 'I')

-- 每个房间保留一条记录 
update #glist set gindex=(select count(1) from #glist a where #glist.roomno=a.roomno and #glist.accnt>=a.accnt) 
	where #glist.roomno<>'' 
delete #glist where gindex>1  

-- 计算现有人数 
update #glist set gstno = isnull((select sum(a.gstno) from master a where #glist.saccnt=a.saccnt), 0) 

select accnt,sta,name,type,roomno,gstno,done,checkin,arr,dep from #glist order by roomno, type 

return 0
;

