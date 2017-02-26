/*--------------------------------------------------------s---------------------*/
//
//		点菜计时
//
/*-----------------------------------------------------------------------------*/
if exists(select 1 from sysobjects where name = 'p_gl_pos_input_time' and type = 'P')
	drop proc  p_gl_pos_input_time;

create proc p_gl_pos_input_time
	@menu			char(10),
	@empno		char(10),
	@inumber		integer	,		          
	@end_time	datetime,		            
	@pc_id		char(4)			          
as
declare
   @li_i       integer,
   @ret1       char(2),
   @li_number  integer,
   @date1      integer,
   @date2      integer,
   @bdate1      char(5),
   @edate1      char(5),
   @begindate  datetime,
   @enddate    datetime,
	@ret			integer,
	@msg			char(60),
	@bdate		datetime,		      
	@begin_date	datetime,		            
	@p_mode		char(1),			                          
	@deptno		char(2)	,		            
	@pccode		char(3)	,		            
	@timecode	char(3)	,		          
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
	@timestamp_old		varbinary(8),
	@timestamp_new		varbinary(8),
	@beg_tmp			char(5),
	@ii				int

select @bdate  = bdate1 from sysdata
select @p_mode = value  from sysoption where catalog = "pos_dish" and item = "p_mode"

begin tran
save  tran p_hry_pos_input_time_s1
select @timestamp_old = timestamp from pos_menu where menu = @menu
update pos_menu set pc_id = @pc_id where menu = @menu
select @deptno = deptno,@pccode = pccode,@sta = sta,@mode = mode,
		 @serve_rate = serve_rate,@tax_rate = tax_rate,@dsc_rate = dsc_rate
  from pos_menu where menu = @menu
if @@rowcount = 0
	select @ret = 2,@msg = "主单不存在或已销单"
else if @sta ='3'
	select @ret = 2,@msg = "主单已被其他收银员结帐"
else
	begin        
	select @begin_date = date1, @id = id, @code = plucode+','+sort+','+code,@number = number,@minutes = datediff(minute,date1,@end_time) from pos_dish
		where menu =@menu and inumber = @inumber
	if @@rowcount = 0
		select @ret = 2,@msg = "点菜单错误"
	else
		begin
		select @timecode = timecode,@special = special from pos_plu where id = @id
		if @special <> 'S'
			select @ret = 2,@msg = "菜单号不存在（或标志不为“计时”）"
		else
			begin
//			select @count = count(1) from pos_time where timecode = @timecode
         select @count = count(1) from pos_time_code where timecode = @timecode //cq.modi,jm
			if @count = 0
				select @ret = 2,@msg = "时段码未定义"
			else
				begin
            
				select @amount0 = amount from pos_time_code
					where timecode = @timecode and minute =
					(select min(minute) from pos_time_code where timecode = @timecode and minute >= @minutes) and bdate='0000' and edate='0000'
				if @@rowcount = 0
					begin
					if @count = 1
						begin
						select @minute = minute,@amount0 = amount from pos_time_code where timecode = @timecode and bdate='0000' and edate='0000'
						select @times = ceiling(@minutes / @minute)
						select @amount0 = @amount0 * @times
						end
					else
						begin
						select @minute2 = max(minute) from pos_time_code where timecode = @timecode and bdate='0000' and edate='0000'
						                 
						select @ii = 1, @amount0 = 0
						while @ii <>  0 and @ii < 100
							begin
							if @minutes < @minute2 and @minute2 > (select min(minute) from pos_time_code where timecode = @timecode and bdate='0000' and edate='0000')
								select @minute2 = isnull(max(minute), 0) from pos_time_code where timecode = @timecode and minute < @minute2 and bdate='0000' and edate='0000'
							else
								begin
								if @minute2 = (select min(minute) from pos_time_code where timecode = @timecode and bdate='0000' and edate='0000')
									begin
									select @ii = 0
									select @minute = minute, @amount2 = amount from pos_time_code where timecode = @timecode and minute = @minute2 and bdate='0000' and edate='0000'
									select @times = ceiling(@minutes / @minute) 
									select @amount0 = @amount0 + @times * @amount2
									break
									end
								select @minute = minute, @amount2 = amount from pos_time_code where timecode = @timecode and minute = @minute2 and bdate='0000' and edate='0000'
								select @times = floor(@minutes / @minute) 
								select @amount0 = @amount0 + @times * @amount2, @minutes = @minutes - @times * @minute
								if @minutes = 0 
									break
								end
							select @ii = @ii + 1
							end
						end
					end
				else
					select @times = count(1) from pos_time_code
						where timecode = @timecode and amount = @amount0 and bdate='0000' and edate='0000'
//cq
            select @amount0=isnull(@amount0,0)
            declare p_cur cursor for select number from pos_time_code where timecode=@timecode and bdate<>'0000' and edate<>'0000'
            open p_cur
				fetch p_cur into @li_number
            while @@sqlstatus = 0 
                begin
                select @bdate1=bdate,@edate1=edate from pos_time_code where timecode=@timecode and number=@li_number
                select @date1=convert(integer,substring(@bdate1,1,2)) ,@date2=convert(integer,substring(@edate1,1,2))
                select @li_i = datediff(dd,@begin_date,@end_time)
                select @ii=0
                while @ii <= @li_i
						 begin
						 if @date1 > @date2
								begin
	//                   select @begindate=datetime(date(getdate())+time(@bdate1)),@enddate=datetime(date(dateadd(dd,1,getdate()))+time(@edate1))
								select @begindate=convert(datetime,(substring(convert(char,dateadd(dd,@ii,@begin_date)),1,11)+''+@bdate1))
								select @enddate=convert(datetime,(substring(convert(char,dateadd(dd,@ii+1,@begin_date)),1,11)+''+@bdate1))
								end
						 else
								begin
	//						   select @begindate=datetime(date(getdate())+time(@bdate1)),@enddate=datetime(date(getdate())+time(@edate1))
								select @begindate=convert(datetime,(substring(convert(char,dateadd(dd,@ii,@begin_date), 11),1,11)+''+@bdate1))
								select @enddate=convert(datetime,(substring(convert(char,dateadd(dd,@ii,@begin_date), 11),1,11)+''+@bdate1))
								end
						 if datediff(minute,@begindate,@begin_date)>=0 and datediff(minute,@end_time,@enddate)>=0 
							 
							 begin
							 select @minutes = datediff(minute,@begin_date,@end_time)
							 if @minutes > 0
							 begin
							 select @minute = minute, @amount2 = amount from pos_time_code where timecode = @timecode and number=@li_number
							 select @times = ceiling(@minutes / @minute) 
							 select @amount0 = @amount0 + @times * @amount2
							 end
							 end
	//            
                   else
						 if datediff(minute,@begindate,@begin_date)>=0 and datediff(minute,@enddate,@end_time)>=0
							 begin
							 select @minutes = datediff(minute,@begin_date,@enddate)
							 if @minutes > 0
							 begin
							 select @minute = minute, @amount2 = amount from pos_time_code where timecode = @timecode and number=@li_number
							 select @times = ceiling(@minutes / @minute) 
							 select @amount0 = @amount0 + @times * @amount2
							 end
							 end
	//                
                   else
						 if datediff(minute,@begin_date,@begindate)>=0 and datediff(minute,@end_time,@enddate)>=0
							 begin
							 select @minutes = datediff(minute,@begindate,@end_time)
							 if @minutes > 0
							 begin
							 select @minute = minute, @amount2 = amount from pos_time_code where timecode = @timecode and number=@li_number
							 select @times = ceiling(@minutes / @minute) 
							 select @amount0 = @amount0 + @times * @amount2
							 end
							 end
                   else
						  if datediff(minute,@begin_date,@begindate)>=0 and datediff(minute,@enddate,@end_time)>=0
							 begin
							 select @minutes = datediff(minute,@begindate,@enddate)
							 if @minutes > 0
							 begin
							 select @minute = minute, @amount2 = amount from pos_time_code where timecode = @timecode and number=@li_number
							 select @times = ceiling(@minutes / @minute) 
							 select @amount0 = @amount0 + @times * @amount2
							 end
							 end
						  select @ii=@ii+1
                    end
                 fetch p_cur into @li_number
                 end
            
  ////          


				select @amount0 = @amount0 * @number
				                            
				exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@code,@amount0,@dsc_rate,@result = @amount output

				                            
				exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@code,@amount0,@amount,@serve_rate,@result0 = @serve_charge0 output,@result = @serve_charge output

				                            
				exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@code,@amount0,@amount,@tax_rate,@result0 = @tax_charge0 output,@result = @tax_charge output
				                             
				update pos_dish set amount = @amount0, dsc = @amount0 - @amount, srv = @serve_charge, tax = @tax_charge, 
					flag = substring(flag,1,23)+'T'+substring(flag,25,6), date2 = @end_time	where menu = @menu and inumber = @inumber
				                                 

				            
				update pos_menu set amount = amount + @amount + @serve_charge + @tax_charge
				 where menu = @menu
				select @charge = amount,@timestamp_new = timestamp from pos_menu where menu = @menu
				select @ret = 0,@msg = "成功"

				             
				update pos_tblav set sta = '0' where menu = @menu and inumber = @inumber
				end
			end
		end
	end
commit tran 
  
select @ret1,@ret,@msg,@charge
return 0;
