
IF OBJECT_ID('p_gds_vipcard_maint') IS NOT NULL
    DROP PROCEDURE p_gds_vipcard_maint;
create proc p_gds_vipcard_maint
as
--------------------------------------------------------------------
--	vipcard maint.   维护，重建数据使用
--------------------------------------------------------------------
declare
	@no		char(20),
	@hno		char(7),
	@type		char(3),
	@sta0		char(1),
	@sta		char(1),
	@dep		datetime,
	@resby	char(10),
	@reserved	datetime,
	@cardcode	char(10),
	@cardcode0	char(10)

-- vipcard_type.calc
if exists(select 1 from vipcard_type where calc not in (select code from vipptcode))
begin
	select * from vipcard_type where calc not in (select code from vipptcode)
	return 
end
 
-- vipcard_type.guestcard
if exists(select 1 from vipcard_type where guestcard not in (select code from guest_card_type where cat<>'CC'))
begin
	select * from vipcard_type where guestcard not in (select code from guest_card_type where cat<>'CC')
	return 
end

-- guest_card, guest.cardcode
declare c_vip cursor for select no,hno,type,dep,sta,resby,reserved from vipcard order by no
open c_vip
fetch c_vip into @no,@hno,@type,@dep,@sta,@resby,@reserved
while @@sqlstatus = 0
begin
	select @cardcode=guestcard from vipcard_type where code=@type
	if @sta = 'I' 
		select @sta = 'F'
	else
		select @sta = 'T'	

	-- guest_card
	select @cardcode0=cardcode, @sta0=halt from guest_card where no=@hno and cardno=@no
	if @@rowcount = 0
		insert guest_card(no,cardcode,cardno,cardlevel,expiry_date,halt,cby,changed)
			values(@hno,@cardcode,@no,'',	@dep,@sta,@resby,@reserved)
	else if @cardcode <> @cardcode0 or @sta <> @sta0
		update guest_card set cardcode=@cardcode, halt=@sta where no=@hno and cardno=@no

	-- guest
	if exists(select 1 from guest where no=@hno and cardcode='')
		update guest set cardcode=@cardcode, cardno=@no, cby=@resby, changed=@reserved, logmark=logmark+1 where no=@hno

	fetch c_vip into @no,@hno,@type,@dep,@sta,@resby,@reserved
end
close c_vip
deallocate cursor c_vip


return 0
;

