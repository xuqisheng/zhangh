
if exists (select * from sysobjects where name = 'p_gds_morning_rmpost' and type ='P')
   drop proc p_gds_morning_rmpost
;
create proc p_gds_morning_rmpost
	@modu_id			char(2),
	@pc_id			char(4),
	@empno			char(10),
	@shift			char(1),
	@askmode			char(1)
as
----------------------------------------------------------
-- X ϵ�а汾���µ����˷��⴦��
--   �ù����ڶ����Ĵ�������ɣ�һ����� his_dyn5
--
-- ���� x50110 ���ڰ汾�Ѿ������Զ������µ����˷��⣬
-- ��˸ù�����Ҫ���������ڰ汾��
--   
--                    simon 2006.5.18 
----------------------------------------------------------
declare
	@ret				integer,
	@msg				varchar(60),
	@bdate			datetime,
	@rmpostdate		datetime,
	@exposted		char(1),
	@checking		char(8),
	@rmposting		char(8),
	@accnt			char(10),
	@now				datetime,
	@today			datetime,
	@half_time		datetime,
	@settime			varchar(30),
	@count			integer


select @ret=0, @msg='', @now	= getdate()
select @today = convert(datetime, convert(char(10), @now, 111))
select @bdate = convert(datetime, convert(char(10), bdate, 111)), @rmpostdate = convert(datetime, convert(char(10), rmpostdate, 111)), @exposted = exposted
	from sysdata
select @checking = checking, @rmposting = rmposting from accthead
select @half_time = dateadd(minute, datepart(minute, convert(datetime, value)),
	dateadd(hh, datepart(hh, convert(datetime, value)), convert(datetime, convert(char(10), @bdate, 111))))
	from sysoption where catalog = 'ratemode' and item = 't_half_rmrate'

-- ��ȡ�ϴ��µ����˷������˵�ʱ�� 
if not exists(select 1 from sysoption where catalog='ratemode' and item='morning_rmpost')
	insert sysoption (catalog,item,value) select 'ratemode','morning_rmpost', '2000.1.1 12:00:00'
select @settime=substring(value, 1, 30) from sysoption where catalog='ratemode' and item='morning_rmpost'

begin tran
save tran p_gds_morning_rmpost

if exists(select 1 from gate where audit='T')
	select @ret = 1, @msg = 'ϵͳ���ڽ���ҹ����'
else if rtrim(@checking) is not null or rtrim(@rmposting) is not null
	select @ret = 1, @msg = 'ϵͳ���ڽ���ҹ���⴦�� %1^' + @rmposting
else if convert(datetime, @settime) > @half_time 
	select @ret = 1, @msg = '�����µ����˷��⴦���Ѿ����'
else
begin
	select @count = count(1) from master where accnt like 'F%' and sta='I' and rmposted='F' and citime<@half_time 
	if @askmode='T'  -- ��Ѷģʽ 
	begin
		if @count = 0 
			select @ret=1, @msg='��ǰû���ʺ���������ס��¼'
		else
			select @ret=0, @msg='��ǰ��%1������ס��¼^' + convert(char(10), @count)
	end
	else
	begin					-- ����ģʽ 
		declare c_rmpost cursor for 
			select accnt from master where accnt like 'F%' and sta='I' and rmposted='F' and citime<@half_time
		open c_rmpost
		fetch c_rmpost into @accnt
		while @@sqlstatus = 0
		begin
			-- ������˹���û��msg����ֵ�����ִ����ʱ���û����Բ�ѯ
			exec @ret = p_gl_audit_rmpost_added @modu_id, @pc_id, 0, @shift, @empno, @accnt, 'RN'
			if @ret <> 0 
				select @msg = '����ʧ�ܣ�������ס��¼'
			fetch c_rmpost into @accnt
		end		
	end
end

if @ret <> 0
	rollback tran p_gds_morning_rmpost
else if @askmode = 'F' 
begin
	--	��¼ִ��ʱ��
	select @settime = convert(char(10), getdate(), 111)+' '+convert(char(8), getdate(), 8)
	update sysoption set value=@settime where catalog='ratemode' and item='morning_rmpost'
end
commit tran
select @ret, @msg
return 0
;
