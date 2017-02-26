/*-----------------------------------------------------------------------------*/
//
//		点菜计时
//
/*-----------------------------------------------------------------------------*/
if exists(select 1 from sysobjects where name = 'p_cyj_pos_input_time' and type = 'P')
	drop proc  p_cyj_pos_input_time;

create proc p_cyj_pos_input_time
	@menu			char(10),
	@empno		char(10),
	@inumber		integer ,		                -- pos_dish.inumber
	@end_			datetime,		                -- 结束时间
	@pc_id		char(4)			          
as
declare
   @li_i       integer,
   @ret1       char(2),
   @inumb  		integer,
   @bdate1      char(5),
   @edate1      char(5),
   @begindate  datetime,
   @enddate    datetime,
	@ret			integer,
	@msg			char(60),
	@bdate		datetime,		      
	@begin_		datetime,		            -- 开始时间 dish.date1
	@deptno		char(2)	,		            
	@pccode		char(3)	,		            
	@timeid		char(3)	,		            -- 适用的计费标准号pos_timedef.id    
	@code			char(15)	,		        
	@id			integer,			 
	@special		char(1)	,		    
	@minute		money,			              
	@minutes		money,			              
	@mode			char(3),			            
	@name1		char(20)	,		            
	@name2		char(30)	,		            
	@unit			char(4)	,		        
	@amount0		money	,			          
	@amount		money	,			                
	@number		money	,			            
	@times		money	,			            
	@count		money	,			                

	@minute1		money,			              
	@minute2		money,			              
	@amount1		money	,			    
	@amount2		money	,			        

	@dsc_rate	money,		                
 	@serve_rate		money,		                
	@tax_rate		money,		                

	@serve_charge0	money,		                  
	@tax_charge0	money,		                  
	@serve_charge	money,		                           
	@tax_charge		money,		                           
	@charge			money,		              

	@sta					char(1), 
	@beg_tmp			char(5),
	@ii				int,
	@factor			money,
 
//	@duration		money,
//	@basemut			money,
//	@stepmut			money,

	@duration		int,
	@basemut			int,
	@stepmut			int,

	@cgunits			int,
	@adjumut			money

select @bdate  = bdate1 from sysdata

begin tran
save  tran p_hry_pos_input_time_s1
select @ret = 0, @msg = ''
update pos_menu set pc_id = @pc_id where menu = @menu
select @deptno = deptno,@pccode = pccode,@sta = sta,@mode = mode,
		 @serve_rate = serve_rate,@tax_rate = tax_rate,@dsc_rate = dsc_rate
  from pos_menu where menu = @menu
if @@rowcount = 0
	begin
	select @ret = 2,@msg = "主单不存在或已销单"
	goto goout
	end
else if @sta ='3'
	begin
	select @ret = 2,@msg = "主单已被其他收银员结帐"
	goto goout
	end

select @begin_ = date1, @id = id, @code = plucode+','+sort+','+code,@number = number,@minutes = datediff(minute,date1,@end_) from pos_dish
	where menu =@menu and inumber = @inumber
if @@rowcount = 0
	begin
	select @ret = 2,@msg = "点菜单错误"
	goto goout
	end
else if @minutes <= 0 
	begin
	select @ret = 2,@msg = "结束时间不应该早于开始时间"
	goto goout
	end

select @timeid = timecode,@special = special from pos_plu where id = @id
if @special <> 'S'
	begin
	select @ret = 2,@msg = "菜单号不存在（或标志不为“计时”）"
	goto goout
	end
select @count = count(1) from pos_timedef where id = @timeid
if @count = 0
	begin
	select @ret = 2,@msg = "时段码未定义"
	goto goout
	end

select @amount0 = 0
/* Time segment analysis ------------*/
exec p_cyj_pos_timeanal @pc_id, @timeid, @begin_, @end_

declare c_timeanal_cur cursor for select factor, leng_, duration from pos_timeanal where pc_id = @pc_id and id = @timeid
open  c_timeanal_cur
fetch c_timeanal_cur into @factor, @basemut, @duration 
while @@sqlstatus = 0 
	begin
	select @stepmut = @basemut
	if floor(@duration/@basemut) * @basemut = @duration
		select @cgunits= floor(@duration/@basemut)
	else 
		select @cgunits= floor(@duration/@basemut) + 1

	select @amount0 = @amount0 + round(@factor*@cgunits, 3)
	fetch c_timeanal_cur into @factor, @basemut, @duration
	end 
close c_timeanal_cur
deallocate cursor c_timeanal_cur

select @amount0 = @amount0 * @number

exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@code,@amount0,@dsc_rate,@result = @amount output
exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@code,@amount0,@amount,@serve_rate,@result0 = @serve_charge0 output,@result = @serve_charge output
exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@code,@amount0,@amount,@tax_rate,@result0 = @tax_charge0 output,@result = @tax_charge output
									  
update pos_dish set amount = @amount0, dsc = @amount0 - @amount, srv = @serve_charge, tax = @tax_charge, 
	flag = substring(flag,1,23)+'T'+substring(flag,25,6), date2 = @end_	where menu = @menu and inumber = @inumber
											
update pos_menu set amount = amount + @amount + @serve_charge + @tax_charge, srv = srv + @serve_charge, tax = tax + @tax_charge
 where menu = @menu
select @charge = amount from pos_menu where menu = @menu
select @ret = 0,@msg = "成功"

				 
update pos_tblav set sta = '0' where menu = @menu and inumber = @inumber

goout:

commit tran 

select @ret,@msg
return 0;
