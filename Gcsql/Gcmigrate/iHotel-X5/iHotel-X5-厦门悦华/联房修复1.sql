SELECT 'I',a.pcrec,COUNT(1) FROM migrate_xmyh.master a WHERE a.pcrec NOT IN (SELECT b.accnt FROM migrate_xmyh.master b WHERE sta <> 'X' ) AND a.pcrec<>'' AND a.sta='I' GROUP BY a.pcrec HAVING (COUNT(1))>1 ;
SELECT 'S',a.pcrec,COUNT(1) FROM migrate_xmyh.master a WHERE a.pcrec NOT IN (SELECT b.accnt FROM migrate_xmyh.master b WHERE sta <> 'X' AND sta <> 'D') AND a.pcrec<>'' AND a.sta='S' GROUP BY a.pcrec HAVING (COUNT(1))>1 ;
SELECT 'I',a.pcrec,COUNT(1) FROM migrate_xmyh.master a WHERE a.pcrec   IN (SELECT b.accnt FROM migrate_xmyh.master b WHERE sta = 'X' ) AND a.pcrec<>'' AND a.sta='I' GROUP BY a.pcrec HAVING (COUNT(1))>1 ;
		
		
SELECT  * FROM migrate_xmyh.master WHERE pcrec = 'F410260099';
SELECT  * FROM migrate_xmyh.hmaster1 WHERE pcrec = 'F410260099';

SELECT * FROM migrate_xmyh.master WHERE accnt = 'F411250022';

SELECT a.id,a.rmno,a.master_id,a.link_id,b.accnt,b.pcrec FROM master_base a,migrate_xmyh.master b,up_map_accnt c WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND 
a.id = c.accnt_new AND c.hotel_group_id = 1 AND c.hotel_id = 1 AND (c.accnt_type = 'master_si' OR c.accnt_type = 'master_r')
AND b.accnt = c.accnt_old AND b.pcrec = 'F108020020';

-- 历史部分
SELECT a.accnt,a.roomno,a.pcrec,a.sta,b.accnt,b.pcrec,b.sta FROM migrate_xmyh.master a,migrate_xmyh.hmaster1 b WHERE a.pcrec = b.accnt AND a.sta NOT IN('X','N','D') 
AND b.sta NOT IN('X','N');

SELECT a.accnt,a.roomno,a.sta,a.pcrec,b.accnt,b.roomno,b.sta,b.pcrec FROM migrate_xmyh.hmaster1 a,migrate_xmyh.master b WHERE a.pcrec = b.accnt AND b.sta NOT IN('X','N','D');

CREATE INDEX index_scflag ON master_base_history(sc_flag);
-- 1
SELECT * FROM migrate_xmyh.hmaster1 a,(SELECT DISTINCT a.pcrec FROM migrate_xmyh.master a,migrate_xmyh.hmaster1 b WHERE a.pcrec = b.accnt AND a.sta NOT IN('X','N','D') 
AND b.sta NOT IN('X','N')) b WHERE a.pcrec = b.pcrec;

SELECT a.accnt,a.sta,a.type,a.roomno,a.pcrec,a.master,b.accnt,b.pcrec,b.roomno,c.sta,c.rmno,c.link_id,d.id,d.link_id
FROM migrate_xmyh.master a,master_base c,migrate_xmyh.hmaster1 b,master_base_history d,up_map_accnt e WHERE a.accnt = b.pcrec AND a.pcrec <> ''
AND a.sta NOT IN('X','N','D')  AND a.accnt = c.sc_flag AND c.hotel_group_id = 1 AND c.hotel_id = 1
AND  d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.id = e.accnt_new AND e.hotel_group_id = 1 AND e.hotel_id = 1
AND e.accnt_type = 'hmaster' AND e.accnt_old = b.accnt;

SELECT a.accnt,a.sta,a.type,a.roomno,a.pcrec,a.master,b.accnt,b.pcrec,b.roomno,c.sta,c.rmno,c.link_id,d.id,d.link_id
FROM migrate_xmyh.master a,master_base_history c,up_map_accnt f,migrate_xmyh.hmaster1 b,master_base_history d,up_map_accnt e WHERE a.accnt = b.pcrec AND a.pcrec <> ''
AND a.sta NOT IN('X','N','D')   AND a.accnt = c.sc_flag AND f.accnt_type IN('master_si','master_r') AND f.hotel_group_id = 1 AND f.hotel_id = 1 AND c.id = f.accnt_new  AND c.hotel_group_id = 1 AND c.hotel_id = 1
AND  d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.id = e.accnt_new AND e.hotel_group_id = 1 AND e.hotel_id = 1
AND e.accnt_type = 'hmaster' AND e.accnt_old = b.accnt;



UPDATE  migrate_xmyh.master a,master_base c,migrate_xmyh.hmaster1 b,master_base_history d,up_map_accnt e 
SET d.link_id = c.link_id
	WHERE a.accnt = b.pcrec AND a.pcrec <> ''
	AND a.sta NOT IN('X','N','D') AND b.sta = 'O' AND a.accnt = c.sc_flag AND c.hotel_group_id = 1 AND c.hotel_id = 1
	AND  d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.id = e.accnt_new AND e.hotel_group_id = 1 AND e.hotel_id = 1
	AND e.accnt_type = 'hmaster' AND e.accnt_old = b.accnt;

	
DELETE FROM tmp_link_id;
SELECT * FROM tmp_link_id;	
CREATE TABLE tmp_link_id(accnt  CHAR(12),pcrec CHAR(12),link_id BIGINT);
CREATE TABLE tmp_link_id_new(accnt  CHAR(12),pcrec CHAR(12),link_id BIGINT);	
	
INSERT INTO tmp_link_id(accnt,pcrec,link_id)
SELECT b.accnt,b.pcrec,c.link_id
FROM migrate_xmyh.master a,master_base c,migrate_xmyh.hmaster1 b,master_base_history d,up_map_accnt e WHERE a.accnt = b.pcrec AND a.pcrec <> ''
AND a.sta NOT IN('X','N','D') AND b.sta = 'O' AND a.accnt = c.sc_flag AND c.hotel_group_id = 1 AND c.hotel_id = 1
AND  d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.id = e.accnt_new AND e.hotel_group_id = 1 AND e.hotel_id = 1
AND e.accnt_type = 'hmaster' AND e.accnt_old = b.accnt;

INSERT INTO tmp_link_id(accnt,pcrec,link_id)
SELECT b.accnt,b.pcrec,c.link_id
FROM migrate_xmyh.master a,master_base_history c,up_map_accnt f,migrate_xmyh.hmaster1 b,master_base_history d,up_map_accnt e WHERE a.accnt = b.pcrec AND a.pcrec <> ''
AND a.sta NOT IN('X','N','D')   AND a.accnt = c.sc_flag AND f.accnt_type IN('master_si','master_r') AND f.hotel_group_id = 1 AND f.hotel_id = 1 AND c.id = f.accnt_new  AND c.hotel_group_id = 1 AND c.hotel_id = 1
AND  d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.id = e.accnt_new AND e.hotel_group_id = 1 AND e.hotel_id = 1
AND e.accnt_type = 'hmaster' AND e.accnt_old = b.accnt;

-- 去重复联房id
DELETE FROM tmp_link_id_new;
INSERT tmp_link_id_new(pcrec,link_id)
SELECT DISTINCT pcrec,link_id FROM tmp_link_id;	

 
SELECT a.id,a.sc_flag,a.link_id,b.accnt,b.pcrec,c.pcrec,c.link_id FROM  master_base_history a,migrate_xmyh.hmaster1 b,tmp_link_id_new c ,up_map_accnt d
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.sc_flag = b.accnt AND a.id = d.accnt_new AND d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.accnt_type = 'hmaster' AND b.pcrec = c.pcrec;	

UPDATE master_base_history a,migrate_xmyh.hmaster1 b,tmp_link_id_new c ,up_map_accnt d SET a.link_id = c.link_id
	WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.sc_flag = b.accnt AND a.id = d.accnt_new 
	AND d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.accnt_type = 'hmaster' AND b.pcrec = c.pcrec;	

-- 2
SELECT a.accnt,a.roomno,a.sta,a.pcrec,b.accnt,b.roomno,b.pcrec,b.sta,c.link_id,d.link_id FROM migrate_xmyh.master a,master_base c,migrate_xmyh.hmaster1 b,master_base_history d,up_map_accnt e WHERE a.pcrec = b.accnt AND
a.sta NOT IN('X','N','D') AND a.pcrec <> '' AND a.accnt = c.sc_flag AND b.accnt = d.sc_flag AND d.id = e.accnt_new AND e.accnt_type = 'hmaster' AND e.hotel_group_id = 1 AND e.hotel_id = 1;

SELECT a.accnt,a.roomno,a.sta,a.pcrec,b.accnt,b.roomno,b.pcrec,b.sta,c.link_id,d.link_id FROM migrate_xmyh.master a,master_base_history c,up_map_accnt f,migrate_xmyh.hmaster1 b,master_base_history d,up_map_accnt e WHERE a.pcrec = b.accnt AND
a.sta NOT IN('X','N','D') AND a.pcrec <> '' AND a.accnt = c.sc_flag AND c.id = f.accnt_new AND f.accnt_type IN('master_r','master_si') AND f.hotel_group_id = 1 AND f.hotel_id = 1 AND b.accnt = d.sc_flag AND d.id = e.accnt_new AND e.accnt_type = 'hmaster' AND e.hotel_group_id = 1 AND e.hotel_id = 1;


SELECT a.accnt,a.sta,a.type,a.roomno,a.pcrec,a.master,b.accnt,b.pcrec,b.roomno,c.sta,c.rmno,c.link_id,d.id,d.link_id
FROM migrate_xmyh.master a,master_base c,migrate_xmyh.hmaster1 b,master_base_history d,up_map_accnt e WHERE a.pcrec = b.accnt AND a.pcrec <> ''
AND a.sta NOT IN('X','N','D') AND a.accnt = c.sc_flag AND c.hotel_group_id = 1 AND c.hotel_id = 1
AND  d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.id = e.accnt_new AND e.hotel_group_id = 1 AND e.hotel_id = 1
AND e.accnt_type = 'hmaster' AND e.accnt_old = b.accnt;

DELETE FROM  tmp_link_id1;
DELETE FROM  tmp_link_id2;
DROP TABLE tmp_link_id1;
DROP TABLE tmp_link_id2;

CREATE TABLE tmp_link_id1(accnt  CHAR(12),pcrec CHAR(12),accnt1 BIGINT,link_id BIGINT,link_id2 BIGINT);	
CREATE TABLE tmp_link_id2(accnt  CHAR(12),pcrec CHAR(12),accnt1 BIGINT,link_id BIGINT,link_id2 BIGINT);	

-- 当前表
INSERT INTO tmp_link_id1(accnt,pcrec,accnt1,link_id,link_id2)
SELECT b.accnt,b.pcrec,c.id,c.link_id,d.link_id FROM migrate_xmyh.master a,master_base c,migrate_xmyh.hmaster1 b,master_base_history d,up_map_accnt e WHERE a.pcrec = b.accnt AND
a.sta NOT IN('X','N','D') AND a.pcrec <> '' AND a.accnt = c.sc_flag AND b.accnt = d.sc_flag AND d.id = e.accnt_new AND e.accnt_type = 'hmaster' AND e.hotel_group_id = 1 AND e.hotel_id = 1;

INSERT INTO tmp_link_id1(accnt,pcrec,accnt1,link_id,link_id2)
SELECT b.accnt,b.pcrec,c.id,c.link_id,d.link_id FROM migrate_xmyh.master a,master_base_history c,up_map_accnt f,migrate_xmyh.hmaster1 b,master_base_history d,up_map_accnt e WHERE a.pcrec = b.accnt AND
a.sta NOT IN('X','N','D') AND a.pcrec <> '' AND a.accnt = c.sc_flag AND c.id = f.accnt_new AND f.accnt_type IN('master_r','master_si') AND f.hotel_group_id = 1 AND f.hotel_id = 1 AND b.accnt = d.sc_flag AND d.id = e.accnt_new AND e.accnt_type = 'hmaster' AND e.hotel_group_id = 1 AND e.hotel_id = 1;

SELECT * FROM tmp_link_id1 WHERE link_id = 0;
SELECT * FROM migrate_xmyh.master WHERE pcrec = 'F409120158';
SELECT * FROM migrate_xmyh.hmaster1 WHERE pcrec = 'F409120158';

DELETE FROM tmp_link_id2;
INSERT INTO tmp_link_id2(pcrec,link_id)
SELECT DISTINCT pcrec,link_id FROM tmp_link_id1;
SELECT * FROM tmp_link_id2;
SELECT * FROM tmp_link_id2 WHERE link_id = 0;

 

SELECT a.id,a.sc_flag,a.link_id,b.accnt,b.pcrec,c.pcrec,c.link_id FROM  master_base_history a,migrate_xmyh.hmaster1 b,tmp_link_id2 c ,up_map_accnt d
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.sc_flag = b.accnt AND a.id = d.accnt_new AND d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.accnt_type = 'hmaster' AND b.pcrec = c.pcrec
AND a.link_id <> c.link_id AND c.link_id <> 0 AND c.link_id <> a.link_id;	

UPDATE master_base_history a,migrate_xmyh.hmaster1 b,tmp_link_id2 c ,up_map_accnt d SET a.link_id = c.link_id
	WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.sc_flag = b.accnt AND a.id = d.accnt_new AND d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.accnt_type = 'hmaster' AND b.pcrec = c.pcrec
	AND a.link_id <> c.link_id AND c.link_id <> 0;	

-- 2
SELECT * FROM tmp_link_id1 WHERE link_id = 0;

SELECT a.id,a.sc_flag,a.link_id,b.accnt,b.pcrec,c.pcrec,c.link_id,c.link_id2 FROM  master_base_history a,migrate_xmyh.master b,tmp_link_id1 c ,up_map_accnt d
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.sc_flag = b.accnt AND a.id = d.accnt_new AND d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.accnt_type IN('master_si','master_r') AND b.pcrec = c.pcrec
AND a.link_id = c.link_id AND c.link_id = 0;	
-- 更新1
UPDATE master_base_history a,migrate_xmyh.master b,tmp_link_id1 c ,up_map_accnt d SET a.link_id = c.link_id2
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.sc_flag = b.accnt AND a.id = d.accnt_new AND d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.accnt_type IN('master_si','master_r') AND b.pcrec = c.pcrec
AND a.link_id = c.link_id AND c.link_id = 0;	


SELECT a.id,a.sc_flag,a.link_id,b.accnt,b.pcrec,c.pcrec,c.link_id,c.link_id2 FROM  master_base a,migrate_xmyh.master b,tmp_link_id1 c ,up_map_accnt d
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.sc_flag = b.accnt AND a.id = d.accnt_new AND d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.accnt_type IN('master_si','master_r') AND b.pcrec = c.pcrec
AND a.link_id = c.link_id AND c.link_id = 0;	
-- 更新2
UPDATE  master_base a,migrate_xmyh.master b,tmp_link_id1 c ,up_map_accnt d SET a.link_id = c.link_id2
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.sc_flag = b.accnt AND a.id = d.accnt_new AND d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.accnt_type IN('master_si','master_r') AND b.pcrec = c.pcrec
AND a.link_id = c.link_id AND c.link_id = 0;	

SELECT * FROM up_map_accnt WHERE hotel_group_id = 1 AND hotel_id = 1 AND accnt_new = 11969;
SELECT * FROM migrate_xmyh.master WHERE accnt = 'F307020121';
SELECT * FROM migrate_xmyh.hmaster1 WHERE pcrec = 'F409120158';
SELECT * FROM master_base_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND id = 11969;
SELECT * FROM master_base_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND link_id = -347420;

SELECT * FROM migrate_xmyh.master WHERE pcrec = 'F409120158';
SELECT * FROM migrate_xmyh.hmaster1 WHERE pcrec = 'F409120158';


UPDATE master_base_history a,migrate_xmyh.hmaster1 b,tmp_link_id1 c ,up_map_accnt d SET a.link_id = c.link_id
	WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.sc_flag = b.accnt AND a.id = d.accnt_new AND d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.accnt_type = 'hmaster' AND b.pcrec = c.pcrec
	AND a.link_id <> c.link_id AND c.link_id <> 0;	

SELECT a.accnt,a.sta,a.type,a.roomno,a.pcrec,a.master,b.accnt,b.pcrec,b.roomno,c.sta,c.rmno,c.link_id,d.id,d.link_id
FROM migrate_xmyh.master a,master_base c,migrate_xmyh.hmaster1 b,master_base_history d,up_map_accnt e WHERE a.pcrec = b.accnt AND a.pcrec <> ''
AND a.sta NOT IN('X','N','D') AND a.accnt = c.sc_flag AND c.hotel_group_id = 1 AND c.hotel_id = 1
AND  d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.id = e.accnt_new AND e.hotel_group_id = 1 AND e.hotel_id = 1
AND e.accnt_type = 'hmaster' AND e.accnt_old = b.accnt AND a.accnt NOT IN
(SELECT a.accnt FROM migrate_xmyh.master a,migrate_xmyh.hmaster1 b  WHERE a.pcrec = b.accnt AND
a.sta NOT IN('X','N','D') AND a.pcrec <> '');

SELECT a.accnt,a.roomno,a.sta,a.pcrec FROM  migrate_xmyh.master a,migrate_xmyh.hmaster1 b  WHERE a.pcrec = b.accnt AND
a.sta NOT IN('X','N','D') AND a.pcrec <> '' AND a.accnt NOT IN(SELECT a.accnt
FROM migrate_xmyh.master a,master_base c,migrate_xmyh.hmaster1 b,master_base_history d,up_map_accnt e WHERE a.pcrec = b.accnt AND a.pcrec <> ''
AND a.sta NOT IN('X','N','D') AND a.accnt = c.sc_flag AND c.hotel_group_id = 1 AND c.hotel_id = 1
AND  d.hotel_group_id = 1 AND d.hotel_id = 1 AND d.id = e.accnt_new AND e.hotel_group_id = 1 AND e.hotel_id = 1
AND e.accnt_type = 'hmaster' AND e.accnt_old = b.accnt )
 