drop procedure p_cq_sp_bill_elements;

create proc  p_cq_sp_bill_elements

	@menus				varchar(255),
	@today				char(1),					                                    
	@paid					char(1),					                          
	@mode					char(4)					                                                        
as
declare 
	@ls_menus			varchar(255),
	@menu					char(10),
	@ls_pccodes			varchar(255),
	@ls_descripts1		varchar(255),
	@ls_descripts2		varchar(255),
	@ls_pccode			varchar(2),
	@ls_descript1		varchar(10),
	@ls_descript2		varchar(10),
	@li_tables			integer,
	@li_guest			integer,
	@ls_tableno			varchar(255)

select @ls_menus = @menus, @li_tables = 0, @li_guest = 0, @ls_tableno = '', @ls_pccodes = '', @ls_descripts1 = '', @ls_descripts2 = ''
while datalength(@ls_menus) > 1
	begin
	select @menu = substring(@ls_menus, 1, 10), @ls_menus = substring(@ls_menus, 12, 255)
	if @today = 'T'
		                                   
		begin
		select @ls_pccode = b.pccode, @ls_descript1 = b.descript1, @ls_descript2 = isnull(b.descript2, ''), 
			@li_tables = @li_tables + a.tables, @li_guest = @li_guest + a.guest, @ls_tableno = @ls_tableno + a.tableno + ','
			from sp_menu a, pos_tblsta b
			where a.tableno = b.tableno and menu = @menu
		end
	else
		                                    
		begin
		select @ls_pccode = b.pccode, @ls_descript1 = b.descript1, @ls_descript2 = isnull(b.descript2, ''), 
			@li_tables = @li_tables + a.tables, @li_guest = @li_guest + a.guest, @ls_tableno = @ls_tableno + a.tableno + ','
			from sp_hmenu a, pos_tblsta b
			where a.tableno = b.tableno and menu = @menu
		end
	if charindex(@ls_pccode, @ls_pccodes) = 0
		select @ls_pccodes = @ls_pccodes + @ls_pccode + ',', @ls_descripts1 = @ls_descripts1 + @ls_descript1 + ','
	if @ls_descript2 <> ''
		select @ls_descripts2 = @ls_descripts2 + @ls_descript2 + ','
	end
   
if datalength(ltrim(@ls_pccodes)) > 0
	select @ls_pccodes = ltrim(substring(@ls_pccodes, 1, datalength(@ls_pccodes) - 1))
if datalength(ltrim(@ls_descript1)) > 0
	select @ls_descripts1 = ltrim(substring(@ls_descripts1, 1, datalength(@ls_descripts1) - 1))
if datalength(ltrim(@ls_tableno)) > 0
	select @ls_tableno = ltrim(substring(@ls_tableno, 1, datalength(@ls_tableno) - 1))
if datalength(ltrim(@ls_descripts2)) > 0
	select @ls_descripts2 = ltrim(substring(@ls_descripts2, 1, datalength(@ls_descripts2) - 1))
   
select @ls_pccodes, @ls_descripts1, @ls_tableno, @ls_descripts2, @li_tables, @li_guest
return 0;
