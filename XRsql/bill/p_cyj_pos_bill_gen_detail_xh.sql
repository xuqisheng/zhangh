/*
	�����շ������������ʵ�
*/
if exists(select 1 from sysobjects where name = 'p_cyj_pos_bill_gen_detail' and type = 'P')
	drop proc  p_cyj_pos_bill_gen_detail;
create proc p_cyj_pos_bill_gen_detail
	@menus				varchar(255),
	@today				char(1),					                                    
	@paid					char(1),					                          
	@multi				char(1),					                    
	@code					char(4),
	@pc_id				char(4)
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
	@accnt				varchar(10),
	@class				char(1),
	@dec_length			integer,
	@dec_mode			char(1),
	@inumber				int,                                                                    
	@hline				int,
	@ii					int,
	@pagerow				int,					               
	@rows					int,
	@amount				decimal(10,2),
	@samount				varchar(40),
	@deptno2				char(20),
	@dsc_rate			money,
	@srv_rate			money,
	@roomno				char(5),
	@name					char(40),
	@ls_paydes			char(10)


delete bill_dtl where pc_id  = @pc_id
select * into #dish from pos_dish where 1=2
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
	sta         char(1)    	default '0' null,
	sort        integer	   not null,
)

create table #checkout
(
	paycode		char(3)		null,								            
	amount		money			not null,						            
	remark		char(20)		null								                        
)

select @ls_menus = @menus, @ld_total2 = 0, @ls_paymth = '', @ls_transfer = ''

              
select @inumber = inumber, @hline = hline from pos_menu_bill where menu = substring(@menus, 1, 10) 
if @inumber = null
	select @inumber = 0, @hline = 0

while datalength(@ls_menus) > 1
	begin
	select @menu = substring(@ls_menus, 1, 10), @ls_menus = substring(@ls_menus, 12, 255)
	if @today = 'T'
		    
		begin
		if @multi = 'T'
--��δ�
			begin
			if @inumber = 0
				insert #dish select * from pos_dish where menu = @menu  and inumber > @inumber and charindex(rtrim(code), 'YZ') = 0 and charindex(sta, '03579M') > 0 order by inumber
			else
				insert #dish select * from pos_dish where menu = @menu  and inumber > @inumber and charindex(rtrim(code), 'YZ') = 0 and charindex(sta, '0123579M') > 0 order by inumber
			end
		else
--���µ��ϴ�ӡ            
			insert #dish select * from pos_dish where menu = @menu and charindex(sta, '03579M') > 0 and charindex(rtrim(code), 'YZ') = 0 order by inumber
		insert #menu select * from pos_menu where menu = @menu 
		              
		if @paid = 'F'
			begin
			exec p_gl_pos_create_min_charge	@menu, @min_charge out, 'R', 0
			if @min_charge != 0
				select @ld_total2 = @ld_total2 + @min_charge
			end
		end
	else
		begin
		                                                  
		insert #dish select * from pos_hdish where menu = @menu and id_master =  0 and charindex(sta, '03579M') > 0  and charindex(rtrim(code), 'YZ') = 0 order by inumber
		insert #menu select * from pos_hmenu where menu = @menu 
		end
	end
	delete #dish where name1 = '��ͷ'
	update #dish set amount = 0 where sta ='M'
	select @dsc_rate = dsc_rate, @srv_rate = serve_rate from #menu
	if @dsc_rate is null or @dsc_rate = 0
		select @dsc_rate = max(a.rate) from pos_mode_def a,#menu b where a.code = b.mode and a.type = '1'
	if @srv_rate is null or @srv_rate = 0
		select @srv_rate = max(a.rate) from pos_mode_def a,#menu b where a.code = b.mode and a.type = '2'
-- begin 
if @code = '61'        --          
	begin
	insert #bill(menu, inumber, code, empno, name1, name2, number, unit,  amount, status, log_date, sta, sort)
		select menu, min(inumber), code, empno, name1, name2, sum(number), unit, sum(amount), 0, getdate(), sta, min(inumber)
		from #dish 
		where  special <> 'X' 
		group by menu, code, empno, name1, name2, unit, sta
		order by menu, code, empno, name1, name2, unit, sta
	                
	update #bill set name1 = substring(rtrim('[��]' + name1), 1, 60), amount = 0 where sta ='3'
	                
	update #bill set name1 = substring(rtrim('[��]' + name1), 1, 60), amount = 0 where sta = '5'
	          
	if datalength(@menus) < 15
		begin
--		insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort)
--			select '', 0, '', '', '�����ۿ�[' + convert(char(2), convert(int, @dsc_rate * 100)) +'%]', 1, '',
--			round(isnull(sum( -1 * a.dsc), 0),2), 40, getdate(), 4000
--			from #dish a where charindex(rtrim(code), 'YZ') = 0
--  �����dishȡ�ۿۣ��޸��ۿ���ʱ���ʵ���ӡ�᲻ƽ  cyj 03.12.19
		insert #bill(menu, inumber, code, empno, name1,name2, number, unit, amount, status, log_date, sort)
			select a.menu, 0, '', '', '�����ۿ�[' + convert(char(2), convert(int, @dsc_rate * 100)) +'%]', 'Dsc', 1, '',
			sum(-1 *  a.dsc), 40, getdate(), 4000
			from #menu a, pos_mode_name b where a.mode = b.code 
			group by a.menu, b.name2, a.dsc_rate
		end	
	else
		begin
		            
		insert #bill(menu, inumber, code, empno, name1, number, unit, amount,status, log_date, sort)
			select '', 0, '', '', a.tableno +'�ۿ�'+'(' + isnull(rtrim(b.name2), ' ') + ')', 1, '',
			-1 * sum(a.dsc), 40, a.date0, 4000
			from #menu a, pos_mode_name b where a.mode = b.code 
			group by a.menu, a.tableno, b.name2, a.date0
			order by a.menu, a.tableno, b.name2, a.date0
		end

	insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sort)
		select '', 0, '', '', 'Ӧ��С��', '', 1, '', isnull(sum(amount), 0), 15, getdate(), 1500
	from #bill a where a.status = 0 and  not code like '[XYZ]%'

	                                        
	          
	insert #bill(menu, inumber, code, empno,name1, number, unit, amount, status, log_date, sort)
		select '', 0, '', '', '�����[' + convert(char(2), convert(int, @srv_rate * 100)) +'%]', 1, '', round(isnull(sum(srv), 0),2), 20, getdate(), 2000
		from #dish a  where charindex(rtrim(code), 'YZ') = 0
	          
	insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort)
		select '', 0, '', '', '���ӷ�', 1, '',round(isnull(sum(tax), 0),2), 30, getdate(), 3000
		from #dish a  where charindex(rtrim(code), 'YZ')= 0
	end
else if @code = '62'   --             
	begin
	              
	insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort)
		select a.menu, 0, b.code, '01', b.descript, 1, '01',  sum(amount), 0, getdate(),0
		from #dish a, pos_deptcls b
		where  a.code like rtrim(b.deptpat) + '%'
		group by a.menu, b.code, b.descript
	end
else if @code = '65'  --         
	begin
	insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort)
		select '', 0, '', '', '������', 1, '', sum(amount), 0, getdate(), 0
		from #dish
	end


if @paid = 'T'   	              
	begin
	insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sort)
		select '', 0, '', '', '�ϼ�', '', 1, '', isnull(sum(amount), 0), 60, getdate(), 6000
		from #menu 
	          
	if @today = 'T'
		insert #checkout(paycode, amount, remark)
			select paycode, isnull(sum(amount), 0), isnull(accnt, '') 
			from pos_pay where charindex(menu, @menus) > 0 and  sta = '3'
			group by paycode, accnt, roomno  order by paycode, accnt, roomno 
	else
		insert #checkout(paycode, amount, remark)
			select paycode, isnull(sum(amount), 0), isnull(accnt, '') 
			from pos_hpay where charindex(menu, @menus) > 0 and  sta = '3'
			group by paycode, accnt, roomno  order by paycode, accnt, roomno 
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
			select @deptno2 = rtrim(ltrim(descript)) from pccode where pccode = @ls_paycode 
			select @ls_paymth = rtrim(ltrim(@ls_paymth + @deptno2)) + rtrim(ltrim(convert(varchar(10), @ld_amount))) + ","
			if @accnt <> ''
				begin
					select @ls_transfer = @ls_transfer +' ' +  @accnt + '-'+ a.roomno + ' ' + b.name from master a, guest b
						 where a.accnt = @accnt and a.haccnt = b.no
					select @roomno = a.roomno, @name = substring(b.name, 1, 40) from master a, guest b
						 where a.accnt = @accnt and a.haccnt = b.no
				end
			end
		fetch c_paymth into @ls_paycode, @ld_amount, @accnt, @distribute
		end
	close c_paymth
	deallocate cursor c_paymth

                                                                                                                             
	insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sort)
		select '', 0, '', '', '����:' + substring(@ls_paymth, 1, datalength(@ls_paymth) - 1) + isnull(rtrim(@ls_transfer), ' ') + '  ('+ convert(char(8),getdate(),8)+')', '',
		1, '', 1, 70, getdate(), 7000

 
	if @ls_transfer <> ''
		insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort)
			select '', 0, '', '', @ls_transfer, 1, '', 1, 80, getdate(), 8000
	end
else		                                          
	begin
	insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sort)
		select '', 0, '', '', 'Ӧ���ۼ�', '', 1, '', isnull(sum(amount), 0), 50, getdate(), 5000
		from #menu 

	                   
	select @ld_total1 = amount from #bill where status = 50
	if @ld_total1 < @ld_total2
		update #bill set name1 = rtrim(name1) + '(���������' + convert(varchar(6), convert(integer, @ld_total2 - @ld_total1)) + 'Ԫ)',
		amount = @ld_total2 where status = 50
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
				select @ld_total1 = round(@ld_total1 + 4.9999, @dec_length)
			end

		update #bill set amount = @ld_total1 where status = 50
		end
	end

--             
delete #bill where amount = 0 and charindex(sta,'35M') = 0
	--�ײ���ϸ���Ϊ 0
                                                
update #bill set number = 1 where number = 0 

select @ii = 1
while @ii <= @hline and @multi = 'T'	                    
	begin
		insert bill_dtl(pc_id) 	select @pc_id
		select @ii = @ii + 1
	end

                          
insert bill_dtl(pc_id,inumber,code,descript,descript1,unit,number,price,charge,credit,empno,logdate, sort)
select @pc_id, inumber, substring(code,1, 1) + substring(code, 5, 4), rtrim(name1), isnull(name2, ''), unit, number, round(amount / number, 2), amount,0,empno,log_date, substring('00000'+rtrim(convert(char(5), sort)),datalength('00000'+rtrim(convert(char(5), sort))) - 4, 5)
	from #bill where status < 70  order by status, menu, inumber, code

--        
if @roomno is null
	select @roomno = ''
if @name is null
	select @name = ''
                       
if @paid = 'T' 
	begin
	select @amount = convert(decimal(10,2),amount) from #bill where status = 60  
	exec p_cyj_transfer_decimal @amount, @samount output
	if not exists(select 1 from bill_mst where pc_id = @pc_id)
		begin
		insert bill_mst(pc_id,sum1,sum2)
			select @pc_id, '�ϼ�: ' + @samount, amount	from #bill where status = 60  
		update bill_mst set sum3 = name1  from #bill, bill_mst where status = 70 and pc_id = @pc_id  
		end
	else
		begin
		update bill_mst set sum1 = '�ϼ�: '+@samount,sum2=amount from bill_mst,#bill where status = 60  and pc_id = @pc_id
		update bill_mst set sum3 = name1 from bill_mst,#bill where status = 70  and pc_id = @pc_id
		end
	end
	update bill_mst set sum4 = @roomno, sum5 = @name  where pc_id = @pc_id  

return 0;
