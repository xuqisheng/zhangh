if exists(select * from sysobjects where name = "p_gds_vipcard_by_saleid")
	drop proc p_gds_vipcard_by_saleid
;
create proc p_gds_vipcard_by_saleid
as
create table #goutput (
	no					char(7)								not null,	-- 电脑号	
	sno				varchar(20)		default ''		not null,	-- 卡凸码  
	name				varchar(50)							not null,	-- 名称
	type				char(1)								not null,  	-- C-单位卡,R-个人卡,M-储值卡
	code1				char(10)			default ''		not null, 		-- 房价码 
	code2				char(3)			default ''		not null, 		-- 餐娱码 
	araccnt1			char(10)								null,
	aname				varchar(50)		default ''		not null,
	cno				char(7)								null,			-- 单位号(对应 guest)
	cname				varchar(50)		default ''		not null,
	hno				char(7)								null,			-- 持卡人(对应 guest)
	hname				varchar(50)		default ''		not null,
	arr				datetime								null,  		-- 有效日期
	dep				datetime								null,			-- 终止日期
	limit				money				default 0	 	not null, 	-- 限额
	ref				varchar(255)						null,			-- 备注
	saleid			varchar(10)		default ''		not null,
	sname				varchar(30)		default ''		not null
)

//-- Insert 
//insert #goutput(no,sno,type,code1,code2,araccnt1,name,cno,hno,arr,dep,limit,ref)
//	select no,sno,type,code1,code2,araccnt1,name,cno,hno,arr,dep,limit,ref
//		from vipcard where sta='I'
//
//-- Name
//update #goutput set cname=a.name from guest a where #goutput.cno<>'' and #goutput.cno=a.no
//update #goutput set hname=a.name from guest a where #goutput.cno<>'' and #goutput.hno=a.no
//update #goutput set aname=a.name from guest a, master b where #goutput.araccnt1<>'' and #goutput.araccnt1=b.accnt and b.haccnt=a.no
//
//-- Saleid
//update #goutput set saleid=a.saleid from guest a where #goutput.cno<>'' and #goutput.cno=a.no
//update #goutput set saleid=a.saleid from guest a where #goutput.saleid='' and #goutput.hno<>'' and #goutput.hno=a.no
//update #goutput set sname=a.descript from saleid a where #goutput.saleid=a.code
//update #goutput set saleid='???', sname='Unknown' where saleid=''
//update #goutput set sname=saleid where sname=''

select  saleid+'-'+sname,no,sno,code1,code2,cname,araccnt1+'-'+aname,hname,
	limit, ref from #goutput order by saleid, sname
;

//exec p_gds_vipcard_by_saleid;

/*

if exists(select * from sysobjects where name = "p_gds_vipcard_by_saleid")
	drop proc p_gds_vipcard_by_saleid
;
create proc p_gds_vipcard_by_saleid
as
create table #goutput (
	no					char(7)								not null,	-- 电脑号	
	sno				varchar(20)		default ''		not null,	-- 卡凸码  
	name				varchar(50)							not null,	-- 名称
	type				char(1)								not null,  	-- C-单位卡,R-个人卡,M-储值卡
	code1				char(10)			default ''		not null, 		-- 房价码 
	code2				char(3)			default ''		not null, 		-- 餐娱码 
	araccnt1			char(10)								null,
	aname				varchar(50)		default ''		not null,
	cno				char(7)								null,			-- 单位号(对应 guest)
	cname				varchar(50)		default ''		not null,
	hno				char(7)								null,			-- 持卡人(对应 guest)
	hname				varchar(50)		default ''		not null,
	arr				datetime								null,  		-- 有效日期
	dep				datetime								null,			-- 终止日期
	limit				money				default 0	 	not null, 	-- 限额
	ref				varchar(255)						null,			-- 备注
	saleid			varchar(10)		default ''		not null,
	sname				varchar(30)		default ''		not null
)

-- Insert 
insert #goutput(no,sno,type,code1,code2,araccnt1,name,cno,hno,arr,dep,limit,ref)
	select no,sno,type,code1,code2,araccnt1,name,cno,hno,arr,dep,limit,ref
		from vipcard where sta='I'

-- Name
update #goutput set cname=a.name from guest a where #goutput.cno<>'' and #goutput.cno=a.no
update #goutput set hname=a.name from guest a where #goutput.cno<>'' and #goutput.hno=a.no
update #goutput set aname=a.name from guest a, master b where #goutput.araccnt1<>'' and #goutput.araccnt1=b.accnt and b.haccnt=a.no

-- Saleid
update #goutput set saleid=a.saleid from guest a where #goutput.cno<>'' and #goutput.cno=a.no
update #goutput set saleid=a.saleid from guest a where #goutput.saleid='' and #goutput.hno<>'' and #goutput.hno=a.no
update #goutput set sname=a.descript from saleid a where #goutput.saleid=a.code
update #goutput set saleid='???', sname='Unknown' where saleid=''
update #goutput set sname=saleid where sname=''

select  saleid+'-'+sname,no,sno,code1,code2,cname,araccnt1+'-'+aname,hname,
	limit, ref from #goutput order by saleid, sname
;

exec p_gds_vipcard_by_saleid;

// char40,char07,char20,char101,char102,char991,char992,char993,mone10,char994


*/
