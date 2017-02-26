if exists (select 1 from sysobjects where name = 'p_invoice_use_statistics' and type = 'P')
   drop procedure p_invoice_use_statistics
; 
--------------------------------------------------------------------------------
-- p_invoice_use_statistics
--------------------------------------------------------------------------------
create procedure p_invoice_use_statistics
	@inno0	varchar(16) ,
	@inno1	varchar(16) 
as	
begin 
	declare  @inpre	varchar(16),
				@inpre0	varchar(16),
				@inpre1	varchar(16),
				@instr	varchar(16),
				@inno2	varchar(16),
				@idx		int,
				@len		int
    create table #tmp 
	 (
		id					varchar(10)			 null,/*��Ʊ��ˮ*/
		sta				char(1)				 null,/*״̬��� O����|RԤ��|X����*/
		tag				varchar(254)		 null,/*������־ �û��Զ��壬��basecode(invoice_tag) ��ά��,��ѡ*/
		billno			char(10)				 null,/*�÷�Ʊ��Ӧ�Ľ��˵���*/   
		accnt       	char(10)  			 null,/*�÷�Ʊ��Ӧ���˺�*/
		inno        	varchar(16) 	 	 null, /*��Ʊ��*/
		credit     		money     			 null,/*���*/ 
		unitname      	varchar(50)  	    null,/*��Ʊ��λ���� = guest.name or free input */
		remark			varchar(254)		 null,/*��ע*/
		empno				varchar(10)			 null,/*�û�*/
		crtdate			datetime 			 null /*ʱ��*/
    )
    create table #tmp1 
	 (
		inno0        	varchar(16) 	 	 null, /*��Ʊ��*/
		inno1        	varchar(16) 	 	 null 
    )

		/* �����¼*/
	if @inno0 = '' and @inno1 = ''
	begin
		insert into #tmp(id,sta,billno,accnt,inno,credit,unitname,remark,empno,crtdate )
		select a.id,a.sta,a.billno,a.accnt,b.inno,b.credit,a.unitname,b.remark,b.empno,b.crtdate 
		from invoice_op a ,invoice_opdtl b
		where a.id = b.id 
	end
	else if @inno0 = ''
	begin
		insert into #tmp(id,sta,billno,accnt,inno,credit,unitname,remark,empno,crtdate )
		select a.id,a.sta,a.billno,a.accnt,b.inno,b.credit,a.unitname,b.remark,b.empno,b.crtdate 
		from invoice_op a ,invoice_opdtl b
		where a.id = b.id and b.inno <= @inno1 and char_length(@inno1) = char_length(b.inno)
	end
	else if @inno1 = ''
	begin
		insert into #tmp(id,sta,billno,accnt,inno,credit,unitname,remark,empno,crtdate )
		select a.id,a.sta,a.billno,a.accnt,b.inno,b.credit,a.unitname,b.remark,b.empno,b.crtdate 
		from invoice_op a ,invoice_opdtl b
		where a.id = b.id and b.inno >= @inno0 and char_length(@inno0) = char_length(b.inno)
	end
	else if char_length(@inno0) = char_length(@inno1)
	begin 
		insert into #tmp(id,sta,billno,accnt,inno,credit,unitname,remark,empno,crtdate )
		select a.id,a.sta,a.billno,a.accnt,b.inno,b.credit,a.unitname,b.remark,b.empno,b.crtdate 
		from invoice_op a ,invoice_opdtl b
		where a.id = b.id and 
				b.inno >= @inno0 and char_length(@inno0) = char_length(b.inno) and 
				b.inno <= @inno1  
	end
	else  
	begin 
		insert into #tmp(id,sta,billno,accnt,inno,credit,unitname,remark,empno,crtdate )
		select a.id,a.sta,a.billno,a.accnt,b.inno,b.credit,a.unitname,b.remark,b.empno,b.crtdate 
		from invoice_op a ,invoice_opdtl b
		where a.id = b.id and 
				b.inno >= @inno0 and 
				b.inno <= @inno1  
	end


	/*������������*/
	select @inno0 = '', @inno1 = ''
	declare c_2 cursor for select inno from #tmp order by inno
	open c_2
	fetch c_2 into @inno2   
	while @@sqlstatus = 0 
	begin
		label2:
		if @inno0 = '' 
		begin
			select @inno0 = @inno2
			select @len = char_length(@inno0)
			select @idx = @len
			while @idx > 0
			begin
				if substring(@inno0,@idx,1) >= '0' and substring(@inno0,@idx,1) <= '9' 
					select @idx  = @idx  - 1
				else
					break
			end
			if @idx > 1 
				select @inpre = substring(@inno0,1,@idx - 1) , @instr = substring(@inno0,@idx,@len - @idx + 1)
			else
				select @inpre = '', @instr = @inno0
			select @inpre0 = @inpre 
		end
		else
		begin
			if char_length(@inno0) <> char_length(@inno2)
			begin
				if @inno1 <> ''
					insert into #tmp1(inno0,inno1) select @inno0,@inno1 
				select @inno0 = ''
				goto label2
			end
			select @inno1 = @inno2
			select @len = char_length(@inno0)
			select @idx = @len
			while @idx > 0
			begin
				if substring(@inno0,@idx,1) >= '0' and substring(@inno0,@idx,1) <= '9' 
					select @idx  = @idx  - 1
				else
					break
			end
			if @idx > 1 
				select @inpre = substring(@inno0,1,@idx - 1) , @instr = substring(@inno0,@idx,@len - @idx + 1)
			else
				select @inpre = '', @instr = @inno0
			select @inpre1 = @inpre 
			if @inpre0 <> @inpre1  
			begin
				if @inno1 <> ''
					insert into #tmp1(inno0,inno1) select @inno0,@inno1 
				select @inno0 = @inno2,@inpre0 = @inpre 
			end

		end

		fetch c_2 into @inno2  
	end 
	close c_2
	deallocate cursor c_2
	if @inno1 <> ''
		insert into #tmp1(inno0,inno1) select @inno0,@inno1 

		
	declare c_3 cursor for select inno0,inno1 from #tmp1
	open c_3
	fetch c_3 into @inno0,@inno1    
	while @@sqlstatus = 0 
	begin
		select @len = char_length(@inno0)
		select @idx = @len
		while @idx > 0
		begin
			if substring(@inno0,@idx,1) >= '0' and substring(@inno0,@idx,1) <= '9' 
				select @idx  = @idx  - 1
			else
				break
		end
		if @idx > 1 
			select @inpre = substring(@inno0,1,@idx - 1) , @instr = substring(@inno0,@idx,@len - @idx + 1)
		else
			select @inpre = '', @instr = @inno0
		select @inno2 = @inno0,@idx = convert(int,@instr) 
		while @inno2 < @inno1
		begin
			select @idx = @idx + 1
			if @inpre = ''
				select @inno2 = right(replicate("0", 16)+convert(varchar(16),@idx),@len)
			else
				select @inno2 = @inpre + right(replicate("0", 16)+convert(varchar(16),@idx),@len - char_length(@inpre))
	
			if not exists(select 1 from #tmp where inno = @inno2) 
			begin
				 insert into #tmp(id,sta,billno,accnt,inno,credit,unitname,remark,empno,crtdate )
					select '0','','','',@inno2,null ,null, null ,null ,null 
			end 
		end

		fetch c_3 into @inno0,@inno1    
	end 
	close c_3
	deallocate cursor c_3

		/*����*/
	select * from #tmp order by inno 
end
;

-- exec p_invoice_use_statistics '','';
	 