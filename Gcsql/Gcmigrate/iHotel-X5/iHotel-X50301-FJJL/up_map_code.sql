--  basecode,reason,pccode,mktcode,restype,saleid，srccode
-- 客房布置
-- SELECT * FROM basecode WHERE cat='amenities'  ORDER BY CODE;
INSERT INTO portal_pms.up_map_code(hotel_group_id,hotel_id,CODE,code_old,code_old_des,code_new,code_new_des,remark)
SELECT  2,11,'amenities',CODE,descript,'','','客房布置' FROM migrate_db.basecode WHERE cat='amenities';

-- ar账户类别--ar_tag
-- SELECT * FROM basecode WHERE cat='artag1'  ORDER BY CODE;
INSERT INTO portal_pms.up_map_code(hotel_group_id,hotel_id,CODE,code_old,code_old_des,code_new,code_new_des,remark)
SELECT  2,11,'ar_tag',CODE,descript,'','','应收账户类别' FROM migrate_db.basecode WHERE cat='artag1';

-- 黑名单类别   blkcls
-- SELECT * FROM basecode WHERE cat='blkcls'  ORDER BY CODE;
INSERT INTO portal_pms.up_map_code(hotel_group_id,hotel_id,CODE,code_old,code_old_des,code_new,code_new_des,remark)
SELECT  2,11,'blkcls',CODE,descript,'','','黑名单' FROM migrate_db.basecode WHERE cat='blkcls';   
 
-- 渠道  channel
-- SELECT * FROM basecode WHERE cat='channel'  ORDER BY CODE;
INSERT INTO portal_pms.up_map_code (hotel_group_id,hotel_id,CODE,code_old,code_old_des,code_new,code_new_des,remark)
SELECT  2,11,'channel',CODE,descript,'','','渠道码' FROM migrate_db.basecode WHERE cat='channel';   
  
-- 优惠  code_reason
-- select code,descript from reason where halt='F' and 1=1;
INSERT INTO portal_pms.up_map_code(hotel_group_id,hotel_id,CODE,code_old,code_old_des,code_new,code_new_des,remark)
SELECT  2,11,'code_reason',CODE,descript,'','','优惠明细' FROM migrate_db.reason ;   
  
-- 证件类型  idcode
-- SELECT * FROM basecode WHERE cat='idcode'  ORDER BY CODE;
INSERT INTO portal_pms.up_map_code (hotel_group_id,hotel_id,CODE,code_old,code_old_des,code_new,code_new_des,remark)
SELECT  2,11,'idcode',CODE,descript,'','','证件类型' FROM migrate_db.basecode WHERE cat='idcode';   

-- 兴趣爱好  interest
-- SELECT * FROM basecode WHERE cat='interest'  ORDER BY CODE;
INSERT INTO portal_pms.up_map_code(hotel_group_id,hotel_id,CODE,code_old,code_old_des,code_new,code_new_des,remark)
SELECT  2,11,'interest',CODE,descript,'','','兴趣爱好' FROM migrate_db.basecode WHERE cat='interest';

-- 市场码  mktcode
-- SELECT * FROM mktcode WHERE cat='interest'  ORDER BY CODE;
INSERT INTO portal_pms.up_map_code (hotel_group_id, hotel_id, CODE, code_old, code_old_des, code_new, code_new_des, remark) 
SELECT  2,11, 'mktcode', CODE, descript, '', '', '市场码' FROM migrate_db.mktcode; 
 
-- 付款码  paymth
-- SELECT * FROM pccode WHERE pccode>=9000 ORDER BY pccode;
INSERT INTO portal_pms.up_map_code (hotel_group_id, hotel_id, CODE, code_old, code_old_des, code_new, code_new_des, remark) 
SELECT  2,11, 'paymth', pccode, descript, '', '', '付款码' FROM migrate_db.pccode WHERE pccode>=9000 ORDER BY pccode;  

-- 费用码  pccode
-- SELECT * FROM pccode WHERE pccode<9000 ORDER BY pccode;
INSERT INTO portal_pms.up_map_code (hotel_group_id, hotel_id, CODE, code_old, code_old_des, code_new, code_new_des, remark) 
SELECT  2,11, 'pccode', pccode, descript, '', '', '费用码' FROM migrate_db.pccode WHERE pccode<9000 ORDER BY pccode; 

-- 房价码  ratecode
-- SELECT * FROM rmratecode  ORDER BY code;
INSERT INTO portal_pms.up_map_code (hotel_group_id, hotel_id, CODE, code_old, code_old_des, code_new, code_new_des, remark) 
SELECT  2,11, 'ratecode', CODE, descript, '', '', '房价码' FROM migrate_db.rmratecode  ORDER BY CODE; 

-- 换房原因  rmreason
-- SELECT * FROM basecode WHERE cat='rmreason'  ORDER BY CODE;
INSERT INTO portal_pms.up_map_code (hotel_group_id, hotel_id, CODE, code_old, code_old_des, code_new, code_new_des, remark) 
SELECT  2,11, 'rmreason', CODE, descript, '', '', '换房原因' FROM migrate_db.basecode WHERE cat='rmreason';

-- 预订取消原因  rsv_cancle
-- SELECT * FROM basecode WHERE cat='rescancel'  ORDER BY CODE;
INSERT INTO portal_pms.up_map_code (hotel_group_id, hotel_id, CODE, code_old, code_old_des, code_new, code_new_des, remark) 
SELECT  2,11, 'rsv_cancle', CODE, descript, '', '', '预订取消原因' FROM migrate_db.basecode WHERE cat='rescancel'; 

-- 预订类型  rsv_type
-- SELECT * FROM restype   ORDER BY CODE;
INSERT INTO portal_pms.up_map_code (hotel_group_id, hotel_id, CODE, code_old, code_old_des, code_new, code_new_des, remark) 
SELECT  2,11, 'rsv_type', CODE, descript, '', '', '预订类型' FROM migrate_db.restype   ORDER BY CODE; 
  
-- 销售员  salesman
-- SELECT * FROM saleid   ORDER BY CODE;
INSERT INTO portal_pms.up_map_code (hotel_group_id, hotel_id, CODE, code_old, code_old_des, code_new, code_new_des, remark) 
SELECT  2,11, 'salesman', CODE, name, '', '', '销售员' FROM migrate_db.saleid   ORDER BY CODE;   

 -- 保密  secret
-- SELECT * FROM basecode WHERE cat='secret'  ORDER BY CODE;
INSERT INTO portal_pms.up_map_code (hotel_group_id, hotel_id, CODE, code_old, code_old_des, code_new, code_new_des, remark) 
SELECT  2,11, 'secret', CODE, descript, '', '', '保密' FROM migrate_db.basecode WHERE cat='secret';
 
 -- 来源码 srccode
-- SELECT * FROM srccode   ORDER BY CODE;
INSERT INTO portal_pms.up_map_code (hotel_group_id, hotel_id, CODE, code_old, code_old_des, code_new, code_new_des, remark) 
SELECT  2,11, 'srccode', CODE, descript, '', '', '来源码' FROM migrate_db.srccode   ORDER BY CODE; 

-- 房型  typim
-- SELECT * FROM typim  ORDER BY type;
INSERT INTO portal_pms.up_map_code (hotel_group_id, hotel_id, CODE, code_old, code_old_des, code_new, code_new_des, remark) 
SELECT  2,11, 'typim', TYPE, descript, '', '', '房型' FROM migrate_db.typim   ORDER BY TYPE;  

-- 升级理由  up_reason
-- SELECT * FROM basecode WHERE cat='up_reason'  ORDER BY CODE;
INSERT INTO portal_pms.up_map_code (hotel_group_id, hotel_id, CODE, code_old, code_old_des, code_new, code_new_des, remark) 
SELECT  2,11, 'up_reason', CODE, descript, '', '', '升级理由' FROM migrate_db.basecode WHERE cat='up_reason'  ORDER BY CODE;   

 -- vip等级  vip
-- SELECT * FROM basecode WHERE cat='vip'  ORDER BY CODE;
INSERT INTO portal_pms.up_map_code (hotel_group_id, hotel_id, CODE, code_old, code_old_des, code_new, code_new_des, remark)
SELECT  2,11, 'vip', CODE, descript, '', '', 'vip等级' FROM migrate_db.basecode WHERE cat='vip'  ORDER BY CODE;   

-- 签证类型  visaid
-- SELECT * FROM basecode WHERE cat='visaid'  ORDER BY CODE;
INSERT INTO portal_pms.up_map_code (hotel_group_id, hotel_id, CODE, code_old, code_old_des, code_new, code_new_des, remark)
SELECT  2,11, 'visaid', CODE, descript, '', '', '签证类型' FROM migrate_db.basecode WHERE cat='visaid'  ORDER BY CODE; 

 -- 营业日报表 jourrrep
-- SELECT * FROM migrate_db.jourrep;
INSERT INTO portal_pms.up_map_code (hotel_group_id, hotel_id, CODE, code_old, code_old_des, code_new, code_new_des, remark)
SELECT  2,11, 'jourrep', class, descript, '', '', '营业日报' FROM migrate_db.jourrep ORDER BY class;