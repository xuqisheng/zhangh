if object_id('p_yjw_lgfl_rmooo') is not null
drop proc p_yjw_lgfl_rmooo
;
create proc p_yjw_lgfl_rmooo
	@folio			char(10)
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
	@old_folio        char(10),						@new_folio        char(10),
	@old_sfolio       varchar(10),					@new_sfolio       varchar(10),
   @old_status       varchar(1),						@new_status       varchar(1),
   @old_roomno       char(5),							@new_roomno       char(5),
	@old_oroomno		char(5),							@new_oroomno		char(5),
	@old_sta				char(1),							@new_sta				char(1),
	@old_dbegin			datetime,						@new_dbegin			datetime,
	@old_dend			datetime,						@new_dend			datetime,
	@old_reason			char(3),							@new_reason			char(3),
	@old_empno1			char(10),						@new_empno1			char(10),
	@old_date1			datetime,						@new_date1			datetime,
	@old_empno2			char(10),						@new_empno2			char(10),
	@old_date2			datetime,						@new_date2			datetime,
	@old_remark			varchar(255),					@new_remark			varchar(255)

declare		@pos			int

declare c_log_rmsta cursor for
	select folio,sfolio,status,roomno,oroomno,sta,dbegin,dend,reason,empno1,date1,empno2,date2,remark,logmark
		from rm_ooo_log where folio = @folio
	union
	select folio,sfolio,status,roomno,oroomno,sta,dbegin,dend,reason,empno1,date1,empno2,date2,remark,logmark
		from rm_ooo where folio = @folio
	order by logmark


	select @row = 0
	open c_log_rmsta
	fetch c_log_rmsta into @new_folio,@new_sfolio,@new_status,@new_roomno,@new_oroomno,@new_sta,@new_dbegin,@new_dend,@new_reason,@new_empno1,@new_date1,@new_empno2,@new_date2,@new_remark,@logmark
                  
	while @@sqlstatus =0
		begin
		select @row = @row + 1
		if @row > 1
			begin
			if @new_sta != @old_sta 
				insert lgfl(columnname,accnt,old,new,empno,date) values ('ro_sta', @folio, @old_sta, @new_sta, @new_empno1, @new_date1)
			if @new_status != @old_status
				insert lgfl(columnname,accnt,old,new,empno,date) values ('ro_status', @folio, @old_status, @new_status, @new_empno1, @new_date1)
			if @new_dbegin != @old_dbegin
				insert lgfl(columnname,accnt,old,new,empno,date) values ('ro_dbegin', @folio, ltrim(convert(varchar,@old_dbegin,111)), ltrim(convert(varchar,@new_dbegin,111)), @new_empno1, @new_date1)
			if @new_dend != @old_dend
				insert lgfl(columnname,accnt,old,new,empno,date) values ('ro_dend', @folio,ltrim(convert(varchar,@old_dend,111)), ltrim(convert(varchar,@new_dend,111)), @new_empno1, @new_date1)
			if @new_reason != @old_reason
				insert lgfl(columnname,accnt,old,new,empno,date) values ('ro_reason', @folio, @old_reason, @new_reason, @new_empno1, @new_date1)
			if @new_remark != @old_remark
				insert lgfl(columnname,accnt,old,new,empno,date) values ('ro_remark', @folio, @old_remark, @new_remark, @new_empno1, @new_date1)
			end
		select
			@old_sta = @new_sta,
			@old_status = @new_status,
			@old_dbegin = @new_dbegin,
			@old_dend = @new_dend,
			@old_reason = @new_reason,
			@old_remark = @new_remark
			
		fetch c_log_rmsta into @new_folio,@new_sfolio,@new_status,@new_roomno,@new_oroomno,@new_sta,@new_dbegin,@new_dend,@new_reason,@new_empno1,@new_date1,@new_empno2,@new_date2,@new_remark,@logmark
		end
	close c_log_rmsta
	if @row > 0
		delete rm_ooo_log where folio=@folio and logmark < @logmark

deallocate cursor c_log_rmsta

;