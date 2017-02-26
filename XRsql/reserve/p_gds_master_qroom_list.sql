if  exists(select * from sysobjects where name = "p_gds_master_qroom_list")
	drop proc p_gds_master_qroom_list
;
create proc p_gds_master_qroom_list
	@mode				char(1),   -- '':有效   否则表示近期所有(24小时内)
	@moduid			char(2),	  -- 模块
	@pc_id			char(4)
as
-----------------------------------------------------------------------------------------------
--	p_gds_master_qroom_list: q-room list 显示
----------------------------------------------------------------------------------------------- 
declare
	@type1			varchar(10), 
	@types			varchar(255), 
	@sdid				varchar(100) 

create table #goutput(
	accnt			char(10)						not null,
	sta			char(1)						not null,
	haccnt		char(7)						not null,
	name			varchar(60)	default '' 	not null,
	type			char(5)						not null,
	rmnum			int			default 0	not null,
	roomno		char(5)		default ''	not null,
	rmsta			char(3)		default ''	not null,
	gstno			int			default 0	not null,
	arr			datetime						null,
	dep			datetime						null,
	grpno			char(10)		default ''	not null,
	grpname		varchar(50)		default ''	not null,
	crtby			char(10)						null,
	crttime		datetime						null,
	tlong1		int			default 0	not null,
	tlong2		char(10)		default ''	not null,		-- hhhh:mm:ss
	status		char(1)		default ''	not null
)

-- control set 	
select @types = rtrim(type), @sdid = rtrim(sdid) from checkroomset where rcid = @pc_id
if @@rowcount = 0
	select @types = null, @sdid = null

-- insert data
if @moduid = '03'
begin
	if @mode = ''
		insert #goutput
			select b.accnt,b.sta,b.haccnt,c.name,b.type,b.rmnum,b.roomno,'',b.gstno,b.arr,b.dep,b.groupno,'',
					a.crtby,a.crttime,datediff(ss,a.crttime,getdate()), '',a.status
			from qroom a, master b, guest c,rmsta d 
			where a.accnt = b.accnt and b.haccnt = c.no and a.status = 'I' and b.sta in ('R', 'I') and 
					a.roomno = d.roomno and (@types is null or charindex(','+rtrim(b.type)+',', ','+@types+',') > 0) 
					
	else
		insert #goutput
			select b.accnt,b.sta,b.haccnt,c.name,b.type,b.rmnum,b.roomno,'',b.gstno,b.arr,b.dep,b.groupno,'',
				a.crtby,a.crttime,datediff(ss,a.crttime,getdate()), '',a.status
			from qroom a, master b, guest c,rmsta d 
			where a.accnt = b.accnt and b.haccnt = c.no and datediff(hour,a.crttime,getdate()) < 24  and  -- 24 hour
					a.roomno = d.roomno and (@types is null or charindex(','+rtrim(b.type)+',', ','+@types+',') > 0) 
end
else
begin
	if @mode = ''
		insert #goutput
			select b.accnt,b.sta,b.haccnt,c.name,b.type,b.rmnum,b.roomno,'',b.gstno,b.arr,b.dep,b.groupno,'',
					a.crtby,a.crttime,datediff(ss,a.crttime,getdate()), '',a.status
			from qroom a, master b, guest c 
			where a.accnt = b.accnt and b.haccnt = c.no and a.status = 'I' and b.sta in ('R', 'I') 
					
	else
		insert #goutput
			select b.accnt,b.sta,b.haccnt,c.name,b.type,b.rmnum,b.roomno,'',b.gstno,b.arr,b.dep,b.groupno,'',
				a.crtby,a.crttime,datediff(ss,a.crttime,getdate()), '',a.status
			from qroom a, master b, guest c 
			where a.accnt = b.accnt and b.haccnt = c.no and datediff(hour,a.crttime,getdate()) < 24   -- 24 hour
end

-- group
update #goutput set grpname = b.name from master a, guest b
	where #goutput.grpno = a.accnt and a.haccnt = b.no

-- rmsta
update #goutput set rmsta = b.eccocode from rmsta a, rmstamap b 
	where #goutput.roomno = a.roomno and a.ocsta+a.sta=b.code 

-- output
select accnt,sta,haccnt,name,type,rmnum,roomno,rmsta,gstno,arr,dep,
		grpno,grpname,crtby,crttime,tlong1,tlong2,status
	from #goutput order by arr

return 0
;

