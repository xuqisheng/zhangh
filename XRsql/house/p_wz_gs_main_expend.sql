//====================================================================
// Database Administration - 2.2.SYT SQL Server 4.x.foxhis1.dbo
// Reason: 
//--------------------------------------------------------------------
// Modified By: mike wang		Date: 2004.06.04
//--------------------------------------------------------------------
// 清洁员工作量查询
//====================================================================

if exists (select 1 from sysobjects where name = 'p_wz_gs_main_expend')
	drop proc p_wz_gs_main_expend;

create proc p_wz_gs_main_expend
	@code			char(1),
	@site			varchar(10),
	@item			char(3),
	@begin		datetime,
	@end			datetime,
	@empno		char(10),
	@language	integer,
	@mode			char(1)
as

declare	@date_in		datetime,
			@sitedes		varchar(10),
			@itemdes		varchar(10),
			@site_min 	varchar(10)
			

create table #woutput
(
	col		varchar(10),
	row		varchar(30),
	amount	money			default 0 ,
	value 	money 		default 0 ,
	total    money       default 0
)

create table #gs_rec_temp
(	date		datetime	  ,
	code		char(1)	  ,
	site		varchar(10),
	item		char(3)	  ,
	empno		char(10)	  ,	
	descript	varchar(30) default '',
	amount	money	   default 0 ,
	value		money		default 0 ,
	mode		char(1)	default ''
)



--根据模式0/1来决定crosstab的显示
if @mode = '0'  
	begin
	--根据时间插入所需要的数据
		insert #gs_rec_temp (date,code,site,item,empno,amount) 
			 select a.date,a.code,b.site,a.item,a.empno,a.amount from gs_rec a ,gs_site b
				 where  a.code = b.code and a.site = b.site
						and a.code = @code 
						and (@begin is null or a.date>= @begin )
						and (@end is null   or   a.date <= @end )
						and (rtrim(@empno) is null)
						and (rtrim(@item) is null or a.item = @item)
						and (rtrim(@site) is null or a.site = @site)	
		if rtrim(@item) is null
		insert #gs_rec_temp (date,code,site,item,empno,amount) 
				select a.date,a.code,a.site,b.item,a.empno, 0 from #gs_rec_temp a,gs_item b	  
						where a.code =b.code 
								and a.code = @code
								and a.item <> b.item

		update #gs_rec_temp set descript =  isnull(a.descript,'wz'),value = a.value from gs_item a
		  		where #gs_rec_temp.code = a.code and #gs_rec_temp.item = a.item
	
		insert #woutput select convert(char(10),date,11),descript,sum(amount),avg(value),sum(amount*value)  from #gs_rec_temp group by  date,descript
	end
else
	begin
--根据时间插入所需要的数据
		insert #gs_rec_temp (date,code,site,item,empno,amount) 
			 select a.date,a.code,b.site,a.item,a.empno,a.amount from gs_rec a ,gs_site b
				 where  a.code = b.code and a.site = b.site
						and a.code = @code 
						and (@begin is null or a.date>= @begin )
						and (@end is null   or   a.date <= @end )
						and (rtrim(@empno) is null)
						and (rtrim(@item) is null or a.item = @item)
						and (rtrim(@site) is null or a.site = @site)
		
		insert #gs_rec_temp (date,code,site,item,empno,amount) 
			 select a.date,a.code,b.site,a.item,a.empno,0 from gs_rec a ,gs_site b
				 where  a.code = b.code and a.site = b.site
						and a.code = @code 
						and b.site not in (select distinct site from #gs_rec_temp)
						and (rtrim(@empno) is null)
						and (rtrim(@item) is null or a.item = @item)
						and (rtrim(@site) is null or a.site = @site)
		if rtrim(@item) is null
		insert #gs_rec_temp (date,code,site,item,empno,amount) 
				select a.date,a.code,a.site,b.item,a.empno, 0 from #gs_rec_temp a,gs_item b	  
						where a.code =b.code 
								and a.code = @code
								and a.item <> b.item
	
		update #gs_rec_temp set descript =  isnull(a.descript,'wz'),value = a.value from gs_item a
			  where #gs_rec_temp.code = a.code and #gs_rec_temp.item = a.item

		insert #woutput select site,descript,sum(amount),avg(value),sum(amount*value) from #gs_rec_temp group by site,descript	 
	end

select * from #woutput

return 0;