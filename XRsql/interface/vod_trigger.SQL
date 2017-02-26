
if object_id('t_gds_vod_grd_update') is not null
    drop trigger t_gds_vod_grd_update
;
create trigger t_gds_vod_grd_update
   on vod_grd
   for update as
begin
if update(logmark)
   begin
   insert vod_grd_log select inserted.* from inserted
   end
end
;
