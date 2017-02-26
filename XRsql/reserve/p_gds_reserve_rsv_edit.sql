----------------------------------------------------------------------------------------------
--		客房资源管理核心程序
--
--		
--		1.考虑到散客, 团体同时调用的情况, 参数光一个账号不行,必须带上客房资源的信息 (比如团体纯预留)
--		2.有客房的情况下, saccnt 可以自动生成；但是房类同住，需要有相应的需求参数；
--
--
--			处理上可以总体分为两种情况
--				1、与其他记录没有牵连，自己独立处理；
--				2、有牵连，需要拆散相关的 saccnt, 然后重新建立；
--
--		saccnt 的预留、分配、排房 （这种想法放弃*****，看下面）
--			1、quan>1 对应的 rsvsrc 肯定只有一行。此时，rsvsrc.id>0 就表示是纯预留，没有分配数，否则有 1 个分配数；
--			2、quan=1 对应的 rsvsrc 可能有多行。
--
--		一个疑问：‘分配数’还很重要吗？也许没有分配，房号就已经排了。
--		比如，散客订房的时候，一个账号预定多间客房，并且指定了客房；此时，传统的思路就是排房数大于分配数；
--		解决问题：完全以 saccnt 为准；有房号就是分配和排房；否则只是预留；把分配的概念去掉，只有预留和排房；
--		rsvsaccnt 就好比是预留房的 master, 一条rsvsaccnt 记录代表一个分配。
--
--
--		由于这个过程需要嵌套事务使用，因此不能使用临时表，所以采用 rsvsrc_1, rsvsrc_2, linksaccnt
----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------
--	考虑到下面 proc 的复杂性，一分为三 
--		p_gds_reserve_rsv_add / p_gds_reserve_rsv_del / p_gds_reserve_rsv_mod
----------------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_edit")
	drop proc p_gds_reserve_rsv_edit;
//create proc p_gds_reserve_rsv_edit
//	@accnt		char(10),
//	@id			int,
//	@type			char(5),
//	@roomno		char(5),
//	@blkmark		char(1),
//	@begin		datetime,
//	@end			datetime,
//	@quan			int,
//	@gstno		int,
//	@rate			money,
//	@remark		varchar(50),
//	@mode			char(3),			-- DEL, ADD, MOD
//	@retmode		char(1),			-- S, R
//	@ret        int	output,
//   @msg        varchar(60) output
//as
//
//declare
//	@out			int,			-- 表示是否结束扫描，退出处理
//	@class		char(1),		-- 账号类别 Fit, Grp, Met, Csm
//	@saccnt		char(10),
//	@count		int,
//	@host_id		int,
//	@sactlink	char(10)
//
//
//declare		-- 记录光标里上一次的变量，或者原来的纪录；
//	@oid			int,
//	@oblkmark	char(1),
//	@oquan		int,
//	@ogstno		int,
//	@orate		money,
//	@oremark		varchar(50),
//	@otype		char(5),
//	@oroomno		char(5),
//	@obegin		datetime,
//	@oend			datetime
//
//declare		-- date for saccnt
//	@sbegin		datetime,
//	@send			datetime
//
//
//select @host_id = convert(int, host_id())
//select @ret=0, @msg='', @out=0
//select @otype='',@oroomno='',@obegin='1980.1.1',@oend='1980.1.2'
//
//delete linksaccnt where host_id=@host_id
//delete rsvsrc_1 where host_id=@host_id
//delete rsvsrc_2 where host_id=@host_id
//
//select @class=class from master where accnt=@accnt 
//if @class not in ('F', 'G', 'M')  -- 消费帐不能涉及客房。  好像不太合理 ?
//begin
//	select @ret=1, @msg='该帐号类型不能预留客房资源 ! ---- ' + @accnt
//	if @retmode='S'
//		select @ret, @msg
//	return @ret
//end
//
//
//begin tran
//save tran rsvsrc_edit
//-------------------------------------------------------------------
//-- 如果 @begin=@end, p_gds_reserve_filldtl 不会作进一步的插入 - day use 
//-------------------------------------------------------------------
//--	ADD: 参数有效值--客房预留信息
//--		  id 需要由程序自动生成；
//-------------------------------------------------------------------
//if @mode = 'ADD' 
//begin
//	select @begin = convert(datetime,convert(char(8),@begin,1))
//	select @end = convert(datetime,convert(char(8),@end,1))
//	if @begin>@end 
//	begin
//		select @ret=1, @msg = '日期大小不对'
//		goto gout
//	end
//
//	if exists(select 1 from rsvsrc where accnt=@accnt and type=@type and roomno=@roomno 
//		and blkmark=@blkmark and begin_=@begin and end_=@end and quantity=@quan and gstno=@gstno 
//		and rate=@rate and remark=@remark and saccnt<>'')
//	begin
//		select @ret=1, @msg = '该记录已经存盘，不必再次加入'
//		goto gout
//	end
//	if @quan=0 
//	begin
//		select @ret=1, @msg='房数 = 0'
//		goto gout
//	end
//	if @roomno<>'' and @quan>1
//	begin
//		select @ret=1, @msg='有房号的情况下,房数必须 = 1'
//		goto gout
//	end
//
//	-- id : 注意取值
//	if exists(select 1 from rsvsrc where accnt=@accnt)
//		select @id = (select max(id) from rsvsrc where accnt=@accnt) + 1
//	else
//		if @class = 'F'  	-- fit
//			select @id = 0   -- 宾客主单上的资源
//		else					-- grp, meet
//			select @id = 1
//	
//	if @roomno<>'' -- 需要判断 share
//	begin
//		exec p_gds_reserve_rsv_get_saccnt @roomno, @begin, @end
//		-- 在 saccnt 中没有牵连，直接增加；(注意判断牵连的条件)
//		if not exists(select 1 from linksaccnt where host_id=@host_id)
//		begin
//			exec p_GetAccnt1 'SAT', @saccnt output
//			select @sactlink=@accnt,@sbegin=@begin,@send=@end
//			insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt)
//				values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt)
//			insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
//				values(@saccnt,@type,@roomno,'',@sbegin,@send,@quan,@sactlink)
//			update master set saccnt=@saccnt where accnt = @accnt and @id = 0
//			exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
//			goto gout
//		end
//		
//		-- 刚刚包含于某个 saccnt 的范围，则只需直接插入 rsvsrc。@begin=@end 的情况必定包含其中
//		select @saccnt = isnull((select min(saccnt) from rsvsaccnt where roomno=@roomno and @begin>=begin_ and @end<=end_), '')
//		if @saccnt <> ''
//		begin
//			insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt)
//				values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt)
//			update master set saccnt=@saccnt where accnt = @accnt and @id = 0
//			goto gout
//		end
//		
//		-- 有交叉：找出相应的 saccnt,并且取消相关的订房；
//		declare c_del cursor for select saccnt from linksaccnt where host_id=@host_id order by saccnt
//		open c_del
//		fetch c_del into @saccnt
//		while @@sqlstatus = 0
//		begin
//			exec p_gds_reserve_rsv_del_saccnt @saccnt  -- 同时删除 rsvsaccnt 中的记录
//			fetch c_del into @saccnt
//		end
//		close c_del
//		deallocate cursor c_del
//		
//		-- 重新整理相关 rsvsrc
//		insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt)
//			values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,'')
//		insert rsvsrc_1(host_id,accnt,id) select @host_id,accnt,id from rsvsrc 
//			where saccnt in (select saccnt from linksaccnt where host_id=@host_id) or (accnt=@accnt and id=@id)
//	end
//	else	-- 没有房号,这里假定没有 share，直接增加；
//	begin
//		exec p_GetAccnt1 'SAT', @saccnt output
//		select @sactlink=@accnt,@sbegin=@begin,@send=@end
//		insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt)
//			values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt)
//		insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
//			values(@saccnt,@type,@roomno,'',@sbegin,@send,@quan,@sactlink)
//		update master set saccnt=@saccnt where accnt = @accnt and @id = 0  -- @id=0 !
//   	exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
//		goto gout
//	end
//end
//------------------------------------------------------
//--	DEL: 参数有效值 -- accnt + id
//------------------------------------------------------
//else if @mode = 'DEL'
//begin
//	select @saccnt=saccnt from rsvsrc where accnt=@accnt and id=@id
//	if @@rowcount = 0
//	begin
//		select @ret=1, @msg='预留记录不存在，可能已经删除'
//		goto gout
//	end
//
//	if @id=0 and exists(select 1 from rsvsrc where accnt=@accnt and id<>@id)
//	begin
//		select @ret=1, @msg='主单预留记录不能删除，请先删除其他纯预留'
//		goto gout
//	end
//
//	select @count = count(1) from rsvsrc where saccnt=@saccnt
//	-- 没有任何关联；
//	if @count = 1
//	begin
//		exec p_gds_reserve_rsv_del_saccnt @saccnt
//		delete rsvsrc where saccnt=@saccnt
//		goto gout
//	end
//	
//	select @sbegin = min(begin_) from rsvsrc where saccnt=@saccnt and not (accnt=@accnt and id=@id)
//	select @send = min(end_) from rsvsrc where saccnt=@saccnt and not (accnt=@accnt and id=@id)
//	--除去该纪录，对 saccnt 的日期范围没有影响；
//	if exists(select 1 from rsvsaccnt where saccnt=@saccnt and begin_=@sbegin and end_=@send)
//	begin
//		delete rsvsrc where accnt=@accnt and id=@id
//		goto gout
//	end
//
//	-- saccnt 的对应日期有变化，需要重新建立；
//	exec p_gds_reserve_rsv_del_saccnt @saccnt
//	delete rsvsrc where accnt=@accnt and id=@id
//	insert rsvsrc_1(host_id,accnt,id) select @host_id,accnt,id
//			from rsvsrc where saccnt = @saccnt
//end
//------------------------------------------------------
//--	MOD: 参数有效值 -- accnt + id + type + .....
//--			新旧参数的对比，产生要处理的方向。
//-- 		记录的修改有多种形式：客房、日期、数量、其他信息等等；
//------------------------------------------------------
//else if @mode = 'MOD'
//begin
//	select @saccnt=saccnt, @otype=type,@oroomno=roomno,@oblkmark=blkmark,@obegin=begin_,@oend=end_,
//		@oquan=quantity,@ogstno=gstno,@orate=rate,@oremark=remark
//		from rsvsrc where accnt=@accnt and id=@id
//	if @@rowcount = 0
//	begin
//		select @ret=1, @msg='预留记录不存在，可能已经删除'
//		goto gout
//	end
//	if @quan=0 
//	begin
//		select @ret=1, @msg='房数 = 0'
//		goto gout
//	end
//	if @roomno<>'' and @quan>1 
//	begin
//		select @ret=1, @msg='有房号的情况下,房数必须 = 1'
//		goto gout
//	end
//
//	-- 修改与预留无关；
//	if @otype=@type and @oroomno=@roomno and @obegin=@begin and @oend=@end and @oquan=@quan
//	begin
//		update rsvsrc set blkmark=@blkmark,gstno=@gstno,rate=@rate,remark=@remark 
//			where accnt=@accnt and id=@id
//		goto gout
//	end
//
//	select @count = count(1) from rsvsrc where saccnt=@saccnt 
//	if @count=1 and @otype=@type and @oroomno=@roomno and @obegin<=@begin and @oend>=@end and @oquan=@quan
//	begin
//		-- 只有一行，没有同住关系，而且日期包含于以前的区间，直接处理；
//		exec p_gds_reserve_rsv_del_saccnt @saccnt
//		delete rsvsrc where accnt=@accnt and id=@id
//		select @sbegin=@begin,@send=@end  -- 此时, @saccnt 不必重新生成
//		insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt)
//			values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt)
//		insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
//			values(@saccnt,@type,@roomno,'',@sbegin,@send,@quan,@accnt)
//		update master set saccnt=@saccnt where accnt = @accnt and @id = 0
//   	exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
//		goto gout
//	end 
//	elseif @count>1
//		select @sbegin = min(begin_) from rsvsrc where saccnt=@saccnt and not (accnt=@accnt and id=@id)
//		select @send = min(end_) from rsvsrc where saccnt=@saccnt and not (accnt=@accnt and id=@id)
//		--除去该纪录，对 saccnt 的日期范围没有影响；
//		if exists(select 1 from rsvsaccnt where saccnt=@saccnt and type=@type and roomno=@roomno and begin_=@sbegin and end_=@send)
//		begin
//			update rsvsrc set begin_=@begin,end_=@end,blkmark=@blkmark,gstno=@gstno,rate=@rate,remark=@remark
//				where accnt=@accnt and id=@id
//			goto gout
//		end
//	end
//
//	-- 改变了客房信息，或者导致saccnt日期变化，需要重建；
//	exec p_gds_reserve_rsv_del_saccnt @saccnt
//	update rsvsrc set type=@type,roomno=@roomno,begin_=@begin,end_=@end,blkmark=@blkmark,
//		gstno=@gstno,rate=@rate,remark=@remark where accnt=@accnt and id=@id
//	if @roomno<>'' 
//	begin
//	end
//	else
//	begin
//	end
//	
//	exec p_gds_reserve_rsv_get_saccnt @roomno, @begin, @end
//	-- 在 saccnt 中没有牵连，直接增加；(注意判断牵连的条件)
//	if not exists(select 1 from linksaccnt where host_id=@host_id)
//	begin
//		exec p_GetAccnt1 'SAT', @saccnt output
//		select @sactlink=@accnt,@sbegin=@begin,@send=@end
//		insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt)
//			values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt)
//		insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
//			values(@saccnt,@type,@roomno,'',@sbegin,@send,@quan,@sactlink)
//		update master set saccnt=@saccnt where accnt = @accnt and @id = 0
//		exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
//		goto gout
//	end
//	
//	-- 刚刚包含于某个 saccnt 的范围，则只需直接插入 rsvsrc。@begin=@end 的情况必定包含其中
//	select @saccnt = isnull((select min(saccnt) from rsvsaccnt where roomno=@roomno and @begin>=begin_ and @end<=end_), '')
//	if @saccnt <> ''
//	begin
//		insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt)
//			values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt)
//		update master set saccnt=@saccnt where accnt = @accnt and @id = 0
//		goto gout
//	end
//	
//	-- 有交叉：找出相应的 saccnt,并且取消相关的订房；
//	declare c_del cursor for select saccnt from linksaccnt where host_id=@host_id order by saccnt
//	open c_del
//	fetch c_del into @saccnt
//	while @@sqlstatus = 0
//	begin
//		exec p_gds_reserve_rsv_del_saccnt @saccnt  -- 同时删除 rsvsaccnt 中的记录
//		fetch c_del into @saccnt
//	end
//	close c_del
//	deallocate cursor c_del
//	
//	-- 重新整理相关 rsvsrc
//	insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt)
//		values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,'')
//	insert rsvsrc_1(host_id,accnt,id) select @host_id,accnt,id from rsvsrc 
//		where saccnt in (select saccnt from linksaccnt where host_id=@host_id) or (accnt=@accnt and id=@id)
//	goto gout
//end
//
//gout:
//
////-- 如果 rsvsrc_1 包含纪录，表示有需要重建的部分；
////declare c_src cursor for select accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark
////	from rsvsrc_1 where @ret=0 and host_id=@host_id order by type,roomno,begin_,end_,quantity
////open c_src
////fetch c_src into @accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark
////while 1 = 1
////begin
////	if @@sqlstatus <> 0 	-- @out=1 : 表示结束扫描
////		select @out = 1, @begin='1980.1.1',@end='1980.1.2'
////	
////	-- 没有房号的情况下，原来的 share 信息如何提取？
////
////	if (@type<>@otype or @roomno<>@oroomno or @begin>=@oend or @quan<>1 or @out=1) and exists(select 1 from rsvsrc_2 where host_id=@host_id)
////	begin																				-- saccnt 拼接
////		select @sbegin = min(begin_) from rsvsrc_2  where host_id=@host_id
////		select @send = max(end_) from rsvsrc_2 where host_id=@host_id
////		select @saccnt = min(accnt) from rsvsrc_2 where host_id=@host_id
////
////		insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity)
////			values(@saccnt,@type,@roomno,'',@sbegin,@send,@quan)
////		update master set saccnt=@saccnt where accnt in (select accnt from rsvsrc_2 where host_id=@host_id)
////		update rsvsrc set saccnt=@saccnt where accnt in (select accnt from rsvsrc_2 where host_id=@host_id)
////
////		-- 资源调用
////   	exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
////		delete rsvsrc_2  where host_id=@host_id
////	end
////
////	if @out = 1
////		break
////
////	if @quan > 1 or @roomno=''   	-- 数量大于1，肯定没有 share；
////											--没有房号的预订，这里暂时不判断原来的share 
////	begin
////		insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity)
////			values(@accnt,@type,@roomno,'',@begin,@end,@quan)
////		update master set saccnt=@accnt where accnt=@accnt and @id=0
////		update rsvsrc set saccnt=@accnt where accnt=@accnt and id=@id
////
////		-- 资源调用
////   	exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
////
////	end
////	else
////		insert rsvsrc_2 values(@host_id,@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,'')
////
////	select @otype=@type,@oroomno=@roomno,@obegin=@begin,@oend=@end
////
////	fetch c_src into @accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark
////end
////close c_src
////deallocate cursor c_src
//
//-- end 
//if @ret <> 0
//	rollback tran rsvsrc_edit
//commit tran 
//if @retmode='S'
//	select @ret, @msg
//return @ret
//;
//

----------------------------------------------------------------------------------------------
--		saccnt delete 
--		自动清除 srcsaccnt, rsvsrc 中的记录需要手工清除，可能有用；
----------------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_del_saccnt")
	drop proc p_gds_reserve_rsv_del_saccnt;
create proc p_gds_reserve_rsv_del_saccnt
	@saccnt		char(10)
as
declare	
	@type			char(5),
	@roomno		char(5),
	@begin		datetime,
	@blkmark   	char(1),
	@end      	datetime,
	@quan  		int

select @type=type,@roomno=roomno,@begin=begin_,@blkmark=blkmark,@end=end_,@quan=quantity 
	from rsvsaccnt where saccnt=@saccnt
if @@rowcount <> 1
	return 0

select @quan = @quan * -1
if @roomno < '0'
	select @roomno = ''

exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@begin,@end,@quan
delete rsvsaccnt where saccnt=@saccnt

return 0
;


----------------------------------------------------------------------------------------------
--		寻找时段牵连的 saccnt (考虑到 dayuse, 仔细判断)
--		结果放在 linksaccnt (host_id)
--
--		有同住关系的时候，必定有房号（也许是虚拟的）。所以，没有房类参数。
----------------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_get_saccnt")
	drop proc p_gds_reserve_rsv_get_saccnt;
create proc p_gds_reserve_rsv_get_saccnt
	@roomno		char(5),
	@begin		datetime,
	@end			datetime
as
-------------------------------------------------------------------
--	时段牵连的条件, saccnt:[begin_,end_],   rsvsrc:[@begin,@end]
--		基于重视到日的原则
--				if begin_ =end_ and @begin =@end and @begin=begin_ then true
--				if begin_ =end_ and @begin<>@end and @begin<=begin_ and @end>begin_ then true
--				if begin_<>end_ and @begin =@end and @begin>=begin_ and @end<end_ then true
--				if begin_<>end_ and @begin<>@end and @begin <end_ and @end>begin_ then true
-------------------------------------------------------------------
declare	@host_id		varchar(30)
select @host_id = host_id()
delete linksaccnt where host_id=@host_id

insert linksaccnt select @host_id, saccnt from rsvsaccnt where roomno=@roomno
	and ( (begin_ =end_ and @begin =@end and @begin =begin_)
		or (begin_ =end_ and @begin<>@end and @begin<=begin_ and @end>begin_)
		or (begin_<>end_ and @begin =@end and @begin>=begin_ and @end<end_)
		or (begin_<>end_ and @begin<>@end and @begin <end_   and @end>begin_)
	)

return 0
;

----------------------------------------------------------------------------------------------
-- SACCNT  pointer 
----------------------------------------------------------------------------------------------
if not exists(select 1 from sys_extraid where cat='SAT')
	insert sys_extraid (cat, descript, id) 
	values('SAT', 'saccnt for room share', 0)
;
