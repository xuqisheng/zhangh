
-- 辅助工作表 
//if exists(select * from sysobjects where name = "host_accnt" and type='U')
//	drop table host_accnt;
//create table host_accnt
//(
//	host_id		varchar(30)		default '' 	not null,
//   accnt     	char(10) 				not null
//)
//exec sp_primarykey host_accnt,host_id,accnt;
//create unique index index1 on host_accnt(host_id,accnt);


if exists(select * from sysobjects where name = "p_gds_reserve_chktprm")
	drop proc p_gds_reserve_chktprm
;
create proc p_gds_reserve_chktprm
	@accnt           char(10),        -- 帐号 
	@request         char(20),        -- 曾经非常重要的参数，现在无用
	@idcheck         char(1),        -- 判断脏房入住 
	@empno           char(10),        -- 操作员
	@nick           char(5),        -- 假名生成序号
	@ndmaingrpmst    int,				-- 是否要维护团体主单 
	@grpmstlogmark   int,  				-- 是否要记录日志 
	@nullwithreturn  varchar(60) = null output
as
-- ------------------------------------------------------------------------------------
--
--	p_gds_reserve_chktprm
--		in SC, using - p_gds_sc_chktprm 
--		
--		全新的排房程序
--		注意针对虚拟房号的处理:  roomno>='0' 表示分房了, 否则表示没有分房.
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
-- 	分房,退房,换房,预订转入住,预订取消,预订恢复,撤消结帐退房等状态转换及提前,延期等日期更改等
-- 	当本过程更新了客人信息时,返回标志给外层应用以正确记录客人日志
-- ------------------------------------------------------------------------------------
declare
	@ret        int,
   @msg        varchar(60),
	@class 		char(1),
	@bdate      datetime,
	@accnt0		char(10),		-- 原始的 accnt 
	@saccnt		char(10),
	@master		char(10),
	@host_id		varchar(30),
	@mststa     char(1),				@omststa    char(1),
	@type    	char(5),				@otype      char(5),
	@roomno		char(5),				@oroomno    char(5),
	@s_time     datetime,			@oarr       datetime,
	@e_time     datetime,			@odep       datetime,
	@rmnum		int,					@ormnum		int,
	@blkcode		char(10),			@oblkcode	char(10),
	@count		int,
	@oldsta		char(1),	-- 帐号原来的状态
	@staup		char(1),	-- 状态同步条件
	@gstno		int

declare
	@blkup		char(1),			-- 同步是否存在 BLOCK 
	@blkno		char(10),		
	@blknos		varchar(100),	-- 一个同住里面可能有多个 BLKCODE 
	@blktype		char(5),
	@blkarr		datetime,
	@blkdep		datetime

declare @tran_save_point varchar(32) 
select @tran_save_point = 'p_gds_reserve_chktprm_s' + ltrim(convert(char(10), @@trancount)) 

select @ret=0, @msg='', @accnt0=@accnt

-- 存放同住/共享宾客账号
select @host_id = host_id()
delete host_accnt where host_id=@host_id

-- 事务开始
begin tran 
save  tran @tran_save_point

-- 设置排它信号
update chktprm set code = 'A'  

-- 从 master 中提取数据
select @mststa=sta, @omststa=osta, @type=type, @otype=otype, @roomno=roomno, @oroomno=oroomno,
		@s_time=arr, @e_time=dep, @oarr=oarr, @odep=odep, @rmnum=rmnum, @ormnum=ormnum,
		@class=class, @saccnt=saccnt, @master=master, @blkcode=blkcode,  @oblkcode=oblkcode 
	from master where accnt = @accnt
if @@rowcount = 0
begin
	select @ret = 1, @msg='记录不存在'
	goto RET_P
end

-- 团体会议的房数特殊处理 
if @class in ('G','M','C') 
begin
	if @type<>'' and not exists(select 1 from typim where type=@type and tag='P')
	begin
		select @ret = 1, @msg='%1不匹配^房类'
		goto RET_P
	end
	select @rmnum=1, @ormnum=1, @gstno=0 
end

--
if @class in ('G','M')
begin 
	if @blkcode<>'' and exists(select 1 from rsvsrc where accnt=@accnt and type<>'PM')
	begin
		select @ret = 1, @msg='应用BLOCK的时候，不能另外预留资源'
		goto RET_P
	end
end 

-- 没有启用假房的时候，直接退出
if @class in ('G','M','C')  and (@type='' and @otype='')
begin
	if @class<>'C' 
		exec @ret = p_gds_update_group @accnt, @empno, @grpmstlogmark,@msg output
	goto RET_P
end 

if @class='F' and rtrim(@type) is null 
begin
	select @ret = 1, @msg='房类错误'
	goto RET_P
end

if @roomno=null  select @roomno=''
if @roomno='' and @oroomno like '#%' 
	select @roomno=@oroomno 
if @omststa='' select @omststa = ''

--
if (charindex(@mststa,'RICG')=0 and charindex(@omststa,'RICG')=0)
	or ( @mststa=@omststa and @type=@otype and @roomno=@oroomno and @rmnum=@ormnum and @blkcode=@oblkcode 
			and datediff(dd,@s_time,@oarr)=0 and datediff(dd,@e_time,@odep)=0 )
begin
	-- 可能有时间更新
	update rsvsrc set arr=a.arr from master a 
		where a.accnt=@accnt and rsvsrc.accnt=a.accnt and datediff(dd,rsvsrc.arr,a.arr)=0 and rsvsrc.arr<>a.arr and rsvsrc.id=0
	update rsvsrc set dep=a.dep from master a 
		where a.accnt=@accnt and rsvsrc.accnt=a.accnt and datediff(dd,rsvsrc.dep,a.dep)=0 and rsvsrc.dep<>a.dep and rsvsrc.id=0

	select @ret = 0, @msg='不涉及客房资源变化'
	--拆分每日房价记录，插入到rsvsrc_detail   yjw 2008-5-29
	exec p_yjw_rsvsrc_detail_accnt @accnt
	--
	goto RET_P
end

-- 缺省自动同步
if @nick is null or @nick<>'p'
	select @nick = 'U'

----------------------------------------------------------------------------------------------------------------------
-- 状态同步条件：入住.   其他不行，比如：预定取消、入住取消、结账等，有的需要理由，有的的确需要逐个处理
----------------------------------------------------------------------------------------------------------------------
if @mststa<>@omststa
begin
	if @mststa='I' and @omststa not in ('O', 'S')
		select @staup = 'T'
	else
		select @staup = 'F'
end
else
	select @staup = '-'

-----------------------------------------------------------
-- 存在同住，处理方法：删除原来的预留，全部当作新的预定处理
-----------------------------------------------------------
-- 记录相关
insert host_accnt select @host_id, accnt from rsvsrc where saccnt=@saccnt
-- select @count = count(1) from rsvsrc a, rsvsrc b where a.accnt=@accnt and a.saccnt=b.saccnt
select @count = count(1) from host_accnt where host_id=@host_id 

if @count > 1 and  @nick = 'U' and @staup <> 'F' 
begin
	-- 删除预留纪录。如果有BLOCK资源，需要事先释放 
	if exists(select 1 from rsvsrc where saccnt=@saccnt and blkcode<>'') 
		select @blkup='T' 
	else 
		select @blkup='F' 
	if @blkup='T' 
	begin 
		delete rsvsrc_blk where host_id=@host_id
		select @blktype=type, @blkarr=begin_, @blkdep=end_ from rsvsaccnt where saccnt=@saccnt 
		select @blkno = '', @blknos = ''
		select @blkno = isnull((select min(blkcode) from rsvsrc where saccnt=@saccnt and blkcode>@blkno), '') 
		while @blkno <> ''
		begin 
			select @blknos = @blknos + @blkno  -- 把同住中涉及的 blkcode 保存起来 
			exec p_gds_reserve_rsv_blkdiff @host_id, @blkno, @blktype, @blkarr, @blkdep, 'before+'
			select @blkno = isnull((select min(blkcode) from rsvsrc where saccnt=@saccnt and blkcode>@blkno), '') 
		end 
	end 

	exec p_gds_reserve_rsv_del_saccnt @saccnt
	delete rsvsrc where saccnt=@saccnt

	if @blkup='T' 
	begin 
		select @blknos = ltrim(@blknos)
		while rtrim(@blknos) is not null
		begin 
			select @blkno = substring(@blknos, 1, 10) 
			select @blknos = ltrim(stuff(@blknos, 1, 10, ''))

			exec p_gds_reserve_rsv_blkdiff @host_id, @blkno, @blktype, @blkarr, @blkdep, 'after+'
		end 
		exec @ret = p_gds_reserve_rsv_blkuse @host_id, '', @blktype, @empno 
		delete rsvsrc_blk where host_id=@host_id
		if @ret<>0
		begin 
			select @msg='chktprm blkup error' 
			goto RET_P
		end 
	end 
	
	-- 同步处理，虚拟房号可以不变 
	if @roomno < '0'
	begin
		if @oroomno >= '0' -- 去掉房号的，需要生成虚拟房号；原来有房号的（不管是不是虚拟的），保持不变 
		begin
			exec p_GetAccnt1 'SRM', @roomno output
			select @roomno = '#' + rtrim(@roomno)
		end
	end
	
	-- work one by one 
	declare	@gsta 		char(1), 
				@gtype 		char(5), 
				@groomno 	char(5), 
				@garr 		datetime, 
				@gdep 		datetime 

	select @accnt = isnull((select min(accnt) from host_accnt where host_id=@host_id and accnt>''), '')
	while @accnt <> ''
	begin
		select @gsta=osta, @gtype=otype, @groomno=oroomno, @garr=oarr, @gdep=odep from master where accnt=@accnt
		select @oldsta = @gsta

		-- 原来入住的客房，需要调整 rmsta 
		if @gsta = 'I' and @groomno>='0' and (@groomno <> @roomno or (@groomno = @roomno and @mststa <> 'I'))
	   	exec p_gds_reserve_flrmsta @groomno,@accnt,'DELE',@empno

		----------------------------------------------------------------------
		-- 同步处理：更新新的入住信息，如：arr, 清空老的信息，如：oarr 
		----------------------------------------------------------------------
		if @accnt <> @accnt0 
		begin
			--		房号同步条件：saccnt 相同
			select @gtype=@type, @groomno=@roomno
			-- 状态 
			if @staup='T' and @oldsta=@omststa
				select @gsta = @mststa 
			-- 	日期同步条件：对应字段的日期相同，如arr相同，或者dep相同
			if datediff(dd,@oarr,@garr)=0 and datediff(dd,@oarr,@s_time)<>0
				select @garr = @s_time
			if datediff(dd,@odep,@gdep)=0 and datediff(dd,@odep,@e_time)<>0
				select @gdep = @e_time
	
			-- 已经入住的不能修改到日 modi by zk 2008-10-20
			if @class='G' or @class='M' -- 团队会议不更新 ormnum  -- 似乎同步里面不会出现团队哦 
				begin
				update master set otype='', type=@gtype, oroomno='', roomno=@groomno, -- ormnum=0, 
									osta='', sta=@gsta, arr=@garr, oarr=null, dep=@gdep, odep=null, oblkcode='' 
					where accnt = @accnt and sta <> 'I' 
				update master set otype='', type=@gtype, oroomno='', roomno=@groomno, -- ormnum=0, 
									osta='', sta=@gsta, oarr=null, dep=@gdep, odep=null, oblkcode='' 
					where accnt = @accnt and sta = 'I'
				end
			else 
				begin
				update master set otype='', type=@gtype, oroomno='', roomno=@groomno, ormnum=0, 
									osta='', sta=@gsta, arr=@garr, oarr=null, dep=@gdep, odep=null, oblkcode='' 
					where accnt = @accnt and sta <> 'I'
				update master set otype='', type=@gtype, oroomno='', roomno=@groomno, ormnum=0, 
									osta='', sta=@gsta, oarr=null, dep=@gdep, odep=null, oblkcode='' 
					where accnt = @accnt and sta = 'I'
				end
		end 
		else
		begin
			if @class='G' or @class='M' -- 不更新 ormnum 
				update master set otype='', roomno=@roomno, oroomno='',           osta='', oarr=null, odep=null, oblkcode='' where accnt = @accnt
			else
				update master set otype='', roomno=@roomno, oroomno='', ormnum=0, osta='', oarr=null, odep=null, oblkcode='' where accnt = @accnt
		end

		if exists(select 1 from host_accnt where host_id=@host_id and accnt>@accnt)
			select @msg = 'rsvchk=0;'  -- 同步的前面帐户忽略资源检查 
		else 
			select @msg = ''
		exec @ret = p_gds_reserve_chktprm_son @accnt,@request,@idcheck,@empno,@oldsta,@ndmaingrpmst,@grpmstlogmark,@msg output  -- nick->share 
		if @ret<>0
			goto RET_P
		else if @accnt<>@accnt0 -- 记录日志。@accnt0 在客户端已经记录了 
			update master set cby=@empno, changed=getdate(), logmark=logmark+1 where accnt=@accnt 
		select @accnt = isnull((select min(accnt) from host_accnt where host_id=@host_id and accnt>@accnt), '')
	end
end
else
begin		-- 没有同住纪录，直接处理
	exec @ret = p_gds_reserve_chktprm_son @accnt,@request,@idcheck,@empno,@nick,@ndmaingrpmst,@grpmstlogmark,@msg output
	-- 有同住关系，但是不同步换房处理的时候，需要重新调整 master  
	if @ret=0 and @count>1 and @mststa=@omststa and @type+@roomno<>@otype+@oroomno 
	begin
		if @accnt = @master 
		begin
			select @master=min(accnt) from host_accnt where host_id=@host_id and accnt<>@accnt 
			update master set master=@master from host_accnt a where a.host_id=@host_id and master.accnt=a.accnt and a.accnt<>@accnt 
		end
		else
			update master set master=accnt where accnt=@accnt 
	end
end

--拆分每日房价记录，插入到rsvsrc_detail   yjw 2008-5-29
-- exec p_yjw_rsvsrc_detail_accnt @accnt

-- Proc exit
RET_P:
if @ret <> 0 
	rollback tran @tran_save_point
commit   tran 
delete host_accnt where host_id = @host_id 
if @nullwithreturn is null
   select @ret,@msg 
else
   select @nullwithreturn = @msg
return @ret
;
