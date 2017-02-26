drop procedure p_cq_sp_creat_menu;
create procedure p_cq_sp_creat_menu
			@placecode  char(5),
			@cardno		char(10),
			@guests		integer,
			@haccnt		char(10),
			@shift		char(1),
			@pc_id		char(4),
			@empno		char(10),
			@posno		char(2)
			
as
declare
		@menu		char(10),
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

select @bdate = bdate1 from sysdata 
select @inumber = 1
select @name1 = name,@code2 = code2 from guest where no = @haccnt
if @code2 = '' or @code2 is null
	select @code2 = isnull(min(code),'000') from pos_mode_name

begin tran
save  tran p_cq_new_menu


exec @ret = p_GetAccnt1 'POS', @menu output
if @placecode = '' or @placecode is null
	select @pccode = rtrim(value) from sysoption where catalog = 'spo' and item = 'system_pccode'	
else
	select @pccode = pccode from sp_place_sort where  sort = (select sort from sp_place where placecode = @placecode)

if @@rowcount = 0 
	select @ret = 1 ,@msg = '该场地的pccode未定义，sysoption的默认pccode也未定义!'

select @deptno = deptno from pccode where pccode = (select chgcod from pos_pccode where pccode = @pccode)
if @@rowcount = 0 
	select @ret = 1 ,@msg = '部门码错误，请检查pos_pccode的chgcod所对应的deptno!'

if @ret = 0 
	begin
	insert sp_menu (tag ,tag1 ,tag2 ,tag3 ,menu ,tables ,guest ,date0 ,bdate ,shift ,deptno ,pccode ,posno ,tableno ,
	mode ,dsc_rate ,reason ,tea_rate ,serve_rate ,tax_rate ,srv ,dsc ,tax ,amount ,amount0 ,amount1 ,empno1 ,empno2 ,
	empno3 ,sta ,paid ,setmodes ,cusno ,haccnt ,tranlog ,foliono ,remark ,roomno ,accnt ,lastnum ,pcrec ,pc_id ,guestid ,
	saleid ,	empno1_name ,	cardno )
	select '0','','','',@menu,0,@guests,getdate(),@bdate,@shift,@deptno,@pccode,@posno,'',@code2,0,'',0,0,0,0,0,
		0,0,0,0,	NULL,	NULL,	@empno,'2',	'0',	NULL,	NULL,	@haccnt,	NULL,	NULL,	'',	NULL,	NULL,	3,	NULL,	@pc_id,	NULL,	'','',@cardno
	if @@rowcount = 0 
		select @ret = 1,@msg = '生成主单出错，请重新操作!'
	end




if @ret <> 0 
	rollback tran p_cq_new_menu
commit tran p_cq_new_menu

select @ret,@msg,@menu
;
