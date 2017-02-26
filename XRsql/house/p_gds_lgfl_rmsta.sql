------------------------------------------------------------------------
--	rmsta 日志
--
--	rmsta_log -- 生成办法 ：通过插入 deleted 完成 （update tirgger）
--	因此，下面的过程执行后，会导致 rmsta_log 相关记录清除
------------------------------------------------------------------------

-- Log description
//delete lgfl_des where columnname like 'r_%';
//insert lgfl_des(columnname, descript, descript1,tag) values('r_sta','客房状态','Rm. Status','R');
//insert lgfl_des(columnname, descript, descript1,tag) values('r_oroomno','内部房号','Inner No.','R');
//insert lgfl_des(columnname, descript, descript1,tag) values('r_hall','楼号','Building','R');
//insert lgfl_des(columnname, descript, descript1,tag) values('r_rate','房价','Rate','R');
//insert lgfl_des(columnname, descript, descript1,tag) values('r_people','人数','Gst#','R');
//insert lgfl_des(columnname, descript, descript1,tag) values('r_bedno','床数','Bed#','R');
//insert lgfl_des(columnname, descript, descript1,tag) values('r_ocsta','空闲态','Vacant','R');
//insert lgfl_des(columnname, descript, descript1,tag) values('r_tmpsta','临时态','Assignment','R');
//insert lgfl_des(columnname, descript, descript1,tag) values('r_accntset','账号','Acct.','R');
//insert lgfl_des(columnname, descript, descript1,tag) values('r_haccnt','档案','Name','R');
//insert lgfl_des(columnname, descript, descript1,tag) values('r_fempno','设置未来工号','User ID','R');
//insert lgfl_des(columnname, descript, descript1,tag) values('r_ref','备注','Remark','R');
//insert lgfl_des(columnname, descript, descript1,tag) values('r_futsta','未来状态','Future Sta.','R');
//insert lgfl_des(columnname, descript, descript1,tag) values('r_locksta','锁定状态','Lock Sta.','R');
//
-- Proc 
IF OBJECT_ID('p_gds_lgfl_rmsta') IS NOT NULL
    DROP PROCEDURE p_gds_lgfl_rmsta
;
create proc p_gds_lgfl_rmsta
	@roomno			char(10)
as
declare
	@lroomno				char(10),
	@row					integer,
	@cby					char(10),
	@changed				datetime,
	@logmark				integer,
	@tmpstr1				char(10),
	@tmpstr2				char(10),
	@tmpstr3				varchar(70),
	@tmpstr4				varchar(70)

declare
	@old_ormno        char(5),						@new_ormno        char(5),
	@old_hall         varchar(1),					@new_hall         varchar(1),
   @old_flr          varchar(3),					@new_flr          varchar(3),
   @old_type        	char(5),						@new_type        	char(5),
	@old_ocsta			char(1),						@new_ocsta			char(1),
	@old_sta				char(1),						@new_sta				char(1),
	@old_people			int,							@new_people			int,
	@old_bedno			int,							@new_bedno			int,
	@old_rate			money,						@new_rate			money,
	@old_tmpsta			char(1),						@new_tmpsta			char(1),
	@old_locked			char(1),						@new_locked			char(1),
	@old_futsta			char(1),						@new_futsta			char(1),
	@old_fempno			char(10),					@new_fempno			char(10),
	@old_accntset		varchar(70),				@new_accntset		varchar(70),
	@old_ref				varchar(50),				@new_ref				varchar(50)

declare		@pos			int


if @roomno is null
	declare c_rmsta cursor for	select distinct roomno from rmsta_log
else
	declare c_rmsta cursor for	select distinct roomno from rmsta_log where roomno = @roomno

declare c_log_rmsta cursor for
	select oroomno,hall,flr,type,ocsta,sta,people,bedno,rate,tmpsta,locked,futsta,fempno,accntset,ref,empno,changed,logmark
		from rmsta_log where roomno = @lroomno 
	union 
	select oroomno,hall,flr,type,ocsta,sta,people,bedno,rate,tmpsta,locked,futsta,fempno,accntset,ref,empno,changed,logmark
		from rmsta where roomno = @lroomno 
	order by logmark

open c_rmsta
fetch c_rmsta into @lroomno
while @@sqlstatus =0
   begin
	select @row = 0
	open c_log_rmsta
	fetch c_log_rmsta into @new_ormno,@new_hall,@new_flr,@new_type,@new_ocsta,@new_sta,
		@new_people,@new_bedno,@new_rate,@new_tmpsta,@new_locked,@new_futsta,@new_fempno,
			@new_accntset,@new_ref,@cby,@changed,@logmark
	while @@sqlstatus =0
		begin
		select @row = @row + 1
		if @row > 1
			begin
			if @new_sta != @old_sta or @new_ocsta != @old_ocsta
				begin
				select @tmpstr1=eccocode+'('+code+')' from rmstamap where code=@old_ocsta+@old_sta
				select @tmpstr2=eccocode+'('+code+')' from rmstamap where code=@new_ocsta+@new_sta
				insert lgfl(columnname,accnt,old,new,empno,date) values ('r_sta', 'rm:'+@lroomno, @tmpstr1, @tmpstr2, @cby, @changed)
				end
			if @new_ormno != @old_ormno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('r_oroomno', 'rm:'+@lroomno, @old_ormno, @new_ormno, @cby, @changed)
			if @new_hall != @old_hall
				insert lgfl(columnname,accnt,old,new,empno,date) values ('r_hall', 'rm:'+@lroomno, @old_hall, @new_hall, @cby, @changed)
			if @new_rate != @old_rate
				insert lgfl(columnname,accnt,old,new,empno,date) values ('r_rate', 'rm:'+@lroomno, ltrim(convert(char(10), @old_rate)), ltrim(convert(char(10), @new_rate)), @cby, @changed)
			if @new_people != @old_people
				insert lgfl(columnname,accnt,old,new,empno,date) values ('r_people', 'rm:'+@lroomno, ltrim(convert(char(1), @old_people)), ltrim(convert(char(1), @new_people)), @cby, @changed)
			if @new_bedno != @old_bedno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('r_bedno', 'rm:'+@lroomno, ltrim(convert(char(1), @old_bedno)), ltrim(convert(char(1), @new_bedno)), @cby, @changed)
			if @new_tmpsta != @old_tmpsta
				insert lgfl(columnname,accnt,old,new,empno,date) values ('r_tmpsta', 'rm:'+@lroomno, @old_tmpsta, @new_tmpsta, @cby, @changed)
			if @new_accntset != @old_accntset
				begin
				select @tmpstr3=''
				while charindex('#',@old_accntset)>0
					begin
					select @tmpstr1 = substring(@old_accntset,1,charindex('#',@old_accntset) - 1)
					select @old_accntset = substring(@old_accntset,charindex('#',@old_accntset) + 1,datalength(@old_accntset) - charindex('#',@old_accntset))
					if exists(select 1 from master where accnt=@tmpstr1)
						select @tmpstr3 = @tmpstr3+@tmpstr1+'-'+b.name+'#' from master a,guest b where a.accnt=@tmpstr1 and a.haccnt=b.no
					else
						select @tmpstr3 = @tmpstr3+@tmpstr1+'-'+b.name+'#' from hmaster a,guest b where a.accnt=@tmpstr1 and a.haccnt=b.no
					end
				select @old_accntset = @tmpstr3,@tmpstr3 = '',@tmpstr4 = @new_accntset
				while charindex('#',@tmpstr4)>0
					begin
					select @tmpstr1 = substring(@tmpstr4,1,charindex('#',@tmpstr4) - 1)
					select @tmpstr4 = substring(@tmpstr4,charindex('#',@tmpstr4) + 1,datalength(@tmpstr4) - charindex('#',@tmpstr4))
					if exists(select 1 from master where accnt=@tmpstr1)
						select @tmpstr3 = @tmpstr3+@tmpstr1+'-'+b.name+'#' from master a,guest b where a.accnt=@tmpstr1 and a.haccnt=b.no
					else
						select @tmpstr3 = @tmpstr3+@tmpstr1+'-'+b.name+'#' from hmaster a,guest b where a.accnt=@tmpstr1 and a.haccnt=b.no
					end
				insert lgfl(columnname,accnt,old,new,empno,date) values ('r_accntset', 'rm:'+@lroomno, @old_accntset, @tmpstr3, @cby, @changed)
				end
			if @new_fempno != @old_fempno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('r_fempno', 'rm:'+@lroomno, @old_fempno, @new_fempno, @cby, @changed)
			if @new_ref != @old_ref
				insert lgfl(columnname,accnt,old,new,empno,date) values ('r_ref', 'rm:'+@lroomno, @old_ref, @new_ref, @cby, @changed)
			if @new_futsta != @old_futsta
				insert lgfl(columnname,accnt,old,new,empno,date) values ('r_futsta', 'rm:'+@lroomno, @old_futsta, @new_futsta, @cby, @changed)
			if @new_locked != @old_locked
				insert lgfl(columnname,accnt,old,new,empno,date) values ('r_locksta', 'rm:'+@lroomno, @old_locked, @new_locked, @cby, @changed)
			end
		select
			@old_ormno = @new_ormno,
			@old_hall = @new_hall,
			@old_sta = @new_sta,
			@old_flr = @new_flr,
			@old_type = @new_type,
			@old_rate = @new_rate,
			@old_people = @new_people,
			@old_bedno = @new_bedno,
			@old_ocsta = @new_ocsta,
			@old_tmpsta = @new_tmpsta,
			@old_locked = @new_locked,
			@old_futsta = @new_futsta,
			@old_fempno = @new_fempno,
			@old_accntset = @new_accntset,
			@old_ref = @new_ref

		fetch c_log_rmsta into @new_ormno,@new_hall,@new_flr,@new_type,@new_ocsta,@new_sta,
			@new_people,@new_bedno,@new_rate,@new_tmpsta,@new_locked,@new_futsta,@new_fempno,
				@new_accntset,@new_ref,@cby,@changed,@logmark
		end
	close c_log_rmsta
	if @row > 0
		delete rmsta_log where roomno = @lroomno and logmark < @logmark
	fetch c_rmsta into @lroomno
	end
deallocate cursor c_log_rmsta
close c_rmsta
deallocate cursor c_rmsta

return
;

