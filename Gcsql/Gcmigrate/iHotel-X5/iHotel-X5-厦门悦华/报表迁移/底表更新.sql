UPDATE rep_jie a,(SELECT biz_date,classno,descript,SUM(day01) day01,SUM(day02) day02,SUM(day03) day03,SUM(day04) day04,SUM(day05) day05,SUM(day06) day06,SUM(day07) day07,SUM(day08) day08,SUM(day09) day09,SUM(day99) day99,SUM(month01) month01,SUM(month02) month02,
SUM(month03) month03,SUM(month04) month04,SUM(month05) month05,SUM(month06) month06,SUM(month07) month07,SUM(month08) month08,SUM(month09) month09,SUM(month99) month99 FROM portal_tr.rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1  GROUP BY biz_date,classno ORDER BY biz_date,classno ) b 
SET a.day01 = b.day01,a.day02 = b.day02,a.day03 = b.day03,a.day04 = b.day04,a.day05 = b.day05,a.day06 = b.day06,a.day07 = b.day07,a.day08 = b.day08,a.day09 = b.day09,a.day99 = b.day99,
a.month01 = b.month01,a.month02 = b.month02,a.month03 = b.month03,a.month04 = b.month04,a.month05 = b.month05,a.month06 = b.month06,a.month07 = b.month07,a.month08 = b.month08,a.month09 = b.month09,a.month99 = b.month99
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.biz_date = '2014.12.07' AND b.biz_date = '2014.12.07' 
AND a.classno = b.classno;

SELECT * FROM rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1;
SELECT * FROM rep_dai WHERE hotel_group_id = 1 AND hotel_id = 1;

UPDATE rep_dai a,(SELECT biz_date,classno,descript,SUM(credit01) credit01,SUM(credit02) credit02,SUM(credit03) credit03,SUM(credit04) credit04,SUM(credit05) credit05,SUM(credit06) credit06,SUM(credit07) credit07,SUM(sumcre) sumcre,SUM(last_bl) last_bl,SUM(debit) debit,SUM(credit) credit,SUM(till_bl) till_bl,
SUM(credit01m) credit01m,SUM(credit02m) credit02m,SUM(credit03m) credit03m,SUM(credit04m) credit04m,SUM(credit05m) credit05m,SUM(credit06m) credit06m,SUM(credit07m) credit07m,SUM(sumcrem) sumcrem,SUM(last_blm) last_blm,SUM(debitm) debitm,SUM(creditm) creditm,SUM(till_blm) till_blm
FROM portal_tr.rep_dai WHERE hotel_group_id = 1 AND hotel_id = 1 GROUP BY biz_date,classno ORDER BY biz_date,classno) b SET a.credit01 = b.credit01,a.credit02 = b.credit02,a.credit03 = b.credit03,a.credit04 = b.credit04,a.credit05 = b.credit05,a.credit06 = b.credit06,a.credit07 = b.credit07,
a.sumcre = b.sumcre,a.last_bl = b.last_bl,a.debit = b.debit,a.credit = b.credit,a.till_bl = b.till_bl,a.credit01m = b.credit01m,a.credit02m =b.credit02m,
a.credit03m = b.credit03m,a.credit04m = b.credit04m,a.credit05m = b.credit05m,a.credit06m = b.credit06m,a.credit07m = b.credit07m,a.sumcrem = b.sumcrem,a.last_blm = b.last_blm,a.debitm = b.debitm,a.creditm = b.creditm,a.till_blm = b.till_blm
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.biz_date = '2014.12.07' AND b.biz_date = '2014.12.07' 
AND a.classno = b.classno AND a.classno = '01998';

-- jiedai
UPDATE rep_jiedai a,(SELECT biz_date,classno,SUM(last_charge) last_charge,SUM(last_credit) last_credit,SUM(charge) charge,SUM(credit) credit,SUM(apply) apply,SUM(till_charge) till_charge,SUM(till_credit) till_credit,
SUM(last_chargem) last_chargem,SUM(last_creditm) last_creditm,SUM(chargem) chargem,SUM(creditm) creditm,SUM(applym) applym,SUM(till_chargem) till_chargem,SUM(till_creditm) till_creditm FROM portal_tr.rep_jiedai WHERE hotel_group_id = 1 AND hotel_id = 1
GROUP BY biz_date,classno) b 
SET a.last_charge = b.last_charge,a.last_credit = b.last_credit,a.charge = b.charge,
a.credit = b.credit,a.apply = b.apply,a.till_charge = b.till_charge,a.till_credit = b.till_credit,
a.last_chargem = b.last_chargem,a.last_creditm = b.last_creditm,a.chargem = b.chargem,
a.creditm = b.creditm,a.applym = b.applym,a.till_chargem = b.till_chargem,a.till_creditm = b.till_creditm 
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.biz_date = '2014.12.07' AND b.biz_date = '2014.12.07'
AND a.classno = b.classno;



