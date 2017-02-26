if exists(select * from sysobjects where name = "p_gl_public_pkglink_set")
	drop proc p_gl_public_pkglink_set;

create proc p_gl_public_pkglink_set
	@accnt				char(10),						-- 当前账号 
	@accnt1				char(10),						-- 新账号:增加进Package Routing, 或从Package Routing中删除 
	@empno				char(10),
	@operation			char(3)							-- 第一位:A.增加  D.删除
																--	第二位:G.对客人操作  R.对房间操作 
as
-- Package Routing设置 
declare 
	@lic_buy_1			varchar(255),
	@lic_buy_2			varchar(255),
	@class				char(1), 
	@class1				char(1), 
	@pcrec_pkg			char(10), 
	@pcrec_pkg1			char(10), 
	@master				char(10),
	@master1				char(10),
	@accnt2				char(10),
	@accnt3				char(10),
	@count				integer, 
	@ret					integer, 
	@msg					varchar(60)

select @ret = 0, @msg = ''
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
-- 新应收账
if substring(@accnt, 1, 1) = 'A' and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
	begin
	select @class = class from ar_master where accnt = @accnt
	select @class1 = class from ar_master where accnt = @accnt1
	if @class is null
		select @ret = 1, @msg = '账号%1不存在^' + @accnt
	else if @class1 is null
		select @ret = 1, @msg = '账号%1不存在^' + @accnt1
	else if @class in ('G', 'M')
		select @ret = 1, @msg = '团体、会议账号没有Package Routing功能'
	else if @class = '' and @class1 != ''
		select @ret = 1, @msg = '账号%1非客人账号^' + @accnt1
	else if @class = 'A' and @class != 'A'
		select @ret = 1, @msg = '账号%1非AR账号^' + @accnt1
	else if @operation like 'A%' and @accnt = @accnt1
		select @ret = 1, @msg = '同一个账号不能设置Package Routing'
	else
		begin
		begin tran p_gl_public_pkglink_set_s1
		select @master  = master, @pcrec_pkg  = pcrec_pkg from ar_master where accnt = @accnt 
		select @master1 = master, @pcrec_pkg1 = pcrec_pkg from ar_master where accnt = @accnt1
		update ar_master set pcrec_pkg = pcrec_pkg where master in (@master, @master1)
		if @operation like 'A%' 
			begin
			if @pcrec_pkg != '' and @pcrec_pkg1 != ''
				begin
				if @pcrec_pkg = @pcrec_pkg1
					select @ret = 1, @msg = '账号%1与账号%2已建立了Package Routing关系^' + @accnt1+'^' + @accnt
				else
					update ar_master set pcrec_pkg = @pcrec_pkg, cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec_pkg = @pcrec_pkg1
				end
			else if @pcrec_pkg != '' or @pcrec_pkg1 != ''
				begin
				if @pcrec_pkg != ''
					update ar_master set pcrec_pkg = @pcrec_pkg, cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master1
				else
					update ar_master set pcrec_pkg = @pcrec_pkg1, cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master
				end 
			else
				begin
				update ar_master set pcrec_pkg = @accnt, cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master
				update ar_master set pcrec_pkg = @accnt, cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master1
				end
			end 
		else
			begin
			if @pcrec_pkg != @pcrec_pkg1
				select @ret = 1, @msg = '账号%1与账号%2非Package Routing关系^' + @accnt+'^' + @accnt1
			else
				begin
				if @operation like '_G'
					--	解除指定客人的Package Routing关系
					begin
					if @pcrec_pkg = @pcrec_pkg1 and @pcrec_pkg != ''
						begin
						update ar_master set pcrec_pkg = '', cby = @empno, changed = getdate(), logmark = logmark + 1 where accnt = @accnt1
						select @accnt2 = min(accnt), @count = count(1) from ar_master where pcrec_pkg = @pcrec_pkg
						if @count <= 1 
							update ar_master set pcrec_pkg = '', cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec_pkg = @pcrec_pkg
						else if @pcrec_pkg = @accnt1 
							update ar_master set pcrec_pkg = @accnt2, cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec_pkg = @pcrec_pkg
						end
					else
						select @ret = 1, @msg = '账号%1与账号%2非Package Routing关系^' + @accnt+'^' + @accnt1
					end
				else
					--	解除指定房间的Package Routing关系
					begin
					if @pcrec_pkg = @pcrec_pkg1 and @pcrec_pkg != ''
						begin
						update ar_master set pcrec_pkg = '', cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master1 and pcrec_pkg = @pcrec_pkg1
						select @accnt2 = min(accnt), @count = count(distinct master) from ar_master where pcrec_pkg = @pcrec_pkg
						if @count <= 1 
							update ar_master set pcrec_pkg = '', cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec_pkg = @pcrec_pkg
						else if @pcrec_pkg = @accnt1 
							update ar_master set pcrec_pkg = @accnt2, cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec_pkg = @pcrec_pkg
						end
					else
						select @ret = 1, @msg = '账号%1与账号%2非Package Routing关系^' + @accnt+'^' + @accnt1
					end
				end
			end
		commit tran 
		end 
	end 
else
	begin
	select @class = class from master where accnt = @accnt
	select @class1 = class from master where accnt = @accnt1
	if @class is null
		select @ret = 1, @msg = '账号%1不存在^' + @accnt
	else if @class1 is null
		select @ret = 1, @msg = '账号%1不存在^' + @accnt1
	else if @class in ('G', 'M')
		select @ret = 1, @msg = '团体、会议账号没有Package Routing功能'
	else if @class = '' and @class1 != ''
		select @ret = 1, @msg = '账号%1非客人账号^' + @accnt1
	else if @class = 'A' and @class != 'A'
		select @ret = 1, @msg = '账号%1非AR账号^' + @accnt1
	else if @operation like 'A%' and @accnt = @accnt1
		select @ret = 1, @msg = '同一个账号不能设置Package Routing'
	else
		begin
		begin tran p_gl_public_pkglink_set_s2
		select @master  = master, @pcrec_pkg  = pcrec_pkg from master where accnt = @accnt 
		select @master1 = master, @pcrec_pkg1 = pcrec_pkg from master where accnt = @accnt1
		update master set pcrec_pkg = pcrec_pkg where master in (@master, @master1)
		if @operation like 'A%' 
			begin
			if @pcrec_pkg != '' and @pcrec_pkg1 != ''
				begin
				if @pcrec_pkg = @pcrec_pkg1
					select @ret = 1, @msg = '账号%1与账号%2已建立了Package Routing关系^' + @accnt1+'^' + @accnt
				else
					update master set pcrec_pkg = @pcrec_pkg, cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec_pkg = @pcrec_pkg1
				end
			else if @pcrec_pkg != '' or @pcrec_pkg1 != ''
				begin
				if @pcrec_pkg != ''
					update master set pcrec_pkg = @pcrec_pkg, cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master1
				else
					update master set pcrec_pkg = @pcrec_pkg1, cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master
				end 
			else
				begin
				update master set pcrec_pkg = @accnt, cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master
				update master set pcrec_pkg = @accnt, cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master1
				end
			end 
		else
			begin
			if @pcrec_pkg != @pcrec_pkg1
				select @ret = 1, @msg = '账号%1与账号%2非Package Routing关系^' + @accnt+'^' + @accnt1
			else
				begin
				if @operation like '_G'
					--	解除指定客人的Package Routing关系
					begin
					if @pcrec_pkg = @pcrec_pkg1 and @pcrec_pkg != ''
						begin
						update master set pcrec_pkg = '', cby = @empno, changed = getdate(), logmark = logmark + 1 where accnt = @accnt1
						select @accnt2 = min(accnt), @count = count(1) from master where pcrec_pkg = @pcrec_pkg
						if @count <= 1 
							update master set pcrec_pkg = '', cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec_pkg = @pcrec_pkg
						else if @pcrec_pkg = @accnt1 
							update master set pcrec_pkg = @accnt2, cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec_pkg = @pcrec_pkg
						end
					else
						select @ret = 1, @msg = '账号%1与账号%2非Package Routing关系^' + @accnt+'^' + @accnt1
					end
				else
					--	解除指定房间的Package Routing关系
					begin
					if @pcrec_pkg = @pcrec_pkg1 and @pcrec_pkg != ''
						begin
						update master set pcrec_pkg = '', cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master1 and pcrec_pkg = @pcrec_pkg1
						select @accnt2 = min(accnt), @count = count(distinct master) from master where pcrec_pkg = @pcrec_pkg
						if @count <= 1 
							update master set pcrec_pkg = '', cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec_pkg = @pcrec_pkg
						else if @pcrec_pkg = @accnt1 
							update master set pcrec_pkg = @accnt2, cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec_pkg = @pcrec_pkg
						end
					else
						select @ret = 1, @msg = '账号%1与账号%2非Package Routing关系^' + @accnt+'^' + @accnt1
					end
				end
			end
		commit tran 
		end 
	end 
select @ret, @msg
;
