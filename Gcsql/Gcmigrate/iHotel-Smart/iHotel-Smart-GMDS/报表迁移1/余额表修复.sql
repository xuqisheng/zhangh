	SELECT * FROM zzz;
	UPDATE zzz SET hotel_id=10288;
	INSERT INTO zzz(hotel_id,accnt_type,accnt,balance)
	SELECT 10288,'master',a.accnt, SUM(a.charge-a.pay) FROM account a WHERE a.hotel_group_id = 242 AND a.hotel_id = 10288 AND
	a.biz_date <= '2016.08.02' GROUP BY a.accnt;
	-- 消费帐
	SELECT SUM(b.balance) FROM master_base_till a,zzz b WHERE a.hotel_id = 10288   -- -95930.06
	AND a.id = b.accnt AND a.rsv_class = 'H';
	-- 宾客
	SELECT SUM(b.balance) FROM master_base_till a,zzz b WHERE a.hotel_id = 10288  -- 184288.40
	AND a.id = b.accnt AND a.rsv_class = 'F' ;
	-- 团队
	SELECT SUM(b.balance) FROM master_base_till a,zzz b WHERE a.hotel_id = 10288  -- 224569.25
	AND a.id = b.accnt AND a.rsv_class = 'G' ;
	
	SELECT SUM(balance)  FROM zzz  WHERE accnt_type='master'
	消费账户：
	SELECT -95930.06--95060.06=-870
-- 	update rep_jiedai set last_charge=last_charge-870,till_charge=till_charge-870 WHERE hotel_id=10288  and classno='02C';
-- 	UPDATE rep_jiedai_history SET last_charge=last_charge-870,till_charge=till_charge-870 WHERE hotel_id=10288 AND classno='02C';
	
	
	宾客账户：
	SELECT 184288.40-154773.70
	UPDATE rep_jiedai SET last_charge=last_charge+ 29514.70,till_charge=till_charge+ 29514.70 WHERE hotel_id=10288  AND classno='02F';
	UPDATE rep_jiedai_history SET last_charge=last_charge+ 29514.70,till_charge=till_charge+ 29514.70 WHERE hotel_id=10288 AND classno='02F';
	
	SELECT 224569.25-254332.95 = -29763.70
	UPDATE rep_jiedai SET last_charge=last_charge+  -29763.70,till_charge=till_charge+  -29763.70 WHERE hotel_id=10288  AND classno='02G';
	UPDATE rep_jiedai_history SET last_charge=last_charge+  -29763.70,till_charge=till_charge+  -29763.70 WHERE hotel_id=10288 AND classno='02G';
	
	
	SELECT -95930.06 + 184288.40 + 224569.25 = 312927.59
	
	SELECT * FROM REP_DAI WHERE hotel_id=10288  AND CLASSNO='02000';
         
        SELECT  312927.59-314046.59 =-1119.00
	
	
	UPDATE rep_dai SET till_bl=till_bl + -1119.00,last_bl=last_bl + -1119.00 WHERE  hotel_id=10288  AND CLASSNO='02000';
	
	UPDATE rep_dai_history SET till_bl=till_bl + -1119.00,last_bl=last_bl + -1119.00 WHERE  hotel_id=10288  AND CLASSNO='02000';
	
	
	
	
	
	SELECT SUM(b.charge) FROM migrate_db.master a,migrate_db.account b WHERE b.bdate = '2016.08.02' AND a.accnt = b.accnt
	AND a.accnt LIKE 'AR%'  AND a.artag1 NOT IN('1','2','3');
	
	SELECT SUM(b.credit) FROM migrate_db.master a,migrate_db.account b WHERE b.bdate = '2016.08.02' AND a.accnt = b.accnt
	AND a.accnt LIKE 'AR%' AND a.artag1 NOT IN('1','2','3');
		
	SELECT * FROM migrate_db.account;
	
	
	SELECT SUM(balance) FROM zzz WHERE hotel_id = 10288 AND accnt_type = 'master';

	INSERT INTO zzz(hotel_id,accnt_type,accnt,balance)
	SELECT 10288,'armaster',a.id, SUM(a.charge-a.pay) FROM ar_master_till a WHERE a.hotel_group_id = 242 AND a.hotel_id = 10288 
	GROUP BY a.id;	

	SELECT SUM(balance) FROM zzz WHERE hotel_id = 10288 AND accnt_type = 'armaster';
	UPDATE master_snapshot b SET b.till_balance = 0 WHERE b.hotel_group_id = 242 AND b.hotel_id = 10288 AND  b.biz_date_begin < '2016.08.02' AND b.biz_date_end >= '2016.08.02';
	UPDATE master_snapshot b ,zzz a 
	SET b.till_balance =  a.balance   
	WHERE  b.hotel_group_id = 242 AND b.hotel_id = 10288 AND b.biz_date_begin < '2016.08.02' 
	AND b.biz_date_end >= '2016.08.02' AND b.master_id = a.accnt AND b.hotel_id = a.hotel_id AND
 	a.accnt_type ='master' AND b.master_type IN('master','consume') ;
 	
 	UPDATE master_snapshot b ,zzz a 
 	SET b.till_balance =  a.balance  
 	 WHERE  b.hotel_group_id = 242 AND b.hotel_id = 10288  AND b.biz_date_begin < '2016.08.02' AND b.biz_date_end >= '2016.08.02' 
 	 AND b.master_id = a.accnt AND b.hotel_id = a.hotel_id AND
 	a.accnt_type ='armaster' AND b.master_type ='armaster';
	
 
	UPDATE master_snapshot  SET  last_balance = till_balance -charge_ttl + pay_ttl WHERE hotel_group_id = 242 AND hotel_id = 10288 
	AND biz_date_begin < '2016.08.02' AND  biz_date_end >= '2016.08.02'; 
	
	
	SELECT * FROM rep_dai WHERE hotel_id=10288  AND classno='03000';
         
        SELECT  111272.61+3 - 365143.31 = -253867.70
	
	
	UPDATE rep_dai SET till_bl=till_bl + -3,last_bl=last_bl + -3 WHERE  hotel_id=10288  AND CLASSNO='03000';
	
	UPDATE rep_dai_history SET till_bl=till_bl + -3,last_bl=last_bl + -3 WHERE  hotel_id=10288  AND CLASSNO='03000';
	
	
	SELECT * FROM rep_jiedai WHERE hotel_id=10288  AND classno='03A'
	
	SELECT -253867.70

	UPDATE rep_jiedai SET last_charge=last_charge+ -3,till_charge=till_charge+ -3 WHERE hotel_id=10288  AND classno='03A';
	UPDATE rep_jiedai_history SET last_charge=last_charge+ -3,till_charge=till_charge+ -3 WHERE hotel_id=10288 AND classno='03A';
	
	
	
	
	