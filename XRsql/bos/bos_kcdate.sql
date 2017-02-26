//------------------------------------------------------------------------------
//		bos 库存帐务结转日期
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_kcdate')
	drop table bos_kcdate;
create table  bos_kcdate (
	id				char(6)		not null,
	year			int			not null,
	month			int			not null,
	begin_		datetime		not null,
	end_			datetime		not null,
	len			int			default 0	not null
)
exec sp_primarykey bos_kcdate, id
create unique index index1 on bos_kcdate(id)
create unique index index2 on bos_kcdate(year,month)
;

-- create bos_kcdate
if object_id('p_gds_bos_kcdate_create') is not null
	drop proc p_gds_bos_kcdate_create
;
create proc p_gds_bos_kcdate_create
as
declare	@begin datetime, @dtmp datetime,
			@count int, @year int, @month int, @id char(6), @day int

select @begin=getdate()

select @year=datepart(year,@begin), @month=datepart(month,@begin)
select @id=convert(char(4),@year)+right('0'+rtrim(convert(char(2),@month)),2)
insert bos_kcdate (id,year,month,begin_,end_)
	select @id, @year, @month, @begin, @begin

select @count = 0
while @count < 3660
	begin
	select @begin = dateadd(dd, 1, @begin), @count = @count + 1
	select @day=datepart(day,@begin)
	if @day = 1 
		begin
		select @dtmp = dateadd(dd, -1, @begin)
		update bos_kcdate set end_ = @dtmp where id=@id

		select @year=datepart(year,@begin), @month=datepart(month,@begin)
		select @id=convert(char(4),@year)+right('0'+rtrim(convert(char(2),@month)),2)
		insert bos_kcdate (id,year,month,begin_,end_)
			select @id, @year, @month, @begin, @begin
		end
	end

update bos_kcdate set len=datediff(dd, begin_, end_)+1
return 0
;

exec p_gds_bos_kcdate_create;
select * from bos_kcdate order by id;


				