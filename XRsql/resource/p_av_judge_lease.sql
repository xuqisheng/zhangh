if exists (select 1
          from sysobjects
          where name = 'p_av_judge_lease'
          and type = 'P')
   drop procedure p_av_judge_lease
;

/*------------------------------------------------------------------------------
Description: Ԥ����ͻ֧�� 
Reference  : Table --> res_av ,res_ooo
             View  --> <none>
             Proc  --> <none>
Parameter  : 
				@infolio   varchar(10) 		  ���ݺ�
				@inresid   varchar(10)  	  ��Դ����
				@instime   datetime	  		  ��ʼʱ��
				@inetime   datetime	  		  ����ʱ��
				@inqty     integer     		  Ԥ������ 
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

	/* get��Դ��Ϣ */
	select @resname = rtrim(name),@resqty = qty from res_plu where resid = @inresid 

	select @crlf = char(10) 

	select @msg = '��'+convert(char(10),@instime,111)+' '+convert(char(10),@instime,108)+' -- '+convert(char(10),@inetime,111)+' '+convert(char(10),@inetime,108)+'�� '+ @resname 
	select @avmsg = '' ,@ooomsg = '' 
	
	/* ά���ж� */
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
		select @ooomsg = @ooomsg + 'ά�޼�¼��' + @crlf  
		select @ooomsg = @ooomsg + '  ά�޵�  '+replicate(' ',20)+' ʱ�� '+replicate(' ',20)+'���� '+ @crlf  
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
				select @ooomsg = @ooomsg + '�ȵ�......'+ @crlf
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
	
	/* Ԥ���ж� */
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
		select @avmsg = @avmsg + 'Ԥ����¼��' + @crlf  
		select @avmsg = @avmsg + '  Ԥ����  '+replicate(' ',20)+' ʱ�� '+replicate(' ',20)+'���� '+ @crlf  
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
				select @avmsg = @avmsg + '�ȵ�......'+ @crlf
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


	/* ��ͻ��Ϣ */
	if ( @resqty - @avqty - @oooqty - @inqty < 0 )
		select @flag = 1, @msg = @msg + '  �г�ͻ!' +@crlf 
	else
		select @flag = 0, @msg = @msg +@crlf 

	select @flag,@msg,@ooomsg,@avmsg 
end
;

