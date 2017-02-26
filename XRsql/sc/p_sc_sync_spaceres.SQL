IF OBJECT_ID('dbo.p_sc_sync_spaceres') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_sync_spaceres
    IF OBJECT_ID('dbo.p_sc_sync_spaceres') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_sync_spaceres >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_sync_spaceres >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_sync_spaceres
    @status    varchar(10),
    @accnt     char(10),
    @resno     char(10),
    @spaceid   varchar(10),
    @newspid   varchar(10)
as
declare @comspa varchar(50),
        @pos    int,
        @tmpspa varchar(10),
        @tmpcount int
--��ռ����
if @status='new' and @newspid<>'' and @newspid is not null
   begin
    --�����Ƿ��зֳ����ȸ���������
      insert sc_spacereservation(spaceid,resno,appid,restype,account,begindate,enddate,setup,setdown,layout,usemode,noisy,sshare,slock,price,status,note,cby,createdat,updatedby,updatedtime) 
					 select space,evtresno,'7',restype,account,begindate,enddate,setuptime,setdowntime,layout,eventtype,noise,sshare,slock,fprice,status,note,cby,createat,updatedby,updatedat from sc_eventreservation where evtresno=@resno      
      select @comspa=spacearound from sc_spaces where spaceid=@newspid
    	--�зֳ���	
		if @comspa<>'' and @comspa is not null
			begin
				select @pos=charindex(',',@comspa)
            --ͬ���ֳ���
						while @pos>0
							 begin
								 select @tmpspa=substring(@comspa,1,@pos -1)
								 insert sc_spacereservation(spaceid,resno,appid,restype,account,begindate,enddate,setup,setdown,layout,usemode,noisy,sshare,slock,price,status,note,cby,createdat,updatedby,updatedtime) 
										  select @tmpspa,evtresno,'7',restype,account,begindate,enddate,setuptime,setdowntime,layout,eventtype,noise,sshare,slock,fprice,status,note,cby,createat,updatedby,updatedat from sc_eventreservation where evtresno=@resno
								 select @comspa=substring(@comspa,@pos + 1,datalength(@comspa)-datalength(@tmpspa) -1)
								 select @pos=charindex(',',@comspa)
							 end
            insert sc_spacereservation(spaceid,resno,appid,restype,account,begindate,enddate,setup,setdown,layout,usemode,noisy,sshare,slock,price,status,note,cby,createdat,updatedby,updatedtime) 
										  select @comspa,evtresno,'7',restype,account,begindate,enddate,setuptime,setdowntime,layout,eventtype,noise,sshare,slock,fprice,status,note,cby,createat,updatedby,updatedat from sc_eventreservation where evtresno=@resno

		  end
      --�ж��Լ��ǲ��Ǳ��˵ķֳ���
        select @tmpcount=count(1) from sc_spaces where charindex(@newspid,spacearound) >0
        if @tmpcount>0 
           begin
				  declare c_getspa cursor for select spaceid from sc_spaces where charindex(@newspid,spacearound) >0
				  open c_getspa
				  fetch c_getspa into @tmpspa
				  while @@sqlstatus=0
						  begin
                      insert sc_spacereservation(spaceid,resno,appid,restype,account,begindate,enddate,setup,setdown,layout,usemode,noisy,sshare,slock,price,status,note,cby,createdat,updatedby,updatedtime) 
										  select @tmpspa,evtresno,'7',restype,account,begindate,enddate,setuptime,setdowntime,layout,eventtype,noise,sshare,slock,fprice,status,note,cby,createat,updatedby,updatedat from sc_eventreservation where evtresno=@resno
         				 fetch c_getspa into @tmpspa
						  end
              close c_getspa
              deallocate cursor c_getspa
           end
    end 
else
   begin
      delete sc_spacereservation where resno=@resno
      if @newspid<>'' and @newspid is not null
	    begin
   	   --�����Ƿ��зֳ����ȸ���������
      	insert sc_spacereservation(spaceid,resno,appid,restype,account,begindate,enddate,setup,setdown,layout,usemode,noisy,sshare,slock,price,status,note,cby,createdat,updatedby,updatedtime) 
					 select space,evtresno,'7',restype,account,begindate,enddate,setuptime,setdowntime,layout,eventtype,noise,sshare,slock,fprice,status,note,cby,createat,updatedby,updatedat from sc_eventreservation where evtresno=@resno      
      	select @comspa=spacearound from sc_spaces where spaceid=@newspid
    	--�зֳ���	
			if @comspa<>'' and @comspa is not null
				begin
					select @pos=charindex(',',@comspa)
            	--ͬ���ֳ���
						while @pos>0
							 begin
								 select @tmpspa=substring(@comspa,1,@pos -1)
								 insert sc_spacereservation(spaceid,resno,appid,restype,account,begindate,enddate,setup,setdown,layout,usemode,noisy,sshare,slock,price,status,note,cby,createdat,updatedby,updatedtime) 
										  select @tmpspa,evtresno,'7',restype,account,begindate,enddate,setuptime,setdowntime,layout,eventtype,noise,sshare,slock,fprice,status,note,cby,createat,updatedby,updatedat from sc_eventreservation where evtresno=@resno
								 select @comspa=substring(@comspa,@pos + 1,datalength(@comspa)-datalength(@tmpspa) -1)
								 select @pos=charindex(',',@comspa)
							 end
               insert sc_spacereservation(spaceid,resno,appid,restype,account,begindate,enddate,setup,setdown,layout,usemode,noisy,sshare,slock,price,status,note,cby,createdat,updatedby,updatedtime) 
										  select @comspa,evtresno,'7',restype,account,begindate,enddate,setuptime,setdowntime,layout,eventtype,noise,sshare,slock,fprice,status,note,cby,createat,updatedby,updatedat from sc_eventreservation where evtresno=@resno
		  		end
      --�ж��Լ��ǲ��Ǳ��˵ķֳ���
        select @tmpcount=count(1) from sc_spaces where charindex(@newspid,spacearound) >0
        if @tmpcount>0 
           begin
				  declare c_getspa cursor for select spaceid from sc_spaces where charindex(@newspid,spacearound) >0
				  open c_getspa
				  fetch c_getspa into @tmpspa
				  while @@sqlstatus=0
						  begin
                      insert sc_spacereservation(spaceid,resno,appid,restype,account,begindate,enddate,setup,setdown,layout,usemode,noisy,sshare,slock,price,status,note,cby,createdat,updatedby,updatedtime) 
										  select @tmpspa,evtresno,'7',restype,account,begindate,enddate,setuptime,setdowntime,layout,eventtype,noise,sshare,slock,fprice,status,note,cby,createat,updatedby,updatedat from sc_eventreservation where evtresno=@resno
               		 fetch c_getspa into @tmpspa
						  end
              close c_getspa
              deallocate cursor c_getspa
           end
      end 
   end
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_sync_spaceres') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_sync_spaceres >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_sync_spaceres >>>'
;