//--------------------------------------------------------------------
// Description: 主业务数据统计查询 语种的增加
//--------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_wz_gs_main_query" )
	drop proc p_wz_gs_main_query;
create proc p_wz_gs_main_query
	@code			char(1),
	@site			varchar(10),
	@item			char(3),
	@begin		datetime,
	@end			datetime,
	@empno		char(8),
	@language	integer,    //语种的设置   0:中文   2:英文
	@mode			char(1)		// 输出模式    0:时间   1:对象
as
declare
	@stype			varchar(10)	,
	@date				datetime,
	@datedes			varchar(30),
	@site_min		varchar(30),
	@item_min		char(3),
	@descript		varchar(40)


create table #woutput
(	col		varchar(30)  ,
	row		varchar(30)	 ,
	amount	money default 0
)

create table #gs_site
(	code		char(1),
	site		varchar(30)		not null,
	descript varchar(20)		not null
)


if @begin is not null
	select @date = @begin
else if @end is not null
	select @date = @end
else 
	select @date = bdate from sysdata

select @stype = site from gs_type where code = @code


if @language = 0
begin
	if @stype = 'OTH'
		insert #gs_site(code,site,descript) select @code,site,descript	from gs_site where code = @code
	else if @stype = 'ROOM'
		insert #gs_site(code,site,descript)	select @code,roomno,roomno from rmsta
	else if @stype	= 'FLR'
		insert #gs_site(code,site,descript) select @code,code,descript from flrcode
	else if @stype = 'HALL'
		insert #gs_site(code,site,descript) select @code,code,descript	from  basecode where cat = 'hall' 
end
else
begin
	if @stype = 'OTH'
		insert #gs_site(code,site,descript) select @code,site,descript1	from gs_site where code = @code
	else if @stype = 'ROOM'
		insert #gs_site(code,site,descript)	select @code,roomno,roomno from rmsta
	else if @stype	= 'FLR'
		insert #gs_site(code,site,descript) select @code,code,descript1 from flrcode
	else if @stype = 'HALL'
		insert #gs_site(code,site,descript) select @code,code,descript1 from  basecode where cat = 'hall' 

end
//time,item,amount
if @mode = "0"
begin
	insert #woutput(col,row,amount) select isnull(convert(char(10),a.date,11),'wz'),isnull(b.descript,'wz'),isnull(sum(a.amount),0)  from gs_rec a,gs_item b
		where b.code = a.code and b.item = a.item 
				and a.code = @code 
				and ( @begin <=a.date)
				and ( @end >=a.date)
				and (rtrim(@empno) is null or a.empno = @empno)
				and (rtrim(@site) is null or a.site = @site)
				and (rtrim(@item) is null or a.item = @item)
		group by a.date,b.descript

//add item
	if rtrim(@item) is null
	begin
		insert #woutput(col,row,amount) select convert(char(10),@date,11),isnull(descript,'wz'),0 from gs_item
			where code = @code and descript not in (select distinct row from #woutput)
		select @item_min = min(item) from gs_item where code = @code 
	
	end
//add time
	select @date = @begin,@descript = descript from gs_item where code = @code and item  = @item_min
	while @date <= @end
	begin
		select @datedes = convert(varchar(10),@date,11)
		if not exists(select 1 from #woutput where col = @datedes and row = @descript)
			insert #woutput(col,row,amount) select isnull(@datedes,'wz'),isnull(@descript,'wz'),0
		select @date = dateadd(dd,1,@date)
	end
end
else //site,item,amount
begin
	 insert #woutput(col,row,amount) select b.descript,c.descript,isnull(sum(a.amount),0)  from gs_rec a,#gs_site b,gs_item c
		where a.code = @code 
				and c.code = a.code and a.item = c.item 
				and b.code = a.code and b.site = a.site
				and (@begin is null or @begin <=a.date)
				and (@end is null or @end >=a.date)
				and (rtrim(@empno) is null or a.empno = @empno)
				and (rtrim(@site) is null or a.site = @site)
				and (rtrim(@item) is null or a.item = @item)
		group by b.descript,c.descript

//add item
	if rtrim(@item) is null
	begin
		if rtrim(@site) is null
			select @site_min = min(site) from #gs_site
		else
			select @site_min = isnull(@site,'wz')
		select @descript = descript from #gs_site where site = @site_min
		insert #woutput(col,row,amount) select @descript,descript,0 from gs_item
			where code = @code and descript not in (select distinct row from #woutput)
	end
//add site
	if rtrim(@site) is null
	begin
		if rtrim(@item) is null
			select @item_min = min(item) from gs_item where code = @code
		else
			select @item_min = isnull(@item,'wz')
		select @descript = descript from gs_item where code = @code and item = @item_min
		insert #woutput(col,row,amount) select descript,@descript,0 from #gs_site
			where descript not in(select distinct col from #woutput )
	
	end 
end 

select a.col,b.item+a.row,a.amount from #woutput a,gs_item b where b.code='B' and b.descript=a.row

return 0
;