if exists(select 1 from sysobjects where name ='p_cyj_auth_do_login' and type ='P')
	drop proc p_cyj_auth_do_login;
create proc p_cyj_auth_do_login
	@pc_id			char(4),
	@appid			char(1),
	@shift			char(1),
	@empno			char(10),
	@passwd			char(8),
	@phonestr		char(8)
as

declare
	@ret				integer,
	@msg				varchar(70),
	@empname			char(20),
	@emp_groupno	char(3),
	@exclpart		char(8),
	@lockdate		datetime,
	@locked			char(1),
	@host_id			varchar(10),
	@host_name		varchar(30),
	@allows			varchar(100),
	@db_name			varchar(30)


select @host_id = rtrim(substring(host_id(), 1, 10))
select @host_name = rtrim(substring(host_name(), 1, 30))
select @db_name = rtrim(substring(db_name(), 1, 30))


select @ret = 0, @msg = ''
if charindex(@shift, '12345') = 0
	select @ret = 1, @msg = '����İ������'
else
	begin
	select @exclpart = exclpart from accthead holdlock
	select @empname = name, @emp_groupno = deptno, @locked = locked, @lockdate = lockdate, @allows = rtrim(allows)
		from sys_empno holdlock where empno = @empno and (password = @passwd or password is null and rtrim(@passwd) is null)
	   
	if @@rowcount = 0
		select @ret = 1, @msg = '�û��������ڻ���������������Է���ϵ'
	else if datediff(day, getdate(), @lockdate) < 0 and @lockdate is not null
		select @ret = 1, @msg = '����û���ʹ�������ѹ���������Է���ϵ - '+convert(char, @lockdate, 11)
	else if @locked = 'T'
		select @ret = 1, @msg = '����û����ѱ�������������Է���ϵ'
	else if @allows is not null and charindex(@pc_id, @allows) = 0
		select @ret = 1, @msg = '����Ȩʹ����̨����'
	else if not exists (select 1 from basecode  where cat = 'dept' and  code = @emp_groupno)
		select @ret = 1, @msg = '��������Է�����һ���'
	else if rtrim(@exclpart) is not null and rtrim(@exclpart) <> @pc_id
		select @ret = 4, @msg = '���ڻ��˶�ռ����, ���Ժ�'
	else
		begin
		update auth_runsta set act_date = getdate(), status = 'R', empno = @empno, name = @empname, host_id = @host_id, host_name = @host_name, shift=@shift 
			where pc_id = @pc_id and appid =  @appid
		update auth_runsta_detail set act_date = getdate(), status = 'R', empno = @empno, name = @empname, host_id = @host_id, host_name = @host_name, shift=@shift ,db_name=@db_name
			where pc_id = @pc_id and appid =  @appid and host_name = @host_name
		update sys_empno set logdate = getdate() where empno = @empno
		delete selected_account where pc_id = @pc_id
		delete accnt_set where pc_id = @pc_id
		delete account_temp where pc_id = @pc_id
		delete account_folder where pc_id = @pc_id
		end
	end

-- 
if @ret = 0 
begin
	declare	@lic1 varchar(255), @lic2 varchar(255)
	select @lic1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
	select @lic2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
	if (charindex(',oar,', @lic1)>0 or charindex(',oar,', @lic2)>0) 
		and (charindex(',nar,', @lic1)>0 or charindex(',nar,', @lic2)>0) 
		select @ret = 1, @msg = '����ͬʱ��Ȩ��/�� AR ���ִ���ģʽ����������Ȩ'
end
   
select @ret, @msg, @empname, @emp_groupno
return @ret;
