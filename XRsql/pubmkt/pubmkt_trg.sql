--------------------------------------
--	rmratedef 
--------------------------------------
if exists (select * from sysobjects where name = 't_gds_rmratedef_delete' and type = 'TR')
   drop trigger t_gds_rmratedef_delete;
create trigger t_gds_rmratedef_delete
   on rmratedef
   for delete as
begin
	declare	@code		char(10)
	select @code = code from deleted 
	if @@rowcount = 1
	begin
		if exists ( select 1 from rmratecode_link a, rmratecode b where a.code=b.code and a.rmcode=@code)
			rollback trigger with raiserror 20000 "该代码正在使用, 不能删除HRY_MARK"
	end 
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from deleted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'rmrd_','rmrd',@info, '删除',isnull(@empno,''),getdate(),code 
		from deleted 
end
;
if exists (select * from sysobjects where name = 't_gds_rmratedef_insert' and type = 'TR')
   drop trigger t_gds_rmratedef_insert;
create trigger t_gds_rmratedef_insert
   on rmratedef
   for insert as
begin
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from inserted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'rmrd_','rmrd',@info, '增加',isnull(@empno,''),getdate(),code 
		from inserted 
end
;

--------------------------------------
--	rmratecode 
--------------------------------------

if exists (select * from sysobjects where name = 't_gds_rmratecode_delete' and type = 'TR')
   drop trigger t_gds_rmratecode_delete;
create trigger t_gds_rmratecode_delete
   on rmratecode
   for delete as
begin
	declare	@code		char(10)
	select @code = code from deleted 
	if @@rowcount = 1
	begin
		if exists ( select 1 from guest_extra where item='ratecode' and value=@code)
		begin
			rollback trigger with raiserror 20000 "该代码正在使用, 不能删除HRY_MARK"
			return 
		end
		if exists ( select 1 from master where ratecode=@code)
		begin
			rollback trigger with raiserror 20000 "该代码正在使用, 不能删除HRY_MARK"
			return 
		end
	end 
	
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from deleted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'rmrc_','rmrc',@info, '删除',isnull(@empno,''),getdate(),code 
		from deleted 
end
;

if exists (select * from sysobjects where name = 't_gds_rmratecode_insert' and type = 'TR')
   drop trigger t_gds_rmratecode_insert;
create trigger t_gds_rmratecode_insert
   on rmratecode
   for insert as
begin
	
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from inserted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'rmrc_','rmrc',@info, '增加',isnull(@empno,''),getdate(),code 
		from inserted 
end
;
--------------------------------------
--	rmratecode_link 
--------------------------------------

if exists (select * from sysobjects where name = 't_rmratecode_link_delete' and type = 'TR')
   drop trigger t_rmratecode_link_delete;
create trigger t_rmratecode_link_delete
   on rmratecode_link
   for delete as
begin
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' 代码:'+rtrim(code)+' 优先级:'+convert(varchar(16),pri) from deleted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'rmrcl_','rmrcl',@info, '删除',isnull(@empno,''),getdate(),rtrim(code)+'!'+convert(varchar(16),pri) 
		from deleted 
end
;

if exists (select * from sysobjects where name = 't_rmratecode_link_insert' and type = 'TR')
   drop trigger t_rmratecode_link_insert;
create trigger t_rmratecode_link_insert
   on rmratecode_link
   for insert as
begin
	
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' 代码:'+rtrim(code)+' 优先级:'+convert(varchar(16),pri) from deleted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'rmrcl_','rmrcl',@info, '增加',isnull(@empno,''),getdate(),rtrim(code)+'!'+convert(varchar(16),pri) 
		from inserted 
end
;

if exists (select * from sysobjects where name = 't_rmratecode_link_update' and type = 'TR')
   drop trigger t_rmratecode_link_update;
create trigger t_rmratecode_link_update
   on rmratecode_link
   for update as
begin
	
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	
	if update(code)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrcl_code','rmrcl',d.code ,i.code ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+convert(varchar(16),i.pri)
			from inserted i,deleted d 
			where i.code = d.code and i.pri = d.pri
	end
	
	 
	if update(pri)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrcl_pri','rmrcl',convert(varchar(255),d.pri) ,convert(varchar(255),i.pri) ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+convert(varchar(16),i.pri)
			from inserted i,deleted d 
			where i.code = d.code and i.pri = d.pri
	end
	if update(rmcode)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrcl_rmcode','rmrcl',d.rmcode ,i.rmcode ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+convert(varchar(16),i.pri)
			from inserted i,deleted d 
			where i.code = d.code and i.pri = d.pri
	end
end
;
--------------------------------------
--	rmrate_season 
--------------------------------------

if exists (select * from sysobjects where name = 't_rmrate_season_delete' and type = 'TR')
   drop trigger t_rmrate_season_delete;
create trigger t_rmrate_season_delete
   on rmrate_season
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
		select 'rmrs_','rmrs',@info, '删除',isnull(@empno,''),getdate(),code 
		from deleted 
end
;

if exists (select * from sysobjects where name = 't_rmrate_season_insert' and type = 'TR')
   drop trigger t_rmrate_season_insert;
create trigger t_rmrate_season_insert
   on rmrate_season
   for insert as
begin
	
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from inserted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'rmrs_','rmrs',@info, '增加',isnull(@empno,''),getdate(),code 
		from inserted 
end
;
if exists (select * from sysobjects where name = 't_rmrate_season_update' and type = 'TR')
   drop trigger t_rmrate_season_update;
create trigger t_rmrate_season_update
   on rmrate_season
   for update as
begin
	
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	
	if update(code)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrs_code','rmrs', d.code ,i.code ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code = d.code 
	end
	if update(descript)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrs_descript','rmrs', d.descript ,i.descript ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code = d.code
	end
	if update(descript1)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrs_descript1','rmrs', d.descript1 ,i.descript1 ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code = d.code
	end
	if update(begin_)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrs_begin_','rmrs', convert(varchar(255),d.begin_,111) ,convert(varchar(255),i.begin_,111) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code = d.code
	end
	if update(end_)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrs_end_','rmrs', convert(varchar(255),d.end_,111) ,convert(varchar(255),i.end_,111) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code = d.code
	end
	if update(day)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrs_day','rmrs', d.day ,i.day ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code = d.code
	end
	if update(week)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrs_week','rmrs', d.week ,i.week ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code = d.code
	end
	if update(sequence)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrs_sequence','rmrs', convert(varchar(255),d.sequence) ,convert(varchar(255),i.sequence) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code = d.code
	end	
	
end
;

--------------------------------------
--	rmratedef_sslink 
--------------------------------------

if exists (select * from sysobjects where name = 't_rmratedef_sslink_delete' and type = 'TR')
   drop trigger t_rmratedef_sslink_delete;
create trigger t_rmratedef_sslink_delete
   on rmratedef_sslink
   for delete as
begin
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' 代码:'+rtrim(code)+' 季节:'+rtrim(season) from deleted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'rmrdl_','rmrdl',@info, '删除',isnull(@empno,''),getdate(),rtrim(code)+'!'+rtrim(season) 
		from deleted 
end
;

if exists (select * from sysobjects where name = 't_rmratedef_sslink_insert' and type = 'TR')
   drop trigger t_rmratedef_sslink_insert;
create trigger t_rmratedef_sslink_insert
   on rmratedef_sslink
   for insert as
begin
	
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' 代码:'+rtrim(code)+' 季节:'+rtrim(season) from deleted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'rmrdl_','rmrdl',@info, '增加',isnull(@empno,''),getdate(),rtrim(code)+'!'+rtrim(season) 
		from inserted 
end
;
if exists (select * from sysobjects where name = 't_rmratedef_sslink_update' and type = 'TR')
   drop trigger t_rmratedef_sslink_update;
create trigger t_rmratedef_sslink_update
   on rmratedef_sslink
   for update as
begin
	
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	
	if update(code)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrdl_code','rmrdl', d.code ,i.code ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+rtrim(i.season)
			from inserted i,deleted d
			where i.code = d.code and i.season = d.season 
	end
	if update(season)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrdl_season','rmrdl', d.season ,i.season ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+rtrim(i.season)
			from inserted i,deleted d
			where i.code = d.code and i.season = d.season 
	end
	if update(rate1)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrdl_rate1','rmrdl', convert(varchar(255),d.rate1) ,convert(varchar(255),i.rate1) ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+rtrim(i.season)
			from inserted i,deleted d
			where i.code = d.code and i.season = d.season 
	end
	if update(rate2)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrdl_rate2','rmrdl', convert(varchar(255),d.rate2) ,convert(varchar(255),i.rate2) ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+rtrim(i.season)
			from inserted i,deleted d
			where i.code = d.code and i.season = d.season 
	end
	if update(rate3)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrdl_rate3','rmrdl', convert(varchar(255),d.rate3) ,convert(varchar(255),i.rate3) ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+rtrim(i.season)
			from inserted i,deleted d
			where i.code = d.code and i.season = d.season 
	end
	if update(rate4)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrdl_rate4','rmrdl', convert(varchar(255),d.rate4) ,convert(varchar(255),i.rate4) ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+rtrim(i.season)
			from inserted i,deleted d
			where i.code = d.code and i.season = d.season 
	end
	if update(rate5)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrdl_rate5','rmrdl', convert(varchar(255),d.rate5) ,convert(varchar(255),i.rate5) ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+rtrim(i.season)
			from inserted i,deleted d
			where i.code = d.code and i.season = d.season 
	end
	if update(rate6)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrdl_rate6','rmrdl', convert(varchar(255),d.rate6) ,convert(varchar(255),i.rate6) ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+rtrim(i.season)
			from inserted i,deleted d
			where i.code = d.code and i.season = d.season 
	end
	if update(extra)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrdl_extra','rmrdl', convert(varchar(255),d.extra) ,convert(varchar(255),i.extra) ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+rtrim(i.season)
			from inserted i,deleted d
			where i.code = d.code and i.season = d.season 
	end
	if update(child)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrdl_child','rmrdl', convert(varchar(255),d.child) ,convert(varchar(255),i.child) ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+rtrim(i.season)
			from inserted i,deleted d
			where i.code = d.code and i.season = d.season 
	end
	if update(crib)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrdl_crib','rmrdl', convert(varchar(255),d.crib) ,convert(varchar(255),i.crib) ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+rtrim(i.season)
			from inserted i,deleted d
			where i.code = d.code and i.season = d.season 
	end
	if update(packages)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrdl_packages','rmrdl', d.packages ,i.packages ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+rtrim(i.season)
			from inserted i,deleted d
			where i.code = d.code and i.season = d.season 
	end
	if update(amenities)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrdl_amenities','rmrdl', d.amenities ,i.amenities ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+rtrim(i.season)
			from inserted i,deleted d
			where i.code = d.code and i.season = d.season 
	end
	
end
;

--------------------------------------
--	rmrate_factor 
--------------------------------------

if exists (select * from sysobjects where name = 't_rmrate_factor_delete' and type = 'TR')
   drop trigger t_rmrate_factor_delete;
create trigger t_rmrate_factor_delete
   on rmrate_factor
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
		select 'rmrf_','rmrf',@info, '删除',isnull(@empno,''),getdate(),code 
		from deleted 
end
;

if exists (select * from sysobjects where name = 't_rmrate_factor_insert' and type = 'TR')
   drop trigger t_rmrate_factor_insert;
create trigger t_rmrate_factor_insert
   on rmrate_factor
   for insert as
begin
	
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from inserted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'rmrf_','rmrf',@info, '增加',isnull(@empno,''),getdate(),code 
		from inserted 
end
;
if exists (select * from sysobjects where name = 't_rmrate_factor_update' and type = 'TR')
   drop trigger t_rmrate_factor_update;
create trigger t_rmrate_factor_update
   on rmrate_factor
   for update as
begin
	
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	
	if update(code)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrf_code','rmrf',d.code ,i.code ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(descript)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrf_descript','rmrf',d.descript ,i.descript ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(descript1)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrf_descript1','rmrf',d.descript1 ,i.descript1 ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(multi)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrf_multi','rmrf',convert(varchar(255),d.multi) ,convert(varchar(255),i.multi),isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(adder)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrf_adder','rmrf',convert(varchar(255),d.adder) ,convert(varchar(255),i.adder) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end

end
;

--------------------------------------
--	rmrate_calendar 
--------------------------------------

if exists (select * from sysobjects where name = 't_rmrate_calendar_delete' and type = 'TR')
   drop trigger t_rmrate_calendar_delete;
create trigger t_rmrate_calendar_delete
   on rmrate_calendar
   for delete as
begin
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' 日期:'+convert(varchar(20),date,111) from deleted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'rmrcal_','rmrcal',@info, '删除',isnull(@empno,''),getdate(),convert(varchar(20),date,111) 
		from deleted 
end
;

if exists (select * from sysobjects where name = 't_rmrate_calendar_insert' and type = 'TR')
   drop trigger t_rmrate_calendar_insert;
create trigger t_rmrate_calendar_insert
   on rmrate_calendar
   for insert as
begin
	
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' 日期:'+convert(varchar(20),date,111) from deleted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'rmrcal_','rmrcal',@info, '增加',isnull(@empno,''),getdate(),convert(varchar(20),date,111) 
		from inserted 
end
;
if exists (select * from sysobjects where name = 't_rmrate_calendar_update' and type = 'TR')
   drop trigger t_rmrate_calendar_update;
create trigger t_rmrate_calendar_update
   on rmrate_calendar
   for update as
begin
	
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	
	if update(date)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrcal_date','rmrcal', convert(varchar(255),d.date,111) ,convert(varchar(255),i.date,111) ,isnull(@empno,''),getdate(),convert(varchar(20),i.date,111)
			from inserted i,deleted d
			where i.date = d.date
	end
	if update(factor)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrcal_factor','rmrcal', d.factor ,i.factor ,isnull(@empno,''),getdate(),convert(varchar(20),i.date,111)
			from inserted i,deleted d
			where i.date = d.date
	end
end
;






--------------------------------------
--	下方为了  crslink 
--------------------------------------
--------------------------------------
--	rmratecode 
--------------------------------------

if exists (select * from sysobjects where name = 't_gds_rmratecode_update' and type = 'TR')
   drop trigger t_gds_rmratecode_update;
create trigger t_gds_rmratecode_update
   on rmratecode
   for update as
begin
	/*
	declare	@code		char(10)
	select @code = code from inserted  
	if @@rowcount = 1
	begin
		declare	
			@crsid			char(30),
			@crscode			char(10),
			@des				char(60),
			@des1				char(60),
			@clink			varchar(100), 
			@sequence		int
		declare c_crsid cursor for select crsid, code, descript, descript1, sequence, channel_link  from crslink_rc where pmsrc=@code
		open c_crsid 
		fetch c_crsid into @crsid, @crscode, @des, @des1, @sequence, @clink
		while @@sqlstatus = 0
		begin
			delete crslink_rc where @crsid=@crsid and code=@crscode
			delete crslink_rcdef where @crsid=@crsid and code=@crscode

			exec p_crslink_rcset @crsid, @crscode, @des, @des1, @code, @clink, @sequence, '' 

			fetch c_crsid into @crsid, @crscode, @des, @des1, @sequence, @clink
		end
		close c_crsid
		deallocate cursor c_crsid
	end 
	*/
	
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	
	if update(code)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_code','rmrc', d.code ,i.code ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(cat)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_cat','rmrc', d.cat ,i.cat ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(descript)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_descript','rmrc', d.descript ,i.descript ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(descript1)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_descript1','rmrc', d.descript1 ,i.descript1 ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(private)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_private','rmrc', d.private ,i.private ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(mode)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_mode','rmrc', d.mode ,i.mode ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(inher_fo)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_inher_fo','rmrc', d.inher_fo ,i.inher_fo ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(folio)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_folio','rmrc', d.folio ,i.folio ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(src)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_src','rmrc', d.src ,i.src ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(market)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_market','rmrc', d.market ,i.market ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(packages)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_packages','rmrc', d.packages ,i.packages ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(amenities)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_amenities','rmrc', d.amenities ,i.amenities ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(begin_)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_begin_','rmrc', convert(varchar(255),d.begin_,111) ,convert(varchar(255),i.begin_,111),isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(end_)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_end_','rmrc', convert(varchar(255),d.end_,111) ,convert(varchar(255),i.end_,111) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(calendar)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_calendar','rmrc', d.calendar ,i.calendar ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(yieldable)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_yieldable','rmrc', d.yieldable ,i.yieldable ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(yieldcat)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_yieldcat','rmrc', d.yieldcat ,i.yieldcat ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(bucket)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_bucket','rmrc', d.bucket ,i.bucket ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(arrmin)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_arrmin','rmrc', convert(varchar(255),d.arrmin)  ,convert(varchar(255),i.arrmin) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(arrmax)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_arrmax','rmrc', convert(varchar(255),d.arrmax) ,convert(varchar(255),i.arrmax) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(thoughmin)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_thoughmin','rmrc', convert(varchar(255),d.thoughmin) ,convert(varchar(255),i.thoughmin) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(thoughmax)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_thoughmax','rmrc', convert(varchar(255),d.thoughmax) ,convert(varchar(255),i.thoughmax) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(staymin)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_staymin','rmrc', convert(varchar(255),d.staymin) ,convert(varchar(255),i.staymin) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(staymax)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_staymax','rmrc', convert(varchar(255),d.staymax) ,convert(varchar(255),i.staymax) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(multi)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_multi','rmrc', convert(varchar(255),d.multi) ,convert(varchar(255),i.multi) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(addition)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_addition','rmrc', convert(varchar(255),d.addition) ,convert(varchar(255),i.addition) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(pccode)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_pccode','rmrc', d.pccode ,i.pccode ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(halt)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_halt','rmrc', d.halt ,i.halt ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(sequence)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrc_sequence','rmrc', convert(varchar(255),d.sequence) ,convert(varchar(255),i.sequence) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end	
	
end
;

--------------------------------------
--	rmratedef 
--------------------------------------

if exists (select * from sysobjects where name = 't_gds_rmratedef_update' and type = 'TR')
   drop trigger t_gds_rmratedef_update;
create trigger t_gds_rmratedef_update
   on rmratedef
   for update as
begin
	declare	@code		char(10)
	select @code = code from inserted  
	if @@rowcount = 1
	begin
		declare	
			@crsid			char(30),
			@crscode			char(10)
		declare c_crsid cursor for select crsid, code from crslink_rcdef where id=@code
		open c_crsid 
		fetch c_crsid into @crsid, @crscode
		while @@sqlstatus = 0
		begin
			delete crslink_rcdef where @crsid=@crsid and code=@crscode and id=@code 

			insert crslink_rcdef(crsid,code,id,descript,descript1,begin_,end_,packages,amenities,market,src,
					year,month,day,week,stay,hall,gtype,type,flr,roomno,rmnums,ratemode,
					stay_cost,fix_cost,prs_cost,rate1,rate2,rate3,rate4,rate5,rate6,extra,child,crib)
				SELECT @crsid,@crscode,c.code,c.descript,c.descript1,c.begin_,c.end_,c.packages,c.amenities,c.market,c.src,c.
						year,c.month,c.day,c.week,c.stay,c.hall,c.gtype,c.type,c.flr,c.roomno,c.rmnums,c.ratemode,c.
						stay_cost,c.fix_cost,c.prs_cost,c.rate1,c.rate2,c.rate3,c.rate4,c.rate5,c.rate6,c.extra,c.child,c.crib  
					FROM inserted c  

			fetch c_crsid into @crsid, @crscode
		end
		close c_crsid
		deallocate cursor c_crsid
	end 
	
	
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	
	if update(code)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_code','rmrd',d.code , i.code ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(descript)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_descript','rmrd',d.descript , i.descript ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(descript1)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_descript1','rmrd',d.descript1 , i.descript1 ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(begin_)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_begin_','rmrd',convert(varchar(255),d.begin_,111) , convert(varchar(255),i.begin_,111) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(end_)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_end_','rmrd',convert(varchar(255),d.end_,111), convert(varchar(255),i.end_,111) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(packages)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_packages','rmrd',d.packages , i.packages ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(amenities)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_amenities','rmrd',d.amenities , i.amenities ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(market)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_market','rmrd',d.market , i.market ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(src)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_src','rmrd',d.src , i.src ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(year)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_year','rmrd',d.year , i.year ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(month)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_month','rmrd',d.month , i.month ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(day)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_day','rmrd',d.day , i.day ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(week)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_week','rmrd',d.week , i.week ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(stay)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_stay','rmrd',convert(varchar(255),d.stay) , convert(varchar(255),i.stay) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(stay_e)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_stay_e','rmrd',convert(varchar(255),d.stay_e) , convert(varchar(255),i.stay_e) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(hall)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_hall','rmrd',d.hall , i.hall ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(gtype)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_gtype','rmrd',d.gtype , i.gtype ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(type)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_type','rmrd',d.type , i.type ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(flr)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_flr','rmrd',d.flr , i.flr ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(roomno)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_roomno','rmrd',d.roomno , i.roomno ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(rmnums)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_rmnums','rmrd',convert(varchar(255),d.rmnums) , convert(varchar(255),i.rmnums) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(ratemode)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_ratemode','rmrd',d.ratemode , i.ratemode ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(stay_cost)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_stay_cost','rmrd',convert(varchar(255),d.stay_cost) , convert(varchar(255),i.stay_cost) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(fix_cost)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_fix_cost','rmrd',convert(varchar(255),d.fix_cost) , convert(varchar(255),i.fix_cost),isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(prs_cost)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_prs_cost','rmrd',convert(varchar(255),d.prs_cost) , convert(varchar(255),i.prs_cost) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(rate1)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_rate1','rmrd',convert(varchar(255),d.rate1) , convert(varchar(255),i.rate1),isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(rate2)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_rate2','rmrd',convert(varchar(255),d.rate2) , convert(varchar(255),i.rate2) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(rate3)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_rate3','rmrd',convert(varchar(255),d.rate3) , convert(varchar(255),i.rate3),isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(rate4)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_rate4','rmrd',convert(varchar(255),d.rate4) , convert(varchar(255),i.rate4) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(rate5)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_rate5','rmrd',convert(varchar(255),d.rate5) , convert(varchar(255),i.rate5) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(rate6)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_rate6','rmrd',convert(varchar(255),d.rate6) , convert(varchar(255),i.rate6) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(extra)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_extra','rmrd',convert(varchar(255),d.extra) , convert(varchar(255),i.extra),isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(child)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_child','rmrd',convert(varchar(255),d.child) , convert(varchar(255),i.child) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	if update(crib)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'rmrd_crib','rmrd',convert(varchar(255),d.crib) , convert(varchar(255),i.crib) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code 
	end
	
end
;

