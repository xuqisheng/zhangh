if exists (select 1 from sysobjects where name = 'p_wz_gs_input_query')
drop proc p_wz_gs_input_query ;

create proc p_wz_gs_input_query
	@log_date	datetime,
	@date			datetime,
	@code			char(1),
	@site			varchar(10),
	@item			char(3),
	@empno		char(10),
	@sta			char(1),
	@mode			char(1)
as


create table #woutput
(		log_date		datetime			null,
		date			datetime			null,
		code			char(1)			null,
		code_des		char(20)			null,
		site			varchar(10)		null,
		item			char(3)			null,
		item_des		char(10)			null,
		amount		money		default 0	null,
		empno			char(10)			null,
		sta			char(1)			null,
		mode			char(1)			null
)


insert #woutput(log_date,date,code,code_des,site,item,item_des,amount,empno,sta,mode)
	select  a.log_date,a.date,a.code,a.code,a.site,a.item,a.item,a.amount,a.empno,a.sta,a.mode
		from gs_rec a
		where a.code=@code
			and (@log_date is null or datediff(dd,a.log_date,@log_date)=0)
			and (@date is null or datediff(dd,a.date,@date)=0)
			and (rtrim(@site) is null or a.site=@site)
			and (rtrim(@item) is null or a.item=@item)
			and (rtrim(@empno) is null or a.empno=@empno)
			and (rtrim(@sta) is null or a.sta=@sta)
			and (rtrim(@mode) is null or a.mode=@mode)
		group by a.date,a.code,a.site,a.item

update #woutput set item_des = a.descript from gs_item a where #woutput.item_des *= a.item and a.code = @code 
update #woutput set code_des = a.descript from gs_type a where #woutput.code_des *= a.code

select * from #woutput

return 0
;