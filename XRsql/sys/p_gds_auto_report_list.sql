drop proc p_gds_auto_report_list;
create proc p_gds_auto_report_list
	@empno			char(10),
	@modu_id			char(1),
	@entry			varchar(15),
	@show_son		char(1),
	@langid			integer = 0
as

declare
 	@flag				char(1),
	@lic_buy_1		varchar(255),
	@lic_buy_2		varchar(255),
	@reptag 			char(1),
	@deptno			char(3),
	@halttag			varchar(3),
	@length 			integer,
	@count 			integer,
	@sequence		integer

select @reptag  = reptag, @deptno = deptno from sys_empno where empno = @empno

select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
if @empno='FOX'
begin

		declare @lic_buy		varchar(255)
		declare c_1 cursor for select distinct rtrim(lic_buy) from auto_report
		open c_1
		fetch c_1 into @lic_buy
		while @@sqlstatus = 0
		begin
			select @lic_buy_2 = @lic_buy_2 + ','+ @lic_buy
			fetch c_1 into @lic_buy
		end
		close c_1
		deallocate cursor c_1
		select @lic_buy_2 = @lic_buy_2 + ','
end

if @show_son = 'T'
	begin
	select @flag = '%'
	if @entry = '###'
		select @entry = '%'
	end
else
	select @flag = ''


create table #goutput (
	dept			char(10)			not null,
	dept_des		varchar(255)	default '' not null,
	dept_des1	varchar(255)	default '' not null,
	dept_seq		int default 0	null,
	id				char(30)			not null,
	rid			char(30)			not null,
	descript		char(60)			not null,
	descript1	char(60)			not null,
	wtype			char(3)			default 'tab' not null,
	remark		varchar(255)	default '' not null,
	orientation	char(1)			default "0" not null,
	sys			char(1)			default "F" not null,
	halt			char(1)			default "F" not null,
	crby			char(10)			default "" not null,
	crdate		datetime			default getdate() not null,
	expby			char(10)			default "" not null,
	expdate		datetime			default getdate() not null,
	prtno			integer			default 0 not null,
	grp			varchar(16)		default '' not null,
	inher			char(100)			default '' not null,
)


-- 是否有"修改报表"的权限
if @empno='FOX'
	select @halttag = 'TFH'
else if exists (select 1 from sys_function_dtl where tag = 'D' and code = @deptno and '00' like funcsort and '0013' like funccode)
	select @halttag = 'TF'
else
	select @halttag = 'F'
--
if substring(@entry,1,2) = 'W:'
begin
	select @sequence=isnull((select sequence from auto_dept where code='W'), 0)
	select @entry = rtrim(substring(@entry,3,char_length(@entry) - 2))
	if @show_son = 'T'
		insert #goutput
			select a.code,a.descript,a.descript1,@sequence,'W:'+a.code, 'CFG'+a.code, a.descript, a.descript1, a.genput_wtype,'',
			a.genput_orientation, 'F', 'F', '', getdate(), '', getdate(), 0 ,'',''
			from syscode_maint a
			where a.genput_show = 'D' and a.code like @entry + '%' and charindex(@modu_id, a.appid) > 0
	else
		insert #goutput
			select a.code,a.descript,a.descript1,@sequence, 'W:'+a.code, 'CFG'+a.code, a.descript, a.descript1, a.genput_wtype,'',
			a.genput_orientation, 'F', 'F', '', getdate(), '', getdate(), 0 ,'',''
			from syscode_maint a
			where a.genput_show = 'D' and a.code like @entry + '%' and char_length(rtrim(a.code)) = char_length(@entry)+1  and charindex(@modu_id, a.appid) > 0


	select @length = max(char_length(rtrim(dept))) from #goutput
	do while @length > 0
		begin
		update #goutput set dept_des = rtrim(a.descript) + '->' + dept_des, dept_des1 = rtrim(a.descript1) + '->' + dept_des1
			from syscode_maint a where char_length(rtrim(#goutput.dept)) >= @length and substring(#goutput.dept, 1, @length) = a.code
		select @length = @length - 1
		end
	update #goutput set dept_des = rtrim(a.descript) + '->' + dept_des, dept_des1 = rtrim(a.descript1) + '->' + dept_des1
		from auto_dept a where a.code = 'W'
	--
	delete #goutput where dept not in (select code from syscode_maint)

end
else
begin
	if @entry = 'My Reports'
		insert #goutput select a.dept, '', '', 9999, a.id, a.rid, a.descript, a.descript1, a.wtype, a.remark,
			a.orientation, a.sys, a.halt, a.crby, a.crdate, a.expby, a.expdate, b.prtno,a.grp,''
			from auto_report a, auto_empno b where b.empno = @empno and b.id = a.id and charindex(@modu_id, a.allowmodus) > 0
	else if @entry like '	%'
		insert #goutput select a.dept, '', '', 9999, a.id, a.rid, a.descript, a.descript1, a.wtype, a.remark,
		a.orientation, a.sys, a.halt, a.crby, a.crdate, a.expby, a.expdate, b.prtno,a.grp,''
			from auto_report a, auto_empno b where b.empno = @entry and b.id = a.id and charindex(@modu_id, a.allowmodus) > 0
	else if @entry like 'E_P_%'	 
		begin
		insert #goutput select a.dept, '', '', 9999, a.id,a. rid, b.descript, b.descript1, a.wtype, a.remark, a.orientation, a.sys, a.halt, a.crby, a.crdate, a.expby, a.expdate, b.print_num,a.grp,convert(char(100),a.source)
			from auto_report a,auto_report_exp b
			where b.id=a.id and b.groupid= @entry and charindex(@modu_id, a.allowmodus) > 0  and
			((@reptag = 'T' and
			charindex(a.halt, @halttag)>0 and charindex(@modu_id, a.allowmodus) > 0
			and (a.lic_buy = '' or charindex(',' + rtrim(a.lic_buy) + ',', @lic_buy_1) > 0 or charindex(',' + rtrim(a.lic_buy) + ',', @lic_buy_2) > 0)
			and exists(select 1 from sys_rep_link c where c.code = @deptno and c.tag = 'D' and c.class = 'r'
							and ((c.funcsort = a.dept and c.funccode = a.id) or
							(a.dept like rtrim(c.funcsort) + '%' and c.funccode = '%')))
			) or
			 (@reptag = 'F' and
			charindex(a.halt, @halttag)>0 and charindex(@modu_id, a.allowmodus) > 0
			and (a.lic_buy = '' or charindex(',' + rtrim(a.lic_buy) + ',', @lic_buy_1) > 0 or charindex(',' + rtrim(a.lic_buy) + ',', @lic_buy_2) > 0)
			and exists(select 1 from sys_rep_link c where c.code = @empno and c.tag = 'E' and c.class = 'r'
							and ((c.funcsort = a.dept and c.funccode = a.id) or
							(a.dept like rtrim(c.funcsort) + '%' and c.funccode = '%')))
			))
			order by b.seq,b.id

		end
	else if @entry = '#_REPORT' and @show_son='T'
		insert #goutput select a.dept, '', '', 9999, a.id,a. rid, b.descript, b.descript1, a.wtype, a.remark, a.orientation, a.sys, a.halt, a.crby, a.crdate, a.expby, a.expdate, b.print_num,a.grp,convert(char(100),a.source)
			from auto_report a,auto_report_exp b where b.id=a.id and /*b.add_by= @empno and*/ charindex(@modu_id, a.allowmodus) > 0 order by b.seq,b.id
	else if @reptag = 'T'		--
		begin
		insert #goutput select dept, '', '', 9999, id, rid, descript, descript1, wtype, remark, orientation, sys, halt, crby, crdate, expby, expdate, 0,grp,convert(char(100),source)
			from auto_report where charindex(halt, @halttag)>0 and charindex(@modu_id, allowmodus) > 0 and dept like @entry + @flag
			and (lic_buy = '' or charindex(',' + rtrim(lic_buy) + ',', @lic_buy_1) > 0 or charindex(',' + rtrim(lic_buy) + ',', @lic_buy_2) > 0)
			and exists(select 1 from sys_rep_link a where a.code = @deptno and a.tag = 'D' and a.class = 'r'
							and ((a.funcsort = auto_report.dept and a.funccode = auto_report.id) or
							(auto_report.dept like rtrim(a.funcsort) + '%' and a.funccode = '%')))
		end
	else								--
		begin
		insert #goutput select dept, '', '', 9999, id, rid, descript, descript1, wtype, remark, orientation, sys, halt, crby, crdate, expby, expdate, 0,grp,convert(char(100),source)
			from auto_report where charindex(halt, @halttag)>0 and charindex(@modu_id, allowmodus) > 0 and dept like @entry + @flag
			and (lic_buy = '' or charindex(',' + rtrim(lic_buy) + ',', @lic_buy_1) > 0 or charindex(',' + rtrim(lic_buy) + ',', @lic_buy_2) > 0)
			and exists(select 1 from sys_rep_link a where a.code = @empno and a.tag = 'E' and a.class = 'r'
							and ((a.funcsort = auto_report.dept and a.funccode = auto_report.id) or
							(auto_report.dept like rtrim(a.funcsort) + '%' and a.funccode = '%')))
		end
	--
	select @length = max(char_length(rtrim(dept))) from #goutput
	do while @length > 0
		begin
		update #goutput set dept_des = rtrim(a.descript) + '->' + dept_des, dept_des1 = rtrim(a.descript1) + '->' + dept_des1
			from auto_dept a where char_length(rtrim(#goutput.dept)) >= @length and substring(#goutput.dept, 1, @length) = a.code
		select @length = @length - 1
		end
	--
	delete #goutput where dept not in (select code from auto_dept where halt='F')
end

--
update #goutput set dept_seq=a.sequence from auto_dept a where #goutput.dept=a.code

insert #goutput(dept,dept_des,dept_des1,dept_seq,id,rid,descript,descript1,grp)
select distinct dept,dept_des,dept_des1,dept_seq,'*','','','',grp 
from #goutput

update #goutput set inher = '' where inher not like 'id=%'
update #goutput set inher = substring(inher,4,charindex('(',inher) - 4) where inher like 'id=%'
update #goutput set inher = b.rid from auto_report b where rtrim(#goutput.inher) = rtrim(b.id)

-- 注意排序
if @langid = 0
	select id, rid, descript, substring(dept_des, 1, char_length(dept_des) - 2), wtype, remark,
		orientation, sys, halt, crby, crdate, expby, expdate, prtno, selected = 0, tag = '',grp,dept_seq, dept,inher
		from #goutput order by dept_seq, dept, grp,rid, descript
else
	select id, rid, descript1, substring(dept_des1, 1, char_length(dept_des1) - 2), wtype, remark,
		orientation, sys, halt, crby, crdate, expby, expdate, prtno, selected = 0, tag = '',grp,dept_seq, dept,inher
		from #goutput order by dept_seq, dept, grp,rid, descript1

return 0
;