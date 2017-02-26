if exists (select 1
          from sysobjects
          where name = 'p_av_meetroom_dotbmp1'
          and type = 'P')
   drop procedure p_av_meetroom_dotbmp1
;
/*------------------------------------------------------------------------------
Description: Meet Room Dot BMP
Reference  : Table --> res_av 
             View  --> <none>
             Proc  --> <none>
Parameter  : 
				@instime  datetime,         Start Date 
				@inetime  datetime,         End   Date 
 				@inaccnt  varchar(7) = '#'  Ref   Accnt 
Author     : ZHJ
Date       : 2002.04
------------------------------------------------------------------------------*/
create procedure p_av_meetroom_dotbmp1
	@instime  datetime, 
	@inetime  datetime, 
	@insort 	 varchar(10), 
	@inaccnt   varchar(10) = '#',  
	@inlangid  int = 0
as	
begin
 	set nocount on

--declare @judge_date datetime 
--select @judge_date = getdate()

	declare 
			@resid   varchar(10),
			@name    varchar(60), 
			@svar    varchar(50),
			@av      varchar(50),
			@ooo     varchar(50),
			@folios1 varchar(254),
			@folios2 varchar(254),
			@folios3 varchar(254),
			@folio   varchar(10),
			@sta     char(1),
			@flag    char(1),
			@self    char(1),
			@fields  integer,
			@days    integer,
			@pt      integer,
			@pt1     integer,
			@sfield  integer    

	create table #bmp
		(
			resid   varchar(10)          not null,
			name    varchar(60)	default ''  null, 
			self    varchar(50)  default ''  null,
			av      varchar(50)  default ''  null,
			ooo     varchar(50)  default ''  null,
			pos     varchar(50)  default ''  null, 
			rsv     varchar(50)  default ''  null,
			folios1 varchar(254) default ''  null,
			folios2 varchar(254) default ''  null, 
			folios3 varchar(254) default ''  null, 
			folios4 varchar(254) default ''  null,  
			folios5 varchar(254) default ''  null,  
			folios6 varchar(254) default ''  null  
		)
	if @inlangid = 0 
		insert into #bmp 
			select resid,name,
			replicate('.',50),replicate('.',50),replicate('.',50),replicate('.',50),replicate('.',50),
			'','','','','',''   
			from res_plu 
			where ('#'+sortid = @insort or resid = @insort or @insort = '###') and chkmode = 'mtr' 
	else
		insert into #bmp 
			select resid,ename,
			replicate('.',50),replicate('.',50),replicate('.',50),replicate('.',50),replicate('.',50),
			'','','','','',''   
			from res_plu 
			where ('#'+sortid = @insort or resid = @insort or @insort = '###') and chkmode = 'mtr' 
	

	select @days = datediff(day, @instime,@inetime)
	if @days>15 
		select @inetime = dateadd(day,20,@instime) ,@days = 15
                        	                     
	select @fields = 3 
	                     	             
	declare c1 cursor for
		select folio,sta,flag,resid,sfield,datediff(day, @instime,stime)*@fields+sfield, 'T'   
			from res_av 
			where ( resid in (select resid from res_plu where ('#'+sortid = @insort or resid = @insort or @insort = '###') and chkmode = 'mtr' ) ) and 
			( charindex(sta,'X')=0 ) and 
			( datediff(day,@instime,stime) >= 0 and datediff(day,@inetime,stime) <= 0)  and 
			( accnt = @inaccnt ) and ( accnt in(select accnt from master))
		union 
		select folio,sta,flag,resid,sfield,datediff(day, @instime,stime)*@fields+sfield, '.'   
			from res_av 
			where ( resid in (select resid from res_plu where ('#'+sortid = @insort or resid = @insort or @insort = '###') and chkmode = 'mtr' ) ) and 
			( charindex(sta,'X')=0 ) and 
			( datediff(day,@instime,stime) >= 0 and datediff(day,@inetime,stime) <= 0)  and 
			( accnt <> @inaccnt or '#' = @inaccnt) and ( accnt in(select accnt from master)) 
		union -- res_av_h hmaster
		select folio,sta,'T',resid,sfield,datediff(day, @instime,stime)*@fields+sfield, 'T'   
			from res_av_h 
			where ( resid in (select resid from res_plu where ('#'+sortid = @insort or resid = @insort or @insort = '###') and chkmode = 'mtr' ) ) and 
			( charindex(sta,'X')=0 ) and 
			( datediff(day,@instime,stime) >= 0 and datediff(day,@inetime,stime) <= 0)  and 
			( accnt = @inaccnt ) and ( accnt in(select accnt from hmaster))
		union 
		select folio,sta,'T',resid,sfield,datediff(day, @instime,stime)*@fields+sfield, '.'   
			from res_av_h 
			where ( resid in (select resid from res_plu where ('#'+sortid = @insort or resid = @insort or @insort = '###') and chkmode = 'mtr' ) ) and 
			( charindex(sta,'X')=0 ) and 
			( datediff(day,@instime,stime) >= 0 and datediff(day,@inetime,stime) <= 0)  and 
			( accnt <> @inaccnt or '#' = @inaccnt) and ( accnt in(select accnt from hmaster))
	open c1
	fetch c1 into @folio,@sta,@flag,@resid,@sfield,@pt,@self  
	while @@sqlstatus = 0 
	begin
		select @av = av,@svar = self,@folios1 = folios1,@folios2 = folios2 ,@folios3 = folios3 
		from #bmp 
		where resid = @resid
		                           
		select @av    = substring(@av,1,@pt - 1)+@sta+substring(@av,@pt+1,50 - @pt), 
 		       @svar  = substring(@svar,1, @pt - 1)+@self+substring(@svar,@pt+1,50 - @pt) 
		if @sfield = 1
			select @folios1 = @folios1 + '<'+rtrim(convert(char(2),@pt))+'>'+@sta+@flag +rtrim(@folio)+','
		if @sfield = 2
			select @folios2 = @folios2 + '<'+rtrim(convert(char(2),@pt))+'>'+@sta+@flag +rtrim(@folio)+','
		if @sfield = 3
			select @folios3 = @folios3 + '<'+rtrim(convert(char(2),@pt))+'>'+@sta+@flag +rtrim(@folio)+','

		update #bmp 
	   set av = @av,self = @svar,folios1 = @folios1,folios2 = @folios2,folios3 = @folios3 
		where resid= @resid

		fetch c1 into @folio,@sta,@flag,@resid,@sfield,@pt,@self  
	end
	close c1
	deallocate cursor c1

	                                  
	select  @flag = 'F' 
	declare c2 cursor for
		select folio,sta,resid,datediff(day, @instime,stime),datediff(day, @instime,etime)  
			from res_ooo  
			where ( resid in (select resid from res_plu where ('#'+sortid = @insort or resid = @insort or @insort = '###') and chkmode = 'mtr' ) ) and 
		   ( charindex(sta,'AB') > 0 ) and 
         ( (datediff(day,stime,@instime) >= 0 and datediff(day,@instime,etime) >= 0 ) or
			  (datediff(day,@instime,stime) >= 0 and datediff(day,stime,@inetime) >= 0 ) 
			)
		union -- res_ooo_h
		select folio,sta,resid,datediff(day, @instime,stime),datediff(day, @instime,etime)  
			from res_ooo_h  
			where ( resid in (select resid from res_plu where ('#'+sortid = @insort or resid = @insort or @insort = '###') and chkmode = 'mtr' ) ) and 
		   ( charindex(sta,'AB') > 0 ) and 
         ( (datediff(day,stime,@instime) >= 0 and datediff(day,@instime,etime) >= 0 ) or
			  (datediff(day,@instime,stime) >= 0 and datediff(day,stime,@inetime) >= 0 ) 
			)
	open c2
	fetch c2 into @folio,@sta,@resid,@pt,@pt1 
	while @@sqlstatus = 0 
	begin
		select @ooo = ooo,@folios1 = folios1,@folios2 = folios2,@folios3 = folios3 
		from #bmp 
		where resid = @resid
		
		if @pt < 0 
			select @pt = 1
		if @pt1 > @days
			select @pt1 = @days 
		select @pt = @pt*@fields+1,@pt1 = @pt1*@fields+@fields 
		                                            
		while( @pt <= @pt1)
		begin 
			select @ooo     = substring(@ooo,1, @pt - 1)+@sta+@sta+@sta+substring(@ooo,@pt+3,50 - @pt - 2), 
			       @folios1 = @folios1 + '<'+rtrim(convert(char(2),@pt))+'>'+@sta+@flag +rtrim(@folio)+',', 
			       @folios2 = @folios2 + '<'+rtrim(convert(char(2),@pt+1))+'>'+@sta+@flag +rtrim(@folio)+',', 
			       @folios3 = @folios3 + '<'+rtrim(convert(char(2),@pt+2))+'>'+@sta+@flag +rtrim(@folio)+',' 

			select @pt = @pt + @fields 
		end

		update #bmp set ooo = @ooo,folios1= @folios1,folios2 = @folios2,folios3 = @folios3 
		where resid= @resid

		fetch c2 into @folio,@sta,@resid,@pt,@pt1 
	end
	close c2
	deallocate cursor c2
	
	                  
	declare c3 cursor for
		select a.resno,a.sta,b.placecode,convert(int,a.shift),datediff(day, @instime,a.date0)*@fields+convert(int,a.shift) 
			from pos_reserve a, pos_pccode b   
			where ( a.pccode = b.pccode ) and 
         ( b.placecode in(select resid from res_plu where ('#'+sortid = @insort or resid = @insort or @insort = '###') and chkmode = 'mtr' ) ) and 
         ( datediff(day,@instime,a.date0) >= 0 and datediff(day,@inetime,a.date0) <= 0) and 
         ( charindex(a.sta,'127') >0 ) and (charindex(a.shift,'123')>0)
		union 
		select a.resno,a.sta,b.placecode,convert(int,a.shift),datediff(day, @instime,a.date0)*@fields+convert(int,a.shift) 
			from pos_reserve a, pos_tblsta b, pos_tblav c    
			where ( a.pccode = b.pccode ) and 
         ( a.resno = c.menu )	and 
			( b.tableno = c.tableno ) and 
         ( b.placecode in(select resid from res_plu where ('#'+sortid = @insort or resid = @insort or @insort ='###') and chkmode = 'mtr' ) ) and 
         ( datediff(day,@instime,a.date0) >= 0 and datediff(day,@inetime,a.date0) <= 0 ) and   
			( charindex(a.sta,'127') >0 ) and (charindex(a.shift,'123')>0) 
		union -- _h
		select a.resno,a.sta,b.placecode,convert(int,a.shift),datediff(day, @instime,a.date0)*@fields+convert(int,a.shift) 
			from pos_hreserve a, pos_pccode b   
			where ( a.pccode = b.pccode ) and 
         ( b.placecode in(select resid from res_plu where ('#'+sortid = @insort or resid = @insort or @insort = '###') and chkmode = 'mtr' ) ) and 
         ( datediff(day,@instime,a.date0) >= 0 and datediff(day,@inetime,a.date0) <= 0) and 
         ( charindex(a.sta,'127') >0 ) and (charindex(a.shift,'123')>0)

	open c3
	fetch c3 into @folio,@sta,@resid,@sfield,@pt 
	while @@sqlstatus = 0 
	begin
		select @av = pos,@folios1 = folios4,@folios2 = folios5 ,@folios3 = folios6
		from #bmp 
		where resid = @resid

		                
		select @av    = substring(@av,1, @pt - 1)+@sta+substring(@av,@pt+1,50 - @pt) 
		if @sfield = 1
			select @folios1 = @folios1 + '<'+rtrim(convert(char(2),@pt))+'>'+@sta+@flag +rtrim(@folio)+','
		if @sfield = 2
			select @folios2 = @folios2 + '<'+rtrim(convert(char(2),@pt))+'>'+@sta+@flag +rtrim(@folio)+','
		if @sfield = 3
			select @folios3 = @folios3 + '<'+rtrim(convert(char(2),@pt))+'>'+@sta+@flag +rtrim(@folio)+','

		update #bmp 
		set pos= @av,folios4 = @folios1,folios5 = @folios2,folios6 = @folios3 
		where resid= @resid

		fetch c3 into @folio,@sta,@resid,@sfield,@pt 
	end
	close c3
	deallocate cursor c3

	select * from #bmp order by resid 

--select 'DotBMP  ==>Second[',datediff(ss,@judge_date ,getdate()),'] Millisecond[', datediff(ms,@judge_date , getdate()),'] ',@judge_date , getdate()

	set nocount off

end;
