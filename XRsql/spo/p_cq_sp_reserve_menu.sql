drop procedure p_cq_sp_reserve_menu;


create proc p_cq_sp_reserve_menu
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
   @tag2          char(2)

select @pccode = pccode, @shift  = shift,@ls_tableno=tableno from sp_reserve where resno = @resno
select @il_inumber=max(isnull(inumber,0)) from pos_order where pc_id=@pc_id
select @il_inumber=isnull(@il_inumber,0)
begin tran
save  tran p_hry_sp_reserve_menu_s1
exec @ret = p_GetAccnt1 'POS', @menu output
if @shift = "1"
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_rate = tea_charge1 from pos_pccode where pccode = @pccode
else if @shift = "2"
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_rate = tea_charge2 from pos_pccode where pccode = @pccode
else if @shift = "3"
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_rate = tea_charge3 from pos_pccode where pccode = @pccode
else if @shift = "4"
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_rate= tea_charge4 from pos_pccode where pccode = @pccode
else
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_rate = tea_charge5 from pos_pccode where pccode = @pccode

insert sp_menu (tag, menu, tables, guest, bdate, shift, deptno, pccode,posno, tableno, mode, tea_rate, serve_rate, tax_rate, empno3, sta, paid, cusno, haccnt, tranlog,saleid, pc_id, remark)
	select tag, @menu, tables, guest, bdate, shift, deptno, pccode, @posno, tableno, mode, @tea_rate, @serve_rate, @tax_rate, @empno, "2","0", cusno, haccnt, tranlog, saleid,@pc_id, rtrim(substring(unit,1, 35)) + '-Ô¤¶¨'
	from sp_reserve where resno = @resno
if @@rowcount <> 1 
	select @ret = 1
        
select @tag1=min(code) from pos_tag1 
select @tag2=min(code) from pos_tag2
insert pos_menu_tag (menu,tag1,tag2) select @menu,@tag1,@tag2
select @inumber=max(isnull(inumber,0)) from pos_hxsale where menu=@menu
select @inumber = isnull(@inumber,0)+200
declare c_cur cursor for select id,number from pos_reserve_plu where resno = @resno
open c_cur
fetch c_cur into @id,@numb
while @@sqlstatus = 0
   begin
   select @il_inumber = @il_inumber+1
   insert pos_order (pc_id,menu,inumber,orderno,id,sort,code,unit,price,number,amount,name1,name2,sta,special,empno1,empno2,inumber1,tableno,siteno,cook,remark,flag) 
     select @pc_id,@menu,@il_inumber,'',id,sort,code,unit,price,@numb,price,name1,name2,'0',special,'','',0,@ls_tableno,'','','', flag from pos_plu where id = @id
   insert pos_hxsale (bdate,menu,inumber,hxcode,hxname,price,weight,onumber)
     select getdate(),@menu,@inumber,a.hxcode,a.name1,b.price,a.weight*@numb,@il_inumber from pos_hxcode_link a,pos_hxcode b where a.id=@id and a.hxcode=b.code
   select @inumber = @inumber+1  
   fetch c_cur into @id,@numb
   end
close c_cur
delete pos_reserve_plu where resno=@resno 

update pos_dish_pcid set menu = @menu where menu = @resno --add by tcr 2004.1.13   
update sp_reserve set sta = "7", empno = @empno, date = getdate(), menu=@menu where resno = @resno
delete pos_tblav where menu = @menu
update pos_tblav set menu = @menu, sta = '7' where menu = @resno 
if @ret <> 0 
	rollback tran p_hry_sp_reserve_menu_s1
commit tran p_hry_sp_reserve_menu_s1
return 0;
