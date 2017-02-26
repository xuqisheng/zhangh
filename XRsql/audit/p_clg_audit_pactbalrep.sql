IF OBJECT_ID('dbo.p_clg_audit_pactbalrep') IS NOT NULL
    DROP PROCEDURE dbo.p_clg_audit_pactbalrep
;
create proc p_clg_audit_pactbalrep
	@begin		datetime,
	@end			datetime,
	@where		varchar(255),	-- F,M,G,C,AG:,AT:
	@order		varchar(60), -- nr=name,roomno-accnt or rn=roomno-accnt,name 
	@langid		int,
	@mode			char(1)
as
--act_bal用cus_xf代替。。。。
declare 	@artags 			varchar(30), 
			@artag_grps 	varchar(30),
			@pos				int,
			@tmp				varchar(255)  
		
create table #goutput 
(
--	date				datetime		not null,
	accnt				char(10)		not null, 
	roomno			char(10)		default '' not null, 
	groupno			char(10)		default '' not null, 
	sta				char(1)		default '' not null, 
	name				varchar(50)	default '' null, 
	artag1			char(5)		default '' not null,
	artag1_grp		char(5)		default '' not null,
	group_des		varchar(50)	default '' null, 
	cus_des			varchar(50)	default '' null, 
	agent_des		varchar(50)	default '' null, 
	source_des		varchar(50)	default '' null, 
	arr				datetime		null, 
	dep				datetime		null, 
	lastbl			money			default 0 not null, 
	day01			money			default 0 not null, 
	day02			money			default 0 not null, 
	day03			money			default 0 not null, 
	day04			money			default 0 not null, 
	day05			money			default 0 not null, 
	day06			money			default 0 not null, 
	day07			money			default 0 not null, 
	day08			money			default 0 not null, 
	day09			money			default 0 not null, 
	day10			money			default 0 not null, 
	day11			money			default 0 not null, 
	day12			money			default 0 not null,
	day99			money			default 0 not null, 
	cred99			money			default 0 not null, 
	tillbl			money			default 0 not null, 
	payment			varchar(60)				null,
	ref				varchar(255)			null,
	class1			varchar(20)				null,
	class2			varchar(60)				null,
	class3			varchar(60)				null,
	order1			int						null,
	order2			int						null,
	order3			int						null,
	lastdt			datetime					null,
	tilldt			datetime					null
)

----------------
-- 1. 创建数据
----------------
if @mode='T'
begin
	-- 散客
	if charindex(',F,', @where)>0 
		insert #goutput(accnt,day01,day02,day03,day04,day05,day06,day07,day08,day09,day10,day11,day12,day99,cred99,class1,class2,class3,order1,order2,order3,lastdt,tilldt)
			select accnt,sum(rm),sum(fb),sum(mt),sum(en),sum(sp),sum(dot),0,0,0,0,0,0,sum(dtl),sum(ctl),'guest','fit','fit',0,0,0,min(date),max(date)
			from ycus_xf where date>=@begin and date<=@end and accnt like 'F%' and groupno='' group by accnt
	
	-- 成员 
	if charindex(',M,', @where)>0 
		insert #goutput(accnt,day01,day02,day03,day04,day05,day06,day07,day08,day09,day10,day11,day12,day99,cred99,class1,class2,class3,order1,order2,order3,lastdt,tilldt)
			select accnt,sum(rm),sum(fb),sum(mt),sum(en),sum(sp),sum(dot),0,0,0,0,0,0,sum(dtl),sum(ctl),'guest','grp','groupno',0,0,0,min(date),max(date)
			from ycus_xf where date>=@begin and date<=@end and accnt like 'F%' and groupno<>'' group by accnt
	
	-- 团体与会议
	if charindex(',G,', @where)>0 
		insert #goutput(accnt,day01,day02,day03,day04,day05,day06,day07,day08,day09,day10,day11,day12,day99,cred99,class1,class2,class3,order1,order2,order3,lastdt,tilldt)
			select accnt,sum(rm),sum(fb),sum(mt),sum(en),sum(sp),sum(dot),0,0,0,0,0,0,sum(dtl),sum(ctl),'guest','grp','groupno',0,0,0,min(date),max(date)
			from ycus_xf where date>=@begin and date<=@end and accnt like '[MG]%' group by accnt
	
	-- 消费帐户
	if charindex(',C,', @where)>0 
		insert #goutput(accnt,day01,day02,day03,day04,day05,day06,day07,day08,day09,day10,day11,day12,day99,cred99,class1,class2,class3,order1,order2,order3,lastdt,tilldt)
			select accnt,sum(rm),sum(fb),sum(mt),sum(en),sum(sp),sum(dot),0,0,0,0,0,0,sum(dtl),sum(ctl),'ha','ha','ha',0,0,0,min(date),max(date)
			from ycus_xf where date>=@begin and date<=@end and accnt like 'C%' group by accnt
	
	-- AR 帐户
	if charindex(',AG', @where)>0 or charindex(',AT', @where)>0 
	begin
		-- artag1 	
		if charindex(',AT*,', @where)>0 or charindex(',AT:', @where)=0 
			select @artags = '' 
		else if charindex(',AT:', @where)>0 
		begin
			select @pos = charindex(',AT:', @where)
			select @tmp = stuff(@where, 1, @pos+3, '') 
			select @pos = charindex(',', @tmp)
			select @artags = substring(@tmp, 1, @pos-1) 
		end 
		-- artag1 grp 
		if charindex(',AG*,', @where)>0 or charindex(',AG:', @where)=0 
			select @artag_grps = '' 
		else if charindex(',AG:', @where)>0 
		begin
			select @pos = charindex(',AG:', @where)
			select @tmp = stuff(@where, 1, @pos+3, '') 
			select @pos = charindex(',', @tmp)
			select @artag_grps = substring(@tmp, 1, @pos-1) 
		end 

--	if charindex(',A', @where)>0
		insert #goutput(accnt,artag1,artag1_grp,day01,day02,day03,day04,day05,day06,day07,day08,day09,day10,day11,day12,day99,cred99,class1,class2,class3,order1,order2,order3,lastdt,tilldt)
			select a.accnt,b.artag1,c.grp,sum(a.rm),sum(a.fb),sum(a.mt),sum(a.en),sum(a.sp),sum(a.dot),0,0,0,0,0,0,sum(a.dtl),sum(a.ctl),'ar','argrp','artag',0,0,0,min(date),max(date) 
			from ycus_xf a,ar_master b,basecode c	where date>=@begin and date<=@end and a.accnt like 'A%'	and (@artag_grps='' or charindex(rtrim(c.grp), @artag_grps)>0)
			and (@artags='' or charindex(rtrim(b.artag1), @artags)>0) and a.accnt=b.accnt and b.artag1=c.code and  c.cat='artag1' group by c.grp,b.artag1,a.accnt
	end

	update #goutput set roomno=a.roomno,groupno=a.groupno,sta=a.sta,name=a.name,arr=a.arr,dep=a.dep,lastbl=a.lastbl from ycus_xf a where a.accnt=#goutput.accnt and a.date=#goutput.lastdt
	update #goutput set tillbl=a.tillbl from ycus_xf a where a.accnt=#goutput.accnt and a.date=#goutput.tilldt
end
else
begin
	-- 散客 --------因为报表窗口限定了累计统计都是统计某一天，所以不用上面那样group了。--clg
	if charindex(',F,', @where)>0 
		insert #goutput select accnt,roomno,groupno,sta,name,'','','','','','',arr,dep,lastbl,t_rm,t_fb,t_mt,t_en,t_sp,t_dot,0,
	0,0,0,0,0,t_dtl,t_ctl,tillbl,'','','guest','fit','fit',0,0,0,null,null from ycus_xf where date>=@begin and date<=@end and accnt like 'F%' and groupno=''
	
	-- 成员 
	if charindex(',M,', @where)>0 
		insert #goutput select accnt,roomno,groupno,sta,name,'','','','','','',arr,dep,lastbl,t_rm,t_fb,t_mt,t_en,t_sp,t_dot,0,
	0,0,0,0,0,t_dtl,t_ctl,tillbl,'','','guest','grp','groupno',0,0,0,null,null from ycus_xf where date>=@begin and date<=@end and accnt like 'F%' and groupno<>''
	
	-- 团体与会议
	if charindex(',G,', @where)>0 
		insert #goutput select accnt,roomno,groupno,sta,name,'','','','','','',arr,dep,lastbl,t_rm,t_fb,t_mt,t_en,t_sp,t_dot,0,
	0,0,0,0,0,t_dtl,t_ctl,tillbl,'','','guest','grp','groupno',0,0,0,null,null from ycus_xf where date>=@begin and date<=@end and accnt like '[MG]%'
	
	-- 消费帐户
	if charindex(',C,', @where)>0 
		insert #goutput select accnt,roomno,groupno,sta,name,'','','','','','',arr,dep,lastbl,t_rm,t_fb,t_mt,t_en,t_sp,t_dot,0,
	0,0,0,0,0,t_dtl,t_ctl,tillbl,'','','ha','ha','ha',0,0,0,null,null from ycus_xf where date>=@begin and date<=@end and accnt like 'C%'
	
	-- AR 帐户
	if charindex(',AG', @where)>0 or charindex(',AT', @where)>0 
	begin
		-- artag1 	
		if charindex(',AT*,', @where)>0 or charindex(',AT:', @where)=0 
			select @artags = '' 
		else if charindex(',AT:', @where)>0 
		begin
			select @pos = charindex(',AT:', @where)
			select @tmp = stuff(@where, 1, @pos+3, '') 
			select @pos = charindex(',', @tmp)
			select @artags = substring(@tmp, 1, @pos-1) 
		end 
		-- artag1 grp 
		if charindex(',AG*,', @where)>0 or charindex(',AG:', @where)=0 
			select @artag_grps = '' 
		else if charindex(',AG:', @where)>0 
		begin
			select @pos = charindex(',AG:', @where)
			select @tmp = stuff(@where, 1, @pos+3, '') 
			select @pos = charindex(',', @tmp)
			select @artag_grps = substring(@tmp, 1, @pos-1) 
		end

--	if charindex(',A', @where)>0
		insert #goutput select a.accnt,a.roomno,a.groupno,a.sta,a.name,b.artag1,c.grp,'','','','',a.arr,a.dep,a.lastbl,a.t_rm,a.t_fb,a.t_mt,a.t_en,a.t_sp,a.t_dot,0,
			0,0,0,0,0,a.t_dtl,a.t_ctl,a.tillbl,'','','ar','argrp','artag',0,0,0,null,null from ycus_xf a,ar_master b,basecode c
			where date>=@begin and date<=@end and a.accnt like 'A%'	and (@artag_grps='' or charindex(rtrim(c.grp), @artag_grps)>0)
			and (@artags='' or charindex(rtrim(b.artag1), @artags)>0) and a.accnt=b.accnt and b.artag1=c.code and  c.cat='artag1'
	end
end

-- delete from #goutput where tillbl=0
------------------------------------------------
-- 2. 名称统一。有的帐户可能修改了名字 
------------------------------------------------
-- ???  


----------------
-- 3. 代码翻译 
----------------
if @langid=0 
begin
	update #goutput set class1='住客', order1=10 where class1='guest' 
	update #goutput set class1='消费帐', order1=20 where class1='ha' 
	update #goutput set class1='应收帐', order1=30 where class1='ar' 

	update #goutput set class2='散客', order2=10 where class2='fit' 
	update #goutput set class2='团体会议', order2=20 where class2='grp' 
	update #goutput set class2='消费帐', order2=30 where class2='ha' 
	update #goutput set class2=a.descript, order2=a.sequence from basecode a 
		where #goutput.class2='argrp' and #goutput.artag1_grp=a.code and a.cat='argrp1' 

	update #goutput set class3='散客', order3=10 where class3='fit' 
	update #goutput set class3=a.group_des, order3=20 from ymstbalrep a where #goutput.class3='groupno' and #goutput.accnt=a.accnt
	update #goutput set class3='消费帐', order3=30 where class3='ha' 
	update #goutput set class3=a.descript, order3=a.sequence from basecode a 
		where #goutput.class3='artag' and #goutput.artag1=a.code and a.cat='artag1' 
end
else
begin
	update #goutput set class1='Guest', order1=10 where class1='guest' 
	update #goutput set class1='House Accounts', order1=20 where class1='ha' 
	update #goutput set class1='Account Receivable', order1=30 where class1='ar' 

	update #goutput set class2='FIT', order2=10 where class2='fit' 
	update #goutput set class2='Group', order2=20 where class2='grp' 
	update #goutput set class2='House Accounts', order2=30 where class2='ha' 
	update #goutput set class2=a.descript1, order2=a.sequence from basecode a 
		where #goutput.class2='argrp' and #goutput.artag1_grp=a.code and a.cat='argrp1' 

	update #goutput set class3='FIT', order3=10 where class3='fit' 
	update #goutput set class3=a.group_des, order3=20 from ymstbalrep a where #goutput.class3='groupno' and #goutput.accnt=a.accnt
	update #goutput set class3='House Accounts', order3=30 where class3='ha' 
	update #goutput set class3=a.descript1, order3=a.sequence from basecode a 
		where #goutput.class3='artag' and #goutput.artag1=a.code and a.cat='artag1' 
end 

------------------------------------------------
-- 4. 输出 （排序）
--  
--    住客帐的排序：房号，名称 
--    消费帐的排序：帐号，名称 
--    AR  帐的排序：帐号，名称 
------------------------------------------------
update #goutput set roomno=accnt where rtrim(roomno) is null 
if @order = 'nr' 
	select class1,class2,class3,roomno,sta,name,arr,dep,lastbl,day01,day02,day03,day04,day05,day06,day07,day08,day09,day10,day11,day12,day99,cred99,tillbl
		from #goutput order by order1,order2,order3,name,roomno 
else
	select class1,class2,class3,roomno,sta,name,arr,dep,lastbl,day01,day02,day03,day04,day05,day06,day07,day08,day09,day10,day11,day12,day99,cred99,tillbl
		from #goutput order by order1,order2,order3,roomno,name 

return;