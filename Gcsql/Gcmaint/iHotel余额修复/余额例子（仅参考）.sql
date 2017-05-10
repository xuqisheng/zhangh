处理思路如下:[事先要确认底表和余额表哪一个是正确的]
	1. 何老师的脚本检查出哪些账号有问题,使用老郭的过程修复
	2. 检查出哪天有哪里,将余额表上日和出错日插入临时表,利用上日的本日余额和出错日的本日余额对比出哪些账号有问题,然后老郭过程修复
	3. 出错日的charge和pay与实际的账务表对比出哪些账户有问题，再使用老郭的过程修复

SELECT * FROM master_snapshot WHERE hotel_group_id=1 AND hotel_id=14 
AND biz_date_begin < '2015-3-3' AND biz_date_end >= '2015-3-3' AND master_type<>'armaster'

SELECT * FROM master_snapshot WHERE hotel_group_id=1 AND hotel_id=14 AND master_id=1777091

DELETE FROM master_snapshot_tmp

INSERT INTO master_snapshot_tmp(hotel_group_id,hotel_id,biz_date,master_type,master_id,NAME,last_balance,charge_ttl,pay_ttl,till_balance)
SELECT hotel_group_id,hotel_id,'2015-3-2',master_type,master_id,NAME,last_balance,charge_ttl,pay_ttl,till_balance
FROM master_snapshot WHERE hotel_group_id=1 AND hotel_id=14 
AND biz_date_begin < '2015-3-2' AND biz_date_end >= '2015-3-2' AND master_type<>'armaster'
UNION ALL
SELECT hotel_group_id,hotel_id,'2015-3-3',master_type,master_id,NAME,last_balance,charge_ttl,pay_ttl,till_balance
FROM master_snapshot WHERE hotel_group_id=1 AND hotel_id=14 
AND biz_date_begin < '2015-3-3' AND biz_date_end >= '2015-3-3' AND master_type<>'armaster'

SELECT *
FROM master_snapshot_tmp a,master_snapshot_tmp b
WHERE a.hotel_group_id=1 AND a.hotel_id=14 AND a.master_type<>'armaster' AND a.biz_date='2015-3-2'
AND b.hotel_group_id=1 AND b.hotel_id=14 AND b.master_type<>'armaster' AND b.biz_date='2015-3-3'
AND a.master_id=b.master_id AND a.till_balance<>b.last_balance

SELECT * 
FROM master_snapshot_tmp a WHERE  a.hotel_group_id=1 AND a.hotel_id=14 AND a.master_type<>'armaster' AND a.biz_date='2015-3-2'
AND NOT EXISTS(SELECT 1 FROM master_snapshot_tmp b WHERE b.hotel_group_id=1 AND b.hotel_id=14 AND b.master_type<>'armaster' AND b.biz_date='2015-3-3'
AND a.master_id=b.master_id) AND a.till_balance<>0

-- 实际
DELETE FROM master_snapshot_account

INSERT INTO master_snapshot_account(hotel_group_id,hotel_id,biz_date,accnt,charge,pay,balance)
SELECT 1,16,'2015-4-14',b.accnt,SUM(b.charge),SUM(b.pay),SUM(b.charge-b.pay) FROM 
(SELECT * FROM account WHERE hotel_group_id=1 AND hotel_id=16 AND biz_date='2015-4-14' 
UNION ALL
SELECT * FROM account_history WHERE hotel_group_id=1 AND hotel_id=16 AND biz_date='2015-4-14') AS b
GROUP BY accnt

SELECT a.master_id,a.charge_ttl,b.charge
FROM master_snapshot_tmp a,master_snapshot_account b
WHERE a.hotel_group_id=1 AND a.hotel_id=14 AND a.master_type<>'armaster' AND a.biz_date='2015-3-3'
AND b.hotel_group_id=1 AND b.hotel_id=14 AND b.biz_date='2015-3-3'
AND a.master_id=b.accnt AND a.charge_ttl<>b.charge

SELECT COUNT(1)
FROM master_snapshot_tmp a,master_snapshot_account b
WHERE a.hotel_group_id=1 AND a.hotel_id=14 AND a.master_type<>'armaster' AND a.biz_date='2015-3-3'
AND b.hotel_group_id=1 AND b.hotel_id=14 AND b.biz_date='2015-3-3'
AND a.master_id=b.accnt AND a.charge_ttl<>b.charge


SELECT a.accnt 
FROM master_snapshot_account a WHERE a.hotel_group_id=1 AND a.hotel_id=14 AND a.biz_date='2015-3-3'
AND NOT EXISTS(SELECT 1 FROM master_snapshot_tmp b WHERE b.hotel_group_id=1 AND b.hotel_id=14 AND b.master_type<>'armaster' AND b.biz_date='2015-3-3'
AND a.accnt=b.master_id)


SELECT * FROM master_snapshot_tmp WHERE hotel_group_id=1 AND hotel_id=14 AND biz_date='2015-3-2' AND till_balance<>0
GROUP BY biz_date

CALL up_ihotel_master_snapshot_check(1,14)

CALL up_ihotel_master_snapshot_maint(1,14,'master',1777091,@a,@t);


INSERT INTO master_snapshot_account(hotel_group_id,hotel_id,biz_date,accnt,charge,pay,balance)

SELECT 1,14,'2015-3-3',b.accnt,SUM(b.charge),SUM(b.pay),SUM(b.charge-b.pay) FROM 
(SELECT * FROM account WHERE hotel_group_id=1 AND hotel_id=14 AND biz_date='2015-3-3' 
UNION ALL
SELECT * FROM account_history WHERE hotel_group_id=1 AND hotel_id=14 AND biz_date='2015-3-3') AS b
GROUP BY accnt

-- 出错账号插入
INSERT INTO master_snapshot_accnt
SELECT DISTINCT a.hotel_group_id,a.hotel_id,a.master_type,a.master_id
       FROM master_snapshot a
       WHERE a.hotel_group_id=1 AND a.hotel_id=23
             AND
             (
             EXISTS (SELECT 1 FROM master_snapshot b
                              WHERE 
                                   a.hotel_group_id=1 AND a.hotel_id=23 AND b.hotel_group_id=1 AND b.hotel_id=23 AND
                                   b.master_type=a.master_type AND 
                                   b.master_id=a.master_id AND 
                                   b.id <> a.id AND 
                                   b.biz_date_begin > a.biz_date_end
                    )
             AND 
             NOT EXISTS (SELECT 1 FROM master_snapshot b
                                  WHERE 
                                       a.hotel_group_id=1 AND a.hotel_id=23 AND b.hotel_group_id=1 AND b.hotel_id=23 AND
                                       b.master_type=a.master_type AND 
                                       b.master_id=a.master_id AND 
                                       b.id <> a.id AND 
                                       b.biz_date_begin = a.biz_date_end
                        )
             OR
             EXISTS (SELECT 1 FROM master_snapshot b
                              WHERE 
                                   a.hotel_group_id=1 AND a.hotel_id=23 AND b.hotel_group_id=1 AND b.hotel_id=23 AND
                                   b.master_type=a.master_type AND 
                                   b.master_id=a.master_id AND 
                                   b.id <> a.id AND 
                                   b.biz_date_end < a.biz_date_begin
                    )
             AND 
             NOT EXISTS (SELECT 1 FROM master_snapshot b
                                  WHERE 
                                       a.hotel_group_id=1 AND a.hotel_id=23 AND b.hotel_group_id=1 AND b.hotel_id=23 AND
                                       b.master_type=a.master_type AND 
                                       b.master_id=a.master_id AND 
                                       b.id <> a.id AND 
                                       b.biz_date_end = a.biz_date_begin
                        )
             )
       ORDER BY a.hotel_group_id,a.hotel_id,a.master_type,a.master_id,a.biz_date_begin,a.biz_date_end;
	   
	   
-- 底表贷方出错修复
SELECT * FROM rep_dai_history WHERE hotel_group_id=1 AND hotel_id=2 AND biz_date='2015-12-22'
SELECT * FROM rep_jiedai_history WHERE hotel_group_id=1 AND hotel_id=2 AND biz_date='2015-12-22'

-- 某一天[日]
UPDATE rep_dai_history SET credit01=credit01+151,sumcre=sumcre+151,credit01m=credit01m+151,sumcrem=sumcrem+151 WHERE hotel_group_id=1 AND hotel_id=2 AND biz_date='2015-12-22' AND classno='01010';
UPDATE rep_dai_history SET credit01=credit01+151,sumcre=sumcre+151,credit01m=credit01m+151,sumcrem=sumcrem+151 WHERE hotel_group_id=1 AND hotel_id=2 AND biz_date='2015-12-22' AND classno='01020';
UPDATE rep_dai_history SET credit=credit+151,till_bl=till_bl-151,sumcre=sumcre-151,creditm=creditm+151,till_blm=till_blm-151,sumcrem=sumcrem-151 WHERE hotel_group_id=1 AND hotel_id=2 AND biz_date='2015-12-22' AND classno='02000';

UPDATE rep_jiedai_history SET credit=credit+151,till_credit=till_credit+151,creditm=creditm+151,till_creditm=till_creditm+151 WHERE hotel_group_id=1 AND hotel_id=2 AND biz_date='2015-12-22' AND classno='02F';

SELECT * FROM rep_dai_history WHERE hotel_group_id=1 AND hotel_id=2 AND biz_date='2013-4-2'
SELECT * FROM rep_jiedai_history WHERE hotel_group_id=1 AND hotel_id=2 AND biz_date='2013-4-2'

-- 后续天
UPDATE rep_dai_history SET last_bl=last_bl-151,till_bl=till_bl-151,last_blm=last_blm-151,till_blm=till_blm-151 
	WHERE hotel_group_id=1 AND hotel_id=2 AND biz_date>'2015-12-22' AND classno='02000';
UPDATE rep_jiedai_history SET last_credit=last_credit+151,till_credit=till_credit+151,last_creditm=last_creditm+151,till_creditm=till_creditm+151 
	WHERE hotel_group_id=1 AND hotel_id=2 AND biz_date>'2015-12-22' AND classno='02F';
	
UPDATE rep_dai SET last_bl=last_bl-151,till_bl=till_bl-151,last_blm=last_blm-151,till_blm=till_blm-151 
	WHERE hotel_group_id=1 AND hotel_id=2 AND biz_date>'2015-12-22' AND classno='02000';
UPDATE rep_jiedai SET last_credit=last_credit+151,till_credit=till_credit+151,last_creditm=last_creditm+151,till_creditm=till_creditm+151 
	WHERE hotel_group_id=1 AND hotel_id=2 AND biz_date>'2015-12-22' AND classno='02F';



-- 岷山饭店[调整底表宾客和团队余额与余额表一致]
UPDATE rep_jiedai_history SET last_charge=last_charge-92275.05,till_charge=till_charge-92275.05,
last_chargem=last_chargem-92275.05,till_chargem=till_chargem-92275.05 
WHERE hotel_group_id=1 AND hotel_id=101 AND biz_date>='2015-1-1' AND classno='02F';

UPDATE rep_jiedai_history SET last_charge=last_charge+92275.05,till_charge=till_charge+92275.05,
last_chargem=last_chargem+92275.05,till_chargem=till_chargem+92275.05
WHERE hotel_group_id=1 AND hotel_id=101 AND biz_date>='2015-1-1' AND classno='02G';

UPDATE rep_jiedai SET last_charge=last_charge-92275.05,till_charge=till_charge-92275.05,
last_chargem=last_chargem-92275.05,till_chargem=till_chargem-92275.05 
WHERE hotel_group_id=1 AND hotel_id=101 AND biz_date>='2015-1-1' AND classno='02F';

UPDATE rep_jiedai SET last_charge=last_charge+92275.05,till_charge=till_charge+92275.05,
last_chargem=last_chargem+92275.05,till_chargem=till_chargem+92275.05
WHERE hotel_group_id=1 AND hotel_id=101 AND biz_date>='2015-1-1' AND classno='02G';	


