-----------------------------------------------
--		系统客房资源数据重建
--		注意虚拟房号
--
-- 	这里不更新 master=accnt, 可能去掉原来的同住关系
-----------------------------------------------
if exists(select 1 from sysobjects where name = "p_gds_reserve_rsvsrc_reb")
	drop proc p_gds_reserve_rsvsrc_reb;
create proc p_gds_reserve_rsvsrc_reb
as
declare
	@ret        int,
   @msg        varchar(60),
	@id			int,
	@out			int,					-- 判断光标终止
	@accnt		char(10),
	@type			char(5),
	@quan			int,
	@roomno		char(5),
	@begin		datetime,
	@end			datetime,
	@master		char(10),
	@rateok		char(1)

declare
	@saccnt		char(10),
	@otype		char(5),
	@oroomno		char(5),
	@maxend		datetime,		-- 纪录当前段的 max end date
	@sbegin		datetime,
	@send			datetime,
	@sactlink	char(10),			-- 放入 rsvsaccnt 中的 accnt
	@mroomno		char(5),
	@sroomno		char(5),
	@count		int,
	@sc			char(1)

------------------------------------------------------------
-- 重建工作有两部分： master + rsvsrc(id>0) 
--
--		一个注意点：没有指定房号的同住记录如何保持 ? -- 虚拟房号
------------------------------------------------------------
select @ret=0, @msg='', @out=0
select @otype='',@oroomno='',@maxend='1980.1.2'

create table #rsv (
   accnt     	char(10) 				not null,
	id				int		default 0	not null,
	type      	char(5) 					not null,
   roomno    	char(5) 	default ''	not null,
	begin_    	datetime  				not null,
	end_      	datetime  				not null,
	quantity  	int		default 0	not null
)

-- 先插入到临时表，否则可能引起重复键
-- 不能用 select * into #rsvsrc.... 因为会丢失 default ......
create table #rsvsrc
(
   accnt     	char(10) 				not null,
	id				int		default 0	not null,	-- 序号，含意丰富
	type      	char(5) 					not null,
   roomno    	char(5) 	default ''	not null,
	blkmark   	char(1)	default ''	not null,
	blkcode   	char(10)	default ''	not null,
	begin_    	datetime  				not null,		-- 不包含时间
	end_      	datetime  				not null,
	quantity  	int		default 0	not null,
	gstno			int		default 0	not null,
	child			int		default 0	not null,
	rmrate		money		default 0	not null,
	rate			money		default 0	not null,
	rtreason		char(3) default ''	not null,			-- 优惠理由
	remark		varchar(50)	default ''	not null,
	saccnt		char(10) default ''	not null,			-- 共享标记
	master		char(10) default ''	not null,			-- 同住主账号
	rateok		char(1)	default 'F'	not null,			-- 是否核准共享价格
	arr			datetime					not null,		-- 包含时间
	dep			datetime					not null,
	ratecode    char(10)    default '' 	not null,	-- 房价码  
	src			char(3)		default '' 	not null,	-- 来源 
	market		char(3)		default '' 	not null,	-- 市场码 
	packages		varchar(50)	default ''	not null,	-- 包价  
	srqs		   varchar(30)	default ''	not null,	-- 特殊要求 
	amenities  	varchar(30)	default ''	not null,	-- 房间布置 
	exp_m			money							null,
	exp_dt		datetime						null,
	exp_s1		varchar(20)					null,
	exp_s2		varchar(20)					null,
	cby			char(10)						null,
	changed		datetime						null,
	logmark		int		default 0		null
)

-- Begin 
begin tran
save tran rsvsrc_reb

-- data ready
delete rsvsrc where id = 0	-- 保留纯预留；
delete rsvsrc 					-- 去掉过期数据
	where accnt not in (select accnt from master where sta in ('R','I') and class in ('F','G','M','C')) 
		and  accnt not in (select accnt from sc_master where sta in ('R','I') and class in ('F','G','M','C')) 

-- 插入主单 - fo 
insert #rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,master,rateok,arr,dep,
		rmrate,rtreason,ratecode,src,market,packages,srqs,amenities)
	select accnt,0,type,roomno,'',arr,dep,rmnum,gstno,setrate,master,'F',arr,dep,
		rmrate,rtreason,ratecode,src,market,packages,srqs,amenities
	from master where sta in ('R','I') and class in ('F','G','M','C') and type<>'' 
-- 插入主单 - sc
insert #rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,master,rateok,arr,dep,
		rmrate,rtreason,ratecode,src,market,packages,srqs,amenities)
	select accnt,0,type,roomno,'',arr,dep,rmnum,gstno,setrate,master,'F',arr,dep,
		setrate,'',ratecode,src,market,packages,srqs,amenities
	from sc_master where foact='' and sta in ('R','I') and class in ('F','G','M','C') and type<>'' 

-- 2005.5.26 Simon 防止 rsvsrc_log 重复键
update #rsvsrc set logmark=isnull((select max(a.logmark) from rsvsrc_log a 
		where #rsvsrc.accnt=a.accnt and #rsvsrc.id=a.id), 0) + 1

update #rsvsrc set quantity=1, gstno=0 where accnt like '[GM]%'

insert rsvsrc select * from #rsvsrc
update rsvsrc set begin_=convert(datetime,convert(char(8),begin_,1))
update rsvsrc set end_=convert(datetime,convert(char(8),end_,1))
delete rsvsrc where quantity<1

-- reset sum table 
delete rsvsrc where quantity<1
delete rsvsaccnt
delete rsvdtl
delete rsvroom
delete rsvtype

-- start cursor
declare c_src cursor for select accnt,id,type,roomno,begin_,end_,quantity
	from rsvsrc order by type,roomno,begin_,end_,quantity
open c_src
fetch c_src into @accnt,@id,@type,@roomno,@begin,@end,@quan
while 1 = 1
begin
	if @@sqlstatus <> 0 	-- @out=1 : 表示结束扫描
		select @out=1,@begin='1980.1.1',@end='1980.1.2'  --光标终止的时候，随意赋值
	
	-- 
	if exists(select 1 from sc_master where accnt=@accnt and foact='') 
		select @sc='T'
	else
		select @sc='F'

	-- 没有房号的情况下，原来的 share 信息如何提取？

	select @count = count(1) from #rsv
	if (@type<>@otype or @roomno<>@oroomno or @begin>=@maxend or @quan<>1 or @out=1) and @count>0
	begin																				-- saccnt 拼接
		select @sbegin = min(begin_) from #rsv
		select @send = max(end_) from #rsv
		exec p_GetAccnt1 'SAT', @saccnt output
		select @sactlink = min(accnt) from #rsv  -- saccnt 的代表账号

		-- @sroom	-- 资源控制的房号
		if @oroomno like '#%'
			select @sroomno = ''
		else
			select @sroomno = @oroomno

		-- @mroom  -- 虚拟房号
--		if @oroomno like '#%' and @count = 1
--			select @mroomno = ''
--		else
			select @mroomno = @oroomno

		insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
			values(@saccnt,@otype,@sroomno,'',@sbegin,@send,1,@sactlink)
		-- 往 master 填数据-saccnt.  roomno-虚拟房号可能改变。
		-- 注意 col = master 的更新
		if @sc='F'
		begin
			update master set roomno=@mroomno,oroomno=@mroomno,saccnt=@saccnt 
				where accnt in (select accnt from #rsv where id=0)
	--		update master set master=accnt where master not in (select accnt from #rsv where id=0)
			update rsvsrc set roomno=@mroomno,saccnt=@saccnt, rateok='F', master=b.master
				from #rsv a, master b where rsvsrc.accnt=a.accnt and rsvsrc.id=a.id and a.accnt=b.accnt
		end
		else
		begin
			update sc_master set roomno=@mroomno,oroomno=@mroomno,saccnt=@saccnt 
				where accnt in (select accnt from #rsv where id=0)
	--		update sc_master set master=accnt where master not in (select accnt from #rsv where id=0)
			update rsvsrc set roomno=@mroomno,saccnt=@saccnt, rateok='F', master=b.accnt
				from #rsv a, sc_master b where rsvsrc.accnt=a.accnt and rsvsrc.id=a.id and a.accnt=b.accnt
		end

		-- 资源调用
   	exec p_gds_reserve_filldtl @saccnt,@otype,@sroomno,@sbegin,@send,1  -- 此时，quan肯定=1
		-- reset 
		delete #rsv 
		select @otype='',@oroomno='',@maxend='1980.1.2'
	end

	if @out = 1
		break

	if @quan > 1 or @roomno=''   	-- 数量大于1，肯定没有 share；没有房号的预订，这里暂时不判断原来的share 
	begin
		exec p_GetAccnt1 'SAT', @saccnt output
		select @sactlink = @accnt
		insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
			values(@saccnt,@type,@roomno,'',@begin,@end,@quan,@sactlink)
		
		if @sc='F'
		begin
	--		update master set saccnt=@saccnt,master=@accnt where accnt=@accnt and @id=0
			update master set saccnt=@saccnt               where accnt=@accnt and @id=0
		end
		else
		begin
	--		update sc_master set saccnt=@saccnt,master=@accnt where accnt=@accnt and @id=0
			update sc_master set saccnt=@saccnt               where accnt=@accnt and @id=0
		end

		update rsvsrc set saccnt=@saccnt, rateok='T' where accnt=@accnt and id=@id	-- ,master=@accnt

		-- 资源调用
   	exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@begin,@end,@quan
		select @otype='',@oroomno='',@maxend='1980.1.2'
	end
	else
	begin
		insert #rsv values(@accnt,@id,@type,@roomno,@begin,@end,@quan)
		select @otype=@type,@oroomno=@roomno
		if @end > @maxend 
			select @maxend = @end
	end

	fetch c_src into @accnt,@id,@type,@roomno,@begin,@end,@quan
end
close c_src
deallocate cursor c_src

if @ret <> 0
	rollback tran rsvsrc_reb
commit tran 
drop table #rsvsrc
select @ret, @msg
return @ret
;