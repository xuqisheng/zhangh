
if exists(select * from sysobjects where name = "p_gds_reserve_quick_reg")
   drop proc p_gds_reserve_quick_reg
;
create proc p_gds_reserve_quick_reg
	@modu_id		char(2),
	@pc_id		char(4),
	@link			char(1)		-- 联房 ?
as

-- --------------------------------------------------------------------------
-- 快速登记
--	数据从 master_quick 中提取
-- master_quick 的唯一索引 roomno
-- --------------------------------------------------------------------------

declare 	@ret 				int, 
			@msg 				varchar(70), 
			@guestid 		char(7), 
			@accnt			char(7),  
			@sta 				char(1),  
			@groupno 		char(7), 
			@bdate 			datetime, 
			@changed 		datetime, 
			@srcdef			char(1),				-- sysoption 定义
			@accnts			varchar(255),		-- 成功的账号
			@rooms			varchar(255)		-- 成功的房号

declare
			@ratemode		char(3),
			@type		   	char(3),
			@roomno			char(5),
			@arr				datetime,
			@dep				datetime,
			@num				int,
			@cusno			char(7),
			@tranlog     	char(10),
			@src				char(1),
			@class		   char(1),
			@qtrate			money,
			@setrate			money,
			@rtreason	   char(3),
			@discount	   money,
			@discount1		money,
			@name				varchar(50),
			@lname       	varchar(30),
			@idcls       	char(3),
			@ident			char(18),
			@sex				char(1),
			@birth       	datetime,
			@vip				char(1),
			@secret			char(1),
			@nation			char(3),
			@fir				varchar(60),
			@address			varchar(60),
			@birthplace		char(6),
			@haccnt			char(7),
			@paycode			char(4),
			@exp_s			varchar(10),
			@applicant		varchar(30),
			@pcrec		   char(7),
			@phonesta	   char(1),
			@vodsta	   	char(1),
			@ref				varchar(80),
			@resby			char(3),
			@resbyname		char(12),
			@reserved		datetime

if not exists(select 1 from master_quick where modu_id=@modu_id and pc_id=@pc_id)
begin
	select @ret=1, @msg='没有需要快速登记的记录 !'
	select @ret, @msg, ''
	return @ret
end

-- 关于缺省的 来源
select @srcdef=rtrim(value) from sysoption where catalog='reserve' and item='quick_src'
if @@rowcount = 0 
begin
	select @srcdef = min(code) from srccode where code <> '#'
	insert sysoption select 'reserve', 'quick_src', @srcdef
end
else
	if not exists(select 1 from srccode where code=@srcdef)
	begin
		select @srcdef = min(code) from srccode where code <> '#'
		update sysoption set value = @srcdef where catalog='reserve' and item='quick_src'
	end


select  	@ret = 0, @msg = '', @changed = getdate(), @accnts=''
select 	@bdate = bdate1 from sysdata

declare c_roomno cursor for select ratemode,type,roomno,arr,dep,num,cusno,tranlog,
			src,class,qtrate,setrate,rtreason,discount,discount1,name,lname,idcls,
			ident,sex,birth,vip,secret,nation,fir,address,birthplace,haccnt,paycode,
			exp_s,applicant,pcrec,phonesta,vodsta,ref,resby,resbyname,reserved
	from master_quick where modu_id=@modu_id and pc_id=@pc_id order by roomno
open c_roomno 
fetch c_roomno into 
			@ratemode,@type,@roomno,@arr,@dep,@num,@cusno,@tranlog,
			@src,@class,@qtrate,@setrate,@rtreason,@discount,@discount1,@name,@lname,@idcls,
			@ident,@sex,@birth,@vip,@secret,@nation,@fir,@address,@birthplace,@haccnt,@paycode,
			@exp_s,@applicant,@pcrec,@phonesta,@vodsta,@ref,@resby,@resbyname,@reserved
while @@sqlstatus = 0
begin
	-- 每存一个，是一个事务
	begin tran 
	save tran p_mst_s1  
	select @class = 'E', @dep = dateadd(dd, @num, @arr), @fir=@applicant
	if rtrim(@src) is null 
		select @src = @srcdef
	exec p_GetAccnt1 'FIT',@accnt output
	insert master (src, class, type, roomno, qtrate, setrate, rtreason, sta, bdate, arr, dep, exp_s, ref,vodsta,paycode,
				accnt, osta, groupno, otype, oroomno, gstno, discount, discount1, phonesta, tranlog, cusno, applicant,
				ratemode, resby, resbyname, reserved, cby, cbyname, changed) 
	values(@src, @class, @type, @roomno, @qtrate, @setrate, @rtreason, 'I', @bdate, @arr, @dep, @exp_s, @ref,@vodsta,@paycode,
				@accnt, '', '       ', '', '', 1, @discount, @discount1, @phonesta, @tranlog, @cusno, @applicant,
				@ratemode, @resby, @resbyname, @changed, @resby, @resbyname, @changed) 
	if @@rowcount = 0 
		select @ret = 1,@msg = '主单插入失败 !'  
	if @ret = 0
	begin       
		exec @ret = p_hry_reserve_chktprm @accnt,'2','',@resby,'p',1,1,@msg output
		if @ret = 0       
		begin          
			update master set logmark = logmark + 1 where accnt = @accnt
			insert lgfl (tbname, accnt, guestid, columnname, coldes, empno, date)             
				select 'guest', accnt, guestid, '      增加', '***增加***', @resby, @changed from guest where accnt = @accnt
		end        
	end     
	
	if @ret = 0    
	begin    
		select @guestid = min(guestid) from guest where accnt = @accnt and sta = 'I'
		select @guestid = guestid, @sta = sta, @type = type, @roomno = roomno, @arr = arr, @dep = dep, @groupno = groupno from guest where guestid = @guestid    
		exec @ret = p_hry_update_guest @guestid, @sta, @type, @roomno, @arr, @dep, @groupno, '2', @resby, @msg output
		select @msg = @msg + isnull(@groupno, @guestid)    
	end 
	
	if @ret = 0     
	begin     
		update guest set cby = @resby, cbyname = @resbyname, changed = @changed, name = @name, 
				lname = @lname, sex = @sex, nation = @nation, fir = @fir, address = @address, 
				birthplace=@birthplace, idcls = @idcls, ident = @ident, vip=@vip, secret=@secret,
				haccnt=@haccnt
			where guestid = @guestid    
		update guest set logmark = logmark + 1 where guestid = @guestid    
		if @@rowcount = 0       
			select @ret = 1, @msg = '客人信息更新失败'    
	end       
	
	if @ret <> 0    
		rollback tran p_mst_s1 
	else
	begin		
		select @accnts=@accnts+@accnt+'/', @rooms=@rooms+@roomno+'/'
		update master_quick set accnt=@accnt where roomno=@roomno
	end
	commit tran 
	
	if @ret <> 0 
		goto gout		-- 中断退出
	
	fetch c_roomno into 
			@ratemode,@type,@roomno,@arr,@dep,@num,@cusno,@tranlog,
			@src,@class,@qtrate,@setrate,@rtreason,@discount,@discount1,@name,@lname,@idcls,
			@ident,@sex,@birth,@vip,@secret,@nation,@fir,@address,@birthplace,@haccnt,@paycode,
			@exp_s,@applicant,@pcrec,@phonesta,@vodsta,@ref,@resby,@resbyname,@reserved
end

gout:
close c_roomno
deallocate cursor c_roomno

-- 联房
select @rooms=ltrim(@rooms), @accnts=ltrim(@accnts)
if @link = 'T' and datalength(@accnts) > 10
begin
	select @accnt=substring(@accnts, 1, 7)
	update master set pcrec=@accnt where charindex(accnt, @accnts) > 0
end

select @ret, @msg, @rooms

return @ret
;