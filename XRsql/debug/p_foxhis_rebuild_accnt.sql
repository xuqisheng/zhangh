
IF OBJECT_ID('p_foxhis_rebuild_accnt') IS NOT NULL
    DROP PROCEDURE p_foxhis_rebuild_accnt
;
create proc p_foxhis_rebuild_accnt
	@mode		char(10)='' 
as
-----------------------------------------------------------------
-- 批量帐务重建  参数： FA 错误输出 gdsmsg 
-- simon 2008.4.9 
-----------------------------------------------------------------
declare
	@ret			int,
	@errcnt		int,
	@msg			varchar(60), 
	@accnt      varchar(10)

select @ret=0, @errcnt=0, @msg='' 
select @mode=isnull(rtrim(@mode), '') 

-- output ready 
delete gdsmsg 

-- master 
declare c_master cursor for select accnt from master 
	where @mode='' 
			or (accnt not like 'A%' and @mode like '%F%')
			or (accnt like 'A%' and @mode like '%A%')
	order by accnt
open c_master
fetch c_master into @accnt
while @@sqlstatus =0
begin
	exec @ret = p_gl_accnt_rebuild @accnt,'R', @msg output 
	if @ret<>0 
	begin
		select @errcnt = @errcnt + 1
		insert gdsmsg select 'Reb error:' + @accnt+'-'+@msg 
	end 
	fetch c_master into @accnt
end
close c_master
deallocate cursor c_master

-- ar_master 
declare c_ar_master cursor for select accnt from ar_master 
	where @mode='' or @mode like '%A%'
		order by accnt
open c_ar_master
fetch c_ar_master into @accnt
while @@sqlstatus =0
begin
	exec @ret = p_gl_ar_rebuild @accnt,'R', @msg output 
	if @ret<>0 
	begin
		select @errcnt = @errcnt + 1
		insert gdsmsg select 'Reb error:' + @accnt+'-'+@msg 
	end 
	fetch c_ar_master into @accnt
end
close c_ar_master
deallocate cursor c_ar_master

-- output
if @errcnt = 0 
	select '全部重建成功 All Rebuild OK !'
else
	select * from gdsmsg 
return ;
