
if exists(select * from sysobjects where name='p_gds_after_login' and type ='P')
   drop proc p_gds_after_login;
create proc p_gds_after_login
   @modu_id  char(2),
   @empno    char(10),
	@shift	 char(1),
	@langid		int
as
-- ------------------------------------------------------------------------
-- ϵͳ��½����Զ���ʾ
-- ------------------------------------------------------------------------
create table #msgout	(
	flag				char(5),
	msg				varchar(255)
)

declare		@deptno				varchar(5),
				@audit_warning		varchar(255),
				@freedb				int,
				@bdate				datetime,
				@bfdate				datetime

select @bdate = bdate1 from sysdata
select @bfdate = dateadd(day, -1, @bdate)
select @deptno = ','+rtrim(deptno)+',' from sys_empno where empno = @empno
select @audit_warning = rtrim(value) from sysoption where catalog='audit' and item='dept_warning_after_login'
if @@rowcount=0 
begin
	insert sysoption(catalog, item, value) select 'audit', 'dept_warning_after_login', '?'
	select @audit_warning = '?'
end
select @audit_warning = ','+rtrim(@audit_warning)+','

-- ------------------------------------------------------------------------
-- 1. ��������
-- ------------------------------------------------------------------------
-- 1.1 ��� ������
-- ------------------------------------------------------------------------
-- ��ѯ�Ƿ�������
insert #msgout	select 'EMAIL', 'From:' + sender + '  ' + a.subject + '......' from message_mail a
	where a.status = '1' and a.id in
	( select id from message_mailrecv b  where b.receiver = @empno  and b.tag = '0')
if @@rowcount>0 
	insert #msgout	select '-----', ''

-- ��ѯҹ���Ƿ�����
if exists(select 1 from gate where audit='T')
begin
	if @langid = 0 
		insert #msgout	select 'ERROR', '����ҹ��û������, ����ע�� !'
	else
		insert #msgout	select 'ERROR', 'Caution! Last audit is not finished !'
	insert #msgout	select '-----', ''
end

-- ��ѯҹ���Ƿ�û����
if ((select datediff(dd,bdate1,getdate()) from sysdata)=1 
		and (select datepart(hh, getdate()) from sysdata)>=6
	)
	or (select datediff(dd,bdate1,getdate()) from sysdata)>1
begin
	if @langid = 0 
		insert #msgout	select 'ERROR', '��ǰʵ��ʱ���뷹��Ӫҵ��������ϴ�, �Ƿ�û����ҹ��, �������Աע�� !'
	else
		insert #msgout	select 'ERROR', 'Caution! Now is far away from the audit date, may be night audit is not done.'
	insert #msgout	select '-----', ''
end

-- ------------------------------------------------------------------------
-- 1.2 ��� ������Ҫ���Ѳ���
-- ------------------------------------------------------------------------
if charindex(@deptno, @audit_warning) > 0
begin
	-- ��ѯ���ս��
	if exists (select 1 from yjierep where date=@bfdate and class='999') 
	begin
		declare	@jie		money, @dai		money
		select @jie = day99 from jierep where class='999'
		select @dai = sumcre from dairep where class='09000'
		if @jie<>@dai
		begin
			if @langid = 0 
				insert #msgout	select 'ERROR', '����ҹ����˵ױ�ƽ, �������Աע�� !'
			else
				insert #msgout	select 'ERROR', 'Caution! Last audit report has some errors !'
			insert #msgout	select '-----', ''
		end
	end
	
	
	-- free db limit
	declare	@db			varchar(255),
				@dbdata  	int, 			@dblog  		int, 			@dbfree  	int,
				@len			int,			@pos			int
	
	select @db = null
	select @db = rtrim(ltrim(value)) from sysoption where catalog='hotel' and item='database'
	if @@rowcount > 0  and @db is not null
	begin
		select @len = datalength(@db), @pos = charindex(',', @db)
		if @len > 0 and @pos > 0 
		begin
			select @db = substring(@db, @pos+1, @len-@pos)
			select @pos = count(1) from master.dbo.sysdatabases where name = @db
			if @pos  = 1 
			begin
				if not exists(select 1 from sysoption where catalog = 'hotel' and item = 'space_warning')
					insert sysoption(catalog, item, value) select 'hotel', 'space_warning', '100'
				select @freedb = null
				select  @freedb = convert(integer, value) from sysoption where catalog = 'hotel' and item = 'space_warning'
				select  @freedb = isnull(@freedb, 100)
				
				exec p_foxhis_helpdb @db, 'R', @dbdata output, @dblog output, @dbfree output
				if @dbfree is null
					select @dbfree = 0
				select @dbfree = @dbfree / 1000
				if @dbfree < @freedb 
				begin
					if @langid = 0 
						insert #msgout	select 'ERROR', '���ݿ�ռ����, �����ϵͳ������Աע�� !'
					else
						insert #msgout	select 'ERROR', 'Caution! database space is almost out of use.'
					insert #msgout	select '-----', ''
				end
			end
		end
	end
end 

-- ------------------------------------------------------------------------
-- 2. �Ƶ���Ի����Ѳ��� -- �빤����Ա��������� 
-- ------------------------------------------------------------------------
-- 2.1 ��� ������
-- ------------------------------------------------------------------------




-- ------------------------------------------------------------------------
-- 2.2 ��� ������Ҫ���Ѳ��� 
-- ------------------------------------------------------------------------




-- Output
select flag, msg from #msgout

return 0
;

