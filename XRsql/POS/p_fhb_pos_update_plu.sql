drop proc p_fhb_pos_update_plu;
create proc p_fhb_pos_update_plu

as 

declare	@id	int
--declare c_happy cursor for select id from pos_plu
declare c_happy cursor for select distinct a.id from pos_happytime a,pos_plu b where b.id = a.id 
open c_happy
fetch	c_happy into @id
while @@sqlstatus = 0 
begin
	exec p_fhb_pos_plumod_record @id = @id
	fetch	c_happy into @id
end
close c_happy
deallocate cursor c_happy;