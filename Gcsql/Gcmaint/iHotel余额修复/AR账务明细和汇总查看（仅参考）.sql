 
-- 已审核的明细和汇总比较
SELECT b.accnt,b.number,b.charge + b.charge0 AS charge2,a.ar_accnt,a.charge,a.ar_inumber,c.ar_accnt,c.ar_inumber,c.charge1 FROM ar_detail a,ar_account b,
(SELECT ar_accnt,ar_inumber,SUM(charge) AS charge1 FROM ar_detail WHERE hotel_group_id = 12 AND hotel_id = 39 AND ar_subtotal = 'F'
GROUP BY ar_accnt,ar_inumber) c
WHERE a.hotel_group_id = 12 AND a.hotel_id = 39 AND  b.hotel_group_id = 12 AND b.hotel_id = 39
AND b.accnt = c.ar_accnt AND c.ar_inumber = b.number
AND  a.ar_subtotal = 'T'    
AND b.accnt = a.ar_accnt AND b.audit_tag = '1' AND b.number = a.ar_inumber
AND b.accnt = 1090;

-- 汇总表按账次汇总 
SELECT number, SUM(charge+charge0 -charge9)-SUM(pay+pay0-pay9) FROM ar_account WHERE hotel_group_id = 12 AND hotel_id = 39 AND accnt = 1090 
GROUP BY number;
-- 明细表按账次汇总
SELECT ar_inumber, SUM(charge-charge9)-SUM(pay-credit9) FROM ar_detail WHERE hotel_group_id = 12 AND hotel_id = 39 AND ar_accnt = 1090 AND ar_subtotal = 'F'
GROUP BY ar_inumber;

SELECT number, SUM(charge+charge0),SUM(charge9),SUM(pay+pay0),SUM(pay9) FROM ar_account WHERE hotel_group_id = 12 AND hotel_id = 39 AND accnt = 1090;

SELECT ar_inumber, SUM(charge),SUM(charge9),SUM(pay),SUM(credit9) FROM ar_detail WHERE hotel_group_id = 12 AND hotel_id = 39 AND ar_accnt = 1090 AND ar_subtotal = 'F';
-- 明细数据汇总
SELECT b.accnt,b.biz_date,SUM(a.charge) charge,SUM(a.pay) pay FROM ar_detail a,ar_account b 
WHERE a.hotel_group_id = 12 AND a.hotel_id = 39 AND a.ar_accnt = 1090
	AND a.ar_accnt = b.accnt AND b.hotel_group_id = 12 AND b.hotel_id = 39
		 AND a.ar_inumber = b.number AND a.ar_subtotal = 'F';

-- 明细是否和汇总一致检查
SELECT * FROM (SELECT number, SUM(charge+charge0 -charge9)-SUM(pay+pay0-pay9) AS balance1 FROM ar_account WHERE hotel_group_id = 12 AND hotel_id = 39 AND accnt = 1090 GROUP BY number) a,
(SELECT ar_inumber, SUM(charge-charge9)-SUM(pay-credit9) AS balance2 FROM ar_detail WHERE hotel_group_id = 12 AND hotel_id = 39 AND ar_accnt = 1090 AND ar_subtotal = 'F' GROUP BY ar_inumber) b
WHERE a.number = b.ar_inumber AND a.balance1 <> b.balance2;

SELECT * FROM ar_account WHERE hotel_group_id = 12 AND hotel_id = 39 AND accnt = 1090 AND number = 304;
 
SELECT * FROM ar_detail WHERE hotel_group_id = 12 AND hotel_id = 39 AND ar_accnt = 1090  AND ar_inumber = 304;

SELECT -10000.00*3-3000.00-30000.00-65348.00-3000.00;
SELECT -13000-13000-75348-30000;

DROP TABLE tmp_detail_vs_account;
CREATE TABLE tmp_detail_vs_account(
	biz_date	DATETIME,
	number		BIGINT,
	balance		DECIMAL(12,2) NOT NULL DEFAULT 0,
	number1		BIGINT,
	balance1	DECIMAL(12,2) NOT NULL DEFAULT 0			
);

INSERT INTO  tmp_detail_vs_account(biz_date,number,balance)
SELECT biz_date,number, SUM(charge+charge0 -charge9)-SUM(pay+pay0-pay9) AS balance1 FROM ar_account WHERE hotel_group_id = 12 AND hotel_id = 39 AND accnt = 1090 GROUP BY number;

SELECT * FROM tmp_detail_vs_account;



SELECT SUM(a.charge+ a.charge9)-SUM(a.pay-a.credit9)  FROM ar_detail a,ar_account c 
WHERE a.hotel_group_id = 12  AND a.hotel_id = 39 AND c.hotel_group_id = 12  AND c.hotel_id = 39
AND c.accnt = a.ar_accnt  AND c.number = a.ar_inumber AND c.accnt = 1090 
AND a.ar_subtotal = 'F' AND c.audit_tag = '1';

UPDATE tmp_detail_vs_account a,
(SELECT ar_inumber,SUM(a.charge- a.charge9)-SUM(a.pay-a.credit9) balance FROM ar_detail a 
WHERE a.hotel_group_id = 12  AND a.hotel_id = 39 
AND a.ar_accnt = 1090 AND a.ar_subtotal = 'F'  GROUP BY a.ar_inumber) b SET a.number1 = b.ar_inumber,a.balance1 = b.balance 
WHERE a.number = b.ar_inumber;

SELECT * FROM tmp_detail_vs_account WHERE balance <> balance1;

SELECT * FROM  ar_detail a WHERE a.hotel_group_id = 12  AND a.hotel_id = 39  AND a.ar_accnt = 1090
AND a.ar_inumber = 1;


SELECT * FROM ar_account WHERE hotel_group_id = 12 AND hotel_id = 39 AND accnt = 1090
AND biz_date <= '2015.9.30' AND number = 1505;
SELECT * FROM ar_detail WHERE hotel_group_id = 12 AND hotel_id = 39 AND ar_accnt = 1090
AND ar_inumber = 1505;

SELECT * FROM ar_account WHERE hotel_group_id = 12 AND hotel_id = 39 AND accnt = 1090
AND biz_date = '2015.9.16'  ;

SELECT * FROM ar_detail WHERE hotel_group_id = 12 AND hotel_id = 39 AND ar_accnt = 1090
AND ar_inumber = 1508;


-- 若没有导入过数据,可使用老郭的过程来修复(修复前审核掉前一日之前的所有AR账);若导入过数据,就只有手工修复
CALL up_ihotel_master_snapshot_check(2,9);
CALL up_ihotel_master_snapshot_maint(2,9,'armaster',1352,@w,@q);

-- 使用AR上日余额与底表AR余额来判断哪个表数据是正确的
SELECT till_bl AS amount FROM rep_dai WHERE hotel_group_id=2 AND hotel_id=9 AND classno='03000'
UNION ALL
SELECT SUM(charge-pay) AS amount FROM ar_master_till WHERE hotel_group_id=2 AND hotel_id=9;

-- AR余额发生和收回判断
SELECT DATE(a.biz_date) biz_date,
       IFNULL(SUM(a.debit),0) rep_dai_debit,
       IFNULL(SUM(a.credit),0) rep_dai_credit,

       (SELECT IFNULL(SUM(b.charge_ttl),0) FROM master_snapshot b WHERE b.hotel_group_id=2 AND b.hotel_id=9 AND b.biz_date_begin = a.biz_date - INTERVAL 1 DAY AND b.master_type='armaster') AS snapshot_charge,

       (SELECT IFNULL(SUM(b.pay_ttl),0) FROM master_snapshot b WHERE b.hotel_group_id=2 AND b.hotel_id=9 AND b.biz_date_begin = a.biz_date - INTERVAL 1 DAY AND b.master_type='armaster') AS snapshot_pay,

       IFNULL(SUM(a.debit),0) - 
       (SELECT IFNULL(SUM(b.charge_ttl),0) FROM master_snapshot b WHERE b.hotel_group_id=2 AND b.hotel_id=9 AND b.biz_date_begin = a.biz_date - INTERVAL 1 DAY AND b.master_type='armaster')
       AS diff_debit_charge,

       IFNULL(SUM(a.credit),0) - 
       (SELECT IFNULL(SUM(b.pay_ttl),0) FROM master_snapshot b WHERE b.hotel_group_id=2 AND b.hotel_id=9 AND b.biz_date_begin = a.biz_date - INTERVAL 1 DAY AND b.master_type='armaster')
       AS diff_credit_pay

       FROM rep_dai_history a
       WHERE a.hotel_group_id=2 AND a.hotel_id=9 AND a.classno='03000'
       GROUP BY a.biz_date
       HAVING diff_debit_charge <> 0 OR diff_credit_pay <> 0
       ORDER BY a.biz_date;


	
	-- 从 account pos_dish ar_detail中插入，用于判断哪些数据有出入
	DROP TABLE ar_snapshot_reb;

	TRUNCATE TABLE master_snapshot_account;

	INSERT INTO master_snapshot_account
	SELECT 2,19,biz_date,trans_accnt,pay,charge,0 FROM account WHERE hotel_group_id=2 AND hotel_id=19 AND trans_accnt=15176
	UNION ALL
	SELECT 2,19,biz_date,trans_accnt,pay,charge,0 FROM account_history WHERE hotel_group_id=2 AND hotel_id=19 AND trans_accnt=15176;

	-- INSERT INTO master_snapshot_account
	-- SELECT 2,19,biz_date,accnt,fee,0,0 FROM pos_dish WHERE hotel_group_id=2 AND hotel_id=19 AND CODE='9800' AND accnt=15176 AND biz_date='2012-8-6';

	INSERT INTO master_snapshot_account
	SELECT 2,19,biz_date,ar_accnt,charge,pay,0 FROM ar_detail WHERE hotel_group_id=2 AND hotel_id=19 AND ar_tag='P' AND modu_code='04' AND ar_subtotal='F' AND ar_accnt=15176;

	INSERT INTO master_snapshot_account
	SELECT 2,19,biz_date,ar_accnt,charge,pay,0 FROM ar_detail WHERE hotel_group_id=2 AND hotel_id=19 AND ar_tag='A' AND modu_code='02' AND ar_subtotal='F' AND ar_accnt=15176;

	SELECT a.biz_date_end,a.charge_ttl,a.pay_ttl, 
	(SELECT IFNULL(SUM(b.charge),0) FROM master_snapshot_account b WHERE b.hotel_group_id=2 AND b.hotel_id=19 AND b.biz_date=a.biz_date_end AND b.accnt=15176) AS charge,
	(SELECT IFNULL(SUM(c.pay),0) FROM master_snapshot_account c WHERE c.hotel_group_id=2 AND c.hotel_id=19 AND c.biz_date=a.biz_date_end AND c.accnt=15176) AS pay,
	(a.charge_ttl
	-
	(SELECT IFNULL(SUM(b.charge),0) FROM master_snapshot_account b WHERE b.hotel_group_id=2 AND b.hotel_id=19 AND b.biz_date=a.biz_date_end AND b.accnt=15176)) AS charge_diff,
	(a.pay_ttl
	-
	(SELECT IFNULL(SUM(c.pay),0) FROM master_snapshot_account c WHERE c.hotel_group_id=2 AND c.hotel_id=19 AND c.biz_date=a.biz_date_end AND c.accnt=15176)) AS pay_diff
	FROM master_snapshot a 
	WHERE a.hotel_group_id=2 AND a.hotel_id=19 AND a.master_id=15176
	GROUP BY a.biz_date_end
	HAVING charge_diff<>0 OR pay_diff <>0
	ORDER BY a.biz_date_end;	
	
   
-- 宾客余额发生和收回判断	   
SELECT DATE(a.biz_date) biz_date,
       IFNULL(SUM(a.debit),0) rep_dai_debit,
       IFNULL(SUM(a.credit),0) rep_dai_credit,

       (SELECT IFNULL(SUM(b.charge_ttl),0) FROM master_snapshot b WHERE b.hotel_group_id=2 AND b.hotel_id=9 AND b.biz_date_begin = a.biz_date - INTERVAL 1 DAY AND b.master_type<>'armaster') AS snapshot_charge,

       (SELECT IFNULL(SUM(b.pay_ttl),0) FROM master_snapshot b WHERE b.hotel_group_id=2 AND b.hotel_id=9 AND b.biz_date_begin = a.biz_date - INTERVAL 1 DAY AND b.master_type<>'armaster') AS snapshot_pay,

       IFNULL(SUM(a.debit),0) - 
       (SELECT IFNULL(SUM(b.charge_ttl),0) FROM master_snapshot b WHERE b.hotel_group_id=2 AND b.hotel_id=9 AND b.biz_date_begin = a.biz_date - INTERVAL 1 DAY AND b.master_type<>'armaster')
       AS diff_debit_charge,

       IFNULL(SUM(a.credit),0) - 
       (SELECT IFNULL(SUM(b.pay_ttl),0) FROM master_snapshot b WHERE b.hotel_group_id=2 AND b.hotel_id=9 AND b.biz_date_begin = a.biz_date - INTERVAL 1 DAY AND b.master_type<>'armaster')
       AS diff_credit_pay

       FROM rep_dai_history a
       WHERE a.hotel_group_id=2 AND a.hotel_id=9 AND a.classno='02000'
       GROUP BY a.biz_date
       HAVING diff_debit_charge <> 0 OR diff_credit_pay <> 0
       ORDER BY a.biz_date;
	   
 
             	   
             
