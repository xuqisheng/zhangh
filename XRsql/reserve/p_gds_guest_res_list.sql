if object_id('p_gds_guest_res_list') is not null
	drop  proc p_gds_guest_res_list
;
create  proc p_gds_guest_res_list
	@no    		char(7)
as
-------------------------------------------------------------------------------
--	某客户在当前的预订记录 -- 实际包括所有状态
-------------------------------------------------------------------------------

-- Create table 
create table #blocklist(
	accnt		char(10)				null,
	name		varchar(60)			null,
	sta		char(1)				null,
	arr		datetime				null,
	dep		datetime				null,
	type		char(5)				null,
	roomno	char(5)				null,
	quan		int					null,
	gstno		int					null,
	rate		money					null,
	company	varchar(250)		null,
	bal		money					null,
	crtby		char(10)				null,
	crttime	datetime				null	
)

-- Insert 1: fo 
insert #blocklist(accnt,sta,arr,dep,type,roomno,quan,gstno,rate,bal,crtby,crttime)
	select a.accnt,b.sta,a.begin_,a.end_,a.type,a.roomno,a.quantity,a.gstno,
			a.rate,b.charge-b.credit,b.resby,b.restime
		from rsvsrc a, master b
	where a.accnt=b.accnt 
		and (b.haccnt=@no or b.cusno=@no or b.agent=@no or b.source=@no)

insert #blocklist(accnt,sta,arr,dep,type,roomno,quan,gstno,rate,bal,crtby,crttime)
	select b.accnt,b.sta,b.arr,b.dep,b.type,b.roomno,b.rmnum,b.gstno,
			b.setrate,b.charge-b.credit,b.resby,b.restime
		from master b
	where b.sta not in ('R', 'I', 'D') and b.class in ('F', 'M', 'G')
		and (b.haccnt=@no or b.cusno=@no or b.agent=@no or b.source=@no)

-- Insert 2: sc 
--......


-- Insert 3: block  
--......


-- Update 
update #blocklist set name=a.haccnt, company=a.groupno+'/'+a.cusno+a.agent+a.source 
	from master_des a where #blocklist.accnt *= a.accnt
update #blocklist set crtby=a.ciby, crttime=a.citime
	from master a where #blocklist.accnt *= a.accnt

-- Output
select accnt,name,sta,arr,dep,type,roomno,quan,gstno,rate,company,bal,crtby,crttime
	from #blocklist order by arr

return 0
;
