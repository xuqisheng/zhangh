if exists (select 1
          from sysobjects
          where name = 'p_av_judge_meetroom'
          and type = 'P')
   drop procedure p_av_judge_meetroom
;

/*------------------------------------------------------------------------------
Description: 预订冲突支持 
Reference  : Table --> res_av ,res_ooo,pos_reserve,pos_tblav 
             View  --> <none>
             Proc  --> <none>
Parameter  : 
				@infolio   varchar(10) 		  单据号
				@inresid   varchar(10)  	  资源代码
				@instime   datetime	  		  时间
				@insfield  integer	   	  场次
				@langid    integer	   	  语种 
Author     : ZHJ
Date       : 2002.02
------------------------------------------------------------------------------*/
create procedure p_av_judge_meetroom
				@infolio   varchar(10) 		,
				@inresid   varchar(10)  	,
				@instime   datetime	  		,
				@insfield  integer,	   	 
				@langid    integer	   	 
as	
begin
	declare  @sortid    varchar(10), 
				@resname   varchar(60),
				@fieldname varchar(60),
				@crlf      char(2),	
				@msg		  varchar(254),
				@avmsg	  varchar(254),
				@ooomsg 	  varchar(254),
				@posmsg	  varchar(254),
				@linemsg   varchar(100),
				@resqty    integer, 
				@avqty     integer, 
				@oooqty    integer,  
				@posqty    integer,
				@flag      integer, 
				@qty		  integer  

	create table #lst
	(
		txt		varchar(255) 		not null,
		ord		int 					not null,
		tag		int 					not null
	)

	/* get场次信息 */
	if @langid = 0
		select @sortid = sortid, @resname = rtrim(name),@resqty = qty from res_plu where resid = @inresid 
	else
		select @sortid = sortid, @resname = rtrim(ename),@resqty = qty from res_plu where resid = @inresid 

	if @insfield = 1
		select @fieldname = '上午'
	if @insfield = 2
		select @fieldname = '下午'
	if @insfield = 3
		select @fieldname = '晚上'

	select @crlf = char(10) 

	select @msg = '0^%1 【 %2 '+ @fieldname+'】冲突记录如下:^'+ @resname +'^' +convert(char(10),@instime,111)
	insert into #lst (txt,ord,tag) select replicate('=',30),0,1   
	insert into #lst (txt,ord,tag) select @msg,(select max(ord)+1 from #lst),0  
	insert into #lst (txt,ord,tag) select replicate('=',30),(select max(ord)+1 from #lst),1   
	
	/* 维修判断 */
	select @oooqty = sum(qty) 
	from res_ooo a 
	where ( a.resid = @inresid ) and 
			( a.folio <> @infolio ) and 
			( charindex(sta,'XC') = 0 ) and
   		( datediff(day,a.stime,@instime) >= 0 ) and
			( datediff(day,a.etime,@instime)<=0 ) 
	if @oooqty > 0 
	begin
		insert into #lst (txt,ord,tag) select '0^维修纪录：',(select max(ord)+1 from #lst),0
		declare c_1 cursor for 
			select a.folio+' ' +convert(char(10),a.stime,111)+' -- '+convert(char(10),a.etime,111) 
			from res_ooo a 
			where ( a.resid = @inresid ) and 
					( a.folio <> @infolio ) and 
					( charindex(sta,'XC') = 0 ) and
					( datediff(day,a.stime,@instime) >= 0 ) and
					( datediff(day,a.etime,@instime)<=0 ) 
		open c_1
		fetch c_1 into @linemsg  
		while @@sqlstatus = 0 
		begin
			insert into #lst (txt,ord,tag) select @linemsg,(select max(ord)+1 from #lst),1
			fetch c_1 into @linemsg  
		end 
		label1:
		close c_1
		deallocate cursor c_1 
		insert into #lst (txt,ord,tag) select replicate('-',30),(select max(ord)+1 from #lst),1   
	end	
	
	/* 预订判断 */
	select @avqty = sum(qty) 
	from res_av a 
	where ( a.resid = @inresid ) and 
			( a.sta <> 'X' ) and 
			( a.folio <> @infolio ) and 
			( datediff(day,a.stime,@instime) = 0 ) and 
			( a.sfield = @insfield )  
	if @avqty > 0 
	begin
		insert into #lst (txt,ord,tag) select '0^预订纪录：',(select max(ord)+1 from #lst),0
		declare c_2 cursor for 
			select folio+' [ACNT:'+accnt + ']  '+substring(convert(char(10),stime,108),1,5)+'-'+substring(convert(char(10),etime,108),1,5)  
			from res_av a 
			where ( a.resid = @inresid ) and 
					( a.sta <> 'X' ) and 
					( a.folio <> @infolio ) and 
					( datediff(day,a.stime,@instime) = 0 ) and 
					( a.sfield = @insfield )  
		open c_2
		fetch c_2 into @linemsg   
		while @@sqlstatus = 0 
		begin
			insert into #lst (txt,ord,tag) select @linemsg,(select max(ord)+1 from #lst),1
			fetch c_2 into @linemsg  
		end 
		label2:
		close c_2
		deallocate cursor c_2
		insert into #lst (txt,ord,tag) select replicate('-',30),(select max(ord)+1 from #lst),1   
	end	

	/* 餐饮判断 */
	select @posqty = count(*)
			from pos_reserve a, pos_pccode b   
			where ( a.pccode = b.pccode ) and 
         		( b.placecode = @inresid ) and 
         		( datediff(day,@instime,a.date0) = 0 ) and 
					( convert(int,a.shift)= @insfield - 1 or convert(int,a.shift)=@insfield  or convert(int,a.shift)=@insfield+1 ) and 
         		( charindex(a.sta,'17') >0 ) 
	select @posqty = @posqty + count(*)
			from pos_reserve a, pos_tblsta b, pos_tblav c    
			where ( a.pccode = b.pccode ) and 
		         ( a.resno = c.menu )	and 
					( b.tableno = c.tableno ) and 
         		( b.placecode = @inresid ) and 
         		( datediff(day,@instime,a.date0) = 0 ) and   
					( convert(int,a.shift)= @insfield - 1 or convert(int,a.shift)=@insfield  or convert(int,a.shift)=@insfield+1 ) and 
					( charindex(a.sta,'17') >0 ) 
	if @posqty > 0 
	begin
		insert into #lst (txt,ord,tag) select '0^餐饮纪录：',(select max(ord)+1 from #lst),0
		declare c_3 cursor for 
			select a.resno+' [ACNT:'+a.accnt+']  '+a.shift 
			from pos_reserve a, pos_pccode b   
			where ( a.pccode = b.pccode ) and 
         		( b.placecode = @inresid ) and 
         		( datediff(day,@instime,a.date0) = 0 ) and 
					( convert(int,a.shift)= @insfield - 1 or convert(int,a.shift)=@insfield  or convert(int,a.shift)=@insfield+1 ) and 
         		( charindex(a.sta,'17') >0 ) 
			union 
			select a.resno+' [ACNT:'+a.accnt+']  '+a.shift 
			from pos_reserve a, pos_tblsta b, pos_tblav c    
			where ( a.pccode = b.pccode ) and 
		         ( a.resno = c.menu )	and 
					( b.tableno = c.tableno ) and 
         		( b.placecode = @inresid ) and 
         		( datediff(day,@instime,a.date0) = 0 ) and   
					( convert(int,a.shift)= @insfield - 1 or convert(int,a.shift)=@insfield  or convert(int,a.shift)=@insfield+1 ) and 
					( charindex(a.sta,'17') >0 ) 
		open c_3
		fetch c_3 into @linemsg   
		while @@sqlstatus = 0 
		begin
			insert into #lst (txt,ord,tag) select @linemsg,(select max(ord)+1 from #lst),1
			fetch c_3 into @linemsg  
		end 
		label3:
		close c_3
		deallocate cursor c_3
		insert into #lst (txt,ord,tag) select replicate('-',30),(select max(ord)+1 from #lst),1   
	end	

	/* 冲突信息 */
	select @qty = count(*) from #lst
	if @qty = 3
		delete from #lst

	select txt,ord,tag from #lst order by ord 

end
;

