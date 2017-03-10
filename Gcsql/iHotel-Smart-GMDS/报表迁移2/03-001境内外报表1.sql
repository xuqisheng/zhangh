-- 境内统计报表 前期检查
SELECT * FROM portal_pms.guest_sta_inland WHERE hotel_group_id = 2 AND hotel_id = 13;
SELECT * FROM portal_pms.guest_sta_inland_history WHERE hotel_group_id = 2 AND hotel_id = 13;
-- 清空当前日期数据
DELETE FROM portal_pms.guest_sta_inland WHERE hotel_group_id = 2 AND hotel_id = 13  ;	
DELETE FROM portal_pms.guest_sta_inland_history WHERE hotel_group_id = 2 AND hotel_id = 13;
-- 绿云正式开始导入
INSERT INTO portal_pms.guest_sta_inland (hotel_group_id,hotel_id,DATE,guest_class,where_from,descript,descript1,
	list_order,dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
SELECT 2,13,DATE,gclass,wfrom,descript,'','',dtc,dgc,dmc ,dtt,dgt,dmt ,mtc,mgc,mmc ,mtt,mgt,mmt ,ytc,ygc,ymc ,ytt,ygt,ymt
		FROM migrate_db.gststa1 WHERE  gclass<>'52';
-- 修复绿云表
UPDATE portal_pms.guest_sta_inland SET guest_class = '40' WHERE hotel_group_id = 2 AND hotel_id = 13 AND guest_class = '41' ; 
UPDATE portal_pms.guest_sta_inland SET guest_class = '50' WHERE hotel_group_id = 2 AND hotel_id = 13 AND guest_class = '51' ;

-- 省内的描述为空的要更新
UPDATE guest_sta_inland a,code_division b SET a.descript = b.descript
WHERE a.hotel_group_id = 2 AND a.hotel_id = 13
 AND a.guest_class = '40' AND a.where_from = b.code AND b.hotel_group_id = 2 AND b.hotel_id = 13 AND b.country = 'CN' AND b.province = 'FU'
AND a.descript = '';

SELECT * FROM code_division WHERE hotel_id = 13 AND descript LIKE '%厦门%';

INSERT INTO portal_pms.guest_sta_inland_history(id,hotel_group_id,hotel_id,DATE,guest_class,where_from,descript,descript1,list_order,
	dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
SELECT id,hotel_group_id,hotel_id,DATE,guest_class,where_from,descript,descript1,list_order,
	dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt
FROM portal_pms.guest_sta_inland WHERE hotel_group_id = 2 AND hotel_id = 13 ;
 
--
SELECT  COUNT(1) FROM portal_pms.guest_sta_inland WHERE hotel_group_id = 2 AND hotel_id = 13;
SELECT COUNT(1) FROM portal_pms.guest_sta_inland_history WHERE hotel_group_id = 2 AND hotel_id = 13;

-- 删除当前表
DELETE FROM portal_pms.guest_sta_inland WHERE hotel_group_id = 2 AND hotel_id = 13 AND DATE <'2015-11-04' ;
 




-- 境外统计报表,前期检查

SELECT * FROM portal_pms.guest_sta_overseas WHERE hotel_group_id = 2 AND hotel_id = 13;
SELECT * FROM portal_pms.guest_sta_overseas_history WHERE hotel_group_id = 2 AND hotel_id = 13;
-- 清空数据准备
DELETE FROM portal_pms.guest_sta_overseas WHERE hotel_group_id = 2 AND hotel_id = 13 ;	
DELETE FROM portal_pms.guest_sta_overseas_history WHERE hotel_group_id = 2 AND hotel_id = 13 ;
-- 导入绿云当前境外报表
INSERT INTO portal_pms.guest_sta_overseas(hotel_group_id,hotel_id,DATE,guest_class,nation,list_order,descript,descript1,
	sequence,dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)	
SELECT 2,13,DATE,gclass,nation,order_,descript,'','',dtc,dgc,dmc ,dtt,dgt,dmt ,mtc,mgc,mmc ,mtt,mgt,mmt ,ytc,ygc,ymc ,ytt,ygt,ymt
		FROM migrate_db.gststa ;	

-- UPDATE guest_sta_overseas a,up_map_code b SET a.nation = b.code_new WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id 
-- 	AND a.hotel_group_id = 2 AND a.hotel_id = 13 AND b.cat = 'nation' AND b.code_old = a.nation; 

-- 修复国籍
SELECT * FROM guest_sta_overseas a,up_map_code b
WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id 
AND a.hotel_group_id = 2 AND a.hotel_id = 13 AND a.date >='2013.01.01'   AND b.code = 'country' AND b.code_old = a.nation; 

UPDATE guest_sta_overseas a,up_map_code b SET a.nation = b.code_new WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id 
AND a.hotel_group_id = 2 AND a.hotel_id = 13 AND a.date >='2013.01.01'   AND b.code = 'country' AND b.code_old = a.nation; 


-- 修复绿云当前境外报表
UPDATE portal_pms.guest_sta_overseas a SET guest_class = '3' WHERE hotel_group_id = 2 AND hotel_id = 13 AND guest_class ='4';
-- 修复显示境内的问题，把省外guest_class改成2
UPDATE portal_pms.guest_sta_overseas a SET guest_class = '2',list_order = '02' WHERE hotel_group_id = 2 AND hotel_id = 13 AND guest_class ='3' AND descript = '省  外';
SELECT * FROM guest_sta_overseas WHERE hotel_group_id = 2 AND hotel_id = 13 AND descript = '省  内';
UPDATE guest_sta_overseas SET list_order = '01'  WHERE hotel_group_id = 2 AND hotel_id = 13 AND descript = '省  内';
SELECT * FROM guest_sta_overseas WHERE hotel_group_id = 2 AND hotel_id = 13 AND DATE = '2015.09.26' ORDER BY guest_class,list_order;
UPDATE guest_sta_overseas SET descript = '境  内' WHERE hotel_group_id = 2 AND hotel_id = 13 AND descript = '境内';

-- 解决境外报表中的境内不显示的问题，嘎子提供
INSERT INTO portal_pms.guest_sta_overseas
	(
	hotel_group_id, 
	hotel_id, 
	DATE, 
	guest_class, 
	nation, 
	list_order, 
	descript, 
	descript1, 
	sequence, 
	dtc, 
	dgc, 
	dmc, 
	dtt, 
	dgt, 
	dmt, 
	mtc, 
	mgc, 
	mmc, 
	mtt, 
	mgt, 
	mmt, 
	ytc, 
	ygc, 
	ymc, 
	ytt, 
	ygt, 
	ymt
	)
SELECT   
	hotel_group_id, 
	hotel_id, 
	DATE, 
	guest_class, 
	nation, 
	'', 
	'---境内---', 
	'---境内---', 
	sequence, 
	SUM(dtc), 
	SUM(dgc), 
	SUM(dmc), 
	SUM(dtt), 
	SUM(dgt), 
	SUM(dmt), 
	SUM(mtc), 
	SUM(mgc), 
	SUM(mmc), 
	SUM(mtt), 
	SUM(mgt), 
	SUM(mmt), 
	SUM(ytc), 
	SUM(ygc), 
	SUM(ymc), 
	SUM(ytt), 
	SUM(ygt), 
	SUM(ymt)
	FROM portal_pms.guest_sta_overseas WHERE hotel_id = 13  AND guest_class = '2' GROUP BY DATE;
	

INSERT INTO portal_pms.guest_sta_overseas_history(id,hotel_group_id,hotel_id,DATE,guest_class,nation,list_order,descript,descript1,sequence,
	dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
SELECT id,hotel_group_id,hotel_id,DATE,guest_class,nation,list_order,descript,descript1,sequence,
	dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt
FROM portal_pms.guest_sta_overseas WHERE hotel_group_id = 2 AND hotel_id = 13;

--
SELECT  COUNT(1) FROM portal_pms.guest_sta_overseas WHERE hotel_group_id = 2 AND hotel_id = 13;
SELECT COUNT(1) FROM portal_pms.guest_sta_overseas_history WHERE hotel_group_id = 2 AND hotel_id = 13;


-- 删除历史记录保留当天
DELETE   FROM portal_pms.guest_sta_overseas WHERE hotel_group_id = 2 AND hotel_id = 13 AND DATE <'2015-11-04' ;
 


