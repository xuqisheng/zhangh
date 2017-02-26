
// 广州华厦

//
if not exists(select 1 from sys_extraid where cat='RPN') 
	insert sys_extraid(cat, descript, id) values('RPN', 'RSV PLAN', 0);

// 配额表 
if exists(select * from sysobjects where name = "gzhs_rsv_plan" and type="U")
	drop table gzhs_rsv_plan;
create table gzhs_rsv_plan
(
	id				char(10)						not null,
	no  			char(10)						not null,
	date			datetime						not null,
	class			char(1)	default 'F'		not null,	-- F-fit, G-grp  
	quan			int		default 0		not null,	-- 配额 
	lmt			int		default 0		not null,	-- 截至天数 
	leaf			int		default 0		null,			-- 剩余 
	flag			char(1)	default 'F'		not null,	-- 强制扣除 
	rmtypes		varchar(255) default ''	not null,
	ratecodes	varchar(255) default ''	not null,
	cmt			varchar(255)				null,			-- 说明 
	remark		varchar(255)				null,			-- 备注
	crtby			char(10)						not null,
	crttime		datetime						not null,
	cby			char(10)						not null,
	changed		datetime						not null,
	logmark		int		default 0		null
)
exec sp_primarykey gzhs_rsv_plan, id
create unique index  gzhs_rsv_plan on gzhs_rsv_plan(id)
create unique index  gzhs_rsv_plan1 on gzhs_rsv_plan(no, date, class )
;

if exists(select * from sysobjects where name = "gzhs_rsv_plan_log" and type="U")
	drop table gzhs_rsv_plan_log;
create table gzhs_rsv_plan_log
(
	id				char(10)						not null,
	no  			char(10)						not null,
	date			datetime						not null,
	class			char(1)	default 'F'		not null,	-- F-fit, G-grp  
	quan			int		default 0		not null,	-- 配额 
	lmt			int		default 0		not null,	-- 截至天数 
	leaf			int		default 0		null,			-- 剩余 
	flag			char(1)	default 'F'		not null,	-- 强制扣除 
	rmtypes		varchar(255) default ''	not null,
	ratecodes	varchar(255) default ''	not null,
	cmt			varchar(255)				null,			-- 说明 
	remark		varchar(255)				null,			-- 备注
	crtby			char(10)						not null,
	crttime		datetime						not null,
	cby			char(10)						not null,
	changed		datetime						not null,
	logmark		int		default 0		null
)
exec sp_primarykey gzhs_rsv_plan_log, id, logmark 
create unique index  gzhs_rsv_plan_log on gzhs_rsv_plan_log(id, logmark)
;

if exists(select * from sysobjects where name = "gzhs_rsv_plan_del" and type="U")
	drop table gzhs_rsv_plan_del;
create table gzhs_rsv_plan_del
(
	id				char(10)						not null,
	no  			char(10)						not null,
	date			datetime						not null,
	class			char(1)	default 'F'		not null,	-- F-fit, G-grp  
	quan			int		default 0		not null,	-- 配额 
	lmt			int		default 0		not null,	-- 截至天数 
	leaf			int		default 0		null,			-- 剩余 
	flag			char(1)	default 'F'		not null,	-- 强制扣除 
	rmtypes		varchar(255) default ''	not null,
	ratecodes	varchar(255) default ''	not null,
	cmt			varchar(255)				null,			-- 说明 
	remark		varchar(255)				null,			-- 备注
	crtby			char(10)						not null,
	crttime		datetime						not null,
	cby			char(10)						not null,
	changed		datetime						not null,
	logmark		int		default 0		null
)
exec sp_primarykey gzhs_rsv_plan_del, id
create unique index  gzhs_rsv_plan_del on gzhs_rsv_plan_del(id)
;

// ------------------------------------------------------------------------------------
//		gzhs_rsv_plan 更新触发器
// ------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_gds_gzhs_rsv_plan_update' and type = 'TR')
	drop trigger t_gds_gzhs_rsv_plan_update
;
create trigger t_gds_gzhs_rsv_plan_update
   on gzhs_rsv_plan for update
	as
begin
if update(logmark)   -- 注意，这里插入的是 deleted
	insert gzhs_rsv_plan_log select deleted.* from deleted
end
;

// ------------------------------------------------------------------------------------
//		gzhs_rsv_plan insert 触发器
// ------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_gds_gzhs_rsv_plan_insert' and type = 'TR')
	drop trigger t_gds_gzhs_rsv_plan_insert;
create trigger t_gds_gzhs_rsv_plan_insert
   on gzhs_rsv_plan for insert
	as
begin
insert lgfl(columnname,accnt,old,new,empno,date,ext) 
	select 'g_profile', no, '', no, cby, changed,'' from inserted
end
;

// 
delete lgfl_des where columnname like 'RPN_%'; 
insert lgfl_des(columnname,descript,descript1,tag) values('RPN_no','档案号','档案号','O'); 
insert lgfl_des(columnname,descript,descript1,tag) values('RPN_date','日期','日期','O'); 
insert lgfl_des(columnname,descript,descript1,tag) values('RPN_class','类别','类别','O'); 
insert lgfl_des(columnname,descript,descript1,tag) values('RPN_flag','强行扣除','强行扣除','O'); 
insert lgfl_des(columnname,descript,descript1,tag) values('RPN_rmtypes','房类','房类','O'); 
insert lgfl_des(columnname,descript,descript1,tag) values('RPN_ratecodes','房价码','房价码','O'); 
insert lgfl_des(columnname,descript,descript1,tag) values('RPN_cmt','说明','说明','O'); 
insert lgfl_des(columnname,descript,descript1,tag) values('RPN_remark','备注','备注','O'); 
insert lgfl_des(columnname,descript,descript1,tag) values('RPN_quan','配额','配额','O'); 
insert lgfl_des(columnname,descript,descript1,tag) values('RPN_lmt','截止天数','截止天数','O'); 

// 
if exists (select * from sysobjects where name = 'p_gds_lgfl_gzhs_rsv_plan' and type = 'P')
	drop proc p_gds_lgfl_gzhs_rsv_plan;
create proc p_gds_lgfl_gzhs_rsv_plan
	@id					char(10)
as
-- GUEST日志 
declare
	@cid					char(10),
	@row					integer,
	@cby					char(10),
	@changed				datetime,
	@logmark				integer,
	@old_no				varchar(10),			@new_no				varchar(10),
	@old_date			datetime,				@new_date			datetime,
	@old_class			char(1),					@new_class			char(1),
	@old_flag			char(1),					@new_flag			char(1),
	@old_rmtypes		varchar(255),			@new_rmtypes		varchar(255),
	@old_ratecodes		varchar(255),			@new_ratecodes		varchar(255),
	@old_cmt				varchar(255),			@new_cmt				varchar(255),
	@old_remark			varchar(255),			@new_remark			varchar(255),
	@old_quan			int,						@new_quan			int,
	@old_lmt				int,						@new_lmt				int 

--
if @id is null
	declare c_plan cursor for select distinct id from gzhs_rsv_plan_log
else
	declare c_plan cursor for select distinct id from gzhs_rsv_plan_log where id = @id
--
declare c_log_plan cursor for 
	select cby,changed,logmark,no,date,class,flag,rmtypes,ratecodes,cmt,remark,quan,lmt 
		from gzhs_rsv_plan_log where id = @cid
	union select cby,changed,logmark,no,date,class,flag,rmtypes,ratecodes,cmt,remark,quan,lmt 
		from gzhs_rsv_plan where id = @cid
	order by logmark
open c_plan
fetch c_plan into @cid
while @@sqlstatus = 0
   begin
	select @row = 0
	open c_log_plan
	fetch c_log_plan into @cby,@changed,@logmark,@new_no,@new_date,@new_class,@new_flag,
			@new_rmtypes,@new_ratecodes,@new_cmt,@new_remark,@new_quan,@new_lmt
	while @@sqlstatus =0
		begin
		select @row = @row + 1
		if @row > 1
			begin
			if @new_no != @old_no
				insert lgfl values ('RPN_sno', @cid, @old_no, @new_no, @cby, @changed)
			if @new_date != @old_date
				insert lgfl values ('RPN_date', @cid, convert(char(10), @old_date, 111) + ' ' + convert(char(10), @old_date, 108), 
				convert(char(10), @new_date, 111) + ' ' + convert(char(10), @new_date, 108), @cby, @changed)
			if @new_class != @old_class
				insert lgfl values ('RPN_class', @cid, @old_class, @new_class, @cby, @changed)
			if @new_flag != @old_flag
				insert lgfl values ('RPN_flag', @cid, @old_flag, @new_flag, @cby, @changed)
			if @new_rmtypes != @old_rmtypes
				insert lgfl values ('RPN_rmtypes', @cid, @old_rmtypes, @new_rmtypes, @cby, @changed)
			if @new_ratecodes != @old_ratecodes
				insert lgfl values ('RPN_ratecodes', @cid, @old_ratecodes, @new_ratecodes, @cby, @changed)
			if @new_cmt != @old_cmt
				insert lgfl values ('RPN_cmt', @cid, @old_cmt, @new_cmt, @cby, @changed)
			if @new_remark != @old_remark
				insert lgfl values ('RPN_remark', @cid, @old_remark, @new_remark, @cby, @changed)
			if @new_quan != @old_quan
				insert lgfl values ('RPN_quan', @cid, convert(char(10),@old_quan), convert(char(10),@new_quan), @cby, @changed)
			if @new_lmt != @old_lmt
				insert lgfl values ('RPN_lmt', @cid, convert(char(10),@old_lmt), convert(char(10),@new_lmt), @cby, @changed)
			end
		select @old_no=@new_no,@old_date=@new_date,@old_class=@new_class,@old_flag=@new_flag,
			@old_rmtypes=@new_rmtypes,@old_ratecodes=@new_ratecodes,@old_cmt=@new_cmt,
			@old_remark=@new_remark,@old_quan=@new_quan,@old_lmt=@new_lmt
		fetch c_log_plan into @cby,@changed,@logmark,@new_no,@new_date,@new_class,@new_flag,
			@new_rmtypes,@new_ratecodes,@new_cmt,@new_remark,@new_quan,@new_lmt
		end
	close c_log_plan
	if @row > 0
		delete gzhs_rsv_plan_log where id = @cid and logmark < @logmark
	fetch c_plan into @cid
	end
deallocate cursor c_log_plan
close c_plan
deallocate cursor c_plan
;
