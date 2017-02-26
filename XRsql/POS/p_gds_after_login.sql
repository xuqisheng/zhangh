drop  proc p_gds_after_login;
create proc p_gds_after_login
   @modu_id  char(2),
   @empno    char(10),
	@shift	 char(1),
	@langid		int
as
-- ------------------------------------------------------------------------
-- 系统登陆后的自动提示
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
-- 1. 公共部分
-- ------------------------------------------------------------------------
-- 1.1 针对 所有人
-- ------------------------------------------------------------------------
-- 查询是否有留言
insert #msgout	select 'EMAIL', 'From:' + sender + '  ' + a.subject + '......' from message_mail a
	where a.status = '1' and a.id in
	( select id from message_mailrecv b  where b.receiver = @empno  and b.tag = '0')
if @@rowcount>0
	insert #msgout	select '-----', ''

-- 查询夜审是否做完
if exists(select 1 from gate where audit='T')
begin
	if @langid = 0
		insert #msgout	select 'ERROR', '上日夜审还没有做完, 敬请注意 !'
	else
		insert #msgout	select 'ERROR', 'Caution! Last audit is not finished !'
	insert #msgout	select '-----', ''
end

-- 查询夜审是否没有做
if ((select datediff(dd,bdate1,getdate()) from sysdata)=1
		and (select datepart(hh, getdate()) from sysdata)>=6
	)
	or (select datediff(dd,bdate1,getdate()) from sysdata)>1
begin
	if @langid = 0
		insert #msgout	select 'ERROR', '当前实际时间与饭店营业日期相隔较大, 是否没有做夜审, 请相关人员注意 !'
	else
		insert #msgout	select 'ERROR', 'Caution! Now is far away from the audit date, may be night audit is not done.'
	insert #msgout	select '-----', ''
end

-- ------------------------------------------------------------------------
-- 1.2 针对 特殊需要提醒部门
-- ------------------------------------------------------------------------
if charindex(@deptno, @audit_warning) > 0
begin
	-- 查询上日借贷
	if exists (select 1 from sysoption where catalog='pos' and item ='alone' and value='T')
	begin
		if exists (select 1 from yjierep where date=@bfdate and class='999')
		begin
			declare	@jie		money, @dai		money
			select @jie = day99 from jierep where class='999'
			select @dai = sumcre from dairep where class='09000'
			if @jie<>@dai
			begin
				if @langid = 0
					insert #msgout	select 'ERROR', '上日夜审稽核底表不平, 请相关人员注意 !'
				else
					insert #msgout	select 'ERROR', 'Caution! Last audit report has some errors !'
				insert #msgout	select '-----', ''
			end
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
						insert #msgout	select 'ERROR', '数据库空间紧张, 请电脑系统管理人员注意 !'
					else
						insert #msgout	select 'ERROR', 'Caution! database space is almost out of use.'
					insert #msgout	select '-----', ''
				end
			end
		end
	end
end

-- ------------------------------------------------------------------------
-- 2. 酒店个性化提醒部分 -- 请工程人员在下面添加
-- ------------------------------------------------------------------------
-- 2.1 针对 所有人
-- ------------------------------------------------------------------------




-- ------------------------------------------------------------------------
-- 2.2 针对 特殊需要提醒部门
-- ------------------------------------------------------------------------




-- Output
select flag, msg from #msgout

return 0
;