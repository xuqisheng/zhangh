-- 境内历史表迁移 
INSERT INTO guest_sta_inland (hotel_group_id,hotel_id,DATE,guest_class,where_from,descript,descript1,
	list_order,dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
SELECT 1,1,DATE,gclass,wfrom,descript,'','',dtc,dgc,0 ,dtt,dgt,0 ,mtc,mgc,0 ,mtt,mgt,0 ,ytc,ygc,0 ,ytt,ygt,0
		FROM migrate_xmyh.ygststa1 WHERE DATE >='2013.01.01' AND DATE <= '2014-10-24';	
UPDATE guest_sta_inland SET guest_class = '40' WHERE hotel_group_id = 1 AND hotel_id = 1 AND DATE >='2013.01.01' AND DATE <='2014-10-24' AND guest_class = '41'; 
UPDATE guest_sta_inland SET guest_class = '50' WHERE hotel_group_id = 1 AND hotel_id = 1 AND DATE >='2013.01.01' AND DATE <='2014-10-24' AND guest_class = '51';

INSERT INTO guest_sta_inland_history(id,hotel_group_id,hotel_id,DATE,guest_class,where_from,descript,descript1,list_order,
	dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
SELECT id,hotel_group_id,hotel_id,DATE,guest_class,where_from,descript,descript1,list_order,
	dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt
FROM guest_sta_inland WHERE hotel_group_id = 1 AND hotel_id = 1 AND DATE >='2013.01.01' AND DATE <='2014-10-24';

DELETE FROM guest_sta_inland WHERE hotel_group_id = 1 AND hotel_id = 1 AND DATE >='2013.01.01' AND DATE <'2014-10-24';

SELECT DISTINCT DATE FROM guest_sta_inland WHERE hotel_group_id = 1 AND hotel_id = 1;
-- 境外历史表迁移
DELETE FROM guest_sta_overseas WHERE hotel_group_id = 1 AND hotel_id = 1;
SELECT MAX(DATE) FROM migrate_xmyh.ygststa;
SELECT * FROM guest_sta_overseas WHERE hotel_group_id = 1 AND hotel_id = 1;
SELECT DISTINCT DATE FROM guest_sta_overseas WHERE hotel_group_id = 1 AND hotel_id = 1;	
SELECT DISTINCT DATE FROM guest_sta_overseas_history WHERE hotel_group_id = 1 AND hotel_id = 1;
INSERT INTO guest_sta_overseas(hotel_group_id,hotel_id,DATE,guest_class,nation,list_order,descript,descript1,
	sequence,dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)	
SELECT 1,1,DATE,gclass,nation,order_,descript,'','',dtc,dgc,0 ,dtt,dgt,0 ,mtc,mgc,0 ,mtt,mgt,0 ,ytc,ygc,0 ,ytt,ygt,0
		FROM migrate_xmyh.ygststa WHERE   DATE >='2013.01.01' AND DATE <= '2014-10-24';
		
-- UPDATE guest_sta_overseas a,up_map_code b SET a.nation = b.code_new WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id 
-- 	AND a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.date >='2013.01.01' AND  a.date < '2014.04.20' AND b.cat = 'nation' AND b.code_old = a.nation; 
-- 
UPDATE guest_sta_overseas a SET guest_class = '3' WHERE hotel_group_id = 1 AND hotel_id = 1 AND  DATE >='2013.01.01' AND DATE <= '2014-10-24' AND guest_class ='4';
INSERT INTO guest_sta_overseas_history(id,hotel_group_id,hotel_id,DATE,guest_class,nation,list_order,descript,descript1,sequence,
	dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
SELECT id,hotel_group_id,hotel_id,DATE,guest_class,nation,list_order,descript,descript1,sequence,
	dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt
FROM guest_sta_overseas WHERE hotel_group_id = 1 AND hotel_id = 1 AND  DATE >='2013.01.01' AND DATE <'2014-10-23';

INSERT INTO guest_sta_overseas_history(id,hotel_group_id,hotel_id,DATE,guest_class,nation,list_order,descript,descript1,sequence,
	dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
SELECT id,hotel_group_id,hotel_id,DATE,guest_class,nation,list_order,descript,descript1,sequence,
	dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt
FROM guest_sta_overseas WHERE hotel_group_id = 1 AND hotel_id = 1 AND  DATE >='2014.10.24';
DELETE FROM guest_sta_overseas WHERE hotel_group_id = 1 AND hotel_id = 1 AND  DATE >='2013.01.01' AND DATE <='2014-10-23';
SELECT DISTINCT DATE FROM guest_sta_overseas WHERE hotel_group_id = 1 AND hotel_id = 1;
SELECT DISTINCT DATE FROM guest_sta_inland WHERE hotel_group_id = 1 AND hotel_id = 1;