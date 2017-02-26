
if exists (select * from sysobjects where name ='p_gds_audit_pmstbalrep' and type ='P')
	drop proc p_gds_audit_pmstbalrep;
create proc p_gds_audit_pmstbalrep
	@begin		datetime,
	@end			datetime,
	@where		varchar(255),	-- F,M,G,C,AG:,AT:
	@order		varchar(60), -- nr=name,roomno-accnt or rn=roomno-accnt,name 
	@langid		int 
as

create table #goutput 
(
	date				datetime		not null,
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
	charge			money			default 0 not null, 
	credit			money			default 0 not null, 
	tillbl			money			default 0 not null, 
	payment			varchar(60)				null,
	ref				varchar(255)			null,
	class1			varchar(20)				null,
	class2			varchar(60)				null,
	class3			varchar(60)				null,
	order1			int						null,
	order2			int						null,
	order3			int						null
)

----------------
-- 1. 创建数据
----------------
-- 散客
if charindex(',F,', @where)>0 
	insert #goutput select *,'guest','fit','fit',0,0,0 from ymstbalrep where date>=@begin and date<=@end and accnt like 'F%' and groupno=''

-- 成员 
if charindex(',M,', @where)>0 
	insert #goutput select *,'guest','grp','groupno',0,0,0 from ymstbalrep where date>=@begin and date<=@end and accnt like 'F%' and groupno<>''

-- 团体与会议
if charindex(',G,', @where)>0 
	insert #goutput select *,'guest','grp','groupno',0,0,0 from ymstbalrep where date>=@begin and date<=@end and accnt like '[MG]%'

-- 消费帐户
if charindex(',C,', @where)>0 
	insert #goutput select *,'ha','ha','ha',0,0,0 from ymstbalrep where date>=@begin and date<=@end and accnt like 'C%'

-- AR 帐户
if charindex(',AG', @where)>0 or charindex(',AT', @where)>0 
begin
	declare 	@artags 			varchar(30), 
				@artag_grps 	varchar(30),
				@pos				int,
				@tmp				varchar(255)  
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

	insert #goutput select *,'ar','argrp','artag',0,0,0 from ymstbalrep
		where date>=@begin and date<=@end and accnt like 'A%'
			and (@artag_grps='' or charindex(rtrim(artag1_grp), @artag_grps)>0)
			and (@artags='' or charindex(rtrim(artag1), @artags)>0)
end 

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
	update #goutput set class3=group_des, order3=20 where class3='groupno' 
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
	update #goutput set class3=group_des, order3=20 where class3='groupno' 
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
	select class1,class2,class3,roomno,sta,name,payment,char99_1  =  convert(char(99),  group_des+'/'+cus_des+'/'+agent_des+'/'+source_des),arr,dep,lastbl,charge,credit,tillbl,ref 
		from #goutput order by order1,order2,order3,name,roomno 
else
	select class1,class2,class3,roomno,sta,name,payment,char99_1  =  convert(char(99),  group_des+'/'+cus_des+'/'+agent_des+'/'+source_des),arr,dep,lastbl,charge,credit,tillbl,ref 
		from #goutput order by order1,order2,order3,roomno,name 

return ;
