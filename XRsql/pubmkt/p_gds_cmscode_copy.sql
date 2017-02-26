//================================================================================
// 	佣金码复制
//================================================================================
if  exists(select * from sysobjects where name = "p_gds_cmscode_copy")
	drop proc p_gds_cmscode_copy;
create proc p_gds_cmscode_copy
	@no0				char(10),	// 原码
	@no1				char(10)		// 复制号码
as
declare		@ret			int,
				@msg			varchar(60),
				@des			varchar(30),
				@code			char(10),
				@code_new	char(10),
				@num			int,
				@row_count	int

select @ret = 0, @msg = '',@num = 1

select @des = descript from cmscode where code=@no0
if @@rowcount = 0
begin
	select @ret=1, @msg='佣金码 - %1 - 已经不存在^'+ @no0 
	goto p_out
end
if exists(select 1 from cmscode where code=@no1)
begin
	select @ret=1, @msg='佣金码 - %1 - 已经存在^'+ @no1 
	goto p_out
end

select @des = rtrim(substring(@des+'-copy', 1, 30))
if exists(select 1 from cmscode where descript=@des)
begin
	select @ret=1, @msg='佣金码描述 - %1 - 已经存在^'+ @des 
	goto p_out
end

select * into #temp from cmscode where code=@no0
update #temp set code=@no1, descript=@des 
insert cmscode select * from #temp

delete cmscode_link where code=@no1
select * into #temp1 from cmscode_link where code=@no0 order by code
select * into #temp2 from cms_defitem where no in (select cmscode from cmscode_link where code = @no0)

select @code_new = max(no) from cms_defitem where no like 'C'+convert(char(6),getdate(),12)+'%'
if @code_new='' or @code_new = null
	begin
	select @code_new='C'+convert(char(6),getdate(),12)+'001'
	end
else
	begin
	select @code_new=substring(@code_new,1,7)+substring('000'+convert(char(3),convert(integer,substring(@code_new,8,3))+1),datalength('000'+convert(char(3),convert(integer,substring(@code_new,8,3))+1)) -4,6)
	end

declare c1 cursor for select no from cms_defitem where no in (select cmscode from cmscode_link where code = @no0)
open c1
fetch c1 into @code
while  @@sqlstatus = 0
	begin
	update #temp1 set cmscode = @code_new where cmscode = @code
	update #temp2 set no = @code_new where no = @code
	select @code_new=substring(@code_new,1,7)+substring('000'+convert(char(3),convert(integer,substring(@code_new,8,3))+1),datalength('000'+convert(char(3),convert(integer,substring(@code_new,8,3))+1)) -4,6)
	fetch c1 into @code
	end
close c1
deallocate cursor c1


delete #temp1 where cmscode not like 'C'+convert(char(6),getdate(),12)+'%'
update #temp1 set code = @no1
insert cmscode_link select * from #temp1
insert cms_defitem select * from #temp2



p_out:
select @ret, @msg
return @ret
;
