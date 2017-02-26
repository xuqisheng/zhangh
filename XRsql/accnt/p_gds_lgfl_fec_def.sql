--
delete lgfl_des where columnname like 'fec_%';
insert lgfl_des(columnname,descript,descript1,tag) values('fec_descript', '中文描述', 'Chinese Name', 'R');
insert lgfl_des(columnname,descript,descript1,tag) values('fec_descript1', '英文描述', 'English Name', 'R');
insert lgfl_des(columnname,descript,descript1,tag) values('fec_disc', '贴息率', 'Discount Rate', 'R');
insert lgfl_des(columnname,descript,descript1,tag) values('fec_base', '基数', 'Base', 'R');
insert lgfl_des(columnname,descript,descript1,tag) values('fec_price_in', '买入价', 'Price In', 'R');
insert lgfl_des(columnname,descript,descript1,tag) values('fec_price_out', '卖出价', 'Price Out', 'R');
insert lgfl_des(columnname,descript,descript1,tag) values('fec_price_cash', '现钞价', 'Price Cash', 'R');


--
if exists (select * from sysobjects where name = 'p_gds_lgfl_fec_def' and type = 'P')
	drop proc p_gds_lgfl_fec_def;
create proc p_gds_lgfl_fec_def
	@no					char(3)
as
-- fec_def日志 
declare
	@code					char(3),
	@row					integer,
	@cby					char(10),
	@changed				datetime,
	@logmark				integer,
	@old_descript		varchar(30),			@new_descript		varchar(30),
	@old_descript1		varchar(30),			@new_descript1		varchar(30),--
	@old_disc			money,					@new_disc			money,--
	@old_base			money,					@new_base			money,
	@old_price_in		money,					@new_price_in		money,
	@old_price_out		money,					@new_price_out		money,--
	@old_price_cash	money,					@new_price_cash	money

--
if @no is null
	declare c_fec_def cursor for select distinct code from fec_def_log
else
	declare c_fec_def cursor for select distinct code from fec_def_log where code = @no
--
declare c_log_fec_def cursor for
	select descript,descript1,disc,base,price_in,price_out,price_cash,cby,changed,logmark from fec_def_log where code = @code
	order by logmark
open c_fec_def
fetch c_fec_def into @code
while @@sqlstatus = 0
   begin
	select @row = 0
	delete lgfl where columnname like 'fec_%' and accnt=@code 
	open c_log_fec_def
	fetch c_log_fec_def into @new_descript,@new_descript1,@new_disc,@new_base,@new_price_in,@new_price_out,@new_price_cash,@cby,@changed,@logmark
	while @@sqlstatus =0
		begin
		select @row = @row + 1
		if @row > 1
			begin
			if @new_descript != @old_descript
				insert lgfl values ('fec_descript', @code, @old_descript, @new_descript, @cby, @changed)
			if @new_descript1 != @old_descript1
				insert lgfl values ('fec_descript1', @code, @old_descript1, @new_descript1, @cby, @changed)
			if @new_disc != @old_disc
				insert lgfl values ('fec_disc', @code, ltrim(convert(char(10),@old_disc)), ltrim(convert(char(10),@new_disc)), @cby, @changed)
			if @new_base != @old_base
				insert lgfl values ('fec_base', @code, ltrim(convert(char(10),@old_base)), ltrim(convert(char(10),@new_base)), @cby, @changed)
			if @new_price_in != @old_price_in
				insert lgfl values ('fec_price_in', @code, ltrim(convert(char(10),@old_price_in)), ltrim(convert(char(10),@new_price_in)), @cby, @changed)
			if @new_price_out != @old_price_out
				insert lgfl values ('fec_price_out', @code, ltrim(convert(char(10),@old_price_out)), ltrim(convert(char(10),@new_price_out)), @cby, @changed)
			if @new_price_cash != @old_price_cash
				insert lgfl values ('fec_price_cash', @code, ltrim(convert(char(10),@old_price_cash)), ltrim(convert(char(10),@new_price_cash)), @cby, @changed)
			end
		select @old_descript = @new_descript, @old_descript1 = @new_descript1, 
			@old_disc = @new_disc, @old_base = @new_base, 
			@old_price_out = @new_price_out, @old_price_in = @new_price_in, @old_price_cash = @new_price_cash

		fetch c_log_fec_def into @new_descript,@new_descript1,@new_disc,@new_base,@new_price_in,@new_price_out,@new_price_cash,@cby,@changed,@logmark
		end
	close c_log_fec_def
--	if @row > 0          -- 不删除，为了做汇率日志报表方便 
--		delete fec_def_log where code = @code and logmark < @logmark
	fetch c_fec_def into @code
	end
deallocate cursor c_log_fec_def
close c_fec_def
deallocate cursor c_fec_def
;
