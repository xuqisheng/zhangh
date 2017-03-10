drop table ar_test;
create table ar_test(
   no			char(20)
   araccnt      char(10)     NOT NULL,
   amount		money,
   type			char(1),
   sta			char(1)
);
EXEC sp_primarykey 'dbo.ar_test', araccnt;

insert into ar_test select no,araccnt1,0,type,sta from vipcard where araccnt1<>'' order by araccnt1;

select type,sta,count(1) from vipcard group by type,sta order by type;

select * from vipcard where araccnt1 in ('AR00718');

select * from har_master;

select a.sno,(b.charge-b.credit) from vipcard a,ar_master b where a.araccnt1=b.accnt;
select a.sno,(b.charge-b.credit) from vipcard a,har_master b where a.araccnt1=b.accnt;


select b.artag1,b.accnt from ar_test a,ar_master b where a.araccnt=b.accnt order by b.artag1;

select a.araccnt from ar_test a where not exists(select 1 from ar_master b where a.araccnt=b.accnt and b.artag1='3') order by a.araccnt;

select a.araccnt from ar_test a where exists(select 1 from har_master b where a.araccnt=b.accnt and b.artag1='3') order by a.araccnt;

select a.araccnt from ar_test a where exists(select 1 from ar_master b where a.araccnt=b.accnt and b.artag1='3') order by a.araccnt;

select araccnt,amount from ar_test order by araccnt;

select * from ar_test where araccnt in ('AR00718');

update ar_test set amount=(select isnull(b.charge-b.credit,0) from ar_master b where ar_test.araccnt=b.accnt);

select sum(amount) from ar_test;