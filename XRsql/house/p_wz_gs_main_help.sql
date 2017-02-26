//====================================================================
// 		w_wz_gs_main 数据中帮助查询
//====================================================================

if exists(select 1 from sysobjects where name = "p_wz_gs_main_help" )
	drop proc p_wz_gs_main_help;
create proc p_wz_gs_main_help
	@code		char(1),
	@type		char(4),
	@langid	integer   --0 chinese    2 english
as

if @langid = 0
begin
	if @type = 'site'
	begin
			select tag = '#',des = '所有'
		union
			select tag = a.site,des = a.descript from gs_site a,gs_type b 
				where a.code = @code and a.code = b.code and b.site = 'OTH'
		union
			select tag =roomno,des = roomno 	from rmsta a
				where exists(select 1 from gs_type where code = @code and site = 'ROOM')
		union
			select tag =code,des = descript 	from flrcode 
				where exists(select 1 from gs_type where code = @code and site = 'FLR')
		union
			select tag =code,des = descript 	from basecode 
				where cat = 'hall' and exists(select 1 from gs_type where code = @code and site = 'HALL')
		order by tag
	end
	else if @type = 'item'
		select tag = '#',des = '所有'
	  union
		select tag = item,des = descript from gs_item where code = @code
	else if @type = 'mode'
		select tag = '#',des = '所有'
	 union
		select tag = code,des = descript from gs_list 
end		
else
begin 
	if @type = 'site'
	begin
			select tag = '#',des = 'All'
		union
			select tag = a.site,des = a.descript1 from gs_site a,gs_type b 
				where a.code = @code and a.code = b.code and b.site = 'OTH'
		union
			select tag =roomno,des = roomno 	from rmsta 
				where exists(select 1 from gs_type where code = @code and site = 'ROOM')
		union
			select tag =code,des = descript1 from flrcode 
				where exists(select 1 from gs_type where code = @code and site = 'FLR')
		union
			select tag =code,des = descript1 from basecode 
				where cat = 'hall' and exists(select 1 from gs_type where code = @code and site = 'HALL')
		order by tag
	end
	else if @type = 'item'
		select tag = '#',des = 'All'
	  union
		select tag = item,des = descript from gs_item where code = @code
	else if @type = 'mode'
		select tag = '#',des = 'All'
	 union
		select tag = code,des = descript from gs_list 
end

return 0 ;







	