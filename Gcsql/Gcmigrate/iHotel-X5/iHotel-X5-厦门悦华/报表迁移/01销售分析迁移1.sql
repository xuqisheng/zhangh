DELETE FROM rep_revenue_type WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07';
 
ALTER TABLE migrate_xmyh.ymktsummaryrep ADD code_category VARCHAR(30) AFTER CODE;
ALTER TABLE migrate_xmyh.ymktsummaryrep ADD code1 VARCHAR(15) AFTER CODE;
-- 房价码
-- select a.code,b.code_old,b.code_old_des ,b.code_new from migrate_xmyh.ymktsummaryrep a,up_map_code b where a.class = 'r' and b.hotel_group_id = 1 and b.hotel_id = 1
-- and b.code = 'ratecode' and   a.code = b.code_old;
-- /*
UPDATE migrate_xmyh.ymktsummaryrep a,up_map_code b SET a.code1 = b.code_new
WHERE a.class = 'R' AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.code = 'ratecode' AND   a.code = b.code_old;
*/
SELECT * FROM migrate_xmyh.ymktsummaryrep WHERE class = 'R' AND code1 IS NULL;

UPDATE migrate_xmyh.ymktsummaryrep a  SET a.code1 = a.code
WHERE a.class = 'R' AND a.code1 IS NULL;
-- 市场码
SELECT a.code,b.code_old,b.code_old_des,b.code_new  FROM migrate_xmyh.ymktsummaryrep a,up_map_code b WHERE a.class = 'M' AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.code = 'mktcode' AND   a.code = b.code_old; 
UPDATE migrate_xmyh.ymktsummaryrep a,up_map_code b SET a.code1 = b.code_new
WHERE a.class = 'M' AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.code = 'mktcode' AND   a.code = b.code_old;
-- 检查是否有未对照的
SELECT * FROM migrate_xmyh.ymktsummaryrep  WHERE DATE >= '2013.01.01' AND  class = 'M' AND code1 IS NULL;
-- 更新市场码
UPDATE migrate_xmyh.ymktsummaryrep a,code_base b,code_base c SET a.code_category = b.descript 
WHERE b.hotel_group_id = c.hotel_group_id AND b.hotel_id = c.hotel_id AND b.parent_code = 'market_category' 
AND c.hotel_group_id = 1 AND c.hotel_id = 1 AND c.parent_code = 'market_code' 
AND c.code_category = b.code AND a.code1 = c.code AND a.class='M';
-- 更新房价码
UPDATE migrate_xmyh.ymktsummaryrep a,code_ratecode b SET a.code_category = b.descript 
WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 
AND a.code = b.code AND a.class='R';	
UPDATE migrate_xmyh.ymktsummaryrep a,code_ratecode b SET a.code_category = b.descript 
WHERE b.hotel_group_id = 1 AND b.hotel_id = 1
AND a.code1 = b.code AND a.class='R';			

-- 来源码
SELECT a.code,b.code_old,b.code_old_des,b.code_new  FROM migrate_xmyh.ymktsummaryrep a,up_map_code b WHERE a.class = 'S' AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.code = 'srccode' AND   a.code = b.code_old; 
-- 更新来源码
UPDATE migrate_xmyh.ymktsummaryrep a,up_map_code b SET a.code1 = b.code_new
WHERE a.class = 'S' AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.code = 'srccode' AND   a.code = b.code_old;

UPDATE migrate_xmyh.ymktsummaryrep a,code_base b,code_base c SET a.code_category = b.descript 
WHERE b.hotel_group_id = c.hotel_group_id AND b.hotel_id = c.hotel_id AND b.parent_code = 'src_cat' 
AND c.hotel_group_id = 1 AND c.hotel_id = 1 AND c.parent_code = 'src_code' 
AND c.code_category = b.code AND a.code1 = c.code AND a.class='S';

SELECT * FROM migrate_xmyh.ymktsummaryrep  WHERE DATE = '2013.01.01' AND  class = 'S' AND code1 IS NULL;
-- 渠道
SELECT a.code,b.code_old,b.code_old_des,b.code_new  FROM migrate_xmyh.ymktsummaryrep a,up_map_code b WHERE a.class = 'C' AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.code = 'channel' AND   a.code = b.code_old; 

UPDATE migrate_xmyh.ymktsummaryrep a,up_map_code b SET a.code1 = b.code_new
WHERE a.class = 'C' AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.code = 'channel' AND   a.code = b.code_old;

UPDATE migrate_xmyh.ymktsummaryrep a,code_base b,code_base c SET a.code_category = b.descript 
WHERE b.hotel_group_id = c.hotel_group_id AND b.hotel_id = c.hotel_id AND b.parent_code = 'channel' 
AND c.hotel_group_id = 1 AND c.hotel_id = 1 AND c.parent_code = 'channel_cat' 
AND c.code_category = b.code AND a.code1 = c.code AND a.class='C';

DELETE FROM rep_revenue_type WHERE hotel_group_id = 1 AND hotel_id = 1;

SELECT * FROM migrate_xmyh.ymktsummaryrep WHERE code1 IS NULL;
SELECT * FROM migrate_xmyh.ymktsummaryrep WHERE class IS NULL;
SELECT MAX(DATE) FROM migrate_xmyh.ymktsummaryrep;
SELECT * FROM migrate_xmyh.ymktsummaryrep WHERE DATE = '2014.12.7';

SELECT * FROM rep_revenue_type WHERE hotel_group_id = 1 AND hotel_id = 1;
SELECT * FROM rep_revenue_market WHERE hotel_group_id = 1 AND hotel_id = 1;
DELETE FROM rep_revenue_type_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date <='2014.12.7';
DELETE FROM rep_revenue_market_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date <='2014.12.7';

-- 插入当前表
INSERT INTO rep_revenue_type(hotel_group_id,hotel_id,biz_date,code_type,code_category,CODE,rev_total,rev_rm,rev_rm_srv,rev_rm_pkg,rooms_total,people_total,rooms_arr,rooms_dep,rooms_noshow,rooms_cxl,people_arr,people_dep)
SELECT  1,1,DATE,'MARKET',code_category,code1,SUM(tincome),SUM(rincome),SUM(rsvc),SUM(rpak),SUM(rquan),SUM(pquan),SUM(rarr),SUM(rdep),SUM(noshow),SUM(cxl),SUM(parr),SUM(pdep)
FROM migrate_xmyh.ymktsummaryrep WHERE DATE >= '2013-01-01' AND class='M' AND NOT (grp='z' AND CODE='zzz') GROUP BY DATE,class,code1
UNION ALL
SELECT  1,1,DATE,'RATECODE',code_category,code1,SUM(tincome),SUM(rincome),SUM(rsvc),SUM(rpak),SUM(rquan),SUM(pquan),SUM(rarr),SUM(rdep),SUM(noshow),SUM(cxl),SUM(parr),SUM(pdep)
FROM migrate_xmyh.ymktsummaryrep WHERE DATE >= '2013.01.01' AND class='R' AND NOT (grp='z' AND CODE='zzz') GROUP BY DATE,class,code1
UNION ALL
SELECT  1,1,DATE,'SOURCE',code_category,code1,SUM(tincome),SUM(rincome),SUM(rsvc),SUM(rpak),SUM(rquan),SUM(pquan),SUM(rarr),SUM(rdep),SUM(noshow),SUM(cxl),SUM(parr),SUM(pdep)
FROM migrate_xmyh.ymktsummaryrep WHERE DATE >= '2013.01.01' AND class='S' AND NOT (grp='z' AND CODE='zzz') GROUP BY DATE,class,code1
UNION ALL
SELECT  1,1,DATE,'CHANNEL',code_category,code1,SUM(tincome),SUM(rincome),SUM(rsvc),SUM(rpak),SUM(rquan),SUM(pquan),SUM(rarr),SUM(rdep),SUM(noshow),SUM(cxl),SUM(parr),SUM(pdep)
FROM migrate_xmyh.ymktsummaryrep WHERE DATE >= '2013.01.01' AND class='C' AND NOT (grp='z' AND CODE='zzz') GROUP BY DATE,class,code1;

SELECT * FROM rep_revenue_type WHERE hotel_group_id = 1 AND hotel_id = 1;
SELECT MAX(biz_date) FROM rep_revenue_type WHERE hotel_group_id = 1 AND hotel_id = 1;

SELECT * FROM rep_revenue_type WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07'
AND code_type = 'CHANNEL';

SELECT * FROM rep_revenue_type WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07'
AND code_type = 'MARKET' ORDER BY CODE;

SELECT DISTINCT biz_date FROM  rep_revenue_type_history WHERE hotel_group_id = 1 AND hotel_id = 1 
DELETE FROM rep_revenue_type_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07';

INSERT INTO `rep_revenue_type_history` 
	(`hotel_group_id`, 
	`hotel_id`, 
	`id`, 
	`biz_date`, 
	`code_type`, 
	`code_category`, 
	`code`, 
	`rev_total`, 
	`rev_rm`, 
	`rev_rm_srv`, 
	`rev_rm_pkg`, 
	`rev_fb`, 
	`rev_mt`, 
	`rev_en`, 
	`rev_sp`, 
	`rev_ot`, 
	`rooms_total`, 
	`rooms_arr`, 
	`rooms_dep`, 
	`rooms_noshow`, 
	`rooms_cxl`, 
	`people_total`, 
	`people_arr`, 
	`people_dep`
	)
SELECT hotel_group_id, 
	hotel_id, 
	id, 
	biz_date, 
	code_type, 
	code_category, 
	CODE, 
	rev_total, 
	rev_rm, 
	rev_rm_srv, 
	rev_rm_pkg, 
	rev_fb, 
	rev_mt, 
	rev_en, 
	rev_sp, 
	rev_ot, 
	rooms_total, 
	rooms_arr, 
	rooms_dep, 
	rooms_noshow, 
	rooms_cxl, 
	people_total, 
	people_arr, 
	people_dep
FROM rep_revenue_type WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date >= '2013.1.1' AND biz_date <='2014.12.7';

DELETE FROM rep_revenue_type WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date <= '2014.12.07';
SELECT * FROM rep_revenue_type WHERE hotel_group_id = 1 AND hotel_id = 1 ;
SELECT DISTINCT biz_date FROM rep_revenue_type WHERE hotel_group_id = 1 AND hotel_id = 1 ;

SELECT * FROM rep_revenue_type_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date <= '2014.11.25';