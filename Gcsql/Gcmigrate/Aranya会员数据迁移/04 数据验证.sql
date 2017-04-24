SELECT a.descript,count_value ,point_pay,point_charge,point_balance  ,pay,charge,balance
FROM (
	SELECT cl.code,cl.descript,COUNT(1) count_value
	FROM card_base cb
	LEFT JOIN card_level cl ON cb.hotel_group_id=cl.hotel_group_id AND cb.card_level=cl.code
	WHERE cb.hotel_group_id=2  AND cb.hotel_id = 9 AND cb.create_datetime < ADDDATE(DATE('2013-12-26'),INTERVAL 1 DAY)
	GROUP BY cb.card_level
	ORDER BY cl.list_order,cl.code
)a LEFT JOIN (
	SELECT cl.code,cl.descript,SUM(cp.produce) point_pay,SUM(cp.apply) point_charge, 
		SUM(cp.produce-cp.apply) point_balance,SUM(cb.point_pay- cb.point_charge) point_balance2
	FROM card_base cb,card_point cp,card_level  cl
	WHERE cb.hotel_group_id=2  AND cb.hotel_id = 9 AND cp.biz_date <= '2013-12-26'
	AND cp.card_no = cb.id AND cb.hotel_group_id = cl.hotel_group_id AND cb.card_level = cl.code
	GROUP BY cb.card_level
	ORDER BY cl.list_order,cl.code
)b ON a.code = b.code
LEFT JOIN (
	SELECT cl.code,cl.descript,SUM(ca.pay) pay,SUM(ca.charge) charge,SUM(ca.pay-ca.charge) balance,SUM(cb.pay-cb.charge) balance2
	FROM card_account ca,card_base cb,card_level cl
	WHERE cb.hotel_group_id=2  AND cb.hotel_id = 9 AND ca.biz_date <= '2013-12-26'
	AND ca.card_id = cb.id AND cb.hotel_group_id = cl.hotel_group_id AND cb.card_level = cl.code
	GROUP BY cb.card_level
	ORDER BY cl.list_order,cl.code
) c ON a.code = c.code