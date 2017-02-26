// x 系列餐饮系统菜谱检查
if exists(select 1 from sysobjects where name='p_cyj_pos_maint_plu' and type ='P')
	drop proc p_cyj_pos_maint_plu;
create proc p_cyj_pos_maint_plu
as
declare
	@bdate		datetime

select @bdate = bdate1 from sysdata

create	table	 #list(
	type		char(10),
	menu		char(10),
	msg		char(200)
)


insert into #list
select '300',menu,'餐厅：'+pccode+'菜号:'+code+'菜名:'+name1+'  没有定义报表数据项' from pos_detail_jie where date=@bdate and tocode ='099'

insert into #list
	select '310',sort, '菜类:'+name1+'  没有定义报表数据项' from pos_sort where  tocode = '' or tocode is null


insert into #list
	select '500',a.code,'没有定义价格:'+a.name1 from pos_plu a where a.id not in(select id from pos_price)

insert into #list
	select '520',a.code,'价格为0:'+a.name1 from pos_plu a where flag11<>'T' and a.id in(select id from pos_price where price=0)

if exists(select 1 from pos_pserver)
	begin
	insert into #list
		select '550',sort,'没有定义对应厨房打印机:'+name1 from pos_sort where plucode+sort not in(select plucode+plusort from pos_prnscope)
	end

insert into #list
	select '580',plucode,'该菜本没有适用餐厅:'+descript from pos_plucode  where pccodes is null or pccodes = ''

insert into #list
	select '590',a.pccode,'该餐厅没有菜本定义:'+ a.descript  from pos_pccode a where not exists(select 1 from pos_plucode where charindex(a.pccode,pccodes)>0)

select * from #list order by type,menu
;
