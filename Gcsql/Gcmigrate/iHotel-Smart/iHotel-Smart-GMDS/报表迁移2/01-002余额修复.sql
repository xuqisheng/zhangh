	-- 在正式库portal中执行
	DELETE FROM zzz WHERE hotel_id = 13;
	SELECT * FROM zzz WHERE hotel_id = 13;
	INSERT INTO zzz(hotel_id,accnt_type,accnt,balance)
	SELECT 13,'master',a.accnt, SUM(a.charge-a.pay) FROM account a WHERE a.hotel_group_id = 2 AND a.hotel_id = 13 AND
	a.biz_date <= '2016.09.09' GROUP BY a.accnt;

	SELECT SUM(charge - credit ) FROM migrate_db.master_till WHERE accnt NOT LIKE 'AR%'  -- 63663.40
	SELECT SUM(balance) FROM zzz WHERE hotel_id = 13 AND accnt_type = 'master';  -- 63663.40
	SELECT SUM(charge - pay ) FROM master_base_till WHERE hotel_group_id = 2 AND hotel_id = 13 -- 63663.40
	
	SELECT SUM(b.balance) FROM master_base_till a,zzz b WHERE b.hotel_id = 13 AND b.accnt_type = 'master'
	AND b.accnt = a.id AND a.hotel_group_id = 2 AND a.hotel_id = 13 AND a.rsv_class = 'H'; -- -2317.00

	SELECT SUM(b.balance) FROM master_base_till a,zzz b WHERE b.hotel_id = 13 AND b.accnt_type = 'master'
	AND b.accnt = a.id AND a.hotel_group_id = 2 AND a.hotel_id = 13 AND a.rsv_class = 'F'; -- 65601.40

	SELECT SUM(b.balance) FROM master_base_till a,zzz b WHERE b.hotel_id = 13 AND b.accnt_type = 'master'
	AND b.accnt = a.id AND a.hotel_group_id = 2 AND a.hotel_id = 13 AND a.rsv_class = 'G'; -- 379.00
 

	SELECT 141817.00;
	
	SELECT SUM(balance) FROM zzz WHERE hotel_id = 13 AND accnt_type = 'master';	 -- 295803.33
	SELECT SUM(balance) FROM zzz WHERE hotel_id = 13 AND accnt_type = 'armaster';
	INSERT INTO zzz(hotel_id,accnt_type,accnt,balance)
	SELECT 13,'armaster',a.id, SUM(a.charge-a.pay) FROM ar_master_till a WHERE a.hotel_group_id = 2 AND a.hotel_id = 13 
	GROUP BY a.id;	

	SELECT SUM(balance) FROM zzz WHERE hotel_id = 13 AND accnt_type = 'armaster'; -- -146298.05
	
	SELECT SUM(charge - credit) FROM migrate_db.master WHERE  accnt LIKE 'AR%'  AND artag1 NOT IN  ('CAR'); -- -146298.05
		
	UPDATE master_snapshot b SET b.till_balance = 0 WHERE b.hotel_group_id = 2 AND b.hotel_id = 13 AND  b.biz_date_begin < '2016.09.09' AND b.biz_date_end >= '2016.09.09';
	UPDATE master_snapshot b ,zzz a SET b.till_balance =  a.balance   WHERE  b.hotel_group_id = 2 AND b.hotel_id = 13 AND b.biz_date_begin < '2016.09.09' AND b.biz_date_end >= '2016.09.09' AND b.master_id = a.accnt AND b.hotel_id = a.hotel_id AND a.accnt_type ='master' AND b.master_type IN('master','consume') ;
 	UPDATE master_snapshot b ,zzz a SET b.till_balance =  a.balance   WHERE  b.hotel_group_id = 2 AND b.hotel_id = 13  AND b.biz_date_begin < '2016.09.09' AND b.biz_date_end >= '2016.09.09' AND b.master_id = a.accnt AND b.hotel_id = a.hotel_id AND a.accnt_type ='armaster' AND b.master_type ='armaster';
	
	UPDATE master_snapshot  SET  last_balance = till_balance -charge_ttl + pay_ttl WHERE hotel_group_id = 2 AND hotel_id = 13 AND biz_date_begin < '2016.09.09' AND  biz_date_end >= '2016.09.09'; 
	
	-- -146298.05
	SELECT SUM(till_balance) FROM master_snapshot WHERE hotel_group_id = 2 AND hotel_id = 13 AND  biz_date_begin < '2016.09.09' AND  biz_date_end >= '2016.09.09' AND master_type = 'armaster'; 
	
	-- 63663.40
	SELECT SUM(till_balance) FROM master_snapshot WHERE hotel_group_id = 2 AND hotel_id = 13 AND  biz_date_begin < '2016.09.09' AND  biz_date_end >= '2016.09.09' AND master_type <> 'armaster'; 	
	
	SELECT * FROM master_snapshot WHERE hotel_group_id = 2 AND hotel_id = 13 AND  biz_date_begin < '2016.09.09' AND  biz_date_end >= '2016.09.09' AND sta = 'O';
		
	SELECT * FROM master_snapshot WHERE hotel_group_id = 2 AND hotel_id = 13
	
	SELECT SUM(till_balance) FROM master_snapshot WHERE hotel_id = 13 AND master_type ='armaster' -- -8802352.70
