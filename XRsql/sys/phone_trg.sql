if exists (select * from sysobjects where name = 't_phcodeg_delete' and type = 'TR')
   drop trigger t_phcodeg_delete;
create trigger t_phcodeg_delete
   on phcodeg 
   for delete as
begin
		declare	@retmode		char(1),
					@empno		varchar(10),
					@shift		char(1),
					@pc_id		char(4),
					@appid		varchar(5) 
		execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
		--select @pc_id=pc_id, @shift=shift, @empno=empno, @appid=appid from auth_runsta where rtrim(host_id)=rtrim(host_id()) and status='R'
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'delete','phcodeg', d.id, 'É¾³ý',@empno,getdate(),d.id 
			from deleted d 
end
;


if exists (select * from sysobjects where name = 't_phcodeg_update' and type = 'TR')
   drop trigger t_phcodeg_update;
create trigger t_phcodeg_update
   on phcodeg
   for update as
begin
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5) 

	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output

	--select @pc_id=pc_id, @shift=shift, @empno=empno, @appid=appid from auth_runsta where rtrim(host_id)=rtrim(host_id()) and status='R'

	if update(descript)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'phcodeg_des','phcodeg', d.descript, i.descript,@empno,getdate(),i.id
			from inserted i ,deleted d
			where i.id = d.id 
	end
	if update(begintime)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'phcodeg_begin','phcodeg', convert(varchar(32),d.begintime), convert(varchar(32),i.begintime),@empno,getdate(),i.id
			from inserted i ,deleted d
			where i.id = d.id 
	end
	if update(endtime)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'phcodeg_end','phcodeg',  convert(varchar(32),d.endtime), convert(varchar(32),i.endtime),@empno,getdate(),i.id
			from inserted i ,deleted d
			where i.id = d.id 
	end
	if update(delay)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'phcodeg_delay','phcodeg', convert(varchar(32),d.delay), convert(varchar(32),i.delay),@empno,getdate(),i.id
			from inserted i ,deleted d
			where i.id = d.id 
	end
	if update(basesnd)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'phcodeg_base','phcodeg', convert(varchar(32),d.basesnd), convert(varchar(32),i.basesnd),@empno,getdate(),i.id
			from inserted i ,deleted d
			where i.id = d.id 
	end
	if update(stepsnd)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'phcodeg_step','phcodeg',  convert(varchar(32),d.stepsnd), convert(varchar(32),i.stepsnd),@empno,getdate(),i.id
			from inserted i ,deleted d
			where i.id = d.id 
	end
	if update(grpsnd)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'phcodeg_grp','phcodeg',  convert(varchar(32),d.grpsnd), convert(varchar(32),i.grpsnd),@empno,getdate(),i.id
			from inserted i ,deleted d
			where i.id = d.id 
	end
	if update(rate1)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'phcodeg_rate1','phcodeg',  convert(varchar(32),d.rate1), convert(varchar(32),i.rate1),@empno,getdate(),i.id
			from inserted i ,deleted d
			where i.id = d.id 
	end
	if update(rate2)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'phcodeg_rate2','phcodeg',  convert(varchar(32),d.rate2) , convert(varchar(32),i.rate2) ,@empno,getdate(),i.id
			from inserted i ,deleted d
			where i.id = d.id 
	end
	if update(sumfee)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'phcodeg_sumfee','phcodeg', convert(varchar(32),d.sumfee), convert(varchar(32),i.sumfee),@empno,getdate(),i.id
			from inserted i ,deleted d
			where i.id = d.id 
	end
	if update(seq)
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'phcodeg_seq','phcodeg', convert(varchar(32),d.seq), convert(varchar(32),i.seq),@empno,getdate(),i.id
			from inserted i ,deleted d
			where i.id = d.id 
	end
end
;

if exists (select * from sysobjects where name = 't_phcodeg_insert' and type = 'TR')
   drop trigger t_phcodeg_insert;
create trigger t_phcodeg_insert
   on phcodeg
   for insert as
begin
	declare	@old varchar(254),@new varchar(254),
				@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5) 

	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	--select @pc_id=pc_id, @shift=shift, @empno=empno, @appid=appid from auth_runsta where rtrim(host_id)=rtrim(host_id()) and status='R'
	if @@rowcount = 1
	begin
		insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
			select 'insert','phcodeg', '', 'ÄÚÈÝÔö¼Ó',@empno,getdate(),i.id
			from inserted i 
	end
end
;
