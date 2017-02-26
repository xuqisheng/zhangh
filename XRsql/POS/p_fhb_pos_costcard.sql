drop proc p_fhb_pos_costcard;
create proc p_fhb_pos_costcard
	@plucode	char(2),
	@sort	char(4),
	@code	char(6)

as

create table #cost_card
(	
	id	int,
	inumber int,
	sort	char(4),								--��Ʒ���
	code	char(6),								--����
	name1	varchar(30),						--����
	unit	char(4),								--���۵�λ
	price money,								--���ۼ۸�
	artcode	char(12),						--������
	descript	char(40),						--��������
	csunit	char(6),							--���ϵ�λ
	number	money,							--��������
	cprice	money,							--���ϵ��ۡ��ɱ���λ�۸�
	cost		money,							--�ɱ�
	bcost		money,							--��׼�ɱ���
	ccost		money,							--�ο��ɱ���
	rate		money								--������
	
)
if @plucode is null or @plucode = ''
begin
	insert #cost_card
		select a.id,a.inumber,b.sort,b.code,b.name1,a.unit,c.price,a.artcode,a.descript,a.csunit,a.number,0,0,0,0,a.rate from pos_pldef_price a,pos_plu b,pos_price c where a.id = c.id and a.inumber = c.inumber and b.id = a.id and b.pluid = 1 and 1 = 2
	select * from #cost_card
	return 0
end

if @sort is null
	select @sort = ''
if @code is null
	select @code = ''


insert #cost_card
	select a.id,a.inumber,b.sort,b.code,b.name1,a.unit,c.price,'---------','----------','',0,0,0,0,c.cost_f,0 from pos_pldef_price a,pos_plu b,pos_price c 
		where a.id = c.id and a.inumber = c.inumber and b.id = a.id and b.pluid = 1 and b.plucode = @plucode and (rtrim(b.sort) = @sort or @sort = '') and (rtrim(b.code) = @code or @code = '')
union
select a.id,a.inumber,'','','','',0,a.artcode,a.descript,a.csunit,a.number,a.price,round(a.number*a.price,2),0,0,a.rate from pos_pldef_price a,pos_plu b,pos_price c 
		where a.id = c.id and a.inumber = c.inumber and b.id = a.id and b.pluid = 1 and b.plucode = @plucode and (rtrim(b.sort) = @sort or @sort = '') and (rtrim(b.code) = @code or @code = '')
order by a.id,a.inumber
--�Ľ����۸�Ϊ�ɱ���λ�۸�
update pos_st_article set csunit = unit,csnumber = 1 where csnumber <= 0
update #cost_card set cprice = round(cprice/csnumber,2),cost = round(cost/csnumber,2) from pos_st_article a where a.code = #cost_card.artcode

--����ÿ����Ʒ�ɱ�
create table #cost_temp
(
	id	int,
	inumber int,
	cost	money
)

insert #cost_temp select id,inumber,isnull(sum(cost),0) from #cost_card group by id,inumber

update #cost_card set cost = a.cost from #cost_temp a where a.id = #cost_card.id and a.inumber = #cost_card.inumber and #cost_card.sort <> '' and #cost_card.code <> ''
update #cost_card set bcost = round(cost/price,3),csunit = 'С��:' where price <> 0 and sort <> '' and code <> ''

select * from #cost_card order by id,inumber,sort
return 0;