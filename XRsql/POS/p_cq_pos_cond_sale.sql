if exists(select 1 from sysobjects where name = 'p_cq_pos_cond_sale' and type = 'P')
	drop proc p_cq_pos_cond_sale;

create proc p_cq_pos_cond_sale
	@menu			char(10),
	@menuid		integer,
	@id			integer,
	@pinumber	integer
as
declare
		@empno		char(10),
		@bdate		datetime,
		@number		integer,
		@amount		money
		

select @empno = empno ,@bdate = bdate,@number = number,@amount = amount from pos_dish where menu = @menu and inumber = @menuid
insert pos_sale
	select @menu,@menuid,a.pccode,a.id,@number,@amount,a.inumber,a.condid,b.unit,b.descript,@number*a.number,
		@number*a.number*b.price,@empno,@bdate,getdate()
		from pos_pldef_price a ,pos_condst b where a.condid = b.condid and a.id = @id and a.inumber = @pinumber
return 0
;


	