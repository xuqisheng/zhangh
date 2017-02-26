--自动实现组的分布
--write by wz at 2003.5.22

if exists (select 1 from sysobjects where name = 'p_wz_house_group_bu')
	drop proc p_wz_house_group_bu ;

create proc p_wz_house_group_bu
		 @person		integer
		
		 	
as
declare
		@thall			char(1),
		@tflr				char(3),
		@troomno			char(5),
		@tadd_sta		varchar(4),
		@ptmp				integer,
		@temp				integer,
		@tmp1				integer,
		@tmp2				integer,
		@value_all		integer,
		@rule				integer

create table #roomsta(
		hall		  char(1),
		roomno	  char(5),
		flr		  char(3),
		ocsta		  char(1),
		sta 		  char(1),
		add_sta	  varchar(4),
		item 		  char(4),
		value		  money		default 0
		
)
create table #woutput(
		attendant		integer,
		hall				char(1),
		flr				char(3),
		roomno			char(5),
		status			varchar(4),
		credits			money		default 0
)
create table #group_bu(
			group_num	integer,
			tcredits		money		default	0
)
	

insert #roomsta (hall,roomno,flr,ocsta,sta)
		select hall,roomno,flr,ocsta,sta  from rmsta where  sta <>'M' and sta<>'L'  
update #roomsta set add_sta = ocsta + sta 

delete #roomsta where add_sta = 'OR'

update #roomsta set #roomsta.item =b.item,#roomsta.value = b.value from gs_item b 
		where #roomsta.add_sta = b.descript

select @value_all = isnull((select sum(value) from #roomsta),0)

if @person=0
	select @person = 1
select @rule = @value_all/@person
--根据算法规则来分配要清洁的房间
select @ptmp = 1,@tmp2 = 0

declare c_rmsta cursor for select hall,flr,roomno,add_sta,value from #roomsta order by roomno
open c_rmsta
fetch c_rmsta into @thall,@tflr,@troomno,@tadd_sta,@tmp1

while	@ptmp < = @person and @@sqlstatus = 0
begin
	while @tmp2 < @rule and @@sqlstatus = 0
	begin
		insert #woutput select @ptmp,@thall,@tflr,@troomno,@tadd_sta,@tmp1
		select @tmp2 = @tmp2 + @tmp1 
		fetch c_rmsta into @thall,@tflr,@troomno,@tadd_sta,@tmp1
	end
	insert #group_bu values( @ptmp ,@tmp2)
	select @ptmp = @ptmp + 1, @tmp2 = 0
end
close c_rmsta
deallocate cursor c_rmsta

//select * from #woutput 
select group_num,tcredits from #group_bu
return 0 ;
		