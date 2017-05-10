
INSERT INTO portal.lost_found_reg(hotel_group_id,hotel_id, bill_no,sta,goods_grade,goods_class,goods_name,remark,amount,pick_man,
	pick_address,pick_date,pick_descript,rep_man,rep_date,rep_phone,rep_address,host_guest_id,host_name,host_mobile,get_guest_id,
	get_name,get_idcls,get_ident,get_date,get_reason,get_phone,get_address,audit_user,lost_found_rep_id,lost_found_rep_bill_no,create_user,create_datetime,modify_user,modify_datetime)
SELECT  1,1,a.folio,'I',a.grade,a.class,a.goods,IF(a.refer <> '',CONCAT(a.descript,'//',a.refer),a.descript),a.amount,a.pick_man, 
	a.pick_add,a.pick_date,a.pick_thing,a.rep_man,a.rep_date,a.rep_phone,a.rep_address,NULL,NULL,NULL,NULL, 
	NULL,NULL, NULL,NULL, NULL,NULL,NULL,NULL,NULL, NULL,a.empno,a.date,a.empno,a.date
	FROM migrate_xmyh.swreg a ORDER BY a.folio;
SELECT * FROM lost_found_reg;

SELECT * FROM up_map_code WHERE hotel_id = 1 AND CODE = 'sw_class';

UPDATE lost_found_reg a,up_map_code b SET a.goods_class = b.code_new WHERE a.hotel_group_id = 1 AND a.hotel_id = 1
AND a.goods_class = b.code_old;