if exists(select 1 from sysobjects where name = "p_gds_master_grpmid")
	drop proc p_gds_master_grpmid;
create proc p_gds_master_grpmid
	@accnt		varchar(10),
	@retmode		char(1),
	@ret			int			output,
	@msg			varchar(60)	output
as
----------------------------------------------------------------------------------------------
--		产生团体会议成员模版相关信息  master_middle, guest 
--
--		团体会议主单生成的时候，自动生成相应的成员模版信息
--		成员主单放在 master_middle, 
--		成员profile 信息也需要产生 guest, 账号放在 exp_s1 
--
--			把＇重建＇独立出来，是因为　p_gds_master_grpmid 需要放到 master update trigger, 
--			速度上要保证
----------------------------------------------------------------------------------------------
declare		@class		char(1),
				@haccnt		char(7),
				@guest		char(7),
				@name			varchar(50),
				@country		char(3),
				@nation		char(3),
				@lang			char(1),
				@crtby		char(10),
				@hall			char(1),
				@extra		char(30),
				@sta			char(1),
				@fname		varchar(30),
				@lname		varchar(30),
				@name2		varchar(50),
				@name3		varchar(50),
				@name4		varchar(255)

select @ret=0, @msg = ''

begin tran
save tran master_grpmid

-- check data
select @class=class, @haccnt=haccnt, @guest=rtrim(exp_s1), @crtby=cby, @extra=extra from master where accnt=@accnt

-- hall adjustment 
select @hall = substring(@extra, 2, 1)
if not exists(select 1 from basecode where cat='hall' and code=@hall)
begin
	select @hall = min(code) from basecode where cat='hall'
	select @extra = stuff(@extra, 2, 1, @hall)
	update master set extra=@extra where accnt=@accnt 
	if @@rowcount = 0 
	begin
		select @ret = 1, @msg = 'Hall adjustment error'
		goto gout
		return
	end
end

-- guest
if @guest is null 
	select @guest = ''

if not exists(select 1 from guest where no=@guest and class='F')
begin
	select @name=name,@fname=fname,@lname=lname,@name2=name2,@name3=name2,@name4=name4, @country=country, @nation=nation, @lang=lang from guest where no=@haccnt
	exec p_GetAccnt1 'HIS', @guest output
	insert guest(no,sta,name,fname,lname,name2,name3,name4,class,country,src,market,keep,nation,lang,cusno,crtby,crttime,cby,changed)
		select @guest,'I',@name,@fname,@lname,@name2,@name3,@name4,'F',@country,src,market,'F',@nation,@lang,cusno,@crtby,getdate(),@crtby,getdate()
			from master where accnt=@accnt
	if @@rowcount = 0
	begin
		select @ret = 1, @msg = 'create guest error'
		goto gout
		return
	end
	exec p_gds_guest_name4 @guest 
	update master set exp_s1=@guest where accnt=@accnt
end
else
	begin
	select @sta = sta,@name = name,@country = country,@nation = nation,@lang = lang from guest where no = @haccnt
	update guest set name = @name,fname='',lname='',country=@country,src=b.src,market=b.market,nation = @nation ,
		lang=@lang,cusno=b.cusno from master b where accnt = @accnt and no = @guest
	end

-- master_middle  (每次都重新建立)
delete master_middle where accnt=@accnt
insert master_middle select * from master where accnt=@accnt
update master_middle set groupno=@accnt, haccnt=@haccnt, class='F',charge=0,credit=0,accredit=0,
		lastnumb=0, lastinumb=0 where accnt=@accnt

-- 
gout:
if @ret<>0
	rollback tran master_grpmid
else
	commit
if @retmode='S'
	select @ret, @msg
return @ret
;

