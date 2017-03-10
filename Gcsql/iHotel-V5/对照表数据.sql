SELECT * FROM migrate_xc.up_map_code WHERE hotel_id=105 GROUP BY cat

SELECT * FROM portal.up_map_code WHERE hotel_id=103  GROUP BY cat

INSERT INTO migrate_xc.up_map_code SELECT 1,105,cat,code_old,code_old_des,code_new,code_new_des
FROM portal.up_map_code WHERE hotel_group_id=1 AND hotel_id=103 AND cat IN ('country','idcode','nation');

INSERT INTO migrate_xc.up_map_code SELECT 1,105,cat,code_old,code_old_des,code_new,code_new_des
FROM portal.up_map_code WHERE hotel_group_id=1 AND hotel_id=103 AND cat IN ('mktcode','mktcode_g');

INSERT INTO migrate_xc.up_map_code 
SELECT 1,105,'pccode',CONCAT(pccode,servcode),descript2,'',''
FROM migrate_xc.chgcod;

INSERT INTO migrate_xc.up_map_code 
SELECT 1,105,'paymth',paycode,descript2,'',''
FROM migrate_xc.paymth;

INSERT INTO migrate_xc.up_map_code 
SELECT 1,105,'paymth',CONCAT(tag1,'0'),descript2,'',''
FROM migrate_xc.paymth;

INSERT INTO migrate_xc.up_map_code 
SELECT 1,105,'rmtype',TYPE,descript,'',''
FROM migrate_xc.typim;

INSERT INTO migrate_xc.up_map_code 
SELECT 1,105,'salesman',CODE,descript,'',''
FROM migrate_xc.saleid;


