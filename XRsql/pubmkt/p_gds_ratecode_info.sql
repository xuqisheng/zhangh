if  exists(select * from sysobjects where name = "p_gds_ratecode_info")
	drop proc p_gds_ratecode_info;
create proc p_gds_ratecode_info
	@code				char(30),			-- ������ or ������+����+���� 
	@date				datetime = null,	-- ��ѯ����
	@pc_id			char(4) = 'pcid',
	@quantity		integer	= 0
as
--================================================================================
-- Rate Code Info.
--	get info  packages from rmratedef   -- Modified by PYN 
--	�Ľ� - 2006.6.1 simon 
--================================================================================
declare
   @ls_ratecode   char(10),
   @ls_data       char(10),   -- rate
   @ls_type       char(5),
   @packages      varchar(50)

-- For Output
create table #goutput(msg	varchar(200))

--
if @date is null
	select @date = getdate()
select @date = convert(datetime,convert(char(8),@date,1))

-- 
if charindex('#', @code) > 0   -- ������������= ������+����+����  
begin
	select @ls_ratecode = substring(@code,1,charindex('#',@code) - 1) 
	select @code =  substring(@code,charindex('#',@code)+1,30)
	select @ls_data = substring(@code,1,charindex('#',@code) - 1)
	select @ls_type = substring(@code,charindex('#',@code) + 1,5)

	select @packages = isnull((select min(a.packages) from rmratedef a,rmratecode b,rmratecode_link c 
											where a.code = c.rmcode and b.code=c.code and b.code=@ls_ratecode and c.code=@ls_ratecode 
													and charindex(rtrim(@ls_type),a.type)>0
													and (a.begin_ is null or @date>=a.begin_)
													and (a.end_ is null or @date<=a.end_)
										), '')
	if @packages='' 
		select @packages=packages from rmratecode where code=@ls_ratecode 
	
	insert #goutput select @ls_ratecode+': '+descript from rmratecode where code=@ls_ratecode
	insert #goutput select @ls_data+': '+descript1 from rmratecode where code=@ls_ratecode
	insert #goutput select @ls_type+' Packages:' + @packages 
	insert #goutput select convert(char(10),date,11)+':  ����:'+rtrim(convert(char(10),quan))+'  ����:'+rtrim(convert(char(10),leftn + @quantity))+'  ʣ��:'+rtrim(convert(char(10),leftn))+'*'
			from rsv_plan_check b
			where ','+rtrim(b.rmtypes)+',' like '%,'+rtrim(@ls_type)+',%' and ','+b.ratecodes+',' like '%,'+rtrim(@ls_ratecode)+',%' and leaf = 1 and pc_id = @pc_id
	insert #goutput select convert(char(10),date,11)+':  ����:'+rtrim(convert(char(10),quan))+'  ����:'+rtrim(convert(char(10),leftn + @quantity))+'  ʣ��:'+rtrim(convert(char(10),leftn))+'' 
			from rsv_plan_check b
			where ','+rtrim(b.rmtypes)+',' like '%,'+rtrim(@ls_type)+',%' and ','+b.ratecodes+',' like '%,'+rtrim(@ls_ratecode)+',%' and leaf = 0 and pc_id = @pc_id
end
else    -- @code = ratecode
begin
	insert #goutput select descript from rmratecode where code=@code
	insert #goutput select descript1 from rmratecode where code=@code
	insert #goutput select 'Packages:' + packages from rmratecode where code=@code
end

select msg from #goutput 
return 0;
