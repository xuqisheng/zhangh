--************************
--************************
--basecode insert 
--************************
--************************
if exists (select * from sysobjects where name = 't_gds_basecode_insert' and type = 'TR')
   drop trigger t_gds_basecode_insert;
create trigger t_gds_basecode_insert
   on basecode 
   for insert as
begin
declare	@cat		varchar(30),
			@code		varchar(10),
			@grp		varchar(16),
			@des		varchar(60),
			@des1		varchar(60),
			@len		int

select @cat=cat, @code=code, @grp=grp, @des=descript, @des1=descript1 from inserted
if @@rowcount = 0 
   rollback trigger with raiserror 20000 "增加代码错误HRY_MARK"

-----------------------------
-- 某些不能随意增加的代码
-----------------------------
if @cat in ('guest_class', 'chgcod_deptno7','guest_type','artag2') 
   rollback trigger with raiserror 20000 "系统级别代码, 不能随意增加HRY_MARK"

-----------------------------
-- 代码
-----------------------------
if rtrim(@code) is null
   rollback trigger with raiserror 20000 "请输入代码HRY_MARK"
if charindex("'", @code)>0 or charindex('"', @code)>0 or charindex("'", @code)>0
   rollback trigger with raiserror 20000 "代码里禁止使用英文引号HRY_MARK"

-----------------------------
-- 描述
-----------------------------
if rtrim(@des) is null or  rtrim(@des1) is null 
   rollback trigger with raiserror 20000 "请输入描述HRY_MARK"
if charindex("'", @des)>0 or charindex('"', @des)>0 or charindex("'", @des1)>0 or charindex('"', @des1)>0
   rollback trigger with raiserror 20000 "描述里禁止使用英文引号HRY_MARK"

-----------------------------
-- artag1
-----------------------------
if @cat='artag1' 
	begin
	if @grp is null 
		select @grp = ''
	if not exists(select 1 from basecode where cat='argrp1' and code=@grp)
	   rollback trigger with raiserror 20000 "必须输入正确的类别代码HRY_MARK"
	end
end

-----------------------------
-- 代码长度控制
-----------------------------
select @len = len from basecode_cat where cat=@cat
if @@rowcount = 1
	begin
	if datalength(rtrim(@code)) > @len 
	   rollback trigger with raiserror 20000 "代码长度超长HRY_MARK"
	end

---------------------------------------------------
-- basecode相关日志处理 by zhj 2008-03-05
---------------------------------------------------
declare	@info 		 varchar(255)
select 	@info = '代码类别:'+rtrim(cat)+' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from inserted
insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
	select 'basecode_','basecode', @info, '代码增加',isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.cat)+'!'+rtrim(i.code)
	from inserted i 

;


--************************
--************************
--basecode delete
--************************
--************************
if exists (select * from sysobjects where name = 't_gds_basecode_delete' and type = 'TR')
   drop trigger t_gds_basecode_delete;
create trigger t_gds_basecode_delete
   on basecode
   for delete as
begin
	if exists ( select 1 from deleted where charindex(sys,'TtYy')>0 )
		rollback trigger with raiserror 20000 "系统级别代码, 不能删除HRY_MARK"

		---------------------------------------------------
		-- basecode相关日志处理 by zhj 
		---------------------------------------------------
		declare	@retmode		char(1),
					@empno		varchar(10),
					@shift		char(1),
					@pc_id		char(4),
					@appid		varchar(5),
					@info 		 varchar(255)
		select 	@info = '代码类别:'+rtrim(cat)+' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from deleted
		execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'basecode_','basecode', @info, '代码被删除',isnull(@empno,''),getdate(),rtrim(d.cat)+'!'+rtrim(d.code)
			from deleted d 
end
;


--************************
--************************
--basecode update
--************************
--************************
if exists (select * from sysobjects where name = 't_gds_basecode_update' and type = 'TR')
   drop trigger t_gds_basecode_update;
create trigger t_gds_basecode_update
   on basecode
   for update as
begin
declare	@cat		varchar(30),	@cat0		varchar(30),
			@code		varchar(10),	@code0	varchar(10),
			@grp		varchar(16),	@grp0		varchar(16),
			@des		varchar(60),
			@des1		varchar(60),
			@len		int

select @cat=cat, @code=code, @grp=grp, @des=descript, @des1=descript1 from inserted
if @@rowcount = 0 return 
select @cat0=cat, @code0=code, @grp0=grp from deleted
if @@rowcount = 0 return 

if exists ( select 1 from deleted where charindex(sys,'TtYy')>0 )
	begin
	if not ( update(sys) or update(sequence) )
   	rollback trigger with raiserror 20000 "系统级别代码, 不能随意修改HRY_MARK"
	end

-----------------------------
-- artag1 grp can not changed
-----------------------------
if update(grp) and @cat = 'artag1'
	begin
	 if exists(select 1 from master where class='A' and artag1=@code0)
		or exists(select 1 from ar_master where artag1=@code0)
			rollback trigger with raiserror 20000 "代码已经在帐户中使用, 不能随意修改HRY_MARK"
	end

-----------------------------
-- 描述
-----------------------------
if rtrim(@des) is null or  rtrim(@des1) is null 
   rollback trigger with raiserror 20000 "请输入描述HRY_MARK"
if charindex("'", @des)>0 or charindex('"', @des)>0 or charindex("'", @des1)>0 or charindex('"', @des1)>0
   rollback trigger with raiserror 20000 "描述里禁止使用英文引号HRY_MARK"

-----------------------------
-- 代码长度控制
-----------------------------
select @len = len from basecode_cat where cat=@cat
if @@rowcount = 1
	begin
	if datalength(rtrim(@code)) > @len 
	   rollback trigger with raiserror 20000 "代码长度超长HRY_MARK"
	end

	---------------------------------------------------
	-- basecode相关日志处理 by zhj 2008-03-05
	---------------------------------------------------
	if update(code)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'basecode_code','basecode', d.code, i.code,isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.cat)+'!'+rtrim(i.code)
			from inserted i ,deleted d
			where i.cat=d.cat and i.code=d.code
	end
	if update(descript)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'basecode_des','basecode', d.descript, i.descript,isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.cat)+'!'+rtrim(i.code)
			from inserted i ,deleted d
			where i.cat=d.cat and i.code=d.code
	end
	if update(descript1)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'basecode_des1','basecode', d.descript1, i.descript1,isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.cat)+'!'+rtrim(i.code)
			from inserted i ,deleted d
			where i.cat=d.cat and i.code=d.code
	end
	if update(sys)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'basecode_sys','basecode', d.sys, i.sys,isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.cat)+'!'+rtrim(i.code)
			from inserted i ,deleted d
			where i.cat=d.cat and i.code=d.code
	end
	if update(halt)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'basecode_halt','basecode', d.halt, i.halt,isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.cat)+'!'+rtrim(i.code)
			from inserted i ,deleted d
			where i.cat=d.cat and i.code=d.code
	end
	if update(sequence)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'basecode_seq','basecode', convert(varchar(32),d.sequence), convert(varchar(32),i.sequence),isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.cat)+'!'+rtrim(i.code)
			from inserted i ,deleted d
			where i.cat=d.cat and i.code=d.code
	end
	if update(grp)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'basecode_grp','basecode', d.grp, i.grp,isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.cat)+'!'+rtrim(i.code)
			from inserted i ,deleted d
			where i.cat=d.cat and i.code=d.code
	end
	if update(center)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'basecode_crs','basecode', d.center, i.center,isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.cat)+'!'+rtrim(i.code)
			from inserted i ,deleted d
			where i.cat=d.cat and i.code=d.code
	end


end
;


--************************
--basecode_cat delete 
--************************
if exists (select * from sysobjects where name = 't_gds_basecode_cat_delete' and type = 'TR')
   drop trigger t_gds_basecode_cat_delete;
create trigger t_gds_basecode_cat_delete
   on basecode_cat
   for delete as
begin
if exists ( select 1 from basecode a, deleted b where a.cat=b.cat )
   rollback trigger with raiserror 20000 "该类别还有代码定义, 不能删除HRY_MARK"
end
;

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_sysoption_insert' and type = 'TR')
   drop trigger t_sysoption_insert;
create trigger t_sysoption_insert
   on sysoption
   for insert as
begin
	declare	@info 		 varchar(255)
	select 	@info = '类别:'+rtrim(catalog)+' 项目:'+rtrim(item) from inserted
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'sysoption_','sysoption', @info, '参数增加',isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.catalog)+'!'+rtrim(i.item)
		from inserted i 
end
;

if exists (select * from sysobjects where name = 't_sysoption_update' and type = 'TR')
   drop trigger t_sysoption_update;
create trigger t_sysoption_update
   on sysoption
   for update as
begin

	if update(catalog)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'sysoption_cat','sysoption', d.catalog, i.catalog,isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.catalog)+'!'+rtrim(i.item)
			from inserted i,deleted d
			where i.catalog=d.catalog and i.item=d.item 
	end
	if update(item)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'sysoption_item','sysoption', d.item, i.item,isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.catalog)+'!'+rtrim(i.item)
			from inserted i,deleted d
			where i.catalog=d.catalog and i.item=d.item 
	end
	if update(value)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'sysoption_val','sysoption', d.value, i.value,isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.catalog)+'!'+rtrim(i.item)
			from inserted i,deleted d
			where i.catalog=d.catalog and i.item=d.item 
	end
	if update(def)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'sysoption_def','sysoption', d.def, i.def,isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.catalog)+'!'+rtrim(i.item)
			from inserted i,deleted d
			where i.catalog=d.catalog and i.item=d.item 
	end
	if update(remark)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'sysoption_des','sysoption', d.remark, i.remark,isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.catalog)+'!'+rtrim(i.item)
			from inserted i,deleted d
			where i.catalog=d.catalog and i.item=d.item 
	end
	if update(remark1)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'sysoption_des1','sysoption', d.remark1, i.remark1,isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.catalog)+'!'+rtrim(i.item)
			from inserted i,deleted d
			where i.catalog=d.catalog and i.item=d.item 
	end
	if update(addby)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'sysoption_add','sysoption', d.addby, i.addby,isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.catalog)+'!'+rtrim(i.item)
			from inserted i,deleted d
			where i.catalog=d.catalog and i.item=d.item 
	end
	if update(addtime)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'sysoption_addtm','sysoption', convert(varchar(32),d.addtime,111), convert(varchar(32),i.addtime,111),isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.catalog)+'!'+rtrim(i.item)
			from inserted i,deleted d
			where i.catalog=d.catalog and i.item=d.item 
	end
	if update(lic)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'sysoption_lic','sysoption', d.lic, i.lic,isnull(i.cby,''),isnull(i.changed,getdate()),rtrim(i.catalog)+'!'+rtrim(i.item)
			from inserted i,deleted d
			where i.catalog=d.catalog and i.item=d.item 
	end
end
;
if exists (select * from sysobjects where name = 't_sysoption_delete' and type = 'TR')
   drop trigger t_sysoption_delete;
create trigger t_sysoption_delete
   on sysoption
   for delete as
begin
		declare	@retmode		char(1),
					@empno		varchar(10),
					@shift		char(1),
					@pc_id		char(4),
					@appid		varchar(5),
					@info 		 varchar(255)
		select 	@info = '类别:'+rtrim(catalog)+' 项目:'+rtrim(item) from deleted
		execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'sysoption_','sysoption', @info, '参数被删除',isnull(@empno,''),getdate(),rtrim(d.catalog)+'!'+rtrim(d.item)
			from deleted d 

end
;
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_mktcode_insert' and type = 'TR')
   drop trigger t_mktcode_insert;
create trigger t_mktcode_insert
   on mktcode
   for insert as
begin
	declare	@info 		 varchar(255)
	select  @info = ' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from inserted
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'mktcode_','mktcode', @info, '内容增加',isnull(i.cby,''),isnull(i.changed,getdate()),i.code
		from inserted i 
end
;

if exists (select * from sysobjects where name = 't_mktcode_update' and type = 'TR')
   drop trigger t_mktcode_update;
create trigger t_mktcode_update
   on mktcode
   for update as
begin

	if update(code)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'mktcode_code','mktcode', d.code, i.code,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(descript)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'mktcode_des','mktcode', d.descript, i.descript,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(descript1)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'mktcode_des1','mktcode', d.descript1, i.descript1,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(grp)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'mktcode_grp','mktcode', d.grp, i.grp,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(jierep)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'mktcode_jierep','mktcode', d.jierep, i.jierep,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(flag)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'mktcode_flag','mktcode', d.flag, i.flag,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(halt)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'mktcode_halt','mktcode', d.halt, i.halt,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(sequence)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'mktcode_seq','mktcode', convert(varchar(32),d.sequence), convert(varchar(32),i.sequence),isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
end
;
if exists (select * from sysobjects where name = 't_mktcode_delete' and type = 'TR')
   drop trigger t_mktcode_delete;
create trigger t_mktcode_delete
   on mktcode
   for delete as
begin
		declare	@retmode		char(1),
					@empno		varchar(10),
					@shift		char(1),
					@pc_id		char(4),
					@appid		varchar(5),
					@info 		 varchar(255)
		select  @info = ' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from deleted
		execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'mktcode_','mktcode', @info, '代码删除',isnull(@empno,''),getdate(),d.code 
			from deleted d 
end
;
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_srccode_insert' and type = 'TR')
   drop trigger t_srccode_insert;
create trigger t_srccode_insert
   on srccode
   for insert as
begin
	declare	@info 		 varchar(255)
	select  @info = ' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from inserted
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'srccode_','srccode',@info, '内容增加',isnull(i.cby,''),isnull(i.changed,getdate()),i.code
		from inserted i 
end
;

if exists (select * from sysobjects where name = 't_srccode_update' and type = 'TR')
   drop trigger t_srccode_update;
create trigger t_srccode_update
   on srccode
   for update as
begin

	if update(code)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'srccode_code','srccode', d.code, i.code,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(descript)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'srccode_des','srccode', d.descript, i.descript,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(descript1)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'srccode_des1','srccode',  d.descript1, i.descript1,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(grp)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'srccode_grp','srccode',  d.grp, i.grp,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(halt)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'srccode_halt','srccode',  d.halt, i.halt,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(sequence)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'srccode_seq','srccode', convert(varchar(32),d.sequence),convert(varchar(32),i.sequence),isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
end
;
if exists (select * from sysobjects where name = 't_srccode_delete' and type = 'TR')
   drop trigger t_srccode_delete;
create trigger t_srccode_delete
   on srccode
   for delete as
begin
		declare	@retmode		char(1),
					@empno		varchar(10),
					@shift		char(1),
					@pc_id		char(4),
					@appid		varchar(5),
					@info 		 varchar(255)
		select  @info = ' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from deleted
		execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'srccode_','srccode', @info, '删除',isnull(@empno,''),getdate(),d.code 
			from deleted d 
end
;
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_gtype_insert' and type = 'TR')
   drop trigger t_gtype_insert;
create trigger t_gtype_insert
   on gtype
   for insert as
begin
	declare	@info 		 varchar(255)
	select  @info = ' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from inserted
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'gtype_','gtype', @info, '内容增加',isnull(i.cby,''),isnull(i.changed,getdate()),i.code
		from inserted i 
end
;

if exists (select * from sysobjects where name = 't_gtype_update' and type = 'TR')
   drop trigger t_gtype_update;
create trigger t_gtype_update
   on gtype
   for update as
begin
	declare @old varchar(254),@new varchar(254)

	if update(code)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'gtype_code','gtype', d.code, i.code,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(descript)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'gtype_des','gtype', d.descript, i.descript,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(descript1)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'gtype_des1','gtype', d.descript1, i.descript1,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(tag)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'gtype_tag','gtype',  d.tag, i.tag,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(halt)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'gtype_halt','gtype',  d.halt, i.halt,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(sequence)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'gtype_seq','gtype',  convert(varchar(32),d.sequence), convert(varchar(32),i.sequence),isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
end
;
if exists (select * from sysobjects where name = 't_gtype_delete' and type = 'TR')
   drop trigger t_gtype_delete;
create trigger t_gtype_delete
   on gtype
   for delete as
begin
		declare	@retmode		char(1),
					@empno		varchar(10),
					@shift		char(1),
					@pc_id		char(4),
					@appid		varchar(5),
					@info 		 varchar(255)
		select  @info = ' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from deleted
		execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'gtype_','gtype',@info, '删除',isnull(@empno,''),getdate(),d.code 
			from deleted d 
end
;
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_restype_insert' and type = 'TR')
   drop trigger t_restype_insert;
create trigger t_restype_insert
   on restype
   for insert as
begin
	declare	@info 		 varchar(255)
	select  @info = ' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from inserted
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'restype_','restype', @info , '内容增加',isnull(i.cby,''),isnull(i.changed,getdate()),i.code
		from inserted i 
end
;

if exists (select * from sysobjects where name = 't_restype_update' and type = 'TR')
   drop trigger t_restype_update;
create trigger t_restype_update
   on restype
   for update as
begin

	if update(code)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'restype_code','restype', d.code, i.code,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(descript)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'restype_des','restype',  d.descript, i.descript,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(descript1)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'restype_des1','restype', d.descript1, i.descript1,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(definite)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'restype_def','restype',  d.definite, i.definite,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(req_arr)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'restype_arr','restype',  d.req_arr, i.req_arr,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(req_card)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'restype_card','restype', d.req_card, i.req_card,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(req_credit)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'restype_credit','restype',  d.req_credit, i.req_credit,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(halt)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'restype_halt','restype', d.halt, i.halt,isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(sequence)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'restype_seq','restype',  convert(varchar(32),d.sequence), convert(varchar(32),i.sequence),isnull(i.cby,''),isnull(i.changed,getdate()),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
end
;

if exists (select * from sysobjects where name = 't_restype_delete' and type = 'TR')
   drop trigger t_restype_delete;
create trigger t_restype_delete
   on restype
   for delete as
begin
		declare	@retmode		char(1),
					@empno		varchar(10),
					@shift		char(1),
					@pc_id		char(4),
					@appid		varchar(5),
					@info 		 varchar(255)
		select  @info = ' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from deleted
		execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'restype_','restype', @info, '删除',isnull(@empno,''),getdate(),d.code 
			from deleted d 
end
;











