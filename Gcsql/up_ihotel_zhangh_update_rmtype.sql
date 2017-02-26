DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_update_rmtype`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_zhangh_update_rmtype`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_rmno				VARCHAR(10),
	IN arg_rmtype_new		VARCHAR(10)
)

	SQL SECURITY INVOKER

label_0:
BEGIN
	-- =========================================================
	--  房号对应的房类更新
	--  未测试
	-- 作者：zhangh
	-- 1、代码配置中房号对应房类先作修改
	-- 2、房态图-->帮助-->重建
	-- 3、检查以下各表里房号对应房类，是否正确
	-- =========================================================
	UPDATE room_no SET rmtype = arg_rmtype_new WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND code = arg_rmno;
	UPDATE real_time_room_sta SET rmtype = arg_rmtype_new WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rmno = arg_rmno;
	UPDATE rsv_occ SET rmtype = arg_rmtype_new WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rmno = arg_rmno;	
	UPDATE rsv_rmno SET rmtype = arg_rmtype_new WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rmno = arg_rmno;
	UPDATE rsv_rate SET rmtype = arg_rmtype_new WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rmno = arg_rmno;	
	UPDATE rsv_src SET rmtype = arg_rmtype_new WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rmno = arg_rmno;		
	UPDATE crs_rsv_src SET rmtype = arg_rmtype_new WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rmno = arg_rmno;
	UPDATE master_base SET rmtype = arg_rmtype_new WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rmno = arg_rmno AND sta IN ('I','R');
	
	
	UPDATE room_type a SET a.quantity = IFNULL((SELECT COUNT(1) FROM room_no b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.code=b.rmtype),0) WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id;
	
END$$

DELIMITER ;

-- CALL up_ihotel_zhangh_update_rmtype();
-- DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_update_rmtype`;