if exists (select 1 from sysobjects where name = 'p_wz_bos_kc_init')
	drop proc p_wz_bos_kc_init ;
create proc p_wz_bos_kc_init
			@parm			char(4)
as
declare
	@charge  	char(1),
	@id			char(6),
	@wdate		datetime,
	@pccode 		char(5),
	@site			char(5)

if @parm = 'init'
begin
	truncate table bos_detail 
	truncate table bos_hdetail 
	truncate table bos_store 
	truncate table bos_hstore 
	truncate table bos_tmpdetail 
	truncate table bos_kcmenu 
	truncate table bos_kcdish 
	
	select @wdate = getdate()
	if not exists(select 1 from sysoption where catalog = 'house' and item = 'flr_roomno')
		insert sysoption(catalog,item,value,remark) select 'house','flr_roomno','T','T:以楼层作为物流地点 F:以客房房间号码作为物流地点'

	select @id = id from bos_kcdate where @wdate >= begin_ and @wdate <= end_
	select @charge = value from sysoption where catalog = 'house' and item = 'flr_roomno'


	
	declare c_cur	cursor for select pccode,site0 from bos_pccode where jxc = 1
	open c_cur
	fetch c_cur into @pccode,@site
	while @@sqlstatus = 0
	begin
		if @charge = 'T'
			insert bos_store(id,pccode,site,code)
				select @id,@pccode,@site,'init' 
			  union 
				select @id,@pccode,code,'init' from flrcode 
		else
			insert bos_store(id,pccode,site,code)
				select @id,@pccode,@site,'init' 
			  union 
				select @id,@pccode,roomno,'init' from rmsta 
	
		fetch c_cur into @pccode,@site
	end 
	close c_cur
	deallocate cursor c_cur
end 

return 0
;

exec p_wz_bos_kc_init 'init'  ;