
if exists(select * from sysobjects where name = 'p_gl_accnt_update_balance' and type='P')
	drop proc p_gl_accnt_update_balance;

create proc p_gl_accnt_update_balance
	@accnt				char(10),					-- �ʺ� 
	@pccode				char(5),						-- ������ 
	@charge				money,						-- �跽 
	@credit				money,						-- ���� 
	@roomno				char(5)		out,			-- ���Ÿ��� 
	@groupno				char(10)		out,			-- �źŸ��� 
	@lastnumb			integer		out,			
	@lastinumb			integer		out,
	@balance				money			out,
	@class				char(3)		out,			-- ������ 
	@msg					varchar(60)	out			-- ������Ϣ 
as
-- ����ʱ��������Ӧ���ݵĸ��� 
-- ���ʹ���:�ȸ�������������,����һ���ֲ�����¼��ϸ�� 
-- Master.LastinumbתΪPackage_detail.Numberָ�� 

declare
	@statype				char(1),
	@sta					char(1),
	@status				char(10),				-- ���������˵�״̬ 
	@step1				integer,
	@step2				integer,
	@ret					integer

select @status = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), '-ODEX')
select @ret = 0, @statype = substring(@status, 1, 1)
--
if @pccode = '' and @charge = 0 and @credit = 0
	select @step1 = 0, @step2 = 1
else
	select @step1 = 1, @step2 = 0
begin tran
save tran p_gl_accnt_update_balance_s1
update master set charge = charge + @charge, credit = credit + @credit, lastnumb = lastnumb + @step1, lastinumb = lastinumb + @step2
	where accnt = @accnt
if @@rowcount = 0 
	select @ret = 1, @msg = '�ʺ�['+rtrim(@accnt)+']������^' 
else
	begin
	select @class = market, @sta = sta from master where accnt = @accnt
	if (@statype = '-' and charindex(@sta, @status) = 0 or @statype != '-' and charindex(@sta, @status) > 0)
		select @msg = sta, @lastnumb = lastnumb, @lastinumb = lastinumb, @balance = charge - credit, @roomno = roomno, @groupno = groupno
			from master where accnt = @accnt
	else if charindex(@sta, "ODE") > 0
		select @ret = 1, @msg = '�ʺ�['+rtrim(@accnt)+']�Ѿ�����^' 
	else 
		select @ret = 1, @msg = '�ʺ�['+rtrim(@accnt)+']��Ӧ״̬���������׷���,����^'
	end
if @ret != 0
   rollback tran p_gl_accnt_update_balance_s1
commit tran 
return @ret
;
