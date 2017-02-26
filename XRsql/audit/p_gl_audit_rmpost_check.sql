/* ���ȼ���ܷ�����⣻����ǰ���ȡ���˲������ѣ�ҹ���Check In�ĵ�����ʾ�����Զ������շ��� */

if  exists(select * from sysobjects where name = 'p_gl_audit_rmpost_check')
	drop proc p_gl_audit_rmpost_check;

create proc p_gl_audit_rmpost_check
	@pc_id			char(4),
	@realpost		char(1)
as
declare
	@bdate			datetime,
	@rmpostdate		datetime,
	@exposted		char(1),
	@checking		char(8),
	@rmposting		char(8),
	@today			datetime,
	@now				datetime,
	@ret				integer,
	@halfhour		datetime,
	@msg				varchar(60)


select @now	= getdate()
select @halfhour = convert(datetime, value) from sysoption where catalog = 'ratemode' and item = 't_half_rmrate'
select @today = convert(datetime, convert(char(10), @now, 111)), @ret = 0, @msg = ''
begin tran
save tran p_gl_audit_rmpost_check
update sysdata  set bdate = bdate
update accthead set bdate = bdate
select @bdate = convert(datetime, convert(char(10), bdate, 111)),
	@rmpostdate = convert(datetime, convert(char(10), rmpostdate, 111)), @exposted = exposted
	from sysdata
select @checking = checking, @rmposting = rmposting from accthead
//
if @bdate = @rmpostdate
	select @ret = 1, @msg = convert(char(10), @rmpostdate, 111) + '�����ѹ�'
else if @today < @bdate
	select @ret = 1, @msg = '������������9��45�ֺ������'
else if @today = @bdate and convert(char(8), @now, 108) < "21:45"
	select @ret = 1, @msg = '��������9��45�ֺ������'
else if rtrim(@checking) is not null and rtrim(@checking) <> @pc_id
	select @ret = 1, @msg = '��һ̨����' + @checking + '���ڷ���Ԥ��'
else if rtrim(@rmposting) is not null and rtrim(@rmposting) <> @pc_id
	select @ret = 1, @msg = '��һ̨����' + @rmposting + '����ʵ������'
else
	update accthead set checking = @pc_id
//
if @ret != 0
	rollback tran p_gl_audit_rmpost_check
commit tran
select @ret, @msg
return 0;
