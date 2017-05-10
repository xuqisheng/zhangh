SELECT * FROM master_base WHERE  hotel_group_id = 1 AND hotel_id = 1 AND link_id = 0 AND id <> rsv_id AND sta = 'I'
-- 1、检查是否存在有冲突的数据（概率低）
SELECT * FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 AND link_id IN (SELECT id FROM master_base WHERE link_id = 0);
-- 2、如存在有冲突的数据，须看情况逐一修改

-- 3、无冲突数据直接执行修改
UPDATE master_base SET link_id = id WHERE hotel_group_id = 1 AND hotel_id = 1 AND link_id = 0;

-- 4、更新联房序列号
UPDATE sys_extra_id a, hotel b SET a.pos_cur = (SELECT MAX(link_id) FROM master_base WHERE hotel_group_id = b.hotel_group_id AND hotel_id = b.id) WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.id AND a.code = 'LINKNO';