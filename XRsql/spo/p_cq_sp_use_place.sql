drop procedure p_cq_sp_use_place;
create procedure p_cq_sp_use_place
			@placecode  char(5),
			@cardno		char(20),
			@guests		money,
			@haccnt		char(10),
			@shift		char(1),
			@pc_id		char(4),
			@empno		char(10),
			@posno		char(2),
			@date0		datetime,   --操作日期
			@name		   char(50),
			@tag			char(1),
			@accnt		char(10),
			@stime		datetime,
			@etime		datetime,
			@menu			char(11),
			@type			char(1)
			
as
declare
		@sp_menu	char(10),
		@pccode	char(5),
		@deptno  char(2),
		@bdate	datetime,
		@inumber	integer,
		@amount	money,
		@ret		integer,
		@msg		char(50),
		@beg_times	datetime,
		@end_times	datetime,
		@name1	char(30),
		@code2	char(3)

select @menu = substring(@menu,1,10)
select @bdate = bdate1 from sysdata 
select @name1 = name,@code2 = code2 from guest where no = @haccnt
if @code2 = '' or @code2 is null
	select @code2 = isnull(min(code),'000') from pos_mode_name

begin tran
save  tran p_cq_new_menu
--直接开单
if @type = '1'
begin
	if @menu = '' or @menu is null
	begin
		exec @ret = p_GetAccnt1 'POS', @menu output
		if @ret <> 0 
			rollback tran p_cq_new_menu
	end
	
	if @menu <> '' or @menu is not null
	begin
		select @inumber = isnull(max(inumber),0) + 1,@sp_menu = isnull(min(sp_menu),'') from sp_plaav where menu = @menu
		insert sp_plaav (	menu ,inumber ,menu1 ,tag ,vipno ,vipsno ,cno ,hno ,accnt ,guests ,placecode ,empno ,bdate ,
		shift ,sta ,sta1 ,stime ,etime ,amount ,dishtype ,dnumber ,resno ,sp_menu ,logdate,used,remark )
		select @menu,@inumber,@menu,@tag,@cardno,'','','',@accnt,@guests,@placecode,@empno,@bdate,
		@shift,'I','I',@stime,@etime,0,'F',0,'',@sp_menu,getdate(),0,@name
		if @@rowcount <> 1 
			rollback tran p_cq_new_menu
		select @menu = @menu+rtrim(convert(char,@inumber))
	end
end
--直接预订和批量预订
if @type = '2' or @type = '3'
begin
	if @menu = '' or @menu is null
	begin
		exec @ret = p_GetAccnt1 'HOS', @menu output
		select @menu = "R" + substring(@menu, 2,9)
		if @ret <> 0 
			rollback tran p_cq_new_menu

		if @placecode = '' or @placecode is null
			select @pccode = rtrim(value) from sysoption where catalog = 'spo' and item = 'system_pccode'	
		else
			select @pccode = pccode from sp_place_sort where  sort = (select sort from sp_place where placecode = @placecode)
		select @deptno = deptno from pccode where pccode = (select chgcod from pos_pccode where pccode = @pccode)

		insert sp_reserve (resno ,tag ,bdate ,date0 ,shift ,name ,unit ,phone ,tables,guest ,standent ,stdunit ,stdno ,deptno ,
			pccode ,tableno ,paymth ,mode ,sta ,cusno ,haccnt ,tranlog ,menu_header ,menu_detail ,menu_footer ,remark ,menu ,amount ,
			doc ,empno ,date ,email ,unitto ,araccnt ,accnt ,flag ,logmark ,saleid ,reserveplu ,cardno )
		 VALUES (@menu,'0',@bdate,@date0,@shift,@name1,@name,NULL,1,@guests,0,'1',NULL,@deptno,@pccode,'',
			'1',@code2,'1',NULL,@haccnt,NULL,	NULL,NULL,NULL,NULL,NULL,0,NULL,@empno,getdate(),'','','','','',0,'',NULL,	@cardno)
		if @@rowcount <> 1 
			rollback tran p_cq_new_menu
	end
	
	if @menu <> '' or @menu is not null
	begin
		select @inumber = isnull(max(inumber),0) + 1 from sp_plaav where menu = @menu
		insert sp_plaav (	menu ,inumber ,menu1 ,tag ,vipno ,vipsno ,cno ,hno ,accnt ,guests ,placecode ,empno ,bdate ,
		shift ,sta ,sta1 ,stime ,etime ,amount ,dishtype ,dnumber ,resno ,sp_menu ,logdate,used,remark )
		select @menu,@inumber,@menu,@tag,@cardno,'','','',@accnt,@guests,@placecode,@empno,@bdate,
		@shift,'R','R',@stime,@etime,0,'F',0,@menu,'',getdate(),0,''
		if @@rowcount <> 1 
			rollback tran p_cq_new_menu
	end
end
--场地维修
if @type = '5'
begin
	if @menu = '' or @menu is null
	begin
		exec @ret = p_GetAccnt1 'POS', @menu output
		if @ret <> 0 
			rollback tran p_cq_new_menu
	end
	
	if @menu <> '' or @menu is not null
	begin
		select @inumber = isnull(max(inumber),0) + 1 from sp_plaav where menu = @menu
		insert sp_plaav (	menu ,inumber ,menu1 ,tag ,vipno ,vipsno ,cno ,hno ,accnt ,guests ,placecode ,empno ,bdate ,
		shift ,sta ,sta1 ,stime ,etime ,amount ,dishtype ,dnumber ,resno ,sp_menu ,logdate,used,remark )
		select @menu,@inumber,@menu,@tag,@cardno,'','','',@accnt,@guests,@placecode,@empno,@bdate,
		@shift,'O','O',@stime,@etime,0,'F',0,'','',getdate(),0,@name
		if @@rowcount <> 1 
			rollback tran p_cq_new_menu
	end
end

if @type = '6' //6.租用结算
	begin
		exec @ret = p_GetAccnt1 'POS', @menu output
		select @pccode = rtrim(value) from sysoption where catalog = 'spo' and item = 'system_pccode'
		select @amount = price from pos_plu where id = 	(select convert(integer,value) from sysoption where catalog = 'spo' and item = 'rent')
		select @deptno = deptno from pccode where pccode = (select chgcod from pos_pccode where pccode = @pccode)
		if @ret = 0 
			insert sp_menu (tag ,tag1 ,tag2 ,tag3 ,menu ,tables ,guest ,date0 ,bdate ,shift ,deptno ,pccode ,posno ,tableno ,
			mode ,dsc_rate ,reason ,tea_rate ,serve_rate ,tax_rate ,srv ,dsc ,tax ,amount ,amount0 ,amount1 ,empno1 ,empno2 ,
			empno3 ,sta ,paid ,setmodes ,cusno ,haccnt ,tranlog ,foliono ,remark ,roomno ,accnt ,lastnum ,pcrec ,pc_id ,guestid ,
			saleid ,	empno1_name ,	cardno )
			select '0','','','',@menu,0,@guests,getdate(),@bdate,@shift,@deptno,@pccode,@posno,'',@code2,0,'',0,0,0,0,0,
				0,@amount,0,0,	NULL,	NULL,	@empno,'2',	'0',	NULL,	NULL,	'',	NULL,	@name,	'寄存柜租用',	NULL,	NULL,	3,	NULL,	@pc_id,	NULL,	'','',@cardno
			insert sp_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
			select @menu,10,a.plucode,a.sort,a.id,0,a.code,1,a.price,a.name1,a.name2,'',@empno,@bdate,'','N','0', 0,0,'',0,0,0,'', '','','',null,null from pos_plu a
				where a.id = (select convert(integer,value) from sysoption where catalog = 'spo' and item = 'rent')
			update sp_menu set amount = (select sum(a.amount) from sp_dish a where a.menu = @menu) where menu = @menu
	end 
update sp_plaav set sp_menu = '' where sp_menu is null
commit tran p_cq_new_menu
select @msg = '生成主单出错，请重新操作!'
select @ret,@msg,@menu
;
