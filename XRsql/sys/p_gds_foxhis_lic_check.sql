
if exists (select 1 from sysobjects where name = 'p_gds_foxhis_lic_check' and type='P')
	drop proc p_gds_foxhis_lic_check
;
create proc  p_gds_foxhis_lic_check 
	@lic		varchar(30),
	@retmode	char(1)='R',
	@ret		int=0 				output,
	@msg		varchar(60)=''		output 
as
--------------------------------------------------------------------------------
--  系统授权判断 
--------------------------------------------------------------------------------
declare	@lic1 varchar(255), 
			@lic2 varchar(255)

-- lic 
select @lic1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')

-- 
select @lic=isnull(ltrim(rtrim(@lic)), '')
if @lic = '' 
begin
	select @ret=1, @msg='授权码为空'
end
else
begin
	if substring(@lic,1,1)<>','
		select @lic = ','+@lic 
	if substring(@lic,char_length(@lic),1)<>','
		select @lic = @lic+',' 
	
	if charindex(@lic, @lic1)=0 and charindex(@lic, @lic2)=0
		select @ret=1, @msg='抱歉，当前功能未授权'
end

-- output 
if @retmode = 'S'
	select @ret, @msg 
return @ret 
;
