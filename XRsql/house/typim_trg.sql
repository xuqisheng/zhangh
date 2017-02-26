-- typim trigger 


if exists (select * from sysobjects where name = 't_hry_typim_insert' and type = 'TR')
   drop trigger t_hry_typim_insert;
create trigger t_hry_typim_insert
   on  typim
   for insert as
begin
	declare	@type			char(5),
				@tag			char(1)
	select @type=type, @tag=tag from inserted 
	if @@rowcount = 0 return 

	if @type in ('PM', 'PY') and @tag<>'P' 
	   begin
	   rollback trigger with raiserror 20000 "当前房类代码必须应用于假房HRY_MARK"
	--   raiserror ("当前房类代码必须应用于假房HRY_MARK",16,-1)
	--   rollback tran
	   end 

	declare	@info 		 varchar(255)
		select  @info = ' 代码:'+rtrim(type)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from inserted
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_','typim',@info, '增加',i.cby,i.changed,i.type 
		from inserted i 
end
;


if exists (select * from sysobjects where name = 't_hry_typim_update' and type = 'TR')
   drop trigger t_hry_typim_update;
create trigger t_hry_typim_update
   on  typim
   for update as
begin

declare	@type			char(5),
			@tag			char(1)
select @type=type, @tag=tag from inserted 
if @@rowcount = 0 return 

if update(tag) or update(type)
begin
	if @type in ('PM', 'PY') and @tag<>'P' 
		begin
		rollback trigger with raiserror 20000 "当前房类代码必须应用于假房HRY_MARK"
	--   raiserror ("当前房类代码必须应用于假房HRY_MARK",16,-1)
	--   rollback tran
		end 
end

if update(rate)
   update rmsta set rate = inserted.rate from inserted
          where rmsta.type = inserted.type and charindex(rmsta.special,'yYtT') = 0 
end


if update(type)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_code','typim', d.type, i.type,i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(descript)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_des','typim', d.descript, i.descript,i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(descript1)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_des1','typim', d.descript1, i.descript1,i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(descript2)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_des2','typim', d.descript2, i.descript2,i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(descript3)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_des3','typim', d.descript3, i.descript3,i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(descript4)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_des4','typim', d.descript4, i.descript4,i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(quantity)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_qty','typim', convert(varchar(32),d.quantity), convert(varchar(32),i.quantity),i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(overquan)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_oq','typim', convert(varchar(32),d.overquan), convert(varchar(32),i.overquan),i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(futdate)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_fd','typim', convert(varchar(32),d.futdate,111), convert(varchar(32),i.futdate,111),i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(adjquan)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_aq','typim', convert(varchar(32),d.adjquan), convert(varchar(32),i.adjquan),i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(ratecode)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_rc','typim', d.ratecode, i.ratecode,i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(futrate)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_fr','typim', convert(varchar(32),d.futrate), convert(varchar(32),i.futrate),i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(begin_)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_begin','typim',convert(varchar(32),d.begin_,111), convert(varchar(32),i.begin_,111),i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(hotelcode)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_htl','typim', d.hotelcode, i.hotelcode,i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(sequence)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_seq','typim', convert(varchar(32),d.sequence), convert(varchar(32),i.sequence),i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(gtype)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_gtype','typim', d.gtype, i.gtype,i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(tag)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_tag','typim', d.tag, i.tag,i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(internal)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_int','typim', convert(varchar(32),d.internal), convert(varchar(32),i.internal),i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(yieldable)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_ya','typim', d.yieldable, i.yieldable,i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(yieldcat)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_yc','typim', d.yieldcat, i.yieldcat,i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(crsthr)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_thr','typim', convert(varchar(32),d.crsthr),convert(varchar(32),i.crsthr),i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(crsper)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_per','typim', convert(varchar(32),d.crsper), convert(varchar(32),i.crsper),i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(pic)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_pic','typim', d.pic, i.pic,i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end
if update(halt)
begin
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'typim_halt','typim', d.halt, i.halt,i.cby,i.changed,i.type
		from inserted i,deleted d
		where i.type = d.type
end

;

if exists (select * from sysobjects where name = 't_hry_typim_delete' and type = 'TR')
   drop trigger t_hry_typim_delete;
create trigger t_hry_typim_delete
   on  typim
   for delete as
begin
if exists (select 1 from master,deleted where master.type = deleted.type)
   begin
   rollback trigger with raiserror 20000 "已有客人使用本房类,你不能删除HRY_MARK"
--   raiserror ("已有客人使用本房类,你不能删除HRY_MARK",16,-1)
--   rollback tran
   end 
else if exists (select 1 from rmsta,deleted where rmsta.type = deleted.type)
   begin
   rollback trigger with raiserror 20000 "已有房间使用本房类,你不能删除HRY_MARK"
--   raiserror ("已有房间使用本房类,你不能删除HRY_MARK",16,-1)
--   rollback tran
   end 
else if exists (select 1 from rsvtype,deleted where rsvtype.type = deleted.type)
   begin
   rollback trigger with raiserror 20000 "已有预订使用本房类,你不能删除HRY_MARK"
--   raiserror ("已有预订使用本房类,你不能删除HRY_MARK",16,-1)
--   rollback tran
   end 
else if exists (select 1 from grprate,deleted where grprate.type = deleted.type)
   begin
   rollback trigger with raiserror 20000 "已有团体定义本房类房价,你不能删除HRY_MARK"
--   raiserror ("已有团体定义本房类房价,你不能删除HRY_MARK",16,-1)
--   rollback tran
   end 

declare	@retmode		char(1),
			@empno		varchar(10),
			@shift		char(1),
			@pc_id		char(4),
			@appid		varchar(5),
			@info 		 varchar(255)
select  @info = ' 代码:'+rtrim(type)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from deleted
execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
	select 'typim_','typim', @info, '代码被删除',isnull(@empno,''),getdate(),d.type 
	from deleted d 

end
;

