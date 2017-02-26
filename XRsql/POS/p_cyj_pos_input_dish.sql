/*-----------------------------------------------------------------------------*/
//
//	������ϸ����, PDA ������øĹ��̣�����һҲ����
//
// ����� ȱ�� !  2001/06/17   		��Ǻ���
// ��ˮ�ɿ��     2002/05/20   
// �Ӳ���@pinumberָ���˼���ţ��ɱ�����        09/04/22
/*-----------------------------------------------------------------------------*/


if object_id('p_cyj_pos_input_dish') is not null
	drop proc p_cyj_pos_input_dish
;
create proc p_cyj_pos_input_dish
	@menu			char(10),
	@empno		char(10),
	@id			int,						//   ��Ψһ��
	@plu_number	money,      		   //   ����
	@plu_price	money,      		   //   ����
	@amount0		money,      		   //   ���
	@flag			char(10),            //   ����̬ M -- �ײ�
	@remark		char(15),
	@name1		char(20),
	@pc_id		char(8),
	@empno1		char(20),
	@dish_add	varchar(100),        //   �����������������Ҫ���  
	@unit			char(4),
	@pinumber	integer   = 1        //   pos_price.inumber �ɱ���
as
declare
	@ret			integer  ,
	@msg			char(60) ,
	@bdate		datetime,
	@p_mode		char(1)	,
	@mdate		datetime,
	@mshift		char(1),
	@deptno		char(2)	,
	@pccode		char(10)	,
	@mode			char(3),
	@code			char(6),
	@sort			char(4),
	@code1		char(10),
	@plucode		char(2),
	@inumber		integer	,
	@printid		integer	,
	@name2		char(30)	,
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
	@times			integer,
	@minute			integer,
	@minute1			integer,
	@minute2			integer,

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
	@mx_id 			integer,
	@cost				money         -- ���۳ɱ�

select @hx = 0

select @bdate  = bdate1 from sysdata
select @p_mode = value  from sysoption where catalog = "pos_dish" and item = "p_mode"
select @reason3 = ''

begin tran
save  tran p_hry_pos_input_dish_s1
select @timestamp_old = timestamp from pos_menu where menu = @menu
update pos_menu set pc_id = @pc_id where menu = @menu
select @mdate = bdate,@mshift = shift,@deptno = deptno,@pccode = pccode,@inumber = lastnum + 1,@sta = sta,
		 @mode = mode,@serve_rate = serve_rate,@tax_rate = tax_rate,@dsc_rate = dsc_rate
  from pos_menu where menu = @menu

if @@rowcount = 0
	select @ret = 1,@msg = "�˵���" + @menu + "���Ѳ����ڻ�������"
else if @sta ='3'
	select @ret = 1,@msg = "�˵���" + @menu + "���ѱ���������Ա����"
else if @sta ='7'
	select @ret = 1,@msg = "�˵���" + @menu + "���ѱ�ɾ��"

else
	begin
	select @name1 = rtrim(@name1)
	select @cost = cost from pos_price where id = @id and inumber = @pinumber
	select @name1 = isnull(@name1,name1),@name2 = isnull(name2,''),@special=special,
		@plucode = plucode, @sort = sort, @code = code
	  from pos_plu where id = @id
	if @@rowcount = 0
		begin
		select @name1 = isnull(@name1,name1),@name2 = isnull(name2,''),@special=special
		  from pos_plu where code = @code
		if @@rowcount = 0
			begin
			select @ret = 1,@msg = "�˺š�" + rtrim(@code) + "���Ѳ�����"
			goto gout
			end
		end	
	// ���嵥��pos_assess�м�¼�����ж�. �ڿͻ�����ʾ�������ڴ�ǿ��ִֹͣ��
	/*
	select @number = number, @number1 = number1 from pos_assess where bdate = @bdate and id = @id 
	if @@rowcount = 1
		if @plu_number >= @number - @number1		// ��������
			begin
			select @ret = 1,@msg = @name1 + '---' + rtrim(@code) + 'ֻ��' + convert(char(8), @number - @number1)+'�ݣ��Ѳ�����!'
			goto gout
			end
	*/
	// ԭ�������� -- gds--------------------------------->>>

	declare @minid int
	select @minid=isnull(min(id),0) from pos_dish where menu=@menu and code=@code
	if @minid > 0
		select @name1=name1,@name2=@name2 from pos_dish where menu=@menu and code=@code
	// ԭ�������� -- gds--------------------------------->>>

	select @serve_charge0 = 0,@serve_charge = 0,@tax_charge0 = 0,@tax_charge = 0,@charge = 0
	select @number = @plu_number
	if @special = 'T'
		select @amount = @amount0,@amount0 = 0
	else if @special = 'X'
		select @amount = @amount0,@reason3 = isnull(substring(@remark,1,2),'')
	select @printid = isnull(max(printid)+1,1) from pos_dish 
	insert pos_dish(menu,inumber,plucode,sort,code,id,printid,name1,name2,unit,number,amount,empno,bdate,remark,special,id_cancel,id_master,reason,empno1,price,pinumber,pamount)
		select @menu,@inumber,@plucode,@sort,@code,@id,@printid,@name1,@name2,@unit,@number,@amount0,@empno,@bdate,@remark,@special,0,0,@reason3,@empno1,@plu_price,@pinumber,isnull(@number*@cost,0)
//	exec p_cyj_bar_pos_sale @menu, @inumber
//	// ����������
//	if rtrim(@dish_add) <> '' and not rtrim(@dish_add) is null
//		insert pos_dish_add(menu, inumber, descript) values(@menu, @inumber, rtrim(@dish_add))
	--FHB Modified At 20090316
	exec p_cyj_pos_sale  @menu,@inumber
	if charindex(@special,'XT') = 0            
		begin
		/*�ۿۣ�����ѣ�˰����*/
		select @code1 = @sort + @code
		exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@code1,@amount0,@dsc_rate,@result = @amount output
		exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@code1,@amount0,@amount,@serve_rate,@result0 = @serve_charge0 output,@result = @serve_charge output
		exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@code1,@amount0,@amount,@tax_rate,@result0 = @tax_charge0 output,@result = @tax_charge output
	
		update pos_dish set dsc =  amount - @amount 	where menu = @menu and inumber = @inumber
		update pos_dish set srv =  @serve_charge 	 where menu = @menu and inumber = @inumber
		update pos_dish set tax =  @tax_charge 	 where menu = @menu and inumber = @inumber
	
		update pos_dish set amount = amount + @serve_charge0, dsc = dsc + @serve_charge0 - @serve_charge
		 where menu = @menu and code = "Z"
		update pos_dish set amount = amount + @tax_charge0, dsc = dsc + @tax_charge0 - @tax_charge
		 where menu = @menu and code = "Y"
		end

	select @mx_id = @inumber

//	if charindex('M', upper(@flag)) > 0       //  ��Щ�ײ˵���������û���壬Ҫ��ʱ����
//	begin
//
//		declare std_mx_cur cursor for
//			select a.code,a.name1,a.name2,a.unit,a.number,a.special,a.id,a.amount
//				from pos_dish_pcid a,pos_plu b where pc_id = @pc_id and  a.master_id = b.id
//		open std_mx_cur
//		fetch std_mx_cur into @cur_code,@cur_name1,@cur_name2,@cur_unit,@cur_number,@cur_special,@cur_id,@cur_amount0
//		while @@sqlstatus = 0
//		begin
//			select @cur_plucode = plucode,@cur_sort = sort from pos_plu where id = @cur_id
//			select @mx_id = @mx_id + 1
//			select @printid = isnull(max(printid)+1,1) from pos_dish 
//			insert pos_dish(menu,inumber,plucode,sort,id,printid,code,name1,name2,unit,number,amount,empno,bdate,remark,special,sta,id_cancel,id_master,reason,empno1)
//				select @menu,@mx_id,@plucode,@sort,@id,@printid,@cur_code,@cur_name1,isnull(@cur_name2,''),isnull(@cur_unit,''),@cur_number,isnull(@cur_amount0,0),@empno,@bdate,'',isnull(@cur_special,''),'M',0,@inumber,'',@empno1 //cq
//			exec p_cyj_bar_pos_sale @menu, @mx_id
//			fetch std_mx_cur into @cur_code,@cur_name1,@cur_name2,@cur_unit,@cur_number,@cur_special,@cur_id,@cur_amount0
//		end
//		close std_mx_cur
//		deallocate cursor std_mx_cur
//	end
//
//	delete pos_dish_pcid where pc_id = @pc_id and menu = @menu
//
//	insert pos_empnoav (empno, menu, bdate, shift, sta, inumber)
//		select @empno1,@menu, @bdate, @mshift, '1', @inumber
//  ����ÿ̨������
	update pos_tblav set amount = isnull((select sum(amount) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0 )
		+ (select sum(srv) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
		+ (select sum(tax) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
		- (select sum(dsc) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0), 0)
		from pos_tblav a where a.menu = @menu  and sta ='7'

	update pos_menu set amount = amount + @amount + @serve_charge + @tax_charge,lastnum = @mx_id
	 where menu = @menu
	select @charge = amount,@timestamp_new = timestamp from pos_menu where menu = @menu
	select @ret = 0,@msg = "�ɹ�"
//   ���嵥
	update pos_assess set number1 = number1 + @plu_number where id = @id
//   ��ˮ�ɿ��
//	exec p_cyj_bar_pos_sale @menu, @id
	end

gout:
if @ret <> 0 
	rollback tran p_hry_pos_input_dish_s1
else
	if @hx = 1 
		select @msg = 'hx' + convert(char(4), @line)
commit tran

select @ret,@msg,@charge
return 0

;
