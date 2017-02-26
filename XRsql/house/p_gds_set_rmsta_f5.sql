
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
--	设置客房临时态
--		w_gds_set_rmsta_f5 使用
-- ----------------------------------------------------------------------
declare
   @ret      	int,
	@exeret		int,
   @cgetdate 	datetime,
   @f5       	char(1),
	@remarkold	varchar(60),
	@sta			char(1),
	@nsta			char(1),
	@clrmode		char(1),		-- 解除临时态模式
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
   select @ret=1,@msg='房号不存在'
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
				select @ret=1, @msg = '抱歉，您不能解除其他部门设置的临时态'
				goto gout
			end
		end

        select @exeret = 1 -- 记录权限，分开前台和客房
		if @cat='H'
			exec @exeret = p_gds_auth_check  @empno, 'rmsta!f5clr', 'R', @msg out
		else if @cat='G'
			exec @exeret = p_gds_auth_check  @empno, 'rmsta!ff5clr', 'R', @msg out
		if @exeret <> 0
		begin
			select @ret=1, @msg = '抱歉，您没有权限解除当前临时态'
            goto gout
        end

		update rmsta set logmark=logmark+1,tmpsta = '',empno = @empno,changed = getdate() where roomno = @rm_no
		if @@error <> 0
			select @ret=1, @msg = '更新房态表失败 !'
		else
		begin
			if not (exists(select 1 from rmstalist where sta=@sta and maintnmark='T') or @clrmode='G')
			begin    -- 维修房不用处理了；解除前台临时态也不用设置房态
				select @nsta = substring(@remark,1,1)   -- 第一位表示解除后的状态
				if @nsta is null
					select @nsta='D'
				if not exists(select 1 from rmstalist where sta=@nsta and instready='T' and maintnmark='F')
					select @nsta='D'
				if @nsta = 'I'
					select @ret=1, @msg = '房态干净度不能设置高于当前状态或检查房'
				else if @sta <> @nsta
				begin
					if  ( @nsta='T' and @sta in ('D') )
						or ( @nsta='R' and @sta in ('D', 'T') )
						select @ret=1, @msg = '房态干净度不能设置高于当前状态或检查房'
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
			select @ret=1,@msg='%1房已为本状态^' + @rm_no
		else
		begin
			update rmsta set logmark=logmark+1,tmpsta = @f5value,empno = @empno,changed = getdate() where roomno = @rm_no
			if @@error <> 0
				select @ret=1, @msg = '更新房态表失败 !'
		end
	end
end
else
begin
	if @f5value=''
		select @ret=1,@msg='%1房已为本状态^' + @rm_no
	else
	begin
		select @exeret = 1 -- 记录权限，分开前台和客房
		if exists(select 1 from rmstalist1 where code=@f5value and cat='H')
			exec @exeret = p_gds_auth_check  @empno, 'rmsta!f5', 'R', @msg out
		else
			exec @exeret = p_gds_auth_check  @empno, 'rmsta!ff5', 'R', @msg out
		if @exeret = 0
		begin
			update rmsta set logmark=logmark+1,tmpsta = @f5value,empno = @empno,changed = getdate() where roomno = @rm_no
			if @@error <> 0
				select @ret=1, @msg = '更新房态表失败 !'
		end
		else
			select @ret=1, @msg = '抱歉，您没有权限设置当前临时态'
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

