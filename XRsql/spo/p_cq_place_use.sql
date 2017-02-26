drop procedure p_cq_place_use;
create procedure p_cq_place_use
			@bdate1		datetime,
			@bdate2		datetime	
			
as
declare
			@day			integer
	

select @day = convert(integer,datediff(dd,@bdate1,@bdate2))
create table #sort
(
	sort		char(4),
	name1		char(20),
	basic		money,
	number	money,
	deci		money
)

insert #sort select sort,name1,0,0,0 from pos_sort where plucode = '20' and sort in ('0002','0003','0004','0005','0007','0008','0009','0017')

update #sort set basic = @day*a.number from place_basic a where #sort.sort = a.sort
update #sort set number = (select sum(number) from sp_hdish where menu in (select menu from sp_hmenu where bdate >=@bdate1 
and bdate <=@bdate2 and sta = '3') and charindex(rtrim(sta),'0357') >0 and code like '__3%' and sort = #sort.sort )
update #sort set deci = number/basic

select sort,name1,basic,number,deci from #sort order by sort
;
