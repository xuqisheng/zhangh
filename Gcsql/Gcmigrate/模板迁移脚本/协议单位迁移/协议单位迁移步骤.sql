SELECT * FROM portal_group.hotel WHERE hotel_group_id = 11;

SELECT a.accnt,a.no,a.name,a.valid_begin,a.valid_end,a.sys_cat,a.linkman1,a.ratecode,a.mobile,a.phone,a.fax,a.saleman,a.street
	FROM migrate_db.company a  ;
	
SELECT * FROM migrate_db.company;

SELECT * FROM portal_group.sales_man WHERE hotel_group_id = 11;	
-- 修改销售员 应该从对照表取数
UPDATE migrate_db.company SET saleman = 'TJ' WHERE saleman = '唐俊';
UPDATE migrate_db.company SET sys_cat = 'C' ;

SELECT * FROM portal_group.company_base WHERE hotel_group_id = 11;
-- 导入协议单位
CALL up_ihotel_up_company(11,23,@ret);

SELECT * FROM company_base WHERE hotel_group_id = 11;

SELECT * FROM profile_extra WHERE hotel_group_id=11 AND hotel_id = 23 AND extra_item = 'RATECODE' AND master_type = 'COMPANY';
-- 生成协议单位房价码信息
CALL up_fill_company_profile_extra(11,23);

UPDATE company_base SET mobile = SUBSTRING(mobile,1,INSTR(mobile,'.')-1) WHERE hotel_group_id = 11 AND INSTR(mobile,'.')>0;
 
SELECT * FROM company_type WHERE hotel_group_id = 11;

UPDATE company_type SET valid_begin = DATE(NOW()),valid_end = DATE_ADD(NOW(),INTERVAL 1 YEAR) WHERE hotel_group_id = 11
AND valid_begin IS NULL;

UPDATE company_type SET valid_end = DATE(valid_end) WHERE hotel_group_id = 11
AND valid_end >='2017.5.2';

UPDATE profile_extra SET date_begin = DATE(NOW()),date_end = DATE_ADD(DATE(NOW()),INTERVAL 1 YEAR) WHERE hotel_group_id = 11
AND date_begin IS NULL;

SELECT * FROM portal_f.company_base WHERE hotel_group_id = 11;
-- 插入pms库
INSERT INTO portal_f.company_base 
SELECT a.* FROM portal_group.company_base a,portal_group.up_map_accnt b
WHERE a.hotel_group_id = 11 AND a.id = b.accnt_new AND b.hotel_group_id = 11 AND b.hotel_id = 23 AND b.accnt_type = 'COMPANY';

INSERT INTO portal_f.company_type 
SELECT a.* FROM portal_group.company_type a,portal_group.up_map_accnt b
WHERE a.hotel_group_id = 11 AND a.company_id = b.accnt_new AND b.hotel_group_id = 11 AND b.hotel_id = 23 AND b.accnt_type = 'COMPANY';

INSERT INTO portal_f.profile_extra
SELECT a.* FROM portal_group.profile_extra a,portal_group.up_map_accnt b
WHERE a.hotel_group_id = 11 AND a.master_id = b.accnt_new AND b.hotel_group_id = 11 AND b.hotel_id = 23 AND b.accnt_type = 'COMPANY';
