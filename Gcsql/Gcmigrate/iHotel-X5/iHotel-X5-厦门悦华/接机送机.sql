-- 接机送机导入 车型对照
INSERT INTO portal.master_arrdep (hotel_group_id,hotel_id, master_type,master_id,trans_type,trans_date,trans_info,trans_car,
	trans_rate,trans_adult,trans_dest,extra_info,create_user,create_datetime,modify_user,modify_datetime)
SELECT 	1, 1, IF(b.accnt_type = 'master_r','RESRV','MASTER'),b.accnt_new, 'ARR',a.arrdate,a.arrinfo,a.arrcar,
	a.arrrate, '1', '','',a.cby,a.changed,a.cby,a.changed
	FROM  migrate_xmyh.master a,up_map_accnt b  WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND 
	(b.accnt_type = 'master_r' OR b.accnt_type = 'master_si') AND b.accnt_old = a.accnt 
	AND (a.arrinfo <> '' OR a.arrcar <> '')  ;

INSERT INTO portal.master_arrdep (hotel_group_id,hotel_id, master_type,master_id,trans_type,trans_date,trans_info,trans_car,
	trans_rate,trans_adult,trans_dest,extra_info,create_user,create_datetime,modify_user,modify_datetime)
SELECT 	1, 1, IF(b.accnt_type = 'master_r','RESRV','MASTER'),b.accnt_new, 'DEP',a.depdate,a.depinfo,a.depcar,
	a.deprate, '1', '','',a.cby,a.changed,a.cby,a.changed
	FROM  migrate_xmyh.master a,up_map_accnt b WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND 
	(b.accnt_type = 'master_r' OR b.accnt_type = 'master_si') AND b.accnt_old = a.accnt 
	AND (a.depinfo <> '' OR a.depcar <> '') ;

UPDATE	master_arrdep a,rsv_src b SET a.master_type = 'MASTER' WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 
AND a.master_id = b.accnt AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.occ_flag = 'MF' AND a.master_type = 'RESRV';
	
SELECT * FROM master_arrdep WHERE hotel_group_id = 1 AND hotel_id = 1;
	
UPDATE 	master_arrdep a,up_map_code b SET a.trans_car = b.code_new WHERE a.hotel_group_id = 1
AND a.hotel_id = 1 AND a.trans_car = b.code_old AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code = 'car';
