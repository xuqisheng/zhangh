-- 自动消息类别
insert basecode_cat(cat,descript,descript1,len) select 'automsg_type', '消息类别', '消息类别', 10;

insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'automsg_type', 'foxnotify','FOXHIS窗口提示信息', 'FOXHIS Notify', 'T','T',0,'1';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'automsg_type', 'sms','短信', 'SMS', 'T','T',0,'1';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'automsg_type', 'email','电邮', 'eMail', 'T','T',0,'1';

-- 联系类别
insert basecode_cat(cat,descript,descript1,len) select 'contact', '联系类别', '联系类别', 10;
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'contact', 'email','电邮', 'eMail', 'T','T',0,'email';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'contact', 'mobile','手机', 'Mobile', 'T','T',0,'sms';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'contact', 'tel','电话', 'Tel', 'T','T',0,'sms';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'contact', 'fax','传真', 'Fax', 'T','T',0,'';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'contact', 'qq','QQ', 'QQ', 'T','T',0,'1','';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'contact', 'msn','MSN', 'MSN', 'T','T',0,'';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'contact', 'icq','ICQ', 'ICQ', 'T','T',0,'';

--职员联系信息表
if exists(select * from sysobjects where name = "sys_empno_contact")
	drop table sys_empno_contact;
create table sys_empno_contact
(
	empno				varchar(10)						not null, 
   type	   		varchar(10)    				not null, -- 联系方式
   content   		varchar(60) default ''   	not null  -- 具体内容
)
create index index1 on sys_empno_contact(empno,type)
;


--系统自动消息事件
if exists(select * from sysobjects where name = "automsg_event")
	drop table automsg_event;
create table automsg_event
(
	eventid			varchar(64)						not null, 
   descript   		varchar(60) default ''		not null,
   descript1  		varchar(60) default ''   	not null,
	tdcheck			char(3)							not null, 
	tdtrigger		char(3)							not null, 
	lastcheck		datetime							 null,
	lasttrigger		datetime							 null 
)
exec sp_primarykey automsg_event,eventid
create unique index index1 on automsg_event(eventid)
;
--系统自动消息事件通知消息
if exists(select * from sysobjects where name = "automsg_event_notify")
	drop table automsg_event_notify;
create table automsg_event_notify
(
	recid				varchar(10)						not null, 
	eventid			varchar(64)						not null, 
  	type	   		varchar(10) 					not null,  -- basecode==automsg_type
   notify   		varchar(254) default ''   	not null,  -- 通知人员 
   content   		varchar(254) default ''   	not null,  -- 具体内容,宏定义，如：0^%1，GM超出%2^
	tmhold			char(3)							not null   -- 消息处理后保留时间，
)
exec sp_primarykey automsg_event_notify,eventid,type
create unique index index1 on automsg_event_notify(eventid,type)
;

--系统自动消息处理表
if exists(select * from sysobjects where name = "automsg")
	drop table automsg;
create table automsg
(
	recid				varchar(10)						not null, 
	eventid			varchar(64)						not null, 
  	type	   		varchar(10) 					not null,  
   notify   		varchar(254) default ''   	not null,  
   content   		varchar(254) default ''   	not null,
	tmhold			char(3)							not null,   -- 消息处理后保留时间，
	tmtrigger		datetime							not null,
	tmprocess		datetime								 null,
	tag				char(1)		 default 'N'	not null  -- N:新纪录 S:成功 F:失败 X:取消
)
exec sp_primarykey automsg,recid
create unique index index1 on automsg(recid)
;

insert into sys_extraid(cat,descript,id) select 'AMN','自动消息事件通知表',0 
insert into sys_extraid(cat,descript,id) select 'AME','自动消息处理表',0 
;

-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 过程: 判断一个世界是否需要触发处理 
--------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_am_chkrunning' and type = 'P') 
   drop procedure p_am_chkrunning 
;  
create procedure p_am_chkrunning  
	@enventid	varchar(64), 
	@retmode		char(1) = 'S',
	@retcode		int = 0	output 
as	 
begin  
	declare @tdcheck			char(3)
	declare @tdtrigger		char(3)
	declare @lastcheck		datetime 
	declare @lasttrigger		datetime 
	declare @lastpost			datetime 
	declare @n int, @d int
	-----------------------------------------------------------------------------
	-- 检查是否符合处理检查条件
	select @tdcheck = isnull(tdcheck,'D99')+'000', @lastcheck = lastcheck 
		from automsg_event 
		where eventid = @enventid
	if ( @lastcheck is not null) 
	begin
		select @d = convert(int,substring(@tdcheck,2,2)) 
	
		if lower(substring(@tdcheck,1,1)) = 'd'
			select @n = datediff(dd,@lastcheck,getdate())
		if lower(substring(@tdcheck,1,1)) = 'h'
			select @n = datediff(hh,@lastcheck,getdate())
		if lower(substring(@tdcheck,1,1)) = 'm'
			select @n = datediff(mi,@lastcheck,getdate())

		if @n < @d 
		begin	
			-- 还是还没有到检查时间，直接返回
			select @retcode = 1 
			if @retmode='S'
				select @retcode 
			return @retcode 
		end
	end
	-- 需要检查，更新检查时间 
	update automsg_event set lastcheck = getdate() where eventid = @enventid

	-- 检查是否已经有触发信息（当前间隔内）
	select @tdtrigger = isnull(tdtrigger,'D99')+'000', @lasttrigger = lasttrigger 
		from automsg_event 
		where eventid = @enventid
	if ( @lasttrigger is not null) 
	begin
		select @d = convert(int,substring(@tdtrigger,2,2)),@lastpost = @lasttrigger
		if lower(substring(@tdtrigger,1,1)) = 'd'
			select @lastpost = dateadd(dd,@d,@lasttrigger)
		if lower(substring(@tdtrigger,1,1)) = 'h'
			select @lastpost = dateadd(hh,@d,@lasttrigger)
		if lower(substring(@tdtrigger,1,1)) = 'm'
			select @lastpost = dateadd(mi,@d,@lasttrigger)
		if exists (select 1 from automsg where eventid = @enventid and @lasttrigger <= tmtrigger and tmtrigger < @lastpost and @lastpost > getdate()) 
		begin	
			-- 已经触发过了，直接返回
			select @retcode = 2 
			if @retmode='S'
				select @retcode 
			return @retcode 
		end
	end
	-- 需要进行触发处理 
	select @retcode = 0
	if @retmode='S'
		select @retcode 
	return @retcode 
end
;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 过程例子
--------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_am_lettingrate' and type = 'P') 
   drop procedure p_am_lettingrate 
;  
create procedure p_am_lettingrate   
as	 
begin  
	declare @ret int, @msg	varchar(254) 
	declare @retchk			int 
	declare @lasttrigger		datetime 
	declare @procname		 	varchar(64)
	declare @type				varchar(10)
	declare @notify			varchar(254)
	declare @content			varchar(254)
	declare @tmhold			char(3)
	declare @recid				char(10)
	-----------------------------------------------------------------------------
	declare @tm	 datetime 
	declare @occ money 
	-----------------------------------------------------------------------------
	-- 1. 初始化
	-----------------------------------------------------------------------------
	select @procname = 'p_am_lettingrate'
	select @ret = 0,@msg = ''

	-- 检查是否需要进行触发
	exec p_am_chkrunning @procname, 'R', @retchk output

	if @retchk > 0
	begin
		select @ret = @retchk,@msg = ''
		select @ret,@msg 
		return @ret
	end
	-- 保存触发时间 
	select @lasttrigger = getdate()
	-----------------------------------------------------------------------------
	-- 2. 具体处理,把处理记录加入automsg
	-----------------------------------------------------------------------------
	-- 计算出租率
	select @tm = getdate()
	exec p_gds_reserve_rsv_index @tm, '%', 'Occupancy %', 'R', @occ output
	select @occ
	
	if @occ > 0.00
	begin
		-- 把处理记录加入automsg
		declare c_1 cursor for 
			select type,notify,content,tmhold  
			from automsg_event_notify 
			where eventid = @procname
		open c_1
		fetch c_1 into @type,@notify,@content,@tmhold 
		while @@sqlstatus = 0 
		begin
			-- 获取记录号
			exec p_GetAccnt1 @type = 'AME', @accnt = @recid out
			-- 创建完整消息串
			-- @content在定义中是不包含参数的，在这里追加上具体参数，可以使用系统宏
			-- 这里可以依据各个通知消息具体处理 
			select @content = @content + '^经理'
			insert into automsg(recid,eventid,type,notify,content,tmhold,tmtrigger,tmprocess,tag)
				select @recid,@procname,@type,@notify,@content,@tmhold,getdate(),null,'N' 

			fetch c_1 into @type,@notify,@content,@tmhold 
		end 
		close c_1
		deallocate cursor c_1 
	end
	-----------------------------------------------------------------------------
	-- 3. 处理结束,更新处理时间
	-----------------------------------------------------------------------------
	if @ret = 0 
	begin
		update automsg_event set lasttrigger = @lasttrigger where eventid = @procname
	end
	-----------------------------------------------------------------------------
	-- 4.	发回
	-- 处理中一切正常 ： @ret >= 0  @msg = '' 
	-- 处理中出现错误 ： @ret < 0  @msg = 出错提示信息
	-----------------------------------------------------------------------------
	select @ret,@msg 
end 
;  
