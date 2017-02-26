drop procedure p_cq_pos_reserve_display;
create proc p_cq_pos_reserve_display
		@pccode			char(255),
		@pccodes			char(255) = '',         -- 增加站点对应pccodes全局变量
		@date				datetime,
		@sta				char(30)
 
as
declare 
		@ii					integer,
		@add					integer,
		@date1				datetime,
		@date2				datetime,
		@date3				datetime,
		@date4				datetime,
		@date5				datetime,
		@date6				datetime,
		@date7				datetime


if rtrim(@pccode) is null 
	select @pccode = '%'

create table #reserve
(
	pccode		char(3),
	tableno		char(6),
	descript		char(20),
	date1			datetime  null,
	date1_1		integer  null,
	date1_2		integer  null,
	date1_3		integer  null,
	date1_4		integer  null,
	date1_5		integer  null,
	date1_t		integer  null,
	date2			datetime  null,
	date2_1		integer  null,
	date2_2		integer  null,
	date2_3		integer  null,
	date2_4		integer  null,
	date2_5		integer  null,
	date2_t		integer  null,
	date3			datetime  null,
	date3_1		integer  null,
	date3_2		integer  null,
	date3_3		integer  null,
	date3_4		integer  null,
	date3_5		integer  null,
	date3_t		integer  null,
	date4			datetime  null,
	date4_1		integer  null,
	date4_2		integer  null,
	date4_3		integer  null,
	date4_4		integer  null,
	date4_5		integer  null,
	date4_t		integer  null,
	date5			datetime  null,
	date5_1		integer  null,
	date5_2		integer  null,
	date5_3		integer  null,
	date5_4		integer  null,
	date5_5		integer  null,
	date5_t		integer  null,
	date6			datetime  null,
	date6_1		integer  null,
	date6_2		integer  null,
	date6_3		integer  null,
	date6_4		integer  null,
	date6_5		integer  null,
	date6_t		integer  null,
	date7			datetime  null,
	date7_1		integer  null,
	date7_2		integer  null,
	date7_3		integer  null,
	date7_4		integer  null,
	date7_5		integer  null,
	date7_t		integer  null,
	shift_1		char(8)  null,
	shift_2		char(8)  null,
	shift_3		char(8)  null,
	shift_4		char(8)  null,
	shift_5		char(8)  null,
	limit			char(20)  null,
	selected		char(20)   null
)
if @pccode <> '%'
	begin
	insert into #reserve(pccode,tableno,descript) select pccode,tableno,descript1 from pos_tblsta where charindex(rtrim(pccode),@pccode) > 0 order by pccode,tableno
	select @date1 = @date,@date2 = dateadd(dd,1,@date),@date3 = dateadd(dd,2,@date),@date4 = dateadd(dd,3,@date),@date5 = dateadd(dd,4,@date),@date6 = dateadd(dd,5,@date),@date7 = dateadd(dd,6,@date)
	if exists(select 1 from pos_reserve where charindex(rtrim(pccode),@pccode) > 0 and charindex(sta,@sta) > 0  and tableno = '')
		insert into #reserve(pccode,tableno,descript) select distinct a.pccode,'',b.descript from pos_reserve a, pos_pccode b
		where charindex(rtrim(a.pccode),@pccode) > 0 and charindex(a.sta,@sta) > 0   and a.tableno = '' and a.pccode=b.pccode

	update #reserve set date1 = @date1,date2 = @date2,date3 = @date3,date4 = @date4,date5 = @date5,date6 = @date6,date7 = @date7
	

	update #reserve set date1_1 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date1) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '1'),
							  date1_2 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date1) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '2'),
							  date1_3 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date1) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '3')
	update #reserve set date1_4 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date1) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '4'),
							  date1_5 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date1) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '5'),
							  date1_t =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date1) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) )
	
	update #reserve set date2_1 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date2) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '1'),
							  date2_2 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date2) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '2'),
							  date2_3 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date2) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '3')
	update #reserve set date2_4 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date2) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '4'),
							  date2_5 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date2) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '5'),
							  date2_t =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date2) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) )
	
	update #reserve set date3_1 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date3) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '1'),
							  date3_2 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date3) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '2'),
							  date3_3 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date3) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '3')
	update #reserve set date3_4 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date3) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '4'),
							  date3_5 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date3) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '5'),
							  date3_t =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date3) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) )
	
	update #reserve set date4_1 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date4) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '1'),
							  date4_2 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date4) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '2'),
							  date4_3 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date4) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '3')
	update #reserve set date4_4 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date4) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '4'),
							  date4_5 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date4) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '5'),
							  date4_t =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date4) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) )
	
	update #reserve set date5_1 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date5) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '1'),
							  date5_2 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date5) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '2'),
							  date5_3 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date5) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '3')
	update #reserve set date5_4 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date5) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '4'),
							  date5_5 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date5) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '5'),
							  date5_t =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date5) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) )
	
	update #reserve set date6_1 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date6) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '1'),
							  date6_2 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date6) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '2'),
							  date6_3 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date6) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '3')
	update #reserve set date6_4 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date6) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '4'),
							  date6_5 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date6) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '5'),
							  date6_t =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date6) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) )
	
	update #reserve set date7_1 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date7) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '1'),
							  date7_2 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date7) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '2'),
							  date7_3 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date7) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '3')
	update #reserve set date7_4 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date7) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '4'),
							  date7_5 =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date7) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) and a.shift = '5'),
							  date7_t =  (select isnull(count(1),0) from pos_reserve a,pos_tblav b where datediff(dd,a.date0,@date7) = 0 and charindex(a.sta,@sta) > 0 and #reserve.tableno = b.tableno and (a.resno = b.menu or a.resno = (select resno from  pos_menu  where  menu =  b.menu)) )

	end
else
	begin

	insert into #reserve(pccode,tableno,descript) select pccode,'',descript from pos_pccode where charindex(rtrim(pccode),@pccodes)>0 or @pccodes = '' order by pccode

	select @date1 = @date,@date2 = dateadd(dd,1,@date),@date3 = dateadd(dd,2,@date),@date4 = dateadd(dd,3,@date),@date5 = dateadd(dd,4,@date),@date6 = dateadd(dd,5,@date),@date7 = dateadd(dd,6,@date)
	update #reserve set date1 = @date1,date2 = @date2,date3 = @date3,date4 = @date4,date5 = @date5,date6 = @date6,date7 = @date7
	
	update #reserve set date1_1 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date1) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '1'),
							  date1_2 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date1) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '2'),
							  date1_3 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date1) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '3')
	update #reserve set date1_4 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date1) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '4'),
							  date1_5 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date1) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '5'),
							  date1_t =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date1) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode )
	
	update #reserve set date2_1 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date2) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '1'),
							  date2_2 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date2) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '2'),
							  date2_3 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date2) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '3')
	update #reserve set date2_4 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date2) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '4'),
							  date2_5 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date2) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '5'),
							  date2_t =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date2) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode )
	
	update #reserve set date3_1 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date3) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '1'),
							  date3_2 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date3) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '2'),
							  date3_3 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date3) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '3')
	update #reserve set date3_4 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date3) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '4'),
							  date3_5 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date3) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '5'),
							  date3_t =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date3) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode )
	
	update #reserve set date4_1 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date4) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '1'),
							  date4_2 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date4) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '2'),
							  date4_3 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date4) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '3')
	update #reserve set date4_4 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date4) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '4'),
							  date4_5 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date4) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '5'),
							  date4_t =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date4) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode )
	
	update #reserve set date5_1 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date5) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '1'),
							  date5_2 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date5) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '2'),
							  date5_3 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date5) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '3')
	update #reserve set date5_4 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date5) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '4'),
							  date5_5 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date5) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '5'),
							  date5_t =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date5) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode )
	
	update #reserve set date6_1 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date6) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '1'),
							  date6_2 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date6) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '2'),
							  date6_3 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date6) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '3')
	update #reserve set date6_4 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date6) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '4'),
							  date6_5 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date6) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '5'),
							  date6_t =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date6) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode )
	
	update #reserve set date7_1 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date7) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '1'),
							  date7_2 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date7) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '2'),
							  date7_3 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date7) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '3')
	update #reserve set date7_4 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date7) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '4'),
							  date7_5 =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date7) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode and a.shift = '5'),
							  date7_t =  (select isnull(count(1),0) from pos_reserve a where datediff(dd,a.date0,@date7) = 0 and charindex(a.sta,@sta) > 0 and #reserve.pccode = a.pccode )
	
	end
update #reserve set shift_1 = a.descript from basecode a where a.cat = 'pos_shift' and a.code = '1'
update #reserve set shift_2 = a.descript from basecode a where a.cat = 'pos_shift' and a.code = '2'
update #reserve set shift_3 = a.descript from basecode a where a.cat = 'pos_shift' and a.code = '3'
update #reserve set shift_4 = a.descript from basecode a where a.cat = 'pos_shift' and a.code = '4'
update #reserve set shift_5 = a.descript from basecode a where a.cat = 'pos_shift' and a.code = '5'
update #reserve set limit = value from sysoption where catalog = 'pos' and item = 'reserve_shift'
select * from #reserve
return 0;