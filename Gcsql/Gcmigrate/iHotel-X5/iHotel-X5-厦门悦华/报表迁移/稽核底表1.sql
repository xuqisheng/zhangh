ALTER TABLE migrate_xmyh.jierep ADD CODE CHAR(10) NOT NULL DEFAULT '' AFTER class;
-- 对照
SELECT * FROM migrate_xmyh.jierep ORDER BY DATE,class;
SELECT biz_date,classno,descript,toclass FROM portal.rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1 ORDER BY biz_date,classno;
SELECT * FROM migrate_xmyh.jie_map ORDER BY classno;
SELECT biz_date,classno,descript FROM rep_jie WHERE hotel_id = 1 ORDER BY classno;
SELECT * FROM migrate_xmyh.jie_map GROUP BY classno HAVING COUNT(1) > 1;
SELECT * FROM migrate_xmyh.jie_map WHERE CODE NOT IN(SELECT class FROM migrate_xmyh.jierep);
SELECT * FROM rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1 ORDER BY classno;
SELECT * FROM migrate_xmyh.jierep WHERE class IN
(SELECT CODE FROM migrate_xmyh.jie_map WHERE classno NOT IN(SELECT classno FROM portal.rep_jie));

SELECT * FROM migrate_xmyh.jie_map WHERE classno NOT IN(SELECT classno FROM portal.rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1);

 -- 修改code
UPDATE migrate_xmyh.jierep a, migrate_xmyh.jie_map b SET a.code = b.classno WHERE a.class = b.code;

SELECT * FROM migrate_xmyh.jierep ORDER BY DATE,class;
SELECT * FROM migrate_xmyh.jie_map;
SELECT biz_date,classno,descript FROM portal_tr.rep_jie WHERE hotel_id = 1 ORDER BY classno;

SELECT * FROM migrate_xmyh.jierep WHERE CODE = '' AND day99 <> 0 ORDER BY DATE,class;
-- SELECT * FROM migrate_xmyh.jierep group by code having count(1) > 1;
SELECT * FROM migrate_xmyh.jierep WHERE CODE = ' '
SELECT * FROM migrate_xmyh.jierep  GROUP BY CODE HAVING COUNT(1) > 1;

SELECT classno,descript,day99 FROM portal_tr.rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1 ORDER BY biz_date,classno
SELECT a.*,b.* FROM rep_jie a,migrate_xmyh.jierep b WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.biz_date = '2014.12.07'
AND a.biz_date = b.date AND a.classno = b.code;
SELECT * FROM rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1 AND classno NOT IN(SELECT CODE FROM migrate_xmyh.jierep) 
ORDER BY biz_date,classno

SELECT * FROM rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07';

UPDATE rep_jie SET day01 = 0,day02 = 0,day03 = 0,day04 = 0,day05 = 0,day06 = 0,day07 = 0,day08 = 0,day09 = 0,day09 = 0,day99 = 0,
month01 = 0,month02 = 0,month03 = 0,month04=0,month05 = 0,month06 = 0,month07 = 0,month08 = 0,month09 = 0,month99 = 0 WHERE hotel_group_id = 1 AND hotel_id = 1 
AND biz_date = '2014.12.07';

UPDATE rep_jie a,(SELECT DATE,CODE,descript,SUM(day01) day01,SUM(day02) day02,SUM(day03) day03,SUM(day04) day04,SUM(day05) day05,SUM(day06) day06,SUM(day07) day07,SUM(day08) day08,SUM(day09) day09,SUM(day99) day99,SUM(month01) month01,SUM(month02) month02,
SUM(month03) month03,SUM(month04) month04,SUM(month05) month05,SUM(month06) month06,SUM(month07) month07,SUM(month08) month08,SUM(month09) month09,SUM(month99) month99 FROM migrate_xmyh.jierep GROUP BY DATE,CODE ORDER BY DATE,CODE ) b 
SET a.day01 = b.day01,a.day02 = b.day02,a.day03 = b.day03,a.day04 = b.day04,a.day05 = b.day05,a.day06 = b.day06,a.day07 = b.day07,a.day08 = b.day08,a.day09 = b.day09,a.day99 = b.day99,
a.month01 = b.month01,a.month02 = b.month02,a.month03 = b.month03,a.month04 = b.month04,a.month05 = b.month05,a.month06 = b.month06,a.month07 = b.month07,a.month08 = b.month08,a.month09 = b.month09,a.month99 = b.month99
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.biz_date = '2014.12.07' AND b.date = '2014.12.07' 
AND a.classno = b.code;

SELECT * FROM rep_jie WHERE hotel_id = 1 ORDER BY biz_date,classno;

-- 贷方
ALTER TABLE migrate_xmyh.dairep ADD CODE CHAR(10) NOT NULL DEFAULT '' AFTER class;
SELECT * FROM rep_dai WHERE hotel_group_id = 1 AND hotel_id = 1 ORDER BY biz_date,classno;
SELECT * FROM migrate_xmyh.dairep ORDER BY DATE,class;

UPDATE migrate_xmyh.dairep  SET CODE = class ;
UPDATE migrate_xmyh.dairep  SET CODE = '01998' WHERE class IN('0120','0130');
UPDATE migrate_xmyh.dairep  SET CODE = '' WHERE class IN('0820','0830','0850','0870');


SELECT * FROM rep_dai WHERE hotel_id = 1 ORDER BY biz_date,classno;
SELECT * FROM migrate_xmyh.dairep ORDER BY DATE,class;
SELECT DATE,CODE,descript,SUM(credit01) credit01,SUM(credit02) credit02,SUM(credit03) credit03,SUM(credit04) credit04,SUM(credit05) credit05,SUM(credit06) credit06,SUM(credit07) credit07,SUM(sumcre) sumcre,SUM(last_bl) last_bl,SUM(debit) debit,SUM(credit) credit,SUM(till_bl) tillbl,
SUM(credit01m) credit01m,SUM(credit02m) credit02m,SUM(credit03m) credit03m,SUM(credit04m) credit04m,SUM(credit05m) credit05m,SUM(credit06m) credit06m,SUM(credit07m) credit07m,SUM(sumcrem) sumcrem,SUM(last_blm) last_blm,SUM(debitm) debitm,SUM(creditm) creditm,SUM(till_blm) tillblm
FROM migrate_xmyh.dairep WHERE CODE <> '' GROUP BY DATE,CODE ORDER BY DATE,CODE;

SELECT a.*,b.* FROM rep_dai a,migrate_xmyh.dairep b WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.biz_date = '2014.12.07'
AND a.classno = b.code;

SELECT 103526 - 18000;
SELECT 379953.00 + 45000;
SELECT * FROM rep_dai WHERE hotel_group_id = 1 AND hotel_id = 1 ORDER BY biz_date,classno;
UPDATE rep_dai SET credit01 =0,credit02 = 0,credit03 = 0,credit04 = 0,credit05 = 0,credit06 = 0,credit07 = 0,sumcre = 0,last_bl = 0,debit =0,credit = 0,till_bl =0,
credit01m =0,credit02m = 0,credit03m = 0,credit04m = 0,credit05m = 0,credit06m = 0,credit07m = 0,sumcrem = 0,last_blm = 0,debitm =0,creditm = 0,till_blm =0
WHERE hotel_group_id = 1 AND hotel_id = 1;

UPDATE rep_dai a,(SELECT DATE,CODE,descript,SUM(credit01) credit01,SUM(credit02) credit02,SUM(credit03) credit03,SUM(credit04) credit04,SUM(credit05) credit05,SUM(credit06) credit06,SUM(credit07) credit07,SUM(sumcre) sumcre,SUM(last_bl) last_bl,SUM(debit) debit,SUM(credit) credit,SUM(till_bl) till_bl,
SUM(credit01m) credit01m,SUM(credit02m) credit02m,SUM(credit03m) credit03m,SUM(credit04m) credit04m,SUM(credit05m) credit05m,SUM(credit06m) credit06m,SUM(credit07m) credit07m,SUM(sumcrem) sumcrem,SUM(last_blm) last_blm,SUM(debitm) debitm,SUM(creditm) creditm,SUM(till_blm) till_blm
FROM migrate_xmyh.dairep WHERE CODE <> '' GROUP BY DATE,CODE ORDER BY DATE,CODE) b SET a.credit01 = b.credit01,a.credit02 = b.credit02,a.credit03 = b.credit03,a.credit04 = b.credit04,a.credit05 = b.credit05,a.credit06 = b.credit06,a.credit07 = b.credit07,
a.sumcre = b.sumcre,a.last_bl = b.last_bl,a.debit = b.debit,a.credit = b.credit,a.till_bl = b.till_bl,a.credit01m = b.credit01m,a.credit02m =b.credit02m,
a.credit03m = b.credit03m,a.credit04m = b.credit04m,a.credit05m = b.credit05m,a.credit06m = b.credit06m,a.credit07m = b.credit07m,a.sumcrem = b.sumcrem,a.last_blm = b.last_blm,a.debitm = b.debitm,a.creditm = b.creditm,a.till_blm = b.till_blm
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.biz_date = '2014.12.07' AND b.date = '2014.12.07' 
AND a.classno = b.code AND a.classno = '01998';
 

 
SELECT * FROM rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1 ORDER BY biz_date,classno;

SELECT * FROM rep_dai  WHERE hotel_group_id = 1 AND hotel_id = 1 ORDER BY biz_date,classno;;
SELECT * FROM migrate_xmyh.dairep ORDER BY DATE,class;
SELECT * FROM migrate_xmyh.jiedai ORDER BY DATE,class;

-- 借贷表
ALTER TABLE migrate_xmyh.jiedai ADD CODE CHAR(10) NOT NULL DEFAULT '' AFTER class;

SELECT * FROM rep_jiedai WHERE hotel_group_id = 1 AND hotel_id = 1 ORDER BY biz_date,classno;
SELECT * FROM migrate_xmyh.jiedai;
UPDATE migrate_xmyh.jiedai SET CODE = class;
UPDATE migrate_xmyh.jiedai SET CODE = '02G' WHERE CODE = '02M';

UPDATE rep_jiedai SET last_charge = 0, last_credit = 0,charge = 0,credit = 0,apply = 0, 
till_charge = 0,till_credit = 0,last_chargem = 0,last_creditm = 0,chargem = 0,creditm = 0,applym = 0,till_chargem = 0, 
till_creditm = 0 WHERE hotel_group_id = 1 AND hotel_id = 1;

UPDATE rep_jiedai a,(SELECT DATE,CODE,SUM(last_charge) last_charge,SUM(last_credit) last_credit,SUM(charge) charge,SUM(credit) credit,SUM(apply) apply,SUM(till_charge) till_charge,SUM(till_credit) till_credit,
SUM(last_chargem) last_chargem,SUM(last_creditm) last_creditm,SUM(chargem) chargem,SUM(creditm) creditm,SUM(applym) applym,SUM(till_chargem) till_chargem,SUM(till_creditm) till_creditm FROM migrate_xmyh.jiedai
GROUP BY DATE,CODE) b 
SET a.last_charge = b.last_charge,a.last_credit = b.last_credit,a.charge = b.charge,
a.credit = b.credit,a.apply = b.apply,a.till_charge = b.till_charge,a.till_credit = b.till_credit,
a.last_chargem = b.last_chargem,a.last_creditm = b.last_creditm,a.chargem = b.chargem,
a.creditm = b.creditm,a.applym = b.applym,a.till_chargem = b.till_chargem,a.till_creditm = b.till_creditm 
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.biz_date = '2014.12.07' AND b.date = '2014.12.07'
AND a.classno = b.code;
 
-- UPDATE rep_jiedai SET last_charge = 0,charge = 0,credit = 0,till_charge = 0,till_credit = 0,last_chargem = 0,chargem = 0,
-- creditm = 0,till_chargem = 0,till_creditm = 0 WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07'
SELECT * FROM rep_jiedai WHERE hotel_group_id = 1 AND hotel_id = 1 ORDER BY biz_date,classno;
SELECT * FROM migrate_xmyh.jiedai;
 

 
SELECT * FROM rep_jiedai_history WHERE hotel_id = 1 AND  biz_date = '2014.12.07'
DELETE FROM rep_jie_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07';
DELETE FROM rep_dai_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07';
DELETE FROM rep_jiedai_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07';
INSERT INTO rep_jie_history SELECT * FROM rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07';
INSERT INTO rep_dai_history SELECT * FROM rep_dai WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07';
INSERT INTO rep_jiedai_history SELECT * FROM rep_jiedai WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07';
SELECT * FROM rep_jie WHERE hotel_id = 1 

SELECT * FROM card_snapshot WHERE hotel_id = 1 AND biz_date = '2014.12.07';

SELECT * FROM rep_dai_history WHERE hotel_id = 1;
SELECT * FROM rep_dai WHERE hotel_id = 1;