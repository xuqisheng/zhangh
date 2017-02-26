
if exists(select * from sysobjects where name = "p_gds_house_ooo_list")
   drop proc p_gds_house_ooo_list
;
create proc p_gds_house_ooo_list
	@dbegin	datetime,	-- 开始日期
	@din		datetime,	-- 包含日期 
	@type		char(5),
	@roomno	char(5),
	@oo		char(1),
	@os		char(1),
	@i			char(1),
	@o			char(1),
	@x			char(1),
	@his		char(1)  
as

-- OOO/OS 列表 

create table #goutput (
	folio			char(10)		not null,
	dbegin		datetime		not null,
	dend			datetime		not null,
	type			char(5)		not null,
	roomno		char(5)		not null,
	oroomno		char(5)		not null,
	status		char(1)		not null,
	sta			char(1)		not null,
	reason		char(3)		not null, 	--  原因
	remark		varchar(255) not null, 	--  描述
	empno1		char(10)		null, 		--  设定工号
	date1			datetime		null,
	empno3		char(10)		null,	    --  解除工号
	date3			datetime		null,
	empno4		char(10)		null,	    --  取消工号
	date4			datetime		null
)

-- 房态
if @oo='T'
	select @oo='O'
else
	select @oo='?'
if @os='T'
	select @os='S'
else
	select @os='?'

-- 单据状态 
if @i='T'
	select @i='I'
else
	select @i='?'
if @o='T'
	select @o='O'
else
	select @o='?'
if @x='T'
	select @x='X'
else
	select @x='?'

-- data ready 
if not ((@dbegin is null and @din is null) or (@i+@o+@x='???')) -- 直接排除无效条件 
begin 
	if @type is null
		select @type=''
	if @roomno is null
		select @roomno=''
	
	-- now 
	insert #goutput(folio,dbegin,dend,type,roomno,oroomno,status,sta,reason,remark,empno1,date1,empno3,date3,empno4,date4)
		select a.folio,a.dbegin,a.dend,b.type,a.roomno,a.oroomno,a.status,a.sta,a.reason,a.remark,
				a.empno1,a.date1,a.empno3,a.date3,a.empno4,a.date4
			from rm_ooo a, rmsta b  
			where a.roomno=b.roomno 
			--	and (@dbegin is null or a.dbegin=@dbegin) 
			--	and (@din is null or (@din>=a.dbegin and @din<a.dend))
				and (@dbegin is null or not(a.dend<@dbegin))
				and (@din is null or not(a.dbegin>@din))
				and (@type='' or @type=b.type)
				and (@roomno='' or @roomno=a.roomno)
				and a.sta in (@oo, @os)
				and a.status in (@i, @o, @x)

	-- his 
	if @his is not null and @his='T' 
		insert #goutput(folio,dbegin,dend,type,roomno,oroomno,status,sta,reason,remark,empno1,date1,empno3,date3,empno4,date4)
			select a.folio,a.dbegin,a.dend,b.type,a.roomno,a.oroomno,a.status,a.sta,a.reason,a.remark,
					a.empno1,a.date1,a.empno3,a.date3,a.empno4,a.date4
				from hrm_ooo a, rmsta b  
				where a.roomno=b.roomno 
				--	and (@dbegin is null or a.dbegin=@dbegin) 
				--	and (@din is null or (@din>=a.dbegin and @din<a.dend))
					and (@dbegin is null or not(a.dend<@dbegin))
					and (@din is null or not(a.dbegin>@din))
					and (@type='' or @type=b.type)
					and (@roomno='' or @roomno=a.roomno)
					and a.sta in (@oo, @os)
					and a.status in (@i, @o, @x)
	
	update #goutput set type=a.type from rmsta a where #goutput.roomno=a.roomno 
end 

-- output 
select folio,dbegin,dend,type,roomno,status,sta,reason,remark,empno1,date1,empno3,date3,empno4,date4
	from #goutput
	order by dbegin, oroomno, roomno 

return 0
;
