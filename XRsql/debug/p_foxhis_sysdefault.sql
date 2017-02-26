if exists (select 1 from sysobjects where name='p_foxhis_sysdefault')
   drop proc p_foxhis_sysdefault;
create proc p_foxhis_sysdefault
	@dw		varchar(30),
	@col		varchar(30),
	@val		varchar(30),
	@mode		char(1) = 'A'  -- A-append, R-Reset 
as
-- ---------------------------------------------------------------------------------------
-- ���� sysdefault   - simon 2006.10 
-- ---------------------------------------------------------------------------------------

-- 1����������У��
select @dw = isnull(ltrim(rtrim(@dw)),'') , @col = isnull(ltrim(rtrim(@col)),'') 
if @dw='' or @col='' 
	return 1
-- select @val = isnull(ltrim(rtrim(@val)),'')   -- �������ԭ֭ԭζ 
if @val is null
	select @val = '' 
if @mode is null or @mode <> 'R' 
	select @mode='A' 


-- 2��ȱʡֵ���鲿�� 
-- ......


-- 3�����ݸ��²��� 
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
