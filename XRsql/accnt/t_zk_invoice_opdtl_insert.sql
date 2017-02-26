drop trigger t_zk_invoice_opdtl_insert;
create trigger t_zk_invoice_opdtl_insert
   on invoice_opdtl
   for insert as

declare 	@id 			varchar(10),	@inno 			varchar(16),
			@credit		money,			@remark			varchar(254),
			@empno		varchar(10),	@crtdate			datetime,
			@pc_id		char(4),			@cby				char(10),
			@changed		datetime,		@logmark			int,
			@billno		char(10),		@accnt			char(10),
			@unitname	varchar(50),	@sta				char(1),
			@msg			varchar(255)
        


select @id = id,	@inno = inno,@credit = credit,@remark = remark,@empno = empno,	@crtdate = crtdate,@pc_id = pc_id,@cby = cby,
			@changed = changed,@logmark = logmark from inserted
select @sta = sta,@billno = billno,@accnt = accnt,@unitname = unitname from invoice_op where id = @id
if @sta = 'O'
	select @msg = '����: ���� '
else
	select @msg = '����: Ԥ�� '

if rtrim(@accnt) <> null
	insert lgfl select 'arinvoice_i',@accnt,'',@msg + '��λ����:' + @unitname + ' ��Ʊ��:' + @inno + ' ���:' + ltrim(rtrim(convert(char(20),@credit))) + ' ��ע:' + @remark,
		@cby,@changed,''

;