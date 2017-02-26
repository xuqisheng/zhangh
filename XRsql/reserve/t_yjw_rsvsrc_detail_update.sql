drop trigger t_yjw_rsvsrc_detail_update
;
create trigger t_yjw_rsvsrc_detail_update
   on rsvsrc_detail for update
	as
if update(logmark)
   insert rsvsrc_detail_log select * from inserted

;