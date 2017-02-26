if  exists(select * from sysobjects where name = "p_gds_rep_cms_summary")
	drop proc p_gds_rep_cms_summary;
create proc p_gds_rep_cms_summary
	@cno				char(10),
	@dbegin			datetime,
	@dend				datetime,
	@pc_id			char(4)='' 
as
----------------------------------------------------------------------------------
-- 佣金汇总报表 
----------------------------------------------------------------------------------

-- parms 
if rtrim(@cno) is null or @cno='' 
	select @cno='%' 
if @dbegin is null 
	select @dbegin='1960.1.1'
if @dend is null 
	select @dend='2048.1.1'
select @pc_id=isnull(rtrim(@pc_id), 'pcid') 

-- table ready 
delete statistic_p where pc_id=@pc_id 

-- create list 
insert statistic_p(pc_id,cat,grp,code,amount25,amount26,
			amount01,amount02,amount03,amount04,
			amount06,amount07,amount08,amount09,
			amount11,amount12,amount13,amount14) 
	select @pc_id, belong, 'L', isaudit, 0, ispaied, 
			rmrate, netrate, w_or_h, cms0, -- 房费，净房费，房晚，佣金 
			rmrate, netrate, w_or_h, cms0, 
			rmrate, netrate, w_or_h, cms0
		from cms_rec 
			where belong like @cno and sta='I' 
				and bdate>=@dbegin and bdate<=@dend 
update statistic_p set amount25=1 where pc_id=@pc_id and code='T' 
update statistic_p set amount26=1 where pc_id=@pc_id and amount26>0  

-- create summary 
insert statistic_p(pc_id,cat,grp,
			amount01,amount02,amount03,amount04,
			amount06,amount07,amount08,amount09,
			amount11,amount12,amount13,amount14) 
	select @pc_id, cat, 'S',
			sum(amount01), sum(amount02), sum(amount03), sum(amount04),  													-- 发生 
			sum(amount25*amount01), sum(amount25*amount02), sum(amount25*amount03), sum(amount25*amount04), 	-- 审核
			sum(amount26*amount01), sum(amount26*amount02), sum(amount26*amount03), sum(amount26*amount04)		-- 支付 
		from statistic_p where pc_id=@pc_id and grp='L' group by cat 


return 0
;
