if  exists(select * from foxhis.dbo.sysobjects where name = "p_hui_phone_update")
	drop proc p_hui_phone_update;
create proc p_hui_phone_update
as

declare 
@lextno 	varchar(16),
@extno  	char(8)

declare c_phone cursor for select a.extno,b.extno from longshort a,phextroom b where a.roomno=b.extno and b.rgid ='A' order by b.extno
open c_phone
fetch c_phone into @lextno,@extno
while @@sqlstatus = 0
	begin

		update phextroom set lextno = @lextno where extno = @extno

		fetch c_phone into @lextno,@extno
	end
close c_phone
deallocate cursor c_phone

return 0;