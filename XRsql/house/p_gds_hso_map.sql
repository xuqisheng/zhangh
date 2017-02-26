if object_id('p_gds_hso_map') is not null
	drop proc p_gds_hso_map;

create proc p_gds_hso_map
	@gkey		varchar(10)
as
create table #map (
	site		char(5)	 		not null,
	number	integer 		default 0 	not null,
	ref		varchar(60)	default ''	null,
	accnt		char(10)		default '' 	not null,
	folio		char(10)		default '' 	not null
)
declare 	
	@rmuse 	char(1)

select @rmuse = rtrim(descript) from basecode where cat = 'res_sort' and code = lower(@gkey)
if @@rowcount=0
	begin
	select box='', site, number, ref,folio from #map order by site
	return 1
	end

if @rmuse = 'T'
	begin
	insert #map select roomno, 0, '','','' from rmsta

	update #map set number = isnull((select count(1) from res_av a,master b where #map.site = b.roomno and b.sta = 'I' and a.sta like '[RI]%' ),0)
	update #map set ref = 
		isnull((select isnull(b.roomno,'-') + '-' + a.haccnt from master_des a,master b 
			where a.accnt = b.accnt and b.accnt = (select min(accnt) from master c where c.sta = 'I' and c.roomno = #map.site)),'')
	update #map set number = -1, ref = '¿Í·¿Î¬ÐÞ' from rmsta a where a.roomno = #map.site and a.ocsta='V' and charindex(a.sta, 'R,D')=0 and #map.number=0
	end
else
	begin
	insert #map select resid, 0, '','','' from res_plu where lower(sortid) = lower(@gkey)

	update #map set number = isnull((select count(1) from res_av a where #map.site = a.resid and a.sta like '[RI]%' ),0)

	update #map set ref = 
		isnull((select isnull(a.roomno,'-') + '-' + a.haccnt from master a,master_des b where a.accnt = b.accnt and #map.accnt = a.accnt),'')

	update #map set folio = isnull((select min(a.folio) from res_av a where #map.site = a.resid),'')

//	update #map set ref = (select isnull(a.roomno,'-')+'-'+a.name from hso_folio a where a.folio=(select min(b.folio) from hso_folio b where b.sta='I' and b.site=#map.site))

	update #map set number = -1, ref= a.summary from res_ooo a where a.resid = #map.site and a.sta = 'B' and #map.number = 0
	end

select box='', site, number, ref,folio from #map order by site

return 0;

