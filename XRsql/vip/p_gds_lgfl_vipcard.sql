

if not exists(select 1 from lgfl_des where columnname = 'v_src')
	insert lgfl_des values('v_src','来源','Source','O');
if not exists(select 1 from lgfl_des where columnname = 'v_flag')
	insert lgfl_des values('v_flag','标记','Flag','O');
if not exists(select 1 from lgfl_des where columnname = 'v_saleid')
	insert lgfl_des values('v_saleid','销售员','Sales Agent','O');


IF OBJECT_ID('p_gds_lgfl_vipcard') IS NOT NULL
	drop proc p_gds_lgfl_vipcard;
create proc p_gds_lgfl_vipcard
	@accnt			char(20)
as
declare
	@laccnt				char(20),
	@lguestid			char(7),
	@row					integer,
	@cby					char(10),
	@changed				datetime,
	@logmark				integer

declare
	@old_sno				varchar(20),			@new_sno				varchar(20),
	@old_sta				char(1),					@new_sta				char(1),
	@old_type			char(1),					@new_type			char(1),
	@old_class			char(3),					@new_class			char(3),
	@old_code1			char(10),				@new_code1			char(10),
	@old_code2			char(3),					@new_code2			char(3),
	@old_araccnt1		char(7),					@new_araccnt1		char(7),
	@old_araccnt2		char(7),					@new_araccnt2		char(7),
	@old_name			varchar(50),			@new_name			varchar(50),
	@old_cno				char(7),					@new_cno				char(7),
	@old_hno				char(7),					@new_hno				char(7),
	@old_arr				datetime,				@new_arr				datetime,
	@old_dep				datetime,				@new_dep				datetime,
	@old_password		varchar(10),			@new_password		varchar(10),
	@old_extrainf		varchar(30),			@new_extrainf		varchar(30),
	@old_postctrl		char(1),					@new_postctrl		char(1),
	@old_limit			money,					@new_limit			money,
	@old_ref				varchar(255),			@new_ref				varchar(255),
	@old_src				char(3),					@new_src				char(3),
	@old_flag			varchar(40),			@new_flag			varchar(40),
	@old_saleid			varchar(50),			@new_saleid			varchar(50)


declare		@pos			int


if @accnt is null
	declare c_vipcard cursor for select distinct no from vipcard_log
else
	declare c_vipcard cursor for select distinct no from vipcard_log where no = @accnt

-- name 字段已经没有了
declare c_log_vipcard cursor for
  	SELECT sno,sta,type,class,code1,code2,araccnt1,araccnt2,'name',cno,hno,arr,dep,password,extrainf,postctrl,
			limit,cby,changed,ref,logmark,src,flag,saleid
		from vipcard_log where no = @laccnt
	union SELECT sno,sta,type,class,code1,code2,araccnt1,araccnt2,'name',cno,hno,arr,dep,password,extrainf,postctrl,
				limit,cby,changed,ref,logmark,src,flag,saleid
		from vipcard where no = @laccnt
	order by logmark

open c_vipcard
fetch c_vipcard into @laccnt
while @@sqlstatus =0
   begin
	select @row = 0
	open c_log_vipcard
	fetch c_log_vipcard into @new_sno,@new_sta,@new_type,@new_class,@new_code1,@new_code2,
		@new_araccnt1,@new_araccnt2,@new_name,@new_cno,@new_hno,@new_arr,@new_dep,
		@new_password,@new_extrainf,@new_postctrl,@new_limit,@cby,@changed,@new_ref,@logmark,
		@new_src,@new_flag,@new_saleid

	while @@sqlstatus =0
		begin
		select @row = @row + 1
		if @row > 1
			begin
			if @new_sta != @old_sta
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_sta', 'v:'+@laccnt, @old_sta, @new_sta, @cby, @changed)
			if @new_sno != @old_sno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_sno', 'v:'+@laccnt, @old_sno, @new_sno, @cby, @changed)
			if @new_class != @old_class
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_class', 'v:'+@laccnt, @old_class, @new_class, @cby, @changed)
			if @new_type != @old_type
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_type',  'v:'+@laccnt, @old_type, @new_type, @cby, @changed)
			if @new_code1 != @old_code1
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_code1',  'v:'+@laccnt, @old_code1, @new_code1, @cby, @changed)
			if @new_code2 != @old_code2
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_code2', 'v:'+@laccnt, @old_code2, @new_code2, @cby, @changed)
			if @new_araccnt1 != @old_araccnt1
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_araccnt1', 'v:'+@laccnt, @old_araccnt1, @new_araccnt1, @cby, @changed)
			if @new_araccnt2 != @old_araccnt2
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_araccnt2', 'v:'+@laccnt, @old_araccnt2, @new_araccnt2, @cby, @changed)
			if @new_name != @old_name
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_name',  'v:'+@laccnt, @old_name, @new_name, @cby, @changed)
			if @new_cno != @old_cno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_cno',  'v:'+@laccnt, @old_cno, @new_cno, @cby, @changed)
			if @new_hno != @old_hno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_hno',  'v:'+@laccnt, @old_hno, @new_hno, @cby, @changed)
			if @new_arr != @old_arr
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_arr', 'v:'+@laccnt, convert(char(10), @old_arr, 111) + ' ' + convert(char(10), @old_arr, 108),
				convert(char(10), @new_arr, 111) + ' ' + convert(char(10), @new_arr, 108), @cby, @changed)
			if @new_dep != @old_dep
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_dep',  'v:'+@laccnt, convert(char(10), @old_dep, 111) + ' ' + convert(char(10), @old_dep, 108),
				convert(char(10), @new_dep, 111) + ' ' + convert(char(10), @new_dep, 108), @cby, @changed)
			if @new_password != @old_password
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_password', 'v:'+@laccnt, @old_password, @new_password, @cby, @changed)
			if @new_extrainf != @old_extrainf
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_extrainf',  'v:'+@laccnt, @old_extrainf, @new_extrainf, @cby, @changed)
			if @new_postctrl != @old_postctrl
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_postctrl',  'v:'+@laccnt, @old_postctrl, @new_postctrl, @cby, @changed)
			if @new_limit != @old_limit
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_limit',  'v:'+@laccnt, ltrim(convert(char(10), @old_limit)), ltrim(convert(char(10), @new_limit)), @cby, @changed)
			if @new_ref != @old_ref
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_ref',  'v:'+@laccnt, @old_ref, @new_ref, @cby, @changed)
			if @new_src != @old_src
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_src',  'v:'+@laccnt, @old_src, @new_src, @cby, @changed)
			if @new_flag != @old_flag
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_flag',  'v:'+@laccnt, @old_flag, @new_flag, @cby, @changed)
			if @new_saleid != @old_saleid
				insert lgfl(columnname,accnt,old,new,empno,date) values ('v_saleid',  'v:'+@laccnt, @old_saleid, @new_saleid, @cby, @changed)
			end
		select 	@old_sno = @new_sno,
					@old_sta = @new_sta,
					@old_type = @new_type,
					@old_class = @new_class,
					@old_code1 = @new_code1,
					@old_code2 = @new_code2,
					@old_araccnt1 = @new_araccnt1,
					@old_araccnt2 = @new_araccnt2,
					@old_name = @new_name,
					@old_cno = @new_cno,
					@old_hno = @new_hno,
					@old_arr = @new_arr,
					@old_dep = @new_dep,
					@old_password = @new_password,
					@old_extrainf = @new_extrainf,
					@old_postctrl = @new_postctrl,
					@old_limit = @new_limit,
					@old_ref = @new_ref,
					@old_src = @new_src,
					@old_flag = @new_flag,
					@old_saleid = @new_saleid

		fetch c_log_vipcard into @new_sno,@new_sta,@new_type,@new_class,@new_code1,@new_code2,
			@new_araccnt1,@new_araccnt2,@new_name,@new_cno,@new_hno,@new_arr,@new_dep,
			@new_password,@new_extrainf,@new_postctrl,@new_limit,@cby,@changed,@new_ref,@logmark,
			@new_src,@new_flag,@new_saleid
		end
	close c_log_vipcard
	if @row > 0
		delete vipcard_log where no = @laccnt and logmark <= @logmark
	fetch c_vipcard into @laccnt
	end

deallocate cursor c_log_vipcard
close c_vipcard
deallocate cursor c_vipcard

return
;
