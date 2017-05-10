-- 01迁移客人投诉记录
DELETE FROM profile_complaint WHERE hotel_group_id = 1 AND hotel_id = 1;
INSERT INTO profile_complaint(hotel_group_id,hotel_id,sta,guest_id,guest_name,company_id,company_name, 
	cpl_tag,cpl_date,cpl_item,cpl_remark,salesman,deal_man,deal_date,deal_remark,is_alert,compaint_level,create_user,create_datetime,modify_user,modify_datetime
	)
SELECT  1,1,'I',b.accnt_new,c.name,NULL,NULL, 
	a.tag,a.date,a.item,TRIM(a.ref),a.saleid,NULL,NULL,NULL,'T',NULL,a.cby,a.changed,a.cby,a.changed
FROM migrate_xmyh.guest_cpl a,up_map_accnt b,guest_base c WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND (b.accnt_type = 'GUEST_FIT')
AND b.accnt_old = a.no AND c.hotel_group_id = 1 AND c.id = b.accnt_new AND a.no <> '' ;
-- 更新标记
UPDATE guest_type a,profile_complaint b SET a.extra_flag = CONCAT(SUBSTRING(a.extra_flag,1,3),'1',SUBSTRING(a.extra_flag,5,26))
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.guest_id = b.guest_id AND b.hotel_group_id = 1 AND b.hotel_id = 1;
-- 迁移协议单位投诉记录
INSERT INTO profile_complaint(hotel_group_id,hotel_id,sta,guest_id,guest_name,company_id,company_name, 
	cpl_tag,cpl_date,cpl_item,cpl_remark,salesman,deal_man,deal_date,deal_remark,is_alert,compaint_level,create_user,create_datetime,modify_user,modify_datetime
	)
SELECT  1,1,'I',NULL,NULL,b.accnt_new,c.name,
	a.tag,a.changed,a.item,a.ref,a.saleid,NULL,NULL,NULL,'T',NULL,a.cby,a.changed,a.cby,a.changed
FROM migrate_xmyh.guest_cpl a,up_map_accnt b,company_base c WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND (b.accnt_type = 'COMPANY')
AND b.accnt_old = a.cusno AND c.hotel_group_id = 1 AND c.id = b.accnt_new AND a.no = '' AND a.cusno <> '' ;
UPDATE company_type a,profile_complaint b SET a.extra_flag = CONCAT(SUBSTRING(a.extra_flag,1,3),'1',SUBSTRING(a.extra_flag,5,26))
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.company_id = b.guest_id AND b.hotel_group_id = 1 AND b.hotel_id = 1;


SELECT * FROM profile_complaint WHERE guest_id IN('429','38790');

SELECT * FROM profile_complaint a,up_map_code b WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code = 'gc_cpl' AND b.code_old = a.cpl_item;
-- 更新投诉类别新代码
UPDATE  profile_complaint a,up_map_code b SET a.cpl_item = b.code_new
WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code = 'gc_cpl' AND b.code_old = a.cpl_item;

-- 迁移客人持卡
SELECT * FROM profile_card WHERE hotel_group_id = 1 AND hotel_id = 1 AND master_id = 503
OR master_id = 504;
SELECT * FROM migrate_xmyh.guest_card;
DELETE FROM profile_card WHERE hotel_group_id = 1 AND hotel_id = 1;
INSERT INTO profile_card (hotel_group_id, hotel_id, master_type, master_id, card_type, card_no, 
	date_begin, date_end, remark, is_master, is_halt, create_user, create_datetime, modify_user, modify_datetime)
SELECT 1, 1,'F', b.accnt_new,a.cardcode,a.cardno,
	DATE_ADD(NOW(),INTERVAL -10 YEAR),a.expiry_date,'','F', a.halt, a.cby, a.changed, a.cby, a.changed
	FROM migrate_xmyh.guest_card a,up_map_accnt b 
	WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND (b.accnt_type = 'GUEST_FIT' OR b.accnt_type = 'GUEST_GRP')
	AND b.accnt_old = a.no AND a.cardcode NOT IN('JL1','JL3','JL4','JL5') GROUP BY cardno HAVING COUNT(1) >=1;
   UPDATE profile_card SET card_type = 'bankCard' WHERE hotel_group_id = 1 AND hotel_id = 1;
-- UPDATE profile_card a,up_map_code b SET a.card_type = b.code_new WHERE a.hotel_group_id=1 AND a.hotel_id=1 AND b.hotel_group_id=1 AND b.hotel_id=1 AND b.code = 'paymth' AND b.code_old = a.card_type;
SELECT * FROM profile_card WHERE hotel_group_id = 1 AND hotel_id = 1;
 -- 更新标记
UPDATE guest_type a,profile_card b SET a.extra_flag = CONCAT(SUBSTRING(a.extra_flag,1,4),'1',SUBSTRING(a.extra_flag,6,25))
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.guest_id = b.master_id AND b.hotel_group_id = 1 AND b.hotel_id = 1;

-- 签订单人信息

DELETE FROM  guest_relation WHERE hotel_group_id = 1 AND hotel_id = 1 AND relation_code = 'GUEST_COMPANY';
INSERT INTO guest_relation(hotel_group_id,hotel_id,host_id,host_name,slave_id,slave_name,tag1,tag2,
	tag3,tag4,tag5,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime,relation_code)
	SELECT 1,1,e.id,e.name,b.accnt_new,d.name,a.tag1,a.tag2,
	a.tag3,a.tag4,a.tag5,'F',0,a.cby,a.changed,a.cby,a.changed,'GUEST_COMPANY'
	FROM migrate_xmyh.argst a,up_map_accnt b,company_base d,up_map_accnt c,guest_base e
		WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.accnt_type = 'COMPANY' AND b.accnt_old = a.accnt
		AND b.accnt_new = d.id 	AND c.accnt_old = a.no AND c.accnt_type = 'GUEST_FIT' AND c.hotel_group_id = 1 AND c.hotel_id = 1
		AND c.accnt_new = e.id;
SELECT a.company_id,a.extra_flag FROM company_type a,guest_relation b  WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.company_id = b.slave_id
AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.relation_code = 'GUEST_COMPANY';

UPDATE company_type a,guest_relation b SET a.extra_flag = CONCAT(SUBSTRING(a.extra_flag,1,8),'1',SUBSTRING(a.extra_flag,9,21))
	WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.company_id = b.slave_id
	AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.relation_code = 'GUEST_COMPANY';
SELECT * FROM guest_relation WHERE hotel_group_id = 1 AND hotel_id = 1 AND relation_code = 'GUEST_COMPANY';
SELECT * FROM company_type WHERE company_id = 39423;
SELECT LENGTH(extra_flag) FROM company_type WHERE company_id = 40719;

SELECT * FROM up_map_accnt WHERE hotel_id = 1 AND accnt_new = 41031;

CALL up_fill_company_profile_extra(1,1)
 