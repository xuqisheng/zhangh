
if exists(select 1 from sysobjects where name = 'p_gl_pos_adjust_dish' and type = 'P')
	drop proc p_gl_pos_adjust_dish;

create proc p_gl_pos_adjust_dish
	@menu			char(10),
	@empno		char(10),
	@old_id		integer,
	@pc_id		char(8),			          
	@add_remark	char(15)=NULL,
   @li_inumber integer
as
-------------------------------------------------------------------------------------------------
--
--			��˳���dish
--
-------------------------------------------------------------------------------------------------
declare
	@code				char(6),		        
	@plucode			char(4),
   @modcode       char(15),		        
	@remark			char(15),		        
	@id				int,		        

	@ret			integer,
	@msg			char(60),
	@bdate		datetime,		            
	@p_mode		char(1)	,		                          
	@deptno		char(2)	,		 
	@pccode		char(3)	,		            
	@mode			char(3),			           
	@new_id		integer	,		          
	@name1		char(20)	,		            
	@name2		char(30)	,		            
	@unit			char(4)	,		        
	@amount		money	,			                
	@number		money	,			            
	@shift 		char(1),
	@empno1		char(10),

	@charge			money,		              

	@special				char(1),
	@dish_sta			char(1), 
	@menu_sta			char(1), 
	@newsta 				char(1),
	@cur_id 				int,
	@app_id 				int,
	@lastnum				int

select @bdate  = bdate1 from sysdata
select @p_mode = value  from sysoption where catalog = "pos_dish" and item = "p_mode"

begin tran
save  tran p_hry_pos_adjust_dish_s1
update pos_menu set pc_id = @pc_id where menu= @menu
select @code = code, @number = - number,@unit = unit, @dish_sta = sta, @remark = remark, @empno1 =empno1, @plucode = plucode, @id = id, @special=special
  from pos_dish where menu = @menu and inumber = @old_id
if charindex(@dish_sta,'03579M')=0 or (@dish_sta = 'M' and @special ='C')
	begin
	select @ret = 1,@msg = "��ǰ��Ŀ���ܱ�����"
	commit tran 
	select @ret,@msg,@charge
	return 0
	end

                       
select @deptno = deptno,@pccode = pccode,@new_id = lastnum + 1,@menu_sta = sta,@mode = mode,
		 @shift = shift, @bdate = bdate
  from pos_menu where menu = @menu
if @@rowcount = 0
	select @ret = 1,@msg = "����" + @menu+ "�Ѳ����ڻ�������"
else if @menu_sta ='3'
	select @ret = 1,@msg = "����" + @menu + "�ѱ���������Ա����"
else
	begin
	select @name1 = name1,@name2 = name2,@special=special,@modcode = sort+code 
	  from pos_plu where plucode = @plucode and code = @code
	if @@rowcount = 0
		select @ret = 1,@msg = "�˺�" + rtrim(@code) + "�Ѳ�����"
	else
		begin
			if @dish_sta = 'M'    -- �ײ���ϸ����, ��Ӧspecial��Ϊ ��C��, sta ��Ϊ ��1���͡�2��
				begin
				insert pos_dish(menu,inumber,plucode,sort,id,code,name1,name2,unit,number,amount,dsc,srv,tax,empno,empno1,bdate,remark,special,sta,id_cancel,id_master,orderno)
						select @menu,@new_id,plucode,sort,id,code,name1,name2,unit,-1 * number, -1 * amount,-1 * dsc,-1 * srv,-1 * tax,@empno,@empno1,@bdate,@add_remark,'C','2',id_cancel,id_master,orderno
				from pos_dish where menu = @menu and inumber = @old_id
				-- ��̨�����־
				if exists(select 1 from pos_dish where menu = @menu and inumber = @old_id and charindex('B', upper(flag))>0)
					update pos_dish set flag = 'B' where menu = @menu and inumber = @new_id 
	 			exec p_cyj_bar_pos_sale @menu, @new_id
				update pos_dish set special = 'C', sta = '1' from pos_dish where menu = @menu and inumber = @old_id
				update pos_menu set lastnum = lastnum + 1 from pos_menu where menu = @menu
				select @ret = 0,@msg = "ok"
				commit tran 
				select @ret,@msg,@charge
				return 0
				end

			select @newsta = convert(char(1),convert(int,@dish_sta) + 1)
			select @name1=name1,@name2=@name2 from pos_dish where menu=@menu and inumber=@old_id

			insert pos_dish(menu,inumber,plucode,sort,id,code,name1,name2,unit,number,amount,dsc,srv,tax,empno,empno1,bdate,remark,special,sta,id_cancel)
				   select @menu,@new_id,plucode,sort,id,@code,@name1,@name2,@unit,-number,-amount,- dsc,- srv,- tax,@empno,@empno1,@bdate,@add_remark,@special,'2',@old_id
			from pos_dish where menu = @menu and inumber = @old_id
			select @lastnum = @new_id
			-- ��̨�����־
			if exists(select 1 from pos_dish where menu = @menu and inumber = @old_id and charindex('B', upper(flag))>0)
				update pos_dish set flag = 'B' where menu = @menu and inumber = @new_id 
 			exec p_cyj_bar_pos_sale @menu, @new_id
	
-- �ײ˳���, ������ϸ
			select @app_id= @new_id
			declare std_mx_cur cursor for
				select inumber from pos_dish where menu=@menu and sta='M' and id_master=@old_id order by id
			open std_mx_cur
			fetch std_mx_cur into @cur_id
			while @@sqlstatus = 0
			begin
				select @app_id = @app_id + 1
				insert pos_dish(menu,inumber,plucode,sort,id,code,name1,name2,unit,number,amount,dsc,srv,tax,empno,bdate,remark,special,sta,id_cancel,id_master)
				   select @menu,@app_id,plucode,sort,id,code,name1,name2,unit,- number,-amount,-dsc,-srv,-tax,@empno,@bdate,@add_remark,special,'2',@cur_id,@new_id
						from pos_dish where menu=@menu and id = @cur_id
				select @lastnum = @app_id
				-- ��̨�����־
				if exists(select 1 from pos_dish where menu = @menu and inumber = @cur_id and charindex('B', upper(flag))>0)
					update pos_dish set flag = 'B' where menu = @menu and inumber = @app_id 
	 			exec p_cyj_bar_pos_sale @menu, @app_id
				fetch std_mx_cur into @cur_id
			end
			close std_mx_cur
			deallocate cursor std_mx_cur
			update pos_menu set lastnum = @lastnum  from pos_menu where menu = @menu
-- ���±���dish��״̬
			update pos_dish set sta = @newsta where menu = @menu and inumber = @old_id
-- ���¼�ʦ״̬			                
			update pos_empnoav set sta ='0' where bdate = @bdate and shift =@shift and empno = @empno1 and inumber = @old_id
			update pos_assess set number1 = number1 + @number where id = @id
			update pos_dish set sta='1' where menu=@menu and sta='M' and id_master=@old_id
			select @charge = amount from pos_menu where menu = @menu
			select @ret = 0,@msg = "�ɹ�"
		end

-- ����Ѻϼ�
	update pos_dish set amount = (select sum(srv) from pos_dish where menu = @menu and charindex(rtrim(ltrim(code)), 'YZ') =0 and charindex(sta,'03579')>0 ) where menu = @menu and rtrim(ltrim(code)) = 'Z'
-- ˰�ϼ�
	update pos_dish set amount = (select sum(tax) from pos_dish where menu = @menu and charindex(rtrim(ltrim(code)), 'YZ') =0 and charindex(sta,'03579')>0 ) where menu = @menu and rtrim(ltrim(code)) = 'Y'
-- ����menu�ϼ�
	update pos_menu set amount = (select sum(amount) - sum(dsc) + sum(srv) + sum(tax) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
		amount0 = (select sum(amount) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
		dsc = (select sum(dsc) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
		srv = (select sum(srv) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
		tax = (select sum(tax) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0)
		where menu = @menu
-- ��������ϼ�
	update pos_tblav set amount = isnull((select sum(amount) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0 )
	+ (select sum(srv) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	+ (select sum(tax) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	- (select sum(dsc) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0), 0)
	from pos_tblav a where a.menu = @menu  and sta ='7'
  
--cq modify �������ϵ����ۻ�������ԭ��
   delete pos_hxsale where menu=@menu and inumber=@li_inumber
 end
commit tran 
select @ret,@msg,@charge
return 0;
