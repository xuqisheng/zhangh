--------------------------------------------------------------------------------
--		bos 库存平衡表    --------   商场
--------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_gds_bos_kcbal')
	drop proc p_gds_bos_kcbal;
create proc  p_gds_bos_kcbal
	@pccode		char(5),
	@id			char(6) = '',
	@tag			char(2) = '',
	@class		char(1) = '',
	@site			char(5) = '',
	@code			varchar(8) = '',
	@mode			varchar(6) = ''			-- m-去掉明细 g-纯柜台 s-纯类别 z-合计
as
declare 	@ret		int,
			@ii		int,
			@idcur	char(6)

create table #goutput (
	order_		int	default 0			not null,
	site			char(6)						not null,
	sitedes		varchar(18)	default ''	not null,
	sort			char(4)						not null,
	sortdes		varchar(12)	default ''	not null,
	amount0		money	default 0			not null,
	sale0			money	default 0			not null,
	profit0		money	default 0			not null,
	amount1		money	default 0			not null,
	sale1			money	default 0			not null,
	profit1		money	default 0			not null,
	amount2		money	default 0			not null,
	sale2			money	default 0			not null,
	profit2		money	default 0			not null,
	amount3		money	default 0			not null,
	sale3			money	default 0			not null,
	profit3		money	default 0			not null,
	amount4		money	default 0			not null,
	sale4			money	default 0			not null,
	profit4		money	default 0			not null,
	amount5		money	default 0			not null,
	sale5			money	default 0			not null,
	disc			money	default 0			not null,
	profit5		money	default 0			not null,
	amount6		money	default 0			not null,
	sale6			money	default 0			not null,
	profit6		money	default 0			not null,
	amount7		money	default 0			not null,
	sale7			money	default 0			not null,
	profit7		money	default 0			not null,
	amount8		money	default 0			not null,
	sale8			money	default 0			not null,
	profit8		money	default 0			not null,
	amount9		money	default 0			not null,
	sale9			money	default 0			not null,
	profit9		money	default 0			not null,
	ref			varchar(20)					not null
)

select @idcur = min(id) from bos_store
if @id='' or rtrim(@id) is null
	select @id = @idcur

-- 基本数据
if @id = @idcur
	insert #goutput
		select 0, a.site,'',b.sort,'',
			sum(amount0),sum(sale0),sum(profit0),sum(amount1),sum(sale1),sum(profit1),
			sum(amount2),sum(sale2),sum(profit2),sum(amount3),sum(sale3),sum(profit3),
			sum(-1*amount4),sum(-1*sale4),sum(-1*profit4),sum(amount5),sum(sale5),sum(disc),sum(profit5),
			sum(amount6),sum(sale6),sum(profit6),sum(amount7),sum(sale7),sum(profit7),
			sum(amount8),sum(sale8),sum(profit8),sum(amount9),sum(sale9),sum(profit9),''
			from bos_store a, bos_plu b, bos_site c
			where a.pccode=b.pccode and a.code=b.code and a.pccode=@pccode
				and a.site=c.site and a.pccode=c.pccode 
				and (@tag='' or c.tag=@tag)
				and (@site='' or a.site=@site)
				and (@class='' or b.class=@class)
				and (@code='' or a.code like @code+'%')
			group by a.site, b.sort order by a.site, b.sort
else
	insert #goutput
		select 0, a.site,'',b.sort,'',
			sum(amount0),sum(sale0),sum(profit0),sum(amount1),sum(sale1),sum(profit1),
			sum(amount2),sum(sale2),sum(profit2),sum(amount3),sum(sale3),sum(profit3),
			sum(-1*amount4),sum(-1*sale4),sum(-1*profit4),sum(amount5),sum(sale5),sum(disc),sum(profit5),
			sum(amount6),sum(sale6),sum(profit6),sum(amount7),sum(sale7),sum(profit7),
			sum(amount8),sum(sale8),sum(profit8),sum(amount9),sum(sale9),sum(profit9),''
			from bos_hstore a, bos_plu b, bos_site c
			where a.pccode=b.pccode and a.code=b.code and a.pccode=@pccode
				and a.site=c.site and a.pccode=c.pccode
				and (@tag='' or c.tag=@tag)
				and (@site='' or a.site=@site)
				and (@class='' or b.class=@class)
				and (@code='' or a.code like @code+'%') and a.id=@id
			group by a.site, b.sort order by a.site, b.sort

delete #goutput where amount0=0 and amount1=0 and amount2=0 and amount3=0 and amount4=0 
	and amount5=0 and amount6=0 and amount7=0 and amount8=0 and amount9=0 and disc=0

-- 合计项目
if charindex('g', @mode)>0
	insert #goutput
		select 0, site,'','-','',
			sum(amount0),sum(sale0),sum(profit0),sum(amount1),sum(sale1),sum(profit1),
			sum(amount2),sum(sale2),sum(profit2),sum(amount3),sum(sale3),sum(profit3),
			sum(amount4),sum(sale4),sum(profit4),sum(amount5),sum(sale5),sum(disc),sum(profit5),
			sum(amount6),sum(sale6),sum(profit6),sum(amount7),sum(sale7),sum(profit7),
			sum(amount8),sum(sale8),sum(profit8),sum(amount9),sum(sale9),sum(profit9),''
			from #goutput group by site
if charindex('s', @mode)>0
	insert #goutput
		select 0, 'zzz','',sort,'',
			sum(amount0),sum(sale0),sum(profit0),sum(amount1),sum(sale1),sum(profit1),
			sum(amount2),sum(sale2),sum(profit2),sum(amount3),sum(sale3),sum(profit3),
			sum(amount4),sum(sale4),sum(profit4),sum(amount5),sum(sale5),sum(disc),sum(profit5),
			sum(amount6),sum(sale6),sum(profit6),sum(amount7),sum(sale7),sum(profit7),
			sum(amount8),sum(sale8),sum(profit8),sum(amount9),sum(sale9),sum(profit9),''
			from #goutput where sort<>'-' group by sort
-- GaoLiang 2005/5/19 防止空值
if charindex('z', @mode)>0
	begin
	if (select count(1) from #goutput where sort<>'-' and site<>'zzz') > 0
		insert #goutput
			select 0, 'zzz','','-','',
				sum(amount0),sum(sale0),sum(profit0),sum(amount1),sum(sale1),sum(profit1),
				sum(amount2),sum(sale2),sum(profit2),sum(amount3),sum(sale3),sum(profit3),
				sum(amount4),sum(sale4),sum(profit4),sum(amount5),sum(sale5),sum(disc),sum(profit5),
				sum(amount6),sum(sale6),sum(profit6),sum(amount7),sum(sale7),sum(profit7),
				sum(amount8),sum(sale8),sum(profit8),sum(amount9),sum(sale9),sum(profit9),''
				from #goutput where sort<>'-' and site<>'zzz'
	else
		insert #goutput
			select 0, 'zzz','','-','',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,''
	end
if charindex('m', @mode)>0
	delete #goutput where site<>'zzz' and sort<>'-'

-- 中文描述
update #goutput set sitedes = a.descript from bos_site a 
	where a.pccode=@pccode and #goutput.site=a.site and #goutput.site<>'zzz'
update #goutput set sitedes = sitedes+'-小计' where sort='-' and site<>'zzz'
update #goutput set sitedes = '总    计' where sort='-' and site='zzz'
update #goutput set sortdes = a.name from bos_sort a 
	where a.pccode=@pccode and #goutput.sort=a.sort and #goutput.sort<>'-'

-- 如果当前代码指定某一个，则可以修改类的名称为商品的名称
if rtrim(@code) is not null
	begin
	if (select count(1) from bos_plu where pccode=@pccode and code=@code) = 1
		update #goutput set sortdes=a.name from bos_plu a 
			where a.pccode=@pccode and a.code=@code and #goutput.sort<>'-'
	end

select sitedes,sortdes,amount0,sale0,profit0,amount1,sale1,profit1,
		amount2,sale2,profit2,amount3,sale3,profit3,
		amount4,sale4,profit4,amount5,sale5,disc,profit5,
		amount6,sale6,profit6,amount7,sale7,profit7,
		amount8,sale8,profit8,amount9,sale9,profit9,ref
	from #goutput order by site, sort

return 0
;
