IF OBJECT_ID('dbo.p_gds_audit_release_cutoff') IS NOT NULL
    DROP PROCEDURE dbo.p_gds_audit_release_cutoff
;
create proc p_gds_audit_release_cutoff
	@empno	char(10),
   @ret     int  out,
   @msg     varchar(70) out
as
-- --------------------------------------------------------------------------
--		夜审处理：自动释放团体 cutoff 用房
-- --------------------------------------------------------------------------
select @ret = 0, @msg = ''
declare 	@bdate 		datetime,
			@grpaccnt	char(10),
			@parm			char(1),
			@id			int,
			@tmpaccnt	char(10)

select  @bdate = bdate1 from sysdata  -- 夜审后的营业日期

-- 参数获取
if not exists(select 1 from sysoption where catalog = 'reserve' and item = 'auto_cutoff')
	insert sysoption(catalog, item, value) select 'reserve', 'auto_cutoff', 'T'
select @parm = rtrim(value) from sysoption where catalog = 'reserve' and item = 'auto_cutoff'
if @parm is null or charindex(@parm, 'TtYy')=0
	select @parm = 'F'
else
	select @parm = 'T'
if @parm = 'F'
	return @ret 	-- 不做处理，直接返回

-- 处理 1: Cutoff Date - 普通团队会议 
begin tran
declare c_cutoff_date cursor for select accnt from master
	where class in ('G', 'M') and sta='R'
		and exp_dt1 is not null and datediff(dd, exp_dt1, @bdate)>0
open c_cutoff_date
fetch c_cutoff_date into @grpaccnt
while @@sqlstatus = 0
begin
insert gdsmsg select '3'
	exec p_gds_reserve_release_block @grpaccnt, @empno
	insert lgfl (columnname,accnt,old,new,empno,date,ext) values('g_cutoff',@grpaccnt,'','已执行当天cutoff',@empno,getdate(),'')
	fetch c_cutoff_date into @grpaccnt
end
close c_cutoff_date
deallocate cursor c_cutoff_date
commit tran

-- 处理 2: Cutoff Date - BLOCK 
begin tran
declare c_cutoff_date2 cursor for select accnt from sc_master
	where sta='R' and cutoff is not null and datediff(dd, cutoff, @bdate)>0
open c_cutoff_date2
fetch c_cutoff_date2 into @grpaccnt
while @@sqlstatus = 0
begin
	insert gdsmsg select '2'
	exec p_gds_sc_release_block @grpaccnt, @empno
	insert lgfl (columnname,accnt,old,new,empno,date,ext) values('g_cutoff',@grpaccnt,'','已执行当天cutoff',@empno,getdate(),'')
	fetch c_cutoff_date2 into @grpaccnt
end
close c_cutoff_date2
deallocate cursor c_cutoff_date2
commit tran

-- 处理 3: Cutoff Days - 普通团队会议 + block 
select  @tmpaccnt = ''
create table #rsvsrc(accnt char(10) null, id int null)
insert into #rsvsrc select a.accnt,a.id from rsvsrc a, master b
	where b.class in ('G', 'M') and a.accnt=b.accnt
		and b.exp_m1 is not null and b.exp_m1>=1
		and dateadd(dd, convert(int, b.exp_m1), @bdate)>a.begin_
insert into #rsvsrc select a.accnt,a.id from rsvsrc a, sc_master b
	where a.accnt=b.accnt 
		and b.exp_m1 is not null and b.exp_m1>=1
		and dateadd(dd, convert(int, b.exp_m1), @bdate)>a.begin_
begin tran
declare c_cutoff_days cursor for select accnt, id from #rsvsrc
open c_cutoff_days
fetch c_cutoff_days into @grpaccnt, @id
while @@sqlstatus = 0
begin
	if @grpaccnt is not null and @id is not null 
		begin
		if @grpaccnt <> @tmpaccnt
			begin
			insert gdsmsg select '1'
			insert lgfl (columnname,accnt,old,new,empno,date,ext) values('g_cutoff',@grpaccnt,'','已执行当天cutoff',@empno,getdate(),'')
			select @tmpaccnt = @grpaccnt 
			end
		exec p_gds_reserve_rsv_del @grpaccnt, @id, 'R', @empno, @ret output, @msg output
		end
	fetch c_cutoff_days into @grpaccnt, @id
end
close c_cutoff_days
deallocate cursor c_cutoff_days
commit tran

--
return @ret
;
