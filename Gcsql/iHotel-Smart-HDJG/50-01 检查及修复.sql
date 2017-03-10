-- 房类
SELECT * FROM master_base WHERE hotel_group_id = 2 AND  hotel_id=15 AND rmtype<>''
AND rmtype NOT IN (SELECT CODE FROM room_type WHERE hotel_group_id = 2 AND  hotel_id=15 );

SELECT * FROM rsv_src WHERE hotel_group_id = 2 AND  hotel_id=15 AND rmtype<>''
AND rmtype NOT IN (SELECT CODE FROM room_type WHERE hotel_group_id = 2 AND  hotel_id=15 );

-- 房号
SELECT * FROM master_base WHERE hotel_group_id = 2 AND  hotel_id=15 AND rmno<>''
AND rmno NOT IN (SELECT CODE FROM room_no WHERE hotel_group_id = 2 AND  hotel_id=15 );

SELECT * FROM rsv_src WHERE hotel_group_id = 2 AND  hotel_id=15 AND rmno<>''
AND rmno NOT IN (SELECT CODE FROM room_no WHERE hotel_group_id = 2 AND  hotel_id=15 );

-- 市场码
SELECT * FROM master_base WHERE hotel_group_id = 2 AND  hotel_id=15
AND market NOT IN (SELECT CODE FROM code_base WHERE hotel_group_id = 2 AND  hotel_id=15 AND parent_code='market_code' )
GROUP BY market;

-- 来源码
SELECT  * FROM master_base WHERE hotel_group_id = 2 AND  hotel_id=15  
AND src NOT IN (SELECT CODE FROM code_base WHERE hotel_group_id = 2 AND  hotel_id=15 AND parent_code='src_code' AND is_halt='F')
GROUP BY src;

-- 渠道码
SELECT * FROM master_base WHERE hotel_group_id = 2 AND  hotel_id=15
AND channel NOT IN (SELECT CODE FROM code_base WHERE hotel_group_id = 2 AND  hotel_id=15 AND parent_code='channel' AND is_halt='F')
GROUP BY channel;

-- 预订类型
SELECT * FROM master_base WHERE hotel_group_id = 2 AND  hotel_id=15  AND rsv_class<>'H'
AND rsv_type NOT IN (SELECT CODE FROM code_rsv_type WHERE hotel_group_id = 2 AND  hotel_id=15 AND is_halt='F') 
GROUP BY rsv_type;

-- 房价码
SELECT * FROM master_base WHERE hotel_group_id = 2 AND  hotel_id=15  AND ratecode<>''  AND rsv_class<>'H'
AND ratecode NOT IN (SELECT CODE FROM code_ratecode WHERE hotel_group_id = 2 AND  hotel_id=15 ) 
GROUP BY ratecode;


-- 费用码 付款码
SELECT * FROM account WHERE hotel_group_id = 2 AND  hotel_id=15  
AND ta_code NOT IN (SELECT CODE FROM code_transaction WHERE hotel_group_id = 2 AND  hotel_id=15 ) 
GROUP BY ta_code;

SELECT * FROM account WHERE hotel_group_id = 2 AND  hotel_id=15  
AND arrange_code NOT IN (SELECT CODE FROM code_base WHERE hotel_group_id = 2 AND  hotel_id=15 AND parent_code='arrangement_bill') 
GROUP BY arrange_code;


SELECT a.ta_code,a.ta_descript,c.pccode,c.ref
FROM  account a,up_map_accnt b,migrate_db.account c 
	WHERE a.hotel_group_id=2 AND a.hotel_id=25 AND b.hotel_group_id=2 AND b.hotel_id=25 
	AND a.accnt=b.accnt_new AND b.accnt_old=c.accnt AND a.number=c.number AND b.accnt_type IN ('master_si','master_r','consume');

-- ar余额检查
-- ihotel(migrate_db)
SELECT artag1,SUM(charge-credit) FROM ar_master WHERE sta='I' GROUP BY artag1 ORDER BY artag1;
SELECT artag1,COUNT(1) FROM ar_master WHERE sta='I' GROUP BY artag1 ORDER BY artag1;
SELECT SUM(charge-credit) FROM ar_master WHERE sta='I' ;
SELECT 1,SUM(charge-credit) FROM MASTER WHERE sta='I' AND a 
UNION ALL
SELECT 2,SUM(a.charge + a.charge0 - a.credit - a.credit0) FROM ar_detail a,ar_master b WHERE a.accnt=b.accnt ; 

-- 检查及修复
SELECT ar_category,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 2 AND hotel_id = 25 AND sta='I' GROUP BY ar_category ORDER BY 		ar_category;
SELECT ar_category,COUNT(1) FROM ar_master WHERE hotel_group_id = 2 AND hotel_id = 25 AND sta='I' GROUP BY ar_category ORDER BY ar_category;	
SELECT 1,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 2 AND hotel_id = 25
UNION ALL
SELECT 2,SUM(charge + charge0 - pay - pay0) FROM ar_account WHERE hotel_group_id = 2 AND hotel_id = 25;


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
	




