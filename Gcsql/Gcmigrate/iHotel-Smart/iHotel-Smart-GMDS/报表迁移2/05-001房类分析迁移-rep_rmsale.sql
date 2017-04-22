-- 注意楼栋字符大小

SELECT * FROM portal.rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 5;
SELECT * FROM migrate_xmhy.yrmsalerep_new GROUP BY hall ;
SELECT * FROM migrate_xmhy.yrmsalerep_new WHERE gkey = 'f';
SELECT * FROM migrate_xmhy.yrmsalerep_new WHERE gkey = 'h';
SELECT * FROM migrate_xmhy.yrmsalerep_new WHERE gkey = 't';
SELECT * FROM portal.rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 5 AND rep_type = 'F';
SELECT * FROM portal.rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 5 AND rep_type = 'B';
SELECT * FROM portal.rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 5 AND rep_type = 'T';
SELECT * FROM migrate_xmhy.yrmsalerep_new  WHERE DATE = '2015.11.04';
SELECT * FROM portal.up_map_code WHERE hotel_id = 5 AND CODE = 'building';
SELECT * FROM portal.code_base WHERE hotel_id = 5 AND parent_code = 'building';

-- 扩充先关字段 migrate_xmhy.yrmsalerep_new ,hall,CODE 字段
ALTER TABLE migrate_xmhy.yrmsalerep_new MODIFY COLUMN hall CHAR(10);
ALTER TABLE migrate_xmhy.yrmsalerep_new MODIFY COLUMN CODE CHAR(10);

SELECT * FROM migrate_xmhy.yrmsalerep_new WHERE DATE = '2015.11.04';

UPDATE migrate_xmhy.yrmsalerep_new a,portal.up_map_code b SET a.hall = b.code_new 
WHERE b.hotel_group_id = 1 AND b.hotel_id = 5 AND b.code = 'building' AND b.code_old = a.hall;


UPDATE migrate_xmhy.yrmsalerep_new a,portal.up_map_code b SET a.code = b.code_new 
WHERE b.hotel_group_id = 1 AND b.hotel_id = 5 AND b.code = 'building' AND b.code_old = a.code AND a.gkey = 'h';

-- 清空数据
SELECT * FROM portal.rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date<='2015.11.04';
SELECT * FROM  portal.rep_rmsale_history WHERE hotel_group_id = 1 AND hotel_id = 5  AND biz_date<='2015.11.04';

DELETE FROM  portal.rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date<='2015.11.04';
DELETE FROM  portal.rep_rmsale_history WHERE hotel_group_id = 1 AND hotel_id = 5  AND biz_date<='2015.11.04';

INSERT INTO portal.rep_rmsale(hotel_group_id,hotel_id,biz_date,rep_type,building,CODE,descript,descript_en,
	rooms_total,rooms_ooo,rooms_os,rooms_hse,rooms_avl,rooms_vac,sold_fit,sold_grp,sold_long,sold_ent,sold_added,
	rev_fit,rev_grp,rev_long,people_fit,people_grp,people_long)
SELECT 1,5,DATE,gkey,hall,CODE,descript,descript,
	SUM(ttl),SUM(mnt),0,SUM(htl),SUM(avl),SUM(vac),SUM(soldf),SUM(soldg+soldc),SUM(soldl),SUM(ent),SUM(ext),
	SUM(incomef),SUM(incomeg+incomec),SUM(incomel),SUM(gstf),SUM(gstg+gstc),SUM(gstl)
FROM migrate_xmhy.yrmsalerep_new WHERE DATE >= '2013-01-01' AND CODE NOT LIKE '%{{{%' GROUP BY DATE,gkey,hall,CODE;


UPDATE portal.rep_rmsale SET rep_type = 'B' WHERE hotel_group_id = 1 AND hotel_id = 5 AND rep_type ='h';
UPDATE portal.rep_rmsale SET rep_type = 'F' WHERE hotel_group_id = 1 AND hotel_id = 5 AND rep_type ='f';
UPDATE portal.rep_rmsale SET rep_type = 'T' WHERE hotel_group_id = 1 AND hotel_id = 5 AND rep_type ='t';
UPDATE portal.rep_rmsale SET CODE = LTRIM(CODE) WHERE hotel_group_id = 1 AND hotel_id = 5;
-- delete FROM rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date = '2014.05.15' and rep_type = 'F' ;
-- delete FROM rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date = '2014.05.15' AND rep_type = 'B';
-- delete FROM rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date = '2014.05.15' AND rep_type = 'T';
 
SELECT DISTINCT biz_date FROM portal.rep_rmsale_history WHERE hotel_group_id = 1 AND hotel_id = 5;

DELETE FROM portal.rep_rmsale_history WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date  <='2015.11.04';;

INSERT INTO portal.rep_rmsale_history SELECT * FROM portal.rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date <='2015.11.04';

-- 删除当前历史记录保留当天
DELETE FROM portal.rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date <='2015.11.04';

SELECT DISTINCT biz_date FROM portal.rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 5 ;

SELECT DISTINCT biz_date FROM portal.rep_rmsale_history WHERE hotel_group_id = 1 AND hotel_id = 5 ;

SELECT * FROM portal.rep_rmsale_history WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date ='2015.11.04';

SELECT * FROM rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 5 

SELECT rep_type,building,CODE,descript,rooms_vac,sold_fit,sold_grp,sold_long,sold_ent FROM rep_rmsale_history WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date >='2015.11.04';

