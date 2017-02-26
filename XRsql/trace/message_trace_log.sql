---------------------------------------------------
-- message_trace日志处理 by zhj 2009-03-26
---------------------------------------------------
---------------------------------------------------
-- 列追加: 最新修改人信息
-- message_trace.sql中创建代码已经修改，这里代码是为了升级等
---------------------------------------------------
if not exists (select 1 from  syscolumns  where  id = object_id('message_trace') and name = 'cby')
begin
	alter table message_trace add cby	  char(10)	default '!'  		null
	alter table message_trace add changed datetime	default getdate()	null 
end
;
------------------------------------------------------------------
-- message_trace 
------------------------------------------------------------------
delete from basecode where cat = 'lgfl_prefix' and code = 'trc_'
;
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'trc_', 'Trace', 'Trace', 'F', 'F', 0, 'O', 'F','FOX',getdate() 
;

delete from  lgfl_des  where  columnname like 'trc_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'trc_','Trace','Trace','O'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'trc_recvaddr','接受人地址','Receiver Addr','O'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'trc_receiver','接受人','Receiver','O'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'trc_content','事务内容 ','Content','O'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'trc_inure','生效时间','Inure','O'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'trc_abate','失效时间','Abate','O'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'trc_tag','事务状态','Tag','O'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'trc_resolver','处理人','Resolver','O'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'trc_resolvedate','处理时间 ','Resolve Date','O'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'trc_remark','处理备注','Remark','O'
;
------------------------------------------------------------------
-- message_trace  trigger
------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_message_trace' and type = 'TR')
   drop trigger t_message_trace
;
create trigger t_message_trace
   on message_trace
   for update as
begin
	--recvaddr
	if update(recvaddr)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'trc_recvaddr',i.accnt, d.recvaddr, i.recvaddr,isnull(i.cby,''),isnull(i.changed,getdate()),convert(varchar(128), i.id) 
			from inserted i, deleted d
			where i.id = d.id 
	end
	-- receiver
	if update(receiver)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'trc_receiver',i.accnt, d.receiver, i.receiver,isnull(i.cby,''),isnull(i.changed,getdate()),convert(varchar(128), i.id) 
			from inserted i, deleted d
			where i.id = d.id 
	end
	--content

	--inure
	if update(inure)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'trc_inure',i.accnt, convert(varchar(32),d.inure,111), convert(varchar(32),i.inure,111),isnull(i.cby,''),isnull(i.changed,getdate()),convert(varchar(128), i.id) 
			from inserted i, deleted d
			where i.id = d.id 
	end
	--abate
	if update(abate)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'trc_abate',i.accnt, convert(varchar(32),d.abate,111), convert(varchar(32),i.abate,111),isnull(i.cby,''),isnull(i.changed,getdate()),convert(varchar(128), i.id) 
			from inserted i, deleted d
			where i.id = d.id 
	end
	--tag
	if update(tag)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'trc_tag',i.accnt, d.tag, i.tag,isnull(i.cby,''),isnull(i.changed,getdate()),convert(varchar(128), i.id) 
			from inserted i, deleted d
			where i.id = d.id 
	end
	--resolver
	if update(resolver)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'trc_resolver',i.accnt, d.resolver, i.resolver,isnull(i.cby,''),isnull(i.changed,getdate()),convert(varchar(128), i.id) 
			from inserted i, deleted d
			where i.id = d.id 
	end
	--resolvedate
	if update(resolvedate)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'trc_resolvedate',i.accnt, convert(varchar(32),d.resolvedate,111),convert(varchar(32),i.resolvedate,111),isnull(i.cby,''),isnull(i.changed,getdate()),convert(varchar(128), i.id) 
			from inserted i, deleted d
			where i.id = d.id 
	end
	--remark
	if update(remark)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'trc_remark',i.accnt, d.remark, i.remark,isnull(i.cby,''),isnull(i.changed,getdate()),convert(varchar(128), i.id) 
			from inserted i, deleted d
			where i.id = d.id 
	end

end
;
