SELECT a.* FROM  rsv_src AS a WHERE hotel_group_id = 1 AND hotel_id = 1 AND occ_flag = 'MF' AND dep_date = '2014-12-18'
AND NOT EXISTS (SELECT 1 FROM real_time_room_sta WHERE hotel_group_id = 1 AND hotel_id = 1 
AND rmno = a.rmno  AND is_dep= 'T')


SELECT id,accnt,rmtype,rmno,master_id,arr_date,dep_date FROM rsv_src WHERE hotel_group_id = 1 AND hotel_id = 1 
AND occ_flag = 'MF' AND  dep_date = '2014-12-18'
AND rmno <> '' AND LEFT(rmno,1) <> '#'
ORDER BY rmno,master_id

SELECT id,rsv_id,rsv_class,rmno,master_id,real_rate,arr,dep FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 
AND rmno IN ('1101','1208','3305','3329','3330','3419','4309') ORDER BY rmno,master_id

-- 非法同住资源查看
SELECT accnt,rmno,arr_date,dep_date,rmnum,rsv_occ_id,master_id FROM rsv_src AS a WHERE hotel_group_id = 1 AND hotel_id = 1 AND occ_flag = 'MF' AND rmno <> '' AND a.arr_date <= '2014-12-18'
AND EXISTS(SELECT 1 FROM rsv_src WHERE hotel_group_id = 1 AND hotel_id = 1 AND occ_flag = 'MF' AND rmno = a.rmno AND id <> a.id AND a.master_id <> master_id AND arr_date <='2014.12.18')
ORDER BY rmno,master_id

SELECT id,sta,rsv_man,rmno,master_id,link_id FROM master_base WHERE hotel_id = 1 AND rmno = '1216';

SELECT * FROM rsv_src WHERE hotel_id = 1 ;

SELECT * FROM rsv_src WHERE rmtype NOT IN(SELECT CODE FROM room_type WHERE hotel_id = 1);
-- 查询是否有非法的房类
SELECT * FROM rsv_src AS a WHERE hotel_group_id = 1 AND hotel_id = 1 AND NOT EXISTS(SELECT 1 FROM room_type WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE = a.rmtype AND quantity > 0 AND is_halt = 'F')