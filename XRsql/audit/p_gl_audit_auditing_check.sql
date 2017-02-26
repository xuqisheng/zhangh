
if exists(select * from sysobjects where name = 'p_gl_audit_auditing_check')
	drop proc p_gl_audit_auditing_check;

create proc p_gl_audit_auditing_check
	@pc_id		char(4), 
	@askmode		char(1)
as
--  ҹ���ж� */

declare
	@ret			integer, 
	@msg			varchar(60), 
	@count		integer,
	@audit		char(8), 
	@now			datetime, 
	@today		datetime, 
	@halfhour	datetime, 
	@bdate1		datetime, 
	@bdate		datetime, 
	@rpdate		datetime,
	@rmpostdate	datetime

select @now	= getdate()
select @halfhour = convert(datetime, value) from sysoption where catalog = 'ratemode' and item = 't_half_rmrate'
select @today = convert(datetime, convert(char(10), @now, 111)), @ret = 0, @msg = ''
begin tran
save tran p_gl_audit_auditing_check_s1
update sysdata set bdate = bdate 
update accthead set bdate = bdate
select @bdate1 = bdate1, @bdate = bdate, @rmpostdate = rmpostdate, @rpdate = rpdate from sysdata 
select @count = count(1) from auditprg where needinst = 'T' and retotal = 'T' and hasdone = 'T'
select @audit = audit from accthead
-- if exists (select bdate from sysdata where bdate <> rmpostdate)
if @bdate <> @rmpostdate and @bdate <> @rpdate
	begin
	if @today < @bdate
		select @ret = 1, @msg = '��������'
	if @today > @bdate
		select @ret = 1, @msg = '��������������'
	else
		begin
		if (datepart(hh, @now) < datepart(hh, @halfhour) or datepart(hh, @now) = datepart(hh, @halfhour) and datepart(minute, @now) < datepart(minute, @halfhour))
			select @ret = 1, @msg = '��������'
		else if (datepart(hh, @now) > 21 or datepart(hh, @now) = 21 and datepart(minute, @now) >=45)
			select @ret = 1, @msg = '��������������'
		else 
			select @ret = 1, @msg = '����21��45�ֺ�������������, ��������'
		end
	end
else if @bdate1 = @bdate and @count > 0
	select @ret = 1, @msg = '�ϴ��ؽ�����û�н���, ������ؽ��������������'
else if rtrim(@audit) is not null and rtrim(@audit) <> @pc_id
	select @ret = 1, @msg = '��һ̨����%1����������^' + @audit
else if @askmode = 'T'
	begin
	if rtrim(@audit) = @pc_id
		select @ret = 0, @msg = '�Ƿ�ȷ��Ҫ����������'
	else
		select @ret = 0, @msg = '�Ƿ�ȷ��Ҫ������'
	end
else
	update accthead set audit = @pc_id
if @ret <> 0
	rollback tran p_gl_audit_auditing_check_s1
commit tran
select @ret, @msg
return 0
;
