UPDATE master_guest a, up_map_accnt b, migrate_xmyh.master c SET a.phone=c.phone 
WHERE a.hotel_group_id =  1 AND a.hotel_id = 1 
	AND b.hotel_group_id =  1 AND b.hotel_id = 1 
	AND a.id=b.accnt_new AND b.accnt_old=c.accnt 
	AND b.accnt_type IN ('master_si', 'master_r', 'comsume')
	AND a.phone='' AND c.phone <>'';


INSERT INTO code_base (hotel_group_id,hotel_id,CODE,parent_code,descript,descript_en,max_len,flag,
code_category,is_sys,is_group,group_code,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime,code_type) 

SELECT 1,1,CODE,'profile_class2',descript,descript1,'10','','','F','T','','F','0','ADMIN','2013-06-06 10:37:31','ADMIN','2013-06-06 10:37:31',''
FROM migrate_xmyh.basecode WHERE cat='cuscls2';

INSERT INTO code_base (hotel_group_id,hotel_id,CODE,parent_code,descript,descript_en,max_len,flag,
code_category,is_sys,is_group,group_code,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime,code_type) 

SELECT 1,1,CODE,'profile_class3',descript,descript1,'10','','','F','T','','F','0','ADMIN','2013-06-06 10:37:31','ADMIN','2013-06-06 10:37:31',''
FROM migrate_xmyh.basecode WHERE cat='cuscls3';

INSERT INTO code_base (hotel_group_id,hotel_id,CODE,parent_code,descript,descript_en,max_len,flag,
code_category,is_sys,is_group,group_code,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime,code_type) 

SELECT 1,1,CODE,'profile_class4',descript,descript1,'10','','','F','T','','F','0','ADMIN','2013-06-06 10:37:31','ADMIN','2013-06-06 10:37:31',''
FROM migrate_xmyh.basecode WHERE cat='cuscls4';


UPDATE master_base a,migrate_xmyh.master b,up_map_accnt c SET a.amenities = b.amenities WHERE a.hotel_group_id =  1 AND a.hotel_id = 1
AND c.hotel_group_id =  1 AND c.hotel_id = 1 AND c.accnt_type IN ('master_r','master_si') AND a.id=c.accnt_new
AND b.accnt=c.accnt_old


UPDATE company_base a,up_map_accnt b,migrate_xmyh.guest c SET a.register_no=c.regno
WHERE a.hotel_group_id =  1 AND a.hotel_id=0 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.id=b.accnt_new
AND b.accnt_old=c.no AND b.accnt_type='company' AND a.register_no<>c.regno AND c.regno<>''
AND c.class IN ('C','A','S');

UPDATE company_base a,up_map_accnt b,migrate_xmyh.guest c SET a.bank_name=c.bank
WHERE a.hotel_group_id =  1 AND a.hotel_id=0 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.id=b.accnt_new
AND b.accnt_old=c.no AND b.accnt_type='company' AND a.bank_name<>c.bank AND c.bank<>''
AND c.class IN ('C','A','S');

UPDATE company_base a,up_map_accnt b,migrate_xmyh.guest c SET a.bank_account=c.bankno
WHERE a.hotel_group_id =  1 AND a.hotel_id=0 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.id=b.accnt_new
AND b.accnt_old=c.no AND b.accnt_type='company' AND a.bank_account<>c.bankno AND c.bankno<>''
AND c.class IN ('C','A','S');

UPDATE company_base a,up_map_accnt b,migrate_xmyh.guest c SET a.tax_no=c.taxno
WHERE a.hotel_group_id =  1 AND a.hotel_id=0 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.id=b.accnt_new
AND b.accnt_old=c.no AND b.accnt_type='company' AND a.tax_no<>c.taxno AND c.taxno<>''
AND c.class IN ('C','A','S');


UPDATE company_production a,up_map_accnt b,migrate_xmyh.guest c SET a.production_rm=c.rm
WHERE a.hotel_group_id =  1 AND a.hotel_id = 1 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.company_id=b.accnt_new
AND b.accnt_old=c.no AND b.accnt_type='company';

UPDATE company_production a,up_map_accnt b,migrate_xmyh.guest c SET a.production_rm=c.rm
WHERE a.hotel_group_id =  1 AND a.hotel_id=0 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.company_id=b.accnt_new
AND b.accnt_old=c.no AND b.accnt_type='company';

UPDATE company_production a,up_map_accnt b,migrate_xmyh.guest c SET a.production_fb=c.fb
WHERE a.hotel_group_id =  1 AND a.hotel_id = 1 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.company_id=b.accnt_new
AND b.accnt_old=c.no AND b.accnt_type='company';

UPDATE company_production a,up_map_accnt b,migrate_xmyh.guest c SET a.production_fb=c.fb
WHERE a.hotel_group_id =  1 AND a.hotel_id=0 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.company_id=b.accnt_new
AND b.accnt_old=c.no AND b.accnt_type='company';

UPDATE company_production a,up_map_accnt b,migrate_xmyh.guest c SET a.production_ttl=c.tl
WHERE a.hotel_group_id =  1 AND a.hotel_id = 1 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.company_id=b.accnt_new
AND b.accnt_old=c.no AND b.accnt_type='company';

UPDATE company_production a,up_map_accnt b,migrate_xmyh.guest c SET a.production_ttl=c.tl
WHERE a.hotel_group_id =  1 AND a.hotel_id=0 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.company_id=b.accnt_new
AND b.accnt_old=c.no AND b.accnt_type='company';

UPDATE master_guest a,migrate_xmyh.master b,up_map_accnt c SET a.mobile = b.phone WHERE a.hotel_group_id =  1 AND a.hotel_id = 1
AND c.hotel_group_id =  1 AND c.hotel_id = 1 AND c.accnt_type IN ('master_r','master_si') AND a.id=c.accnt_new
AND b.accnt=c.accnt_old

UPDATE master_guest a,migrate_xmyh.master b,up_map_accnt c SET a.fax = b.fax WHERE a.hotel_group_id =  1 AND a.hotel_id = 1
AND c.hotel_group_id =  1 AND c.hotel_id = 1 AND c.accnt_type IN ('master_r','master_si') AND a.id=c.accnt_new
AND b.accnt=c.accnt_old

UPDATE company_base a,migrate_xmyh.guest b,up_map_accnt c SET a.city = b.town WHERE a.hotel_group_id =  1 AND a.hotel_id=0
AND c.hotel_group_id =  1 AND c.hotel_id = 1 AND c.accnt_type IN ('company') AND a.id=c.accnt_new
AND b.no=c.accnt_old AND b.class IN ('C','S','A')

UPDATE company_type a,migrate_xmyh.guest b,up_map_accnt c SET a.latency = b.latency WHERE a.hotel_group_id =  1 AND a.hotel_id = 1
AND c.hotel_group_id =  1 AND c.hotel_id = 1 AND c.accnt_type IN ('company') AND a.company_id=c.accnt_new
AND b.no=c.accnt_old AND b.class IN ('C','S','A')

-- 修复AR信用的灯
UPDATE ar_master a SET a.extra_flag = CONCAT(SUBSTR(extra_flag,1,19),(SELECT COUNT(1) cnt FROM accredit b WHERE b.accnt_type = 'A' AND b.accnt = a.id) ,SUBSTR(extra_flag,21,10));
UPDATE accredit SET ta_code = '9930' WHERE ta_code = '9600';

-- 修复AR离开时间
UPDATE ar_master a,up_map_accnt b,migrate_xmyh.ar_master c SET a.dep=c.dep
WHERE a.hotel_group_id =  1 AND a.hotel_id = 1 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.id=b.accnt_new
AND b.accnt_old=c.accnt AND b.accnt_type='armst' AND a.ar_category='E' AND c.artag1='E';

-- 更新首次入住时间、房号、房价
UPDATE company_production a,up_map_accnt b,migrate_xmyh.guest c SET a.first_visit_date=c.fv_date,a.first_visit_room=c.fv_room,a.first_visit_rate=c.fv_rate
WHERE a.hotel_group_id =  1 AND a.hotel_id = 1 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.company_id=b.accnt_new
AND b.accnt_old=c.no AND b.accnt_type='company';

-- 更新最近入住时间、房号、房价
UPDATE company_production a,up_map_accnt b,migrate_xmyh.guest c SET a.last_visit_date=c.lv_date,a.last_visit_room=c.lv_room,a.last_visit_rate=c.lv_rate
WHERE a.hotel_group_id =  1 AND a.hotel_id = 1 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.company_id=b.accnt_new
AND b.accnt_old=c.no AND b.accnt_type='company';

-- 更新AR账的电话和手机
UPDATE ar_master a,up_map_accnt b,migrate_xmyh.ar_master c,migrate_xmyh.guest d SET a.phone=d.mobile
WHERE a.hotel_group_id =  1 AND a.hotel_id = 1 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.id=b.accnt_new
AND b.accnt_old=c.accnt AND b.accnt_type='armst' AND c.haccnt=d.no AND d.mobile<>'';
UPDATE ar_master a,up_map_accnt b,migrate_xmyh.ar_master c,migrate_xmyh.guest d SET a.phone=d.phone
WHERE a.hotel_group_id =  1 AND a.hotel_id = 1 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.id=b.accnt_new
AND b.accnt_old=c.accnt AND b.accnt_type='armst' AND c.haccnt=d.no AND d.phone<>'' AND a.phone='';

-- 更新AR账时间
UPDATE ar_account a,up_map_accnt b,migrate_xmyh.ar_detail c SET a.create_datetime=c.log_date,a.modify_datetime=c.log_date
	WHERE a.hotel_group_id =  1 AND a.hotel_id = 1 AND b.hotel_group_id =  1 AND b.hotel_id = 1
	AND a.accnt=b.accnt_new AND b.accnt_old=c.accnt AND a.number=c.number AND b.accnt_type='armst';
	
-- 更新 name_combine 和 name4不一致
SELECT a.name_combine,c.name4 FROM company_base a,up_map_accnt b,migrate_xmyh.guest c
WHERE a.hotel_group_id =  1 AND a.hotel_id=0 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.id=b.accnt_new
AND b.accnt_old=c.no AND b.accnt_type='company' AND a.name_combine<>c.name4;

UPDATE company_base a,up_map_accnt b,migrate_xmyh.guest c SET a.name_combine=c.name4
WHERE a.hotel_group_id =  1 AND a.hotel_id=0 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.id=b.accnt_new
AND b.accnt_old=c.no AND b.accnt_type='company' AND a.name_combine<>c.name4;

UPDATE company_base a,up_map_accnt b,migrate_xmyh.guest c SET a.name2=TRIM(c.name2)
WHERE a.hotel_group_id =  1 AND a.hotel_id=0 AND b.hotel_group_id =  1 AND b.hotel_id = 1 AND a.id=b.accnt_new
AND b.accnt_old=c.no AND b.accnt_type='company' AND a.name2<>c.name2;
-- 更新 guest_base 协议单位
UPDATE guest_base a,up_map_accnt b,company_base c SET a.company_id=c.id
WHERE a.hotel_group_id =  1 AND a.hotel_id=0 AND c.hotel_group_id =  1 AND c.hotel_id=0
AND a.company_id=b.accnt_old AND b.accnt_new=c.id AND b.accnt_type='COMPANY' AND a.company_id<>0
AND b.hotel_group_id =  1 AND b.hotel_id = 1;






