IF OBJECT_ID('dbo.p_gds_rmratecode_copy') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_gds_rmratecode_copy
END
;
create proc p_gds_rmratecode_copy
	@no0				char(10),	        
	@no1				char(10)		            
as
declare		@ret			int,
				@msg			varchar(60),
				@des			varchar(30),
				@code			char(10),
				@code_new	char(10),
				@num			int,
				@row_count	int,
				@tmp1			char(10),
				@tmp2			char(10)

select @ret = 0, @msg = '',@num = 1

select @des = descript from rmratecode where code=@no0
if @@rowcount = 0
begin
	select @ret=1, @msg='房价码 - %1 - 已经不存在^'+ @no0 
	goto p_out
end
if exists(select 1 from rmratecode where code=@no1)
begin
	select @ret=1, @msg='房价码 - %1 - 已经存在^'+ @no1 
	goto p_out
end


select * into #temp from rmratecode where code=@no0
update #temp set code=@no1, descript=@no1 , descript1=@no1 
insert rmratecode select * from #temp

delete rmratecode_link where code=@no1
select * into #temp1 from rmratecode_link where code=@no0 order by code
select * into #temp2 from rmratedef where code in (select rmcode from rmratecode_link where code = @no0)
select * into #temp3 from rmratedef_sslink where code in (select rmcode from rmratecode_link where code = @no0)


select @code_new = max(code) from rmratedef where code like 'R'+convert(char(6),getdate(),12)+'%'
--select @code_new,'R'+convert(char(6),getdate(),12)+'%'
if @code_new='' or @code_new = null
	begin
	select @code_new='R'+convert(char(6),getdate(),12)+'001'
	end
else
	begin
	select @tmp1 = substring(@code_new,1,7)
	select @tmp2 = substring(@code_new,8,3)
	select @tmp2 = '000'+convert(char(3),convert(integer,@tmp2)+1)
	select @code_new = rtrim(@tmp1) + substring(rtrim(@tmp2),datalength(rtrim(@tmp2)) - 2,3)
	end

declare c1 cursor for select code from rmratedef where code in (select rmcode from rmratecode_link where code = @no0)
open c1
fetch c1 into @code
while  @@sqlstatus = 0
	begin
	update #temp1 set code = @no1,rmcode = @code_new where rmcode = @code
	update #temp2 set code = @code_new,descript=type,descript1=type where code = @code
	update #temp3 set code = @code_new where code = @code
	select @tmp1 = substring(@code_new,1,7)
	select @tmp2 = substring(@code_new,8,3)
	select @tmp2 = '000'+convert(char(3),convert(integer,@tmp2)+1)
	select @code_new = rtrim(@tmp1) + substring(rtrim(@tmp2),datalength(rtrim(@tmp2)) - 2,3)
	fetch c1 into @code
	end
close c1
deallocate cursor c1


delete #temp1 where rmcode not like 'R'+convert(char(6),getdate(),12)+'%'
update #temp1 set code = @no1
insert rmratecode_link select * from #temp1
insert rmratedef select * from #temp2
insert rmratedef_sslink select * from #temp3



p_out:
select @ret, @msg
return @ret
;