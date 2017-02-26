
IF OBJECT_ID('p_gds_sc_guest_res_list') IS NOT NULL
    DROP PROCEDURE p_gds_sc_guest_res_list
;
create  proc p_gds_sc_guest_res_list
	@no    		char(7)
as

-- Create table
create table #blocklist(
	accnt		char(10)				null,
	name		varchar(60)			null,
	sta		char(1)				null,
	arr		datetime				null,
	dep		datetime				null,
	quan		int					null,
	gstno		int					null,
	rate		money					null,
	company	varchar(250)		null,
	crtby		char(10)				null,
	crttime	datetime				null
)

-- Insert
insert #blocklist(accnt,name,sta,arr,dep,quan,gstno,rate,crtby,crttime)
	select b.accnt,name,b.sta,b.arr,b.dep,b.rmnum,b.gstno,b.setrate,b.resby,b.restime
		from sc_master b
	where b.sta = 'R' and (b.haccnt=@no or b.cusno=@no or b.agent=@no or b.source=@no)

-- Update
update #blocklist set company=a.groupno+'/'+a.cusno+a.agent+a.source
	from master_des a where #blocklist.accnt *= a.accnt

-- Output
select accnt,name,sta,arr,dep,quan,gstno,rate,company,crtby,crttime
	from #blocklist order by arr

return 0
;
