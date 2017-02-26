if exists(select 1 from sysobjects where type='P' and name='p_cyj_pos_store_dtl_del') 
   drop procedure p_cyj_pos_store_dtl_del;

create proc  p_cyj_pos_store_dtl_del
	@no			char(10)
as
-----------------------------------------------------------------------------
--
--  É¾³ýµ¥¾Ý
--
-----------------------------------------------------------------------------

declare 
	@type 		char(1),                                     
	@number		money,		
	@storecode 	char(2),
	@storecode1	char(2),
	@ret			int,
	@msg			char(32),
   @condid	int,
	@inumber    int

select @ret = 0, @msg = ''

begin tran 
save 	tran t_store_dtl
select @type = type, @storecode = storecode, @storecode1 = storecode1 from pos_store_mst where no = @no
delete pos_store_mst where no=@no
declare c_dtl cursor for
	select condid,inumber from pos_store_dtl where no=@no
open c_dtl
fetch c_dtl into @condid,@inumber
while @@sqlstatus = 0
begin
	select @number=number from pos_store_dtl where  no=@no and inumber=@inumber
	delete pos_store_dtl where no=@no and inumber=@inumber             
	if	@type = '0' or @type ='2'
	begin
		if exists(select 1 from pos_store_store where storecode = @storecode and condid = @condid)	
			update pos_store_store set number = isnull(number, 0) - @number where storecode = @storecode and condid = @condid
	end
	else
	begin
		if exists(select 1 from pos_store_store where storecode = @storecode and condid = @condid)	
			update pos_store_store set number = isnull(number, 0) - @number where storecode = @storecode and condid = @condid
		
		if exists(select 1 from pos_store_store where storecode = @storecode1 and condid = @condid)	
			update pos_store_store set number = isnull(number, 0) + @number where storecode = @storecode1 and condid = @condid
	end
   fetch c_dtl into @condid,@inumber
end
close c_dtl
deallocate cursor c_dtl
if @ret <> 0 
	rollback tran t_store_dtl

commit  tran t_store_dtl

select @ret, @msg;
