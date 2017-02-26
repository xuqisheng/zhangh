if exists(select * from sysobjects where name = 'p_gds_vipcard_lost_issue' and type ='P')
	drop proc p_gds_vipcard_lost_issue;
create proc p_gds_vipcard_lost_issue
	@no1			varchar(20),	-- 老卡号
	@no2			varchar(20),   -- 新卡号
	@empno		char(10)
as
----------------------------------------------------------------
-- 挂失卡 重新发行
----------------------------------------------------------------
declare		@ret			int,
				@msg			varchar(60),
				@set			char(1),
				@logdate		datetime,
				@exp_s8     char(64)
				
select @ret=0, @msg='',@logdate=getdate()
if @no1 is null select @no1=''
if @no2 is null select @no2=''

if not exists(select 1 from vipcard where no=@no1 and sta='L')
begin
	select @ret=1, @msg='The card is not exists or not in Lost status'
	goto gout
end

select @set=isnull((select value from sysoption where catalog='vipcard' and item='auto_no'), 'T')
if charindex(@set, 'TtYy')>0 
	exec p_GetAccnt1 'CRD', @no2 output
if rtrim(@no2) is null  
begin
	select @ret=1, @msg='Please give me the new card no.'
	goto gout
end
if exists(select 1 from vipcard where no=@no2) 
begin
	select @ret=1, @msg='The card no is exists, please change to anther one.'
	goto gout
end

select * into #vipcard from vipcard where 1=2
select * into #vippoint from vippoint where 1=2
update vipcard set sta=sta where no=@no1

begin tran 
save tran lost_issue

insert #vipcard select * from vipcard where no=@no1
insert #vippoint select * from vippoint where no=@no1

select @exp_s8 = '<<' + @no1
update #vipcard set sta='R', no=@no2, exp_s8=@exp_s8
update #vippoint set no=@no2

select @exp_s8 = space(20) + '>>' + @no2
update vipcard set sta='T',exp_s8=@exp_s8,cby=@empno,changed=@logdate,logmark=logmark+1 where no=@no1
if @@error<>0
begin
	select @ret=1, @msg='Transfer error'
	goto pout
end

insert vipcard select * from #vipcard
if @@error<>0
begin
	select @ret=1, @msg='Transfer error'
	goto pout
end
insert vippoint select * from #vippoint 
if @@error<>0
begin
	select @ret=1, @msg='Transfer error'
	goto pout
end

insert vipcard_tranlog
	select @no1, number, @no2, number, @empno, @logdate from #vippoint 

pout:
if @ret<>0
	rollback tran lost_issue
commit tran 

gout:
select @ret, @msg

return @ret
;
