

if exists(select * from sysobjects where name = "p_gds_sc_block_select")
   drop proc p_gds_sc_block_select;

create proc p_gds_sc_block_select
   @accnt 	varchar(10),
   @code 	varchar(20),
	@name		varchar(50),
	@cusno	varchar(10),
	@saleid	varchar(10),
	@arr		datetime
as
--------------------------------------------------------
-- block 
--------------------------------------------------------

declare
	@type			char(5)

select @accnt=rtrim(@accnt),@code=rtrim(@code),@name=rtrim(@name)
select @cusno=rtrim(@cusno),@saleid=rtrim(@saleid)
if @code is not null 
	select @code='%' + @code + '%' 
if @name is not null 
	select @name='%' + @name + '%' 

select a.accnt, a.blockcode, a.name, a.name2, a.arr, a.dep, a.restype 
	from sc_master a, sc_ressta b 
		where a.status=b.code and b.allowpick='T' 
			and (@accnt is null or a.accnt=@accnt)
			and (@code is null or a.blockcode like @code)
			and (@name is null or a.name like @name)
			and (@cusno is null or a.cusno=@cusno or a.agent=@cusno or a.source=@cusno)
			and (@saleid is null or a.saleid=@saleid)
			and (@arr is null or datediff(dd,@arr,a.dep)>0)
		order by a.arr 
	
return 0
;