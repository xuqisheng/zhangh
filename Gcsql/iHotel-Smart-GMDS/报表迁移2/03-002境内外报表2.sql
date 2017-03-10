
-- 历史境内迁移
SELECT * FROM guest_sta_inland WHERE hotel_group_id = 1 AND hotel_id = 13
SELECT * FROM guest_sta_inland_history WHERE hotel_group_id = 1 AND hotel_id = 13  AND DATE <'2015-06-29';

INSERT INTO guest_sta_inland (hotel_group_id,hotel_id,DATE,guest_class,where_from,descript,descript1,
	list_order,dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
SELECT 1,13,DATE,gclass,wfrom,descript,'','',dtc,dgc,dmc ,dtt,dgt,dmt ,mtc,mgc,mmc ,mtt,mgt,mmt ,ytc,ygc,ymc ,ytt,ygt,ymt
		FROM migrate_bbyh.ygststa1 WHERE DATE <'2015-06-29';

-- select * from guest_sta_inland WHERE hotel_group_id = 1 AND hotel_id = 13 AND guest_class = '41' and date < '2015-06-29' ; 

UPDATE guest_sta_inland SET guest_class = '40' WHERE hotel_group_id = 1 AND hotel_id = 13 AND guest_class = '41'; 
UPDATE guest_sta_inland SET guest_class = '50' WHERE hotel_group_id = 1 AND hotel_id = 13 AND guest_class = '51';

INSERT INTO guest_sta_inland_history(id,hotel_group_id,hotel_id,DATE,guest_class,where_from,descript,descript1,list_order,
	dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
SELECT id,hotel_group_id,hotel_id,DATE,guest_class,where_from,descript,descript1,list_order,
	dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt
FROM guest_sta_inland WHERE hotel_group_id = 1 AND hotel_id = 13 AND DATE <'2015-06-29';
 
SELECT * FROM guest_sta_inland_history WHERE hotel_group_id = 1 AND hotel_id = 13 AND DATE <'2015-06-29'; 

DELETE FROM guest_sta_inland WHERE hotel_group_id = 1 AND hotel_id = 13 AND DATE <'2015-06-29';

SELECT DISTINCT DATE FROM guest_sta_inland WHERE hotel_group_id = 1 AND hotel_id = 13;
SELECT * FROM guest_sta_inland WHERE hotel_group_id = 1 AND hotel_id = 13 ORDER BY DATE,guest_class,list_order; 


-- 历史境外迁移
SELECT * FROM guest_sta_overseas WHERE hotel_group_id = 1 AND hotel_id = 13
SELECT * FROM guest_sta_overseas_history WHERE hotel_group_id = 1 AND hotel_id = 13  AND DATE <'2015-06-29';

INSERT INTO guest_sta_overseas(hotel_group_id,hotel_id,DATE,guest_class,nation,list_order,descript,descript1,
	sequence,dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)	
SELECT 1,13,DATE,gclass,nation,order_,descript,'','',dtc,dgc,dmc ,dtt,dgt,dmt ,mtc,mgc,mmc ,mtt,mgt,mmt ,ytc,ygc,ymc ,ytt,ygt,ymt
		FROM migrate_bbyh.ygststa WHERE DATE < '2015-06-29';
SELECT * FROM guest_sta_overseas WHERE hotel_group_id = 1 AND hotel_id = 13 AND guest_class ='4';

UPDATE guest_sta_overseas a SET guest_class = '3' WHERE hotel_group_id = 1 AND hotel_id = 13 AND guest_class ='4';

INSERT INTO guest_sta_overseas_history(id,hotel_group_id,hotel_id,DATE,guest_class,nation,list_order,descript,descript1,sequence,
	dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
SELECT id,hotel_group_id,hotel_id,DATE,guest_class,nation,list_order,descript,descript1,sequence,
	dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt
FROM guest_sta_overseas WHERE hotel_group_id = 1 AND hotel_id = 13 AND DATE < '2015-06-29';
 
DELETE FROM guest_sta_overseas WHERE hotel_group_id = 1 AND hotel_id = 13 AND DATE <'2015-06-29';

SELECT DISTINCT DATE FROM guest_sta_overseas WHERE hotel_group_id = 1 AND hotel_id = 13;
SELECT * FROM guest_sta_overseas WHERE hotel_group_id = 1 AND hotel_id = 13 ORDER BY DATE,guest_class,list_order; 