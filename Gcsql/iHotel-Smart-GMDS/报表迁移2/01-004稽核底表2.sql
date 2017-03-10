-- 日期改成迁移日期减去 1 天
SELECT * FROM portal.rep_jie_history WHERE hotel_group_id = 1 AND hotel_id = 5  AND biz_date<='2015.11.03';
DELETE FROM  portal.rep_jie_history WHERE  hotel_group_id = 1 AND hotel_id = 5 AND biz_date <= '2015.11.03';
SELECT * FROM migrate_xmhy.yjierep WHERE DATE = '2015.11.03' AND class = '001';

SELECT * FROM portal.rep_jie WHERE hotel_group_id = 1 AND hotel_id = 5  AND biz_date<='2015.11.03';
-- 借方直接导入历史表
INSERT INTO portal.rep_jie_history
	(hotel_group_id, 
	hotel_id, 
 	biz_date, 
	orderno, 
	itemno, 
	modeno, 
	classno, 
	descript, 
	descript1, 
	rectype, 
	toop, 
	toclass, 
	sequence, 
	day01, 
	day02, 
	day03, 
	day04, 
	day05, 
	day06, 
	day07, 
	day08, 
	day09, 
	day99, 
	month01, 
	month02, 
	month03, 
	month04, 
	month05, 
	month06, 
	month07, 
	month08, 
	month09, 
	month99
	)
SELECT  1, 
	5, 
 	DATE, 
	'F', 
	NULL, 
	MODE, 
	class, 
	descript, 
	descript1, 
	rectype, 
	toop, 
	toclass, 
	NULL, 
	day01, 
	day02, 
	day03, 
	day04, 
	day05, 
	day06, 
	day07, 
	day08, 
	day09, 
	day99, 
	month01, 
	month02, 
	month03, 
	month04, 
	month05, 
	month06, 
	month07, 
	month08, 
	month09, 
	month99
FROM migrate_xmhy.yjierep  WHERE DATE >='2013.01.01' AND DATE <= '2015.11.03';

-- 查看
SELECT * FROM portal.rep_jie_history WHERE hotel_group_id = 1 AND hotel_id = 5   AND  biz_date = '2015.11.03' ORDER BY biz_date,classno;


-- 导入历史贷方表
SELECT * FROM migrate_xmhy.ydairep WHERE DATE = '2015.11.03';
SELECT * FROM portal.rep_dai WHERE hotel_group_id = 1 AND hotel_id = 5;

SELECT * FROM portal.rep_dai_history WHERE hotel_group_id = 1 AND hotel_id = 5 ORDER BY biz_date,classno;

SELECT DISTINCT biz_date FROM portal.rep_dai_history WHERE hotel_id = 5;
DELETE FROM portal.rep_dai_history WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date <='2015.11.03';

-- 对照存在的项目
ALTER TABLE migrate_xmhy.ydairep ADD CODE CHAR(10) NOT NULL DEFAULT ''  AFTER class;
UPDATE migrate_xmhy.ydairep SET CODE = class;
UPDATE migrate_xmhy.ydairep SET CODE = '01998' WHERE CODE IN('0120','0130');
UPDATE  migrate_xmhy.ydairep  SET CODE = '' WHERE class IN('0810','0820','0830','0840','0850','0870');
SELECT * FROM migrate_xmhy.ydairep WHERE DATE ='2015.11.03'


INSERT INTO portal.rep_dai_history
	(hotel_group_id, 
	hotel_id, 
 	biz_date, 
	orderno, 
	itemno, 
	modeno, 
	classno, 
	descript, 
	descript1, 
	sequence, 
	credit01, 
	credit02, 
	credit03, 
	credit04, 
	credit05, 
	credit06, 
	credit07, 
	sumcre, 
	last_bl, 
	debit, 
	credit, 
	till_bl, 
	credit01m, 
	credit02m, 
	credit03m, 
	credit04m, 
	credit05m, 
	credit06m, 
	credit07m, 
	sumcrem, 
	last_blm, 
	debitm, 
	creditm, 
	till_blm
	)
SELECT  1, 
	5, 
 	DATE, 
	order_, 
	itemno, 
	MODE, 
	CODE, 
	descript, 
	descript1, 
	NULL, 
	SUM(credit01), 
	SUM(credit02), 
	SUM(credit03), 
	SUM(credit04), 
	SUM(credit05), 
	SUM(credit06), 
	SUM(credit07), 
	SUM(sumcre), 
	SUM(last_bl), 
	SUM(debit), 
	SUM(credit), 
	SUM(till_bl), 
	SUM(credit01m), 
	SUM(credit02m), 
	SUM(credit03m), 
	SUM(credit04m), 
	SUM(credit05m), 
	SUM(credit06m), 
	SUM(credit07m), 
	SUM(sumcrem), 
	SUM(last_blm), 
	SUM(debitm), 
	SUM(creditm), 
	SUM(till_blm)
FROM migrate_xmhy.ydairep WHERE DATE>='2013.01.01' AND DATE<='2015.11.03' AND CODE <> '' GROUP BY DATE,CODE; 

SELECT * FROM migrate_xmhy.ydairep WHERE DATE='2015.11.03' ORDER BY DATE,class;
SELECT * FROM migrate_xmhy.yjiedai ORDER BY DATE,class;
SELECT * FROM portal.rep_dai_history WHERE hotel_id = 5  AND biz_date ='2015.11.03'


-- 借贷表
ALTER TABLE migrate_xmhy.yjiedai ADD CODE CHAR(10) NOT NULL DEFAULT ''  AFTER class;
UPDATE migrate_xmhy.yjiedai a,migrate_xmhy.jiedai b SET a.code = b.code WHERE a.class = b.class;
SELECT * FROM portal.rep_jiedai_history WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date <='2015.11.03';
DELETE FROM   portal.rep_jiedai_history WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date <='2015.11.03';

INSERT INTO portal.rep_jiedai_history 
	(hotel_group_id, 
	hotel_id, 
 	biz_date, 
	orderno, 
	itemno, 
	modeno, 
	classno, 
	descript, 
	descript1, 
	sequence, 
	last_charge, 
	last_credit, 
	charge, 
	credit, 
	apply, 
	till_charge, 
	till_credit, 
	last_chargem, 
	last_creditm, 
	chargem, 
	creditm, 
	applym, 
	till_chargem, 
	till_creditm
	)
SELECT  1, 
	5, 
 	DATE, 
	order_, 
	itemno, 
	MODE, 
	class, 
	descript, 
	descript1, 
	NULL, 
	last_charge, 
	last_credit, 
	charge, 
	credit, 
	apply, 
	till_charge, 
	till_credit, 
	last_chargem, 
	last_creditm, 
	chargem, 
	creditm, 
	applym, 
	till_chargem, 
	till_creditm
FROM migrate_xmhy.yjiedai WHERE DATE>= '2013.01.01' AND DATE<= '2015.11.03'; 
-- UPDATE rep_jiedai SET last_charge = 0,charge = 0,credit = 0,till_charge = 0,till_credit = 0,last_chargem = 0,chargem = 0,
-- creditm = 0,till_chargem = 0,till_creditm = 0 WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date = 2014.04.20

 

 
 