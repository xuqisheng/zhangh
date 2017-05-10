SELECT * FROM migrate_xmyh.guest;

SELECT * FROM up_map_code WHERE hotel_group_id = 1 AND hotel_id = 1;

INSERT INTO up_map_code SELECT * FROM portal.up_map_code

SELECT COUNT(1) FROM up_map_accnt WHERE hotel_group_id = 1 AND hotel_id = 1;


SELECT * FROM hotel


SELECT rmtype,COUNT(1) FROM room_no WHERE hotel_group_id = 1 AND hotel_id = 1 GROUP BY rmtype ORDER BY rmtype;

SELECT CODE,quantity,over_quan,is_halt FROM room_type WHERE hotel_group_id =1 AND hotel_id = 1 ORDER BY CODE

SELECT accnt,rmno,master_id FROM rsv_src WHERE hotel_group_id = 1 AND hotel_id = 1 AND occ_flag = 'MF' ORDER BY rmno,master_id


SELECT * FROM rsv_src AS a WHERE hotel_group_id = 1 AND hotel_id = 1
AND NOT EXISTS (SELECT 1 FROM room_type WHERE hotel_group_id = 1 AND hotel_id = 1 
 AND CODE = a.rmtype)
 
 
SELECT * FROM rsv_rmtype_total AS a WHERE hotel_group_id = 1 AND hotel_id = 1
AND NOT EXISTS (SELECT 1 FROM room_type WHERE hotel_group_id = 1 AND hotel_id = 1 
 AND CODE = a.rmtype AND a.rmtype_num = quantity)
 
 
SELECT * FROM master_base AS a WHERE hotel_group_id = 1 AND hotel_id = 1 
AND EXISTS (SELECT 1 FROM rsv_src WHERE hotel_group_id = 1 AND hotel_id = 1
AND accnt = a.id AND master_id <> a.master_id)

SELECT * FROM rsv_src AS a WHERE hotel_group_id = 1 AND hotel_id = 1 AND occ_flag = 'MF'
AND  NOT EXISTS (SELECT 1 FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1
AND a.accnt = id AND is_resrv = 'F' AND id<> rsv_id)


 

SELECT GROUP_CONCAT(accnt) FROM rsv_src AS a WHERE hotel_group_id = 1 AND hotel_id = 1 AND occ_flag IN ('RF','RG')
AND  NOT EXISTS (SELECT 1 FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1
AND a.accnt = id AND is_resrv = 'T' AND id= rsv_id)


SELECT * FROM rsv_src AS a WHERE hotel_group_id = 1 AND hotel_id = 1 AND occ_flag IN ('RF','RG')
AND  NOT EXISTS (SELECT 1 FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1
AND a.accnt = id AND is_resrv = 'T' AND id= rsv_id);

SELECT * FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 AND grp_accnt > 0 AND
id <> rsv_id AND is_resrv = 'T';

UPDATE master_base SET is_resrv = 'F' WHERE hotel_group_id = 1 AND hotel_id = 1 AND grp_accnt > 0 AND
id <> rsv_id AND is_resrv = 'T';


DELETE FROM rsv_src WHERE hotel_group_id = 1 AND hotel_id = 1 AND occ_flag IN('RF') AND accnt IN(3216,3217,3218,3219,3220,3221,3222,3235,3304,3328,3329,3330,3331,3332,3429,3501,3502,3503,3504,3515,3528,3534,3535,3559,3725,3726,3727,3770,3918,4496,4496,4496);

SELECT * FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 AND id = 4496;
SELECT * FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 AND rsv_id = 4496;


SELECT * FROM master_base WHERE id IN ( 4496,4496,4496)


SELECT GROUP_CONCAT(DISTINCT rsv_id) FROM master_base WHERE id IN (4496,4496,4496) 

SELECT * FROM master_base WHERE id IN (3921,3926,3931,3932,3934,3938,3935,3939,3940,3941,3964,3947,4495,4496)

SELECT * FROM up_map_accnt WHERE accnt_new=  4496;