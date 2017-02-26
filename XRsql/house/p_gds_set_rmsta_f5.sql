
if exists(select * from sysobjects where name = "p_gds_set_rmsta_f5" and type = 'P')
   drop proc p_gds_set_rmsta_f5;
create proc p_gds_set_rmsta_f5
   @rm_no   char(5),
   @f5value char(1),
   @remark 	varchar(60),
   @empno   char(10),
   @retmode char(1) = 'R',
   @msg     varchar(60)  output
as
-- ----------------------------------------------------------------------
--	���ÿͷ���ʱ̬
--		w_gds_set_rmsta_f5 ʹ��
-- ----------------------------------------------------------------------
declare
   @ret      	int,
	@exeret		int,
   @cgetdate 	datetime,
   @f5       	char(1),
	@remarkold	varchar(60),
	@sta			char(1),
	@nsta			char(1),
	@clrmode		char(1),		-- �����ʱ̬ģʽ
	@cat			char(1)

if @f5value = ''
begin
	select @clrmode = rtrim(substring(@msg, 1, 1))
	if @clrmode is null
		select @clrmode = 'H'
end

select @ret=0,@msg='',@cgetdate = convert(datetime,convert(char(8),getdate(),1))
select @f5=tmpsta, @sta=sta from rmsta where roomno = @rm_no
if @@rowcount = 0
   begin
   select @ret=1,@msg='���Ų�����'
   if @retmode ='S'
      select @ret,@msg
   return @ret
   end

begin tran
save  tran p_gds_set_rmsta_f5_s1

-- lock
update rmsta set sta = sta where roomno = @rm_no

-- old f5
if rtrim(@f5) is not null
begin
	if not exists(select 1 from rmsta a, rmtmpsta b where a.roomno=@rm_no and a.roomno=b.roomno and a.tmpsta=b.tmpsta)
	begin
		delete rmtmpsta where roomno = @rm_no
		insert rmtmpsta (roomno, tmpsta) select @rm_no, @f5
	end
end

-- work
if rtrim(@f5) is not null
begin
	if @f5value=''
	begin
        select @cat=cat from rmstalist1 where code=@f5
		if @@rowcount=1
		begin
			if @cat<>@clrmode
			begin
				select @ret=1, @msg = '��Ǹ�������ܽ�������������õ���ʱ̬'
				goto gout
			end
		end

        select @exeret = 1 -- ��¼Ȩ�ޣ��ֿ�ǰ̨�Ϳͷ�
		if @cat='H'
			exec @exeret = p_gds_auth_check  @empno, 'rmsta!f5clr', 'R', @msg out
		else if @cat='G'
			exec @exeret = p_gds_auth_check  @empno, 'rmsta!ff5clr', 'R', @msg out
		if @exeret <> 0
		begin
			select @ret=1, @msg = '��Ǹ����û��Ȩ�޽����ǰ��ʱ̬'
            goto gout
        end

		update rmsta set logmark=logmark+1,tmpsta = '',empno = @empno,changed = getdate() where roomno = @rm_no
		if @@error <> 0
			select @ret=1, @msg = '���·�̬��ʧ�� !'
		else
		begin
			if not (exists(select 1 from rmstalist where sta=@sta and maintnmark='T') or @clrmode='G')
			begin    -- ά�޷����ô����ˣ����ǰ̨��ʱ̬Ҳ�������÷�̬
				select @nsta = substring(@remark,1,1)   -- ��һλ��ʾ������״̬
				if @nsta is null
					select @nsta='D'
				if not exists(select 1 from rmstalist where sta=@nsta and instready='T' and maintnmark='F')
					select @nsta='D'
				if @nsta = 'I'
					select @ret=1, @msg = '��̬�ɾ��Ȳ������ø��ڵ�ǰ״̬���鷿'
				else if @sta <> @nsta
				begin
					if  ( @nsta='T' and @sta in ('D') )
						or ( @nsta='R' and @sta in ('D', 'T') )
						select @ret=1, @msg = '��̬�ɾ��Ȳ������ø��ڵ�ǰ״̬���鷿'
					else
						exec @ret = p_gds_update_room_status @rm_no,'',@nsta,@cgetdate,@cgetdate,@empno,'R',@msg out
				end
			end
		end
	end
	else
	begin
		select  @remarkold = remark from rmtmpsta where roomno=@rm_no
		if @f5=@f5value and @remark=@remarkold
			select @ret=1,@msg='%1����Ϊ��״̬^' + @rm_no
		else
		begin
			update rmsta set logmark=logmark+1,tmpsta = @f5value,empno = @empno,changed = getdate() where roomno = @rm_no
			if @@error <> 0
				select @ret=1, @msg = '���·�̬��ʧ�� !'
		end
	end
end
else
begin
	if @f5value=''
		select @ret=1,@msg='%1����Ϊ��״̬^' + @rm_no
	else
	begin
		select @exeret = 1 -- ��¼Ȩ�ޣ��ֿ�ǰ̨�Ϳͷ�
		if exists(select 1 from rmstalist1 where code=@f5value and cat='H')
			exec @exeret = p_gds_auth_check  @empno, 'rmsta!f5', 'R', @msg out
		else
			exec @exeret = p_gds_auth_check  @empno, 'rmsta!ff5', 'R', @msg out
		if @exeret = 0
		begin
			update rmsta set logmark=logmark+1,tmpsta = @f5value,empno = @empno,changed = getdate() where roomno = @rm_no
			if @@error <> 0
				select @ret=1, @msg = '���·�̬��ʧ�� !'
		end
		else
			select @ret=1, @msg = '��Ǹ����û��Ȩ�����õ�ǰ��ʱ̬'
	end
end

-- end
if @ret = 0
begin
	if @f5value = ''
	begin
		if rtrim(@f5) is not null
			insert into hrmtmpsta select *,@empno,getdate(),'O' from rmtmpsta where roomno=@rm_no
		delete rmtmpsta where roomno = @rm_no
	end
	else
	begin
		if rtrim(@f5) is not null
			insert into hrmtmpsta select *,@empno,getdate(),'M' from rmtmpsta where roomno=@rm_no
		if not exists(select 1 from rmtmpsta where roomno = @rm_no)
			insert rmtmpsta select @rm_no, @f5value, @remark, @empno, getdate()
		else
			update rmtmpsta set tmpsta=@f5value, remark=@remark, empno=@empno, date=getdate()
				where roomno = @rm_no
	end
end

gout:
if @ret <> 0
   rollback tran p_gds_set_rmsta_f5_s1
commit tran

if @retmode ='S'
   select @ret,@msg

return @ret
;

