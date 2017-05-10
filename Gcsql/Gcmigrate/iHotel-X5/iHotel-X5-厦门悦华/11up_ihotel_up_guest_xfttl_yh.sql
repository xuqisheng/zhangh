DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_up_guest_xfttl_xsw`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_up_guest_xfttl_xsw`(
	arg_hotel_group_id	BIGINT(16),
	arg_hotel_id		BIGINT(16)
)
SQL SECURITY INVOKER
label_0:
BEGIN

	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='XFTTL';
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark) VALUES(arg_hotel_id,'XFTTL',NOW(),NULL,0,''); 
		
	DELETE FROM statistic_y WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	-- 协议单位
	INSERT INTO statistic_y (hotel_group_id,hotel_id,YEAR,cat,grp,CODE,month01,month02,month03,month04,month05,month06,month07,month08,month09,month10,month11,month12,month99)
	SELECT b.hotel_group_id,b.hotel_id,a.year,TRIM(a.tag),b.accnt_class,b.accnt_new,a.m1,a.m2,a.m3,a.m4,a.m5,a.m6,a.m7,a.m8,a.m9,a.m10,a.m11,a.m12,a.ttl 
		FROM migrate_db.guest_xfttl a,up_map_accnt b 
		WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.accnt_type='COMPANY' AND a.no=b.accnt_old;
		
	-- 团队
	INSERT INTO statistic_y (hotel_group_id,hotel_id,YEAR,cat,grp,CODE,month01,month02,month03,month04,month05,month06,month07,month08,month09,month10,month11,month12,month99)
	SELECT b.hotel_group_id,b.hotel_id,a.year,TRIM(a.tag),'G',b.accnt_new,a.m1,a.m2,a.m3,a.m4,a.m5,a.m6,a.m7,a.m8,a.m9,a.m10,a.m11,a.m12,a.ttl 
		FROM migrate_db.guest_xfttl a,up_map_accnt b 
		WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.accnt_type='GUEST_GRP' AND a.no=b.accnt_old;
	
	-- 散客
	INSERT INTO statistic_y (hotel_group_id,hotel_id,YEAR,cat,grp,CODE,month01,month02,month03,month04,month05,month06,month07,month08,month09,month10,month11,month12,month99)
	SELECT b.hotel_group_id,b.hotel_id,a.year,TRIM(a.tag),'F',b.accnt_new,a.m1,a.m2,a.m3,a.m4,a.m5,a.m6,a.m7,a.m8,a.m9,a.m10,a.m11,a.m12,a.ttl 
		FROM migrate_db.guest_xfttl a,up_map_accnt b 
		WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.accnt_type='GUEST_FIT' AND a.no=b.accnt_old;	
	
	UPDATE statistic_y SET cat='yielddb_revenus_fb' 	WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat='FB';
	UPDATE statistic_y SET cat='yielddb_rooms_nights' 	WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat='NIGHTS';	
	UPDATE statistic_y SET cat='yielddb_revenus_extras' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat='OT';
	UPDATE statistic_y SET cat='yielddb_revenus_room' 	WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat='RM';		
	UPDATE statistic_y SET cat='yielddb_revenus_total' 	WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat='TTL';		
	
	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='XFTTL';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='XFTTL';
		
END$$

DELIMITER ;