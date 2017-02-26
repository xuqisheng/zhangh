drop proc p_gds_checkroom_list;
create proc p_gds_checkroom_list
	@type				char(1),  -- 1:查房 2:报房 
	@date				datetime,
	@pc_id			char(4),
	@class			char(1) --A 所有 F 散客 G 团体
as

-- 这个程序,要加强! 根据 pcid 对房号进行过滤 ! - gds
-- 针对历史日期改善 2009.8 

declare
	@type1			varchar(10), 
	@types			varchar(255), 
	@sdid				varchar(100) 


if @type = '1'
	select @type1 = '13'
else
	select @type1 = @type
	
select @types = rtrim(type), @sdid = rtrim(sdid) from checkroomset where rcid = @pc_id
if @@rowcount = 0
	select @types = null, @sdid = null
	
if datediff(dd, @date, getdate()) = 0
begin
	select a.roomno, char2 = (select e.descript from basecode e where e.code = d.vip and cat = 'vip'), a.accnt,
			a.type, a.sta, a.empno1,a.date1, a.empno2, a.date2, a.empno3, a.date3, a.refer,a.pc_id,e.haccnt,e.groupno,e.cusno, d.vip, c.arr, datediff(ss, c.arr, a.date1) 
		from checkroom a, rmsta b, master c,guest d, master_des e
		where a.roomno = b.roomno and (rtrim(@types) is null or charindex(','+rtrim(b.type)+',', ','+@types+',') > 0)
			and ( rtrim(@sdid) is null or charindex(a.pc_id, @sdid) > 0 ) 
			and datediff(dd, a.date1, @date) = 0  -- 若需要包含前几天没有处理的记录，去除这个条件
			and a.date1 < getdate()
			and charindex(a.type, @type1) > 0
			and a.accnt = c.accnt
			and c.haccnt = d.no
			and c.accnt = e.accnt
			and (@class='A' or (@class='F' and e.groupno='') or (@class='G' and e.groupno<>''))
	union 
	select a.roomno, char2 = (select e.descript from basecode e where e.code = d.vip and cat = 'vip'), a.accnt,
			a.type, a.sta, a.empno1,a.date1, a.empno2, a.date2, a.empno3, a.date3, a.refer,a.pc_id,e.haccnt,e.groupno,e.cusno, d.vip, c.arr, datediff(ss, c.arr, a.date1) 
		from checkroom a, master c,guest d, master_des e
		where (a.roomno = 'GRP' or a.roomno='') 
			and ( rtrim(@sdid) is null or charindex(a.pc_id, @sdid) > 0 ) 
			and datediff(dd, a.date1, @date) = 0  -- 若需要包含前几天没有处理的记录，去除这个条件
			and a.date1 < getdate()
			and charindex(a.type, @type1) > 0
			and a.accnt = c.accnt
			and c.haccnt = d.no
			and c.accnt = e.accnt
			and (@class='A' or (@class='F' and e.groupno='') or (@class='G' and e.groupno<>''))
		order by a.date1 desc
end
else		-- 历史记录 
begin
	create table #gout (
		roomno		char(5)				not null,
		vipdes		varchar(60)			null,
		accnt			char(10)				not null,
		type			char(1)				not null,
		sta			char(1)				not null,
		empno1		char(10)				null,
		date1			datetime				null,
		empno2		char(10)				null,
		date2			datetime				null,
		empno3		char(10)				null,
		date3			datetime				null,
		refer			varchar(2)			null,
		pc_id			char(4)				null,
		haccnt		varchar(50)			null,
		groupno		varchar(50)			null,
		cusno			varchar(50)			null,
		vipcode		char(3)				null,
		arr			datetime				null,
		sss			int					null 
	)
	insert #gout (roomno,accnt,type,sta,empno1,date1,empno2,date2,empno3,date3,refer,pc_id,haccnt,groupno,cusno,vipdes,vipcode) 
		select a.roomno,a.accnt,a.type,a.sta, a.empno1, a.date1, a.empno2, a.date2, a.empno3, a.date3, a.refer,a.pc_id,'','','','','0'
			from checkroom a, rmsta b
			where a.roomno = b.roomno and (rtrim(@types) is null or charindex(','+rtrim(b.type)+',', ','+@types+',') > 0)
				and ( rtrim(@sdid) is null or charindex(a.pc_id, @sdid) > 0 ) 
				and datediff(dd, a.date1, @date) = 0  
				and charindex(a.type, @type1) > 0
	insert #gout (roomno,accnt,type,sta,empno1,date1,empno2,date2,empno3,date3,refer,pc_id,haccnt,groupno,cusno,vipdes,vipcode) 
		select a.roomno,a.accnt,a.type,a.sta, a.empno1, a.date1, a.empno2, a.date2, a.empno3, a.date3, a.refer,a.pc_id,'','','','','0'
			from checkroom a
			where (a.roomno = 'GRP' or a.roomno='') 
				and ( rtrim(@sdid) is null or charindex(a.pc_id, @sdid) > 0 ) 
				and datediff(dd, a.date1, @date) = 0  
				and charindex(a.type, @type1) > 0

	update #gout set haccnt=substring(b.name+'/'+b.name2,1,50), vipdes=b.vip, groupno=a.groupno, cusno=a.cusno, vipcode=b.vip, arr=a.arr, sss=datediff(ss,date1,a.arr) 
		from master a, guest b where #gout.accnt=a.accnt and a.haccnt=b.no 
	update #gout set haccnt=substring(b.name+'/'+b.name2,1,50), vipdes=b.vip, groupno=a.groupno, cusno=a.cusno, vipcode=b.vip, arr=a.arr, sss=datediff(ss,date1,a.arr) 
		from hmaster a, guest b where #gout.accnt=a.accnt and a.haccnt=b.no 
	if @class='F' 
		delete #gout where groupno<>'' and accnt like 'F%' 
	if @class='G' 
		delete #gout where groupno='' and accnt like 'F%' 
	update #gout set groupno=substring(b.name+'/'+b.name2,1,50) from master a, guest b where #gout.groupno=a.accnt and a.haccnt=b.no 
	update #gout set groupno=substring(b.name+'/'+b.name2,1,50) from hmaster a, guest b where #gout.groupno=a.accnt and a.haccnt=b.no 
	update #gout set cusno=substring(a.name+'/'+a.name2,1,50) from guest a where #gout.cusno=a.no 
	update #gout set vipdes=a.descript from basecode a where #gout.vipdes=a.code and a.cat='vip'
	update #gout set vipcode='0' where rtrim(vipcode) is null 

	/* Adaptive Server has expanded all '*' elements in the following statement */ select #gout.roomno, #gout.vipdes, #gout.accnt, #gout.type, #gout.sta, #gout.empno1, #gout.date1, #gout.empno2, #gout.date2, #gout.empno3, #gout.date3, #gout.refer, #gout.pc_id, #gout.haccnt, #gout.groupno, #gout.cusno, #gout.vipcode, #gout.arr, #gout.sss from #gout order by date1 desc
end
/* ### DEFNCOPY: END OF DEFINITION */
;