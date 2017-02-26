if exists(select 1 from sysobjects where name = 'p_rpt_deptempauth' and type = 'P')
	drop proc p_rpt_deptempauth
;
create proc p_rpt_deptempauth
	@mode				char(1),        -- E:人员 A:权限
	@deptno			varchar(10), 			
	@langid			int 
as
begin 
	declare
		@funcsort			varchar(10),
		@funccode			varchar(30),
		@functag				char(1)
	
	create table #lst 
	(
		id				char(10)				null,
		name			char(20)				null,
		code			varchar(10)			null,
		descript		varchar(60)			null,
		val			int		default 0	null 
	)
	create table #fun
	(
		code				char(10)				null,
	)
	
	
	if @mode = 'E'
	begin
		-----------------------------------------------------------------------------------------
		-- E:人员
		if @langid = 0 
			insert into #lst(id,name,code,descript,val) select a.empno,a.name,a.deptno,b.descript,1 
				from sys_empno a,basecode b
				where a.deptno = b.code and b.cat = 'dept' and a.deptno like @deptno+'%'
		else
			insert into #lst(id,name,code,descript,val) select a.empno,a.name,a.deptno,b.descript1,1 
				from sys_empno a,basecode b
				where a.deptno = b.code and b.cat = 'dept' and a.deptno like @deptno+'%'
		-----------------------------------------------------------------------------------------
	end
	else if @mode = 'A'
	begin
		-----------------------------------------------------------------------------------------
		-- A:权限
		if @langid = 0 
		begin
			insert into #lst(id,name,code,descript,val) 
				select a.code, a.descript,b.code,b.descript,0
				from basecode a,basecode b 
				where a.cat = 'function_class'  and b.cat = 'dept' and 
					( (b.code like @deptno+'%' /*and datalength(rtrim(b.code)) > 1*/ and @deptno <> '%') or (datalength(rtrim(b.code)) = 1 and @deptno = '%') )

			insert into #lst(id,name,code,descript,val) 
				select a.code, a.descript,b.code,b.descript,0
				from sys_function a,basecode b 
				where b.cat = 'dept'  and 
					( (b.code like @deptno+'%' /*and datalength(rtrim(b.code)) > 1*/ and @deptno <> '%') or (datalength(rtrim(b.code)) = 1 and @deptno = '%') )
		end
		else
		begin
			insert into #lst(id,name,code,descript,val) 
				select a.code, a.descript1,b.code,b.descript1,0
				from basecode a,basecode b 
				where a.cat = 'function_class'  and b.cat = 'dept'  and 
					( (b.code like @deptno+'%' /*and datalength(rtrim(b.code)) > 1*/ and @deptno <> '%') or (datalength(rtrim(b.code)) = 1 and @deptno = '%') )

			insert into #lst(id,name,code,descript,val) 
				select a.code, a.descript1,b.code,b.descript1,0
				from sys_function a,basecode b 
				where b.cat = 'dept'  and 
					( (b.code like @deptno+'%' /*and datalength(rtrim(b.code)) > 1*/ and @deptno <> '%') or (datalength(rtrim(b.code)) = 1 and @deptno = '%') )
		end 
		-----------------------------------------------------------------------------------------
		if @deptno = '%'  -- TOP LEVEL 
		begin
			update #lst set val = 1 
				from #lst a,sys_function_dtl b
				where b.code = a.code and 
				substring(a.id,1,2) = b.funcsort and b.funccode = '%' and 
				b.tag ='Z' 
			update #lst set val = 1 
				from #lst a,sys_function_dtl b
				where b.code = a.code and 
				a.id = b.funccode and 
				b.tag ='Z' 
		end 
		else
		begin
			update #lst set val = 2 
				from #lst a,sys_function_dtl b
				where b.code = a.code and b.code = @deptno and 
				substring(a.id,1,2) = b.funcsort and b.funccode = '%' and 
				b.tag ='Z' 
			update #lst set val = 2 
				from #lst a,sys_function_dtl b
				where b.code = a.code and b.code = @deptno and  
				a.id = b.funccode and 
				b.tag ='Z' 
		
			insert into #fun(code) select id from #lst where val=2
			update #lst set val = 2 
				from #lst a,#fun b
				where a.id = b.code or a.id = substring(b.code,1,2)

			delete from #lst where val <> 2 
			update #lst set val = 0 
			update #lst set val = 1 where code = @deptno 

			update #lst set val = 1 
				from #lst a,sys_function_dtl b
				where b.code = a.code and 
				substring(a.id,1,2) = b.funcsort and b.funccode = '%' and 
				b.tag ='D' 
			update #lst set val = 1 
				from #lst a,sys_function_dtl b
				where b.code = a.code and 
				a.id = b.funccode and 
				b.tag ='D' 

		end
		-----------------------------------------------------------------------------------------
	end
	select * from #lst order by id,code 
end
;

--exec p_rpt_deptempauth 'E','B',0 ;
--exec p_rpt_deptempauth 'A','B',0 ;
--drop proc p_rpt_deptempauth;

