if exists (select 1
          from sysobjects
          where name = 'p_av_judge_lease'
          and type = 'P')
   drop procedure p_av_judge_lease
;

/*------------------------------------------------------------------------------
Description: 预订冲突支持 
Reference  : Table --> res_av ,res_ooo
             View  --> <none>
             Proc  --> <none>
Parameter  : 
				@infolio   varchar(10) 		  单据号
				@inresid   varchar(10)  	  资源代码
				@instime   datetime	  		  开始时间
				@inetime   datetime	  		  结束时间
				@inqty     integer     		  预订数量 
Author     : ZHJ
Date       : 2002.02
------------------------------------------------------------------------------*/
create procedure p_av_judge_lease
				@infolio   varchar(10) 		,
				@inresid   varchar(10)  	,
				@instime   datetime	  		,
				@inetime   datetime	  		,
				@inqty     integer     		 
as	
begin
	declare  @sortid    varchar(10), 
				@resname   varchar(60),
				@fieldname varchar(60),
				@crlf      char(2),	
				@msg		  varchar(254),
				@avmsg	  varchar(254),
				@ooomsg 	  varchar(254),
				@linemsg   varchar(100),
				@resqty    integer, 
				@avqty     integer, 
				@oooqty    integer,  
				@flag      integer  

	/* get资源信息 */
	select @resname = rtrim(name),@resqty = qty from res_plu where resid = @inresid 

	select @crlf = char(10) 

	select @msg = '【'+convert(char(10),@instime,111)+' '+convert(char(10),@instime,108)+' -- '+convert(char(10),@inetime,111)+' '+convert(char(10),@inetime,108)+'】 '+ @resname 
	select @avmsg = '' ,@ooomsg = '' 
	
	/* 维修判断 */
	select @oooqty = sum(qty) 
	from res_ooo a 
	where ( a.resid = @inresid ) and 
			( a.folio <> @infolio ) and 
			( charindex(sta,'XC') = 0 ) and
			(
				( datediff(day,a.stime,@instime) < 0 and datediff(day,a.stime,@inetime)>=0 ) or
				( datediff(day,a.stime,@instime) >= 0 and datediff(day,@instime,a.etime)>=0 ) 
			) 
	if @oooqty > 0 
	begin
		select @ooomsg = @ooomsg + replicate('-',30) + @crlf  
		select @ooomsg = @ooomsg + '维修纪录：' + @crlf  
		select @ooomsg = @ooomsg + '  维修单  '+replicate(' ',20)+' 时间 '+replicate(' ',20)+'数量 '+ @crlf  
		declare c_1 cursor for 
			select a.folio+' ' +convert(char(10),a.stime,111)+' '+convert(char(10),a.stime,108)+' -- '+convert(char(10),a.stime,111)+' '+convert(char(10),a.etime,108)+' '+convert(char(3),qty)  + @crlf  
			from res_ooo a 
			where ( a.resid = @inresid ) and 
					( a.folio <> @infolio ) and 
					( charindex(sta,'XC') = 0 ) and
					(
						( datediff(day,a.stime,@instime) < 0 and datediff(day,a.stime,@inetime)>=0 ) or
						( datediff(day,a.stime,@instime) >= 0 and datediff(day,@instime,a.etime)>=0 ) 
					) 
		open c_1
		fetch c_1 into @linemsg  
		while @@sqlstatus = 0 
		begin
			if (datalength(@ooomsg + @linemsg) > 254 )
			begin 
				select @ooomsg = @ooomsg + '等等......'+ @crlf
				goto label1
			end 
			else 
				select @ooomsg = @ooomsg + @linemsg  
			fetch c_1 into @linemsg  
		end 
		label1:
		close c_1
		deallocate cursor c_1 
	end	
	
	/* 预订判断 */
	select @avqty = sum(qty) 
	from res_av a 
	where ( a.resid = @inresid ) and 
			( a.sta <> 'X' ) and 
			( a.folio <> @infolio ) and 
			(
				( datediff(day,a.stime,@instime) < 0 and datediff(day,a.stime,@inetime)>=0 ) or
				( datediff(day,a.stime,@instime) >= 0 and datediff(day,@instime,a.etime)>=0 ) 
			) 
	if @avqty > 0 
	begin
		select @avmsg = @avmsg + replicate('-',30) + @crlf  
		select @avmsg = @avmsg + '预订纪录：' + @crlf  
		select @avmsg = @avmsg + '  预订单  '+replicate(' ',20)+' 时间 '+replicate(' ',20)+'数量 '+ @crlf  
		declare c_2 cursor for 
			select a.folio+' ' +convert(char(10),a.stime,111)+' '+convert(char(10),a.stime,108)+' -- '+convert(char(10),a.stime,111)+' '+convert(char(10),a.etime,108)+' '+convert(char(3),qty)  + @crlf  
			from res_av a 
			where ( a.resid = @inresid ) and 
					( a.sta <> 'X' ) and 
					( a.folio <> @infolio ) and 
					(
						( datediff(day,a.stime,@instime) < 0 and datediff(day,a.stime,@inetime)>=0 ) or
						( datediff(day,a.stime,@instime) >= 0 and datediff(day,@instime,a.etime)>=0 ) 
					) 
		open c_2
		fetch c_2 into @linemsg   
		while @@sqlstatus = 0 
		begin
			if (datalength(@avmsg + @linemsg) > 254 )
			begin 
				select @avmsg = @avmsg + '等等......'+ @crlf
				goto label2
			end 
			else 
				select @avmsg = @avmsg + @linemsg  
			fetch c_2 into @linemsg  
		end 
		label2:
		close c_2
		deallocate cursor c_2
	end	


	/* 冲突信息 */
	if ( @resqty - @avqty - @oooqty - @inqty < 0 )
		select @flag = 1, @msg = @msg + '  有冲突!' +@crlf 
	else
		select @flag = 0, @msg = @msg +@crlf 

	select @flag,@msg,@ooomsg,@avmsg 
end
;

