// x ϵ�в���ϵͳ���׼��
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
select '300',menu,'������'+pccode+'�˺�:'+code+'����:'+name1+'  û�ж��屨��������' from pos_detail_jie where date=@bdate and tocode ='099'

insert into #list
	select '310',sort, '����:'+name1+'  û�ж��屨��������' from pos_sort where  tocode = '' or tocode is null


insert into #list
	select '500',a.code,'û�ж���۸�:'+a.name1 from pos_plu a where a.id not in(select id from pos_price)

insert into #list
	select '520',a.code,'�۸�Ϊ0:'+a.name1 from pos_plu a where flag11<>'T' and a.id in(select id from pos_price where price=0)

if exists(select 1 from pos_pserver)
	begin
	insert into #list
		select '550',sort,'û�ж����Ӧ������ӡ��:'+name1 from pos_sort where plucode+sort not in(select plucode+plusort from pos_prnscope)
	end

insert into #list
	select '580',plucode,'�ò˱�û�����ò���:'+descript from pos_plucode  where pccodes is null or pccodes = ''

insert into #list
	select '590',a.pccode,'�ò���û�в˱�����:'+ a.descript  from pos_pccode a where not exists(select 1 from pos_plucode where charindex(a.pccode,pccodes)>0)

select * from #list order by type,menu
;
