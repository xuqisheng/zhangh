if exists (select 1 from sysobjects where name = 'p_trace_employeetree' and type = 'P')
   drop procedure p_trace_employeetree
; 
--------------------------------------------------------------------------------
-- get trace linked dept. & employee treeveiw data 
--------------------------------------------------------------------------------
create procedure p_trace_employeetree
	@inmode      char(1),  -- A:all T:trace M:mail C:chat S:MailSend
	@inid        integer = 0,  
	@inlangid    integer = 0   
as	
begin 
	create table #lst
		(  
			flag     integer     null,
			id       varchar(15) null,
			pid      varchar(15) null,
			name    	varchar(60) null, 
			tvhandle	integer     null 
		)
	create table #lst1
		(  
			flag     integer    null,
			code     varchar(3) null 
		)
	-- Trace of @inid
	if ( @inmode = 'T')
	begin 
		if not exists (select 1 from message_trace where id = @inid and  receiver like '%<hotel>;%')
		begin
			-- Recv Dept.
			insert into #lst1 
				select 0,a.code 
				from basecode a, message_trace b  
				where a.cat='dept' and b.id = @inid and b.receiver like '%<D:'+ltrim(rtrim(a.code))+'>;%' 
			-- Recv Dept. Child
			insert into #lst1 
				select 0,a.code 
				from basecode a,#lst1 b 
				where a.cat = 'dept' and a.code like substring(ltrim(rtrim(b.code)),1,1)+'%' and datalength(ltrim(rtrim(b.code))) = 1 
			-- Insert Recv Dept. Employee
			insert into #lst 
				select 0 flag,'<'+ltrim(rtrim(empno))+'>' id,'<D:'+ltrim(rtrim(deptno))+'>' pid, ltrim(rtrim(name)) name,0 tvhandle 
				from sys_empno 
				where deptno in(select code from #lst1)
			-- Recv Employee Dept. 
			insert into #lst1 
				select 1,a.deptno 
				from sys_empno a, message_trace b 
				where b.id = @inid and b.receiver like '%<'+ltrim(rtrim(a.empno))+'>;%'
			-- Recv Employee Dept. Parent 
			insert into #lst1 
				select 0,a.code 
				from basecode a,#lst1 b 
				where a.cat = 'dept' and b.flag = 1 and a.code like substring(ltrim(rtrim(b.code)),1,1)+'%' and datalength(ltrim(rtrim(b.code))) = 3  

			-- Insert Recv Dept.
			insert into #lst 
				select distinct datalength(ltrim(rtrim(a.code))) flag,'<D:'+ ltrim(rtrim(a.code))+'>' id,'<D:'+ substring(ltrim(rtrim(a.code)),1,1)+'>' pid, ltrim(rtrim(a.descript)) name,0 tvhandle 
				from basecode a, #lst1 b
				where cat='dept' and a.code = b.code 
			-- Insert Recv Employee
			insert into #lst 
				select 0 flag,'<'+ltrim(rtrim(a.empno))+'>' id,'<D:'+ltrim(rtrim(a.deptno))+'>' pid, ltrim(rtrim(a.name)) name,0 tvhandle  
				from sys_empno a, message_trace b 
				where b.id = @inid and b.receiver like '%<'+ltrim(rtrim(a.empno))+'>;%'
		end 
	end
	-- Mail of @inid
	if ( @inmode = 'M')
	begin 
		if not exists (select 1 from message_trace where id = @inid and  receiver like '%<hotel>;%')
		begin
			if @inlangid = 0 
			begin
				insert into #lst 
					select datalength(ltrim(rtrim(code))) flag,'<D:'+ ltrim(rtrim(code))+'>' id,'<D:'+ substring(ltrim(rtrim(code)),1,1)+'>' pid, ltrim(rtrim(descript)) name,0 tvhandle 
					from basecode 
					where cat='dept' and 
						( 
						 code in(select a.deptno from sys_empno a, message_mailrecv b where  a.empno = b.receiver and b.id = @inid )  
						 or 
						 code in(select substring(ltrim(rtrim(a.deptno)),1,1) from sys_empno a, message_mailrecv b where  a.empno = b.receiver and b.id = @inid )  
						) 
			end
			else
			begin
				insert into #lst 
					select datalength(ltrim(rtrim(code))) flag,'<D:'+ ltrim(rtrim(code))+'>' id,'<D:'+ substring(ltrim(rtrim(code)),1,1)+'>' pid, ltrim(rtrim(descript1)) name,0 tvhandle 
					from basecode 
					where cat='dept' and 
						( 
						 code in(select a.deptno from sys_empno a, message_mailrecv b where  a.empno = b.receiver and b.id = @inid )  
						 or 
						 code in(select substring(ltrim(rtrim(a.deptno)),1,1) from sys_empno a, message_mailrecv b where  a.empno = b.receiver and b.id = @inid )  
						) 
			end
			insert into #lst 
				select 0 flag,'<'+ltrim(rtrim(a.empno))+'>' id,'<D:'+ltrim(rtrim(a.deptno))+'>' pid, ltrim(rtrim(a.name)) name,0 tvhandle  
				from sys_empno a, message_mailrecv b  
				where  a.empno = b.receiver and b.id = @inid 
			
		end 
	end
	-- Mail of @inid
	if ( @inmode = 'S')
	begin 
		if not exists (select 1 from message_trace where id = @inid and  receiver like '%<hotel>;%')
		begin
			if @inlangid = 0 
			begin
				insert into #lst 
					select datalength(ltrim(rtrim(code))) flag,'<D:'+ ltrim(rtrim(code))+'>' id,'<D:'+ substring(ltrim(rtrim(code)),1,1)+'>' pid, ltrim(rtrim(descript)) name,0 tvhandle 
					from basecode 
					where cat='dept' and 
						( 
						 code in(select a.deptno from sys_empno a, message_mailrecv b where  a.empno = b.receiver and b.id = @inid )  
						 or 
						 code in(select substring(ltrim(rtrim(a.deptno)),1,1) from sys_empno a, message_mailrecv b where  a.empno = b.receiver and b.id = @inid )  
						)  
			end
			else
			begin
				insert into #lst 
					select datalength(ltrim(rtrim(code))) flag,'<D:'+ ltrim(rtrim(code))+'>' id,'<D:'+ substring(ltrim(rtrim(code)),1,1)+'>' pid, ltrim(rtrim(descript1)) name,0 tvhandle 
					from basecode 
					where cat='dept' and 
						( 
						 code in(select a.deptno from sys_empno a, message_mailrecv b where  a.empno = b.receiver and b.id = @inid )  
						 or 
						 code in(select substring(ltrim(rtrim(a.deptno)),1,1) from sys_empno a, message_mailrecv b where  a.empno = b.receiver and b.id = @inid )  
						)  
			end
			update #lst set tvhandle = 
				(select count(*) from sys_empno b where #lst.id = '<D:'+ltrim(rtrim(b.deptno))+'>' )

			insert into #lst 
				select 0 flag,'<'+ltrim(rtrim(a.empno))+'>' id,'<D:'+ltrim(rtrim(a.deptno))+'>' pid, ltrim(rtrim(a.name)) name,0 tvhandle  
				from sys_empno a, message_mailrecv b  
				where  a.empno = b.receiver and b.id = @inid 

			update #lst set tvhandle = 
				(select count(*) from sys_empno a, message_mailrecv b where  a.empno = b.receiver and b.id = @inid and
				#lst.pid = '<D:'+ltrim(rtrim(a.deptno))+'>' ) where flag = 0

			delete from #lst where flag = 0 and tvhandle = 
				(select count(*) from sys_empno b where #lst.pid = '<D:'+ltrim(rtrim(b.deptno))+'>' )

			delete from #lst where flag > 0 and id in(select pid from #lst where flag = 0)

			delete from #lst where flag > 0 and id in(select pid from #lst where flag > 0 and id <> pid ) and id = pid
		
		end 
	end
	-- All Dept. & Employee 
	if ( @inmode = 'A')
	begin 
		if @inlangid = 0 
		begin
			insert into #lst 
				select datalength(ltrim(rtrim(code))) flag,'<D:'+ ltrim(rtrim(code))+'>' id,'<D:'+ substring(ltrim(rtrim(code)),1,1)+'>' pid, ltrim(rtrim(descript)) name,0 tvhandle 
				from basecode 
				where cat='dept' 
		end
		else
		begin
			insert into #lst 
				select datalength(ltrim(rtrim(code))) flag,'<D:'+ ltrim(rtrim(code))+'>' id,'<D:'+ substring(ltrim(rtrim(code)),1,1)+'>' pid, ltrim(rtrim(descript1)) name,0 tvhandle 
				from basecode 
				where cat='dept' 
		end
		insert into #lst 
			select 0 flag,'<'+ltrim(rtrim(empno))+'>' id,'<D:'+ltrim(rtrim(deptno))+'>' pid, ltrim(rtrim(name)) name,0 tvhandle 
			from sys_empno
	end 
	-- All Employee 
	if ( @inmode = 'C')
	begin 
		insert into #lst 
			select 0 flag,'<'+ltrim(rtrim(empno))+'>' id,'<D:'+ltrim(rtrim(deptno))+'>' pid, ltrim(rtrim(name)) name, 0 tvhandle 
			from sys_empno 
			where empno not in(select empno from auth_runsta where status = 'R')
		insert into #lst 
			select 0 flag,'<'+ltrim(rtrim(empno))+'>' id,'<D:'+ltrim(rtrim(deptno))+'>' pid, ltrim(rtrim(name)) name, 1 tvhandle 
			from sys_empno 
			where empno in(select empno from auth_runsta where status = 'R')
	end 
	-- All Affair Dept.  
	if ( @inmode = 'F')
	begin 
		if @inlangid = 0 
		begin
			insert into #lst 
				select datalength(ltrim(rtrim(code))) flag,'<D:'+ ltrim(rtrim(code))+'>' id,'<D:'+ substring(ltrim(rtrim(code)),1,1)+'>' pid, ltrim(rtrim(descript)) name,0 tvhandle 
				from basecode 
				where cat='dept' and halt = 'T'  
		end
		else
		begin
			insert into #lst 
				select datalength(ltrim(rtrim(code))) flag,'<D:'+ ltrim(rtrim(code))+'>' id,'<D:'+ substring(ltrim(rtrim(code)),1,1)+'>' pid, ltrim(rtrim(descript1)) name,0 tvhandle 
				from basecode 
				where cat='dept' and halt = 'T'   
		end
	end 
	-- Return 
	select * from #lst order by flag

end
;
