   	UPDATE master_base a,up_map_code b 
   	SET a.ratecode = b.code_new WHERE a.hotel_group_id=1 AND a.hotel_id = 1
   	 AND a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id  AND b.code = 'ratecode' AND b.code_old = a.ratecode; 


UPDATE master_base a,up_map_accnt b,migrate_xmyh.master c,up_map_accnt d SET master_id=d.accnt_new
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 
	AND b.hotel_id = 1 AND d.hotel_group_id = 1 AND d.hotel_id = 1
	AND a.id=b.accnt_new AND (b.accnt_type ='master_si' OR b.accnt_type = 'master_r')AND (d.accnt_type ='master_si' OR d.accnt_type ='master_r')  
	AND b.accnt_old=c.accnt AND c.master<>'' AND c.master = d.accnt_old;


	SELECT * FROM master_base a,up_map_accnt b,migrate_xmyh.master c WHERE a.hotel_group_id = 1 AND a.hotel_id = 1
	AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND a.id = b.accnt_new AND 
	(b.accnt_type ='master_si' OR b.accnt_type = 'master_r' )
	AND b.accnt_old = c.accnt;
	
	UPDATE  master_base a,up_map_accnt b,migrate_xmyh.master c SET a.ratecode = c.ratecode
	WHERE a.hotel_group_id = 1 AND a.hotel_id = 1
	AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND a.id = b.accnt_new AND 
	(b.accnt_type ='master_si' OR b.accnt_type = 'master_r' )
	AND b.accnt_old = c.accnt;
	
	UPDATE  rsv_src a,up_map_accnt b,migrate_xmyh.master c SET a.ratecode = c.ratecode
	WHERE a.hotel_group_id = 1 AND a.hotel_id = 1
	AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND a.accnt = b.accnt_new AND 
	(b.accnt_type ='master_si' OR b.accnt_type = 'master_r' )
	AND b.accnt_old = c.accnt;
	
	-- 修改协议单位房价码
	SELECT a.company_id,a.code1,b.accnt_old,b.accnt_new,c.no,c.code1 FROM company_type a,up_map_accnt b,migrate_xmyh.guest c WHERE a.hotel_group_id = 1 AND a.hotel_id = 1
	AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND a.company_id = b.accnt_new AND 
	(b.accnt_type ='COMPANY' )
	AND b.accnt_old = c.no AND c.class IN('A','S','C');	
	
	UPDATE company_type a,up_map_accnt b,migrate_xmyh.guest c  SET a.code1 = c.code1 
	WHERE a.hotel_group_id = 1 AND a.hotel_id = 1
	AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND a.company_id = b.accnt_new AND 
	(b.accnt_type ='COMPANY' )
	AND b.accnt_old = c.no AND c.class IN('A','S','C');	
	
	-- 修改有效期
	SELECT * FROM company_type WHERE DATE(valid_begin) = '2014.10.25';
	UPDATE company_type SET valid_begin = NULL WHERE DATE(valid_begin) = '2014.10.25';
	UPDATE company_type SET valid_end = NULL WHERE DATE(valid_end) = '2018.12.31';	
	
	-- 修改单位类别
	UPDATE company_type SET class1 = '' WHERE class1 = '0';
	UPDATE company_type SET class2 = '' WHERE class2 = '0';
	UPDATE company_type SET class3 = '' WHERE class3 = '0';
	UPDATE company_type SET class4 = '' WHERE class4 = '0';
	