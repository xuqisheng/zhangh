if exists (select 1 from sysobjects where name = 'p_house_expend_rep')
	drop proc p_house_expend_rep;

create proc p_house_expend_rep

	@begin		datetime,
	@end			datetime

as

declare	@itemdes		varchar(10),
			@items		varchar(255),
			@no			integer,
			@pos			integer			
			
create table #temp
(
	date	char(10),
	e1		money,	e2		money,	e3		money,
	e4		money,	e5		money,	e6		money,
	e7		money,	e8		money,	e9		money,
	e10	money,	e11	money,	e12	money,
	e13	money,	e14	money,	e15	money,
	e16	money,	e17	money,	e18	money,
	e19	money,	e20	money,	e21	money,
	e22	money,	e23	money,	e24	money,
	e25	money,	e26	money,	e27	money,
	e28	money,	e29	money,	e30	money
)
create table #woutput
(
	col		varchar(10),
	row		varchar(30),
	value 	money 		default 0 ,	
)

insert into #temp select convert(char(10),cleantime,11),isnull(sum(e1),0),isnull(sum(e2),0),isnull(sum(e3),0)
		,isnull(sum(e4),0),isnull(sum(e5),0),isnull(sum(e6),0),isnull(sum(e7),0),isnull(sum(e8),0),isnull(sum(e9),0)
		,isnull(sum(e10),0),isnull(sum(e11),0),isnull(sum(e12),0),isnull(sum(e13),0),isnull(sum(e14),0),isnull(sum(e15),0)
		,isnull(sum(e16),0),isnull(sum(e17),0),isnull(sum(e18),0),isnull(sum(e19),0),isnull(sum(e20),0),isnull(sum(e21),0)
		,isnull(sum(e22),0),isnull(sum(e23),0),isnull(sum(e24),0),isnull(sum(e25),0),isnull(sum(e26),0),isnull(sum(e27),0)
		,isnull(sum(e28),0),isnull(sum(e29),0),isnull(sum(e30),0)
	from task_assignment where cleantime>=@begin and cleantime<=@end group by convert(char(10),cleantime,11)

declare c_expend cursor for
	select descript from basecode where cat='expend'
open c_expend
fetch c_expend into @itemdes
while @@sqlstatus=0
	begin
	select @items=@items + @itemdes +'/'
	fetch c_expend into @itemdes
	end
close c_expend
deallocate cursor c_expend

select @no = 0
select @pos = charindex('/',@items)
while @items != ''
	begin	
	select @itemdes=substring(@items,1,@pos - 1)
	select @items  =substring(@items,@pos + 1,datalength(@items) - @pos)
	select @no = @no + 1
	if @no = 1		
		insert into #woutput select date,@itemdes,e1 from #temp
	else if @no = 2
		insert into #woutput select date,@itemdes,e2 from #temp
	else if @no = 3
		insert into #woutput select date,@itemdes,e3 from #temp
	else if @no = 4
		insert into #woutput select date,@itemdes,e4 from #temp
	else if @no = 5
		insert into #woutput select date,@itemdes,e5 from #temp
	else if @no = 6
		insert into #woutput select date,@itemdes,e6 from #temp
	else if @no = 7
		insert into #woutput select date,@itemdes,e7 from #temp
	else if @no = 8
		insert into #woutput select date,@itemdes,e8 from #temp
	else if @no = 9
		insert into #woutput select date,@itemdes,e9 from #temp
	else if @no = 10
		insert into #woutput select date,@itemdes,e10 from #temp
	else if @no = 11
		insert into #woutput select date,@itemdes,e11 from #temp
	else if @no = 12
		insert into #woutput select date,@itemdes,e12 from #temp
	else if @no = 13
		insert into #woutput select date,@itemdes,e13 from #temp
	else if @no = 14
		insert into #woutput select date,@itemdes,e14 from #temp
	else if @no = 15
		insert into #woutput select date,@itemdes,e15 from #temp
	else if @no = 16
		insert into #woutput select date,@itemdes,e16 from #temp
	else if @no = 17
		insert into #woutput select date,@itemdes,e17 from #temp

	select @pos=charindex('/',@items)
	if @pos=0
		select @items=''
	end

select * from #woutput where value>0

return 0
--exec p_house_expend_rep @begin='06/04/01' ,@end='06/04/30';
;