drop proc p_cq_newpos_std_add;
create proc p_cq_newpos_std_add
	@menu			char(10),
	@empno		char(10),
	@id			int,
	@inumber		int,
	@number		money,
	@unit			char(4),
	@price		money,
	@remark		char(15),
	@pc_id		char(8),
	@pinumber	int,
	@cook			char(100) = '',
	@name			char(30) = ''
as
declare
	@stdmx_id			int,
	@printid				int,
	@plucode				char(2),
	@sort					char(4),
	@code					char(6),
	@orderno				char(10),
	@tableno				char(5),
	@siteno				char(2),
	@name2				char(32),
	@pccode				char(3),
	@kitchen				char(10),

	@bdate				datetime,
	@flag					char(30),

	@name1				char(20)

select @stdmx_id = lastnum + 1 from pos_menu where menu = @menu
select @plucode = plucode, @sort = sort, @code = code, @name1 = name1 ,@name2 = name2,
	@flag = flag0+flag1+flag2+flag3+flag4+flag5+flag6+flag7+flag8+flag9+flag10+flag11+flag12+flag13+flag14+flag15+flag16+flag17+flag18+flag19+'FFFFFFFFFF'
	 from pos_plu where id = @id

if @name = '' or @name is null
	select @name = @name1

select @bdate = bdate from sysdata
select @printid = isnull(max(printid)+1,1) from pos_dish
select @tableno = tableno, @siteno = siteno, @orderno =orderno from pos_dish where menu = @menu and inumber = @inumber
select @pccode = pccode from pos_menu where menu = @menu
exec p_cq_pos_get_printer @pccode,@id,@kitchen output


insert pos_dish(menu,inumber,pinumber,plucode,sort,id,printid,code,number,price,amount,pamount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2,empno1,cook,kitchen,kit_ref,flag19,flag19_use)
		select @menu,@stdmx_id,@pinumber,@plucode,@sort,@id,@printid,@code,@number,@price,@number * @price,0,@name,@name2,@unit,@empno,@bdate,'','','M',0, @inumber,'',0,0,0,@orderno,  @tableno,@siteno,isnull(@flag, ''),getdate(),getdate(),'',@cook,@kitchen,'','',''

update pos_menu set lastnum = lastnum + 1 from pos_menu where menu = @menu

--Êý¾Ý²åÈëpos_dishcard
exec p_cq_newpos_input_dishcard  @menu, @stdmx_id,@pc_id

exec p_fhb_pos_tcmxft @menu
--FHB Added
exec p_cyj_pos_sale  @menu, @stdmx_id
;