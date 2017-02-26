drop  proc p_cyj_pos_reserve_menu;
create proc p_cyj_pos_reserve_menu
	@resno		char(10),
	@posno		char(2),
	@empno		char(10),
	@pc_id		char(4)
as
declare
	@menu				char(10),
	@pccode			char(3),
	@shift			char(1),
	@serve_rate		money,
	@tax_rate		money,
	@tea_rate		money,
	@ret				integer,
   @ls_sort       char(4),
   @ls_code       char(6),
   @ls_name1      char(30),
   @ls_name2      char(50),
   @ls_unit       char(4),
   @ls_special    char(1),
   @ld_price      money,
   @ls_flag       char(10),
   @ls_tableno    char(6),
   @il_inumber    integer,
   @id            integer,
   @inumber       integer,
   @numb          integer,
   @tag1          char(2),
   @tag2          char(2),
   @more	         char(1)               -- Y 预定多场

select @pccode = pccode, @shift  = shift,@ls_tableno=tableno, @more = more from pos_reserve where resno = @resno
select @il_inumber=max(isnull(inumber,0)) from pos_order where pc_id=@pc_id
select @il_inumber=isnull(@il_inumber,0)
begin tran
save  tran p_cyj_reserve_s1
exec @ret = p_GetAccnt1 'POS', @menu output
if @shift = "1"
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_rate = tea_charge1 from pos_pccode where pccode = @pccode
else if @shift = "2"
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_rate = tea_charge2 from pos_pccode where pccode = @pccode
else if @shift = "3"
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_rate = tea_charge3 from pos_pccode where pccode = @pccode
else if @shift = "4"
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_rate = tea_charge4 from pos_pccode where pccode = @pccode
else
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_rate = tea_charge5 from pos_pccode where pccode = @pccode

insert pos_menu (tag, menu, tables, guest, bdate, shift, deptno, pccode, posno, tableno, mode, tea_rate, serve_rate, tax_rate, empno3, sta, paid, cusno, haccnt,accnt,saleid, pc_id, remark, resno)
	select tag, @menu, tables, guest, bdate, shift, deptno, pccode, @posno, tableno, mode, @tea_rate, @serve_rate, @tax_rate, @empno, "2", "0", cusno, haccnt,accnt, saleid,@pc_id, rtrim(substring(unit,1, 35)) + '-预定', @resno
	from pos_reserve where resno = @resno
if @@rowcount <> 1
	select @ret = 1

//预订点菜转为正式
update pos_order set menu = @menu where menu = @resno
                                                                            

if @more <> 'Y'     -- 只预定一场
	update pos_reserve set sta = "7", empno = @empno, date = getdate(), menu=@menu where resno = @resno

delete pos_tblav where menu = @menu
update pos_tblav set menu = @menu, sta = '7' where menu = @resno

if @ret <> 0
	rollback tran p_cyj_reserve_s1
commit tran p_cyj_reserve_s1
return 0

;