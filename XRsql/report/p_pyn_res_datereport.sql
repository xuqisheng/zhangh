IF OBJECT_ID('dbo.p_pyn_res_datereport') IS NOT NULL
    DROP PROCEDURE dbo.p_pyn_res_datereport
;
create proc p_pyn_res_datereport
  @bdate  datetime,
  @edate  datetime
  as
declare @haccnt   char(7)
create table #resreport(
			type       char(5)       null,
			resby		  char(10)      null,
		   quantity   integer       null,
         gstno		  integer       null,
		   roomno	  char(5)       null,
			rate		  money         null,
			resno		  char(10)      null,
			ratecode   char(10)      null,
			packages	  varchar(50)   null,
			restime    datetime      null,
			arr		  datetime      null,
			dep		  datetime      null,
			days		  integer       null,
			haccnt     char(7)       null,
         haccnt_    varchar(50)   null,
			descript   varchar(60)   null,
			i_times    integer       null,
         groupno    char(10)      null,
			cusno      char(7)       null,
			agent      char(7)       null,
			source     char(7)       null,
         cusagso    varchar(255)  null,
			srqs       varchar(30)   null,
			feature    varchar(30)   null,
			rmpref	  varchar(20)   null,
			refer1     varchar(255)  null,
			arrinfo    varchar(30)   null )

insert #resreport
select c.type,a.resby,c.quantity,c.gstno,c.roomno,c.rate,a.resno,a.ratecode,a.packages,
		 a.restime,c.arr,c.dep,datediff(dd,  c.arr,  c.dep),a.haccnt,'',e.descript,d.i_times,
		 a.groupno,a.cusno,a.agent,a.source,'',a.srqs,d.feature,d.rmpref,d.refer1,a.arrinfo
	from rsvsrc c,master a,guest d,basecode e
	where e.cat='vip' and d.vip*=e.code and a.haccnt=d.no and c.accnt=a.accnt  and a.sta = 'R' and a.class in ('G','M','F')
	and datediff(dd,  a.restime,  @bdate)<=0 and datediff(dd,  @edate,  a.restime )<=0  and substring(a.extra, 9,1)<>'1'
union all
select a.type,a.resby,a.rmnum,a.gstno,a.roomno,a.setrate,a.resno,a.ratecode,a.packages,
		 a.restime,a.arr,a.dep,datediff(dd,  a.arr,  a.dep),a.haccnt,'',e.descript,d.i_times,
		 a.groupno,a.cusno,a.agent,a.source,'',a.srqs,d.feature,d.rmpref,d.refer1,a.arrinfo
	from master a,guest d,basecode e
	where e.cat='vip' and d.vip*=e.code and a.haccnt=d.no and a.sta <>'R' and a.class='F'
	and datediff(dd,  a.restime,  @bdate)<=0 and datediff(dd,  @edate,  a.restime )<=0  and substring(a.extra, 9,1)<>'1'
union all
select a.type,a.resby,a.rmnum,a.gstno,a.roomno,a.setrate,a.resno,a.ratecode,a.packages,
		 a.restime,a.arr,a.dep,datediff(dd,  a.arr,  a.dep),a.haccnt,'',e.descript,d.i_times,
		 a.groupno,a.cusno,a.agent,a.source,'',a.srqs,d.feature,d.rmpref,d.refer1,a.arrinfo
	from hmaster a,guest d,basecode e
	where e.cat='vip' and d.vip*=e.code and a.haccnt = d.no  and a.class='F'
	and datediff(dd,  a.restime,  @bdate)<=0 and datediff(dd,  @edate,  a.restime )<=0  and substring(a.extra, 9,1)<>'1'

update #resreport set haccnt_ = guest.name from guest where guest.no= #resreport.haccnt

update #resreport set cusagso = a.name from guest a, master b where #resreport.groupno=b.accnt and a.no = b.haccnt
update #resreport set cusagso = a.name from guest a, hmaster b where #resreport.groupno=b.accnt and a.no = b.haccnt

update #resreport set cusagso = substring(cusagso+' / ' + a.name, 1, 50) from guest a where a.no = #resreport.cusno
update #resreport set cusagso = substring(cusagso+' / ' + a.name, 1, 50) from guest a where a.no = #resreport.agent
update #resreport set cusagso = substring(cusagso+' / ' + a.name, 1, 50) from guest a where a.no = #resreport.source

select type,resby,quantity,quantity*gstno,roomno,rate,resno,ratecode,packages,convert(char(10),restime,11),arr,dep,quantity*days,
       haccnt_,descript,i_times,substring(cusagso,1,90),srqs,feature,rmpref,substring(refer1,1,90),arrinfo
	from #resreport order by restime,resby,resno

return
;
