//
delete lgfl_des where columnname like 'fefo_%';
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_sta', '状态', 'Status','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_sno', '手工单号', 'Inn.#','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_tag', '内部标记', 'Inn.Tag','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_gstid', '档案号', 'Prof.#','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_roomno', '房号', 'Room#','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_name', '姓名', 'Name','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_nation', '国家', 'Country','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_idcls', '证件类型', 'IDType','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_ident', '证件号码', 'ID#','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_code', '币种', 'Currency','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_class', '类别', 'Type','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_amount0', '金额', 'Amt0','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_amount', '净额', 'Amt','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_amtout', '兑出金额', 'Amt-Out','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_ref', '备注', 'Remark','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_cby', '修改人', 'Modified','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_changed', '修改时间', 'Modi. Time','R');
insert lgfl_des(columnname,descript,descript1,tag) values('fefo_print', '水单打印', 'Print Bill','R');


//
if exists (select * from sysobjects where name = 'p_gds_lgfl_fec_folio' and type = 'P')
	drop proc p_gds_lgfl_fec_folio;
create proc p_gds_lgfl_fec_folio
	@foliono					char(10)
as
--  fec_folio 日志
declare
	@code					char(10),
	@row					integer,
	@cby					char(10),
	@changed				datetime,
	@logmark				integer,

	@old_sta				char(1),			@new_sta				char(1),
	@old_sno				varchar(12),	@new_sno				varchar(12),
	@old_tag				char(1),			@new_tag				char(1),
	@old_gstid			char(7),			@new_gstid			char(7),
	@old_roomno			char(5),			@new_roomno			char(5),
	@old_name			varchar(50),	@new_name			varchar(50),
	@old_nation			char(3),			@new_nation			char(3),
	@old_idcls			char(3),			@new_idcls			char(3),
	@old_ident			char(20),		@new_ident			char(20),
	@old_code			char(3),			@new_code			char(3),
	@old_class			char(5),			@new_class			char(5),
	@old_amount0		money,			@new_amount0		money,
	@old_amount			money,			@new_amount			money,
	@old_amount_out	money,			@new_amount_out	money,
	@old_ref				varchar(100),	@new_ref				varchar(100)

//
if @foliono is null
	declare c_fec_folio cursor for select distinct foliono from fec_folio_log
else
	declare c_fec_folio cursor for select distinct foliono from fec_folio_log where foliono = @foliono
//
declare c_log_fec_folio cursor for
	select sta,sno,tag,gstid,roomno,name,nation,idcls,ident,code,class,amount0,amount,amount_out,ref,cby,changed,logmark from fec_folio_log where foliono = @code
	union 
	select sta,sno,tag,gstid,roomno,name,nation,idcls,ident,code,class,amount0,amount,amount_out,ref,cby,changed,logmark from fec_folio where foliono = @code
	order by logmark
open c_fec_folio
fetch c_fec_folio into @code
while @@sqlstatus = 0
   begin
	select @row = 0
	open c_log_fec_folio
	fetch c_log_fec_folio into @new_sta,@new_sno,@new_tag,@new_gstid,@new_roomno,@new_name,@new_nation,@new_idcls,@new_ident,
									@new_code,@new_class,@new_amount0,@new_amount,@new_amount_out,@new_ref,@cby,@changed,@logmark
	while @@sqlstatus =0
		begin
		select @row = @row + 1
		if @row > 1
			begin
			if @new_sta != @old_sta
				insert lgfl values ('fefo_sta', @code, @old_sta, @new_sta, @cby, @changed)
			if @new_sno != @old_sno
				insert lgfl values ('fefo_sno', @code, @old_sno, @new_sno, @cby, @changed)
			if @new_tag != @old_tag
				insert lgfl values ('fefo_tag', @code, @old_tag, @new_tag, @cby, @changed)
			if @new_gstid != @old_gstid
				insert lgfl values ('fefo_gstid', @code, @old_gstid, @new_gstid, @cby, @changed)
			if @new_roomno != @old_roomno
				insert lgfl values ('fefo_roomno', @code, @old_roomno, @new_roomno, @cby, @changed)
			if @new_name != @old_name
				insert lgfl values ('fefo_name', @code, @old_name, @new_name, @cby, @changed)
			if @new_nation != @old_nation
				insert lgfl values ('fefo_nation', @code, @old_nation, @new_nation, @cby, @changed)
			if @new_idcls != @old_idcls
				insert lgfl values ('fefo_idcls', @code, @old_idcls, @new_idcls, @cby, @changed)
			if @new_ident != @old_ident
				insert lgfl values ('fefo_ident', @code, @old_ident, @new_ident, @cby, @changed)
			if @new_code != @old_code
				insert lgfl values ('fefo_code', @code, @old_code, @new_code, @cby, @changed)
			if @new_class != @old_class
				insert lgfl values ('fefo_class', @code, @old_class, @new_class, @cby, @changed)
			if @new_ref != @old_ref
				insert lgfl values ('fefo_ref', @code, @old_ref, @new_ref, @cby, @changed)
			if @new_amount0 != @old_amount0
				insert lgfl values ('fefo_amount0', @code, ltrim(convert(char(10),@old_amount0)), ltrim(convert(char(10),@new_amount0)), @cby, @changed)
			if @new_amount != @old_amount
				insert lgfl values ('fefo_amount', @code, ltrim(convert(char(10),@old_amount)), ltrim(convert(char(10),@new_amount)), @cby, @changed)
			if @new_amount_out != @old_amount_out
				insert lgfl values ('fefo_amtout', @code, ltrim(convert(char(10),@old_amount_out)), ltrim(convert(char(10),@new_amount_out)), @cby, @changed)

			end

		select @old_sta=@new_sta,@old_sno=@new_sno,@old_tag=@new_tag,@old_gstid=@new_gstid,
			@old_roomno=@new_roomno,@old_name=@new_name,@old_nation=@new_nation,
			@old_idcls=@new_idcls,@old_ident=@new_ident,@old_code=@new_code,@old_class=@new_class,
			@old_amount0=@new_amount0,@old_amount=@new_amount,@old_amount_out=@new_amount_out,@old_ref=@new_ref

		fetch c_log_fec_folio into @new_sta,@new_sno,@new_tag,@new_gstid,@new_roomno,@new_name,@new_nation,@new_idcls,@new_ident,
									@new_code,@new_class,@new_amount0,@new_amount,@new_amount_out,@new_ref,@cby,@changed,@logmark
		end
	close c_log_fec_folio
	if @row > 0
		delete fec_folio_log where foliono = @code and logmark < @logmark
	fetch c_fec_folio into @code
	end
deallocate cursor c_log_fec_folio
close c_fec_folio
deallocate cursor c_fec_folio
;
