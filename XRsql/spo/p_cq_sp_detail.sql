drop procedure p_cq_sp_detail;
create proc p_cq_sp_detail
	@as_menu				char(10), 			                          
	@date					datetime				              
as

declare
	@bdate				datetime, 			            
                                  
   @master_menu		char(10),			          
   @pcrec				varchar(20), 		          
   @menu					char(10), 			          
	@deptno				char(2), 			          
	@pccode				char(3), 			          
	@posno				char(2), 			          
	@shift				char(1), 
	@empno				char(10), 
	@paid					char(1), 
	@sta					char(1), 
	@pay_sta				char(1), 			                             
	@mode					char(3), 			        
	@dsc_rate			money, 				          
	@serve_rate			money, 				            
	@tax_rate			money, 				            
                                  
	@sort					char(4), 			        
	@code					char(6), 			        
	@plucode				char(2),
   @modcode          char(15),
	@plu_code			char(10),			                            
	@inumber				integer, 			            
	@type					char(1), 			        
	@name1				char(20), 			            
	@name2				char(20), 			            
	@number				money, 				        
	@amount0				money, 				          
	@dsc_amount			money, 				            
	@amount				money, 				                
	@amount1				money, 				                                        
	@amount2				money, 				                                
	@amount3				money, 				                                
	@amount4				money, 				    
	@serve0				money, 				            
	@serve1				money, 				                                        
	@serve2				money, 				                                  
	@serve3				money, 				                                  
	@tax0					money, 				            
	@tax1					money, 				     
	@tax2					money, 				                                  
	@tax3					money, 	
	@reason				char(3),			                                  
	@reason1				char(3), 			                        
	@reason2				char(3), 			                      
	@reason3				char(3), 			                                   
   @special				char(1), 			              
                      
   @i						integer, 
	@distribute			char(3), 
   @tocode				char(3), 			                        
   @paycode				char(3), 
   @jamount				money, 
  @damount				money, 
   @thispart			money, 
   @sumpart				money, 
   @divval				money, 
   @diffpart			money, 
   @credit				money, 
   @dsc					money, 
   @srv					money, 
   @tax					money, 
   @pccodes				varchar(120)
   
create table #menu
(
	menu			char(10)		not null, 				            
	charge		money			default 0 not null 	         
)
create unique index #menu on #menu (menu)
   
create table #jie
(
	menu			char(10)		not null, 				            
	code			char(15)		not null, 				     
	id				integer		not null, 				              
	amount		money			default 0 not null, 	          
	special		char(1)		not null,				                      
	reason		char(3)		not null 				              
)
create unique index #jie on #jie (menu, code,id)
declare c_jie cursor for select menu, code, id, amount, special from #jie where amount <> 0 order by code 
   
create table #dai
(
	paycode		char(5)		default '', 				                            
	distribute	char(4)		default '', 				                      
	amount		money			default 0,		 
	reason3		char(3)		default ''					                                  
)	 
create unique index #dai on #dai (paycode, reason3)
declare c_dai cursor for select paycode, distribute, sum(amount), reason3 from #dai where amount <> 0 
	group by paycode, distribute, reason3
	order by paycode, distribute, reason3
   
create table #jiedai
(
	menu			char(10)		not null, 				          
	code			char(15)		not null, 				          
	id				integer		not null, 				              
	paycode		char(5)		default '', 			                          
	amount		money			default 0, 
	reason3		char(3)		default ''				                  
)	 
create unique index #jiedai on #jiedai (menu, code, id, paycode, reason3)
declare c_jiedai cursor for select menu, code, id from #jiedai where paycode = @paycode and reason3 = @reason3 order by code 
   
select @bdate = bdate1 from sysdata
if ltrim(rtrim(@as_menu)) is null
	select @as_menu = '%'

update sp_menu  set pccode = rtrim(pccode)
update sp_tmenu set pccode = rtrim(pccode)
update sp_hmenu set pccode = rtrim(pccode)

if @date = @bdate																								        
	begin
                                                                             
	declare c_master_menu cursor for
		select menu, pcrec, paid from sp_menu where menu like @as_menu order by menu
	declare c_menu cursor for
		select menu, pccode, shift, empno3, paid, deptno, posno, mode, reason, dsc_rate, serve_rate, tax_rate, bdate
		from sp_menu where menu = @master_menu or (pcrec = @pcrec and @pcrec >'')
		order by menu
	declare c_dish cursor for
		select plucode,sort, code, name1, inumber, number, amount, dsc, srv, tax, special, reason, sta
		from sp_dish where menu = @menu and sta <>'M'  order by code, id                                   
	declare c_pay cursor for                                                    
		select paycode, number, amount, sta    
		from sp_pay where menu = @menu and charindex(sta, '23') > 0 order by paycode, number  
                                         
	end
else if datediff(dd, @date, @bdate) = 1																        
	begin
                                                                         
	declare c_master_menu cursor for
		select menu, pcrec, paid from sp_tmenu where menu like @as_menu order by menu
	declare c_menu cursor for
		select menu, pccode, shift, empno3, paid, deptno, posno, mode, reason, dsc_rate, serve_rate, tax_rate, bdate
		from sp_tmenu where menu = @master_menu or (pcrec = @pcrec and @pcrec >'')
		order by menu
	declare c_dish cursor for
		select plucode,sort, code, name1, inumber, number, amount, dsc, srv, tax, special, reason, sta
		from sp_tdish where menu = @menu  and sta <>'M'  order by code, id                                   
	declare c_pay cursor for                                                    
		select paycode, number, amount, sta    
		from sp_tpay where menu = @menu and charindex(sta, '23') > 0 order by paycode, number  
	end
else																												        
	begin
	select * into #hmenu from sp_hmenu where bdate = @date
	create index index1 on #menu(menu)
                                        
//    select * from #hmenu                                                                      
	declare c_master_menu cursor for
		select menu, pcrec, paid from #hmenu where menu like @as_menu order by menu
	declare c_menu cursor for
		select menu, pccode, shift, empno3, paid, deptno, posno, mode, reason, dsc_rate, serve_rate, tax_rate, bdate
		from #hmenu where menu = @master_menu or (pcrec = @pcrec and @pcrec >'')
		order by menu
	declare c_dish cursor for
		select plucode,sort, code, name1, inumber, number, amount, dsc, srv, tax, special, reason, sta
		from sp_hdish where menu = @menu  and sta <>'M'  order by code, id                                   
	declare c_pay cursor for       
		select paycode, number, amount, sta    
		from sp_hpay where menu = @menu and charindex(sta, '23') > 0 order by paycode, number  
	end

if (select substring(ltrim(rtrim(@as_menu)),1,1)) = '%' or ltrim(rtrim(@as_menu)) is null
	begin 
	delete pos_detail_jie where date = @date and (menu in (select menu from sp_menu ) or menu in (select menu from sp_tmenu ) or menu in (select menu from sp_hmenu ))
	delete pos_detail_dai where date = @date and (menu in (select menu from sp_menu ) or menu in (select menu from sp_tmenu ) or menu in (select menu from sp_hmenu ))
   end
else
	begin
   delete pos_detail_jie where date = @date and menu like @as_menu
	delete pos_detail_dai where date = @date and menu like @as_menu
	end

              
open c_master_menu
fetch c_master_menu into @master_menu, @pcrec, @paid
while @@sqlstatus =0
   begin
	if @paid <> '1' or exists (select 1 from pos_detail_jie where date = @date and menu = @master_menu)
		begin
		fetch c_master_menu into @master_menu, @pcrec, @paid
		continue
		end
	   
                            
                                        
   truncate table #jie 
   truncate table #dai
   truncate table #jiedai
	open c_menu
	fetch c_menu into @menu, @pccode, @shift, @empno, @paid, @deptno, @posno, @mode, @reason1, @dsc_rate, @serve_rate, @tax_rate, @date
	while @@sqlstatus =0
	   begin
                                                  
		open c_dish
		fetch c_dish into @plucode,@sort, @code, @name1, @inumber, @number, @amount, @dsc, @srv, @tax, @special, @reason3, @sta
		while @@sqlstatus = 0
			begin
         select @modcode=@sort+','+ @code            
			if substring(@code, 1, 4) = '' or @sta in ('B', 'C') or 	( @amount = 0  ) 
				begin
				fetch c_dish into  @plucode ,@sort, @code, @name1, @inumber, @number, @amount, @dsc, @srv, @tax, @special, @reason3, @sta
				continue
				end
			else
				begin
				           
				if not exists (select 1 from #menu where menu = @menu)
					insert #menu (menu, charge) values (@menu, @amount -  @dsc )
				else
					update #menu set charge = charge + @amount - @dsc where menu = @menu
				select @serve0 = 0, @tax0 = 0, @serve1 = 0, @tax1 = 0, @serve2 = 0, @tax2 = 0, @serve3 = 0, @tax3 = 0, @type = '0'
                                                     
                                                              
                                                  
                                                                 
                   
                                                   
                                                   
                                                   
				if @special = 'T'
					select @amount3 =  - @amount, @amount1 = 0, @amount2 = 0, @amount = 0
				else if  @special = 'X'
					select @amount3 = 0, @amount1 = 0, @amount2 = 0
				else
					begin
                                    
					if @sta > '0' and @sta <= '9'                         
						begin
						select @type = convert(char(1), convert(int, @sta) + 1)
						select @amount3 = @dsc
						                              
						exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@modcode,@amount,@dsc_rate,@result = @dsc_amount output
						          
						select @dsc_amount = @amount - @dsc_amount
						                                      
						select @amount3 = @amount3 - @dsc_amount
						end
					else
						select @amount3 = 0, @dsc_amount = @dsc
					       
					exec p_gl_pos_get_discount	@deptno, @pccode, @mode, @modcode, @amount, @dsc_amount, @dsc_rate, @result1 = @amount1 output, @result2 = @amount2 output, @result3 = @reason2 output

					                                  
					exec p_gl_pos_get_serve		@deptno, @pccode, @mode, @modcode, @amount, @amount1, @amount2, @serve_rate, @result0 = @serve0 output, @result1 = @serve1 output, @result2 = @serve2 output

					                                  
					exec p_gl_pos_get_tax		@deptno, @pccode, @mode, @modcode, @amount, @amount1, @amount2, @tax_rate, @result0 = @tax0 output, @result1 = @tax1 output, @result2 = @tax2 output
					end

                                  
				insert #jie (menu, code, id, amount, special, reason) values (@menu, @code, @inumber, @amount - @dsc, @special,@reason3 )

				select @tocode = tocode from pos_speed where fmcode = @pccode + rtrim(ltrim(@sort)) + @code
				if @@rowcount = 0
					begin  
					select @plu_code = @code            
                                        
                                      
                                                                          
					exec p_gl_pos_get_item_code @pccode, @plu_code, @tocode out
                                         
                                            
					delete from pos_speed where fmcode = @pccode+rtrim(ltrim(@sort))+@code
					insert pos_speed (fmcode, tocode) select @pccode+rtrim(ltrim(@sort))+@code, @tocode
						where (select count(1) from pos_speed where fmcode = @pccode+rtrim(ltrim(@sort))+@code) = 0
					end 

				insert pos_detail_jie values(@date, @deptno, @posno, @pccode, @shift, @empno, @menu, @code, @inumber, @type, @name1, @name2, @number, isnull(@amount, 0), isnull(@amount1, 0), isnull(@amount2, 0), isnull(@amount3,0), 
					isnull(@serve0, 0), isnull(@serve1, 0), isnull(@serve2, 0), isnull(@serve3, 0), isnull(@tax0, 0), isnull(@tax1, 0), isnull(@tax2, 0), isnull(@tax3, 0), @reason2, @reason1, @reason3, @special, @tocode)
				end  
			fetch c_dish into @plucode,@sort, @code, @name1, @inumber, @number, @amount, @dsc, @srv, @tax, @special, @reason3, @sta
			end
		close c_dish

		open c_pay
		fetch c_pay into  @paycode, @number, @amount, @pay_sta
		while @@sqlstatus = 0 
			begin

			if not exists (select 1 from pccode where rtrim(pccode) = @paycode and deptno8 > '')
				select @reason = ''
			if @pay_sta = '2'
				select @reason = '¶¨',@reason3 = '¶¨'
			              
			select @paycode = deptno1 from pccode where rtrim(deptno1) = @paycode

			if not exists (select 1 from #dai where paycode = @paycode and reason3 = @reason3)
				insert #dai (paycode, amount, reason3) values (@paycode, @amount, @reason3)
			else
				update #dai set amount = amount + @amount where paycode = @paycode and reason3 = @reason3
			fetch c_pay into  @paycode, @number, @amount, @pay_sta
			end
		close c_pay
		fetch c_menu into @menu, @pccode, @shift, @empno, @paid, @deptno, @posno, @mode, @reason1, @dsc_rate, @serve_rate, @tax_rate, @date
		end
	close c_menu
	                           
	update #dai set distribute = 'T' + pccode.deptno8
		from pccode where pccode.pccode = #dai.paycode and substring(pccode.deptno8,1, 1) > ''
              
	select @i = 0
	while @i < 2
		begin
		if exists ( select 1 from #dai where ((@i = 0 and substring(distribute, 1, 1) = 'T') or (@i = 1 and substring(distribute, 1, 1) <> 'T')) and amount <> 0 )
			begin
			select @credit = isnull(sum(amount), 0) from #dai
			if @credit <> 0
				begin
				                     
				select @dsc = isnull(sum(amount),0) from #jie where special = 'E'
				open c_dai
				fetch c_dai into @paycode, @distribute, @damount, @reason3
				while @@sqlstatus = 0
					begin
					                                                  
					if (@i = 0 and (substring(@distribute, 1, 1) <> 'T' or  @damount = @dsc)) or (@i = 1 and substring(@distribute, 1, 1) = 'T')
						begin
							fetch c_dai into @paycode, @distribute, @damount, @reason3
							continue
						end
					if @i = 0                          
						select @damount = @damount - @dsc
					select @sumpart = 0, @divval = @damount / (@credit - @dsc)
					open c_jie
					fetch c_jie into @menu, @code, @inumber, @jamount, @special
					while @@sqlstatus = 0
						begin
						if	@special = 'E'
							begin
							fetch c_jie into @menu, @code, @inumber, @jamount, @special
							continue
							end
						select @thispart = round( @jamount * @divval , 2)
						select @sumpart  = @sumpart + @thispart 
						insert #jiedai (menu, code, id, paycode, amount, reason3) values (@menu, @code, @inumber, @paycode, @thispart, @reason3)
						fetch c_jie into @menu, @code, @inumber, @jamount, @special
						end
					close c_jie
					select @diffpart = @damount  - @sumpart
					if @diffpart <> 0
						begin 
						open c_jiedai
						fetch c_jiedai into @menu, @code, @inumber
						while @@sqlstatus = 0
							begin
							update #jiedai set amount = amount + @diffpart
								where menu = @menu and code = @code and id = @inumber and paycode = @paycode and reason3 = @reason3
							if @@rowcount = 1
								break
							fetch c_jiedai into @menu, @code, @inumber
							end
						close c_jiedai
						end 
					fetch c_dai into @paycode, @distribute, @damount, @reason3
					end
				close c_dai
               
				if @i = 0 		
					begin
					select @paycode = pccode from pccode where deptno2 = 'ENT'
					insert #jiedai (menu, code, id, paycode, amount, reason3) 
					select @menu, code, id, @paycode, amount, reason from #jie where  special = 'E'
					end
				insert pos_detail_dai (date, menu, paycode, amount, reason3)
				select @date, menu, paycode, sum(amount), reason3 from #jiedai group by menu, paycode, reason3
				if @i = 0
					begin
					insert pos_detail_jie (date, deptno, posno, pccode, shift, empno, menu, code, id, type, name1, name2, number, amount0, amount1, amount2, amount3, 
					serve0, serve1, serve2, serve3, tax0, tax1, tax2, tax3, reason1, reason2,reason3, special, tocode)
                select date, a.deptno, a.posno,a.pccode, a.shift, a.empno, a.menu, a.code, a.id, isnull(b.paycode,''), a.name1, a.name2,a.number,a.amount0,a.amount1,a.amount2, isnull(b.amount,0),
                a.serve0,a.serve1,a.serve2,a.serve3,a.tax0,a.tax1,a.tax2,a.tax3,a.reason1,a.reason2, isnull(b.reason3,''),a.special, a.tocode
						from pos_detail_jie a, #jiedai b where a.date = @date and a.menu = b.menu and a.id = b.id
					end
				truncate table #jiedai
				end
			end
		select @i = @i + 1
		end
		if not exists ( select 1 from pos_detail_dai where date = @date and menu = @menu  )
			insert pos_detail_dai (date, menu, paycode, amount, reason3)
			select @date, @menu, paycode, sum(amount), reason3 from #dai group by paycode, reason3
		if exists ( select 1 from pos_detail_dai where date = @date and menu = @menu ) and
			not exists ( select 1 from pos_detail_jie where date = @date and menu = @menu )
			begin
			select @tocode = min(code) from pos_itemdef where pccode = @pccode
                                                                                                                
			insert pos_detail_jie values(@date, @deptno, @posno, @pccode, @shift, @empno, @menu, '', 0, '', '', '', 0, 0, 0, 0, 0, 
				0, 0, 0, 0, 0, 0, 0, 0, '', '', '', 'N', @tocode)
			end
	fetch c_master_menu into @master_menu, @pcrec, @paid
	end
close c_master_menu
   
deallocate cursor c_master_menu
deallocate cursor c_menu
deallocate cursor c_dish
deallocate cursor c_pay
deallocate cursor c_jie
deallocate cursor c_dai
deallocate cursor c_jiedai
                      
insert #jiedai (menu, paycode, code, id)
select menu, min(paycode), '', 0 from pos_detail_dai where menu in 
(select menu from #menu a where charge <> (select sum(amount) from pos_detail_dai b where a.menu = b.menu))
group by menu
update #jiedai set amount = (select sum(amount) from pos_detail_dai b where date = @date and #jiedai.menu = b.menu group by menu)
update pos_detail_dai set pos_detail_dai.amount = pos_detail_dai.amount + b.charge - a.amount
from #jiedai a, #menu b where a.menu = b.menu and a.menu = pos_detail_dai.menu and a.paycode = pos_detail_dai.paycode

return 0

;