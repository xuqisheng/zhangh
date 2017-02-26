if  exists(select * from sysobjects where name = "p_gds_master_single_rate" and type = "P")
	drop proc p_gds_master_single_rate
;
create proc  p_gds_master_single_rate
   @accnt    char(10),
   @rmrate   money,
   @rate     money,
	@rtreason	char(3),
   @empno    char(10),
   @nullwithreturn    varchar(60) output
as
declare
   @ret     int,
   @msg     varchar(60),
   @mststa  char(1),
   @roomno  char(5),
   @groupno char(10),
   @sta     char(1)

begin tran
save  tran p_gds_master_single_rate_s1

select @ret = 0,@msg = ""

update master set sta = sta where accnt = @accnt
select @mststa = sta from master where accnt = @accnt
if @mststa is null
begin
	select @ret = 1,@msg = "主单%1不存在^"+@accnt
	goto gout
end
if charindex(@mststa,'OED') > 0
begin
  select @ret = 1,@msg = "主单已结帐,不允许更改抵离日期"
	goto gout
end

update master set rmrate=@rmrate, setrate=@rate, rtreason=@rtreason, cby=@empno, changed=getdate(), logmark=logmark+1
    where accnt = @accnt
if @@rowcount = 0
	select @ret=1, @msg='Update Error'

gout:

if @ret <> 0
   rollback tran p_gds_master_single_rate_s1
commit tran


if @nullwithreturn  is null
   select @ret,@msg
else
   select @nullwithreturn = @msg
return @ret
;
