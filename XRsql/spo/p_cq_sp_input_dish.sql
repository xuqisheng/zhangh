drop procedure p_cq_sp_input_dish;
create proc p_cq_sp_input_dish
	@menu			char(10),
	@empno		char(10),
	@id			int,						              
	@plu_number	money,      		             
	@plu_price	money,      		             
	@flag			char(10),                                  
	@remark		char(15),
	@name1		char(20),
	@pc_id		char(8),
	@empno1		char(20),
	@dish_add	varchar(100),
	@places		char(255),
	@plaavmenu	char(10),
	@plaavinumber int                                         
as
declare
	@ret			integer  ,
	@msg			char(60) ,
	@bdate		datetime,
	@p_mode		char(1)	,
	@mdate		datetime,
	@mshift		char(1),
	@deptno		char(2)	,
	@pccode		char(3)	,
	@mode			char(3),
	@code			char(6),
	@sort			char(4),
	@code1		char(10),
	@plucode		char(2),
	@inumber		integer	,
	@printid		integer	,
	@name2		char(30)	,
	@unit			char(4)	,
	@amount0		money	,
	@amount		money	,
	@number		money	,
	@number1		money	,

	@dsc_rate		money,
	@serve_rate		money,
	@tax_rate		money,

	@serve_charge0	money,
	@tax_charge0	money,
	@serve_charge	money,
	@tax_charge		money,
	@charge			money,

	@timecode		char(3),
	@tableno			char(4),
	@times			integer,
	@minute			integer,
	@minute1			integer,
	@minute2			integer,

	@oprice				money,
	@special				char(1),
	@sta					char(1),
	@timestamp_old		varbinary(8),
	@timestamp_new		varbinary(8),
	@reason3			char(2),
	@cookid			char(2),
	@kitchen			char(5),
	@drinkid			integer,
	@dinnerid		integer,
	@hx				int, 
	@line 			int,
	@cur_code 		char(6),
	@cur_name1 		char(20),
	@cur_name2 		char(30),
  	@cur_unit 		char(4),
	@cur_number 	money,
	@cur_amount0 	money,
  	@cur_special 	char(1),
	@cur_cont 		char(1),
	@cur_cookid 	char(2),
  	@cur_kitchen 	char(5),
	@cur_plucode 	char(2),
	@cur_sort 		char(4),
	@cur_id 			int,
	@mx_id 			integer

select @hx = 0

select @bdate  = bdate1 from sysdata
select @p_mode = value  from sysoption where catalog = "sp_dish" and item = "p_mode"
select @reason3 = ''

begin tran
save  tran p_hry_pos_input_dish_s1
select @timestamp_old = timestamp from sp_menu where menu = @menu
update sp_menu set pc_id = @pc_id where menu = @menu
select @mdate = bdate,@mshift = shift,@deptno = deptno,@pccode = pccode,@inumber = lastnum + 1,@sta = sta,
		 @mode = mode,@serve_rate = serve_rate,@tax_rate = tax_rate,@dsc_rate = dsc_rate
  from sp_menu where menu = @menu

if @@rowcount = 0
	select @ret = 1,@msg = "菜单“" + @menu + "”已不存在或已销单"
else if @sta ='3'
	select @ret = 1,@msg = "菜单“" + @menu + "”已被其他收银员结帐"

else
	begin
	select @name1 = rtrim(@name1)
	select @name1 = isnull(@name1,name1),@name2 = isnull(name2,''),@unit = isnull(unit,''),@oprice = price,@special=special,
		@plucode = plucode, @sort = sort, @code1 = sort + code,@code = code
	  from pos_plu where id = @id
	if @@rowcount = 0
		begin
		select @ret = 1,@msg = "菜号“" + rtrim(@code) + "”已不存在"
		goto gout
		end       
                                                                                                                                                                                                                                                                                                                                                                                                                                                           
	select @serve_charge0 = 0,@serve_charge = 0,@tax_charge0 = 0,@tax_charge = 0,@charge = 0
	select @number = @plu_number
	select @amount0 = round(@plu_price * @number,2)
	if @special = 'T'
		select @amount = @amount0,@amount0 = 0
	else if @special = 'X'
		select @amount = @amount0,@reason3 = isnull(substring(@remark,1,2),'')
	else
		begin
		if @special = 'S'                 
			begin
			select @timecode = timecode,@tableno = tableno from pos_plu where id = @id
			select @plu_number = count(1) from pos_time_code where timecode = @timecode
			if @plu_number = 0
				begin
				select @ret = 1,@msg = "时段码“" + rtrim(@timecode) + "”未定义"
				goto gout
				end
			                               
                                                                       
                                                                                                                                                                                                                                     
//			select @minute = max(minute) from pos_time where timecode = @timecode
//			                             
//			select @amount0 = 0, @amount = 0
//			update pos_tblav set end_time = dateadd(minute,@minute,begin_time) where menu = @menu and tableno = @tableno and inumber = @inumber
//			select @remark = convert(char(5),begin_time,8) + '～' + convert(char(5),end_time,8) from pos_tblav where menu = @menu and tableno = @tableno and inumber = @inumber
			end

		exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@code1,@amount0,@dsc_rate,@result = @amount output


		exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@code1,@amount0,@amount,@serve_rate,@result0 = @serve_charge0 output,@result = @serve_charge output


		exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@code1,@amount0,@amount,@tax_rate,@result0 = @tax_charge0 output,@result = @tax_charge output
		end
	select @printid = isnull(max(printid)+1,1) from sp_dish 
	insert sp_dish(menu,inumber,plucode,sort,code,id,printid,name1,name2,unit,number,amount,empno,bdate,remark,special,id_cancel,id_master,reason,empno1)
		select @menu,@inumber,@plucode,@sort,@code,@id,@printid,@name1,@name2,@unit,@number,@amount0,@empno,@bdate,@remark,@special,0,0,@reason3,@empno1
	              
	if rtrim(@dish_add) <> '' and not rtrim(@dish_add) is null
		insert pos_dish_add(menu, inumber, descript) values(@menu, @inumber, rtrim(@dish_add))

	if charindex(@special,'XT') = 0            
		begin
		                        
		--select @code1 = @code
		exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@code1,@amount0,@dsc_rate,@result = @amount output
		exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@code1,@amount0,@amount,@serve_rate,@result0 = @serve_charge0 output,@result = @serve_charge output
		exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@code1,@amount0,@amount,@tax_rate,@result0 = @tax_charge0 output,@result = @tax_charge output
	
		update sp_dish set dsc =  amount - @amount 	where menu = @menu and inumber = @inumber
		update sp_dish set srv =  @serve_charge 	 where menu = @menu and inumber = @inumber
		update sp_dish set tax =  @tax_charge 	 where menu = @menu and inumber = @inumber
	
		update sp_dish set amount = amount + @serve_charge0, dsc = dsc + @serve_charge0 - @serve_charge
		 where menu = @menu and code = "Z"
		update sp_dish set amount = amount + @tax_charge0, dsc = dsc + @tax_charge0 - @tax_charge
		 where menu = @menu and code = "Y"
		end

	select @mx_id = @inumber

	if charindex('M', upper(@flag)) > 0                                                
	begin

		declare std_mx_cur cursor for
			select a.code,a.name1,a.name2,a.unit,a.number,a.special,a.id
				from pos_dish_pcid a,pos_plu b where pc_id = @pc_id and  a.master_id = b.id
		open std_mx_cur
		fetch std_mx_cur into @cur_code,@cur_name1,@cur_name2,@cur_unit,@cur_number,@cur_special,@cur_id
		while @@sqlstatus = 0
		begin
			select @cur_plucode = plucode,@cur_sort = sort from pos_plu where id = @cur_id
			select @mx_id = @mx_id + 1
			select @printid = isnull(max(printid)+1,1) from sp_dish 
			insert sp_dish(menu,inumber,plucode,sort,id,printid,code,name1,name2,unit,number,amount,empno,bdate,remark,special,sta,id_cancel,id_master,reason,empno1)
				select @menu,@mx_id,@plucode,@sort,@id,@printid,@cur_code,@cur_name1,isnull(@cur_name2,''),isnull(@cur_unit,''),@cur_number,@cur_amount0,@empno,@bdate,'',@cur_special,'M',0,@id,'',@empno1
			fetch std_mx_cur into @cur_code,@cur_name1,@cur_name2,@cur_unit,@cur_number,@cur_special,@cur_id
		end
		close std_mx_cur
		deallocate cursor std_mx_cur
	end

	delete pos_dish_pcid where pc_id = @pc_id

	insert pos_empnoav (empno, menu, bdate, shift, sta, inumber)
		select @empno1,@menu, @bdate, @mshift, '1', @inumber
                   
	update pos_tblav set amount = isnull((select sum(amount) from sp_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0 )
		+ (select sum(srv) from sp_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
		+ (select sum(tax) from sp_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
		- (select sum(dsc) from sp_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0), 0)
		from pos_tblav a where a.menu = @menu  and sta ='7'


update sp_menu set srv = (select sum(srv) from sp_dish where menu = @menu and charindex(sta,'03579')>0)

	where menu = @menu

update sp_menu set tax = (select sum(tax) from sp_dish where menu = @menu and charindex(sta,'03579')>0)

	where menu = @menu

update sp_menu set dsc = (select sum(dsc) from sp_dish where menu = @menu and charindex(sta,'03579')>0)

	where menu = @menu

update sp_menu set amount0 = (select sum(amount) from sp_dish where menu = @menu and charindex(sta,'03579')>0)

	where menu = @menu

update sp_menu set amount = (select sum(amount) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)

	+ (select sum(srv) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)

	+ (select sum(tax) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)

	- (select sum(dsc) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)

	where menu = @menu

update sp_menu set lastnum = @mx_id + 1 where menu = @menu

update pos_tblav set amount = isnull((select sum(amount) from sp_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0 )

	+ (select sum(srv) from sp_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)

	+ (select sum(tax) from sp_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)

	- (select sum(dsc) from sp_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0), 0)

	from pos_tblav a where a.menu = @menu  and sta ='7'



//	update sp_menu set amount = amount + @amount + @serve_charge + @tax_charge,lastnum = @mx_id
//	 where menu = @menu
	select @charge = amount,@timestamp_new = timestamp from sp_menu where menu = @menu
	update sp_plaav set used = 0 ,packcode = '' ,packid = 0,dishtype = 'T',amount = @amount0,dnumber=@inumber,
					empno = @empno ,logdate = getdate(),sp_menu = @menu
						where menu = @plaavmenu and inumber = @plaavinumber
	update sp_plaav set sp_menu = @menu where charindex(menu+rtrim(convert(char,inumber)),@places) > 0 and 
			(sp_menu = '' or sp_menu is null)
//	update sp_plaav set dishtype = 'T', dnumber = @id,amount = @plu_price where menu = @menu and inumber = @plaavinumber
	select @ret = 0,@msg = "成功"
            
//	update pos_assess set number1 = number1 + @plu_number where id = @id
                
	--exec p_cyj_bar_pos_sale @menu, @id
	end

gout:
if @ret <> 0 
	rollback tran p_hry_pos_input_dish_s1
else
	if @hx = 1 
		select @msg = 'hx' + convert(char(4), @line)
commit tran

select @ret,@msg,@plu_price,@inumber
return 0

;