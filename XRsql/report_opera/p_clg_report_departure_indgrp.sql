--E78µÄ¹ý³Ì
drop proc p_clg_report_departure_indgrp;
create proc p_clg_report_departure_indgrp
	@date	datetime
as

create table #goutput(
	roomno	char(10)		null,
	name		varchar(50)	null,
	sta		char(12)		null,
	adults	char(8)		null,
	children	char(10)		null)
insert into #goutput values(' Room No.','                          Name',' Room Status',' Adults',' Children')

insert into #goutput select a.roomno,b.name,a.sta,convert(char(2),a.gstno),convert(char(2),a.children) from master a,guest b
 where a.haccnt=b.no and datediff(dd,a.dep,@date)=0 and a.class='F' and a.groupno='' and charindex(a.sta,"XNR")=0 order by a.roomno
insert into #goutput select a.roomno,b.name,a.sta,convert(char(2),a.gstno),convert(char(2),a.children) from hmaster a,guest b
 where a.haccnt=b.no and datediff(dd,a.dep,@date)=0 and a.class='F' and a.groupno='' and charindex(a.sta,"XNR")=0 order by a.roomno

insert into #goutput values('','','','','')
insert into #goutput values('','','','','')
insert into #goutput values(' Room No.','                       Group Name',' Room Status',' Adults',' Children')

insert into #goutput select a.roomno,b.name,a.sta,convert(char(2),a.gstno),convert(char(2),a.children) from master a,guest b,master c
 where a.groupno=c.accnt and c.haccnt=b.no and datediff(dd,a.dep,@date)=0 and a.class='F' and a.groupno<>'' and charindex(a.sta,"XNR")=0 order by a.roomno
insert into #goutput select a.roomno,b.name,a.sta,convert(char(2),a.gstno),convert(char(2),a.children) from hmaster a,guest b,master c
 where a.groupno=c.accnt and c.haccnt=b.no and datediff(dd,a.dep,@date)=0 and a.class='F' and a.groupno<>'' and charindex(a.sta,"XNR")=0 order by a.roomno

select * from #goutput
;