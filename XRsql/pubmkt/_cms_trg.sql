--------------------------------------------------------------------------------------------------------
-- cmscode
--------------------------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_cmscode_insert' and type = 'TR')
   drop trigger t_cmscode_insert;
create trigger t_cmscode_insert
   on cmscode
   for insert as
begin
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' ´úÂë:'+rtrim(code)+' ÃèÊö1:'+rtrim(descript)+' ÃèÊö2:'+rtrim(descript1) from deleted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'cmsc_','cmscode', @info, 'Ôö¼Ó',isnull(@empno,''),getdate(),code 
		from inserted 
end
;

if exists (select * from sysobjects where name = 't_cmscode_update' and type = 'TR')
   drop trigger t_cmscode_update;
create trigger t_cmscode_update
   on cmscode
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
			select 'cmsc_code','cmscode', d.code,i.code ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(descript)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsc_descript','cmscode', d.descript,i.descript ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(descript1)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsc_descript1','cmscode', d.descript1,i.descript1 ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(halt)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsc_halt','cmscode', d.halt,i.halt ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(upmode)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsc_upmode','cmscode', d.upmode,i.upmode ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(rmtype_s)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsc_rmtype_s','cmscode', d.rmtype_s,i.rmtype_s ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(sequence)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsc_sequence','cmscode', convert(varchar(255),d.sequence),convert(varchar(255),i.sequence) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(begin_)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsc_begin_','cmscode', convert(varchar(255),d.begin_,111),convert(varchar(255),i.begin_,111) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(end_)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsc_end_','cmscode', convert(varchar(255),d.end_,111),convert(varchar(255),i.end_,111) ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
	if update(flag)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsc_flag','cmscode', d.flag,i.flag ,isnull(@empno,''),getdate(),i.code
			from inserted i,deleted d
			where i.code=d.code
	end
end
;

if exists (select * from sysobjects where name = 't_cmscode_delete' and type = 'TR')
   drop trigger t_cmscode_delete;
create trigger t_cmscode_delete
   on cmscode
   for delete as
begin
		declare	@retmode		char(1),
					@empno		varchar(10),
					@shift		char(1),
					@pc_id		char(4),
					@appid		varchar(5),
					@info 		 varchar(255)
		select  @info = ' ´úÂë:'+rtrim(code)+' ÃèÊö1:'+rtrim(descript)+' ÃèÊö2:'+rtrim(descript1) from deleted
		execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'cmsc_','cmscode', @info, 'É¾³ý',isnull(@empno,''),getdate(),d.code 
			from deleted d 
end
;

--------------------------------------------------------------------------------------------------------
-- cmscode_link
--------------------------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_cmscode_link_insert' and type = 'TR')
   drop trigger t_cmscode_link_insert;
create trigger t_cmscode_link_insert
   on cmscode_link
   for insert as
begin
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' Code:'+rtrim(code)+' PRI:'+rtrim(convert(varchar(16),pri)) from deleted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'cmscl_','cmscl', @info, 'Ôö¼Ó',isnull(@empno,''),getdate(),rtrim(code)+'!'+convert(varchar(16),pri)  
		from inserted 
end
;

if exists (select * from sysobjects where name = 't_cmscode_link_update' and type = 'TR')
   drop trigger t_cmscode_link_update;
create trigger t_cmscode_link_update
   on cmscode_link
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
			select 'cmscl_code','cmscl', d.code ,i.code ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+convert(varchar(16),i.pri) 
			from inserted i,deleted d
			where i.code=d.code and i.pri=d.pri
	end
	if update(pri)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmscl_pri','cmscl', convert(varchar(255),d.pri) ,convert(varchar(255),i.pri) ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+convert(varchar(16),i.pri) 
			from inserted i,deleted d
			where i.code=d.code and i.pri=d.pri
	end
	if update(cmscode)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmscl_cmscode','cmscl', d.cmscode ,i.cmscode ,isnull(@empno,''),getdate(),rtrim(i.code)+'!'+convert(varchar(16),i.pri) 
			from inserted i,deleted d
			where i.code=d.code and i.pri=d.pri
	end
end
;

if exists (select * from sysobjects where name = 't_cmscode_link_delete' and type = 'TR')
   drop trigger t_cmscode_link_delete;
create trigger t_cmscode_link_delete
   on cmscode_link
   for delete as
begin
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' Code:'+rtrim(code)+' PRI:'+rtrim(convert(varchar(16),pri)) from deleted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'cmscl_','cmscl', @info, 'É¾³ý',isnull(@empno,''),getdate(),rtrim(code)+'!'+convert(varchar(16),pri)   
		from deleted  
end
;
--------------------------------------------------------------------------------------------------------
-- cms_defitem
--------------------------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_cms_defitem_insert' and type = 'TR')
   drop trigger t_cms_defitem_insert;
create trigger t_cms_defitem_insert
   on cms_defitem
   for insert as
begin
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' ±àºÅ:'+rtrim(no) from deleted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'cmsd_','cmsd', @info, 'Ôö¼Ó',isnull(@empno,''),getdate(),no 
		from inserted 
end
;

if exists (select * from sysobjects where name = 't_cms_defitem_update' and type = 'TR')
   drop trigger t_cms_defitem_update;
create trigger t_cms_defitem_update
   on cms_defitem
   for update as
begin
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output


	if update(no)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_no','cmsd', d.no ,i.no ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(unit)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_unit','cmsd', d.unit ,i.unit ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(type)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_type','cmsd', d.type ,i.type ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(rmtype)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_rmtype','cmsd', d.rmtype ,i.rmtype ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(amount)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_amount','cmsd', convert(varchar(255),d.amount) ,convert(varchar(255),i.amount) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(dayuse)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_dayuse','cmsd', d.dayuse ,i.dayuse ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(uproom1)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_uproom1','cmsd', convert(varchar(255),d.uproom1) ,convert(varchar(255),i.uproom1) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(upamount1)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_upamount1','cmsd', convert(varchar(255),d.upamount1) ,convert(varchar(255),i.upamount1) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(uproom2)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_uproom2','cmsd', convert(varchar(255),d.uproom2) ,convert(varchar(255),i.uproom2) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(upamount2)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_upamount2','cmsd', convert(varchar(255),d.upamount2) ,convert(varchar(255),i.upamount2) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(uproom3)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_uproom3','cmsd', convert(varchar(255),d.uproom3) ,convert(varchar(255),i.uproom3) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(upamount3)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_upamount3','cmsd', convert(varchar(255),d.upamount3) ,convert(varchar(255),i.upamount3) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(uproom4)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_uproom4','cmsd', convert(varchar(255),d.uproom4 ),convert(varchar(255),i.uproom4) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(upamount4)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_upamount4','cmsd', convert(varchar(255),d.upamount4) ,convert(varchar(255),i.upamount4) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(uproom5)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_uproom5','cmsd', convert(varchar(255),d.uproom5) ,convert(varchar(255),i.uproom5) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(upamount5)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_upamount5','cmsd', convert(varchar(255),d.upamount5) ,convert(varchar(255),i.upamount5) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(uproom6)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_uproom6','cmsd', convert(varchar(255),d.uproom6) ,convert(varchar(255),i.uproom6) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(upamount6)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_upamount6','cmsd', convert(varchar(255),d.upamount6) ,convert(varchar(255),i.upamount6) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(uproom7)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_uproom7','cmsd', convert(varchar(255),d.uproom7) ,convert(varchar(255),i.uproom7) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(upamount7)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_upamount7','cmsd', convert(varchar(255),d.upamount7) ,convert(varchar(255),d.upamount7) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(rmtype_s)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_rmtype_s','cmsd', d.rmtype_s ,i.rmtype_s ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(name)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_name','cmsd', d.name ,i.name ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(datecond)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_datecond','cmsd', d.datecond ,i.datecond ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(extra)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_extra','cmsd', d.extra ,i.extra ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(d_line)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_d_line','cmsd', convert(varchar(255),d.d_line) ,convert(varchar(255),i.d_line) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(begin_)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_begin_','cmsd', convert(varchar(255),d.begin_,111) ,convert(varchar(255),i.begin_,111) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
	if update(end_)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext)
			select 'cmsd_end_','cmsd', convert(varchar(255),d.end_,111) ,convert(varchar(255),i.end_,111) ,isnull(@empno,''),getdate(),i.no
			from inserted i,deleted d
			where i.no=d.no
	end
end
;

if exists (select * from sysobjects where name = 't_cms_defitem_delete' and type = 'TR')
   drop trigger t_cms_defitem_delete;
create trigger t_cms_defitem_delete
   on cms_defitem
   for delete as
begin
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' ±àºÅ:'+rtrim(no) from deleted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'cmsd_','cmsd', @info, 'É¾³ý',isnull(@empno,''),getdate(),d.no 
		from deleted d 
end
;
































