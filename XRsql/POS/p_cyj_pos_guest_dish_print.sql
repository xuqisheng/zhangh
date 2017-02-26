drop proc p_cyj_pos_guest_dish_print;
create proc p_cyj_pos_guest_dish_print
	@type			char(1),
	@menu			char(10),
	@pc_id		char(4),
	@printer		char(10),
	@remark		char(100),
   @inumber     int,
   @pnumber     int
as
-- 生成早餐勾兑帐单打印
declare
	@ret			integer,
	@msg			char(60),
   @tableno    char(5),
	@dinput		datetime,
	@bdate		datetime,
   @changed    char(1),
   @cook       char(100),
   @printid    integer

select @ret=0, @msg='ok',@bdate=bdate1 from sysdata
select @type = upper(@type)
if charindex(@type,'GQPSUC') > 0
	begin
	if not exists(select 1 from pos_menu where menu=@menu )
	begin
		select @ret=1, @msg='该菜单不存在，或者已经结账 !'
		select @ret, @msg
		return 1
	end
if @type ='Q'
		begin
		select @changed = 'R'
		select @cook = @remark
		end
if @type='S'
		begin
		select @changed = 'R'
		select @cook = @remark
		end
if @type='C'
		begin
		select @changed = 'R'
		select @cook = @remark
		end
if @type ='U'
		begin
		select @changed = 'R'
		select @cook = "客人已到，请上菜"
		end

if @type ='P'
		begin
		select @changed = 'P'
		select @cook = "克"
		end
 select @tableno = tableno from pos_menu where menu = @menu
if @type <>'P'
 select @printid = max(printid) from pos_dish where menu =@menu
else
  begin
   select @printid = isnull(min(printid),0) from pos_dishcard
    select @printid = @printid - 1
  end
 select @dinput= getdate() , @printer = rtrim (@printer)

if @type ='G'
		begin
		select @changed = 'G'
		select @cook = " "
   update pos_dishcard set changed = 'G',p_number = 1,printer = @printer+'#',printer1 = @printer+'#' where menu = @menu and changed1 = 'G'

      end
else
  begin

   delete pos_dishcard where printid= @printid and changed1 = @changed

   insert pos_dishcard(menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,   price,number,p_number,p_number1, empno, date,  changed,changed1,times,pc_id, printer,printer1,bdate, cook ,p_sort,siteno)
				 select @menu,@tableno,@printid,   0, 0,'' ,''  ,''   ,''   ,  '',       0,     0,       1,        1, ''   ,@dinput,@changed,@changed,   0 ,@pc_id, @printer,@printer,@bdate,@cook,'',''

end
end

select @ret, @msg
;