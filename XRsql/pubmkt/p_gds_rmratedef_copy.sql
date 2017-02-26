//================================================================================
// 	房价明细码复制
//================================================================================
if  exists(select * from sysobjects where name = "p_gds_rmratedef_copy")
	drop proc p_gds_rmratedef_copy;
create proc p_gds_rmratedef_copy
	@no0				char(10),	// 原码
	@no1				char(10)	// 复制号码
as
declare		@ret		int,
				@msg		varchar(60),
				@des		varchar(30)

select @ret = 0, @msg = ''

select @des = descript from rmratedef where code=@no0
if @@rowcount = 0
begin
	select @ret=1, @msg='房价明细码 - %1 - 已经不存在^'+ @no0 
	goto p_out
end
if exists(select 1 from rmratedef where code=@no1)
begin
	select @ret=1, @msg='房价明细码 - %1 - 已经存在^'+ @no1 
	goto p_out
end

select @des = rtrim(substring(@des+'-copy', 1, 30))
if exists(select 1 from rmratedef where descript=@des)
begin
	select @ret=1, @msg='房价明细码描述 - %1 - 已经存在^'+ @des 
	goto p_out
end

select * into #temp from rmratedef where code=@no0
update #temp set code=@no1, descript=@des ,type=''
insert rmratedef select * from #temp

delete rmratedef_sslink where code=@no1
select * into #temp1 from rmratedef_sslink where code=@no0
update #temp1 set code=@no1
insert rmratedef_sslink select * from #temp1

p_out:
select @ret, @msg
return @ret
;
