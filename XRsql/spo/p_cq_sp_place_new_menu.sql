drop procedure p_cq_sp_place_new_menu;
create procedure p_cq_sp_place_new_menu
			@placecodes  char(100),
			@sort       char(2),
			@shift		char(1),
			@pc_id		char(4),
			@empno		char(10),
			@posno		char(2),
			@beg_time	datetime,
			@end_time	datetime
			
as
declare
		@menu		char(10),
		@pccode	char(5),
		@deptno  char(2),
		@bdate	datetime,
		@placecode char(5),
		@inumber	integer,
		@amount	money,
		@ret		integer,
		@msg		char(50)

select @bdate = bdate1 from sysdata 
select @inumber = 1

begin tran
save  tran p_cq_new_menu
exec @ret = p_GetAccnt1 'POS', @menu output
if @sort = '' or @sort is null
	select @pccode = rtrim(value) from sysoption where catalog = 'spo' and item = 'system_pccode'	
else
	select @pccode = pccode from sp_place_sort where  sort = @sort
select @deptno = deptno from pccode where pccode = (select chgcod from pos_pccode where pccode = @pccode)
--select @deptno,@pccode
if @ret = 0 
	insert sp_menu (tag ,tag1 ,tag2 ,tag3 ,menu ,tables ,guest ,date0 ,bdate ,shift ,deptno ,pccode ,posno ,tableno ,
	mode ,dsc_rate ,reason ,tea_rate ,serve_rate ,tax_rate ,srv ,dsc ,tax ,amount ,amount0 ,amount1 ,empno1 ,empno2 ,
	empno3 ,sta ,paid ,setmodes ,cusno ,haccnt ,tranlog ,foliono ,remark ,roomno ,accnt ,lastnum ,pcrec ,pc_id ,guestid ,
	saleid ,	empno1_name ,	cardno )
	select '0','','','',@menu,0,0,getdate(),@bdate,@shift,@deptno,@pccode,@posno,'','000',0,'',0,0,0,0,0,
		0,0,0,0,	NULL,	NULL,	@empno,'2',	'0',	NULL,	NULL,	NULL,	NULL,	NULL,	'',	NULL,	NULL,	3,	NULL,	@pc_id,	NULL,	'','',''
if @@rowcount = 0 
	select @ret = 1
else
	begin
	select @placecode = substring(@placecodes,1,charindex('#',@placecodes) - 1)
	while @placecode <> '' and @placecode is not null 
		begin
		select @placecodes = substring(@placecodes,charindex('#',@placecodes) + 1 ,datalength(@placecodes) - charindex('#',@placecodes))
		select @amount = isnull(price,0) from pos_plu where id = (select convert(integer,plucode) from sp_place where placecode = @placecode) 
		insert sp_plaav(menu,placecode,inumber,empno,bdate,shift,sta,stime,etime,amount,dishtype,dnumber,resno) select @menu,@placecode,@inumber,@empno,@bdate,@shift,'I',@beg_time,@end_time,@amount,'F',0,''
		select @inumber = @inumber + 1
		if @placecodes = '' or @placecodes is null
			select @placecode = ''
		else
			select @placecode = substring(@placecodes,1,charindex('#',@placecodes) - 1)
		end 
	end

if @ret <> 0 
	rollback tran p_cq_new_menu
commit tran p_cq_new_menu
select @msg = '生成主单出错，请重新操作!'
select @ret,@msg,@menu
;
