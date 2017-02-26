if exists (select 1 from sysobjects where name='p_foxhis_sysdefault')
   drop proc p_foxhis_sysdefault;
create proc p_foxhis_sysdefault
	@dw		varchar(30),
	@col		varchar(30),
	@val		varchar(30),
	@mode		char(1) = 'A'  -- A-append, R-Reset 
as
-- ---------------------------------------------------------------------------------------
-- 设置 sysdefault   - simon 2006.10 
-- ---------------------------------------------------------------------------------------

-- 1。基本参数校验
select @dw = isnull(ltrim(rtrim(@dw)),'') , @col = isnull(ltrim(rtrim(@col)),'') 
if @dw='' or @col='' 
	return 1
-- select @val = isnull(ltrim(rtrim(@val)),'')   -- 这个保持原汁原味 
if @val is null
	select @val = '' 
if @mode is null or @mode <> 'R' 
	select @mode='A' 


-- 2。缺省值检验部分 
-- ......


-- 3。数据更新部分 
if exists(select 1 from sysdefault where datawindow=@dw and columnname=@col)
begin
	if @mode='A' 
		return 0
	else
		update sysdefault set defaultvalue=@val where datawindow=@dw and columnname=@col
end
else
begin
	insert sysdefault(datawindow, columnname, defaultvalue) values(@val, @dw, @col) 
end

return 0
;
