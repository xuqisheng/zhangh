if exists(select 1 from sysobjects where name='p_cyj_pos_input_kitchen' and type='P')
   drop procedure p_cyj_pos_input_kitchen;

create proc p_cyj_pos_input_kitchen
	@menu			char(10),
	@inumber		int,
	@printers	char(30),		  --
	@empno		char(10),
	@option		char(1),			  --Q: 催菜,S: 缓菜,G: 客单,U: 上菜, T: 换台, D: 单菜备注
	@pc_id		char(4),
	@msg			char(30)  = ''   -- 备注信息
as
--------------------------------------------------------------------------------
--
--	厨房指令处理, 客户端通过调用N_kitchen_print.f_kitchen_print_r 处理
--
--------------------------------------------------------------------------------
declare	
	@printid 		int,
	@sysdate			datetime,
	@pccode			char(3),
	@orderid			int,
	@kitchen			char(30),
	@print_gst		char(3),
	@flag_gst 		char(1)

select @sysdate = bdate1 from sysdata
if @printers <> ''
	select @kitchen = @printers
else
	begin
	select @pccode = pccode from pos_menu where menu = @menu
	select @orderid = id from pos_dish  where menu = @menu and inumber = @inumber
	exec p_cq_pos_get_printer @pccode,@orderid,@kitchen output
	end

if @option ='Q'
	begin
	select @printid = isnull(max(printid), 0) + 1 from pos_dishcard
	insert pos_dishcard(menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price,number,p_number,p_number1, empno, date,    changed,changed1,times,pc_id, printer,printer1, bdate,     refer, cook,p_sort,siteno)
			     select  @menu,tableno,@printid,inumber,id,sta,code,name1,name2,unit, price,number,1,       1,         empno,getdate(),'R',    'R',     0,   @pc_id, @kitchen,@kitchen,@sysdate, '催菜, 快点上',cook,'',siteno
			from pos_dish where menu=@menu and inumber = @inumber 
	end
else if @option ='S'
	begin
	select @printid = isnull(max(printid), 0) + 1 from pos_dishcard
	insert pos_dishcard(menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price,number,p_number,p_number1, empno, date,    changed,changed1,times,pc_id, printer,printer1, bdate,     refer, cook,p_sort,siteno)
			     select  @menu,tableno,@printid,inumber,id,sta,code,name1,name2,unit, price,number,1,       1,         empno,getdate(),'R',    'R',     0,   @pc_id, @kitchen,@kitchen,@sysdate, '缓菜, 慢点上',cook,'',siteno
			from pos_dish where menu=@menu and inumber = @inumber 
	end
else if @option ='D'  -- 针对单菜的备注信息
	begin
	select @printid = isnull(max(printid), 0) + 1 from pos_dishcard
	insert pos_dishcard(menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,  price,number,p_number,p_number1, empno, date,    changed,changed1,times,pc_id, printer,printer1, bdate,     refer, cook,p_sort,siteno)
			     select  @menu,tableno,@printid,inumber,id,sta,code,name1,name2,unit, price,number,1,       1,         empno,getdate(),'R',    'R',     0,   @pc_id, @kitchen,@kitchen,@sysdate, @msg,cook,'',siteno
			from pos_dish where menu=@menu and inumber = @inumber 
	end
else if @option ='U'  -- 起菜, 作用整单, 整单起菜，对应叫起
	begin
	select @printid = isnull(max(printid), 0) + 1 from pos_dishcard
	insert into pos_dishcard (menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,price,number,p_number,p_number1,empno,date,changed,changed1,times,pc_id,printer,printer1,refer,cook,bdate,p_sort,siteno) 
		select @menu,tableno,@printid,0,0,'0','','起菜',' DISH UP ','',0,0,1,1,@empno,getdate(),'R','R',0,@pc_id,@kitchen,@kitchen, '('+tableno + ')起菜','',@sysdate,'','' from pos_menu where menu =@menu
	end
else if @option ='G'
	begin
	select @print_gst = '', @flag_gst = 'T'
	select @print_gst = printname, @flag_gst = flag from pos_station where pc_id =@pc_id
	if @flag_gst = 'F' and @print_gst <> ''
		begin
		delete pos_dishcard where menu = @menu and changed1 ='1'
		insert into pos_dishcard (menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,price,number,p_number,p_number1,empno,date,changed,changed1,times,pc_id,printer,printer1,refer,cook,bdate) 
		select @menu,b.tableno,a.printid,a.inumber,a.id,'0',a.code,a.name1,a.name2,a.unit,a.price,a.number,1,1,@empno,getdate(),'1','1',0,@pc_id,@print_gst,@print_gst,'客单','',a.bdate from pos_dish a, pos_menu b 
		where a.menu=b.menu and a.menu =@menu and charindex(a.sta, '03579M')>0 and rtrim(ltrim(code)) <'X'
		end
	else
		begin
		delete pos_dishcard where menu = @menu and changed1 ='G'
		insert into pos_dishcard (menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,price,number,p_number,p_number1,empno,date,changed,changed1,times,pc_id,printer,printer1,refer,cook,bdate) 
		select @menu,b.tableno,a.printid,a.inumber,a.id,'0',a.code,a.name1,a.name2,a.unit,a.price,a.number,1,1,@empno,getdate(),'G','G',0,@pc_id,@kitchen,@kitchen,'客单','',a.bdate from pos_dish a, pos_menu b 
		where a.menu=b.menu and a.menu =@menu and charindex(a.sta, '03579M')>0 and rtrim(ltrim(code)) <'X'
		end
	end
else if @option ='T'     --  换台
	begin
	select @printid = isnull(max(printid), 0) + 1 from pos_dishcard
	insert into pos_dishcard (menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,price,number,p_number,p_number1,empno,date,changed,changed1,times,pc_id,printer,printer1,refer,cook,bdate) 
	select @menu,tableno,@printid,0,0,'0','','换台信息','换台信息','',0,0,1,1,@empno,getdate(),'R','R',0,@pc_id,@kitchen,@kitchen,@msg,'',@sysdate from pos_menu where menu =@menu
	end
else if @option ='R'     --  备注信息
	begin
	select @printid = isnull(max(printid), 0) + 1 from pos_dishcard
	insert into pos_dishcard (menu,tableno,printid,inumber,id,sta,code,name1,name2,unit,price,number,p_number,p_number1,empno,date,changed,changed1,times,pc_id,printer,printer1,refer,cook,bdate) 
	select @menu,tableno,@printid,0,0,'0','',@msg,@msg,'',0,0,1,1,@empno,getdate(),'R','R',0,@pc_id,@kitchen,@kitchen,'','',@sysdate from pos_menu where menu =@menu
	end


;

