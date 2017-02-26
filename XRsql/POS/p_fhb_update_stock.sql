create proc p_fhb_update_stock 
	@pc_id	char(4),
	@id	int,
	@mode	char(1),
	@type	char(2),
	@ret	int out,
	@msg varchar(60) out
as

declare	@istcode	char(3),
		@ostcode	char(3),
		@code	char(12),
		@subid	int,
		@number	money,
		@price	money,
		@amount	money,
		@ret1	int

--根据不同操作，不同单据类型调整库存
select @ret = -@id,@msg = '库存更新成功！'
declare stock_cur cursor for select a.istcode,isnull(a.ostcode,''),b.code,b.subid 
			from pos_st_documst a,pos_st_docudtl b 
				where a.id = b.id and a.id = @id
open stock_cur
if @mode = 'A'
begin
	if @type = '01' or @type = '04' or @type = '05'			--新增入库单或盘点单或差价单
	begin
		fetch stock_cur into @istcode,@ostcode,@code,@subid
		while @@sqlstatus=0
		begin
			exec p_fhb_docu_jd @id = @id,@subid = @subid,@stcode = @istcode,@code = @code,@flag = 'D',@ret = @ret1 out,@msg = @msg out
			if @@sqlstatus <> 0
			begin
				select @ret = 1,@msg = '库存更新失败！'
				return 0
			end
			if @ret1 = -1
			begin
				select @ret = 1
				return 0
			end
			fetch stock_cur into @istcode,@ostcode,@code,@subid
		end
	end
	else if @type = '02'					--销售单
	begin
		fetch stock_cur into @istcode,@ostcode,@code,@subid
		while @@sqlstatus=0
		begin
			exec p_fhb_docu_jd @id = @id,@subid = @subid,@stcode = @ostcode,@code = @code,@flag = 'C',@ret = @ret1 out,@msg = @msg out
			if @@sqlstatus <> 0
			begin
				select @ret = 1,@msg = '库存更新失败！'
				return 0
			end
			if @ret1 = -1
			begin
				select @ret = 1
				return 0
			end
			fetch stock_cur into @istcode,@ostcode,@code,@subid
		end
	end
	else if	@type = '03' 					--调拨单
	begin
		fetch stock_cur into @istcode,@ostcode,@code,@subid
		while @@sqlstatus=0
		begin
			--调出部门       必须先贷方，再借方【数量为0,金额不为0的情况处理】
			exec p_fhb_docu_jd @id = @id,@subid = @subid,@stcode = @ostcode,@code = @code,@flag = 'C',@ret = @ret1 out,@msg = @msg out
			if @@sqlstatus <> 0
			begin
				select @ret = 1,@msg = '库存更新失败！'
				return 0
			end
			if @ret1 = -1
			begin
				select @ret = 1
				return 0
			end
			--调入部门
			exec p_fhb_docu_jd @id = @id,@subid = @subid,@stcode = @istcode,@code = @code,@flag = 'D',@ret = @ret1 out,@msg = @msg out
			if @@sqlstatus <> 0
			begin
				select @ret = 1,@msg = '库存更新失败！'
				return 0
			end
			if @ret1 = -1
			begin
				select @ret = 1
				return 0
			end
			fetch stock_cur into @istcode,@ostcode,@code,@subid
		end
	end
	--if @type = '00' 结转单不更改库存数
	select @ret = -@id,@msg = ''
end
else if @mode = 'D'
begin
	if @type = '01' or @type = '04'			--删除入库单或盘点单
	begin
		fetch stock_cur into @istcode,@ostcode,@code,@subid
		while @@sqlstatus=0
		begin
			exec p_fhb_docu_jd @id = @id,@subid = @subid,@stcode = @istcode,@code = @code,@flag = 'C',@ret = @ret1 out,@msg = @msg out
			if @@sqlstatus <> 0
			begin
				select @ret = 1,@msg = '库存更新失败！'
				return 0
			end
			if @ret1 = -1
			begin
				select @ret = 1
				return 0
			end
			fetch stock_cur into @istcode,@ostcode,@code,@subid
		end
	end
	else if @type = '02'					--销售单
	begin
		fetch stock_cur into @istcode,@ostcode,@code,@subid
		while @@sqlstatus=0
		begin
			exec p_fhb_docu_jd @id = @id,@subid = @subid,@stcode = @ostcode,@code = @code,@flag = 'D',@ret = @ret1 out,@msg = @msg out
			if @@sqlstatus <> 0
			begin
				select @ret = 1,@msg = '库存更新失败！'
				return 0
			end
			if @ret1 = -1
			begin
				select @ret = 1
				return 0
			end
			fetch stock_cur into @istcode,@ostcode,@code,@subid
		end
	end
	else if	@type = '03' 					--调拨单
	begin
		fetch stock_cur into @istcode,@ostcode,@code,@subid
		while @@sqlstatus=0
		begin
			--调入部门
			exec p_fhb_docu_jd @id = @id,@subid = @subid,@stcode = @istcode,@code = @code,@flag = 'C',@ret = @ret1 out,@msg = @msg out
			if @@sqlstatus <> 0
			begin
				select @ret = 1,@msg = '库存更新失败！'
				return 0
			end
			if @ret1 = -1
			begin
				select @ret = 1
				return 0
			end
			--调出部门
			exec p_fhb_docu_jd @id = @id,@subid = @subid,@stcode = @ostcode,@code = @code,@flag = 'D',@ret = @ret1 out,@msg = @msg out
			if @@sqlstatus <> 0
			begin
				select @ret = 1,@msg = '库存更新失败！'
				return 0
			end
			if @ret1 = -1
			begin
				select @ret = 1
				return 0
			end
			fetch stock_cur into @istcode,@ostcode,@code,@subid
		end
	end
	select @ret = 0,@msg = ''
end
close stock_cur
deallocate cursor stock_cur;