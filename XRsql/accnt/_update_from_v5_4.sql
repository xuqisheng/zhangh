// 分账户定义表
update subaccnt set pccodes = a.pccodes from v5..accnt_ab a
	where subaccnt.type = '0' and a.type = '0' and substring(subaccnt.accnt, 3, 7) = a.accnt;
//
update subaccnt set pccodes = '+000;001;002;003;004;005;006;007;009;011;012;013' where pccodes = '+;01;02;';
update subaccnt set pccodes = '-000;001;002;003;004;005;006;007;009;011;012;013' where pccodes = '-;01;02;';
//update subaccnt set roomno = a.roomno from v5..master a where subaccnt.accnt = a.accnt;
//update subaccnt set to_roomno = a.roomno from v5..master a where subaccnt.to_accnt = a.accnt;

truncate table accredit;
insert accredit select accnt,number,paycode,cardno,'2004/1/1',foliono,creditno,amount,tag,empno1,bdate1,shift1,log_date1,
	empno2,bdate2,shift2,log_date2,partout,billno from v5..accredit where tag = '0';
update accredit set accnt = a.accnt from master a where accredit.accnt = substring(a.accnt, 3, 7);
update accredit set pccode = a.pccode from pccode a where accredit.pccode = a.deptno2;

if exists (select * from sysobjects where name = 'aa' and type ='U')
	drop table aa;
create table aa
(
	accnt			char(10)		not null,
	number		integer		default 0 not null,
	amount		money			default 0 not null,
);
insert aa select accnt, count(1), sum(amount) from accredit group by accnt;
update master set accredit = a.amount, lastinumb = a.number from aa a where master.accnt = a.accnt;
drop table aa;
update master set paycode = a.pccode from pccode a where master.paycode = a.deptno2;

truncate table gltemp;
insert gltemp select a.* from account a,sysdata b where datediff(dd,a.bdate,b.bdate1)=1;
truncate table outtemp;
insert outtemp select a.* from account a,sysdata b
	where billno like 'B' + substring(convert(char(10),dateadd(dd, -1, b.bdate1),111),4,1) + 
	substring(convert(char(10),dateadd(dd, -1, b.bdate1),111),6,2)+substring(convert(char(10),dateadd(dd, -1, b.bdate1),111),9,2) + '%';

truncate table billno;
insert billno select * from v5..billno;
