p_cqf_agent_report 


CREATE proc p_cqf_agent_report
	@beg_				DATETIME,
	@end_				DATETIME

AS

CREATE TABLE #agent_report
	(
    NO            CHAR(7)     DEFAULT '' NULL,       --旅行社代码
    sno           CHAR(15)    DEFAULT '' NULL,       --自编号
    NAME          VARCHAR(50) DEFAULT '' NULL,       --名称
    class2        CHAR(7)     DEFAULT '' NULL,       --旅行社类别
    class2name    VARCHAR(50) DEFAULT '' NULL,       --类别名称
    saleid			VARCHAR(12) DEFAULT '' NULL,		  --销售员号
    idname			VARCHAR(30) DEFAULT '' NULL,		  --销售员

    rquan_jap           money		DEFAULT 0 NULL,     --日本房数
    rnight_jap          money		DEFAULT 0 NULL,     --日本房晚数
    rincome_jap         money		DEFAULT 0 NULL,     --日本房租
	 avgrate_jap        money		DEFAULT 0 NULL,     --日本平均房价

    rquan_eur           money		DEFAULT 0 NULL,
    rnight_eur          money		DEFAULT 0 NULL,
    rincome_eur         money		DEFAULT 0 NULL,
	 avgrate_eur         money		DEFAULT 0 NULL,

    rquan_in           money		DEFAULT 0 NULL,
    rnight_in          money		DEFAULT 0 NULL,
    rincome_in         money		DEFAULT 0 NULL,
	 avgrate_in         money		DEFAULT 0 NULL,

    rquan_hk           money		DEFAULT 0null,
    rnight_hk          money		DEFAULT 0 NULL,
    rincome_hk         money		DEFAULT 0 NULL,
	 avgrate_hk         money		DEFAULT 0 NULL,

    rquan_oth           money		DEFAULT 0 NULL,
    rnight_oth          money		DEFAULT 0 NULL,
    rincome_oth         money		DEFAULT 0 NULL,
	 avgrate_oth         money		DEFAULT 0 NULL
	)




TRUNCATE TABLE #agent_report

INSERT #agent_report(no) select distinct agent from ycus_xf where agent <> '' and date >= @beg_ and date <= @end_

UPDATE #agent_report set name = guest.name,sno = guest.sno,class2 = guest.class2 from guest where guest.no = #agent_report.no

UPDATE #agent_report set idname = saleid.name from saleid where saleid.code = #agent_report.saleid

UPDATE #agent_report set class2 = '40',class2name = '其他' where class2 not in ('005','009','010','025','071','072')
UPDATE #agent_report set class2 = '00',class2name = '杭州' where class2 = '005'
UPDATE #agent_report set class2 = '10',class2name = '上海' where class2 = '009'
UPDATE #agent_report set class2 = '20',class2name = '北京' where class2 = '010'
UPDATE #agent_report set class2 ='30',class2name = '江苏' where class2 in ('025','071','072')



UPDATE #agent_report set rquan_jap = (select count(distinct a.roomno) from ycus_xf a where a.agent = #agent_report.no and a.accnt = a.master  and a.date >= @beg_ and a.date <= @end_  and a.haccnt in (select no from guest where nation = 'JP'))
UPDATE #agent_report set rnight_jap = (select sum(a.i_days)from ycus_xf a where a.agent = #agent_report.no and a.accnt = a.master  and a.date >= @beg_ and a.date <= @end_  and a.haccnt in (select no from guest where nation = 'JP'))
UPDATE #agent_report set rincome_jap = (select sum(a.rm) from ycus_xf a where a.agent = #agent_report.no  and a.date >= @beg_ and a.date <= @end_  and a.haccnt in (select no from guest where nation = 'JP'))
UPDATE #agent_report set avgrate_jap = rincome_jap/rnight_jap where rnight_jap <> 0

UPDATE #agent_report set rquan_eur = (select count(distinct a.roomno) from ycus_xf a where a.agent = #agent_report.no and a.accnt = a.master  and a.date >= @beg_ and a.date <= @end_  and a.haccnt in (select no from guest where nation in (select code from countrycode where worldcode in ('02','03'))))
UPDATE #agent_report set rnight_eur = (select sum(a.i_days) from ycus_xf a where a.agent = #agent_report.no and a.accnt = a.master  and a.date>= @beg_ and a.date <= @end_  and a.haccnt in (select no from guest where nation in (select code from countrycode where worldcode in ('02','03'))))
UPDATE #agent_report set rincome_eur = (select sum(a.rm) from ycus_xf a where a.agent = #agent_report.no  and a.date >= @beg_ and a.date <= @end_  and a.haccnt in (select no from guest where nation in (select code from countrycode where worldcode in ('02','03'))))
UPDATE #agent_report set avgrate_eur = rincome_eur/rnight_eur where rnight_eur <> 0

UPDATE #agent_report set rquan_in = (select count(distinct a.roomno) from ycus_xf a where a.agent = #agent_report.no and a.accnt = a.master  and a.date >= @beg_ and a.date <= @end_  and a.haccnt in (select no from guest where nation = 'CN'))
UPDATE #agent_report setrnight_in = (select sum(a.i_days) from ycus_xf a where a.agent = #agent_report.no and a.accnt = a.master  and a.date >= @beg_ and a.date <= @end_  and a.haccnt in (select no from guest where nation = 'CN'))
UPDATE #agent_report set rincome_in = (select sum(a.rm) from ycus_xf a where a.agent = #agent_report.no  and a.date >= @beg_ and a.date <= @end_  and a.haccnt in (select no from guest where nation = 'CN'))
UPDATE #agent_report set avgrate_in = rincome_in/rnight_in where rnight_in <> 0

UPDATE #agent_report set rquan_hk = (select count(distinct a.roomno) from ycus_xf a where a.agent = #agent_report.no and a.accnt = a.master  and a.date >= @beg_ and a.date <= @end_  and a.haccnt in (select no from guest where nation in ('HK','TW','MO')))
UPDATE #agent_report set rnight_hk = (select sum(a.i_days) from ycus_xf a where a.agent = #agent_report.no and a.accnt = a.master  and a.date >= @beg_ and a.date <= @end_  and a.haccnt in (select no from guest where nation in ('HK','TW','MO')))
UPDATE #agent_report set rincome_hk = (select sum(a.rm) from ycus_xf a where a.agent = #agent_report.no  and a.date >= @beg_ and a.date <= @end_  and a.haccnt in (select no from guest where nation in ('HK','TW','MO')))
UPDATE #agent_report set avgrate_hk = rincome_hk/rnight_hk where rnight_hk <> 0

UPDATE #agent_report set rquan_oth = (select count(distinct a.roomno) from ycus_xf a where a.agent = #agent_report.no and a.accnt = a.master  and a.date >= @beg_ and a.date <= @end_ and a.haccnt in (select no from guest where nation not in ('JP','CN','HK','TW','MO') and nation not in (select code from countrycode where worldcode in ('02','03'))))
UPDATE #agent_report set rnight_oth = (select sum(a.i_days) from ycus_xf a where a.agent = #agent_report.no and a.accnt = a.master  and a.date >= @beg_ and a.date <= @end_  and a.haccnt in (select no from guest where nation not in ('JP','CN','HK','TW','MO') and nation not in (select code from countrycode where worldcode in ('02','03'))))
UPDATE #agent_report set rincome_oth = (select sum(a.rm)from ycus_xf a where a.agent = #agent_report.no  and a.date >= @beg_ and a.date <= @end_ and a.haccnt in (select no from guest where nation not in ('JP','CN','HK','TW','MO') and nation not in (select code from countrycode where worldcode in ('02','03'))))
UPDATE #agent_report set avgrate_oth = rincome_oth/rnight_oth where rnight_oth <> 0

INSERT #agent_report select '9999999','ZZZZZZZ','','90','当月合计','','',
SUM(rquan_jap),SUM(rnight_jap),SUM(rincome_jap),SUM(rincome_jap),
SUM(rquan_eur),SUM(rnight_eur),SUM(rincome_eur),SUM(rincome_eur),
SUM(rquan_in),SUM(rnight_in),SUM(rincome_in),SUM(rincome_in),
SUM(rquan_hk),SUM(rnight_hk),SUM(rincome_hk),SUM(rincome_hk),
SUM(rquan_oth),SUM(rnight_oth),SUM(rincome_oth),SUM(rincome_oth)
FROM #agent_report --whereclass2 not in ('00','10','20','30','40')


--SELECT * FROM #agent_report


-- return data
--SELECT * FROM #agent_report
SELECT class2name,NAME,rquan_jap,rnight_jap,avgrate_jap,rquan_eur,rnight_eur,avgrate_eur,rquan_in,rnight_in,avgrate_in,rquan_hk,rnight_hk,avgrate_hk,rquan_oth,rnight_oth,avgrate_oth FROM #agent_report order by class2
RETURN;
