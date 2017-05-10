-- 此方法有可能无法保证历史每一天余额与底表都能对上，但主要用于保证后续余额或近阶段时间正确
-- AR修复：1. 底表和余额表数据一致	2.余额表与账龄表一致，账龄表修改一般针对ar_detail

-- =========================================================================
-- 第1步:上日底表AR数据与上日AR主单实际余额对比
--       若两者数据不一致,以AR主单实际余额为准对底表进行修复
-- =========================================================================
SELECT till_bl AS amount FROM rep_dai WHERE hotel_group_id=2 AND hotel_id=18 AND classno='03000'
UNION ALL
SELECT SUM(charge-pay) AS amount FROM ar_master_till WHERE hotel_group_id=2 AND hotel_id=18;

-- AR余额
-- 上日
UPDATE rep_dai SET last_bl=last_bl+2372,till_bl=till_bl+2372,last_blm=last_blm+2372,till_blm=till_blm+2372 
	WHERE hotel_group_id=2 AND hotel_id=18 AND biz_date='2015-12-22' AND classno='03000';
UPDATE rep_dai_history SET last_bl=last_bl+2372,till_bl=till_bl+2372,last_blm=last_blm+2372,till_blm=till_blm+2372 
	WHERE hotel_group_id=2 AND hotel_id=18 AND biz_date='2015-12-22' AND classno='03000';

UPDATE rep_jiedai SET last_charge=last_charge+2372,till_charge=till_charge+2372,last_chargem=last_chargem+2372,till_chargem=till_chargem+2372
	WHERE hotel_group_id=2 AND hotel_id=18 AND biz_date='2015-12-22' AND classno='03A';
UPDATE rep_jiedai_history SET last_charge=last_charge+2372,till_charge=till_charge+2372,last_chargem=last_chargem+2372,till_chargem=till_chargem+2372
	WHERE hotel_group_id=2 AND hotel_id=18 AND biz_date='2015-12-22' AND classno='03A';	

-- 上日以前
UPDATE rep_dai_history SET last_bl=last_bl+2372,till_bl=till_bl+2372,last_blm=last_blm+2372,till_blm=till_blm+2372 
	WHERE hotel_group_id=2 AND hotel_id=18 AND classno='03000' AND biz_date<'2015-12-22' AND biz_date>='2015-1-1';

UPDATE rep_jiedai_history SET last_charge=last_charge+2372,till_charge=till_charge+2372,last_chargem=last_chargem+2372,till_chargem=till_chargem+2372
	WHERE hotel_group_id=2 AND hotel_id=18 AND classno='03A' AND biz_date<'2015-12-22' AND biz_date>='2015-1-1';


-- 宾客余额
-- 上日
UPDATE rep_dai SET last_bl=last_bl+2372,till_bl=till_bl+2372,last_blm=last_blm+2372,till_blm=till_blm+2372 
	WHERE hotel_group_id=1 AND hotel_id=104 AND biz_date='2016-6-2' AND classno='02000';
UPDATE rep_dai_history SET last_bl=last_bl+2372,till_bl=till_bl+2372,last_blm=last_blm+2372,till_blm=till_blm+2372 
	WHERE hotel_group_id=1 AND hotel_id=104 AND biz_date='2016-6-2' AND classno='02000';

UPDATE rep_jiedai SET last_charge=last_charge+2372,till_charge=till_charge+2372,last_chargem=last_chargem+2372,till_chargem=till_chargem+2372
	WHERE hotel_group_id=1 AND hotel_id=104 AND biz_date='2016-6-2' AND classno='02F';
UPDATE rep_jiedai_history SET last_charge=last_charge+2372,till_charge=till_charge+2372,last_chargem=last_chargem+2372,till_chargem=till_chargem+2372
	WHERE hotel_group_id=1 AND hotel_id=104 AND biz_date='2016-6-2' AND classno='02F';	

-- 上日以前
UPDATE rep_dai_history SET last_bl=last_bl+2372,till_bl=till_bl+2372,last_blm=last_blm+2372,till_blm=till_blm+2372 
	WHERE hotel_group_id=1 AND hotel_id=104 AND classno='02000' AND biz_date<'2016-6-2' AND biz_date>='2016-5-10';

UPDATE rep_jiedai_history SET last_charge=last_charge+2372,till_charge=till_charge+2372,last_chargem=last_chargem+2372,till_chargem=till_chargem+2372
	WHERE hotel_group_id=1 AND hotel_id=104 AND classno='02F' AND biz_date<'2016-6-2' AND biz_date>='2016-5-10';
	

-- ======================================================================================
-- 第2步:根据AR主单上实际余额与快照表上日对照，得出AR中具体哪些账户数据不一致
--       根据 up_ihotel_dai_snapshot 过程 得出余额表与底表从哪天开始数据不一致
--       对 ar_snapshot_reb 差额SUM 与 up_ihotel_dai_snapshot 结果对比,判断从哪天开始修复
--       修复使用 up_ihotel_reb_snapshot_armaster 过程,倒数第二个参数值为 till 值
-- =====================================================================================
	   
	CREATE TABLE ar_snapshot_reb(
		biz_date	 DATETIME 		DEFAULT NULL,
		snap_accnt   BIGINT(20) 	DEFAULT NULL,
		arname	     VARCHAR(100) 	DEFAULT NULL,
		snap_bal 	 DECIMAL(12,2) 	NOT NULL DEFAULT '0.00',
		ar_accnt 	 BIGINT(20) 	DEFAULT NULL,
		ar_bal 	     DECIMAL(12,2) 	NOT NULL DEFAULT '0.00',
		till_bl 	 DECIMAL(12,2) 	NOT NULL DEFAULT '0.00',
		KEY index1(snap_accnt),
		KEY index2(biz_date)
	); 
	
	-- DELETE FROM ar_snapshot_reb WHERE biz_date='2015-12-22';
	TRUNCATE TABLE ar_snapshot_reb;
	
	INSERT INTO ar_snapshot_reb(biz_date,snap_accnt,arname,snap_bal)
	SELECT '2015-12-22',a.master_id,a.name,a.till_balance 
	FROM master_snapshot a WHERE a.hotel_group_id = 2 AND a.hotel_id = 18 AND a.master_type = 'armaster'
	AND (a.last_balance<>0 OR a.till_balance<>0 OR a.charge_ttl<>0 OR a.pay_ttl<>0)
	AND a.biz_date_begin < '2015-12-22' AND a.biz_date_end >= '2015-12-22'
	ORDER BY a.master_id;

	UPDATE ar_snapshot_reb a,(SELECT id,SUM(charge - pay) balance FROM ar_master_till 
		WHERE hotel_group_id = 2 AND hotel_id = 18 GROUP BY id) b 
		SET a.ar_accnt = b.id,a.ar_bal = b.balance WHERE a.snap_accnt = b.id AND a.biz_date='2015-12-22';

	SELECT snap_accnt,arname,(snap_bal - ar_bal) AS till FROM ar_snapshot_reb WHERE snap_bal - ar_bal <> 0 AND biz_date='2015-12-22';

	DROP TABLE ar_snapshot_reb;
	


	
	
