if exists(select * from sysobjects where name = "p_gds_guest_inuse_check")
	drop proc p_gds_guest_inuse_check;
create proc p_gds_guest_inuse_check
	@no				char(7),	
	@retmode			char(1) = 'R', 
	@msg				varchar(60)='' output 
as
----------------------------------------------------------------------------------
--  客户档案是否在用检查 
----------------------------------------------------------------------------------
declare		@ret				int,
				@count			int,
				@class		 	char(1) 

select @ret=0, @msg='' 
select @class=class from guest where no=@no 
if @@rowcount=0 
	select @ret=1, @msg='%1不存在^档案'
else if exists(select 1 from master where accnt like '[FGM]%' and (haccnt=@no or cusno=@no or agent=@no or source=@no)) 
	select @ret=1, @msg='当前%1正在使用该档案^订单'
else if exists(select 1 from master where accnt like '[C]%' and (haccnt=@no or cusno=@no or agent=@no or source=@no)) 
	select @ret=1, @msg='当前%1正在使用该档案^消费帐户'
else if exists(select 1 from master where accnt like '[A]%' and (haccnt=@no or cusno=@no or agent=@no or source=@no)) 
	select @ret=1, @msg='当前%1正在使用该档案^AR帐户'

else if exists(select 1 from ar_master where accnt like '[C]%' and (haccnt=@no )) 
	select @ret=1, @msg='当前%1正在使用该档案^AR帐户'

else if exists(select 1 from sc_master where (haccnt=@no or cusno=@no or agent=@no or source=@no)) 
	select @ret=1, @msg='当前%1正在使用该档案^BLOCK'
else if exists(select 1 from vipcard where (hno=@no or cno=@no or kno=@no)) 
	select @ret=1, @msg='当前%1正在使用该档案^会员卡'
else if exists(select 1 from pos_reserve where (haccnt=@no or cusno=@no)) 
	select @ret=1, @msg='当前%1正在使用该档案^餐饮预订'
else if exists(select 1 from sp_reserve where (haccnt=@no or cusno=@no)) 
	select @ret=1, @msg='当前%1正在使用该档案^康乐预订'
else if exists(select 1 from pos_menu where (haccnt=@no or cusno=@no)) 
	select @ret=1, @msg='当前%1正在使用该档案^餐饮单据'
else if exists(select 1 from sp_menu where (haccnt=@no or cusno=@no)) 
	select @ret=1, @msg='当前%1正在使用该档案^康乐单据'

-- output 
if @retmode = 'S' 
	select @ret, @msg 
return @ret 
;
