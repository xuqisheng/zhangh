if exists(select 1 from sysobjects where name='p_cq_newpos_input_dishcard' and type ='P')
	drop  proc p_cq_newpos_input_dishcard;
create proc p_cq_newpos_input_dishcard
	@menu			char(10),
	@inumber		integer,
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
   @pccode     char(3),
	@kitchens	char(20),
	@printer		char(3),
	@prn_code	char(3),
	@prn_des		char(40),

	@id				int, 
	@tag			char(4),		--站点厨房出单标记
	@sta			char(1),
	@flag			char(30),
	@print_id	int, 
	@bdate		datetime,

	@remark		varchar(50),
	@cook			varchar(50),
	@kit_ref		varchar(30),
	@kit_remark varchar(100),
	--@sta			char(1),

	@p_number    int ,      --打印份数，从pos_plu取得
	@flag10      char(1),    --是否合并打印
	@flag8      char(1),		--出菜口是否打印
	@flag9      char(1),		--总厨师长是否需要打印

	@printer1 	char(3),		--出菜口打印机
	@flag1		char(1),
	@set1			char(1),    
	@printer2	char(3),		--厨师长打印机
	@flag2		char(1),
	@set2			char(1),
	@printer3	char(3),		--客人清单打印机
	@flag3		char(1),
	@set3			char(1),
	@flag11		char(1),    --只是定义餐厅没有定义站点是否打印出菜口
	@flag21		char(1),    --只是定义餐厅没有定义站点是否打印厨师长
	@flag31		char(1),    --只是定义餐厅没有定义站点是否打印客人清单
	@p_sort		char(3)		--打印级别
		

select @tag = rtrim(tag) from pos_station where pc_id = @pc_id

select @ret=0, @ret1=0, @msg='ok',@bdate=bdate1 from sysdata
select @inumber = inumber, @id = id,@flag = flag,@kitchens = kitchen,@remark = remark,@cook = cook,@kit_ref = kit_ref,@sta = sta
	from pos_dish where menu=@menu  
		and inumber = @inumber
		  and code <'X' order by inumber
select @p_sort = th_sort from pos_plu_all where id = @id
--假如冲菜则打印备注，否则为做法和厨房指令
if @sta = '2'
	select @kit_remark = @remark
else
	begin
	if @kit_ref = '' or @kit_ref is null
		select @kit_remark = @cook
	else
		select @kit_remark = @cook+'#'+@kit_ref
	end
select @flag11='',@flag21='',@flag31=''
select @pccode = pccode from pos_menu where menu=@menu
--取得出菜口打印机和厨师长打印机，客人清单打印机
--select @printer1 = rtrim(printname1),@flag1 = flag1,@printer2 = rtrim(printname2),@flag2 = flag2,@printer3 = rtrim(printname3),@flag3 = flag3 from pos_pccode where pccode = @pccode
select @printer1 = rtrim(printname1),@flag1 = flag1,@printer2 = rtrim(printname2),@flag2 = flag2,@printer3 = rtrim(printname),@flag3 = flag, @set3=set0,@set1=set1,@set2=set2 from pos_station where  pc_id = @pc_id
if @printer1 = '' or @printer1 is null  -- 如果站点没有定义出菜口打印机，则取餐厅设置
	select @printer1 = rtrim(printname1),@flag1='',@set1='', @flag11 = flag1 from pos_pccode where pccode = @pccode
if @printer2 = '' or @printer2 is null -- 如果站点没有定义厨师长打印机，则取餐厅设置
	select @printer2 = rtrim(printname2),@flag2='',@set2='',@flag21 = flag2 from pos_pccode where pccode = @pccode
if @printer3 = '' or @printer3 is null  -- 如果站点没有定义客人清单打印机，则取餐厅设置
	select @printer3 = rtrim(printname3),@flag3='',@set3='',@flag31 = flag3 from pos_pccode where pccode = @pccode

--取得菜的厨打属性
select @p_number = isnull(p_number,0),@flag10 = flag10,@flag8 = flag8,@flag9 = flag9 from pos_plu where id = @id


select @dinput= getdate()


begin tran
save tran sss
--注意：
--假如某菜没有指定打印机，那么即使定义了出菜口和厨师长打印也不起作用
--但是客单打印是独立于这些设置之外的，只要点了菜都会打印出来
if @kitchens <> '' and @kitchens is not null and @p_number > 0 and @tag = 'T'
	begin
--合并打印处理
	if @flag10 = 'T' 
		insert pos_dishcard(menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price,number,p_number,p_number1, empno, date,  changed,changed1,times,pc_id, printer,printer1,bdate, cook ,p_sort,siteno)
					 select   @menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price, number,@p_number,@p_number, empno,@dinput,'H','H',  0,   @pc_id, @kitchens,@kitchens,@bdate, @kit_remark,outno,siteno
				from pos_dish where menu=@menu and inumber = @inumber 
	else
		insert pos_dishcard(menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price,number,p_number,p_number1, empno, date,  changed,changed1,times,pc_id, printer,printer1,bdate, cook ,p_sort,siteno)
					 select   @menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price, number,@p_number,@p_number, empno,@dinput,'F','F',  0,   @pc_id, @kitchens,@kitchens,@bdate, @kit_remark,outno,siteno
				from pos_dish where menu=@menu and inumber = @inumber 

	--出菜口打印处理
	if @flag8 = 'T' and @printer1 <> '' and @printer1 is not null and ((@flag1 = 'T' and @set1='T') or ( @flag1 ='' and @flag11='T'))
		insert pos_dishcard(menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,   price,       number,p_number,p_number1, empno, date,  changed,changed1,times,pc_id, printer,printer1,bdate, cook ,p_sort,siteno)
					 select   @menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price, number,1,1, empno,@dinput,'B','B' , 0,   @pc_id, @printer1+'#',@printer1+'#',@bdate, @kit_remark,outno,siteno
				from pos_dish where menu=@menu and inumber = @inumber 
	if @flag8 = 'T' and @printer1 <> '' and @printer1 is not null and @flag1 = 'F' and @flag11='' and @set1='T'
		insert pos_dishcard(menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,   price,       number,p_number,p_number1, empno, date,  changed,changed1,times,pc_id, printer,printer1,bdate, cook ,p_sort,siteno)
					 select   @menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price, number,1,1, empno,@dinput,'2','2' , 0,   @pc_id, @printer1+'#',@printer1+'#',@bdate, @kit_remark,outno,siteno
				from pos_dish where menu=@menu and inumber = @inumber 
	
	--厨师长打印处理
	if @flag9 = 'T' and @printer2 <> '' and @printer2 is not null and ((@flag2 = 'T' and @set2='T') or (@flag2='' and @flag21='T'))
		insert pos_dishcard(menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,   price,       number,p_number,p_number1, empno, date,  changed,changed1,times,pc_id, printer,printer1,bdate, cook ,p_sort,siteno)
					 select   @menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price, number,1,1, empno,@dinput,'K','K' , 0,   @pc_id, @printer2+'#',@printer2+'#',@bdate, @kit_remark,outno,siteno
				from pos_dish where menu=@menu and inumber = @inumber 
	if @flag9 = 'T' and @printer2 <> '' and @printer2 is not null and @flag2 = 'F'  and @flag21 ='' and @set2='T'
		insert pos_dishcard(menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,   price,       number,p_number,p_number1, empno, date,  changed,changed1,times,pc_id, printer,printer1,bdate, cook ,p_sort,siteno)
					 select   @menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price, number,1,1, empno,@dinput,'3','3' , 0,   @pc_id, @printer2+'#',@printer2+'#',@bdate, @kit_remark,outno,siteno
				from pos_dish where menu=@menu and inumber = @inumber 

	end


--客人清单打印
--取单菜金额而不是价格
if @printer3 <> '' and @printer3 is not null and ((@flag3 = 'T' and @set3='T') or (@flag3 ='' and @flag31='T'))
	begin
	insert pos_dishcard(menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price, number,p_number,p_number1, empno, date,  changed,changed1,times,pc_id, printer,printer1,bdate, cook ,p_sort,siteno)
				 select   @menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price, number,1,1, empno,@dinput,'G','G' , 0,   @pc_id, @printer3+'#',@printer3+'#',@bdate, @kit_remark,outno,siteno
			from pos_dish where menu=@menu and inumber = @inumber  and sta <>'M'
	insert pos_dishcard(menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price, number,p_number,p_number1, empno, date,  changed,changed1,times,pc_id, printer,printer1,bdate, cook ,p_sort,siteno)
				 select   @menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  0, number,1,1, empno,@dinput,'G','G' , 0,   @pc_id, @printer3+'#',@printer3+'#',@bdate, @kit_remark,outno,siteno
			from pos_dish where menu=@menu and inumber = @inumber  and sta = 'M' 
	end
if @printer3 <> '' and @printer3 is not null and @flag3 = 'F' and @flag31 = '' and @set3='T'
	begin
	insert pos_dishcard(menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price, number,p_number,p_number1, empno, date,  changed,changed1,times,pc_id, printer,printer1,bdate, cook ,p_sort,siteno)
				 select   @menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price, number,1,1, empno,@dinput,'1','1' , 0,   @pc_id, @printer3+'#',@printer3+'#',@bdate, @kit_remark,outno,siteno
			from pos_dish where menu=@menu and inumber = @inumber and sta <> 'M'
	insert pos_dishcard(menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price, number,p_number,p_number1, empno, date,  changed,changed1,times,pc_id, printer,printer1,bdate, cook ,p_sort,siteno)
				 select   @menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  0, number,1,1, empno,@dinput,'1','1' , 0,   @pc_id, @printer3+'#',@printer3+'#',@bdate, @kit_remark,outno,siteno
			from pos_dish where menu=@menu and inumber = @inumber and sta = 'M'
	end
-- dish设置送厨房标志
update pos_dish set flag = substring(flag,1,20)+'T'+substring(flag,22,9) where menu = @menu and inumber = @inumber and 
	exists(select 1 from pos_dishcard where charindex(changed1,'HF')>0 and menu = @menu and inumber = @inumber)

if @ret <> 0
	rollback tran sss
commit

return @ret
;