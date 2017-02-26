
/*
	sp_menu 的三个触发器
*/

if exists(select 1 from sysobjects where name = 't_sp_menu_insert')
	drop trigger t_sp_menu_insert
;

create trigger t_sp_menu_insert
on sp_menu for insert
as
declare
	@lastnum			integer,
	@deptno			char(2),
	@pccode			char(2),
	@sta				char(1),
	@paid				char(1),
	@tea_name		char(10),
	@empno			char(3),
	@empno1			char(3),
	@empno2			char(3),
	@bdate			datetime,
	@shift			char(1),
	@tableno			char(4),
	@mode				char(3),
	@dsc_rate		money,
	@serve_rate		money,
	@serve_charge0	money,
	@serve_charge	money,
	@tax_rate		money,
	@tax_charge0	money,
	@tax_charge		money,
	@tea_charge0	money,
	@tea_charge		money,
	@menu				char(10),
	@guest			integer,
	@tea_rate		money,
	@amount0			money,
	@amount			money

select @menu = menu,@paid = paid from inserted
if @paid = '0'
	begin
	select @bdate = bdate1 from sysdata
	begin tran
	save  tran p_gl_pos_new_menu
	update sp_menu set bdate = @bdate where menu = @menu
	select @sta = sta,@guest = guest,@deptno = deptno,@pccode = pccode,
			 @mode = mode,@dsc_rate = dsc_rate,
			 @serve_rate = serve_rate,@tax_rate = tax_rate,
			 @tea_rate = tea_rate,@lastnum = lastnum,@empno = empno3,
			 @shift = shift,@tableno = isnull(tableno,'')
	  from inserted
	insert pos_tblav (menu, tableno, bdate, shift, sta, empno, pcrec)
	select @menu, @tableno, @bdate, @shift, '7',isnull(empno3, ''),isnull(pcrec, '') from inserted

	/*插入账单打印记录数据*/
	insert sp_menu_bill (menu, hline, inumber, hpage, hamount, dsc, srv, tax) select @menu, 0, 0, 0, 0, 0, 0, 0


	/* 记录员工状态 */
	select @empno1 = empno1, @empno2 = empno2 from inserted
	if rtrim(ltrim(@empno1)) <> null and not exists(select 1 from pos_empno a, inserted b, pos_empnoav c
		 where a.empno = @empno1 and a.empno = c.empno and b.menu = c.menu and c.bdate = @bdate and c.inumber = 0 )
		insert pos_empnoav (empno, menu, bdate, shift, sta, inumber)
			select @empno1,@menu, @bdate, @shift, '1', 0
	if rtrim(ltrim(@empno2)) <> null and not exists(select 1 from pos_empno a, inserted b, pos_empnoav c
		 where a.empno = @empno2 and a.empno = c.empno and b.menu = c.menu and c.bdate = @bdate and c.inumber = 0 )
		insert pos_empnoav (empno, menu, bdate, shift, sta, inumber)
			select @empno1,@menu, @bdate, @shift, '1', 0

	select @tax_charge0 = 0,@tax_charge = 0,@serve_charge0 = 0,@serve_charge = 0
	/*茶位费*/
	select @lastnum = @lastnum + 1,@amount0 = round(@tea_rate * @guest,2),@amount = 0
	select @tea_name = name from pos_pccode where pccode = @pccode
	if @guest > 0 and @tea_rate > 0
		/*计算茶位费的优惠价*/
		exec p_gl_pos_create_discount	@deptno,@pccode,@mode,'X',@amount0,@dsc_rate,@result = @amount output
	insert sp_dish(menu,inumber,plucode,sort,id,name1,code,printid,number,amount,empno,bdate,date0,special) 
				select @menu,@lastnum,'','',0,'茶位费','X',0,@guest,@amount,@empno,@bdate,getdate(),'N'
	/*附加费*/
	select @lastnum = @lastnum + 1
	/*计算茶位费的附加费*/
	exec p_gl_pos_create_tax @deptno,@pccode,@mode,'Y',@amount0,@amount,@tax_rate,@result0 = @tax_charge0 output,@result = @tax_charge output
	insert sp_dish(menu,inumber,plucode,sort,id,code,name1,printid,number,amount,empno,bdate,date0,special) 
		select @menu,@lastnum,'','',0,'Y','附加费',0,1,@tax_charge,@empno,@bdate,getdate(),'N'
	/*服务费*/
	select @lastnum = @lastnum + 1
	/*计算茶位费的服务费*/
	exec p_gl_pos_create_serve @deptno,@pccode,@mode,'Z',@amount0,@amount,@serve_rate,@result0 = @serve_charge0 output,@result = @serve_charge output
	insert sp_dish(menu,inumber,plucode,sort,id,code,name1,printid,number,amount,empno,bdate,date0,special) 
		select @menu,@lastnum,'','',0,'Z','服务费',0,1,@serve_charge,@empno,@bdate,getdate(),'N'
	update sp_menu set lastnum = @lastnum,amount = @guest * @tea_rate + @serve_charge + @tax_charge
    where menu = @menu
	commit tran 
	end
;


if exists(select 1 from sysobjects where name = 't_sp_menu_delete')
	drop trigger t_sp_menu_delete
;

create trigger t_sp_menu_delete
on sp_menu for delete
as

delete sp_dish where menu = (select menu from deleted)
delete pos_tblav where menu = (select menu from deleted)
delete pos_empnoav where menu = (select menu from deleted)
;


if exists(select 1 from sysobjects where name = 't_sp_menu_update')
	drop trigger t_sp_menu_update
;

create trigger t_sp_menu_update
on sp_menu for update
as
declare
	@paid						char(1),
	@current_menu			char(10),
	@menu						char(10),
	@empno					char(3),
	@dish_remark			char(15),
	@menu_remark			char(20),
	@refer					char(20),
	@lastnum					integer,
	@nlastnum				integer,
	@id						integer,
	@code						char(15),
	@shift					char(1),
	@pccode					char(3),
	@package					char(3),
	@tag1						char(3),
	@amount					money,
	@charge					money,
	@pc_id					char(4),
	@selemark				char(13), 
	@accnt					char(20),
	@guestid					char(20),
	@bdate					datetime,
	@ret						integer,
   @msg						char(60), 
	@count					integer,
	@sta						char(7)
	
if update(tableno) or update(bdate) or update(shift)
	update pos_tblav set tableno = a.tableno, bdate = a.bdate, shift = a.shift from inserted a, deleted b
	 where pos_tblav.menu = a.menu and b.menu = a.menu and pos_tblav.tableno = b.tableno and pos_tblav.inumber = 0
if update(empno1) or update(bdate) or update(shift)
begin
	if exists(select 1 from inserted a, deleted b, pos_empnoav	 where pos_empnoav.menu = a.menu and b.menu = a.menu and pos_empnoav.empno = b.empno1 and pos_empnoav.inumber = 0 and rtrim(a.empno1) <> null)
		update pos_empnoav set empno = a.empno1, bdate = a.bdate, shift = a.shift from inserted a, deleted b
		 where pos_empnoav.menu = a.menu and b.menu = a.menu and pos_empnoav.empno = b.empno1 and pos_empnoav.inumber = 0
	else
		insert pos_empnoav (empno, menu, bdate, shift, sta, inumber)
			select empno1,menu, bdate, shift, '1', 0 from inserted where  rtrim(empno1) <> null
end

/* 记录员工状态 */
if update(empno2) or update(bdate) or update(shift)
begin
	if exists(select 1 from inserted a, deleted b, pos_empnoav	where pos_empnoav.menu = a.menu and b.menu = a.menu and pos_empnoav.empno = b.empno2 and pos_empnoav.inumber = 0 and rtrim(a.empno2) <> null)
		update pos_empnoav set empno = a.empno2, bdate = a.bdate, shift = a.shift from inserted a, deleted b
		 where pos_empnoav.menu = a.menu and b.menu = a.menu and pos_empnoav.empno = b.empno2 and pos_empnoav.inumber = 0
	else
		insert pos_empnoav (empno, menu, bdate, shift, sta, inumber)
			select empno2,menu, bdate, shift, '1', 0 from inserted where  rtrim(empno2) <> null
end

if update(paid)
	begin
	select @paid = paid, @current_menu = menu, @menu_remark = remark, @shift = shift, @empno = empno3, 
		@pccode = pccode + 'A', @package = ' ' + pccode, @bdate = bdate, @pc_id = pc_id from inserted
	if @paid = '1'
		begin
		update pos_tblav set sta = '0' from inserted a
		 where pos_tblav.menu = a.menu and a.paid = '1' and pos_tblav.inumber = 0
		update pos_empnoav set sta = '0' from inserted a
		 where pos_empnoav.menu = a.menu and a.paid = '1' and pos_empnoav.inumber = 0
		if exists(select 1 from pos_reserve a, inserted b where a.menu = b.menu)
			update pos_reserve set guest=a.guest, tables=a.tables, tableno=a.tableno, amount = a.amount from inserted a
				where pos_reserve.menu=a.menu
		end
	end

if update(sta)       //    取消菜单, 要冲掉茶位费
	begin
	select @sta = sta, @menu = menu, @pccode = pccode, @charge = amount, @bdate = bdate, @shift = shift from inserted 
	if @sta ='7' and @charge <> 0 
		begin
		update sp_menu set amount = 0 where menu = @menu
		update sp_dish set amount = 0 where menu = @menu and rtrim(code) ='X'
		end
	if @sta = '7'    
		begin
		update pos_empnoav set sta = '0' where menu = @menu
		update pos_tblav set sta = "0" where menu  = @menu
		end
//	if charindex(@sta, '357' ) > 0	// 清理餐位资源
//		exec p_cyj_pos_rsvdtl @menu,@pccode,'',@bdate,@shift,0,0
	end

;
