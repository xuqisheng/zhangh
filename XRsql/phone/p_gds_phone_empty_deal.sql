drop proc p_gds_phone_empty_deal;
create proc p_gds_phone_empty_deal
   @modu_id	    char(2) ,
   @pc_id	    char(4) ,
   @shift	    char(1) ,
   @empno	    char(10) ,
   @inumber     int ,
   @accnt       varchar(20),
	@flag			 char(1) = 'F'
as
-- ------------------------------------------------------------------------------------
--		漏单电话处理
--		
--		2009.8.24 改善备注内容的显示 
-- ------------------------------------------------------------------------------------
declare
   @ret         int,
   @msg      	 varchar(60),
   @phcode		 varchar(50),
   @pccode      varchar(5),
	@calltype	 char(1),
	@p_extno		 char(5),
   @package     varchar(3),
   @selemark    char(13),
   @lastnumb    int,
   @inbalance   money,
   @charge      money,
   @bdate       datetime,
	@refer		 char(10),
	@today		 datetime,
	@len			 char(10),
	@date0		 varchar(20),
	@length		int 

select @ret=0, @msg="", @today = getdate()

select @refer = refer  from phfolio where inumber=@inumber
if @@rowcount <> 1
begin
	select 1, '不存在该话单 !'
	return 1
end

begin tran
save tran sss

if substring(@accnt, 1, 1) = 'A'
begin
	select @accnt = substring(@accnt,2,10)
	select @p_extno=room, @calltype=calltype, @charge = fee, @phcode=phcode, @length=length,@date0= convert(char(10),date,111)+' '+convert(char(8),date,8) from phfolio where inumber = @inumber
	if @length%60 = 0
		select @len = convert(char(10),@length/60) 
	else
		select @len = convert(char(10),@length/60 + 1) 
	exec @ret = p_gds_phone_pccode @p_extno, 'RM', @phcode, @calltype, @pccode output
	if @ret <> 0
		select @ret=1, @msg= '费用码提取有误 !'
	if @ret = 0
	begin
		select @selemark='a'+@phcode,@bdate = bdate1 from sysdata
		select @package = ' ' --  + substring(@pccode, 1, 2)

		select @phcode = substring(@phcode + '--'+@date0+'--'+@len, 1, 50) 
		select @len = '' 
--		exec @ret = p_gl_accnt_post_charge @selemark, @lastnumb, @inbalance, @modu_id, @pc_id, @shift,@empno, @accnt, '', '', @pccode, @package,@charge, NULL, @bdate, NULL, 'IN','R', null, 'I', @msg out
		exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id,0,@shift, @empno, @accnt,0, @pccode, '',1, @charge,@charge,0,0,0,0,@len,@phcode, @today, '','', 'IRYY', 0, '', @msg out
		if @ret = 0
		begin
			update phfolio set refer = @accnt where inumber = @inumber
			if @@error <> 0
				select @ret=1, @msg = '更新 phfolio 失败 !'
		end
	end
end
else
begin
	select @accnt = rtrim(substring(@accnt,2,10))
	if not exists(select 1 from phdeptdef where dept=@accnt)
		select @ret = 1, @msg = '部门代码不存在 !'
	else
	begin
		update phfolio set refer = @accnt where inumber = @inumber
		if @@error <> 0
			select @ret=1, @msg = '更新 phfolio 失败 !'
	end
end

if @ret <> 0
	rollback tran sss
else
	if @flag = 'T'
		insert phempty_deal select getdate(), @inumber, @refer, @accnt, @empno
commit tran

select @ret,@msg

return @ret
/* ### DEFNCOPY: END OF DEFINITION */
;