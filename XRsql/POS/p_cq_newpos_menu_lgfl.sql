drop proc p_cq_newpos_menu_lgfl;
create proc p_cq_newpos_menu_lgfl
	@accnt			char(10)
as
declare
	@laccnt				char(10),
	@lguestid			char(7),
	@row					integer,
	@cby					char(10),
	@changed				datetime,
	@logmark				integer

declare
		@old_tag				char(1),   
		@old_tag1			char(1),   
		@old_tag2			char(1),   
		@old_tag3			char(1),   
		@old_source			char(3),   
		@old_market			char(3),   
		@old_tables			int,   
		@old_guest			int,   
		@old_shift			char(1),   
		@old_deptno			char(2),   
		@old_pccode			char(3),   
		@old_posno			char(2),   
		@old_tableno		char(6),   
		@old_mode			char(3),   
		@old_dsc_rate		money,   
		@old_reason			char(3),   
		@old_tea_rate		money,   
		@old_serve_rate	money,   
		@old_tax_rate		money,   
		@old_srv				money,   
		@old_dsc				money,   
		@old_tax				money,   
		@old_empno1			char(10),   
		@old_empno2			char(10),   
		@old_empno3			char(10),   
		@old_sta				char(1),   
		@old_paid			char(1),   
		@old_setmodes		char(4),   
		@old_cusno			char(10),   
		@old_haccnt			char(10),   
		@old_foliono		char(20),   
		@old_remark			char(80),   
		@old_pcrec			char(10),   
		@old_saleid			char(10),   
		@old_checkid		char(20),
		@old_cardno			char(20),

		@new_tag				char(1),   
		@new_tag1			char(1),   
		@new_tag2			char(1),   
		@new_tag3			char(1),   
		@new_source			char(3),   
		@new_market			char(3),   
		@new_tables			int,   
		@new_guest			int,   
		@new_shift			char(1),   
		@new_deptno			char(2),   
		@new_pccode			char(3),   
		@new_posno			char(2),   
		@new_tableno		char(6),   
		@new_mode			char(3),   
		@new_dsc_rate		money,   
		@new_reason			char(3),   
		@new_tea_rate		money,   
		@new_serve_rate	money,   
		@new_tax_rate		money,   
		@new_srv				money,   
		@new_dsc				money,   
		@new_tax				money,   
		@new_empno1			char(10),   
		@new_empno2			char(10),   
		@new_empno3			char(10),   
		@new_sta				char(1),   
		@new_paid			char(1),   
		@new_setmodes		char(4),   
		@new_cusno			char(10),   
		@new_haccnt			char(10),   
		@new_foliono		char(20),   
		@new_remark			char(80),   
		@new_pcrec			char(10),   
		@new_saleid			char(10),   
		@new_checkid		char(20),
		@new_cardno			char(20)
	 

declare		@pos			int

if @accnt is null
	declare c_menu cursor for
		select menu from pos_menu_log group by menu having count(1) > 1
else
	declare c_menu cursor for
		select menu from pos_menu_log where menu = @accnt group by menu having count(1) > 1
declare c_log_menu cursor for
  SELECT tag,   
         tag1,   
         tag2,   
         tag3,   
         source,   
         market,   
         tables,   
         guest,   
         shift,   
         deptno,   
         pccode,   
         posno,   
         tableno,   
         mode,   
         dsc_rate,   
         reason,   
         tea_rate,   
         serve_rate,   
         tax_rate,   
         srv,   
         dsc,   
         tax,   
         empno1,   
         empno2,   
         empno3,   
         sta,   
         paid,   
         setmodes,   
         cusno,   
         haccnt,   
         foliono,   
         remark,   
         pcrec,   
         saleid,   
         checkid,
			logmark,cardno,
			isnull(cby,empno2),isnull(changed,getdate())
	from pos_menu_log where menu = @laccnt order by logmark
open c_menu
fetch c_menu into @laccnt
while @@sqlstatus =0
   begin

	select @row = 0
	open c_log_menu
	fetch c_log_menu into
		@new_tag,   
		@new_tag1,   
		@new_tag2,   
		@new_tag3,   
		@new_source,   
		@new_market,   
		@new_tables,   
		@new_guest,   
		@new_shift,   
		@new_deptno,   
		@new_pccode,   
		@new_posno,   
		@new_tableno,   
		@new_mode,   
		@new_dsc_rate,   
		@new_reason,   
		@new_tea_rate,   
		@new_serve_rate,   
		@new_tax_rate,   
		@new_srv,   
		@new_dsc,   
		@new_tax,   
		@new_empno1,   
		@new_empno2,   
		@new_empno3,   
		@new_sta,   
		@new_paid,   
		@new_setmodes,   
		@new_cusno,   
		@new_haccnt,   
		@new_foliono,   
		@new_remark,   
		@new_pcrec,   
		@new_saleid,   
		@new_checkid,
		@logmark,@new_cardno,@cby,@changed
	while @@sqlstatus =0
		begin
		select @row = @row + 1
		if @row > 1
			begin
			if @old_tag != @new_tag  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_tag', @laccnt, @old_tag, @new_tag, @cby, @changed)
			if @old_tag1 != @new_tag1  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_tag1', @laccnt, @old_tag1, @new_tag1, @cby, @changed)
			if @old_tag2 != @new_tag2  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_tag2', @laccnt, @old_tag2, @new_tag2, @cby, @changed)
			if @old_tag3 != @new_tag3  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_tag3', @laccnt, @old_tag3, @new_tag3, @cby, @changed)
			if @old_source != @new_source  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_source', @laccnt, @old_source, @new_source, @cby, @changed)
			if @old_market != @new_market  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_market', @laccnt, @old_market, @new_market, @cby, @changed)
			if @old_tables != @new_tables  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_tables', @laccnt, convert(char,@old_tables), convert(char,@new_tables), @cby, @changed)
			if @old_guest != @new_guest  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_guest', @laccnt, convert(char,@old_guest), convert(char,@new_guest), @cby, @changed)
			if @old_shift != @new_shift  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_shift', @laccnt, @old_shift, @new_shift, @cby, @changed)
			if @old_deptno != @new_deptno  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_deptno', @laccnt, @old_deptno, @new_deptno, @cby, @changed)
			if @old_pccode != @new_pccode  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_pccode', @laccnt, @old_pccode, @new_pccode, @cby, @changed)
			if @old_posno != @new_posno  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_posno', @laccnt, @old_posno, @new_posno, @cby, @changed)
			if @old_tableno != @new_tableno  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_tableno', @laccnt, @old_tableno, @new_tableno, @cby, @changed)
			if @old_mode != @new_mode  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_mode', @laccnt, @old_mode, @new_mode, @cby, @changed)
			if @old_dsc_rate != @new_dsc_rate  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_dsc_rate', @laccnt, convert(char,@old_dsc_rate), convert(char,@new_dsc_rate), @cby, @changed)
			if @old_reason != @new_reason  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_reason', @laccnt, @old_reason, @new_reason, @cby, @changed)
			if @old_tea_rate != @new_tea_rate  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_tea_rate', @laccnt, convert(char,@old_tea_rate), convert(char,@new_tea_rate), @cby, @changed)
			if @old_serve_rate != @new_serve_rate  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_serve_rate', @laccnt, convert(char,@old_serve_rate), convert(char,@new_serve_rate), @cby, @changed)
			if @old_tax_rate != @new_tax_rate  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_tax_rate', @laccnt, convert(char,@old_tax_rate), convert(char,@new_tax_rate), @cby, @changed)
			if @old_srv != @new_srv  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_srv', @laccnt, convert(char,@old_srv), convert(char,@new_srv), @cby, @changed)
			if @old_dsc != @new_dsc  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_dsc', @laccnt, convert(char,@old_dsc), convert(char,@new_dsc), @cby, @changed)
			if @old_tax != @new_tax  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_tax', @laccnt, convert(char,@old_tax), convert(char,@new_tax), @cby, @changed)
			if @old_empno1 != @new_empno1  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_empno1', @laccnt, @old_empno1, @new_empno1, @cby, @changed)
			if @old_empno3 != @new_empno3  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_empno3', @laccnt, @old_empno3, @new_empno3, @cby, @changed)
			if @old_sta != @new_sta  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_sta', @laccnt, @old_sta, @new_sta, @cby, @changed)
			if @old_paid != @new_paid  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_paid', @laccnt, @old_paid, @new_paid, @cby, @changed)
			if @old_setmodes != @new_setmodes  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_setmodes', @laccnt, @old_setmodes, @new_setmodes, @cby, @changed)
			if @old_cusno != @new_cusno  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_cusno', @laccnt, @old_cusno, @new_cusno, @cby, @changed)
			if @old_haccnt != @new_haccnt  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_haccnt', @laccnt, @old_haccnt, @new_haccnt, @cby, @changed)
			if @old_foliono != @new_foliono  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_foliono', @laccnt, @old_foliono, @new_foliono, @cby, @changed)
			if @old_remark != @new_remark  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_remark', @laccnt, @old_remark, @new_remark, @cby, @changed)
			if @old_pcrec != @new_pcrec  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_pcrec', @laccnt, @old_pcrec, @new_pcrec, @cby, @changed)
			if @old_saleid != @new_saleid  
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_saleid', @laccnt, @old_saleid, @new_saleid, @cby, @changed)
			if @old_checkid!= @new_checkid
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_checkid', @laccnt, @old_checkid, @new_checkid, @cby, @changed)
			if @old_cardno!= @new_cardno
				insert lgfl(columnname,accnt,old,new,empno,date) values ('np_cardno', @laccnt, @old_cardno, @new_cardno, @cby, @changed)
			end
		select 	@old_tag = @new_tag,   
					@old_tag1 = @new_tag1,   
					@old_tag2 = @new_tag2,   
					@old_tag3 = @new_tag3,   
					@old_source = @new_source,   
					@old_market = @new_market,   
					@old_tables = @new_tables,   
					@old_guest = @new_guest,   
					@old_shift = @new_shift,   
					@old_deptno = @new_deptno,   
					@old_pccode = @new_pccode,   
					@old_posno = @new_posno,   
					@old_tableno = @new_tableno,   
					@old_mode = @new_mode,   
					@old_dsc_rate = @new_dsc_rate,   
					@old_reason = @new_reason,   
					@old_tea_rate = @new_tea_rate,   
					@old_serve_rate = @new_serve_rate,   
					@old_tax_rate = @new_tax_rate,   
					@old_srv = @new_srv,   
					@old_dsc = @new_dsc,   
					@old_tax = @new_tax,   
					@old_empno1 = @new_empno1,   
					@old_empno2 = @new_empno2,   
					@old_empno3 = @new_empno3,   
					@old_sta = @new_sta,   
					@old_paid = @new_paid,   
					@old_setmodes = @new_setmodes,   
					@old_cusno = @new_cusno,   
					@old_haccnt = @new_haccnt,   
					@old_foliono = @new_foliono,   
					@old_remark = @new_remark,   
					@old_pcrec = @new_pcrec,   
					@old_saleid = @new_saleid,   
					@old_checkid= @new_checkid,
					@old_cardno = @new_cardno 

		fetch c_log_menu into
					@new_tag,   
					@new_tag1,   
					@new_tag2,   
					@new_tag3,   
					@new_source,   
					@new_market,   
					@new_tables,   
					@new_guest,   
					@new_shift,   
					@new_deptno,   
					@new_pccode,   
					@new_posno,   
					@new_tableno,   
					@new_mode,   
					@new_dsc_rate,   
					@new_reason,   
					@new_tea_rate,   
					@new_serve_rate,   
					@new_tax_rate,   
					@new_srv,   
					@new_dsc,   
					@new_tax,   
					@new_empno1,   
					@new_empno2,   
					@new_empno3,   
					@new_sta,   
					@new_paid,   
					@new_setmodes,   
					@new_cusno,   
					@new_haccnt,   
					@new_foliono,   
					@new_remark,   
					@new_pcrec,   
					@new_saleid,   
					@new_checkid,
					@logmark,@new_cardno,@cby,@changed
		end
	close c_log_menu
	if @row > 0
		delete pos_menu_log where menu = @laccnt and logmark < @logmark
	fetch c_menu into @laccnt
	end

deallocate cursor c_log_menu
close c_menu
deallocate cursor c_menu

return

;