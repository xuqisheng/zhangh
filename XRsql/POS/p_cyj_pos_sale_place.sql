if exists(select 1 from sysobjects where name = 'p_cyj_pos_sale_place' and type = 'P')
	drop proc p_cyj_pos_sale_place;
create proc p_cyj_pos_sale_place
	@pccodes			varchar(255),		                          
	@plucodes		varchar(255),		                      
	@sorts			varchar(255),		                         
	@begin_			datetime,			            
	@end_				datetime
as
--============================================================================================
--
--		�����������а�
--																											2003/10/25 cyj
--       	�Ż�������������																		2007/02/28 cyj
--============================================================================================

declare 
	@pccode		char(3),
	@plucode		char(2),
	@sort			char(4),
	@sbegin		varchar(10),
	@send			varchar(10)

create  table #menu(menu char(10), pccode char(3))
create  index index1 on #menu(menu)

create  table #dish(
 		pccode	 char(3) default '' not null,
		menu 		 char(10) default '' not null, 
		plucode	 char(2)  default '' not null,
		sort		 char(4)  default '' not null,
      id        integer  default 0 not null,
		code		 char(10) default '' not null,
      sta       char(1)  default '' not null,              
      flag      char(30)  default '' not null,              
 		name1     char(30) default '' not null,          
		number    money  default 0 not null, 					      
		unit      char(4) default '' not null, 
		amount    money  default 0 not null,  					   
		dsc       money  default 0 not null,  					  	 
		srv       money  default 0 not null,  					  	 
		tax       money  default 0 not null,
		pamount   money  default 0 not null
 )



-- �Ǽ��ʣ����ʣ�Ҳ�㵱��Ӫҵ��ʱ���ж���menu��Ϊ׼��bdate ����Ϊ׷�ؽ��˶��仯

select @sbegin = convert(char(6),@begin_, 12) + '0000'
select @send 	= convert(char(6),@end_, 12) + '9999'

insert into #menu select menu,pccode from pos_hmenu where 
	menu > @sbegin and menu < @send and ( sta = '2' or sta = '3' or sta = '5')

if rtrim(@pccodes) is not null 
	delete #menu where  charindex(pccode, @pccodes)=0


insert into #dish select b.pccode,b.menu,a.plucode,a.sort,a.id,a.code,a.sta,a.flag,a.name1,a.number,a.unit,a.amount,a.dsc,a.srv,a.tax,a.pamount 
	from pos_hdish a,  #menu b where a.menu > @sbegin and a.menu < @send and b.menu = a.menu

delete #dish where sta<>'0' and sta<>'3' and sta<>'5' and sta<>'7' and sta<>'9' and sta<>'A' and sta <>'M'
delete #dish where rtrim(code) >='X'

// ɾ���ײ����ˣ�����ɾ���ײ���ϸ������ѡ��һ������
delete #dish where substring(flag, 1, 1) = 'T'
--delete #dish where sta = 'M'

update #dish set name1 = substring(name1,2,20) where substring(name1,1,1)='-'
create  index index1 on #dish( pccode, plucode, sort, id, code, name1, unit)

create  table #sale
(
      id        integer	default 0 not null,              -- ��id
      descript  char(20) default '' not null,            -- ����
		char40    char(40) default '' not null,            -- ����+С��   
		char06    char(10) default '' not null,            -- �˺� 
		name1     char(20) default '' not null,            -- ����
		numb10    money  default 0 not null,               -- ����
		unit      char(4) default '' not null,             -- ��λ
		amount0   money  default 0 not null,               -- ԭ���
		amount    money  default 0 not null,               -- ʵ�ʽ��
		pamount   money  default 0 not null,               -- �ɱ�
		srv       money  default 0 not null,               -- ˰+�����
		dsc       money  default 0 not null,               -- �ۿ�
      number11  money  default 0 not null,   				-- ����
		pccode	 char(3) default '' not null,
		plucode	 char(2) default '' not null,
		sort		 char(4) default '' not null
)


select @sbegin = convert(char(6),@begin_, 12) + '0000'
select @send 	= convert(char(6),@end_, 12) + '9999'

insert into #sale
select id=a.id,
      '', 
		char40 =  isnull(rtrim(d.descript)+'-'+rtrim(e.name1), ''),
		char06  =  a.code,
		a.name1,
		numb10  =  isnull(sum(a.number), 0),
		a.unit, 
		amount0  =  isnull(sum(a.amount), 0),
		amount   =  isnull(sum(a.amount - a.dsc + a.srv + a.tax), 0),
		pamount  =  isnull(sum(a.pamount), 0),
		srv       =  isnull(sum(a.srv + a.tax), 0),
		dsc       =  isnull(sum(a.dsc),0),
      number11  =  1,
		pccode = '',
		plucode = isnull(d.plucode,''),
		sort = isnull(a.sort, '')
	from  #dish a, #menu b, pos_pccode c, pos_plucode d, pos_sort e, pos_plu_all f
	where a.menu=b.menu and b.pccode=c.pccode 
			and a.plucode = d.plucode 
			and a.plucode *= e.plucode 
			and a.sort *= e.sort 
			and a.id *= f.id
			and (rtrim(@plucodes) = null or charindex(d.plucode, @plucodes)>0 )
			and (rtrim(@sorts) = null or charindex(a.sort, @sorts)>0 )
	group by d.descript,e.name1,d.plucode,a.sort,a.code,a.name1,a.unit,a.id
-- having sum(a.number) <> 0         -- ע����ʱ�˵��۲�һ��, �������������
	order by d.descript,e.name1,d.plucode,a.sort,a.code,a.name1,a.unit,a.id

update #sale set number11=(select count(distinct menu) from #dish where 
	id=#sale.id and sta in ('0','3','5','7','A'))
select  char40,char06,name1,   numb10,unit,  amount0,   amount,pamount, number11 from #sale order by plucode, sort, char06 
--select  id, char20,   char40,char10,char20_1,numb10,char04,numb10_2,numb10_3,numb10_4,number11
return 0;
