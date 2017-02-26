
/* 获得菜单的帐单所需要素 */

if exists(select * from sysobjects where name = "p_cyj_pos_bill_gen_elements" and type = "P")
	drop proc p_cyj_pos_bill_gen_elements;

create proc  p_cyj_pos_bill_gen_elements
	@menus				varchar(255),
	@today				char(1),					// T:打印当天的账单F:打印以前的账单
	@pc_id				char(4)
as
declare 
	@menu					char(10),
	@ls_menus			varchar(255),
	@ls_pccodes			varchar(255),
	@ls_descripts1		varchar(255),
	@ls_descripts2		varchar(255),
	@ls_pccode			char(3),
	@ls_descript1		char(10),
	@ls_descript2		char(10),
	@li_tables			int,
	@li_guest			int,
	@ls_tableno			varchar(255),
	@date0				datetime,
	@empno3				char(10),
	@pccode				char(3),
	@pcdes				char(20),
	@tableno				char(5)

delete bill_mst where pc_id = @pc_id
select @ls_menus = @menus, @li_tables = 0, @li_guest = 0, @ls_tableno = '', @ls_pccodes = '', @ls_descripts1 = '', @ls_descripts2 = ''
while datalength(@ls_menus) > 1
	begin
	select @menu = substring(@ls_menus, 1, 10), @ls_menus = substring(@ls_menus, 12, 255)
	if @today = 'T'
		/* 打印当天的账单, 取自 pos_dish */
		begin
		select @ls_pccode = a.pccode, @ls_descript1 = b.descript1, @ls_descript2 = isnull(b.descript2, ''), @date0 = date0,@empno3 = empno3,
			@li_tables = @li_tables + a.tables, @li_guest = @li_guest + a.guest, @ls_tableno = @ls_tableno + a.tableno + ','
			from pos_menu a, pos_tblsta b
--			where a.tableno = b.tableno and menu = @menu
-- 可以输入自定义台号
			where a.tableno *= b.tableno and menu = @menu
		end
	else
		/* 打印以前的账单, 取自 pos_hdish */
		begin
		select @ls_pccode = a.pccode, @ls_descript1 = b.descript1, @ls_descript2 = isnull(b.descript2, ''), @date0 = date0,@empno3 = empno3,
			@li_tables = @li_tables + a.tables, @li_guest = @li_guest + a.guest, @ls_tableno = @ls_tableno + a.tableno + ','
			from pos_hmenu a, pos_tblsta b
--			where a.tableno = b.tableno and menu = @menu
-- 可以输入自定义台号
			where a.tableno *= b.tableno and menu = @menu
	end
	if charindex(@ls_pccode, @ls_pccodes) = 0
		select @ls_pccodes = @ls_pccodes + @ls_pccode + ',', @ls_descripts1 = @ls_descripts1 + @ls_descript1 + ','
	if @ls_descript2 <> ''
		select @ls_descripts2 = @ls_descripts2 + @ls_descript2 + ','
	end
//
if datalength(ltrim(@ls_pccodes)) > 0
	select @ls_pccodes = ltrim(substring(@ls_pccodes, 1, datalength(@ls_pccodes) - 1))
if datalength(ltrim(@ls_descript1)) > 0
	select @ls_descripts1 = ltrim(substring(@ls_descripts1, 1, datalength(@ls_descripts1) - 1))
if datalength(ltrim(@ls_tableno)) > 0
	select @ls_tableno = ltrim(substring(@ls_tableno, 1, datalength(@ls_tableno) - 1))
if datalength(ltrim(@ls_descripts2)) > 0
	select @ls_descripts2 = ltrim(substring(@ls_descripts2, 1, datalength(@ls_descripts2) - 1))
//
select @pcdes = descript from pos_pccode where pccode = @ls_pccode

insert bill_mst(pc_id, char1, char2, char3, char4, char5)
select @pc_id, substring(@menus,1,50), convert(char(9), @date0, 11)+convert(char(8), @date0, 8), rtrim(@pcdes) + '/'+ @ls_tableno, convert(char(5),@li_guest)+'#'+convert(char(5),@li_tables), @empno3
return 0
;
