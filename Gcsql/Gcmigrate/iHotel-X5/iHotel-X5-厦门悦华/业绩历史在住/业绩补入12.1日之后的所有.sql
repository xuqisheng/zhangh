-- 补入12.1日之后的业绩
SELECT COUNT(1) FROM migrate_xmyh.ycus_xf;
 
SELECT * FROM migrate_xmyh.ycus_xf WHERE DATE >='2014.12.1';
SELECT * FROM migrate_xmyh.ycus_xf WHERE DATE >='2014.12.1' AND tag IS NULL;
SELECT DISTINCT actcls FROM migrate_xmyh.ycus_xf;
UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.c_id=b.accnt_new 	WHERE b.hotel_group_id=1 AND b.hotel_id=1 AND a.actcls='P' AND a.cusno=b.accnt_old 	AND b.accnt_type='COMPANY';   
UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.a_id=b.accnt_new 	WHERE b.hotel_group_id=1 AND b.hotel_id=1 AND a.actcls='P' AND a.agent=b.accnt_old 	AND b.accnt_type='COMPANY';  
UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.s_id=b.accnt_new 	WHERE b.hotel_group_id=1 AND b.hotel_id=1 AND a.actcls='P' AND a.source=b.accnt_old 	AND b.accnt_type='COMPANY';   
UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.haccnt_id=b.accnt_new WHERE b.hotel_group_id=1 AND b.hotel_id=1 AND a.actcls='P' AND a.haccnt=b.accnt_old 	AND b.accnt_type='GUEST_FIT';
UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.haccnt_id=b.accnt_new WHERE b.hotel_group_id=1 AND b.hotel_id=1 AND a.actcls='P' AND a.haccnt=b.accnt_old 	AND b.accnt_type='GUEST_GRP';	

UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.accnt_id=b.accnt_new 	WHERE b.hotel_group_id=1 AND b.hotel_id=1
 AND a.actcls='F' AND a.accnt=b.accnt_old AND b.accnt_type='armst';   
 
SELECT * FROM migrate_xmyh.ycus_xf WHERE actcls = 'P';
UPDATE  migrate_xmyh.ycus_xf SET accnt_id = accnt WHERE actcls = 'P';

SELECT * FROM migrate_xmyh.ycus_xf WHERE DATE >='2014.12.1' AND tag = 'A';
SELECT * FROM migrate_xmyh.ycus_xf WHERE DATE >='2014.12.1' AND tag IS NULL;
UPDATE  migrate_xmyh.ycus_xf SET tag1 = 'A1' WHERE DATE >='2014.12.1' AND tag IS NULL;

SELECT * FROM production_detail WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date >='2014.12.1'
AND biz_date <='2014.12.6' AND master_type = 'pos';

SELECT * FROM migrate_xmyh.ycus_xf WHERE  tag1 = 'A1';
SELECT * FROM migrate_xmyh.ycus_xf WHERE  DATE ='2014.12.7';
UPDATE migrate_xmyh.ycus_xf SET tag1 = 'A1' WHERE  DATE ='2014.12.7' AND tag = 'A';

SELECT * FROM production_detail WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date >='2014.12.1'
AND biz_date <='2014.12.7';
SELECT * FROM migrate_xmyh.ycus_xf WHERE  DATE >='2014.12.1' AND DATE <='2014.12.7';

SELECT SUM(nights2),SUM(production_rm),SUM(production_fb),SUM(production_ttl) FROM production_detail WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date >='2014.12.1'
AND biz_date <='2014.12.7';
SELECT SUM(i_days),SUM(rm),SUM(fb),SUM(ttl) FROM migrate_xmyh.ycus_xf WHERE  DATE >='2014.12.1' AND DATE <='2014.12.7';

SELECT SUM(i_days),SUM(rm),SUM(fb),SUM(ttl) FROM migrate_xmyh.ycus_xf WHERE  DATE >='2014.12.1' AND DATE <='2014.12.7' AND (cusno <> '' OR agent<>'' OR source <> '');
SELECT SUM(nights2),SUM(production_rm),SUM(production_fb),SUM(production_ttl) FROM production_detail WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date >='2014.12.1'
AND biz_date <='2014.12.7' AND (agent_id <> 0 OR company_id <> 0 OR source_id <> 0);

SELECT SUM(rm),SUM(fb) FROM migrate_xmyh.ycus_xf WHERE DATE >='2014.12.1' AND (cusno <> '' OR agent<>'' OR source <> '')

SELECT * FROM production_detail WHERE hotel_group_id = 1 AND hotel_id = 1   AND 
dep IS NULL;

UPDATE production_detail SET arr = biz_date  WHERE hotel_group_id = 1 AND hotel_id = 1   AND 
arr IS NULL;
UPDATE production_detail SET dep = biz_date  WHERE hotel_group_id = 1 AND hotel_id = 1   AND 
dep IS NULL;