IF OBJECT_ID('dbo.p_yjw_audit_tchg_report') IS NOT NULL
    DROP PROCEDURE dbo.p_yjw_audit_tchg_report
;

create procedure p_yjw_audit_tchg_report
as
declare
  @bdate 			datetime,
  @ndate 			datetime,
  @rmrate_old 		money,
  @rmrate			money,
  @rate_old			money,
  @rate				money,
  @pkg_old			varchar(50),
  @pkg				varchar(50),
  @ratecode_old	char(10),
  @ratecode			char(10)


create table #tmp
(
	accnt 			char(10) null,
  	sta				char(1) null,
	name  			varchar(50) null,
	roomno  			char(5) null,
	ratecode_old	char(10) null,
	ratecode			char(10) null,
	rmrate_old  	money null,
	rmrate			money null,
   ratediff1     	money null,
	rate_old			money null,
	rate				money null,
	ratediff2		money null,
	pkg_old			varchar(50) null,
	pkg				varchar(50) null,
	haccnt			char(7)  null

)

select @bdate=bdate,@ndate=dateadd(day,1,bdate) from sysdata
insert #tmp select a.accnt,a.sta,b.name,a.roomno,isnull(a.ratecode,''),null,a.rmrate,null,null,a.setrate,null,null,a.packages,null,a.haccnt from master a,guest b where a.haccnt=b.no and a.accnt like 'F%'
update #tmp set ratecode=rsvsrc_detail.ratecode,rmrate=rsvsrc_detail.rmrate,rate=rsvsrc_detail.rate,pkg=rsvsrc_detail.packages from rsvsrc_detail
            where #tmp.accnt=rsvsrc_detail.accnt and rsvsrc_detail.date_=@ndate

delete #tmp where ratecode_old=ratecode and rmrate=rmrate_old and rate_old=rate and pkg_old=pkg
delete #tmp where ratecode is null and rmrate is null and rate is null and pkg is null



update #tmp set ratediff1=rmrate - rmrate_old,ratediff2=rate - rate_old
update #tmp set ratecode_old =null,ratecode=null where ratecode_old=ratecode
update #tmp set pkg_old =null,pkg=null where pkg_old=pkg
update #tmp set rmrate_old =null,rmrate=null where rmrate_old=rmrate
update #tmp set rate_old =null,rate=null where rate_old=rate
select accnt,name,roomno,ratecode_old,ratecode,rmrate_old,rmrate,ratediff1,rate_old,rate,ratediff2,pkg_old,pkg,haccnt from #tmp
;