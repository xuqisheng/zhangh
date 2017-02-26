
if exists(select 1 from sysobjects where name = 'p_cyj_pos_sale' and type = 'P')
	drop procedure p_cyj_pos_sale;
create proc  p_cyj_pos_sale
	@menu			char(10),
	@inumber				int
as
---------------------------------------------------------------------------------------------
--
--		吧台物品对应菜销售处理，出库，销售单
--	  		 注意菜品物品单位不一样的比率问题, 以及菜品物品一对多问题
--			 注意是通过菜品还是通过配菜销售
--
----------------------------------------------------------------------------------------------
declare
	@pccode		char(3),
	@barcode		char(3),
	@number		money,					-- 菜的数量
	@logdate		datetime,
	@bdate		datetime,
	@store_id	int,
	@plu_id		int,
	@pinumber	int,						-- pos_dish.pinumber = pos_price.inumber
	@empno		char(10),
	@type			char(1)					-- '0' 菜品销售, '1' 配菜

begin tran
save  tran t_sale
select @bdate = bdate1 from sysdata
select @pccode = pccode from pos_menu where menu = @menu
select @plu_id = id, @number = number, @pinumber = pinumber, @empno = empno, @logdate = date0 from pos_dish where menu = @menu and inumber = @inumber

select @barcode =  code from pos_store where charindex(@pccode, pccodes)>0
select @type ='0'
insert into pos_sale(type,bdate,menu,inumber,id,storecode,pccode,condid,descript,number,empno,logdate,pnumb,amount)
	select @type,@bdate,@menu,@inumber,@plu_id,@barcode,@pccode,b.condid,b.descript,@number * a.number,@empno,@logdate,@pinumber,@number * a.number * b.price from pos_pldef_price a, pos_condst b
	where a.condid = b.condid and a.id = @plu_id and a.inumber = @pinumber

update pos_store_store set number = isnull(a.number, 0) - @number * b.number
	from pos_store_store a, pos_pldef_price b where a.condid = b.condid and b.id = @plu_id and b.inumber = @pinumber and  a.storecode = @barcode
insert into pos_store_store(storecode, condid, descript, number) 
	select @barcode, a.condid, b.descript, -@number * a.number from pos_pldef_price a, pos_condst b where a.condid = b.condid and a.id = @plu_id and a.inumber = @pinumber and a.condid not in(select condid from pos_store_store where storecode = @barcode)

-- 从配料pos_condst里配菜
select @type = '1'
if exists(select 1 from pos_order_cook a, pos_condgp b, pos_condst c where a.menu = @menu and inumber = @inumber and a.sta ='0' and  a.type ='1' and a.amount <> 0 and a.id = c.condid and charindex(b.code, c.condgp)>0 and b.dish_use = 'F')
	begin
	insert into pos_sale(type,bdate,menu,inumber,id,storecode,pccode,condid,descript,number,empno,logdate,amount)
		select @type,@bdate,@menu,@inumber,c.id,@barcode,@pccode,b.condid,b.descript,sum(c.number),@empno,@logdate,sum(c.number * b.price)  from pos_condst b, pos_order_cook c
		where b.condid = c.id and c.menu = @menu and c.inumber = @inumber and c.sta ='0' and c.type ='1' and c.amount <> 0
		group by c.id,b.condid,b.descript
		order by c.id,b.condid,b.descript
	end

commit  t_sale;
