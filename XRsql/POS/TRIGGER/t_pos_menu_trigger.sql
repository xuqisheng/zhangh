--=======================pos_menu_bill===================================
if exists(select 1 from sysobjects where name = 't_pos_menu_bill_update')
	drop trigger t_pos_menu_bill_update
;

create trigger t_pos_menu_bill_update
on pos_menu_bill for update
as
declare
		@inumber		integer,
		@menu			char(10),
		@pccode		char(3),
		@pc_id		char(4)

select @inumber = inumber,@menu = menu from inserted
---自动刷新的变化记录
select @pccode = pccode ,@pc_id = pc_id from pos_menu where menu = @menu
if update(inumber) and @inumber > 0  and @pccode <> ''
	begin
	update table_update set update_date = getdate() where tbname = 'pos_menu'
	if @pccode <> '' and @pccode is not null
		if exists(select 1 from pos_update where rtrim(pccode) = rtrim(@pccode))
			update pos_update set update_date = getdate(),menu = @menu,pc_id = @pc_id where rtrim(pccode) = rtrim(@pccode)
		else
			insert pos_update select isnull(@pccode,''),getdate(),@pc_id,@menu
	end

;
--=======================pos_menu===================================
if exists(select 1 from sysobjects where name = 't_pos_menu_insert')
	drop trigger t_pos_menu_insert
;
create trigger t_pos_menu_insert
on pos_menu for insert
as
declare
	@lastnum			integer,
	@deptno			char(2),
	@name				char(8),
	@pccode			char(3),
	@sta				char(1),
	@paid				char(1),
	@tea_name		char(10),
	@empno			char(10),
	@empno1			char(10),
	@empno2			char(10),
	@bdate			datetime,
	@shift			char(1),
	@tableno			char(6),
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
	@amount			money,
	@pc_id			char(4)

select @menu = menu,@paid = paid, @sta=sta from inserted
if @paid = '0' and charindex(@sta ,'2456')>0
	begin
	select @bdate = bdate1 from sysdata
	begin tran
	save  tran p_gl_pos_new_menu
	update pos_menu set bdate = @bdate where menu = @menu
	select @sta = sta,@guest = guest,@deptno = deptno,@pccode = pccode,
			 @mode = mode,@dsc_rate = dsc_rate,
			 @serve_rate = serve_rate,@tax_rate = tax_rate,
			 @tea_rate = tea_rate,@lastnum = lastnum,@empno = empno3,
			 @shift = shift,@tableno = tableno,@pc_id = pc_id
	  from inserted
	insert pos_tblav (menu, tableno, bdate, shift, sta, empno, pcrec)
	select @menu, @tableno, @bdate, @shift, '7',isnull(empno3, ''),isnull(pcrec, '') from inserted


   if not exists(select 1 from pos_menu_bill where menu=@menu)
	    insert pos_menu_bill (menu, hline, inumber, hpage, hamount, dsc, srv, tax) select @menu, 0, 0, 0, 0, 0, 0, 0



	select @empno1 = empno1, @empno2 = empno2 from inserted

	select @tax_charge0 = 0,@tax_charge = 0,@serve_charge0 = 0,@serve_charge = 0

	select @lastnum = @lastnum + 1,@amount0 = round(@tea_rate * @guest,2),@amount = 0
	select @tea_name = name from pos_pccode where pccode = @pccode
	
	--================是否启用茶位费===============
	select @name = isnull(name,'茶位费') from pos_pccode where pccode = @pccode
	if (select teaup from pos_pccode where pccode = @pccode) = 'T'
		begin
		if @name = '' 
			select @name = '茶位费'
		if @guest > 0 and @tea_rate > 0
			exec p_gl_pos_create_discount	@deptno,@pccode,@mode,'X',@amount0,@dsc_rate,@result = @amount output
	
		insert pos_dish(menu,inumber,plucode,sort,id,name1,code,printid,number,price,amount,empno,bdate,date0,special)
					select @menu,@lastnum,'','',0,@name,'X',0,@guest,@tea_rate,@amount,@empno,@bdate,getdate(),'N'
		select @lastnum = @lastnum + 1
		end
	--==============================================
	exec p_gl_pos_create_tax @deptno,@pccode,@mode,'Y',@amount0,@amount,@tax_rate,@result0 = @tax_charge0 output,@result = @tax_charge output
	insert pos_dish(menu,inumber,plucode,sort,id,code,name1,printid,number,amount,empno,bdate,date0,special)
		select @menu,@lastnum,'','',0,'Y','附加费',0,1,@tax_charge,@empno,@bdate,getdate(),'N'

	select @lastnum = @lastnum + 1

	exec p_gl_pos_create_serve @deptno,@pccode,@mode,'Z',@amount0,@amount,@serve_rate,@result0 = @serve_charge0 output,@result = @serve_charge output
	insert pos_dish(menu,inumber,plucode,sort,id,code,name1,printid,number,amount,empno,bdate,date0,special)
		select @menu,@lastnum,'','',0,'Z','服务费',0,1,@serve_charge,@empno,@bdate,getdate(),'N'
	update pos_menu set lastnum = @lastnum,amount = @guest * @tea_rate + @serve_charge + @tax_charge
    where menu = @menu
---自动刷新的变化记录
	update table_update set update_date = getdate() where tbname = 'pos_menu'
	if @pccode <> '' and @pccode is not null
		if exists(select 1 from pos_update where rtrim(pccode) = rtrim(@pccode))
			update pos_update set update_date = getdate(),menu = @menu,pc_id = @pc_id where rtrim(pccode) = rtrim(@pccode)
		else
			insert pos_update select isnull(@pccode,''),getdate(),@pc_id,@menu 
	commit tran
	end

;


if exists(select 1 from sysobjects where name = 't_pos_menu_update')
	drop trigger t_pos_menu_update
;
create trigger t_pos_menu_update
on pos_menu for update
as
declare
	@paid						char(1),
	@deptno					char(2),
	@mode						char(3),
	@current_menu			char(10),
	@menu						char(10),
	@empno					char(10),
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
	@amount0					money,
	@dsc_rate				money,
	@charge					money,
	@pc_id					char(4),
	@selemark				char(13),
	@accnt					char(20),
	@guestid					char(20),
	@bdate					datetime,
	@ret						integer,
   @msg						char(60),
	@count					integer,
	@guest 					integer,
	@tea_rate				money,
	@tax_rate				money,
	@total_tax_charge 	money,
	@total_tax_charge0 	money,
	@serve_rate				money,
	@total_serve_charge 		money,
	@total_serve_charge0 	money,
	@sta						char(7)

if update(tableno) or update(bdate) or update(shift)
	update pos_tblav set tableno = a.tableno, bdate = a.bdate, shift = a.shift from inserted a, deleted b
	 where pos_tblav.menu = a.menu and b.menu = a.menu and pos_tblav.tableno = b.tableno and pos_tblav.inumber = 0


if update(paid)
	begin
	select @paid = paid, @current_menu = menu, @menu_remark = remark, @shift = shift, @empno = empno3,
		@pccode = pccode + 'A', @package = ' ' + pccode, @bdate = bdate, @pc_id = pc_id from inserted
	if @paid = '1'
		begin
		update pos_tblav set sta = '0' from inserted a
		 where pos_tblav.menu = a.menu and a.paid = '1' and pos_tblav.inumber = 0
		if exists(select 1 from pos_reserve a, inserted b where a.menu = b.menu)
			update pos_reserve set guest=a.guest, tables=a.tables, tableno=a.tableno, amount = a.amount from inserted a
				where pos_reserve.menu=a.menu
		end
	end

if update(sta)
	begin
	select @sta = sta, @menu = menu, @pccode = pccode, @charge = amount, @bdate = bdate, @shift = shift from inserted
	if @sta ='7' and @charge <> 0
		begin
		update pos_menu set amount = 0 where menu = @menu
		update pos_dish set amount = 0 where menu = @menu and rtrim(code) ='X'
		end
	if @sta = '7'
		begin
		update pos_tblav set sta = "0" where menu  = @menu
		end
	end
if update(sta) or update(tableno) or update(pcrec) or update(amount)
---自动刷新的变化记录
	begin
	update table_update set update_date = getdate() where tbname = 'pos_menu'
	select @pccode = pccode ,@pc_id = pc_id,@menu = menu from inserted
	if @pccode <> '' and @pccode is not null
		if exists(select 1 from pos_update where rtrim(pccode) = rtrim(@pccode))
			update pos_update set update_date = getdate(),menu = @menu,pc_id = @pc_id where rtrim(pccode) = rtrim(@pccode)
		else
			insert pos_update select isnull(@pccode,''),getdate(),@pc_id,@menu
	end
if update(tea_rate)
	begin
	select @deptno=deptno,@pccode=pccode,@mode=mode,@menu=menu,@pccode = pccode,@dsc_rate=dsc_rate,@tea_rate=tea_rate,@tax_rate=tax_rate,@serve_rate=serve_rate from inserted
	select @guest = number from pos_dish where menu = @menu and rtrim(ltrim(code)) = 'X'
	select @amount0 = round(@tea_rate * @guest,2)
	if (select teaup from pos_pccode where pccode = @pccode) = 'T'
		begin
		if @guest >= 0 and @tea_rate >= 0
		exec p_gl_pos_create_discount	@deptno,@pccode,@mode,'X',@amount0,@dsc_rate,@result = @amount output
		update pos_dish set number = @guest,price = @tea_rate, amount = isnull(@amount0, 0), dsc = isnull(@amount0 - @amount, 0) where menu = @menu and ltrim(rtrim(code)) ='X'

		exec p_gl_pos_create_tax @deptno,@pccode,@mode,'X',@amount0,@amount,@tax_rate,@result0 = @total_tax_charge0 output,@result = @total_tax_charge output
		update pos_dish set tax = isnull(@total_tax_charge, 0) where menu = @menu   and ltrim(rtrim(code)) ='X'
									 
		exec p_gl_pos_create_serve @deptno,@pccode,@mode,'X',@amount0,@amount,@serve_rate,@result0 = @total_serve_charge0 output,@result = @total_serve_charge output
		update pos_dish set srv = isnull(@total_serve_charge, 0) where menu = @menu  and ltrim(rtrim(code)) ='X'
		end
	end
if update(logmark)             -- pos_menu没有changed字段，修改后直接进入日志库
	begin
	insert into pos_menu_log select * from inserted
	select @menu = menu from inserted
	exec p_cq_newpos_menu_lgfl @menu
	end
;

if exists(select 1 from sysobjects where name = 't_pos_menu_delete')
	drop trigger t_pos_menu_delete
;
create trigger t_pos_menu_delete
on pos_menu for delete
as
delete pos_dish where menu in (select menu from deleted)
delete pos_tblav where menu in (select menu from deleted)

;

--=======================pos_dish===================================
if exists(select 1 from sysobjects where name = 't_pos_dish_update')
	drop trigger t_pos_dish_update
;
create trigger t_pos_dish_update
on pos_dish for update
as
declare
	@flag_old		char(20),
	@flag_new		char(20),
	@menu				char(10),
	@pccode			char(3),
	@pc_id			char(4)

select @flag_old = flag from deleted
select @flag_new = flag from inserted
select @menu = menu from inserted
select @pccode = pccode,@pc_id = pc_id from pos_menu where menu = @menu
if (substring(@flag_old,11,1) <> substring(@flag_new,11,1)) or (substring(@flag_old,12,1) <> substring(@flag_new,12,1))
	--==================表更新标记
	begin
	update table_update set update_date = getdate() where tbname = 'pos_menu'
	if @pccode <> '' and @pccode is not null
		if exists(select 1 from pos_update where rtrim(pccode) = rtrim(@pccode))
			update pos_update set update_date = getdate(),menu = @menu,pc_id = @pc_id where rtrim(pccode) = rtrim(@pccode)
		else
			insert pos_update select isnull(@pccode,''),getdate(),@pc_id,@menu
		end

;

--=======================pos_tblav===================================
if exists(select 1 from sysobjects where name = 't_pos_tblav_insert')
	drop trigger t_pos_tblav_insert
;
create trigger t_pos_tblav_insert
on pos_tblav for insert
as
declare
	
	@pccode			char(3),
	@menu				char(10),
	@date0			datetime,
	@pc_id			char(4)
	

select @menu = menu from inserted 
if charindex('R',@menu) > 0 
	select @pccode = pccode,@date0 = date0,@pc_id = '' from pos_reserve where resno = @menu
else
	select @pccode = pccode,@date0 = bdate,@pc_id = pc_id from pos_menu where menu = @menu

---
if  (select bdate1 from sysdata)=@date0
	begin
	update table_update set update_date = getdate() where tbname = 'pos_menu'
	if @pccode <> '' and @pccode is not null
		if exists(select 1 from pos_update where rtrim(pccode) = rtrim(@pccode)) 
			update pos_update set update_date = getdate(),menu = @menu,pc_id = @pc_id where rtrim(pccode) = rtrim(@pccode)
		else
			insert pos_update select isnull(@pccode,''),getdate(),@pc_id,@menu
	end
;

if exists(select 1 from sysobjects where name = 't_pos_tblav_delete')
	drop trigger t_pos_tblav_delete
;
create trigger t_pos_tblav_delete
on pos_tblav for delete
as
declare
	@pccode			char(3),
	@menu				char(10),
	@date0			datetime,
	@pc_id			char(4)
	

select @menu = min(menu) from deleted 

if rtrim(@menu) is null 
	return

if charindex('R',@menu) > 0 
	select @pccode = pccode,@date0 = date0,@pc_id = '' from pos_reserve where resno = @menu
else
	select @pccode = pccode,@date0 = bdate,@pc_id = pc_id from pos_menu where menu = @menu

---
if  (select bdate1 from sysdata)=@date0
	begin
	update table_update set update_date = getdate() where tbname = 'pos_menu'
	if @pccode <> '' and @pccode is not null
		if exists(select 1 from pos_update where rtrim(pccode) = rtrim(@pccode)) 
			update pos_update set update_date = getdate(),menu = @menu,pc_id = @pc_id where rtrim(pccode) = rtrim(@pccode)
		else
			insert pos_update select isnull(@pccode,''),getdate(),@pc_id,@menu
	end
;

