IF OBJECT_ID('p_hbb_reserve_noshow_rep') IS NOT NULL
    DROP PROCEDURE p_hbb_reserve_noshow_rep
;
create proc p_hbb_reserve_noshow_rep
   @type       char(1),   --X 取消  N NO Show W waitinglist
	@begin		datetime,
	@end			datetime
as
-- 按到日统计
create table #report (
	restype		char(3)			default '' 	not null,
	accnt			char(10)						 	not null,
	haccnt		char(7)						 	not null,
	name			varchar(60)		default ''	not null,
	groupno		char(10)			default '' 	null,
	ghaccnt		char(7)			default '' 	null,
	gname			varchar(60)		default ''	null,		--原来与下面项目对不上，现在我把临时表结构调整了一下就可以了wz
	cusno			char(7)			default '' 	null,
	cname			varchar(60)		default ''	null,
	agent			char(7)			default '' 	null,
	aname			varchar(60)		default ''	null,
	source		char(7)			default '' 	null,
	sname			varchar(60)		default ''	null,
	arr			datetime							not null,
	dep			datetime							not null,
	type			char(3)							not null,
	roomno		char(5)							not null,
	rate			money			default 0		not null,
	ratecode		char(10)		default ''		not null,
	rmnum			int			default 0		not null,
	gstno			int			default 0		not null,
	ref			varchar(100)	default ''		not null,
   crtby       char(10)       default ''   not null,
   crttime     datetime       					null,     -- 2004.12.3
   reason      varchar(60)    default ''   not null
)

if @type='N'
	begin
		insert #report
			select restype,accnt,haccnt,'',groupno,'','',cusno,'',agent,'',source,'',arr,dep,type,roomno,setrate,ratecode,rmnum,gstno,ref,'',null,'' from master
				where class in ('F','G','M') and datediff(day,@begin,arr) >= 0 and datediff(day,arr,@end) >= 0 and sta='N'
		union
			select restype,accnt,haccnt,'',groupno,'','',cusno,'',agent,'',source,'',arr,dep,type,roomno,setrate,ratecode,rmnum,gstno,ref,'',null,'' from hmaster
				where class in ('F','G','M') and datediff(day,@begin,arr) >= 0 and datediff(day,arr,@end) >= 0 and sta='N'
	end
else if @type='X'
	begin
		insert #report
			select a.restype,a.accnt,a.haccnt,'',a.groupno,'','',a.cusno,'',a.agent,'',a.source,'',a.arr,a.dep,a.type,a.roomno,a.setrate,a.ratecode,a.rmnum,a.gstno,a.ref,b.crtby,b.crttime,b.reason from master a,master_hung b
				where a.class in ('F','G','M') and datediff(day,@begin,arr) >= 0 and datediff(day,arr,@end) >= 0 and a.sta='X' and a.accnt = b.accnt and b.status='I'
		union
			select a.restype,a.accnt,a.haccnt,'',a.groupno,'','',a.cusno,'',a.agent,'',a.source,'',a.arr,a.dep,a.type,a.roomno,a.setrate,a.ratecode,a.rmnum,a.gstno,a.ref,b.crtby,b.crttime,b.reason from hmaster a,master_hung b
				where a.class in ('F','G','M') and datediff(day,@begin,arr) >= 0 and datediff(day,arr,@end) >= 0 and a.sta='X' and a.accnt = b.accnt and b.status='I'
	end
else if @type='W'
	begin
		insert #report
			select restype,accnt,haccnt,'',groupno,'','',cusno,'',agent,'',source,'',arr,dep,type,roomno,setrate,ratecode,rmnum,gstno,ref,'',null,'' from master
				where class in ('F','G','M') and datediff(day,@begin,arr) >= 0 and datediff(day,arr,@end) >= 0 and sta='W'
		union
			select restype,accnt,haccnt,'',groupno,'','',cusno,'',agent,'',source,'',arr,dep,type,roomno,setrate,ratecode,rmnum,gstno,ref,'',null,'' from hmaster
				where class in ('F','G','M') and datediff(day,@begin,arr) >= 0 and datediff(day,arr,@end) >= 0 and sta='W'
	end

update #report set name =a.name from guest a where #report.haccnt=a.no
update #report set cname=a.name from guest a where #report.cusno=a.no
update #report set aname=a.name from guest a where #report.agent=a.no
update #report set sname=a.name from guest a where #report.source=a.no

update #report set ghaccnt=a.haccnt from master a where #report.groupno=a.accnt
update #report set ghaccnt=a.haccnt from hmaster a where #report.groupno=a.accnt
update #report set gname=a.name from guest a where #report.ghaccnt=a.no

update #report set reason=isnull((select b.descript1 from basecode b where b.cat='rescancel' and b.code=#report.reason),'')

select b.descript,a.accnt,a.name,gname+'/'+cname+' '+aname+' '+sname,arr,dep,type,roomno,rate,ratecode,rmnum,gstno,ref,crtby,reason,crttime from #report a, restype b
	where a.restype*=b.code order by b.code, right('0'+roomno,4),a.arr
return 0
;