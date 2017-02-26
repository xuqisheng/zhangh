create proc p_fhb_get_newid
	@id	int out

as

begin	tran	
save	tran	p_fhb_get_newid_s
update pos_st_sysdata set id = id + 1 
select @id = id from pos_st_sysdata
commit tran 
return 0;