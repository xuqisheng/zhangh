

/* 对单据进行计数 */

/*
	修改日志:
	1.  票据异常纪录in_recode 加列accnt varchar(10)
	2.  加表 in_allprint      用以记所有单据打印记录
								cyj		2001/07/01
 
*/

if exists(select * from sysobjects where name = "p_cyj_count_bill" and type = 'P' )
	drop proc p_cyj_count_bill;

create proc p_cyj_count_bill 
	@instr varchar(255),    /*001-020,033,035,050-060*/
	@count_  int    output
as
declare 
	@li_pos       int,
	@li_pos1      int,
	@sbegin       varchar(255),
	@send         varchar(255)
	select @count_ = 0 
	select @li_pos = charindex(',',@instr) 
	while 1 = 1
	begin
		select @li_pos1 = charindex('-',@instr)
		if @li_pos  = 0 
		begin
			if @li_pos1 = 0 
			begin
				if ltrim(rtrim(@instr)) <>'' 
					select @count_ = @count_ + 1
			end
			else
			begin
				select @sbegin = substring(@instr, 1, @li_pos1 - 1)
				select @send = substring(@instr, @li_pos1 + 1, datalength(rtrim(@instr)) - @li_pos1 )
				select @count_ = @count_ + convert(int,@send) - convert(int,@sbegin) + 1
			end
			break
		end	
		if @li_pos1 > @li_pos or @li_pos1 = 0 
		begin
			if ltrim(rtrim(substring(@instr,1, @li_pos - 1))) <>''
			begin
				select @count_ = @count_ + 1
			end
		end
		else
		begin
			select @sbegin = substring(@instr, 1, @li_pos1 - 1)
			select @send = substring(@instr, @li_pos1 + 1, @li_pos - @li_pos1 - 1 )
			select @count_ = @count_ + convert(int,@send) - convert(int,@sbegin) + 1
		end
		select @instr = substring(@instr,@li_pos + 1,datalength(rtrim(@instr)) - @li_pos)
		select @li_pos = charindex(',',@instr)
	end

;

/* 领发票时插入in_detail*/

if exists(select * from sysobjects where name = "p_cyj_indetail_insert" and type = 'P' )
drop proc p_cyj_indetail_insert;
create proc p_cyj_indetail_insert
	@sourcestr varchar(255),
	@empno     char(10),
	@printtype char(10),
	@bnumb     int,
	@ret       int output,
	@msg       char(32) output
as
declare 
	@stmp       char(1),
	@stmp1      char(12),
	@stmp2      varchar(255),
	@sbegin     char(12),
	@send       char(12),
	@pnumb_tmp  int,
	@li_pos     int,
	@li_pos1    int,
	@li_len     int,
	@ii         int,
	@icount     int,
	@jj         int

	select @ret = 0 ,@msg = '', @sourcestr = rtrim(@sourcestr) + ','
	select @li_pos1 = 1, @li_len = datalength(@sourcestr) , @jj = 0
	begin tran  
	save  tran  t_indetail
	while @jj < 5000
 	begin
		select @li_pos =  charindex(',', @sourcestr)
		if @li_pos > 0  
		begin
			select @stmp2 = substring(@sourcestr,1,@li_pos - 1)
			select @li_pos1 = charindex('-',@stmp2) 
			if @li_pos1 > 0 
			begin
				select @sbegin = substring(@stmp2, 1, @li_pos1 - 1),
						@send = substring(@stmp2, @li_pos1 + 1, datalength(rtrim(@stmp2)) - @li_pos1)	
				select @li_len = datalength(rtrim(@sbegin)), @icount = convert(int,@send) - convert(int,@sbegin) 
				select @ii = 0				
				while @ii <= @icount and @icount > 0 and @jj < 5000
				begin
					select @jj = @jj + 1
					select @stmp1 = substring(convert(char(12),convert(int,@sbegin) + 100000000000 + @ii),12 - @li_len + 1 ,@li_len)
					select @pnumb_tmp = bnumb from in_detail where printtype = @printtype and convert(int,inno) = convert(int,@stmp1)
					if @@rowcount = 1 
					begin
						select @ret = 1 ,@msg = '该发票号已在:' + @stmp1 + '批号' + convert(char(4),@pnumb_tmp)
						break 
					end
					else
						insert into in_detail (printtype,inno,bnumb,sta,accnt,billno,pccode,modu,bdate,empno,shift,credit,modi)
						values (@printtype,rtrim(ltrim(@stmp1)),@bnumb,'0','','','','',null,@empno,'',0,'F')
					select @ii = @ii + 1
				end
			end
			else if substring(@sourcestr,1,@li_pos - 1) <> ''
				begin	
					select @stmp1 = substring(@sourcestr, 1, @li_pos - 1)
					select @pnumb_tmp = bnumb from in_detail where printtype = @printtype and convert(int,inno) = convert(int,@stmp1)
					if @@rowcount = 1 
					begin
						select @ret = 1 ,@msg = '该发票号已在:' + @stmp1 + '批号' + convert(char(4),@pnumb_tmp)
						break 
					end
					else
						insert into in_detail (printtype,inno,bnumb,sta,accnt,billno,pccode,modu,bdate,empno,shift,credit,modi)
						values (@printtype,rtrim(ltrim(@stmp1)),@bnumb,'0','','','','',null,@empno,'',0,'F')
				end
			if rtrim(@sourcestr) ='' or datalength(rtrim(@sourcestr)) - @li_pos <= 0 
				break
			select @sourcestr = substring(@sourcestr,@li_pos + 1, datalength(rtrim(@sourcestr)) - @li_pos)
		end
	end
	if @jj >= 5000
		select @ret = 1 , @msg = '一次不能领太多的单据 < 5000!!!'
	if @ret <> 0 
		rollback tran t_indetail

	commit tran 
	return @ret

;

/* 退票时删除in_detail*/

if exists(select * from sysobjects where name = "p_cyj_indetail_return" and type = 'P' )
drop proc p_cyj_indetail_return;
create proc p_cyj_indetail_return
	@sourcestr varchar(255),
	@empno     char(10),
	@empno1    char(10),
	@printtype char(10),
	@bnumb     int,
	@ret       int output,
	@msg       char(32) output
as
declare 
	@stmp       char(1),
	@stmp1      char(12),
	@stmp2      varchar(255),
	@sbegin     char(12),
	@send       char(12),
	@li_pos     int,
	@li_pos1    int,
	@li_len     int,
	@ii         int,
	@icount     int
	
	select @ret = 0 ,@msg = ''
	select @li_pos1 = 1, @li_len = datalength(rtrim(@sourcestr))
	if rtrim(ltrim(@sourcestr)) is null or rtrim(ltrim(@sourcestr)) = '0' 
		return @ret
	select @sourcestr = rtrim(@sourcestr) + ','
	begin tran
	save  tran  t_indetail
	while 1 = 1
	begin
		select @li_pos =  charindex(',', @sourcestr)
		if @li_pos > 0  
		begin
			select @stmp2 = substring(@sourcestr,1,@li_pos - 1)
			select @li_pos1 = charindex('-',@stmp2) 
			if @li_pos1 > 0 
			begin
				select @sbegin = substring(@stmp2, 1, @li_pos1 - 1),
						@send = substring(@stmp2, @li_pos1 + 1, datalength(rtrim(@stmp2)) - @li_pos1)	
				select @li_len = datalength(rtrim(@sbegin)), @icount = convert(int,@send) - convert(int,@sbegin) 
				select @ii = 0				
				while @ii <= @icount
				begin
					select @stmp1 = substring(convert(char(12),convert(int,@sbegin) + 100000000000 + @ii),12 - @li_len + 1 ,@li_len)
					if not exists(select 1 from in_detail where printtype = @printtype and inno = @stmp1)
					begin
						select @ret = 1 ,@msg = '该发票号不在in_detail: ' + @stmp1
						break 
					end
					else
						delete from in_detail where inno = @stmp1 and printtype = @printtype
					select @ii = @ii + 1
				end
			end
			else if substring(@sourcestr,1,@li_pos - 1) <> ''
				begin	
					select @stmp1 = substring(@sourcestr, 1, @li_pos - 1)
					if not exists(select 1 from in_detail where printtype = @printtype and inno = @stmp1)
					begin
						select @ret = 1 ,@msg = '该发票号不在in_detail: ' + @stmp1
						break 
					end
					else
						delete from in_detail where inno = @stmp1 and printtype = @printtype
				end
			if rtrim(@sourcestr) ='' or datalength(rtrim(@sourcestr)) - @li_pos <= 0 
				break
			select @sourcestr = substring(@sourcestr,@li_pos + 1, datalength(rtrim(@sourcestr)) - @li_pos)
//			select rtrim(@sourcestr),@li_pos
		end
	end

	if @ret <> 0 
		rollback tran t_indetail

	commit tran 
	
	return @ret
;

/* 发票领退 */

if exists(select * from sysobjects where name = "p_cyj_invoice_user" and type = 'P' )
	drop proc p_cyj_invoice_user;

create proc p_cyj_invoice_user 
	@moditype_  char(1),      /*'N'新单,'M'改单,'R'退单 */
	@printtype  char(10),     /*acheck:发票 abill:前台账单; pbill:餐饮账单;pcheck;...*/    
	@pnumb      int,          /*批号*/   
	@empno      char(10),      /*领单人 or 退单人*/
	@empno1     char(10),      /*经手人*/
	@gbound     char(255)
as
declare
	@bdate      datetime,
	@inumb      int,
	@inumb_log  int,
	@gnumb      int,
	@count      int,
	@msg        char(32),
	@ret        int
select @msg ='', @ret =0, @inumb = @pnumb
select @bdate =getdate()
begin tran 
save  tran t_invoice 
if @moditype_ = 'N'
begin
	select @inumb = isnull(max(numb),0) + 1 from invoice 
// 避免日志重复键 
	select @inumb_log = isnull(max(numb),0) + 1 from invoice_log
	if @inumb < @inumb_log 
		select @inumb = @inumb_log 
	exec p_cyj_indetail_insert @gbound,@empno,@printtype,@inumb,@ret output,@msg output
	if @ret <> 0 
		goto RET_P
	exec p_cyj_count_bill @gbound, @gnumb  output
	insert into  invoice
	values(@inumb,@printtype,@bdate,@gbound,@gnumb,'',0,'',0,'',0,@empno,@empno1,'','',null,'0',0, @empno1, getdate()) 
	if @@rowcount = 0 
		select @ret =1, @msg ='数据输入失败!'
end
if @moditype_ = 'M'
begin
	if not exists(select 1 from in_detail where sta <> '0' and bnumb = @pnumb)
	begin
		delete from in_detail where bnumb = @pnumb
		exec @ret = p_cyj_indetail_insert @gbound,@empno,@printtype,@pnumb,@ret output,@msg output
		if @ret <> 0 
			goto RET_P
		exec p_cyj_count_bill @gbound, @gnumb  output
		if not exists(select 1 from invoice_log where numb = @inumb)
			insert into invoice_log select * from invoice where numb = @inumb
		else
			update invoice set gbound = @gbound, gnumb = @gnumb, empno=@empno,empno1=@empno1,bdate=@bdate, logmark = isnull(logmark, 0) + 1 from invoice where numb=@pnumb 	
		if @@rowcount = 0 
			select @ret =1, @msg ='数据输入失败!'
	end 
	else
		select @ret = 1, @msg = '该批单据已被使用,不能修改! ' 
end
if @moditype_ = 'R'
begin
	exec @ret = p_cyj_indetail_return @gbound,@empno,@empno1,@printtype,@inumb,@ret output,@msg output
	if @ret <> 0 
		goto RET_P
	select @count = count(1) from in_detail where bnumb = @pnumb and sta = '0'
	if @count > 0 
		select @ret = 1, @msg = '还有'+convert(char(3),@count)+'张单据没被使用! 要退全退!'
	exec p_cyj_count_bill @gbound, @gnumb  output
	if not exists(select 1 from invoice_log where numb = @inumb)
		insert into invoice_log select * from invoice where numb = @inumb
	else
		update invoice set rbound = @gbound, rnumb = @gnumb, empno2=@empno,empno3=@empno1,edate=@bdate,sta = '1',logmark= isnull(logmark, 0) + 1 from invoice where numb=@pnumb 	
	if @@rowcount = 0 
		select @ret =1, @msg ='数据输入失败! -- update invoice R'
end

RET_P:

if @ret <> 0 
	rollback tran t_invoice

commit tran 
select @ret,@msg,@inumb
;

/* 发票批次删除 */

if exists(select * from sysobjects where name = "p_cyj_invoice_del" and type = 'P' )
	drop proc p_cyj_invoice_del;

create proc p_cyj_invoice_del
	@pnumb  int
as
declare @ret int , @msg char(32)
select @ret = 0 ,@msg = ''
if exists(select 1 from in_detail where bnumb = @pnumb and sta <> '0' )
	select @ret = 1 ,@msg = '该批票据已被使用, 不能删除! '
else
begin
	delete from invoice where numb = @pnumb
	delete from in_detail where bnumb = @pnumb
end
select @ret ,@msg

;

/* 单据号入列 */

if exists(select * from sysobjects where name = "p_cyj_queue_insert" and type = 'P' )
drop proc p_cyj_queue_insert;
create proc p_cyj_queue_insert
	@instr     char(12), 
	@sourcestr varchar(255) output                               
as
declare 
	@li_pos       int,
	@li_pos1      int,
	@sbegin       varchar(20),
	@send         varchar(20),
	@tstr1        varchar(255),
	@innumb       int,
	@count_       int,
	@tstr         varchar(255),
	@stmp         char(1),
	@li_len       int,
	@ret          int,
	@msg          char(32),
	@stmp1        char(60),
	@sfirst       char(255),
	@ssecond      char(255),
	@ii           int,
	@jj           int,
	@sbegin_flag  char(20),
	@send_flag    char(20)

	select @ret = 0 ,@msg =''

	/*滤掉空格*/
	select  @ii = charindex(space(1),@sourcestr)
	while @ii > 0
	begin
	   select  @sourcestr = stuff(@sourcestr,@ii,1,null)
   	select  @ii = charindex(space(1),@sourcestr)
	end 
	
	select @innumb = convert(int,@instr)

	/*方便处理*/
	select @sourcestr = '0,'+rtrim(@sourcestr) + ',9999999,'
	select @li_len = datalength(rtrim(@sourcestr))
	select @li_pos1 = 1, @tstr = @sourcestr,@sbegin = '',@send = ''
	while 1 = 1
	begin
		select @li_pos = @li_pos1 + 1,@stmp = ''
		while  charindex(@stmp ,',-') = 0  and @li_pos <= @li_len + 1 and @li_len > 0
		begin
			select @stmp = substring(@tstr,@li_pos,1)
			select @li_pos = @li_pos + 1
		end
		select @send = isnull(substring(@tstr, @li_pos1, @li_pos - @li_pos1 - 1),'')
		select @ii = charindex(',',@send)
		while @ii > 0
		begin
		   select  @send = stuff(@send,@ii,1,null)
   		select  @ii = charindex(',',@send)
		end 
		select @send_flag = isnull(substring(@tstr, @li_pos1, @li_pos - @li_pos1),'')
		select @li_pos1 = @li_pos
		if convert(int,@send) > @innumb
			break
		else if convert(int,@send) < @innumb
		begin
			select @sbegin = @send
			select @sbegin_flag = @send_flag
		end
		else
		begin
			select @ret = 1 ,@msg ='data error!'
			break
		end
		if @li_len <= @li_pos
			break
	end
	if @send > @sbegin and substring(rtrim(@sbegin_flag),datalength(rtrim(@sbegin_flag)),1) = '-'
		select @ret = 1, @msg = 'data error!'
	if charindex(rtrim(@sbegin_flag),@sourcestr) - 2 < 0 
		select @sfirst = ''
	else
		select @sfirst = rtrim(isnull(substring(@sourcestr,1,charindex(rtrim(@sbegin_flag),@sourcestr) - 2),''))
	if datalength(rtrim(@sourcestr)) - charindex(rtrim(@send_flag),@sourcestr) - datalength(rtrim(@send_flag)) < 0 
		select @ssecond = ''
	else
		select @ssecond = rtrim(isnull(substring(@sourcestr,charindex(rtrim(@send_flag),@sourcestr) + datalength(rtrim(@send_flag))  ,datalength(rtrim(@sourcestr)) - charindex(rtrim(@send_flag),@sourcestr) - datalength(rtrim(@send_flag)) + 1 ),''))
	/*
		插入的数一定大于@sbegin and 小于 @end
	*/
	if convert(int,@send) - @innumb = 1 and convert(int,@sbegin) - @innumb = -1
	begin
		if substring(@sourcestr,charindex(rtrim(@sbegin_flag),@sourcestr) - 1,1) = ','
			and substring(@sourcestr,charindex(rtrim(@send_flag),@sourcestr) + datalength(rtrim(@send)),1) = ','
			select @stmp1 = ','+@sbegin + '-' + @send+','
		else if substring(@sourcestr,charindex(rtrim(@sbegin_flag),@sourcestr) - 1,1) = ','
			and substring(@sourcestr,charindex(rtrim(@send_flag),@sourcestr) + datalength(rtrim(@send)),1) = '-'
			select @stmp1 = ','+ @sbegin +'-'
		else if substring(@sourcestr,charindex(rtrim(@sbegin_flag),@sourcestr) - 1,1) = '-'
			and substring(@sourcestr,charindex(rtrim(@send_flag),@sourcestr) + datalength(rtrim(@send)),1) = ','
			select @stmp1 = ','+@send + ','
		else if substring(@sourcestr,charindex(rtrim(@sbegin_flag),@sourcestr) - 1,1) = '-'
			and substring(@sourcestr,charindex(rtrim(@send_flag),@sourcestr) + datalength(rtrim(@send)),1) = '-'
			select @stmp1 = '-' 
	end
	else if convert(int,@send) - @innumb = 1 and convert(int,@sbegin) - @innumb < -1
	begin
		if substring(@sourcestr,charindex(rtrim(@send_flag),@sourcestr) + datalength(rtrim(@send)),1) = ','
			select @stmp1 =  isnull(substring(@sourcestr,charindex(rtrim(@sbegin_flag),@sourcestr) - 1,1),'') + @sbegin +','+@instr + '-' + @send +','
		else	if substring(@sourcestr,charindex(rtrim(@send_flag), @sourcestr) + datalength(rtrim(@send)),1) = '-'
			select @stmp1 =  isnull(substring(@sourcestr,charindex(rtrim(@sbegin_flag) ,@sourcestr) - 1,1),'') +@sbegin +','+@instr + '-' 
			
	end
	else if convert(int,@send) - @innumb > 1 and convert(int,@sbegin) - @innumb = -1
	begin
		if charindex(rtrim(@sbegin_flag), @sourcestr) - 1 <= 0
			select @stmp1 = @sbegin+'-'+@instr + ',' + @send + isnull(substring(@sourcestr,charindex(rtrim(@send_flag), @sourcestr) + datalength(rtrim(@send)),1),'')
		else if substring(@sourcestr,charindex(rtrim(@sbegin_flag), @sourcestr) - 1,1) = '-'
			select @stmp1 = '-'+@instr +',' + @send + isnull(substring(@sourcestr,charindex(rtrim(@send_flag), @sourcestr) + datalength(rtrim(@send)),1),'')
		else if substring(@sourcestr,charindex(rtrim(@sbegin_flag), @sourcestr) - 1,1) = ','
			select @stmp1 = ',' +@sbegin + '-'+@instr + ',' + @send + isnull(substring(@sourcestr,charindex(rtrim(@send_flag), @sourcestr) + datalength(rtrim(@send)),1),'')
	end
	else if convert(int,@send) - @innumb > 1 and convert(int,@sbegin) - @innumb < -1
		select @stmp1 = isnull(substring(@sourcestr,charindex(rtrim(@sbegin_flag),@sourcestr) - 1,1),'')+@sbegin + ',' + @instr + ',' + @send			+ isnull(substring(@sourcestr,charindex(rtrim(@send_flag), @sourcestr) + datalength(rtrim(@send)),1),'')      
	else
		select @ret = 1,@msg = 'error'
	select @sourcestr = rtrim(@sfirst) + rtrim(@stmp1) + rtrim(@ssecond)
	select @sourcestr = substring(@sourcestr, 3, datalength(rtrim(@sourcestr)) - 11)
	/*滤掉空格*/
	select  @ii = charindex(space(1),@sourcestr)
	while @ii > 0
	begin
	   select  @sourcestr = stuff(@sourcestr,@ii,1,null)
   	select  @ii = charindex(space(1),@sourcestr)
	end 

	if charindex(substring(@sourcestr,1,1),'-,') > 0 
		select @sourcestr = substring(@sourcestr,2,datalength(rtrim(@sourcestr)) - 1 )

;


/* 票据打印时更改in_detail*/

if exists(select * from sysobjects where name = "p_cyj_invoice_print" and type = 'P' )
drop proc p_cyj_invoice_print;
create proc p_cyj_invoice_print
	@printtype char(10),
	@empno     char(10),
	@shift     char(1),
	@accnt     char(10),
	@billno    char(10),   /* 打发票时的账单号*/   
	@inno      char(12),   /* 单据号*/   
	@credit0   money,      /* 改前金额         pos*/  
	@credit1   money,      /* 改后金额         pos*/  
	@remark0   varchar(40),/* 改前消费内容     pos*/   
	@remark1   varchar(40),/* 改后消费内容     pos*/   
	@modi      char(1),    /* 'T' OR 'F'*/
	@sta       char(1),    /* 'T' OR 'F'*/
	@accntbillno char(10)     /* account.billno */
	
as
declare
	@ubound varchar(255),
	@ucount int,
	@bnumb  int,	            /* 批号*/		
	@ret    int,      
	@msg    char(32),
	@bdate  datetime,
	@oldno  char(12),
	@auto_foliono  char(50),
	@empno1 char(10)
	
	begin tran
	save tran t_print
	if rtrim(ltrim(@inno)) like '%[^0-9]%'      -- 存在非数字字符
		select @inno = ''
	select @ret = 0, @msg = '', @ubound = '', @oldno = @inno
	select @bdate = bdate from sysdata

	-- 不需要单据管理
	if not exists( select 1 from sysoption where catalog ='audit' and item='bill' and charindex(ltrim(rtrim(value)),'tyTY') >0)
		goto RET_P

	-- 不要单据自动核销
	if exists( select 1 from sysoption where catalog ='bill' and item='auto_foliono' and charindex(rtrim(@printtype), ltrim(rtrim(value))) >0)
		goto RET_P
	
	select @inno = inno, @bnumb = bnumb from in_detail where convert(int, inno) = convert(int,@inno) and printtype =@printtype
	if @bnumb  is null
		select @bnumb = 0
	if @inno  is null
		select @inno =''

	if not exists(select 1 from in_detail where convert(int,inno) = convert(int,@inno) and printtype =@printtype )
		begin
		select @ret = 1, @msg =rtrim(@inno)+" 号单据还没有被申领!"
		insert into in_recode values(@bnumb, @empno, @bdate, getdate(), @printtype, @inno, 
			@billno,@msg,@accnt, convert(char(1), @ret))
		goto RET_D
		end 
	else
		select @oldno = @inno
	
	if exists(select 1 from in_detail where convert(int,inno) = convert(int,@inno)  and printtype =@printtype and empno =@empno and sta ='1')
	begin
		select @ret = 2, @msg =@inno+"号单据已被打印!"
		insert into in_recode values(@bnumb, @empno, @bdate, getdate(), @printtype, @inno, 
			@billno,@msg,@accnt, convert(char(1), @ret))
		goto RET_D
	end 
	if exists(select 1 from in_detail where convert(int,inno) = convert(int,@inno)  and printtype =@printtype and empno =@empno and sta ='2')
	begin
		select @ret = 3, @msg =@inno+"号单据已被报废!"
		insert into in_recode values(@bnumb, @empno, @bdate, getdate(), @printtype, @inno, 
			@billno,@msg,@accnt, convert(char(1), @ret))
		goto RET_D
	end 
	if not exists(select 1 from in_detail where convert(int,inno) = convert(int,@inno)  and printtype =@printtype and empno =@empno)
	begin
		select @empno1 = empno from in_detail where convert(int,inno) = convert(int,@inno)  and printtype =@printtype
		select @ret = 0, @msg =@inno+"本单据是"+@empno1+"领的!"
		insert into in_recode values(@bnumb, @empno, @bdate, getdate(), @printtype, @inno, 
			@billno,@inno+"--本单据是"+@empno1+"领的!",@accnt, '4')
	end 
	
	update in_detail set empno = @empno, shift =@shift,accnt =@accnt,billno =@billno,bdate =@bdate,logdate=getdate(),
		sta = '1', credit = @credit0,modi = @modi, accntbillno = @accntbillno
	from  in_detail where convert(int,inno) =convert(int,@inno) and printtype =@printtype

	declare c_cur_detail cursor for 
		select inno from in_detail where bnumb = @bnumb and sta = '1'
	open c_cur_detail
	fetch c_cur_detail into @inno
	while @@sqlstatus = 0 
	begin
		exec p_cyj_queue_insert @inno,@ubound output
		fetch c_cur_detail into @inno
	end 
	close c_cur_detail
	deallocate cursor c_cur_detail

	exec p_cyj_count_bill @ubound,@ucount output

	update invoice set ubound = @ubound ,unumb = @ucount from invoice where numb =@bnumb
	
	RET_P:
	if @ret <> 0
		rollback tran t_print

	RET_D:
	insert into in_allprint (printtype,inno,accnt,billno,modu,bdate,log_date,empno,shift,credit0,credit1,modi,remark0,remark1,sta, accntbillno)
	values(@printtype,@oldno,@accnt,@billno,'',@bdate,getdate(),@empno,@shift,@credit0,@credit1,@modi,@remark0,@remark1,convert(char(1),@ret),@accntbillno )
	commit tran 

select @ret,@msg
;

/*单据报废 */

if exists(select * from sysobjects where name = "p_cyj_invoice_discard" and type = 'P' )
drop proc p_cyj_invoice_discard;
create proc p_cyj_invoice_discard
	@pnumb int
as

declare 
	@sourcestr char(255),
	@ret       int,
	@count     int,
	@sta       char(1),
	@inno      char(12),
	@msg       char(32)

select @ret = 0, @msg = '', @sourcestr =''
select * into #bill from in_detail where 1=2
insert into #bill select * from in_detail where bnumb = @pnumb

begin tran
save  tran t_discard

declare  c_indetail  cursor for
 	select inno from #bill where sta ='2' order by inno
open c_indetail
fetch c_indetail into @inno
while @@sqlstatus = 0
begin
	exec p_cyj_queue_insert @inno,@sourcestr output
	fetch c_indetail into @inno
end

close c_indetail
deallocate cursor c_indetail

exec p_cyj_count_bill @sourcestr,@count output
update invoice set bbound = @sourcestr, bnumb = @count where numb =@pnumb
update in_detail set logdate = getdate()  where bnumb = @pnumb and sta ='2'

select @sourcestr = '' 
declare  c_indetail_1  cursor for
 	select inno from #bill where sta ='1' order by inno
open c_indetail_1
fetch c_indetail_1 into @inno
while @@sqlstatus = 0
begin
	exec p_cyj_queue_insert @inno,@sourcestr output
	fetch c_indetail_1 into @inno
end

close c_indetail_1
deallocate cursor c_indetail_1

exec p_cyj_count_bill @sourcestr,@count output
update invoice set ubound = @sourcestr, unumb = @count where numb =@pnumb

if @ret <> 0 
	rollback tran t_discard

commit tran 
select @ret , @msg
;


/* 取某批已打单据号串 */

if exists(select * from sysobjects where name = "p_cyj_get_print_invoice" and type = 'P' )
	drop procedure p_cyj_get_print_invoice;
create procedure p_cyj_get_print_invoice
	@pnumb int
as
declare  @s_object  varchar(255),
			@inno      char(12),
			@retnumb   int
select @s_object = ''
declare c_cur cursor for 
	select inno from in_detail where bnumb = @pnumb and sta = '1'

open c_cur
fetch c_cur into @inno
while @@sqlstatus = 0 
begin
	exec p_cyj_queue_insert @inno,@s_object output
	fetch c_cur into @inno
end 
close c_cur
deallocate cursor c_cur

exec p_cyj_count_bill @s_object, @retnumb output

select @retnumb, @s_object;


/* 取某批没打单据号串 */

if exists(select * from sysobjects where name = "p_cyj_get_used_invoice" and type = 'P' )
drop proc p_cyj_get_used_invoice;

create procedure p_cyj_get_used_invoice
	@pnumb int
as
declare  @s_object  varchar(255),
			@inno      char(12),
			@retnumb   int
select @s_object = ''
declare c_cur cursor for 
	select inno from in_detail where bnumb = @pnumb and sta = '0'

open c_cur
fetch c_cur into @inno
while @@sqlstatus = 0 
begin
	exec p_cyj_queue_insert @inno,@s_object output
	fetch c_cur into @inno
end 
close c_cur
deallocate cursor c_cur

exec p_cyj_count_bill @s_object, @retnumb output

select @retnumb, @s_object
;

/* 交班表取单号串 */

if exists(select * from sysobjects where name = "p_cyj_get_bills" and type = 'P' )
drop proc p_cyj_get_bills;

create procedure p_cyj_get_bills
	@printtype  char(10),
	@empno 		char(30),
	@shift  		char(10),
	@bdate      datetime	
as
declare  
	@s_object  varchar(255),
	@inno      char(12),
	@retnumb   int
select @s_object = ''
declare c_cur cursor for 
	select inno from in_allprint where (charindex(empno,@empno) > 0 or @empno ='') 
	and 	 (charindex(shift,@shift) > 0 or @shift ='') and bdate =@bdate
	and    printtype = @printtype and inno >'0' 
	order by inno
open c_cur
fetch c_cur into @inno
while @@sqlstatus = 0 
begin
	exec p_cyj_queue_insert @inno,@s_object output
	fetch c_cur into @inno
end 
close c_cur
deallocate cursor c_cur
select  @s_object
;



/* 待结单号 */
drop procedure p_cyj_get_daijie_invoice;
create procedure p_cyj_get_daijie_invoice
	@pnumb int
as
declare  @s_object  varchar(255),
			@inno      char(12),
			@retnumb   int
select @s_object = ''
declare c_cur cursor for 
	select inno from in_detail where bnumb = @pnumb and sta = '3'

open c_cur
fetch c_cur into @inno
while @@sqlstatus = 0 
begin
	exec p_cyj_queue_insert @inno,@s_object output
	fetch c_cur into @inno
end 
close c_cur
deallocate cursor c_cur

exec p_cyj_count_bill @s_object, @retnumb output

select @retnumb, @s_object;


/* 夜审处理票据打印问题：    －（还没起用）
票据打印时记录in_print, 计划打印单据用in_print, 领退单据用in_detail,夜审时将in_print导入in_detail*/

if exists(select * from sysobjects where name = "p_cyj_invoice_print_new" and type = 'P' )
	drop proc p_cyj_invoice_print_new;
create proc p_cyj_invoice_print_new
	@printtype char(10),
	@empno     char(10),
	@shift     char(1),
	@accnt     char(10),
	@billno    char(10),   /* 打发票时的账单号*/   
	@inno      char(12),   /* 单据号*/   
	@credit0   money,      /* 改前金额         pos*/  
	@credit1   money,      /* 改后金额         pos*/  
	@remark0   varchar(40),/* 改前消费内容     pos*/   
	@remark1   varchar(40),/* 改后消费内容     pos*/   
	@modi      char(1)     /* 'T' OR 'F'*/
as
declare
	@ubound varchar(255),
	@ucount int,
	@bnumb  int,	            /* 批号*/		
	@ret    int,      
	@msg    char(32),
	@bdate  datetime,
	@oldno  char(12),
	@empno1 char(10)

begin tran
save tran t_print
select @ret = 0, @msg = '', @ubound = '', @oldno = @inno
select @bdate = bdate from sysdata

if not exists( select 1 from sysoption where catalog ='audit' and item='bill' and charindex(ltrim(rtrim(value)),'tyTY') >0)
	begin
	select @ret,@msg
	return 
	end

if not exists(select 1 from in_print where printtype = @printtype and inno = @inno)
	insert into in_print(printtype,inno,accnt,billno,pccode,modu,bdate,empno,shift,credit,modi,logdate)
	select @printtype,@inno,@accnt,@billno,'','',@bdate,@empno,@shift,@credit0,@modi,getdate()

insert into in_allprint (printtype,inno,accnt,billno,modu,bdate,log_date,empno,shift,credit0,credit1,modi,remark0,remark1,sta)
values(@printtype,@oldno,@accnt,@billno,'',@bdate,getdate(),@empno,@shift,@credit0,@credit1,@modi,@remark0,@remark1,convert(char(1),@ret) )

commit tran 

select @ret,@msg
;


/* 票据审核时通过in_print更改in_detail*/

if exists(select * from sysobjects where name = "p_cyj_invoice_update" and type = 'P' )
	drop proc p_cyj_invoice_update;

create proc p_cyj_invoice_update
as
declare
	@printtype char(10),
	@empno     char(10),
	@shift     char(1),
	@accnt     char(10),
	@billno    char(10),   /* 打发票时的账单号*/   
	@inno      char(12),   /* 单据号*/   
	@credit0   money,      /* 改前金额         pos*/  
	@credit1   money,      /* 改后金额         pos*/  
	@remark0   varchar(40),/* 改前消费内容     pos*/   
	@remark1   varchar(40),/* 改后消费内容     pos*/   
	@modi      char(1),    /* 'T' OR 'F'*/
	@ubound 	  varchar(255),
	@ucount    int,
	@bnumb  	  int,	            /* 批号*/		
	@ret    	  int,      
	@msg    	  char(32),
	@bdate  	  datetime,
	@oldno  	  char(12),
	@empno1 	  char(10),
	@pccode	  char(3),
	@modu		  char(2),
	@credit	  money,
	@logdate	  datetime


select * into #bill from in_print where 1=2
insert #bill select * from in_print

begin tran
save tran t_print
declare c_cur cursor for select printtype,inno,accnt,billno,pccode,modu,bdate,empno,shift,credit,modi,logdate from #bill
open c_cur
fetch c_cur into @printtype,@inno,@accnt,@billno,@pccode,@modu,@bdate,@empno,@shift,@credit,@modi,@logdate	 
while @@sqlstatus = 0 
	begin
	select @ret = 0, @msg = '', @ubound = '', @oldno = @inno
	select @inno = inno, @bnumb = bnumb from in_detail where convert(int, inno) = convert(int,@inno) and printtype =@printtype
		if @bnumb  is null
			select @bnumb = 0
		if @inno  is null
			select @inno =''
	
		if not exists(select 1 from in_detail where convert(int,inno) = convert(int,@inno) and printtype =@printtype )
			begin
			select @ret = 1, @msg =rtrim(@inno)+" 号单据还没有被申领!"
			insert into in_recode values(@bnumb, @empno, @bdate, getdate(), @printtype, @inno, 
				@billno,@msg,@accnt, convert(char(1), @ret))
			goto RET_D
			end 
		else
			select @oldno = @inno
		
		if exists(select 1 from in_detail where convert(int,inno) = convert(int,@inno)  and printtype =@printtype and empno =@empno and sta ='1')
		begin
			select @ret = 2, @msg =@inno+"号单据已被打印!"
			insert into in_recode values(@bnumb, @empno, @bdate, getdate(), @printtype, @inno, 
				@billno,@msg,@accnt, convert(char(1), @ret))
			goto RET_D
		end 
		if exists(select 1 from in_detail where convert(int,inno) = convert(int,@inno)  and printtype =@printtype and empno =@empno and sta ='2')
		begin
			select @ret = 3, @msg =@inno+"号单据已被报废!"
			insert into in_recode values(@bnumb, @empno, @bdate, getdate(), @printtype, @inno, 
				@billno,@msg,@accnt, convert(char(1), @ret))
			goto RET_D
		end 
		if not exists(select 1 from in_detail where convert(int,inno) = convert(int,@inno)  and printtype =@printtype and empno =@empno)
		begin
			select @empno1 = empno from in_detail where convert(int,inno) = convert(int,@inno)  and printtype =@printtype
			select @ret = 0, @msg =@inno+"本单据是"+@empno1+"领的!"
			insert into in_recode values(@bnumb, @empno, @bdate, getdate(), @printtype, @inno, 
				@billno,@inno+"--本单据是"+@empno1+"领的!",@accnt, '4')
		end 
		
		update in_detail set empno = @empno, shift =@shift,accnt =@accnt,billno =@billno,bdate =@bdate,logdate=getdate(),
			sta = '1', credit = @credit0,modi = @modi
		from  in_detail where convert(int,inno) =convert(int,@inno) and printtype =@printtype
	
		declare c_cur_detail cursor for 
			select inno from in_detail where bnumb = @bnumb and sta = '1'
		open c_cur_detail
		fetch c_cur_detail into @inno
		while @@sqlstatus = 0 
		begin
			exec p_cyj_queue_insert @inno,@ubound output
			fetch c_cur_detail into @inno
		end 
		close c_cur_detail
		deallocate cursor c_cur_detail
	
		exec p_cyj_count_bill @ubound,@ucount output
	
		update invoice set ubound = @ubound ,unumb = @ucount from invoice where numb =@bnumb
		
		RET_D:
	fetch c_cur into @printtype,@inno,@accnt,@billno,@pccode,@modu,@bdate,@empno,@shift,@credit,@modi,@logdate	 
	end
close c_cur
deallocate cursor c_cur
truncate table in_print
select @ret,@msg
;


