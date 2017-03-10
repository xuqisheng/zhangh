-- AR相关信息
SELECT * FROM guest_relation WHERE hotel_group_id = 1 AND hotel_id = 101 AND relation_code = 'GUEST_AR';
DELETE FROM  guest_relation WHERE hotel_group_id = 1 AND hotel_id = 101 AND relation_code = 'GUEST_AR';
INSERT INTO guest_relation(hotel_group_id,hotel_id,host_id,host_name,slave_id,slave_name,tag1,tag2,
	tag3,tag4,tag5,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime,relation_code)
SELECT 1,101,a.no,'',b.accnt_new,c.name,a.tag1,a.tag2,
	a.tag3,a.tag4,a.tag5,'F',0,a.cby,a.changed,a.cby,a.changed,'GUEST_AR'
	FROM migrate_ms.argst a,up_map_accnt b,ar_master_guest c
		WHERE b.hotel_group_id = 1 AND b.hotel_id = 101 AND b.accnt_type = 'armst' AND b.accnt_old = a.accnt
		AND b.accnt_new = c.id AND c.hotel_group_id = 1 AND c.hotel_id = 101 AND a.no <> '' ;
-- 更新标记
UPDATE ar_master a,guest_relation b SET a.extra_flag = CONCAT(SUBSTRING(a.extra_flag,1,20),'1',SUBSTRING(a.extra_flag,22,9))
	WHERE a.hotel_group_id = 1 AND a.hotel_id = 101 AND a.id = b.slave_id AND b.hotel_group_id = 1 AND b.hotel_id = 101
		AND b.relation_code = 'GUEST_AR';

/*
SELECT * FROM guest_relation a,up_map_accnt b,guest_base c WHERE b.hotel_group_id = 1 AND b.hotel_id = 101 AND 
(b.accnt_type = 'GUEST_FIT' OR b.accnt_type = 'GUEST_GRP') AND b.accnt_old = a.host_id AND a.hotel_group_id = 1 AND a.hotel_id = 101 AND b.accnt_new = c.id AND c.hotel_group_id = 101 AND a.relation_code = 'GUEST_AR';
*/

-- 更新新账号及姓名
UPDATE guest_relation a,up_map_accnt b,guest_base c SET a.host_id = b.accnt_new,a.host_name = c.name
WHERE b.hotel_group_id = 1 AND b.hotel_id = 101 AND 
(b.accnt_type = 'GUEST_FIT' OR b.accnt_type = 'GUEST_GRP') AND b.accnt_old = a.host_id AND a.hotel_group_id = 1 AND a.hotel_id = 101 AND b.accnt_new = c.id AND c.hotel_group_id = 1 AND a.relation_code = 'GUEST_AR';

-- SELECT * FROM guest_relation WHERE hotel_group_id = 1 AND hotel_id = 1  AND relation_code = 'GUEST_AR' AND host_name = '';
-- 删除已在原西软Guest表不存在的数据

DELETE FROM guest_relation WHERE hotel_group_id = 1 AND hotel_id = 101 AND host_name = '' AND relation_code = 'GUEST_AR';






