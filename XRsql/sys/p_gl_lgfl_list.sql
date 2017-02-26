if object_id('p_gl_lgfl_list') is not null
drop proc p_gl_lgfl_list
;
create proc p_gl_lgfl_list
	@empno			char(10),
	@begin			datetime,
	@end				datetime,
	@tag				char(1),
	@langid			integer = 0,
	@prefix			varchar(254) ='ZZZ' ,
	@showpcid		char(1) = 'F'

as
create table #lgfl
(
	accnt				char(10)			not null,					/* 账号 */
	columnname		char(15)			not null,					/* 项目 */
	tag				char(1)			default '' not null,		/* 日志类型 */
	descript			char(30)			default '' not null,		/* 项目描述 */
	roomno			char(5)			default '' not null,		/* 客人房号 */
	name				char(50)			default '' not null,		/* 客人姓名 */
	empno				char(10)			not null,					/* 用户名 */
	date				datetime			not null,					/* 日期 */
	old				varchar(255)	null,							/* */
	new				varchar(255)	null,							/* */
	ext				varchar(255)	default '' null ,
	pc_id				char(5)        null			,
	pc_id_des		varchar(30)    null				
)
if rtrim(@empno) is null
	select @empno = '%'

if @tag <> '#'
begin
	insert #lgfl (accnt, columnname, empno, date, old, new,ext)
		select accnt, columnname, empno, date, old, new,isnull(ext,'') 
		from lgfl where empno like @empno and date >= @begin and date < @end and columnname like @prefix +'%' 
end
else
begin
	declare @v1 varchar(254),@v2 varchar(64), @extflag varchar(64)
	declare @p1 int
	select @v1 = @prefix
	while @v1<>'' and @v1 is not null -- datalength(@v1) >0
	begin
		select @p1 = charindex('#',@v1)
		if @p1 = 0
		begin 
			select @v2 = @v1 
			select @v1 = ''
		end
		else
		begin
			select @v2  = substring(@v1,1,@p1 - 1 )
			select @v1  = right(@v1,datalength(@v1) - @p1)
		end
		if @v2 <> ''
		begin
			select @p1 = charindex('!',@v2)
			if @p1 = 0
			begin 
				select @prefix = @v2
				insert #lgfl (accnt, columnname, empno, date, old, new,ext)
					select accnt, columnname, empno, date, old, new,isnull(ext,'') 
					from lgfl where empno like @empno and date >= @begin and date < @end and columnname like @prefix +'%' 
			end
			else
			begin
				select @prefix  = substring(@v2,1,@p1 - 1 )
				select @extflag = right(@v2,datalength(@v2) - @p1)
				insert #lgfl (accnt, columnname, empno, date, old, new,ext)
					select accnt, columnname, empno, date, old, new,isnull(ext,'') 
					from lgfl where empno like @empno and date >= @begin and date < @end and columnname like @prefix +'%' and ext like @extflag +'%'
			end
		end
	end
end 

delete #lgfl where old = new 


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
-- 宾客档案与客户档案分开
if @tag = 'P'
	delete #lgfl from guest a where #lgfl.accnt = a.no and a.class != 'F'
if @tag = 'K'
begin
	delete #lgfl from guest a where #lgfl.accnt = a.no and a.class = 'F'
	select @tag = 'P'
end
-- 其他
if @tag  = 'O'
	begin
	delete #lgfl where tag in ('A', 'B', 'C', 'P', 'R')
	update #lgfl set tag = 'O'
	end
else 
	if @tag <> '#'
		delete #lgfl where not tag like @tag

update #lgfl set roomno = a.roomno, name = b.name from master a, guest b where #lgfl.accnt = a.accnt and a.haccnt = b.no
update #lgfl set roomno = a.roomno, name = b.name from hmaster a, guest b where #lgfl.accnt = a.accnt and a.haccnt = b.no
update #lgfl set name = accnt + a.name from guest a where #lgfl.accnt = a.no 
update #lgfl set roomno = substring(accnt, 4, 5) where columnname like 'r_%' and ext = ''

-- 维护C 
---------------------------------------------------
-- basecode相关日志处理 by zhj 2008-03-05
---------------------------------------------------
update #lgfl set name = 'BaseCode ['+rtrim(a.ext)+']'
	from #lgfl a,basecode_cat b	
	where a.accnt = 'basecode'
---------------------------------------------------
---------------------------------------------------
update #lgfl set name = 'SysOption ['+a.ext +']'
	from #lgfl a 
	where a.accnt = 'sysoption'

update #lgfl set descript = a.descript+'['+a.ext+']'
	from #lgfl a 
	where a.columnname='sysoption_val' 

update #lgfl set name = 'MarketCode ['+rtrim(a.ext)+']'
	from #lgfl a,mktcode b	
	where a.ext = b.code and a.accnt = 'mktcode'

update #lgfl set name = 'SrcCode ['+rtrim(a.ext)+']'
	from #lgfl a,srccode b	
	where a.ext = b.code and a.accnt = 'srccode'

update #lgfl set name = 'ResType ['+rtrim(a.ext)+']'
	from #lgfl a,restype b	
	where a.ext = b.code and a.accnt = 'restype'

update #lgfl set name = 'GType ['+rtrim(a.ext)+']'
	from #lgfl a,gtype b	
	where a.ext = b.code and a.accnt = 'gtype'

update #lgfl set name = 'Rm.Type ['+rtrim(a.ext)+']'
	from #lgfl a,typim b	
	where a.ext = b.type and a.accnt = 'typim'

update #lgfl set name = 'Rm.RateCode ['+rtrim(a.ext)+']'
	from #lgfl a,rmratecode b	
	where a.ext = b.code and a.accnt = 'rmrc'


if @langid = 0
	update #lgfl set name = b.descript
		from #lgfl a,basecode b	
		where rtrim(a.accnt)+'_' = b.code and b.cat='lgfl_prefix' and a.name = ''
else
	update #lgfl set name = b.descript1 
		from #lgfl a,basecode b	
		where rtrim(a.accnt)+'_' = b.code and b.cat='lgfl_prefix' and a.name = ''

---------------------------------------------------
---------------------------------------------------

if @showpcid = 'T'
	begin
	update #lgfl set pc_id = a.pc_id from auth_runsta_detail a where #lgfl.empno = a.empno and #lgfl.date >= a.act_date and act_date <> null and (#lgfl.date < a.ext_date or a.ext_date = null) and db_name = rtrim(substring(db_name(),1,30))
	update #lgfl set pc_id = a.pc_id from auth_runsta_hdetail a where #lgfl.empno = a.empno and #lgfl.date >= a.act_date and #lgfl.date < a.ext_date and db_name = rtrim(substring(db_name(),1,30))
	update #lgfl set pc_id_des = a.descript from pcid_des a where #lgfl.pc_id = a.pc_id
	select accnt, tag, descript, roomno, name, date, old, new, empno, pc_id, pc_id_des from #lgfl order by date
	end
else
	select accnt, tag, descript, roomno, name, date, old, new, empno from #lgfl order by date
;