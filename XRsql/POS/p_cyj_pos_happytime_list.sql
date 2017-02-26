if exists(select 1 from sysobjects where name = 'p_cyj_pos_happytime_list' and type = 'P')
	drop proc p_cyj_pos_happytime_list;
create proc p_cyj_pos_happytime_list
	@pc_id				char(3),               
	@date					datetime,
	@shift				char(1)
as
-----------------------------------------------------------
-- 查询欢乐时光菜，输入站点日期班别, 输出符合条件的菜品列表
-----------------------------------------------------------

create table #plu(
	pccodes		char(20),        -- 餐厅
	plucodes		char(30),        -- 菜本描述
	sorts			char(30),        -- 菜类描述
	id				int,
	descript		char(30),        -- 菜名
	unit			char(4),
	inumber		int,             -- pos_price.inumber
	nprice		money,           -- pos_price.price
	oprice		money,           -- pos_happytime.price
	cost			money,
	code			char(3)          -- 时段码 
)
declare
	@pccodes		char(3),
	@code			char(3),
	@week			char(1),
	@day			char(5)


select @pccodes = pccodes from pos_station where pc_id = @pc_id
insert into #plu select '','','',id,'','',inumber,0,0,0,code from pos_happytime

select @week = convert(char(1),datepart(dw,@date))
select @day  = substring(convert(char(8),@date,1), 1, 5)
select @code = ''
delete #plu where code not in(select code from pos_season where (charindex(@week, week)>0 or charindex(@day, day)>0) and begin_ < getdate() and end_ > getdate() and (charindex(@shift, shift)>0 or shift ='0'))
update #plu set pccodes = b.pccode, oprice = b.price, cost = b.cost from #plu a, pos_price b where a.id = b.id and a.inumber = b.inumber
update #plu set pccodes = b.pccode, oprice = b.price, cost = b.cost from #plu a, pos_price b where a.id = b.id and a.inumber = b.inumber
select pccodes, plucodes, sorts, descript, unit,nprice,oprice,cost FROM #plu order by inumber
;

