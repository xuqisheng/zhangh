if exists(select 1 from sysobjects where name='p_cyj_pos_input_dishcard' and type='P')
   drop procedure p_cyj_pos_input_dishcard;

create proc p_cyj_pos_input_dishcard
	@menu			char(10),
	@empno		char(10),
	@pc_id		char(4)
as
------------------------------------------------------------------------------------------------------------
--
--		点菜后，dish 生成厨房打印数据
--
------------------------------------------------------------------------------------------------------------
declare
	@ret			integer,
	@ret1			integer,
	@msg			char(60),
	@dinput		datetime,
   @pccode     char(6),
	@kitchens	char(20),
	@printer		char(3),
	@prn_code	char(3),
	@prn_des		char(40),
	@inumber			int, 
	@id				int, 
	@tag			char(1),
	@sta			char(1),
	@flag			char(10),
	@print_id	int, 
	@bdate		datetime

select @ret=0, @ret1=0, @msg='ok',@bdate=bdate1 from sysdata

if not exists(select 1 from pos_menu where menu=@menu and paid='0')
begin
	select @ret=1, @msg='该菜单不存在，或者已经结账 !'
	select @ret, @msg
	return 1
end

if not exists(select 1 from pos_dish where menu=@menu and sta<'A' and inumber not in (select inumber from pos_dishcard where menu=@menu))
begin
	select @ret=1, @msg='当前没有需要传送的点菜 !'
	select @ret, @msg
	return 1
end

select @dinput= getdate()
select @pccode = pccode from pos_menu where menu=@menu
--cq modify (get kitchens from pos_dish)
create table #dish
(
	menu			char(10) 	not null,
	inumber		int		 	not null,
	id				int			not null,
	flag			char(10),
	kitchen		char(30)		
)
-- 要打印的dish，包括套菜明细
insert into #dish select menu,inumber,id,flag,kitchen
		from pos_dish where menu=@menu  
			and inumber not in (select inumber from pos_dishcard where menu=@menu)
			  and code <'X' and kitchen <> '' and kitchen is not null  order by inumber

begin tran
save tran sss

declare c_card cursor for select inumber,id,flag,kitchen from #dish order by inumber
open c_card
fetch c_card into @inumber, @id, @flag,@kitchens
while @@sqlstatus = 0 
begin
	select @tag = 'F'
	--exec @ret = p_cyj_pos_get_kitchen @menu, @id, @kitchens output
	if @ret <> 0  or  @kitchens = ''         -- 没指定厨房,就不打
		select @kitchens = '', @tag = '0', @ret =0
	else
		begin
		select @prn_code = ''
		select @prn_code = min(a.code) from pos_printer a, pos_kitchen b where a.code = b.printer1 and charindex(rtrim(b.code), @kitchens) >0 and a.sta <>'0'
		if @prn_code <> '' and @prn_code is not null
			begin
			select @sta = sta, @prn_des = descript from pos_printer where code = @prn_code
			select @ret1 = 1, @msg = rtrim(@prn_des) +'不正常,原因:' + descript from basecode where cat='pos_print_sta' and code = @sta
			insert gdsmsg select '1'
			end
		insert pos_dishcard(menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,   price,       number, empno, date,  changed,times,pc_id, kitchens,bdate, cook )
					 select   @menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price, number, @empno,@dinput,@tag,  0,   @pc_id, @kitchens,@bdate, cook
				from pos_dish where menu=@menu and inumber = @inumber 
		end

	-- dish设置送厨房标志
	if rtrim(@flag) = '' or rtrim(@flag) = null 
		select @flag = 'C'
	else 	if charindex('C', upper(@flag)) = 0 
		select @flag = rtrim(@flag) + 'C'
	update pos_dish set flag = @flag where menu = @menu and inumber = @inumber

	fetch c_card into @inumber, @id, @flag,@kitchens
end
close c_card 
deallocate cursor c_card

if @ret=2 
   select @ret=0
         

if @ret <> 0
	rollback tran sss
commit
if @ret = 1
   select @msg='菜单不存在'

if @ret1 <> 0 and @ret = 0 
	select @ret = @ret1

select @ret, @msg
return @ret;

