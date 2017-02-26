--------------------------------------------------
--		通过触发器 维护  armst 的分账号
--    只有个人的卡，才更新 guest_card
--------------------------------------------------


-----------------------
--	Insert
-----------------------
create trigger t_gds_vipcard_insert
   on vipcard
   for insert as
begin
declare		
	@no			char(20),
	@sno			char(20),
	@hno			char(7),
	@cno			char(7),
	@cardno		char(20),
	@end			datetime,
	@araccnt1	char(10),
	@empno		char(10),
	@cardcode	char(10),
	@type			char(3)

select @no=no, @sno=sno, @hno=hno, @cno=cno, @type=type,@end=dep,@araccnt1=araccnt1, @empno = cby from inserted
if @@rowcount=1 
	begin
	select @cardcode = guestcard from vipcard_type where code=@type
--	if @no like 'K%' and datalength(rtrim(@no))=7 and @sno<>''   -- 保存手工卡号
--		select @cardno = @sno
--	else
		select @cardno = @no

	-- 考虑关联 guest_card 
	if @hno is not null and @hno<>'' 
		begin
		delete from guest_card where no=@hno and cardcode=@cardcode and cardno=@cardno
		insert guest_card (no,cardcode,cardno,cardlevel,expiry_date,halt,cby,changed)
			select @hno, @cardcode, @cardno, '', @end, 'F', @empno, getdate()
		end
	if @cno is not null and @cno<>'' 
		begin
		delete from guest_card where no=@cno and cardcode=@cardcode and cardno=@cardno
		insert guest_card (no,cardcode,cardno,cardlevel,expiry_date,halt,cby,changed)
			select @cno, @cardcode, @cardno, '', @end, 'F', @empno, getdate()
		end

	-- 会员卡自动维护分帐户 
	if @araccnt1 <> ''
		exec p_gds_master_ar_subaccnt @araccnt1, @empno
	end
end
;

-----------------------
--	Update
-----------------------
create trigger t_gds_vipcard_update
   on vipcard
   for update as
begin
declare 
	@no0			char(20),
	@no1			char(20),
	@cardno0		char(20),
	@cardno1		char(20),
	@sno0			char(20),
	@sno1			char(20),
	@hno0			char(7),
	@hno1			char(7),
	@cno0			char(20),
	@cno1			char(20),
	@type0		char(3),
	@type1		char(3),
	@araccnt0	char(10),
	@araccnt1	char(10),
	@cardcode0	char(10),
	@cardcode1	char(10)

declare
	@end			datetime,
	@empno		char(10)

-- 考虑关联 guest_card 
select @no0=no, @sno0=sno, @hno0=hno, @cno0=cno, @type0=type, @araccnt0=araccnt1 from deleted
select @no1=no, @sno1=sno, @hno1=hno, @cno1=cno, @type1=type, @araccnt1=araccnt1, @empno = cby, @end=dep from inserted
select @cardcode0 = guestcard from vipcard_type where code=@type0
select @cardcode1 = guestcard from vipcard_type where code=@type1

-- cardno 
--if @no0 like 'K%' and datalength(rtrim(@no0))=7 and @sno0<>'' 
--	select @cardno0 = @sno0
--else
	select @cardno0 = @no0
--if @no1 like 'K%' and datalength(rtrim(@no1))=7 and @sno1<>'' 
--	select @cardno1 = @sno1
--else
	select @cardno1 = @no1

if @hno0 is not null and @hno0<>'' 
	delete from guest_card where no=@hno0 and cardcode=@cardcode0 and cardno=@cardno0
if @cno0 is not null and @cno0<>'' 
	delete from guest_card where no=@cno0 and cardcode=@cardcode0 and cardno=@cardno0

if @hno1 is not null and @hno1<>''
	begin
	delete guest_card where no=@hno1 and cardcode=@cardcode1 and cardno=@cardno1
	insert guest_card (no,cardcode,cardno,cardlevel,expiry_date,halt,cby,changed)
		select @hno1, @cardcode1, @cardno1, '', @end, 'F', @empno, getdate()
	end
if @cno1 is not null and @cno1<>'' 
	begin
	delete guest_card where no=@cno1 and cardcode=@cardcode1 and cardno=@cardno1
	insert guest_card (no,cardcode,cardno,cardlevel,expiry_date,halt,cby,changed)
		select @cno1, @cardcode1, @cardno1, '', @end, 'F', @empno, getdate()
	end

-- Log
if update(logmark)
	insert vipcard_log select * from deleted

-- 会员卡自动维护分帐户 
if update(araccnt1)
	begin
	select @araccnt1=araccnt1, @empno = cby from inserted
	if @@rowcount=1 and @araccnt1 <> ''
		exec p_gds_master_ar_subaccnt @araccnt1, @empno
	select @araccnt1=araccnt1, @empno = cby from deleted
	if @@rowcount=1 and @araccnt1 <> ''
		exec p_gds_master_ar_subaccnt @araccnt1, @empno
	end

end
;

-----------------------
--	Delete
-----------------------
create trigger t_gds_vipcard_delete
   on vipcard
   for delete as
begin
declare 
	@no			char(20),
	@sno			char(20),
	@hno			char(7),
	@cno			char(7),
	@cardno		char(20),
	@araccnt1	char(10),
	@empno		char(10),
	@cardcode	char(10),
	@type			char(3)

select @no=no, @sno=sno, @hno=hno, @type=type, @araccnt1=araccnt1, @empno = cby from deleted
if @@rowcount=1
	begin
	select @cardcode = guestcard from vipcard_type where code=@type
--	if @no like 'K%' and datalength(rtrim(@no))=7 and @sno<>''     -- 保存手工卡号
--		select @cardno = @sno
--	else
		select @cardno = @no

	-- 考虑关联 guest_card 
	if @hno is not null and @hno<>''
		delete from guest_card where no=@hno and cardcode=@cardcode and cardno=@cardno
	if @cno is not null and @cno<>''
		delete from guest_card where no=@cno and cardcode=@cardcode and cardno=@cardno

	-- 会员卡自动维护分帐户 
	if @araccnt1 <> ''
		exec p_gds_master_ar_subaccnt @araccnt1, @empno
	end

end
;
