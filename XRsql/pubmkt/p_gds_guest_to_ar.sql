if object_id('p_gds_guest_to_ar') is not null
	drop proc p_gds_guest_to_ar;
create proc p_gds_guest_to_ar
	@no			char(7),
	@key			char(1),				-- 决定哪一个 ar accnt
	@name			varchar(50),
	@arr			datetime,
	@dep			datetime,
	@artag1		char(3),
	@artag2		char(3),
	@ref			varchar(100),
	@empno		char(10),
	@retmode		char(1)='S',
	@ret			int			output,
	@msg			varchar(60)	output
as
-- ----------------------------------------------------------------------------------
--		根据客户档案信息生成对应的 ar account
-- ---------------------------------------------------------------------------------- 

declare
	@accnt		char(10),
	@hno			char(7),
	@bdate		datetime,
	@today		datetime,
	@extra		char(30),
	@dw_edit		varchar(30),
	@hall			char(1),
	@lic_buy_1	varchar(255),
	@lic_buy_2	varchar(255)

select @ret=0, @msg='', @bdate = bdate1, @today=getdate() from sysdata
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')

-- Check 
if not exists(select 1 from guest where no=@no)
	select @ret=1, @msg='当前客户档案不存在'
if @ret=0 and exists(select 1 from guest where class='R' and name=@name)
	select @ret=1, @msg='同名应收账已经存在，请检查'
if @ret=0 
begin
	if @key = '1'
	begin
		select @accnt=araccnt1 from guest where no=@no
		if rtrim(@accnt) is not null
			select @ret=1, @msg='当前档案已经存在相应的应收账户，请检查'
	end
	else
	begin
		select @accnt=araccnt2 from guest where no=@no
		if rtrim(@accnt) is not null
			select @ret=1, @msg='当前档案已经存在相应的应收账户，请检查'
	end
end
if @ret<>0 
	goto gexit

select * into #guest from guest where no = @no

-- Begin ......
begin tran 
save tran p_guest_to_ar

-- Create Accnt
exec p_GetAccnt1 'HIS', @hno output   
update #guest set no=@hno, class='R', crtby=@empno,crttime=@today,cby=@empno,changed=@today,logmark=0
insert guest select * from #guest
if @@rowcount<>1
begin
	select @ret=1, @msg='应收账档案产生错误'
	goto gout
end
exec p_gds_guest_name4 @hno 

exec p_GetAccnt1 'AR', @accnt output  
if charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0
begin
	-- for extra  
	select @dw_edit = isnull((select rtrim(ltrim(value))  from sysoption where catalog='reserve' and item='master_edit_b2'), 'd_gds_master51') 
	select @extra = rtrim(ltrim(defaultvalue)) from sysdefault where datawindow=@dw_edit and columnname='extra'
	if @@rowcount=0 or @extra is null 
		select @extra = '000000000000000000000000000000'
	-- hall adjustment 
	select @hall = substring(@extra, 2, 1)
	if not exists(select 1 from basecode where cat='hall' and code=@hall)
	begin
		select @hall = min(code) from basecode where cat='hall'
		select @extra = stuff(@extra, 2, 1, @hall)
	end

	insert ar_master(accnt,haccnt,class,sta,artag1,artag2,ref,arr,dep,bdate,resby,restime,cby,changed,logmark,extra)
		values(@accnt,@hno,'A','I',@artag1,@artag2,@ref,@arr,@dep,@bdate,@empno,@today,@empno,@today,0,@extra)
end
else
begin
	-- for extra  
	select @dw_edit = isnull((select rtrim(ltrim(value))  from sysoption where catalog='reserve' and item='master_edit_a2'), 'd_gds_master41') 
	select @extra = rtrim(ltrim(defaultvalue)) from sysdefault where datawindow=@dw_edit and columnname='extra'
	if @@rowcount=0 or @extra is null 
		select @extra = '000000000000000000000000000000'
	-- hall adjustment 
	select @hall = substring(@extra, 2, 1)
	if not exists(select 1 from basecode where cat='hall' and code=@hall)
	begin
		select @hall = min(code) from basecode where cat='hall'
		select @extra = stuff(@extra, 2, 1, @hall)
	end

	insert master(accnt,haccnt,class,sta,artag1,artag2,ref,arr,dep,bdate,resby,restime,ciby,citime,cby,changed,logmark,extra)
		values(@accnt,@hno,'A','I',@artag1,@artag2,@ref,@arr,@dep,@bdate,@empno,@today,@empno,@today,@empno,@today,0,@extra)
end 
if @@rowcount<>1
begin
	select @ret=1, @msg='应收账户产生错误'
	goto gout
end

gout:
if @ret<>0 
	rollback tran p_guest_to_ar
else
	begin
	if charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0
		update ar_master set logmark=logmark+1 where accnt=@accnt
	else
		update master set logmark=logmark+1 where accnt=@accnt
	update guest set logmark=logmark+1 where no=@hno
	if @key = '1'
		update guest set araccnt1=@accnt, cby=@empno, changed=@today,logmark=logmark+1 where no=@no
	else
		update guest set araccnt2=@accnt, cby=@empno, changed=@today,logmark=logmark+1 where no=@no
	select @msg = @accnt
	end
commit tran 

gexit:
if @retmode='S'
	select @ret, @msg
return @ret
;
