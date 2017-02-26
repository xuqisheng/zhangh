drop trigger t_zk_invoice_opdtl_update;
create trigger t_zk_invoice_opdtl_update
   on invoice_opdtl
   for update as

declare 	@id 			varchar(10),	@inno 			varchar(16),
			@credit		money,			@remark			varchar(254),
			@empno		varchar(10),	@crtdate			datetime,
			@pc_id		char(4),			@cby				char(10),
			@changed		datetime,		@logmark			int,
			@id_o 		varchar(10),	@inno_o 			varchar(16),
			@credit_o		money,			@remark_o			varchar(254),
			@empno_o		varchar(10),	@crtdate_o			datetime,
			@pc_id_o		char(4),			@cby_o				char(10),
			@changed_o		datetime,		@logmark_o			int,
			@billno		char(10),		@accnt			char(10),
			@unitname	varchar(50),	@sta				char(1),
			@msg			varchar(255)
        

select @id_o = id,	@inno_o = inno,@credit_o = credit,@remark_o = remark,@empno_o = empno,	@crtdate_o = crtdate,@pc_id_o = pc_id,@cby_o = cby,
			@changed_o = changed,@logmark_o = logmark from deleted
select @id = id,	@inno = inno,@credit = credit,@remark = remark,@empno = empno,	@crtdate = crtdate,@pc_id = pc_id,@cby = cby,
			@changed = changed,@logmark = logmark from inserted

select @sta = sta,@billno = billno,@accnt = accnt,@unitname = unitname from invoice_op where id = @id


if rtrim(@accnt) <> null and (@inno <> @inno_o or @credit <> @credit_o)
	insert lgfl select 'arinvoice_u',@accnt,'发票号:' + @inno_o + ' 金额:' + ltrim(rtrim(convert(char(20),@credit_o))),'发票号:' + @inno + ' 金额:' + ltrim(rtrim(convert(char(20),@credit))),@cby,@changed,''

;