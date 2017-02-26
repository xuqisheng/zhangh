

if exists (select * from sysobjects where name = 'p_zk_lgfl_saleid' and type = 'P')
	drop proc p_zk_lgfl_saleid;
create proc p_zk_lgfl_saleid
	@code					char(10)
as
-- saleidÈÕÖ¾ 
declare
	--@code					char(10),
	@row					integer,
	@cby					char(10),
	@changed				datetime,
	@logmark				integer,
	@old_sta				char(1),					@new_sta				char(1),
	@old_name			varchar(50),			@new_name			varchar(50),
	@old_dept         char(10),            @new_dept         char(10),     
   @old_job         char(10),             @new_job          char(10),
   @old_extension    varchar(10),            @new_extension         varchar(10),
   @old_grp         char(10),             @new_grp          char(10),
   @old_territory    varchar(30),           @new_territory    varchar(30),
   @old_fulltime				char(1),			@new_fulltime				char(1),
   @old_arr0         datetime,            @new_arr0         datetime,
   @old_arr         datetime,             @new_arr         datetime,
   @old_dep         datetime,             @new_dep         datetime,
   @old_empno        char(10),            @new_empno        char(10),
   @old_lname			varchar(30),			@new_lname			varchar(30),
	@old_fname			varchar(30),			@new_fname			varchar(30),--
	@old_name2			varchar(50),			@new_name2			varchar(50),--
	@old_name3			varchar(50),			@new_name3			varchar(50),--
   @old_sex				char(1),					@new_sex				char(1),
   @old_idcls        char(3),             @new_idcls        char(3),
   @old_ident        char(20),             @new_ident        char(20),
   @old_lang			char(1),					@new_lang			char(1),
   @old_birth			datetime,				@new_birth			datetime,
   @old_nation			char(3),					@new_nation			char(3),
   @old_country		char(3),					@new_country		char(3),
   @old_state        char(3),             @new_state        char(3),
   @old_town         varchar(40),         @new_town         varchar(40),
   @old_street       varchar(60),         @new_street         varchar(60),
   @old_zip            varchar(6),        @new_zip            varchar(6),
   @old_mobile			varchar(20),			@new_mobile			varchar(20),
   @old_phone			varchar(20),			@new_phone			varchar(20),--
	@old_fax				varchar(20),			@new_fax				varchar(20),--
	@old_wetsite		varchar(20),			@new_wetsite		varchar(20),--
	@old_email			varchar(20),			@new_email			varchar(20),
   @old_sequence     integer,             @new_sequence     integer,
   @old_exp_m1        money,              @new_exp_m1        money,
   @old_exp_m2        money,              @new_exp_m2        money,
   @old_exp_dt1        datetime,              @new_exp_dt1        datetime,
   @old_exp_dt2        datetime,              @new_exp_dt2        datetime,
   @old_exp_s1          varchar(10),          @new_exp_s1          varchar(10),
   @old_exp_s2          varchar(10),          @new_exp_s2          varchar(10),
   @old_exp_s3          varchar(10),          @new_exp_s3          varchar(10)






if @code is null
	declare c_saleid cursor for select distinct code from saleid_log
else
	declare c_saleid cursor for select distinct code from saleid_log where code = @code

declare c_log_saleid cursor for 
	 SELECT  sta,name,dept,job, extension,grp,territory,fulltime,arr0,arr,dep,empno,fname,lname,name2,name3,sex,idcls,ident,   
         lang, birth,nation,country,state,town,street,zip,mobile,phone,fax,wetsite,email,sequence,exp_m1,exp_m2,exp_dt1,   
         exp_dt2,exp_s1,exp_s2,exp_s3,logmark,cby,changed
    FROM saleid_log    where code = @code
	union SELECT  sta,name,dept,job, extension,grp,territory,fulltime,arr0,arr,dep,empno,fname,lname,name2,name3,sex,idcls,ident,   
         lang, birth,nation,country,state,town,street,zip,mobile,phone,fax,wetsite,email,sequence,exp_m1,exp_m2,exp_dt1,   
         exp_dt2,exp_s1,exp_s2,exp_s3,logmark,cby,changed
    FROM saleid    where code = @code
	order by logmark
open c_saleid
fetch c_saleid into @code
while @@sqlstatus = 0
   begin
	select @row = 0
	open c_log_saleid
	fetch c_log_saleid into @new_sta,@new_name,  @new_dept, @new_job,@new_extension,@new_grp,@new_territory, @new_fulltime,   
         @new_arr0,@new_arr, @new_dep,@new_empno,@new_fname,@new_lname,@new_name2,@new_name3,@new_sex,@new_idcls,@new_ident,   
         @new_lang,@new_birth, @new_nation,@new_country,@new_state,@new_town, @new_street, @new_zip, @new_mobile,@new_phone,   
         @new_fax, @new_wetsite,@new_email,@new_sequence,@new_exp_m1,@new_exp_m2,@new_exp_dt1,@new_exp_dt2,@new_exp_s1,   
         @new_exp_s2,@new_exp_s3,@logmark, @cby,@changed
	while @@sqlstatus =0
		begin
		select @row = @row + 1
      if @row > 1
			begin
			if @new_name != @old_name
				insert lgfl values ('s_name', @code, @old_name, @new_name, @cby, @changed)
			if @new_lname != @old_lname
				insert lgfl values ('s_lname', @code, @old_lname, @new_lname, @cby, @changed)
			if @new_sex != @old_sex
				insert lgfl values ('s_sex', @code, @old_sex, @new_sex, @cby, @changed)
			if @new_birth != @old_birth
				insert lgfl values ('s_birth', @code, convert(char(10), @old_birth, 111) + ' ' + convert(char(10), @old_birth, 108), 
				convert(char(10), @new_birth, 111) + ' ' + convert(char(10), @new_birth, 108), @cby, @changed)
			if @new_sta != @old_sta
				insert lgfl values ('s_sta', @code, @old_sta, @new_sta, @cby, @changed)
			if @new_idcls != @old_idcls
				insert lgfl values ('s_idcls', @code, @old_idcls, @new_idcls, @cby, @changed)
			if @new_ident != @old_ident
				insert lgfl values ('s_ident', @code, @old_ident, @new_ident, @cby, @changed)
			if @new_arr != @old_arr
				insert lgfl values ('s_arr', @code, convert(char(10), @old_arr, 111) + ' ' + convert(char(10), @old_arr, 108), 
				convert(char(10), @new_arr, 111) + ' ' + convert(char(10), @new_arr, 108), @cby, @changed)
			if @new_nation != @old_nation
				insert lgfl values ('s_nation', @code, @old_nation, @new_nation, @cby, @changed)
			if @new_street != @old_street
				insert lgfl values ('s_street', @code, @old_street, @new_street, @cby, @changed)
			if @new_fname != @old_fname
				insert lgfl values ('s_fname', @code, @old_fname, @new_fname, @cby, @changed)
			if @new_name2 != @old_name2
				insert lgfl values ('s_name2', @code, @old_name2, @new_name2, @cby, @changed)
			if @new_name3 != @old_name3
				insert lgfl values ('s_name3', @code, @old_name3, @new_name3, @cby, @changed)
			if @new_country != @old_country
				insert lgfl values ('s_country', @code, @old_country, @new_country, @cby, @changed)
			if @new_lang != @old_lang
				insert lgfl values ('s_lang', @code, @old_lang, @new_lang, @cby, @changed)
			if @new_zip != @old_zip
				insert lgfl values ('s_zip', @code, @old_zip, @new_zip, @cby, @changed)
			if @new_mobile != @old_mobile
				insert lgfl values ('s_mobile', @code, @old_mobile, @new_mobile, @cby, @changed)
			if @new_phone != @old_phone
				insert lgfl values ('s_phone', @code, @old_phone, @new_phone, @cby, @changed)
			if @new_fax != @old_fax
				insert lgfl values ('s_fax', @code, @old_fax, @new_fax, @cby, @changed)
			if @new_wetsite != @old_wetsite
				insert lgfl values ('s_wetsite', @code, @old_wetsite, @new_wetsite, @cby, @changed)
			if @new_email != @old_email
				insert lgfl values ('s_email', @code, @old_email, @new_email, @cby, @changed)
			if @new_dep != @old_dep
				insert lgfl values ('s_dep', @code, convert(char(10), @old_dep, 111) + ' ' + convert(char(10), @old_dep, 108), 
				convert(char(10), @new_dep, 111) + ' ' + convert(char(10), @new_dep, 108), @cby, @changed)
		   if @new_dept!=@old_dept
            insert lgfl values ('s_dept', @code, @old_dept, @new_dept, @cby, @changed)
         if @new_job!=@old_job
            insert lgfl values ('s_job', @code, @old_job, @new_job, @cby, @changed)
         if @new_extension!=@old_extension
            insert lgfl values ('s_extension', @code, @old_extension, @new_extension, @cby, @changed)
         if @new_grp!= @old_grp
            insert lgfl values ('s_grp', @code, @old_grp, @new_grp, @cby, @changed)
         if @new_territory!=@old_territory
            insert lgfl values ('s_territory', @code, @old_territory, @new_territory, @cby, @changed)
         if @new_fulltime!=@old_fulltime
            insert lgfl values ('s_fulltime', @code, @old_fulltime, @new_fulltime, @cby, @changed)
         if @new_arr0!=@old_arr0
            insert lgfl values ('s_arr0', @code, convert(char(10), @old_arr0, 111) + ' ' + convert(char(10), @old_arr0, 108), 
				convert(char(10), @new_arr0, 111) + ' ' + convert(char(10), @new_arr0, 108), @cby, @changed)
         if @new_empno!=@old_empno
            insert lgfl values ('s_empno', @code, @old_empno, @new_empno, @cby, @changed)
         if @new_state!=@old_state
            insert lgfl values ('s_state', @code, @old_state, @new_state, @cby, @changed)
         if @new_town!=@old_town
            insert lgfl values ('s_town', @code, @old_town, @new_town, @cby, @changed)
         if @new_sequence!=@old_sequence
            insert lgfl values ('s_sequence', @code, convert(char,@old_sequence), convert(char,@new_sequence), @cby, @changed)
         if @new_exp_m1!=@old_exp_m1
            insert lgfl values ('s_exp_m1', @code, convert(char,@old_exp_m1), convert(char,@new_exp_m1), @cby, @changed)
         if @new_exp_m2!=@old_exp_m2
            insert lgfl values ('s_exp_m2', @code, convert(char,@old_exp_m2), convert(char,@new_exp_m2), @cby, @changed)
         if @new_exp_dt1!=@old_exp_dt1
            insert lgfl values ('s_exp_dt1', @code, convert(char(10), @old_exp_dt1, 111) + ' ' + convert(char(10), @old_exp_dt1, 108), 
				convert(char(10), @new_exp_dt1, 111) + ' ' + convert(char(10), @new_exp_dt1, 108), @cby, @changed)
         if @new_exp_dt2!=@old_exp_dt2
            insert lgfl values ('s_exp_dt2', @code, convert(char(10), @old_exp_dt2, 111) + ' ' + convert(char(10), @old_exp_dt2, 108), 
				convert(char(10), @new_exp_dt2, 111) + ' ' + convert(char(10), @new_exp_dt2, 108), @cby, @changed)
         if @new_exp_s1!=@old_exp_s1
            insert lgfl values ('s_exp_s1', @code, @old_exp_s1, @new_exp_s1, @cby, @changed)
         if @new_exp_s2!=@old_exp_s2
            insert lgfl values ('s_exp_s2', @code, @old_exp_s2, @new_exp_s2, @cby, @changed)
         if @new_exp_s3!=@old_exp_s3
            insert lgfl values ('s_exp_s3', @code, @old_exp_s3, @new_exp_s3, @cby, @changed)
			end
		select  @old_sta=@new_sta,   
         @old_name=@new_name,   
         @old_dept=@new_dept,   
         @old_job=@new_job,   
         @old_extension=@new_extension,   
         @old_grp=@new_grp,   
         @old_territory=@new_territory,   
         @old_fulltime=@new_fulltime,   
         @old_arr0=@new_arr0,   
         @old_arr=@new_arr,   
         @old_dep=@new_dep,   
         @old_empno=@new_empno,   
         @old_fname=@new_fname,   
         @old_lname=@new_lname,   
         @old_name2=@new_name2,   
         @old_name3=@new_name3,   
         @old_sex=@new_sex,   
         @old_idcls=@new_idcls,   
         @old_ident=@new_ident,   
         @old_lang=@new_lang,   
         @old_birth=@new_birth,   
         @old_nation=@new_nation,   
         @old_country=@new_country,   
         @old_state=@new_state,   
         @old_town=@new_town,   
         @old_street=@new_street,   
         @old_zip=@new_zip,   
         @old_mobile=@new_mobile,   
         @old_phone=@new_phone,   
         @old_fax=@new_fax,   
         @old_wetsite=@new_wetsite,   
         @old_email=@new_email,
         @old_sequence=@new_sequence,   
         @old_exp_m1=@new_exp_m1,   
         @old_exp_m2=@new_exp_m2,   
         @old_exp_dt1=@new_exp_dt1,   
         @old_exp_dt2=@new_exp_dt2,   
         @old_exp_s1=@new_exp_s1,   
         @old_exp_s2=@new_exp_s2,   
         @old_exp_s3=@new_exp_s3
		fetch c_log_saleid into @new_sta,@new_name,  @new_dept, @new_job,@new_extension,@new_grp,@new_territory, @new_fulltime,   
         @new_arr0,@new_arr, @new_dep,@new_empno,@new_fname,@new_lname,@new_name2,@new_name3,@new_sex,@new_idcls,@new_ident,   
         @new_lang,@new_birth, @new_nation,@new_country,@new_state,@new_town, @new_street, @new_zip, @new_mobile,@new_phone,   
         @new_fax, @new_wetsite,@new_email,@new_sequence,@new_exp_m1,@new_exp_m2,@new_exp_dt1,@new_exp_dt2,@new_exp_s1,   
         @new_exp_s2,@new_exp_s3,@logmark, @cby,@changed
		end
	close c_log_saleid
	if @row > 0
		delete saleid_log where code = @code and logmark < @logmark
	fetch c_saleid into @code
	end
deallocate cursor c_log_saleid
close c_saleid
deallocate cursor c_saleid
;
