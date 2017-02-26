
if exists(select * from sysobjects where name = 'p_gl_accnt_release_resource')
	drop proc p_gl_accnt_release_resource;

create proc p_gl_accnt_release_resource
	@pc_id				char(4),
	@mdi_id				integer,
	@roomno				char(5),
	@accnt				char(10),
	@newsta				char(1),
	@shift				char(1),
	@empno				char(10),
	@ret_mode			char(1) = 'S',
	@msg					char(60)		out
as
--	�ͷ���Դ	--
declare
	@bdate				datetime,	 			--Ӫҵ����
	@billno				char(10),
	@class				char(1),
	@sta					char(1),
	@dep					datetime,
	@balance				money,
	@ret					integer,
	@groupno				char(10),
	@extra				char(30),
	@valid_sta			char(255),
	@invalid_sta		char(255),
	--
	@depby				char(10),
	@master_accnt		char(10),
	@number				integer,
	@rmtype				char(5) 

select @ret = 0, @msg = '', @billno = '', @bdate = bdate1 from sysdata
select @valid_sta = isnull((select value from sysoption where catalog = 'account' and item = 'valid_sta'), '+IRS')
select @invalid_sta = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), '-ODEX')
select @master_accnt = accnt from selected_account where type = '2' and pc_id = @pc_id and number = 0
begin tran
save tran p_gl_accnt_release_resource
-- ��ס�绰�Ǽ���
update phteleclos set settime = settime from accnt_set a
	where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = phteleclos.roomno
--
if @roomno = '' and @accnt = ''				-- ����
	begin
	update master set sta = master.sta from accnt_set a where master.accnt = a.accnt and a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0
	declare c_accnt cursor for
		select b.accnt, b.type 
		from accnt_set a, master b where b.accnt = a.accnt and a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0
		order by b.accnt
	end
else if @accnt = ''								-- ָ������
	begin
	update master set sta = master.sta from accnt_set a where master.accnt = a.accnt and a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.subaccnt = 0
	declare c_accnt cursor for
		select b.accnt, b.type 
		from accnt_set a, master b where b.accnt = a.accnt and a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.subaccnt = 0
		order by b.accnt
	end
else													-- ָ��������˺�
	begin
	update master set sta = master.sta from accnt_set a where master.accnt = a.accnt and a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.accnt = @accnt and a.subaccnt = 0
	declare c_accnt cursor for
		select b.accnt, b.type 
		from accnt_set a, master b where b.accnt = a.accnt and a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.accnt = @accnt and a.subaccnt = 0
		order by b.accnt
	end
open c_accnt
fetch c_accnt into @accnt, @rmtype 
while @@sqlstatus = 0
	begin
	select @class=b.class, @sta=b.sta, @balance=round(b.charge, 2) - round(b.credit, 2), @depby=b.depby, @extra=b.extra 
		from master b where b.accnt=@accnt 
	--
--	if charindex(@sta, @invalid_sta) > 0
--		begin
--		select @ret = 1, @msg = '%1��Ϊ����״̬^' + @accnt
--		goto RET_P
--		end
	if charindex(@sta, @invalid_sta) > 0 or @newsta = @sta
		begin
		fetch c_accnt into @accnt, @rmtype 
		continue
		end
	-- �����˻����ܽ���
	if @newsta = 'O' and substring(@extra, 1, 1) != '0'
		begin
		select @ret = 1, @msg = '�����˻�ֻ���ò��ֽ���'
		goto RET_P
		end
	-- �˷�ʱҪ��������Ϊ��
	if @newsta = 'O' and @balance != 0
		begin
		select @ret = 1, @msg = '%1��δ��ƽ^' + @accnt
		goto RET_P 
		end
	-- R״̬����ת����O״̬
	if @sta in ('I', 'S')
		begin
		if @newsta = 'O' and @depby = ''
			update master set sta = @newsta, dep = getdate(), resdep = @dep, ressta = @sta, coby = @empno, cotime = getdate(), depby = @empno, deptime = getdate(),
				cby = @empno, changed = getdate(), logmark = logmark + 1 where accnt = @accnt
		else if @newsta = 'O' and @sta = 'I'
			update master set sta = @newsta, dep = getdate(), resdep = @dep, ressta = @sta, coby = @empno, cotime = getdate(), depby = @empno, deptime = getdate(),
				cby = @empno, changed = getdate(), logmark = logmark + 1 where accnt = @accnt
		else if @newsta = 'O'
			update master set sta = @newsta, ressta = @sta, coby = @empno, cotime = getdate(), depby = @empno, deptime = getdate(),
				cby = @empno, changed = getdate(), logmark = logmark + 1 where accnt = @accnt
		else
			update master set sta = @newsta, dep = getdate(), resdep = @dep, ressta = @sta, depby = @empno, deptime = getdate(),
				cby = @empno, changed = getdate(), logmark = logmark + 1 where accnt = @accnt
		end
	-- �����ˣ��ϻ�
	if @class in ('A', 'C')
		begin 
		if @rmtype<>'' 
			exec @ret = p_gds_reserve_chktprm @accnt, '2', '', @empno, '', 1, 1, @msg out
		else 
			select @ret = 0
		end 
	-- ���塢���飺1.����Ա��2.�ͷ�Ԥ����
	else if @class in ('G', 'M')
		begin
		if exists (select 1 from master where groupno = @accnt and sta in ('I'))
			begin
			select @ret = 1, @msg = '����%1�����ڵ��Ա����, ����Ϊ��Ա�����˷�^' + @accnt
			goto RET_P
			end
		else if exists (select 1 from master where groupno = @accnt and sta in ('R'))
			begin
			select @ret = 1, @msg = '����%1����Ԥ����Ա����, ����Ϊ��Ա�����˷�^' + @accnt
			goto RET_P
			end
		else if @newsta != 'S' and exists (select 1 from master where groupno = @accnt and sta in ('S'))
			begin
			select @ret = 1, @msg = '����%1���й��˳�Ա����, ����Ϊ��Ա����^' + @accnt
			goto RET_P
			end
		if @newsta = 'O' and exists (select 1 from master where groupno = @accnt and lastnumb > 0 and charindex(sta, @valid_sta) > 0)
			begin
			select @ret = 1, @msg = '����%1�������ɳ�Ա��δ����, ����Ϊ��Ա����^' + @accnt
			goto RET_P
			end
		exec @ret = p_gds_reserve_release_block @accnt, @empno
		if @ret = 0 and @rmtype<>'' 
			exec @ret = p_gds_reserve_chktprm @accnt, '2', '', @empno, '', 1, 1, @msg out
		end
	-- ɢ�͡���Ա���˷�
	else if @class = 'F'
		begin
		if (select rtrim(value) from sysoption where catalog='account' and item='need_rmchk_over')='T' 
			begin
			exec @ret = p_zk_checkroom_check @pc_id,@mdi_id,@roomno,@accnt,1,'',@shift,@empno
			if @ret<>0 and @ret<>null
				begin
				select @ret = 1, @msg = '��δ�鷿'
				goto RET_P 
				end
			end
		exec @ret = p_gds_reserve_chktprm @accnt, '2', '', @empno, '', 1, 1, @msg out
		end
	--
	if @newsta = 'S'
		begin
		exec p_GetAccnt1 @type = 'BIL', @accnt = @billno out
		select @billno = 'S' + substring(@billno, 2, 9)
		insert billno (billno, accnt, bdate, empno1, shift1) select @billno, @accnt, @bdate, @empno, @shift
		end
	fetch c_accnt into @accnt, @rmtype 
	end
RET_P:
close c_accnt
deallocate cursor c_accnt
if @ret != 0
	rollback tran p_gl_accnt_release_resource
commit tran
if @ret_mode = 'S'
	select @ret, @msg
return @ret;
