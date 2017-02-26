
if object_id('p_gds_guest_delete') is not null
	drop proc p_gds_guest_delete;
create proc p_gds_guest_delete
	@no			char(7),
	@empno		char(10),
	@retmode		char(1) = 'S',
	@msg			varchar(60) output 
as
------------------------------------------------------------------------------------
--		档案删除 
-- 
-- 	1. 这里不调用 p_gds_guest_del_check 判断了，因为主单上删除也许就是要删除的 
--
--		2. 查找那些表使用档案 
--		     select a.id, a.name, b.name from syscolumns a, sysobjects b 
--			      where a.name='haccnt' and a.id=b.id	order by b.name 
--
--    3. 这里的删除前判断，最好分解为多个模块的判断，比如前台，贵宾卡，餐饮，桑拿等
--       每个模块的判断一个 Proc， 结构更合理 
------------------------------------------------------------------------------------ 
declare
	@ret			int,
	@class		char(1),
	@quickno		char(7)

select @ret=0, @msg=''  
if @retmode is null 
	select @retmode='R' 

-- 快速登记档案
select @quickno=isnull((select substring(value,1,7) from sysoption where catalog='reserve' and item='default_guestid'), '')
if @quickno = @no 
begin
	select @ret=1, @msg='快速登记档案，不能删除'
	goto gout
end

-----------------------
-- 删除判断 
-----------------------
-- 是否存在
select @class=class from guest where no=@no 
if @@rowcount=0
begin
	if exists(select 1 from guest_del where no=@no) 
		select @ret=1, @msg='%1已经删除^档案'
	else
		select @ret=1, @msg='%1不存在，请检查^档案'
	goto gout
end

-- 类别判断 
--if @class in ('C', 'R')
--begin
--	select @ret=1, @msg='抱歉，消费帐户及应收帐户的档案不能删除'
--	goto gout
--end

-- master 
if exists(select 1 from master where haccnt=@no or cusno=@no or agent=@no or source=@no ) 
begin
	select @ret=1, @msg='档案还在当前使用，不能删除'
	goto gout
end
-- sc_master 
if exists(select 1 from sc_master where haccnt=@no or cusno=@no or agent=@no or source=@no ) 
begin
	select @ret=1, @msg='档案还在当前使用，不能删除'
	goto gout
end
-- ar_master 
if exists(select 1 from ar_master where haccnt=@no) 
begin
	select @ret=1, @msg='档案还在当前使用，不能删除'
	goto gout
end
-- vipcard 
if exists(select 1 from vipcard where hno=@no or cno=@no or kno=@no) 
begin
	select @ret=1, @msg='档案还在当前使用，不能删除'
	goto gout
end
-- pos_menu
if exists(select 1 from pos_menu where haccnt=@no or cusno=@no) 
begin
	select @ret=1, @msg='档案还在当前使用，不能删除'
	goto gout
end
-- pos_reserve
if exists(select 1 from pos_reserve where haccnt=@no or cusno=@no) 
begin
	select @ret=1, @msg='档案还在当前使用，不能删除'
	goto gout
end
-- sp_menu
if exists(select 1 from sp_menu where haccnt=@no or cusno=@no) 
begin
	select @ret=1, @msg='档案还在当前使用，不能删除'
	goto gout
end
-- sp_reserve
if exists(select 1 from sp_reserve where haccnt=@no or cusno=@no) 
begin
	select @ret=1, @msg='档案还在当前使用，不能删除'
	goto gout
end
-- turnaway
if exists(select 1 from turnaway where haccnt=@no) 
begin
	select @ret=1, @msg='档案还在当前使用，不能删除'
	goto gout
end


-----------------------
-- 删除开始 
-----------------------
begin tran 
save tran gst_del 

update guest set sta='X', cby=@empno, changed=getdate(), logmark=logmark+1 where no=@no 
insert guest_del select * from guest where no=@no 
if @@rowcount=0 
begin
	select @ret=1, @msg='删除档案错误'
	goto gout_s
end
else
begin
	delete guest where no=@no 
end

gout_s:
if @ret<>0 
	rollback tran gst_del
else
begin
	delete guest_del_flag where no=@no 
	delete guest_extra where no=@no 
	delete argst where no=@no 
end 
commit

gout:
if @retmode = 'S'
	select @ret, @msg
return @ret
;
