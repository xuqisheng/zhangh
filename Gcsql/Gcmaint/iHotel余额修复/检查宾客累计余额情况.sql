

-- 此方法有可能无法保证历史每一天余额与底表都能对上，但主要用于保证后续余额或近阶段时间正确
-- 

-- =========================================================================
-- 第1步:上日底表宾客余额数据与上日前台主单实际余额对比
--       若两者数据不一致,以AR主单实际余额为准对底表进行修复
-- =========================================================================
SELECT till_bl AS amount FROM rep_dai WHERE hotel_group_id=2 AND hotel_id=18 AND classno='02000'
UNION ALL
SELECT SUM(charge-pay) AS amount FROM master_base_till WHERE hotel_group_id=2 AND hotel_id=18;

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



















select date(a.biz_date) biz_date,
       ifnull(sum(a.last_bl),0) rep_dai_last_bl,
       ifnull(sum(a.till_bl),0) rep_dai_till_bl,

       (select ifnull(sum(b.last_balance),0) from master_snapshot b where b.hotel_group_id=1 and b.hotel_id=2 and b.biz_date_begin=a.biz_date - interval 1 day AND b.master_type<>'armaster' ) + 
       (select ifnull(sum(b.last_balance),0) from master_snapshot b where b.hotel_group_id=1 and b.hotel_id=2  and b.plen>1 and b.biz_date_end>=a.biz_date and b.biz_date_begin<a.biz_date - interval 1 day AND b.master_type<>'armaster')
       as snapshot_last_bl,

       (select ifnull(sum(b.till_balance),0) from master_snapshot b where b.hotel_group_id=1 and b.hotel_id=2 and b.plen=1 and b.biz_date_end = a.biz_date AND b.master_type<>'armaster')
       +
       (select ifnull(sum(b.till_balance),0) from master_snapshot b where b.hotel_group_id=1 and b.hotel_id=2  and b.plen>1 and b.biz_date_begin < a.biz_date and b.biz_date_end >=a.biz_date AND b.master_type<>'armaster')
       as snapshot_till_bl,

       ifnull(sum(a.last_bl),0) 
       - 
       (select ifnull(sum(b.last_balance),0) from master_snapshot b where b.hotel_group_id=1 and b.hotel_id=2 and b.biz_date_begin=a.biz_date - interval 1 day AND b.master_type<>'armaster') 
       - 
       (select ifnull(sum(b.last_balance),0) from master_snapshot b where b.hotel_group_id=1 and b.hotel_id=2  and b.plen>1 and b.biz_date_end>=a.biz_date and b.biz_date_begin<a.biz_date - interval 1 day AND b.master_type<>'armaster')
       as diff_last_bl,

       ifnull(sum(a.till_bl),0) 
       - 
       (select ifnull(sum(b.till_balance),0) from master_snapshot b where b.hotel_group_id=1 and b.hotel_id=2 and b.plen=1 and b.biz_date_end = a.biz_date AND b.master_type<>'armaster')
       -
       (select ifnull(sum(b.till_balance),0) from master_snapshot b where b.hotel_group_id=1 and b.hotel_id=2 and b.plen>1 and b.biz_date_begin < a.biz_date and b.biz_date_end >=a.biz_date AND b.master_type<>'armaster')
       as diff_till_bl

       from rep_dai_history a
       where a.hotel_group_id=1 and a.hotel_id=2 and a.classno='02000'
       group by a.biz_date
       having diff_last_bl <> 0 or diff_till_bl <> 0
       order by a.biz_date
             