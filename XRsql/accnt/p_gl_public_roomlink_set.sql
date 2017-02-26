/* �������� */
if exists(select * from sysobjects where name = "p_gl_public_roomlink_set")
	drop proc p_gl_public_roomlink_set;

create proc p_gl_public_roomlink_set
	@accnt				char(10),						/* ��ǰ�˺� */
	@accnt1				char(10),						/* ���˺�:���ӽ�����, ���������ɾ�� */
	@empno				char(10),
	@operation			char(3)							/* ��һλ:A.����;D.ɾ��
																	�ڶ�λ:G.�Կ��˲���;R.�Է������ */
as
declare 
	@lic_buy_1			varchar(255),
	@lic_buy_2			varchar(255),
	@class				char(1), 
	@class1				char(1), 
	@pcrec				char(10), 
	@pcrec1				char(10), 
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
-- ��Ӧ����
if substring(@accnt, 1, 1) = 'A' and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
	begin
	select @class = class from ar_master where accnt = @accnt
	select @class1 = class from ar_master where accnt = @accnt1
	if @class is null
		select @ret = 1, @msg = '�˺� %1 ������^' + @accnt 
	else if @class1 is null
		select @ret = 1, @msg = '�˺� %1 ������^' + @accnt1 
	else if @class in ('G', 'M')
		select @ret = 1, @msg = '���塢�����˺�û����������'
	else if @class = '' and @class1 != ''
		select @ret = 1, @msg = '�˺� %1 �ǿ����˺�^' + @accnt1 
	else if @class = 'A' and @class != 'A'
		select @ret = 1, @msg = '�˺� %1 ��AR�˺�^' + @accnt1 
	else if @operation like 'A%' and @accnt = @accnt1
		select @ret = 1, @msg = 'ͬһ���˺Ų�����������'
	else
		begin
		begin tran p_gl_public_roomlink_set_s1
		select @master  = master, @pcrec  = pcrec from ar_master where accnt = @accnt 
		select @master1 = master, @pcrec1 = pcrec from ar_master where accnt = @accnt1
		update ar_master set pcrec = pcrec where master in (@master, @master1)
		if @operation like 'A%' 
			begin
			if @pcrec != '' and @pcrec1 != ''
				begin
				if @pcrec = @pcrec1
					select @ret = 1, @msg = '�˺� %1 ���˺� %2 �ѽ�����������ϵ^' + @accnt1 +'^' + @accnt
				else
					update ar_master set pcrec = @pcrec, cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec = @pcrec1
				end
			else if @pcrec != '' or @pcrec1 != ''
				begin
				if @pcrec != ''
					update ar_master set pcrec = @pcrec, cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master1
				else
					update ar_master set pcrec = @pcrec1, cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master
				end 
			else
				begin
				update ar_master set pcrec = @accnt, cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master
				update ar_master set pcrec = @accnt, cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master1
				end
			end 
		else
			begin
			if @pcrec != @pcrec1
				select @ret = 1, @msg = '�˺� %1 ���˺� %2 ��������ϵ^' + @accnt1 +'^' + @accnt
			else
				begin
				if @operation like '_G'
					//	���ָ�����˵�������ϵ
					begin
					if @pcrec = @pcrec1 and @pcrec != ''
						begin
						update ar_master set pcrec = '', cby = @empno, changed = getdate(), logmark = logmark + 1 where accnt = @accnt1
						select @accnt2 = min(accnt), @count = count(1) from ar_master where pcrec = @pcrec
						if @count <= 1 
							update ar_master set pcrec = '', cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec = @pcrec
						else if @pcrec = @accnt1 
							update ar_master set pcrec = @accnt2, cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec = @pcrec
						end
					else
						select @ret = 1, @msg = '�˺� %1 ���˺� %2 ��������ϵ^' + @accnt1 +'^' + @accnt
					end
				else
					//	���ָ�������������ϵ
					begin
					if @pcrec = @pcrec1 and @pcrec != ''
						begin
						update ar_master set pcrec = '', cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master1 and pcrec = @pcrec1
						select @accnt2 = min(accnt), @count = count(distinct master) from ar_master where pcrec = @pcrec
						if @count <= 1 
							update ar_master set pcrec = '', cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec = @pcrec
						else if @pcrec = @accnt1 
							update ar_master set pcrec = @accnt2, cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec = @pcrec
						end
					else
						select @ret = 1, @msg = '�˺� %1 ���˺� %2 ��������ϵ^' + @accnt1 +'^' + @accnt
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
		select @ret = 1, @msg = '�˺� %1 ������^' + @accnt
	else if @class1 is null
		select @ret = 1, @msg = '�˺� %1 ������^' + @accnt1 
	else if @class in ('G', 'M')
		select @ret = 1, @msg = '���塢�����˺�û����������'
	else if @class = '' and @class1 != ''
		select @ret = 1, @msg = '�˺� %1 �ǿ����˺�^' + @accnt1 
	else if @class = 'A' and @class != 'A'
		select @ret = 1, @msg = '�˺� %1 ��AR�˺�^' + @accnt1 
	else if @operation like 'A%' and @accnt = @accnt1
		select @ret = 1, @msg = 'ͬһ���˺Ų�����������'
	else
		begin
		begin tran p_gl_public_roomlink_set_s2
		select @master  = master, @pcrec  = pcrec from master where accnt = @accnt 
		select @master1 = master, @pcrec1 = pcrec from master where accnt = @accnt1
		update master set pcrec = pcrec where master in (@master, @master1)
		if @operation like 'A%' 
			begin
			if @pcrec != '' and @pcrec1 != ''
				begin
				if @pcrec = @pcrec1
					select @ret = 1, @msg = '�˺� %1 ���˺� %2 �ѽ�����������ϵ^' + @accnt1 +'^' + @accnt
				else
					update master set pcrec = @pcrec, cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec = @pcrec1
				end
			else if @pcrec != '' or @pcrec1 != ''
				begin
				if @pcrec != ''
					update master set pcrec = @pcrec, cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master1
				else
					update master set pcrec = @pcrec1, cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master
				end 
			else
				begin
				update master set pcrec = @accnt, cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master
				update master set pcrec = @accnt, cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master1
				end
			end 
		else
			begin
			if @pcrec != @pcrec1
				select @ret = 1, @msg = '�˺� %1 ���˺� %2 ��������ϵ^' + @accnt1 +'^' + @accnt
			else
				begin
				if @operation like '_G'
					//	���ָ�����˵�������ϵ
					begin
					if @pcrec = @pcrec1 and @pcrec != ''
						begin
						update master set pcrec = '', cby = @empno, changed = getdate(), logmark = logmark + 1 where accnt = @accnt1
						select @accnt2 = min(accnt), @count = count(1) from master where pcrec = @pcrec
						if @count <= 1 
							update master set pcrec = '', cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec = @pcrec
						else if @pcrec = @accnt1 
							update master set pcrec = @accnt2, cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec = @pcrec
						end
					else
						select @ret = 1, @msg = '�˺� %1 ���˺� %2 ��������ϵ^' + @accnt1 +'^' + @accnt
					end
				else
					//	���ָ�������������ϵ
					begin
					if @pcrec = @pcrec1 and @pcrec != ''
						begin
						update master set pcrec = '', cby = @empno, changed = getdate(), logmark = logmark + 1 where master = @master1 and pcrec = @pcrec1
						select @accnt2 = min(accnt), @count = count(distinct master) from master where pcrec = @pcrec
						if @count <= 1 
							update master set pcrec = '', cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec = @pcrec
						else if @pcrec = @accnt1 
							update master set pcrec = @accnt2, cby = @empno, changed = getdate(), logmark = logmark + 1 where pcrec = @pcrec
						end
					else
						select @ret = 1, @msg = '�˺� %1 ���˺� %2 ��������ϵ^' + @accnt1 +'^' + @accnt
					end
				end
			end
		commit tran 
		end 
	end 
select @ret, @msg
;
