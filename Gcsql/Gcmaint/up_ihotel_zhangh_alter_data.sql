DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_alter_data`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_zhangh_alter_data`()

	SQL SECURITY INVOKER

label_0:
BEGIN
	-- =========================================================
	--  添加或修改某数据
	-- 
	-- 作者：zhangh
	-- =========================================================
	
	UPDATE report_category SET code = 'X' WHERE hotel_id = 0 AND code = 'OTHER';
	DELETE FROM report_category WHERE hotel_id <> 0 AND code = 'OTHER';	
	UPDATE report_center SET rep_category = 'X' WHERE rep_category = 'OTHER';
	
	
END$$

DELIMITER ;

CALL up_ihotel_zhangh_alter_data();
DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_alter_data`;