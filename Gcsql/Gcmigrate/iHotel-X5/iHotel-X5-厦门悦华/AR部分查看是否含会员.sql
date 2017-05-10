//select count(1) from vipcard a,ar_master b where a.araccnt1 = b.accnt;

//select sum(charge),sum(credit),sum(accredit) from ar_master where artag1 = 'VP';
//
//2591635.3500 2826119.4000
//5164281.6000

//select sum(b.charge),sum(b.credit),sum(b.accredit)  from vipcard a,ar_master b where a.araccnt1 = b.accnt;
//
//select sum(charge),sum(credit),sum(accredit) from ar_master where artag1 = 'VP'
//and accnt not in(select araccnt1 from vipcard where araccnt1 <> '');

//select * from ar_master where artag1 = 'VP'
//and accnt not in(select araccnt1 from vipcard where araccnt1 <> '');