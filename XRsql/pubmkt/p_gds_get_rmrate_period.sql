IF OBJECT_ID('p_gds_get_rmrate_period') IS NOT NULL
    DROP PROCEDURE p_gds_get_rmrate_period
;
create proc p_gds_get_rmrate_period
	@stay				datetime,					-- ��ס����
	@long				int,							-- ����
	@type				char(5),
	@roomno			char(5),
	@rmnums			int,
	@gstno			int,							-- ����
	@ratecode		char(10),					--	������
	@groupno			char(10),
	@mode				char(10)						-- check->����T/F  list->�����б�
as
-----------------------------------------------------------------------------
--				p_gds_get_rmrate_period_period  ��ȡ���䷿�� 
-----------------------------------------------------------------------------

declare	@ret			int,
			@count		int,
			@arr			datetime,
			@rmrate		money,
			@rmrate0		money,
			@diff			money,
			@msg			varchar(60),
			@lp			int

select @ret=0 , @lp = @long
select @stay = convert(datetime,convert(char(8),@stay,1))
if @long is null or @long<=0 
	select @long = 1 
select @arr = @stay 

create table #rate (
	date datetime null, 
	rate money null, 
	diff money null, 
	ret int null, 
	msg varchar(60) null
) 

select @count = 0
while @count < @lp 
begin
	exec @ret = p_gds_get_rmrate @stay,@long,@type,@roomno,@rmnums,@gstno,@ratecode,@groupno,'R',@rmrate out,@msg out 
	if @ret<>0
		select @rmrate = null
	if @count=1 
		select @diff = null 
	else
		select @diff = @rmrate - @rmrate0 
	insert #rate(date,rate,diff,ret,msg) values(@stay,@rmrate,@diff,@ret,@msg) 
	select @rmrate0 = @rmrate 
	select @count = @count + 1
	select @stay=dateadd(dd, @count, @arr),@long = @long - 1
end

-- output 
if @mode='list'
	select * from #rate
else -- check 
begin 
	if exists(select 1 from #rate where diff<>0) 
		select 'T'
	else
		select 'F' 
end
;