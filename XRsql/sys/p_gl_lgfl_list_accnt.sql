if not exists(select 1 from sysoption where catalog='hotel' and item='log_order')
	insert sysoption(catalog,item,value,def,remark,remark1,addby,addtime)
		values('hotel','log_order','1','0','0=date 1=date desc','0=date 1=date desc','GDS',getdate()); 

if exists (select * from sysobjects where name = 'p_gl_lgfl_list_accnt' and type = 'P')
	drop proc p_gl_lgfl_list_accnt;
create proc p_gl_lgfl_list_accnt
	@accnt			char(10),
	@langid			integer = 0

as
--------------------------------------------------------------------------
-- 2009.8 �Ľ� 1)ǰ̨������־�Զ����뵵����־ 2)������ʾ���� 
--------------------------------------------------------------------------
declare
	@date				datetime,
	@arr				datetime,
	@dep				datetime,
	@haccnt			char(10) 

create table #lgfl
(
	accnt				char(10)			not null,					-- �˺� 
	columnname		char(15)			not null,					-- ��Ŀ 
	tag				char(1)			default '' not null,		-- ��־���� 
	descript			char(30)			default '' not null,		-- ��Ŀ���� 
	roomno			char(5)			default '' not null,		-- ���˷��� 
	name				char(50)			default '' not null,		-- �������� 
	empno				varchar(40)			not null,					-- �û��� 
	date				datetime			not null,					-- ���� 
	old				varchar(255)		null,							-- 
	new				varchar(255)		null							-- 
)
if @accnt like 'rm:%'
begin
	-- �ͷ���־���Զ���ȴʡ����ʾ����
	declare @li_days	int
	select @li_days = convert(int, value) from sysoption where catalog='house' and item='def_log_days'
	if @@rowcount <> 1 
	begin
		insert sysoption(catalog,item,value) values('house','def_log_days','2')
		select @li_days = 2
	end
	else
		if @li_days is null  or @li_days<=0 or @li_days>31 
			select @li_days = 2
	select @li_days = -1 * @li_days
	select @date = dateadd(dd, @li_days, bdate1) from sysdata
	insert #lgfl (accnt, columnname, empno, date, old, new)
		select accnt, columnname, empno, date, old, new
		from lgfl where accnt = @accnt and date >= @date
end
else
begin 
	insert #lgfl (accnt, columnname, empno, date, old, new)
		select accnt, columnname, empno, date, old, new
		from lgfl where accnt = @accnt

	if @accnt like '[FGMCA]%'
	begin 
		select @haccnt=''
		select @haccnt=haccnt, @arr=arr, @dep=dep from master where accnt=@accnt 
		if @@rowcount = 0 
		begin 
			select @haccnt=haccnt, @arr=arr, @dep=dep from ar_master where accnt=@accnt 
			if @@rowcount = 0 
			begin 
				select @haccnt=haccnt, @arr=arr, @dep=dep from hmaster where accnt=@accnt 
				if @@rowcount = 0 
				begin 
					select @haccnt=haccnt, @arr=arr, @dep=dep from har_master where accnt=@accnt 
					if @@rowcount = 0 
						select @haccnt = '' 
				end 
			end 
		end 
	end 
	if @haccnt<>'' 
	begin 
		exec p_gl_lgfl_guest @haccnt 
		insert #lgfl (accnt, columnname, empno, date, old, new)
			select accnt, columnname, empno, date, old, new
			from lgfl where accnt = @haccnt and date>=@arr and date<=@dep 
	end 
end

if @langid = 0
	update #lgfl set descript = a.descript, tag = a.tag from lgfl_des a where #lgfl.columnname = a.columnname
else
	update #lgfl set descript = a.descript1, tag = a.tag from lgfl_des a where #lgfl.columnname = a.columnname
-- Fixed Charge & SubAccnt
if @langid = 0
begin
	update #lgfl set descript = 'FixedChg ' + rtrim(substring(#lgfl.columnname, 12, 4)) + ':' + a.descript, tag = a.tag
		from lgfl_des a where #lgfl.columnname like 'fc_%' and substring(#lgfl.columnname, 1, 11) = a.columnname
	update #lgfl set descript = 'Routing ' + rtrim(substring(#lgfl.columnname, 12, 4)) + ':' + a.descript, tag = a.tag
		from lgfl_des a where #lgfl.columnname like 'sa_%' and substring(#lgfl.columnname, 1, 11) = a.columnname
end
else
begin
	update #lgfl set descript = 'FixedChg ' + substring(#lgfl.columnname, 12, 4) + ':' + a.descript1, tag = a.tag
		from lgfl_des a where #lgfl.columnname like 'fc_%' and substring(#lgfl.columnname, 1, 11) = a.columnname
	update #lgfl set descript = 'Routing ' + substring(#lgfl.columnname, 12, 4) + ':' + a.descript1, tag = a.tag
		from lgfl_des a where #lgfl.columnname like 'sa_%' and substring(#lgfl.columnname, 1, 11) = a.columnname
end
--
--update #lgfl set roomno = a.roomno, name = b.name from master a, guest b where #lgfl.accnt = a.accnt and a.haccnt = b.no
--update #lgfl set roomno = a.roomno, name = b.name from hmaster a, guest b where #lgfl.accnt = a.accnt and a.haccnt = b.no
--update #lgfl set name = accnt + a.name from guest a where #lgfl.accnt = a.no 
update #lgfl set roomno = substring(accnt, 4, 5) where columnname like 'r_%'

update #lgfl set empno=#lgfl.empno+'-'+a.name from sys_empno a where #lgfl.empno=a.empno 
if exists(select 1 from sysoption where catalog='hotel' and item='log_order' and value='1')
	select descript, old, new, empno, date from #lgfl order by date desc 
else
	select descript, old, new, empno, date from #lgfl order by date 
;
