
/* -----------------------------------------------------------------------------------------------
	p_gds_master_wait_list: Wait-list 显示
----------------------------------------------------------------------------------------------- */
if  exists(select * from sysobjects where name = "p_gds_master_wait_list")
	 drop proc p_gds_master_wait_list;
create proc p_gds_master_wait_list
   @date		datetime,
	@name		varchar(50)
as

if rtrim(@name) is null
	select @name = '%'

create table #goutput (
	accnt			char(10)						not null,
	class			char(1)						not null,
	haccnt		char(7)						not null,
	name			varchar(60)	default '' 	null,
	type			char(5)						not null,
	rmnum			int			default 0	not null,
	roomno		char(5)		default ''	not null,
	gstno			int			default 0	not null,
	rate			money			default 0	not null,
	arr			datetime						null,
	dep			datetime						null,
	market		char(3)		default ''	not null,
	src			char(3)		default ''	not null,
	channel		char(3)		default ''	not null,
	crttime		datetime						null,
	priority		char(1)		default '' 	null,
	back			int			default 0	not null		 -- 是否可以恢复
)

insert #goutput 
	select a.accnt,a.class,a.haccnt,b.name,a.type,a.rmnum,a.roomno,a.gstno,a.setrate,
		a.arr,a.dep,a.market,a.src,a.channel,a.restime,d.priority,0
	from master a, guest b, master_hung d 
	where a.sta='W' and a.haccnt=b.no and a.accnt=d.accnt and d.status='I'
		and datediff(dd,@date,a.arr)>=0
		and b.name like @name

select * from #goutput order by arr, priority desc, crttime

return 0
;
