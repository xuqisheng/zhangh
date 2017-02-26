
if exists(select * from sysobjects where name = 'p_gds_accnt_subaccnt_copy')
	drop proc p_gds_accnt_subaccnt_copy;

create proc p_gds_accnt_subaccnt_copy
	@accnt				char(10), 
	@subaccnt			integer, 
	@type					char(5), 
	@cp_accnt			char(10), 
	@cp_subaccnt		integer, 
	@cp_type				char(5),
	@shift				char(1),
	@empno				char(10),
	@retmode				char(1) = 'S',
	@msg					varchar(60)='' output 
as
----------------------------------------------------------------------------------
--  复制分账户内容
--		如果 subaccnt, type = null 则自动为第一个分账户 
--		为了散客分账户批量处理制作 (上海锦江银河)
--
--		当前过程只处理 subaccnt,type为空 
--
--		日志还没有添加 for insert, delete 
----------------------------------------------------------------------------------

declare 
	@to_roomno			char(5),
	@to_accnt			char(10),
	@name					char(50),
	@pccodes				varchar(255),
	@starting_time		datetime,
	@closing_time		datetime,
	@paycode				char(5),
	@ref					varchar(50),
	@logmark				integer,
	@groupno				char(10),
	@ret					int

select @ret=0, @msg='' 
if not exists(select 1 from master where accnt=@accnt) 
	or not exists(select 1 from master where accnt=@cp_accnt) 
begin
	select @ret=1, @msg='存在非法帐户'
	goto gout 
end
if @accnt = @cp_accnt 
begin
	select @ret=0, @msg='自己不需要给自己复制'
	goto gout 
end
select @groupno=groupno from master where accnt=@accnt 
if rtrim(@groupno) is null 
	select @subaccnt=2, @type='5'  
else
	select @subaccnt=3, @type='5'
select @groupno=groupno from master where accnt=@cp_accnt 
if rtrim(@groupno) is null 
	select @cp_subaccnt=2, @cp_type='5'  
else
	select @cp_subaccnt=3, @cp_type='5'

begin tran 
save tran p_gds_accnt_subaccnt_copy_1
if exists(select 1 from subaccnt where accnt=@accnt and subaccnt=@subaccnt and type=@type)
begin	
	select @to_roomno=to_roomno,@to_accnt=to_accnt,@name=name,@pccodes=pccodes,
			@starting_time=starting_time,@closing_time=closing_time,@paycode=paycode,@ref=ref 
		from subaccnt where accnt=@accnt and subaccnt=@subaccnt and type=@type  -- 可能多行吗? 
	-- 

	if exists(select 1 from subaccnt where accnt=@cp_accnt and subaccnt=@cp_subaccnt and type=@cp_type)
		-- 更新 
		update subaccnt set to_roomno=@to_roomno,to_accnt=@to_accnt,name=@name,pccodes=@pccodes,
				starting_time=@starting_time,closing_time=@closing_time,paycode=@paycode,ref=@ref, 
				logmark=logmark+1, cby=@empno, changed=getdate() 
			where accnt=@cp_accnt and subaccnt=@cp_subaccnt and type=@cp_type
	else
		-- 增加
		insert subaccnt(roomno,haccnt,accnt,subaccnt,to_roomno,to_accnt,name,pccodes,
			starting_time,closing_time,cby,changed,type,tag,paycode,ref,logmark) 
		select a.roomno,a.haccnt,a.accnt,@cp_subaccnt,@to_roomno,@to_accnt,@name,@pccodes,
				@starting_time,@closing_time,@empno,getdate(),@cp_type,'2',@paycode,@ref,1
			from master a, guest b where a.accnt=@cp_accnt and a.haccnt=b.no 
end
else	-- 删除 
begin
	delete subaccnt where accnt=@cp_accnt and subaccnt=@cp_subaccnt and type=@cp_type
end
if @@error <> 0 
begin
	select @ret=1, @msg='Update Error'
	rollback tran p_gds_accnt_subaccnt_copy_1
end
commit tran

gout:
if @retmode='S'
	select @ret, @msg
return @ret
;
