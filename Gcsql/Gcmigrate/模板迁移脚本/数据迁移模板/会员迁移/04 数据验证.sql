SELECT a.descript,count_value ,point_pay,point_charge,point_balance  ,pay,charge,balance
FROM (
	SELECT cl.code,cl.descript,COUNT(1) count_value
	FROM card_base cb
	LEFT JOIN card_level cl ON cb.hotel_group_id=cl.hotel_group_id AND cb.card_level=cl.code
	WHERE cb.hotel_group_id=2  AND cb.hotel_id = 9 AND cb.create_datetime < ADDDATE(DATE('2013-12-29'),INTERVAL 1 DAY)
	GROUP BY cb.card_level
	ORDER BY cl.list_order,cl.code
)a LEFT JOIN (
	SELECT cl.code,cl.descript,SUM(cp.produce) point_pay,SUM(cp.apply) point_charge, 
		SUM(cp.produce-cp.apply) point_balance,SUM(cb.point_pay- cb.point_charge) point_balance2
	FROM card_base cb,card_point cp,card_level  cl
	WHERE cb.hotel_group_id=2  AND cb.hotel_id = 9 AND cp.biz_date <= '2013-12-29'
	AND cp.card_no = cb.id AND cb.hotel_group_id = cl.hotel_group_id AND cb.card_level = cl.code
	GROUP BY cb.card_level
	ORDER BY cl.list_order,cl.code
)b ON a.code = b.code
LEFT JOIN (
	SELECT cl.code,cl.descript,SUM(ca.pay) pay,SUM(ca.charge) charge,SUM(ca.pay-ca.charge) balance,SUM(cb.pay-cb.charge) balance2
	FROM card_account ca,card_base cb,card_level cl
	WHERE cb.hotel_group_id=2  AND cb.hotel_id = 9 AND ca.biz_date <= '2013-12-29'
	AND ca.card_id = cb.id AND cb.hotel_group_id = cl.hotel_group_id AND cb.card_level = cl.code
	GROUP BY cb.card_level
	ORDER BY cl.list_order,cl.code
) c ON a.code = c.code


-- 更新guest的会员卡关联
	SELECT mb.guest_id,cb.card_type,cb.card_level,cb.card_no,gt.membership_type,gt.membership_level,gt.membership_no
 	FROM card_base cb,member_base mb,guest_type gt
 	WHERE cb.hotel_group_id = mb.hotel_group_id AND cb.member_id = mb.id AND  mb.guest_id IS NOT NULL 
 	AND cb.hotel_group_id = gt.hotel_group_id AND cb.hotel_id = gt.hotel_id AND mb.guest_id = gt.guest_id
 	GROUP BY mb.guest_id
 	
,		
 		,gt.membership_type,gt.membership_level,gt.membership_no
 	AND cb.hotel_group_id = gt.hotel_group_id AND cb.hotel_id = gt.hotel_id AND mb.guest_id = gt.guest_id
 	
 	SELECT  a.*,gt.membership_type,gt.membership_level,gt.membership_no
 	FROM (	
	SELECT cb.hotel_group_id,cb.hotel_id,mb.guest_id,cb.card_type,cb.card_level,cb.card_no
 	FROM card_base cb,member_base mb
 	WHERE cb.hotel_group_id = mb.hotel_group_id AND cb.member_id = mb.id AND  mb.guest_id IS NOT NULL 
 	GROUP BY mb.guest_id 
 	) a,guest_type gt 
 	WHERE a.hotel_group_id = gt.hotel_group_id AND a.hotel_id = gt.hotel_id AND a.guest_id = gt.guest_id;
 		
 	
 	UPDATE (	
	SELECT cb.hotel_group_id,cb.hotel_id,mb.guest_id,cb.card_type,cb.card_level,cb.card_no
 	FROM card_base cb,member_base mb
 	WHERE cb.hotel_group_id = mb.hotel_group_id AND cb.member_id = mb.id AND  mb.guest_id IS NOT NULL 
 	GROUP BY mb.guest_id 
 	) a,guest_type gt 
 	SET  gt.membership_type = a.card_type,gt.membership_level= a.card_level,gt.membership_no = a.card_no
 	WHERE a.hotel_group_id = gt.hotel_group_id AND a.hotel_id = gt.hotel_id AND a.guest_id = gt.guest_id;

-- 更新master_base 上的member_no,card_id
-- 没有导过来的卡,手工清除
-- SELECT * FROM migrate_db.vipcard WHERE NO IN (
SELECT a.id,member_no
FROM master_base a LEFT JOIN card_base b ON a.member_no = b.card_no
WHERE a.hotel_group_id = 2 AND a.member_no <> '' AND b.id IS  NULL 
-- )
-- 更新已经导过来的卡
SELECT a.member_no,b.card_no,a.inner_card_id,b.id
FROM master_base a LEFT JOIN card_base b ON a.member_no = b.card_no
WHERE a.hotel_group_id = 2 AND a.member_no <> '' AND b.id IS NOT NULL 

UPDATE master_base a LEFT JOIN card_base b ON a.member_no = b.card_no
SET  a.inner_card_id = b.id
WHERE a.hotel_group_id = 2 AND a.member_no <> '' AND b.id IS NOT NULL 

-- 插card_snapshot
INSERT INTO card_snapshot(hotel_group_id,hotel_id,biz_date,hotel_descript,hotel_descript_en,
			account_pa,account_pp,account_ch,account_lf,account_lt,account_ad,account_cl,
			account_rt,last_balance,pay,charge,balance,tax_bill,
			point_pa,point_pp,point_ch,point_lf,point_lt,point_ad,point_cl,
			last_point_balance,point_pay,point_charge,point_balance
			) 
		SELECT  a.hotel_group_id,a.id,var_bdate,a.descript,a.descript_en,
		0,0,0,0,0,0,0,
		0,IFNULL(c.balance,0),0,0,IFNULL(c.balance,0),0,
		0,0,0,0,0,0,0,
		IFNULL(c.point_balance,0),0,0,IFNULL(c.point_balance,0)
		FROM hotel a LEFT JOIN card_snapshot b ON a.hotel_group_id = b.hotel_group_id AND a.id = b.hotel_id AND b.biz_date =  var_bdate
		LEFT JOIN card_snapshot c ON a.hotel_group_id = c.hotel_group_id AND a.id = c.hotel_id AND c.biz_date = ADDDATE(var_bdate, -1)
		WHERE b.id IS NULL;	