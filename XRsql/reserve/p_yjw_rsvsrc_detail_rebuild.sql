if object_id('p_yjw_rsvsrc_detail_rebuild') is not null
drop proc p_yjw_rsvsrc_detail_rebuild
;
create proc p_yjw_rsvsrc_detail_rebuild
as
declare
@accnt  char(10),
@id     int

declare c_getaccnt cursor for select accnt,id from rsvsrc where accnt not in(select distinct accnt from rsvsrc_detail)
open c_getaccnt
fetch c_getaccnt into @accnt,@id
while @@sqlstatus=0
     begin
	     if substring(@accnt,1,1)='F'
				 exec p_yjw_rsvsrc_detail_accnt @accnt
        if (substring(@accnt,1,1)='G' or substring(@accnt,1,1)='M' or substring(@accnt,1,1)='B')
             exec p_yjw_rsvsrc_detail_accnt_grp @accnt,@id
			fetch c_getaccnt into @accnt,@id
     end

close c_getaccnt
deallocate cursor c_getaccnt
;