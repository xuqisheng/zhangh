
if exists(select * from sysobjects where name = "p_gds_get_login_info")
	drop proc p_gds_get_login_info
;
create proc p_gds_get_login_info
	@retmode		char(1),
	@empno		varchar(10) output,
	@shift		char(1) output,
	@pc_id		char(4) output,
	@appid		varchar(5) output
as
--------------------------------------------------------------------------------------
--	自动提取系统登录信息。依据：数据库连接 
--------------------------------------------------------------------------------------
declare	@host_id	varchar(30),
			@count	int,
			@ret 		int 

select @host_id = host_id(), @pc_id='', @shift='', @empno='', @appid='' 
select @count = count(1) from auth_runsta where host_id=@host_id and status='R' 
if @count=1 
begin
	select @pc_id=pc_id, @shift=shift, @empno=empno, @appid=appid from auth_runsta where host_id=@host_id and status='R'
	if rtrim(@shift) is null or charindex(@shift, '12345')=0 select @shift='3' 
	select @ret = 0
end
else
	select @ret = 1

if @retmode='S' 
	select @empno, @shift, @pc_id, @appid 
return @ret 
;
