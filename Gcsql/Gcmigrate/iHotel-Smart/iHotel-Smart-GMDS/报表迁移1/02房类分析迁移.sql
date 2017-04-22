SELECT * FROM rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 1;
SELECT * FROM migrate_xmyh.yyrmsalerep_new ;
SELECT * FROM migrate_xmyh.yrmsalerep_new WHERE gkey = 'f';
SELECT * FROM migrate_xmyh.yrmsalerep_new WHERE gkey = 'h';
SELECT * FROM migrate_xmyh.yrmsalerep_new WHERE gkey = 't';
SELECT * FROM rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 1 AND rep_type = 'F';
SELECT * FROM rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 1 AND rep_type = 'B';
SELECT * FROM rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 1 AND rep_type = 'T';

UPDATE migrate_xmyh.yrmsalerep_new a,portal.up_map_code b SET a.hall = b.code_new 
WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code = 'building' AND b.code_old = a.hall;

UPDATE migrate_xmyh.yrmsalerep_new a,portal.up_map_code b SET a.code = b.code_new 
WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code = 'building' AND b.code_old = a.code AND a.gkey = 'h';
 
INSERT INTO rep_rmsale(hotel_group_id,hotel_id,biz_date,rep_type,building,CODE,descript,descript_en,
	rooms_total,rooms_ooo,rooms_os,rooms_hse,rooms_avl,rooms_vac,sold_fit,sold_grp,sold_long,sold_ent,sold_added,
	rev_fit,rev_grp,rev_long,people_fit,people_grp,people_long)
SELECT 1,1,DATE,gkey,hall,CODE,descript,descript,
	SUM(ttl),SUM(mnt),0,SUM(htl),SUM(avl),SUM(vac),SUM(soldf),SUM(soldg+soldc),SUM(soldl),SUM(ent),SUM(ext),
	SUM(incomef),SUM(incomeg+incomec),SUM(incomel),SUM(gstf),SUM(gstg+gstc),SUM(gstl)
FROM migrate_xmyh.yrmsalerep_new WHERE DATE >= '2013-01-01' AND CODE NOT LIKE '%{{{%' GROUP BY DATE,gkey,hall,CODE;

UPDATE rep_rmsale SET rep_type = 'B' WHERE hotel_group_id = 1 AND hotel_id = 1 AND rep_type ='h';
UPDATE rep_rmsale SET rep_type = 'F' WHERE hotel_group_id = 1 AND hotel_id = 1 AND rep_type ='f';
UPDATE rep_rmsale SET rep_type = 'T' WHERE hotel_group_id = 1 AND hotel_id = 1 AND rep_type ='t';
UPDATE rep_rmsale SET CODE = LTRIM(CODE) WHERE hotel_group_id = 1 AND hotel_id = 1;
-- delete FROM rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.05.15' and rep_type = 'F' ;
-- delete FROM rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.05.15' AND rep_type = 'B';
-- delete FROM rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.05.15' AND rep_type = 'T';
 
SELECT DISTINCT biz_date FROM rep_rmsale_history WHERE hotel_group_id = 1 AND hotel_id = 1;
DELETE FROM rep_rmsale_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date <='2014.04.20';
INSERT INTO rep_rmsale_history SELECT * FROM rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date <='2014.10.29';
DELETE FROM rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date < '2014.10.29';
SELECT DISTINCT biz_date FROM rep_rmsale WHERE hotel_group_id = 1 AND hotel_id = 1 

 