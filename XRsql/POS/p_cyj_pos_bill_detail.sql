drop proc p_cyj_pos_bill_detail;
create proc p_cyj_pos_bill_detail
	@menus				varchar(255),
	@today				char(1),					                                    
	@paid					char(1),					                          
	@mode					char(4)					                                                    
as
declare 
	@ls_menus			varchar(255),
	@menu					char(10),
	@min_charge			money,
	@ld_total0			money,
	@ld_total1			money,
	@ld_total2			money,
	@ls_paymth			varchar(255),
	@ls_transfer		varchar(255),
	@ls_paycode			char(3),
	@distribute			char(4),
	@ld_amount			money,
	@accnt				varchar(7),
	@class				char(1),
	@dec_length			integer,
	@dec_mode			char(1),
   @value            char(4),
	@inumber				int                                     

select * into #dish from pos_dish where 1=2 order by code
select * into #menu from pos_menu where 1=2 
create index index1 on #dish(code)
create table #bill
(
	menu			char(10)		not null,						              
	inumber		integer		not null,						          
	code			char(15)		default '' not null,			       
	empno			char(3)		not null,						          
	name1			char(60)		default '' not null,			              
	name2			char(60)		null,								              
	number		money			not null,						          
	unit			char(4)		null,								          
	amount		money			not null,						          
	log_date		datetime		not null,						              
	status		integer		not null,						                                                                                                           
	sta         char(1)default '0' null,
	sort        integer		not null,
)

create table #checkout
(
	paycode		char(3)		null,								      
	amount		money			not null,						            
	remark		char(15)		null								                        
)

select @ls_menus = @menus, @ld_total2 = 0, @ls_paymth = '', @ls_transfer = ''

              
select @inumber = inumber from pos_menu_bill where menu = substring(@menus, 1, 10) 
if @inumber = null
	select @inumber = 0

while datalength(@ls_menus) > 1
	begin
	select @menu =substring(@ls_menus, 1, 10), @ls_menus = substring(@ls_menus, 12, 255)
	if @today = 'T'
		                              
		begin
		insert #dish select * from pos_dish where menu = @menu and id_master =  0 
		insert #menu select * from pos_menu where menu = @menu 
		update pos_menu_bill set  inumber = (select max(a.inumber) from pos_dish a where pos_menu_bill.menu = a.menu) 
			from pos_menu_bill where menu = @menu
	           
		if @paid = 'F'
			begin
			exec p_gl_pos_create_min_charge	@menu, @min_charge out, 'R',0
			if @min_charge != 0
				select @ld_total2 = @ld_total2 + @min_charge
			end
		end
	else
		                                                  
		insert #dish select * from pos_hdish where menu = @menu and id_master=  0
		insert #menu select * from pos_hmenu where menu = @menu 
	end
        
update #dish set name2 = '' where name2 is null
                              
if @today = 'T' and substring(@mode, 2, 1) = '4'
                              
	begin
	if substring(@mode, 1, 1) = '1'
		              
		insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort)
			select a.menu, 0, b.code, '01', b.descript, 1, '01',  sum(amount), 0, getdate(), 0
			from #dish a, pos_deptcls b
			where  a.code like rtrim(b.deptpat) + '%'
			group by a.menu, b.code, b.descript
	else
		begin
		              
		insert #bill(menu, inumber, code, empno, name1, name2, number, unit,  amount, status, log_date, sta, sort)
			select menu, min(inumber), code, empno, name1, name2, sum(number), unit, sum(amount ), 0, getdate(), '0', 0
			from #dish 
			where  special <> 'X'  and charindex(sta, '357') = 0  and inumber > @inumber and charindex(rtrim(code),'XYZ')=0                 
			group by menu, code, empno, name1, name2, unit order by code
      insert #bill(menu, inumber, code, empno, name1, name2, number, unit,  amount, status, log_date, sta, sort)
			select menu, min(inumber), '00001', empno, name1, name2, sum(number), unit, sum(amount), 0, getdate(), '0', 0
			from #dish 
			where  special <> 'X'  and charindex(sta, '357') = 0  and inumber > @inumber and code='X'
			group by menu, code, empno, name1, name2, unit order by code
		insert #bill(menu, inumber, code, empno, name1, name2, number, unit,  amount, status, log_date, sta, sort)
			select menu, inumber, code, empno, '[赠]'+name1, name2, number, unit, amount , 0, getdate(), '0', 0
			from #dish 
			where  special <> 'X'  and charindex(sta, '3') > 0  and inumber > @inumber order by code
		insert #bill(menu, inumber, code, empno, name1, name2, number, unit,  amount, status, log_date, sta, sort)
			select menu, inumber, code, empno, '[免]'+name1, name2, number, unit, amount , 0, getdate(), '0', 0
			from #dish 
			where  special <> 'X'  and charindex(sta, '5') > 0  and inumber > @inumber order by code
      insert #bill(menu, inumber, code, empno, name1, name2, number, unit,  amount, status, log_date, sta, sort)
			select menu, inumber, code, empno, '[折]'+name1, name2, number,unit, amount , 0, getdate(), '0', 0
			from #dish 
			where  special <> 'X'  and charindex(sta, '7') > 0   and inumber > @inumber order by code
		         
                             
                                            
      
                                                       
                                                    
		end
	          
	if datalength(@menus) < 15
		begin
		            
                                              
  
                
                   
         
      insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort)
			select a.menu, 0, '999905', '', '其中折扣(Complimentary)', 1, '',
			a.dsc, 40, a.date0, 40
			from #menu a 
		end
	else
		begin
		            
		insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort)
			select a.menu, 0, '999906', '', '折扣(Complimentary)', 1, '',
			sum(a.dsc), 40, getdate(), 40
			from #menu a group by a.menu
		end
	end
else
                              
	begin
	if substring(@mode, 1, 1) = '4'
		              
		insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort)
			select '', 0, '999901', '', '餐饮费', 1, '', sum(amount), 0, getdate(), 0
			from #dish where not code like ' %'
	else
		begin
		if substring(@mode, 1, 1) = '1'
			              
			insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort)
				select a.menu, 0, b.code, '', b.descript, 1, '', sum(amount), 0, getdate(), 0
				from #dish a, pos_deptcls b
				where not a.code like ' %' and a.code like rtrim(b.deptpat) + '%'
				group by a.menu, b.code, b.descript
		else
			
			begin
			insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sta, sort)
				select menu, min(inumber), code, empno, name1, name2, sum(number), unit, sum(amount), 0, getdate(), '0', 0
				from #dish where special <> 'X'  and charindex(sta, '357') = 0 and charindex(rtrim(code),'XYZ')=0                   
				group by menu, code, empno, name1, name2, unit order by code
         insert #bill(menu, inumber, code, empno, name1, name2, number, unit,  amount,status, log_date, sta, sort)
				select menu, min(inumber), '00001', empno, name1, name2, sum(number), unit, sum(amount ), 0, getdate(), '0', 0
				from #dish 
				where  special <>'X'  and charindex(sta, '357') = 0  and code='X'
				group by menu, code, empno, name1, name2, unit order by code
			insert #bill(menu, inumber, code, empno, name1, name2, number, unit,  amount, status, log_date, sta, sort)
				select menu, inumber, code, empno, '[赠]'+name1, name2, number, unit, amount , 0, getdate(), '0', 0
				from #dish 
				where  special <> 'X'  and charindex(sta, '3') > 0  order by code                              
			insert #bill(menu, inumber, code, empno, name1, name2, number, unit,  amount, status, log_date, sta, sort)
				select menu, inumber, code, empno, '[免]'+name1, name2, number, unit, amount , 0, getdate(), '0', 0
				from #dish 
				where  special <> 'X'  and charindex(sta, '5') > 0  order by code                   
        
	      insert #bill(menu, inumber, code, empno, name1, name2, number, unit,  amount, status, log_date, sta, sort)
				select menu, inumber, code, empno, '[折]'+name1, name2, number, unit, amount, 0, getdate(), '0', 0
				from #dish 
				where  special <> 'X'  and charindex(sta, '7') > 0  order by code                            
			          
                                                                                                               
              
       
                                                     
			end
		   
		if datalength(@menus) < 15
			begin
			            
                                            
                                                                            
                                     
             
         
         insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort)
				select a.menu, 0, '999905', '', '其中折扣(Complimentary)', 1, '', round(isnull(sum(a.dsc), 0),2), 40, b.date0, 40
				from #dish a, pos_menu b where a.menu = b.menu 
				group by a.menu, b.date0, b.dsc_rate
			end
		else
			begin
			            
			insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort)
				select a.menu, 0, '999906', '', b.tableno + '折扣(Complimentary)', 1, '', round(isnull(sum(a.dsc),0), 2), 40, b.date0, 40
				from #dish a, pos_menu b where a.menu = b.menu 
				group by a.menu, b.tableno, b.date0
			end
		end
	end

	                   
  ------------------------------- shq begin                                                                                           
------insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sort)
--------	select '', 0, '999904', '', '应收小计(Subtotal)', '', 1, '', isnull(sum(amount), 0), 15, getdate(), 15
--------from #bill a where a.status = 0 and  not code like '[XYZ]%'

 --------------------------------   shq end                            
          
insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort)
	select '', 0, '999905', '', '服务费', 1, '', round(isnull(sum(srv), 0),2), 20, getdate(), 20
	from #dish a  where charindex(rtrim(code), 'YZ') = 0
          
insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort)
	select '', 0, '999906', '', '附加费', 1, '',round(isnull(sum(tax), 0),2), 30, getdate(), 30
	from #dish a  where charindex(rtrim(code), 'YZ') = 0

if @paid = 'T'      
	              
	begin
	insert #bill(menu, inumber, code, empno, name1,name2, number, unit, amount, status, log_date, sort)
		select '', 0, '999999', '', '合计(Amount)', '', 1, '', round(isnull(sum(amount - dsc + srv + tax), 0),2), 60, getdate(), 60
		from #dish where charindex(rtrim(code), 'YZ') = 0
	          

	insert #checkout(paycode, amount, remark)
		select paycode, isnull(sum(amount), 0), isnull(accnt, '') +  isnull(roomno, '')
		from pos_pay where charindex(menu, @menus) > 0 and  sta = '3'
		group by paycode, accnt, roomno  order by paycode, accnt, roomno 
   insert #checkout(paycode, amount, remark)
		select paycode, isnull(sum(amount), 0), isnull(accnt, '') +  isnull(roomno, '')
		from pos_hpay where charindex(menu, @menus) > 0 and  sta = '3'
		group by paycode, accnt, roomno  order by paycode, accnt,roomno 
	declare c_paymth cursor for
		select a.paycode, a.amount, a.remark, b.deptno8
		from #checkout a, pccode b
		where a.amount <> 0 and a.paycode = b.pccode
		order by a.amount desc
	open c_paymth

	fetch c_paymth into @ls_paycode, @ld_amount, @accnt, @distribute
	while @@sqlstatus = 0
		begin
			begin
			select @ls_paymth = @ls_paymth + @ls_paycode + convert(varchar(10), @ld_amount) + ","
			if @accnt <> ''
				begin
				exec p_hry_accnt_class @accnt, @class out
				if substring(@class, 1, 1) in ('T','M','H')
					select @ls_transfer = @ls_transfer + roomno + '--' + @accnt + ' ' + ref from master where accnt = @accnt
				else if substring(@class, 1, 1) in ('G')
					select @ls_transfer = @ls_transfer + @accnt + ' ' + name from grpmst where accnt = @accnt
				else if substring(@class, 1, 1) in ('C')
					select @ls_transfer = @ls_transfer + @accnt + ' ' + name from armst where accnt = @accnt
				end
			end
		fetch c_paymth into @ls_paycode, @ld_amount, @accnt, @distribute
		end
	close c_paymth
	deallocate cursor c_paymth

	            
	insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sort)
		select '', 0, '999997', '', '其中:' + substring(@ls_paymth, 1, datalength(@ls_paymth) - 1) +'  ('+ convert(char(8),getdate(),8)+')', '',
		1, '', 1, 70, getdate(), 70
	            
	if @ls_transfer <> ''
		insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort)
			select '', 0, '999998', '',@ls_transfer, 1, '', 1, 80, getdate(), 80
	end
else
	                                          
	begin
                                                                           
  

	                   
	select @ld_total1 = amount from #bill where status = 50
	if @ld_total1 < @ld_total2
		update #bill set name1 = rtrim(name1) + '(含最低消费' + convert(varchar(6), convert(integer, @ld_total2 - @ld_total1)) + '元)',
		amount= @ld_total2 where status = 50
	else
		begin
		select @dec_length = a.dec_length, @dec_mode = a.dec_mode
			from pos_pccode a, pos_menu b
			where b.menu = substring(@menus, 1, 10) and b.pccode = a.pccode
		if @dec_mode = '0'
			select @ld_total1 = round(@ld_total1, @dec_length)
		else if @dec_mode = '1'
			begin
			if @dec_length = 1
				select @ld_total1 = round(@ld_total1 - 0.0500, @dec_length)
			else if @dec_length = 0
				select @ld_total1 = round(@ld_total1 - 0.5000, @dec_length)
			else if @dec_length = -1
				select @ld_total1 = round(@ld_total1 - 5.0000, @dec_length)
			end
		else if @dec_mode = '2'
			begin
			if @dec_length = 1
				select @ld_total1 = round(@ld_total1 + 0.0499, @dec_length)
			else if @dec_length = 0
				select @ld_total1 = round(@ld_total1 + 0.4999, @dec_length)
			else if @dec_length = -1
				select @ld_total1= round(@ld_total1 + 4.9999, @dec_length)
			end

		update #bill set amount = @ld_total1 where status = 50
		end
	end
 -----------------shq       
insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sort)
	select '', 0, '999908', '', '应收累计(Amount)', '', isnull(sum(amount), 0), '', isnull(sum(amount - dsc), 0), 50, getdate(), 50
		from #dish where not code like ' %'
------------------shq
select @value=value from sysoption where catalog='pos' and item='print_sort' 
update #bill set sort=convert(integer,@value) where code in (select code from pos_plu where sort=(select value from sysoption where catalog='pos' and item='print_sort' ))
update #bill set sort=9999 where code not in (select code from pos_plu where sort=(select value from sysoption where catalog='pos' and item='print_sort' ))
select menu, inumber, code,empno, name1, name2 = isnull(name2, ''), number, unit, amount , log_date, status
from #bill where amount <> 0 or sta = '3' or status = 10 order by sort,  code
return 0
;