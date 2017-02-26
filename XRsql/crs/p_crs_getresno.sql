// ------------------------------------------------------------------------
//	 get resno
// ------------------------------------------------------------------------ 
if exists (select 1 from sysobjects where name = 'p_crs_getresno'  and type = 'P')
	drop procedure p_crs_getresno;

create  procedure p_crs_getresno  
as
begin 
	declare @accnt    varchar(10),
   	     @ret     int, 
   	     @len     int 
	declare @accnt1    varchar(20) 

	exec @ret = p_GetAccnt1 'CRS',@accnt output
	if @ret <> 0
	begin
   	if not exists(select 1 from sys_extraid where cat='CRS')
		begin
			insert into sys_extraid(cat,descript,id) values('CRS','CRS res no',0)
		end 
		exec @ret = p_GetAccnt1 'CRS',@accnt output
	end 
	if @ret <> 0
	begin
		select @accnt = ''	
	end
	else
	begin
		select @accnt = ltrim(@accnt)
		select @accnt1 = substring(ltrim(reverse(@accnt)+'0000000000'),1,7) 
		select @accnt = 'C'+substring(convert(char(4),datepart(yy,getdate())),3,2)+reverse(@accnt1)
	end

	select @accnt 
	return @ret
end
;

exec p_crs_getresno
;
