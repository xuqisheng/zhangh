if exists(select 1 from sysobjects where name = "p_gds_master_grpmid_reb")
	drop proc p_gds_master_grpmid_reb;
create proc p_gds_master_grpmid_reb
	@retmode		char(1),
	@ret			int			output,
	@msg			varchar(60)	output
as
----------------------------------------------------------------------------------------------
--		产生团体会议成员模版相关信息  master_middle, guest 
--
--			把＇重建＇独立出来，是因为　p_gds_master_grpmid 需要放到 master update trigger, 
--			速度上要保证
--			团体成员的信息模版放在 master.exp_s1
----------------------------------------------------------------------------------------------
declare		@maccnt		char(10),
				@class		char(1),
				@haccnt		char(7),
				@guest		char(7),
				@name			varchar(50),
				@country		char(3),
				@nation		char(3),
				@crtby		char(10)

select @ret=0, @msg = ''

begin tran
save tran master_grpmid

-- 每次都重新建立
delete master_middle

declare c_grp cursor for select accnt from master where class in ('M', 'G')
open c_grp
fetch c_grp into @maccnt
while @@sqlstatus = 0
begin
	-- check data
	select @class=class, @haccnt=haccnt, @guest=rtrim(exp_s1), @crtby=cby from master where accnt=@maccnt
	
	-- guest
	if @guest is null 
		select @guest = ''

	if @guest='' or not exists(select 1 from guest where no=@guest and class='F')
	begin
		select @name=name, @country=country, @nation=nation from guest where no=@haccnt
		exec p_GetAccnt1 'HIS', @guest output
		insert guest(no,sta,name,class,country,src,market,keep,nation,cusno,crtby,crttime,cby,changed)
			select @guest,'I',@name,'F',@country,src,market,'F',@nation,cusno,@crtby,getdate(),@crtby,getdate()
				from master where accnt=@maccnt
		if @@rowcount = 0
		begin
			select @ret = 1, @msg = 'create guest error'
			goto gout
			return
		end
		exec p_gds_guest_name4 @guest  
		update master set exp_s1=@guest where accnt=@maccnt
	end

	insert master_middle select * from master where accnt=@maccnt
	update master_middle set groupno=@maccnt, haccnt=@guest, class='F',charge=0,credit=0,accredit=0,
		lastnumb=0, lastinumb=0 where accnt=@maccnt

	fetch c_grp into @maccnt
end

-- 
gout:
close c_grp
deallocate cursor c_grp

if @ret<>0
	rollback tran master_grpmid
else
	commit
if @retmode='S'
	select @ret, @msg
return @ret
;

