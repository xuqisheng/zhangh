//delete lgfl_des where columnname like 'sa_%';
//insert lgfl_des(columnname,descript,descript1,tag) values('sa_new', '新建分帐户', 'New Routing', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('sa_delete', '删除分帐户', 'Delete Routing', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('sa_roomno', '房号', 'Room', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('sa_haccnt', '客人号', 'P-No', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('sa_toroomno', '转账房号', 'Department', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('sa_toaccnt', '转账账号', 'Accnt. No.', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('sa_name', '名称', 'Name', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('sa_pccodes', '费用码', 'Deptartment', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('sa_starting', '起始日期', 'From', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('sa_closing', '截止日期', 'To', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('sa_paycode', '付款方式', 'Payment', 'R');
//insert lgfl_des(columnname,descript,descript1,tag) values('sa_ref', '备注', 'Remark', 'R');
//
if exists (select * from sysobjects where name = 'p_gl_lgfl_subaccnt' and type = 'P')
	drop proc p_gl_lgfl_subaccnt;
create proc p_gl_lgfl_subaccnt
	@operation			char(1) = 'S'
as
/* subaccnt日志 */
declare
	@accnt				char(10),
	@subaccnt			integer,
	@type					char(1),
	@row					integer,
	@cby					char(10),
	@changed				datetime,
	@logmark				integer,
	@old_roomno			char(5),					@new_roomno			char(5),
	@old_haccnt			char(7),					@new_haccnt			char(7),
	@old_toroomno		char(5),					@new_toroomno		char(5),
	@old_toaccnt		char(10),				@new_toaccnt		char(10),
	@old_name			char(50),				@new_name			char(50),
	@old_pccodes		varchar(255),			@new_pccodes		varchar(255),
	@old_starting		datetime,				@new_starting		datetime,
	@old_closing		datetime,				@new_closing		datetime,
	@old_paycode		char(5),					@new_paycode		char(5),
	@old_ref				varchar(50),			@new_ref				varchar(50)

//
declare c_subaccnt cursor for select distinct accnt, subaccnt, type from subaccnt_log
//
declare c_log_subaccnt cursor for
	select roomno, haccnt, to_roomno, to_accnt, name, pccodes, paycode, ref, starting_time, closing_time, cby, changed, logmark
		from subaccnt_log where accnt = @accnt and subaccnt = @subaccnt and type = @type
	union select roomno, haccnt, to_roomno, to_accnt, name, pccodes, paycode, ref, starting_time, closing_time, cby, changed, logmark
		from subaccnt where accnt = @accnt and subaccnt = @subaccnt and type = @type
	order by logmark
open c_subaccnt
fetch c_subaccnt into @accnt, @subaccnt, @type
while @@sqlstatus = 0
   begin
	select @row = 0
	open c_log_subaccnt
	fetch c_log_subaccnt into @new_roomno, @new_haccnt, @new_toroomno, @new_toaccnt, @new_name, @new_pccodes, @new_paycode, @new_ref, @new_starting, @new_closing, @cby, @changed, @logmark
	while @@sqlstatus =0
		begin
		select @row = @row + 1
		if @row > 1
			begin
			if @new_roomno != @old_roomno
				insert lgfl values ('sa_roomno  ' + convert(char(4), @subaccnt), @accnt, @old_roomno, @new_roomno, @cby, @changed)
			if @new_haccnt != @old_haccnt
				insert lgfl values ('sa_haccnt  ' + convert(char(4), @subaccnt), @accnt, @old_haccnt, @new_haccnt, @cby, @changed)
			if @new_toroomno != @old_toroomno
				insert lgfl values ('sa_toroomno' + convert(char(4), @subaccnt), @accnt, @old_toroomno, @new_toroomno, @cby, @changed)
			if @new_toaccnt != @old_toaccnt
				insert lgfl values ('sa_toaccnt ' + convert(char(4), @subaccnt), @accnt, @old_toaccnt, @new_toaccnt, @cby, @changed)
			if @new_name != @old_name
				insert lgfl values ('sa_name    ' + convert(char(4), @subaccnt), @accnt, @old_name, @new_name, @cby, @changed)
			if @new_pccodes != @old_pccodes
				insert lgfl values ('sa_pccodes ' + convert(char(4), @subaccnt), @accnt, @old_pccodes, @new_pccodes, @cby, @changed)
			if @new_toroomno != @old_toroomno
				insert lgfl values ('sa_toroomno' + convert(char(4), @subaccnt), @accnt, @old_toroomno, @new_toroomno, @cby, @changed)
			if @new_paycode != @old_paycode
				insert lgfl values ('sa_paycode ' + convert(char(4), @subaccnt), @accnt, @old_paycode, @new_paycode, @cby, @changed)
			if @new_ref != @old_ref
				insert lgfl values ('sa_ref     ' + convert(char(4), @subaccnt), @accnt, @old_ref, @new_ref, @cby, @changed)
			if @new_starting != @old_starting
				insert lgfl values ('sa_starting' + convert(char(4), @subaccnt), @accnt, convert(char(10),@old_starting,111), convert(char(10),@new_starting,111), @cby, @changed)
			if @new_closing != @old_closing
				insert lgfl values ('sa_closing ' + convert(char(4), @subaccnt), @accnt, convert(char(10),@old_closing,111), convert(char(10),@new_closing,111), @cby, @changed)
			end
		select @old_roomno=@new_roomno,@old_haccnt=@new_haccnt,@old_toroomno=@new_toroomno,
			@old_toaccnt=@new_toaccnt,@old_name=@new_name,@old_pccodes=@new_pccodes,
			@old_starting=@new_starting,@old_closing=@new_closing,@old_paycode=@new_paycode,@old_ref=@new_ref

		fetch c_log_subaccnt into @new_roomno, @new_haccnt, @new_toroomno, @new_toaccnt, @new_name, @new_pccodes, @new_paycode, @new_ref, @new_starting, @new_closing, @cby, @changed, @logmark
		end
	close c_log_subaccnt
	if @row > 0
		delete subaccnt_log where accnt=@accnt and subaccnt=@subaccnt and type=@type and logmark < @logmark
	fetch c_subaccnt into @accnt, @subaccnt, @type
	end
deallocate cursor c_log_subaccnt
close c_subaccnt
deallocate cursor c_subaccnt
//
if @operation = 'S'
	select 0, ''
;
