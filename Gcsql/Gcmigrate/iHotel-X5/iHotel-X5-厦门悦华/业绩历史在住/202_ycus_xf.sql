-- 扩充字段
ALTER TABLE migrate_xmyh.ycus_xf ADD c_id BIGINT(16) NOT NULL DEFAULT 0;
ALTER TABLE migrate_xmyh.ycus_xf ADD a_id BIGINT(16) NOT NULL DEFAULT 0;
ALTER TABLE migrate_xmyh.ycus_xf ADD s_id BIGINT(16) NOT NULL DEFAULT 0;
ALTER TABLE migrate_xmyh.ycus_xf ADD accnt_id BIGINT(16);
ALTER TABLE migrate_xmyh.ycus_xf ADD groupno_id BIGINT(16);
ALTER TABLE migrate_xmyh.ycus_xf ADD haccnt_id BIGINT(16);
ALTER TABLE migrate_xmyh.ycus_xf ADD master_id BIGINT(16);	

ALTER TABLE migrate_xmyh.ycus_xf ADD tag CHAR(2);	
ALTER TABLE migrate_xmyh.ycus_xf ADD tag1 CHAR(2);	

-- 索引
CREATE INDEX cusno ON migrate_xmyh.ycus_xf(cusno);
CREATE INDEX agent ON migrate_xmyh.ycus_xf(agent);
CREATE INDEX source ON migrate_xmyh.ycus_xf(source);
CREATE INDEX accnt ON migrate_xmyh.ycus_xf(accnt);	
CREATE INDEX haccnt ON migrate_xmyh.ycus_xf(haccnt);
CREATE INDEX MASTER ON migrate_xmyh.ycus_xf(MASTER);
CREATE INDEX saleid ON migrate_xmyh.ycus_xf(saleid);
CREATE INDEX groupno ON migrate_xmyh.ycus_xf(groupno);
CREATE INDEX tag ON migrate_xmyh.ycus_xf(tag,DATE);
CREATE INDEX tag1 ON migrate_xmyh.ycus_xf(tag1,DATE);

-- actcls 'F' 前台 actcls 'P' 餐饮
SELECT * FROM migrate_xmyh.ycus_xf WHERE actcls = 'P';
UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.c_id=b.accnt_new 	WHERE b.hotel_group_id=1 AND b.hotel_id=1 AND a.actcls='F' AND a.cusno=b.accnt_old 	AND b.accnt_type='COMPANY';   
UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.a_id=b.accnt_new 	WHERE b.hotel_group_id=1 AND b.hotel_id=1 AND a.actcls='F' AND a.agent=b.accnt_old 	AND b.accnt_type='COMPANY';  
UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.s_id=b.accnt_new 	WHERE b.hotel_group_id=1 AND b.hotel_id=1 AND a.actcls='F' AND a.source=b.accnt_old 	AND b.accnt_type='COMPANY';   
UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.haccnt_id=b.accnt_new WHERE b.hotel_group_id=1 AND b.hotel_id=1 AND a.actcls='F' AND a.haccnt=b.accnt_old 	AND b.accnt_type='GUEST_FIT';
UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.haccnt_id=b.accnt_new WHERE b.hotel_group_id=1 AND b.hotel_id=1 AND a.actcls='F' AND a.haccnt=b.accnt_old 	AND b.accnt_type='GUEST_GRP';	

SELECT * FROM migrate_xmyh.ycus_xf;
UPDATE migrate_xmyh.ycus_xf a,up_map_code b SET a.market = b.code_new WHERE b.hotel_group_id=1 AND b.hotel_id = 1 AND b.code = 'mktcode' AND b.code_old = a.market ; 
UPDATE migrate_xmyh.ycus_xf a,up_map_code b SET a.src = b.code_new WHERE b.hotel_group_id=1 AND b.hotel_id = 1 AND b.code = 'srccode' AND b.code_old = a.src ; 
UPDATE migrate_xmyh.ycus_xf a,up_map_code b SET a.channel = b.code_new WHERE b.hotel_group_id=1 AND b.hotel_id = 1 AND b.code = 'channel' AND b.code_old = a.channel ; 

 	UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.accnt_id=b.accnt_new 	WHERE b.hotel_group_id=1 AND b.hotel_id=1
	 AND a.actcls='F' AND a.accnt=b.accnt_old 	AND b.accnt_type='hmaster';  

-- 迁移有客史 协议单位、订房中心、旅行社的业绩
UPDATE migrate_xmyh.ycus_xf  SET tag = 'A' WHERE haccnt_id IS NOT NULL;
UPDATE migrate_xmyh.ycus_xf  SET tag = 'A' WHERE c_id <>0;
UPDATE migrate_xmyh.ycus_xf  SET tag = 'A' WHERE a_id <>0;
UPDATE migrate_xmyh.ycus_xf  SET tag = 'A' WHERE s_id <>0;

UPDATE migrate_xmyh.ycus_xf a SET accnt_id = NULL,groupno_id = NULL,master_id = NULL;

SELECT COUNT(1) FROM migrate_xmyh.ycus_xf WHERE tag = 'A';

SELECT * FROM migrate_xmyh.ycus_xf WHERE haccnt = '9312609';
SELECT * FROM up_map_accnt WHERE hotel_group_id = 1 AND hotel_id = 1 AND accnt_new = '789617';
SELECT * FROM migrate_xmyh.hmaster1 WHERE accnt = 'F602280089';
SELECT * FROM up_map_accnt WHERE hotel_group_id = 1 AND hotel_id = 1 AND accnt_old = '6000091';
SELECT * FROM migrate_xmyh.ycus_xf WHERE tag = 'A';
SELECT * FROM up_map_accnt WHERE hotel_group_id = 1 AND hotel_id = 1 AND accnt_new = '680854';

UPDATE migrate_xmyh.ycus_xf a SET a.accnt_id = CONVERT(SUBSTRING(accnt,2),SIGNED)  WHERE tag = 'A'
AND accnt_id IS NULL;
UPDATE migrate_xmyh.ycus_xf a SET a.master_id = CONVERT(SUBSTRING(MASTER,2),SIGNED)  WHERE tag = 'A'
AND master_id IS NULL;
UPDATE migrate_xmyh.ycus_xf a SET a.haccnt_id = haccnt  WHERE tag = 'A'
AND haccnt_id IS NULL;
SELECT * FROM guest_production WHERE hotel_group_id = 1 AND hotel_id = 1   ;
SELECT * FROM production_detail WHERE hotel_group_id = 1 AND hotel_id = 1  AND biz_date <='2014.12.6' AND guest_id = 789617;
