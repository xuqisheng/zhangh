	DELETE FROM zzz;
	SELECT * FROM zzz;
	INSERT INTO zzz(hotel_id,accnt_type,accnt,balance)
	SELECT 1,'master',a.accnt, SUM(a.charge-a.pay) FROM account a WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND
	a.biz_date <= '2014.12.07' GROUP BY a.accnt;

	SELECT SUM(balance) FROM zzz WHERE hotel_id = 1 AND accnt_type = 'master';

	INSERT INTO zzz(hotel_id,accnt_type,accnt,balance)
	SELECT 1,'armaster',a.id, SUM(a.charge-a.pay) FROM ar_master_till a WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 
	GROUP BY a.id;	

	SELECT SUM(balance) FROM zzz WHERE hotel_id = 1 AND accnt_type = 'armaster';
	UPDATE master_snapshot b SET b.till_balance = 0 WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND  b.biz_date_begin < '2014.12.07' AND b.biz_date_end >= '2014.12.07'
	UPDATE master_snapshot b ,zzz a SET b.till_balance =  a.balance   WHERE  b.hotel_group_id = 1 AND
 	b.hotel_id = 1 AND b.biz_date_begin < '2014.12.07' AND b.biz_date_end >= '2014.12.07' AND b.master_id = a.accnt AND b.hotel_id = a.hotel_id AND
 	a.accnt_type ='master' AND b.master_type IN('master','consume') ;
 	UPDATE master_snapshot b ,zzz a SET b.till_balance =  a.balance   WHERE  b.hotel_group_id = 1 AND
 	b.hotel_id = 1  AND b.biz_date_begin < '2014.12.07' AND b.biz_date_end >= '2014.12.07' AND b.master_id = a.accnt AND b.hotel_id = a.hotel_id AND
 	a.accnt_type ='armaster' AND b.master_type ='armaster';
	
 
	UPDATE master_snapshot  SET  last_balance = till_balance -charge_ttl + pay_ttl WHERE hotel_group_id = 1 AND hotel_id = 1 
	AND biz_date_begin < '2014.12.07' AND  biz_date_end >= '2014.12.07'; 
	
	SELECT SUM(till_balance) FROM master_snapshot WHERE hotel_group_id = 1 AND hotel_id = 1 AND  biz_date_begin < '2014.12.07' AND  biz_date_end >= '2014.12.07'
	AND master_type = 'armaster'; 
	
	SELECT SUM(till_balance) FROM master_snapshot WHERE hotel_group_id = 1 AND hotel_id = 1 AND  biz_date_begin < '2014.12.07' AND  biz_date_end >= '2014.12.07'
	AND master_type <> 'armaster'; 	
	
	SELECT * FROM master_snapshot WHERE hotel_group_id = 1 AND hotel_id = 1 AND  biz_date_begin < '2014.12.07' AND  biz_date_end >= '2014.12.07' AND sta = 'O';
	