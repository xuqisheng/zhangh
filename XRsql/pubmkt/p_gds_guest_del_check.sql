if exists(select * from sysobjects where name = "p_gds_guest_del_check")
	drop proc p_gds_guest_del_check;
create proc p_gds_guest_del_check
	@no				char(7),				-- 检查模式，或者档案号码 all, audit, no 
	@empno			char(10)='FOX' 
as
----------------------------------------------------------------------------------
--  客户档案删除检查 all=检查全部  
--							co=夜审检查，针对结帐帐户 - 夜审单独调用 
--							audit=夜审检查，复查标记中的帐户 - 夜审删除前调用 p_gds_audit_guest_del
--							no=针对特定帐户 
----------------------------------------------------------------------------------
declare		@nopass		int, 					-- 不通过检查项目计数 
				@parms		varchar(255),
				@parms1		varchar(255),
				@bdate		datetime,
				@pos			int,
				@ret			int,
				@msg			varchar(60)  

declare		@noadd		char(1),				-- 检查参数
				@noid			char(1),
				@novip		char(1),
				@nogrp		char(1),
				@nolat		char(1),
				@noar			char(1),
				@nomst		char(1),
				@nosaleid	char(1),
				@nokeep		char(1),
				@nocard		char(1),
				@classes		varchar(10),
				@xfttl		money,
				@xfrm			money,
				@xftime		int,
				@xfnt			int,
				@xflong		int


declare 		@mno			char(7),
				@street	   varchar(60),		-- 客户档案提取信息 
				@street1	   varchar(60),
				@ident		char(20),
				@vip			char(3),
				@central		char(1),
				@latency		char(1),
				@araccnt1	char(10),
				@araccnt2	char(10),
				@keep			char(1),
				@saleid     char(12),
				@class		char(1),
				@lv_date		datetime,
				@crttime		datetime,
				@i_times    int,
				@i_days     int,
				@rm         money,
				@tl         money,
				@changed		datetime,
				@cardno		varchar(20) 

-- 
if @no is null 
	select @no = ''
if rtrim(@empno) is null
	select @empno = 'FOX' 

-- parms check 
select @parms=null, @bdate=bdate1 from sysdata 
select @parms=rtrim(value) from sysoption where catalog='profile' and item='del_cond' 
if @parms is null	-- 没有任何设置条件，不处理 
	return 0
else
	select @parms=';'+@parms+';' 
if charindex(';noadd;', @parms)>0 
	select @noadd='T'
else
	select @noadd='F'
if charindex(';noid;', @parms)>0 
	select @noid='T'
else
	select @noid='F'
if charindex(';novip;', @parms)>0 
	select @novip='T'
else
	select @novip='F'
if charindex(';nogrp;', @parms)>0 
	select @nogrp='T'
else
	select @nogrp='F'
if charindex(';nolat;', @parms)>0 
	select @nolat='T'
else
	select @nolat='F'
if charindex(';noar;', @parms)>0 
	select @noar='T'
else
	select @noar='F'
if charindex(';nosaleid;', @parms)>0 
	select @nosaleid='T'
else
	select @nosaleid='F'
if charindex(';nokeep;', @parms)>0 
	select @nokeep='T'
else
	select @nokeep='F'
if charindex(';nocard;', @parms)>0 
	select @nocard='T'
else
	select @nocard='F'
if charindex(';nomst;', @parms)>0 
	select @nomst='T'
else
	select @nomst='F'
select @pos=charindex(';xfttl=', @parms)
if @pos>0 
begin
	select @parms1=substring(@parms, @pos+7, 100)
	select @pos=charindex(';', @parms1)
	select @xfttl=convert(money, substring(@parms1, 1, @pos-1))
end 
select @pos=charindex(';xfrm=', @parms)
if @pos>0 
begin
	select @parms1=substring(@parms, @pos+6, 100)
	select @pos=charindex(';', @parms1)
	select @xfrm=convert(money, substring(@parms1, 1, @pos-1))
end 
select @pos=charindex(';xftime=', @parms)
if @pos>0 
begin
	select @parms1=substring(@parms, @pos+8, 100)
	select @pos=charindex(';', @parms1)
	select @xftime=convert(int, substring(@parms1, 1, @pos-1))
end 
select @pos=charindex(';xfnt=', @parms)
if @pos>0 
begin
	select @parms1=substring(@parms, @pos+6, 100)
	select @pos=charindex(';', @parms1)
	select @xfnt=convert(int, substring(@parms1, 1, @pos-1))
end 
select @pos=charindex(';xflong=', @parms)
if @pos>0 
begin
	select @parms1=substring(@parms, @pos+8, 100)
	select @pos=charindex(';', @parms1)
	select @xflong=convert(int, substring(@parms1, 1, @pos-1))
end 
select @pos=charindex(';classes=', @parms)
if @pos>0 
begin
	select @parms1=substring(@parms, @pos+9, 100)
	select @pos=charindex(';', @parms1)
	select @classes=substring(@parms1, 1, @pos-1)
end 

-- declare cursor 
create table #co (no  char(7)) 
select @mno = @no 
if @mno='all'
	declare c_del_flag cursor for select no from guest 
else if @mno='co' 
begin
	insert #co select distinct haccnt from master_till where sta='O' 
	insert #co select distinct cusno from master_till where sta='O' and cusno<>'' 
	insert #co select distinct agent from master_till where sta='O' and agent<>'' 
	insert #co select distinct source from master_till where sta='O' and source<>'' 
	insert #co select distinct haccnt from ar_master_till where sta='O' and haccnt<>'' 
	declare c_del_flag cursor for select distinct no from #co 
end 
else if @mno='audit'
begin
	insert #co select a.no from guest_del_flag a, guest b 
		where a.no=b.no and a.lastdate<>b.changed 
	declare c_del_flag cursor for select distinct no from #co 
end 
else
	declare c_del_flag cursor for select no from guest where no=@mno

-- 
open c_del_flag
fetch c_del_flag into @no
while  @@sqlstatus = 0
begin
	select @street=street,@street1=street1,@ident=ident,@vip=vip,@central=central,@latency=latency,
			@araccnt1=araccnt1,@araccnt2=araccnt2,@keep=keep,@saleid=saleid,@class=class,@cardno=cardno,
			@lv_date=lv_date,@crttime=crttime,@i_times=i_times,@i_days=i_days,@rm=rm,@tl=tl,@changed=changed 
		from guest where no=@no 
	if @@rowcount = 0
	begin
		delete guest_del_flag where no = @no 
		fetch c_del_flag into @no
		continue 
	end
	if exists(select 1 from guest_del_flag where no=@no and lastdate=@changed)  -- 已经进入名单，而且没有变化的档案忽略
	begin
		fetch c_del_flag into @no
		continue 
	end

	--
	select @nopass = 0 
	if @nopass = 0 
	begin
		if @noadd='T' and (@street<>'' or @street1<>'') 
			select @nopass = @nopass + 1 
	end
	if @nopass = 0 
	begin
		if @noid='T' and (@ident<>'') 
			select @nopass = @nopass + 1 
	end
	if @nopass = 0 
	begin
		if @novip='T' and (@vip>'0') 
			select @nopass = @nopass + 1 
	end
	if @nopass = 0 
	begin
		if @nogrp='T' and (@central='T') 
			select @nopass = @nopass + 1 
	end
	if @nopass = 0 
	begin
		if @nolat='T' and (@latency>'0') 
			select @nopass = @nopass + 1 
	end
	if @nopass = 0 
	begin
		if @noar='T' and (@araccnt1<>'' or @araccnt2<>'') 
			select @nopass = @nopass + 1 
	end
--	if @nopass = 0 and @nomst='T'			-- 这个判断太慢，暂时不考虑 
--	begin
--		if exists(select 1 from guest where master=@no) 
--			select @nopass = @nopass + 1 
--	end
	if @nopass = 0 
	begin
		if @nokeep='T' and (@keep='T') 
			select @nopass = @nopass + 1 
	end
	if @nopass = 0 
	begin
		if @nocard='T' and (@cardno<>'') 
			select @nopass = @nopass + 1 
	end
	if @nopass = 0 
	begin
		if @nosaleid='T' and (@saleid<>'') 
			select @nopass = @nopass + 1 
	end
	if @nopass = 0 
	begin
		if charindex(@class, @classes)=0 
			select @nopass = @nopass + 1 
	end
	if @nopass = 0 
	begin
		if @xfttl is not null and @tl>@xfttl 
			select @nopass = @nopass + 1 
	end
	if @nopass = 0 
	begin
		if @xfrm is not null and @rm>@xfrm 
			select @nopass = @nopass + 1 
	end
	if @nopass = 0 
	begin
		if @xftime is not null and @i_times>@xftime 
			select @nopass = @nopass + 1 
	end
	if @nopass = 0 
	begin
		if @xfnt is not null and @i_days>@xfnt
			select @nopass = @nopass + 1 
	end
	if @nopass = 0 
	begin
		if @lv_date is null 
			select @lv_date=@crttime 
		if @xflong is not null and (datediff(dd,@lv_date,@bdate)<@xflong) 
			select @nopass = @nopass + 1 
	end

	-- 结果处理 
	if @nopass=0  -- 没有任何不符合项目，打上删除标记 
	begin
		exec @ret = p_gds_guest_inuse_check @no, 'R', @msg output 
		if @ret <> 0  -- 正在使用 
			delete guest_del_flag where no = @no 
		else 
		begin 
			if not exists(select 1 from guest_del_flag where no=@no)
				insert guest_del_flag(no,lastdate,crtby,crttime,bdate) values(@no, @changed,@empno, getdate(),@bdate) 
			else   -- 档案修改过，重新标记 
				update guest_del_flag set lastdate=@changed,crtby=@empno,crttime=getdate(),bdate=@bdate where no=@no 
		end 
	end 	
	else
		delete guest_del_flag where no = @no 

	fetch c_del_flag into @no 
end
close c_del_flag
deallocate cursor c_del_flag

;
