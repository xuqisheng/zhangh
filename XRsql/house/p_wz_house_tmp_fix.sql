//====================================================================
// Database Administration - 2.2.SYT SQL Server 4.x.foxhis6.dbo
// Reason: 
//--------------------------------------------------------------------
// Modified By: wz		Date: 2003.07.17
//--------------------------------------------------------------------
//临时房态的存储过程!!
//====================================================================
if exists (select 1 from sysobjects where  name = 'p_wz_house_tmp_fix')
	drop proc p_wz_house_tmp_fix;
create proc p_wz_house_tmp_fix
		@mode			char(1)     //根据modo = 1,2,3来判断是否是临时,非临时,所有

as
declare
		@msg			varchar(2)

create table #tmp(
		roomno		char(5) 			not null,
		tmpsta		char(1)		,
		type			varchar(4)	,
		sta			varchar(2)	,
		remark		varchar(60)		default '',
		descript		varchar(16)		default '' 
)
--all
if @mode = '3' 
begin
	insert #tmp(roomno,tmpsta,type,sta,remark)
	 	select b.roomno,b.tmpsta,a.type,a.ocsta +a.sta 'sta',b.remark  from rmsta a,rmtmpsta b
			where a.roomno = b.roomno 
	update #tmp	set #tmp.descript = c.descript	from rmtmpsta b,rmstalist1 c	
			where #tmp.roomno = b.roomno and b.tmpsta = c.code
end
--temp
if @mode = '1'
insert #tmp
 select b.roomno,b.tmpsta,a.type,a.ocsta +a.sta 'sta',b.remark,c.descript  from rmsta a,rmtmpsta b, rmstalist1 c 
		where a.roomno = b.roomno and b.tmpsta = c.code	and  b.tmpsta in(select code from rmstalist1)  
--not temp
if @mode = '2'
insert #tmp
 select b.roomno,b.tmpsta,a.type,a.ocsta +a.sta 'sta',b.remark,''  from rmsta a,rmtmpsta b
		where a.roomno = b.roomno and   b.tmpsta not in(select code from rmstalist1) 

select * from #tmp order by roomno

return 0;
