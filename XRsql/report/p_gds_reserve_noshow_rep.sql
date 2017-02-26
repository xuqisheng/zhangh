drop proc p_gds_reserve_noshow_rep;
create proc p_gds_reserve_noshow_rep
   @type       char(1),   --X 取消  I 在住  H 自用 W waitinglist  O 离开 C 免费房 D担保&定金报表 U取消入住 N 应到未到
	@begin		datetime,
	@end			datetime,
	@flag1		char(1) = 'T',
	@flag2		char(1) = 'F',
	@flag3		char(1) = 'F'
as
declare
	@num			int,		--No Show （两人同住一人到一人未到房间算到）
	@gmnum			int

select @num = 0,@gmnum = 0

create table #report (
	restype		char(3)			default '' 	not null,
	accnt			char(10)						 	not null,
	resno			char(10)		   null,
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
	arr			datetime							null,
	dep			datetime							null,
	type			char(5)							null,
	roomno		char(5)							null,
	rate			money			default 0		null,
	ratecode		char(10)		default ''		null,
	rmnum			int			default 0		null,
	gstno			int			default 0		null,
	ref			varchar(100)	default ''	not null,
   crtby       char(10)       default ''  not null,
   crttime     datetime       				null,     -- 2004.12.3
   reason      varchar(60)    default ''  not null,
	remark		varchar(100)    default ''  not null,
	master		char(10)			default ''  not null
)
if @type='U'
	begin
	insert #report
		select a.restype,a.accnt,a.resno,a.haccnt,'',a.groupno,'','',a.cusno,'',a.agent,'',a.source,'',a.arr,a.dep,a.type,a.roomno,a.setrate,a.ratecode,a.rmnum,a.gstno,a.ref,'',null,'' ,'',a.master
			from master a,lgfl b where class in ('F') and a.accnt=b.accnt and b.columnname='m_sta2' and datediff(dd,b.date,@begin)<=0 and datediff(dd,b.date,@end)>=0
           
	end
else if @type='D'
	begin
		insert #report
			select restype,accnt,resno,haccnt,'',groupno,'','',cusno,'',agent,'',source,'',arr,dep,type,roomno,setrate,ratecode,rmnum,gstno,ref,'',null,'','',master from master
				where class in ('F','G','M') and bdate>=@begin and bdate<=@end and sta='R' and restype like 'GT%'
	end
else if @type='N'
	begin
		insert #report
			select restype,accnt,resno,haccnt,'',groupno,'','',cusno,'',agent,'',source,'',arr,dep,type,roomno,setrate,ratecode,rmnum,gstno,ref,'',null,'','',master from master
				where class in ('F','G','M') and bdate>=@begin and bdate<=@end and sta='N'
		union
			select restype,accnt,resno,haccnt,'',groupno,'','',cusno,'',agent,'',source,'',arr,dep,type,roomno,setrate,ratecode,rmnum,gstno,ref,'',null,'','',master from hmaster
				where class in ('F','G','M') and bdate>=@begin and bdate<=@end and sta='N'

		select @num = count(1) from #report where master in (select master from master where bdate>=@begin and bdate<=@end and sta = 'I') and rtrim(groupno) is null 
		select @num = @num + count(1) from #report where master in (select master from hmaster where bdate>=@begin and bdate<=@end and sta = 'I') and rtrim(groupno) is null 
		select @gmnum = count(1) from #report where master in (select master from master where bdate>=@begin and bdate<=@end and sta = 'I') and rtrim(groupno) <> null 
		select @gmnum = @gmnum + count(1) from #report where master in (select master from hmaster where bdate>=@begin and bdate<=@end and sta = 'I') and rtrim(groupno) <> null 

 	end
else if @type='X'
	begin
		insert #report
			select a.restype,a.accnt,a.resno,a.haccnt,'',a.groupno,'','',a.cusno,'',a.agent,'',a.source,'',a.arr,a.dep,a.type,a.roomno,a.setrate,a.ratecode,a.rmnum,a.gstno,a.ref,b.crtby,b.crttime,b.reason,b.remark,a.master from master a,master_hung b
				where a.class in ('F','G','M') and ((a.bdate>=@begin and a.bdate<=@end and @flag1 = 'T') or (datediff(dd,a.arr,@begin)<=0 and datediff(dd,a.arr,@end)>=0 and @flag2 = 'T') or (datediff(dd,a.restime,@begin)<=0 and datediff(dd,a.restime,@end)>=0 and @flag3 = 'T')) and a.sta='X' and a.accnt = b.accnt and b.status='I'
		union
			select a.restype,a.accnt,a.resno,a.haccnt,'',a.groupno,'','',a.cusno,'',a.agent,'',a.source,'',a.arr,a.dep,a.type,a.roomno,a.setrate,a.ratecode,a.rmnum,a.gstno,a.ref,b.crtby,b.crttime,b.reason,b.remark,a.master from hmaster a,master_hung b
				where a.class in ('F','G','M') and ((a.bdate>=@begin and a.bdate<=@end and @flag1 = 'T') or (datediff(dd,a.arr,@begin)<=0 and datediff(dd,a.arr,@end)>=0 and @flag2 = 'T') or (datediff(dd,a.restime,@begin)<=0 and datediff(dd,a.restime,@end)>=0 and @flag3 = 'T')) and a.sta='X' and a.accnt = b.accnt and b.status='I'

		select @num = count(1) from #report where master in (select master from master where ((bdate>=@begin and bdate<=@end and @flag1 = 'T') and (datediff(dd,arr,@begin)<=0 and datediff(dd,arr,@end)>=0 and @flag2 = 'T') and (restime>=@begin and datediff(dd,restime,@end)>=0 and @flag3 = 'T')) and sta = 'I') and rtrim(groupno) is null 
		select @num = @num + count(1) from #report where master in (select master from hmaster where ((bdate>=@begin and bdate<=@end and @flag1 = 'T') and (datediff(dd,arr,@begin)<=0 and datediff(dd,arr,@end)>=0 and @flag2 = 'T') and (datediff(dd,restime,@begin)<=0 and datediff(dd,restime,@end)>=0 and @flag3 = 'T')) and sta = 'I') and rtrim(groupno) is null 
		select @gmnum = count(1) from #report where master in (select master from master where ((bdate>=@begin and bdate<=@end and @flag1 = 'T') and (datediff(dd,arr,@begin)<=0 and datediff(dd,arr,@end)>=0 and @flag2 = 'T') and (datediff(dd,restime,@begin)<=0 and datediff(dd,restime,@end)>=0 and @flag3 = 'T')) and sta = 'I') and rtrim(groupno) <> null 
		select @gmnum = @gmnum + count(1) from #report where master in (select master from hmaster where ((bdate>=@begin and bdate<=@end and @flag1 = 'T') and (datediff(dd,arr,@begin)<=0 and datediff(dd,arr,@end)>=0 and @flag2 = 'T') and (datediff(dd,restime,@begin)<=0 and datediff(dd,restime,@end)>=0 and @flag3 = 'T')) and bdate<=@end and sta = 'I') and rtrim(groupno) <> null 
	end
else if @type='W'
	begin
		insert #report
			select restype,accnt,resno,haccnt,'',groupno,'','',cusno,'',agent,'',source,'',arr,dep,type,roomno,setrate,ratecode,rmnum,gstno,ref,'',null,'','',master from master
				where class in ('F','G','M') and bdate>=@begin and bdate<=@end and sta='W'
		union
			select restype,accnt,resno,haccnt,'',groupno,'','',cusno,'',agent,'',source,'',arr,dep,type,roomno,setrate,ratecode,rmnum,gstno,ref,'',null,'','',master from hmaster
				where class in ('F','G','M') and bdate>=@begin and bdate<=@end and sta='W'
	end
else if @type='H'
	begin
		insert #report
			select a.restype,a.accnt,a.resno,a.haccnt,'',a.groupno,'','',a.cusno,'',a.agent,'',a.source,'',a.arr,a.dep,
					a.type,a.roomno,a.setrate,a.ratecode,a.rmnum,a.gstno,a.ref,'',null,'','',a.master
				from master a, mktcode b
				where a.class in ('F') and datediff(dd,a.dep,@begin)<0 and datediff(dd,a.arr,@end)>=0
            and a.sta  in ('I','O','S')  and a.market=b.code and b.flag='HSE'
		union
			select a.restype,a.accnt,a.resno,a.haccnt,'',a.groupno,'','',a.cusno,'',a.agent,'',a.source,'',a.arr,a.dep,
					a.type,a.roomno,a.setrate,a.ratecode,a.rmnum,a.gstno,a.ref,'',null,'','',a.master
				from master a, mktcode b
				where a.class in ('F') and datediff(dd,a.dep,@begin)<0 and datediff(dd,a.arr,@end)>=0
            and a.sta  in ('I','O','S')  and a.market=b.code and b.flag='HSE'
	end

else if @type='C'
	begin
		insert #report
			select restype,accnt,resno,haccnt,'',groupno,'','',cusno,'',agent,'',source,'',arr,dep,type,roomno,setrate,ratecode,rmnum,gstno,ref,'',null,'','',master from master
				where class in ('F') and datediff(dd,dep,@begin)<0 and datediff(dd,arr,@end)>=0
            and sta  in ('I','O','S')  and market='COM'
		union
			select restype,accnt,resno,haccnt,'',groupno,'','',cusno,'',agent,'',source,'',arr,dep,type,roomno,setrate,ratecode,rmnum,gstno,ref,'',null,'','',master from hmaster
			where class in ('F') and datediff(dd,dep,@begin)<0 and datediff(dd,arr,@end)>=0
            and sta  in ('O')  and market='COM'
	end


else if @type='I'
	begin
		insert #report
			select restype,accnt,resno,haccnt,'',groupno,'','',cusno,'',agent,'',source,'',arr,dep,type,roomno,setrate,ratecode,rmnum,gstno,ref,'',null,'','',master from master
				where class in ('F') and datediff(dd,dep,@begin)<0 and datediff(dd,arr,@end)>=0
            and sta  in ('I','O','S')
		union
			select restype,accnt,resno,haccnt,'',groupno,'','',cusno,'',agent,'',source,'',arr,dep,type,roomno,setrate,ratecode,rmnum,gstno,ref,'',null,'','',master from hmaster
				where class in ('F') and datediff(dd,dep,@begin)<0 and datediff(dd,arr,@end)>=0
            and sta  in ('O')
	end


else if @type='O'
	begin
		insert #report
			select restype,accnt,resno,haccnt,'',groupno,'','',cusno,'',agent,'',source,'',arr,dep,type,roomno,setrate,ratecode,rmnum,gstno,ref,'',null,'','',master from master
				where class in ('F') and datediff(dd,@begin,dep)>=0 and datediff(dd,dep,@end)>=0
            and sta  in ('I','O','S')
		union
			select restype,accnt,resno,haccnt,'',groupno,'','',cusno,'',agent,'',source,'',arr,dep,type,roomno,setrate,ratecode,rmnum,gstno,ref,'',null,'','',master from hmaster
				where class in ('F') and datediff(dd,@begin,dep)>=0 and datediff(dd,dep,@end)>=0
            and sta  in ('O')
	end


update #report set name =a.name from guest a where #report.haccnt=a.no
update #report set cname=a.name from guest a where #report.cusno=a.no
update #report set aname=a.name from guest a where #report.agent=a.no
update #report set sname=a.name from guest a where #report.source=a.no

update #report set ghaccnt=a.haccnt from master a where #report.groupno=a.accnt
update #report set ghaccnt=a.haccnt from hmaster a where #report.groupno=a.accnt
update #report set gname=a.name from guest a where #report.ghaccnt=a.no
update #report set reason=isnull((select b.descript from basecode b where b.cat='rescancel' and b.code=#report.reason),'')
							
---add by xx 2008.6.28 增加汇总统计
//insert #report(restype,accnt,haccnt,name,rmnum)
//		select 'ZZA','','','总 团 数：',isnull(count(1),0) from #report where restype not like 'ZZ%' and accnt like '[MG]%'
//insert #report(restype,accnt,haccnt,name,rate,rmnum,gstno)
//		select 'ZZB','','','散客统计：',sum(rmnum*rate),count(distinct master) - @num,count(gstno) from #report where restype not like 'ZZ%' and accnt like 'F%' and rtrim(groupno) is null
//insert #report(restype,accnt,haccnt,name,rate,rmnum,gstno)
//		select 'ZZC','','','团体统计：',sum(rmnum*rate),count(distinct master) - @gmnum,count(gstno) from #report where restype not like 'ZZ%' and accnt like 'F%' and rtrim(groupno) is not null
//insert #report(restype,accnt,haccnt,name,rate,rmnum,gstno)
//		select 'ZZD','','','总　　计：',sum(rmnum*rate),count(distinct master) - @num - @gmnum,count(gstno) from #report where restype not like 'ZZ%' and accnt like 'F%'

select b.descript,a.resno,a.name,gname+'/'+cname+' '+aname+' '+sname,arr,dep,type,roomno,rate,ratecode,rmnum,gstno,ref,crtby,reason,crttime,remark,a.accnt,a.haccnt from #report a, restype b
	where a.restype*=b.code order by a.restype, a.arr
return 0
;