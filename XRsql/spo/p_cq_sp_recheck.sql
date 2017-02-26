drop procedure p_cq_sp_recheck;
create proc p_cq_sp_recheck
	@menu		char(10)
as
declare
	@paid						char(1),
	@current_menu			char(10),
	@empno					char(10),
	@menu_remark			char(20),
	@refer					char(20),
	@lastnum					integer,
	@nnumber					integer,
	@number					integer,
	@paycode					char(15),
	@shift					char(1),
	@pccode					char(3),
	@chgcod					char(5),
	@package					char(3),
	@tag1						char(3),
	@tag3						char(3),
	@amount					money,
	@amount1					money,
	@amount2					money,
	@amount3					money,
	@amount4					money,
	@amount5					money,
	@charge					money,
	@pc_id					char(4),
	@selemark				char(13), 
	@accnt					char(20),
	@guestid					char(20),
	@bdate					datetime,
	@ret						integer,
   @msg						char(60), 
	@count					integer,
	@sta						char(7),
	@pcrec					char(10),
	@ref						char(20),
	@pcdes					varchar(32),
	@shift_menu				char(1),
	@sftoption				char(1),
	@date0					datetime,
	@accnt_bank				char(10),		-- 信用卡对应ａｒ帐
	@lic_buy_1 				char(255),
	@lic_buy_2 				char(255),
	@bank						char(10),
	@remark					char(40),
	@foliono					char(20),
	@quantity				money

	select @ret = 0 , @msg = ''
	begin tran
	save  tran t_check
	if exists(select 1 from sp_menu where menu = @menu and sta <> '3')
		begin
		select @ret = 1, @msg = '不是结账状态'
		goto gout
		end
	select @lic_buy_1 = value from sysoption where catalog = 'hotel' and item = 'lic_buy.1'
	select @lic_buy_2 = value from sysoption where catalog = 'hotel' and item = 'lic_buy.2'
	select @pcrec = pcrec, @paid = paid, @current_menu = menu, @menu_remark = remark, @shift = shift, @empno = empno3, 
		@pccode = rtrim(pccode) + 'A', @package = ' ' + pccode, @bdate = bdate, @pc_id = pc_id	from sp_menu where menu = @menu

	if rtrim(ltrim(@pcrec)) <> null                  
		declare c_menu cursor for
			select menu,lastnum from sp_menu where pcrec =  @pcrec
	else
		declare c_menu cursor for
			select menu,lastnum from sp_menu where menu = @menu

	declare c_pay cursor for                                
	select number, paycode, - amount, accnt, remark, foliono, - quantity, bank from sp_pay
		where menu = @current_menu and charindex(sta, '23') >0 and charindex(crradjt, 'C #CO') = 0
	open c_menu
	fetch c_menu into @current_menu, @lastnum
	while @@sqlstatus =0
		begin
		select @nnumber = @lastnum, @charge = 0
		open c_pay
	fetch c_pay into @number, @paycode, @amount, @accnt,@remark, @foliono, @quantity, @bank
		while @@sqlstatus =0
			begin
			select @nnumber = max(number) + 1 from sp_pay where menu = @current_menu 
			select @tag1 = deptno2 from pccode where pccode = @paycode

			if (select value from sysoption where catalog = 'ar' and item = 'creditcard') = 'T'
				begin
				select @accnt_bank = ''
				if exists(select 1 from bankcard where pccode = @paycode)        -- 付款码判断是否自动转ar
					and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
					begin
					select @accnt_bank = accnt from bankcard where pccode = @paycode and bankcode = @bank
					if rtrim(@accnt_bank) is null
						begin
						select @ret = 1, @msg = @paycode + ' 没有转账账号'
						goto gout
						end
					end
				end

			if rtrim(@accnt) is not null and (@tag1 like "TO%"  or @accnt_bank>'')
				begin
				select @guestid = ''
				select @chgcod = chgcod from pos_pccode where pccode = @pccode
				select @selemark = 'a' + @current_menu  
				exec @ret = p_gl_accnt_posting     @selemark, '04',@pc_id,3, @shift, @empno, @accnt, 0, @chgcod, '', 1, @amount, @amount, 0,0,0,0,@current_menu, '', @bdate, '', '', 'I', 0, '', @msg output
				if @ret != 0
					rollback trigger with raiserror 55555 @msg
				end                                      
            
                           
                                                                                                                                                                                            
                   
                                                  
          
			            
                                                                      
                                                                               
                                                            
			insert into sp_pay
				select menu,@nnumber,@number,paycode,accnt,roomno,foliono,- amount,sta,'CO',reason,@empno,@bdate,@shift,getdate(),remark, menu0,bank,credit,cardno,ref,quantity
				from sp_pay where menu = @current_menu and number = @number
			update sp_pay set crradjt = 'C ' where menu = @current_menu and number = @number
			fetch c_pay into @number, @paycode, @amount, @accnt
			end
		close c_pay
		            
		select @number = inumber, @charge = amount - dsc + srv + tax from sp_dish where menu = @current_menu and sta ='A'
		if @@rowcount = 1
			begin
			update sp_dish set sta = '1' where menu = @current_menu and id = @number
			insert sp_dish(menu,inumber,plucode,sort,id, code, number, name1, name2, unit, amount,dsc,srv,tax, special, sta, empno, bdate, remark)
				select menu, @lastnum + 1,plucode,sort,id, code, - number, name1, name2, unit, - amount,- dsc,  - srv, - tax, special, '2', @empno, bdate, remark
				from sp_dish where menu = @current_menu and inumber = @number
			update sp_dish set sta = '1' where menu = @current_menu and sta ='A'
			                                  
			update sp_menu set amount = amount - @charge, lastnum = @lastnum + 1 where menu = @current_menu
			end
		update sp_pay set menu0 = '', inumber = 0 where menu0 = @current_menu
		update sp_menu set paid = '0', sta = '5', empno3 = @empno, date0 = getdate() where menu = @current_menu
		update sp_plaav set sta = 'I' where sp_menu = @current_menu and charindex(sta,'HD') >0
		update sp_menu set pcrec = '' where menu = @current_menu 
		delete pos_detail_jie where menu = @current_menu
		delete pos_detail_dai where menu = @current_menu
		fetch c_menu into @current_menu, @lastnum
		end
	close c_menu
	deallocate cursor c_pay
	deallocate cursor c_menu
gout:
	if @ret <> 0 
		rollback tran
	commit t_check
select @ret, @msg

;