IF OBJECT_ID('dbo.p_clg_report_group_list') IS NOT NULL
    DROP PROCEDURE dbo.p_clg_report_group_list
;
create proc p_clg_report_group_list
	@dbegin	datetime,
	@dend		datetime,
	@groupno		char(10),
	@sta			char(1),
    @ten            char(1),
    @market         char(5)
as
create table #rslt(
	groupno	char(10) null,
	accnt		char(10),
	haccnt	char(50),
	sta		char(1),
	arr		datetime,
	dep		datetime,
	type		char(5),
	roomno	char(5) null,
	rate		money,
	gstno		money,
	rmnum		money,
	refer1	varchar(250) null,
	srqs	char(30) null,
	ref	varchar(255) null,
	quan	money
)

insert into #rslt select a.groupno,a.accnt,b.haccnt,a.sta,a.arr,a.dep,a.type,a.roomno,a.setrate,a.gstno,a.rmnum,d.refer1,a.srqs,a.ref,1
	from master a,master_des b,guest d,master e where a.groupno=e.accnt and a.haccnt=d.no and a.accnt=b.accnt and a.class='F' and a.groupno<>'' and (rtrim(@groupno) is null or a.groupno=@groupno) and datediff(dd,e.arr,@dend)>=0 and datediff(dd,e.dep,@dbegin)<0 and a.accnt=a.master
insert into #rslt select a.groupno,a.accnt,b.haccnt,a.sta,a.arr,a.dep,a.type,a.roomno,a.setrate,a.gstno,a.rmnum,d.refer1,a.srqs,a.ref,0
	from master a,master_des b,guest d,master e where a.groupno=e.accnt and a.haccnt=d.no and a.accnt=b.accnt and a.class='F' and a.groupno<>'' and (rtrim(@groupno) is null or a.groupno=@groupno) and datediff(dd,e.arr,@dend)>=0 and datediff(dd,e.dep,@dbegin)<0 and a.accnt<>a.master

insert into #rslt select a.accnt,a.accnt,b.haccnt,'R',a.begin_,a.end_,a.type,'',a.rate,a.gstno,a.quantity,'',a.srqs,a.remark,1 from rsvsrc a,master_des b where a.accnt=b.accnt and a.accnt like 'G%' and a.type not in ('PM','PF') and (rtrim(@groupno) is null or a.accnt=@groupno) and datediff(dd,a.begin_,@dend)>=0 and datediff(dd,a.end_,@dbegin)<0

select a.*,c.haccnt,c.cusno+'/'+c.agent+'/'+c.source,b.arr,b.dep,b.market,b.ratecode,b.resno,b.ref,b.comsg from #rslt a,master b,master_des c,restype e where a.groupno=b.accnt and b.accnt=c.accnt and b.sta=@sta and b.restype=e.code and (e.definite=@ten or @ten='A') and (b.market=@market or rtrim(@market) is null) order by a.groupno
--select a.accnt,a.groupno,a.resno,c.type,numb041  =  c.quantity,numb042  =  c.gstno,char05  =  c.roomno,mone10  =  c.rate,a.ratecode,c.arr,
--c.dep,b.haccnt,e.descript,d.i_times,char901  =  b.cusno+'/'+b.agent+'/'+b.source,a.srqs,a.sta,
--char40  =  d.feature+' '+d.rmpref,d.refer1,a.ref,a.arrinfo ,a.market,a.accnt,d.refer1,a.roomno,
--char100 = ( select master.ref from master where master.accnt like 'G%' and (master.accnt = a.groupno or master.accnt = a.accnt)),
--char101 = ( select master.exp_s6 from master where master.accnt like 'G%' and (master.accnt = a.groupno or master.accnt = a.accnt))
--from rsvsrc c,master a,master_des b,guest d,basecode e,restype f
--where e.cat='vip' and d.vip*=e.code and a.haccnt=d.no and c.accnt=a.accnt and a.accnt=b.accnt
--and (a.groupno <> '' or a.class in ('G',  'M'))  and a.restype*=f.code
;